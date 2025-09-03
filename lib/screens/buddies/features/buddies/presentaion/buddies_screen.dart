import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/get_all_buddies_repository.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/get_all_buddies_response_model.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/get_conversation_list_response.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class BuddiesScreen extends StatefulWidget {
  const BuddiesScreen({Key? key}) : super(key: key);

  @override
  _BuddiesScreenState createState() => _BuddiesScreenState();
}

class _BuddiesScreenState extends State<BuddiesScreen> {
  final TextEditingController _searchActivityController = TextEditingController();
  int pageCount = 0;
  int resultPerPage = 20;
  int totalCount = 0;
  bool isSearch = false;
  List<AllBuddiesModel> allBuddiesList = [];
  List<AllBuddiesModel> allSearchBuddiesList = [];
  bool mainLoader = true;
  bool insideListLoader = false;
  ScrollController mScrollController = ScrollController();
  late ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getAllBuddies('');

      mScrollController.addListener(() {
        if (mScrollController.position.pixels == mScrollController.position.maxScrollExtent) {
          if (totalCount != allBuddiesList.length) {
            getAllBuddies('');
          }
        }
      });

      _searchActivityController.addListener(() {
        if (_searchActivityController.text.isNotEmpty) {
          debugPrint('Search -> ${_searchActivityController.text}');
          setState(() {
            isSearch = true;
            getAllBuddies(_searchActivityController.text);
          });
        } else {
          setState(() {
            isSearch = false;
            hideKeyboard();
            allSearchBuddiesList.clear();
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Buddies',
        onBack: () {
          Navigator.of(context).pop();
        },
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(Constants.myFriendsScreen);
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0, top: 15, bottom: 15),
              child: CustomTextView(
                label: 'Your Friends',
                textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18, color: const Color(0xFF006590), fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _pullRefresh,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          border: Border.all(
                            color: const Color(0xFFF5F5F5),
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(10))),
                      child: SizedBox(
                        height: 40,
                        child: TextFormField(
                          autocorrect: false,
                          autofocus: false,
                          cursorColor: OQDOThemeData.greyColor,
                          minLines: 1,
                          controller: _searchActivityController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Image.asset(
                              'assets/images/ic_search_home.png',
                              height: 20,
                              width: 20,
                              fit: BoxFit.fill,
                            ),
                            hintText: 'Search your buddies ',
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  isSearch
                      ? Expanded(
                          child: RefreshIndicator(
                            onRefresh: _pullRefresh,
                            child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: allSearchBuddiesList.length,
                                controller: mScrollController,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                scrollDirection: Axis.vertical,
                                itemBuilder: (context, index) {
                                  AllBuddiesModel allBuddiesModel = allSearchBuddiesList[index];
                                  return singleSearchBuddyView(allBuddiesModel);
                                }),
                          ),
                        )
                      : mainLoader
                          ? const Expanded(
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : Expanded(
                              child: allBuddiesList.isNotEmpty
                                  ? Stack(
                                      children: [
                                        ListView.builder(
                                            physics: const AlwaysScrollableScrollPhysics(),
                                            itemCount: allBuddiesList.length,
                                            controller: mScrollController,
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            scrollDirection: Axis.vertical,
                                            itemBuilder: (context, index) {
                                              AllBuddiesModel allBuddiesModel = allBuddiesList[index];
                                              return singleBuddyView(allBuddiesModel);
                                            }),
                                        insideListLoader
                                            ? const Padding(
                                                padding: EdgeInsets.only(bottom: 10.0),
                                                child: Align(
                                                  alignment: Alignment.bottomCenter,
                                                  child: CircularProgressIndicator(),
                                                ),
                                              )
                                            : const SizedBox(
                                                height: 0,
                                                width: 0,
                                              ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        Image.asset(
                                          'assets/images/ic_empty_view.png',
                                          fit: BoxFit.fill,
                                          height: 400,
                                          width: 400,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        CustomTextView(
                                          label: 'Friends not available',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(fontSize: 16, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                            ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pullRefresh() async {
    allBuddiesList.clear();
    allSearchBuddiesList.clear();
    pageCount = 0;
    setState(() {
      mainLoader = true;
    });
    resultPerPage = 20;
    totalCount = 0;
    getAllBuddies('');
  }

  void showLoader() {
    setState(() {
      insideListLoader = true;
    });
  }

  void hideLoader() {
    setState(() {
      insideListLoader = false;
    });
  }

  Widget singleBuddyView(AllBuddiesModel allBuddiesModel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onTap: () async {
          var isChange = await Navigator.pushNamed(context, Constants.buddiesProfileScreen, arguments: allBuddiesModel);

          if (isChange != null && isChange == true) {
            setState(() {
              mainLoader = true;
            });
            pageCount = 0;
            totalCount = 0;
            allBuddiesList.clear();
            getAllBuddies('');
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            allBuddiesModel.profileImage!.isNotEmpty
                ? Card(
                    elevation: 0,
                    child: ClipPath(
                      clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                      child: Opacity(
                        opacity: 1,
                        child: Container(
                          width: 95,
                          height: 95,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).colorScheme.onBackground),
                          child: CachedNetworkImage(
                            imageUrl: allBuddiesModel.profileImage!,
                            fit: BoxFit.fill,
                            errorWidget: (context, url, error) {
                              return Image.asset(
                                "assets/images/profile_circle.png",
                                fit: BoxFit.fill,
                                width: 50,
                                height: 50,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  )
                : Image.asset(
                    "assets/images/profile_circle.png",
                    fit: BoxFit.fill,
                    width: 95,
                    height: 95,
                  ),
            const SizedBox(
              width: 15,
            ),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTextView(
                    label: '${allBuddiesModel.firstName} ${allBuddiesModel.lastName}',
                    maxLine: 3,
                    textOverFlow: TextOverflow.ellipsis,
                    type: styleSubTitle,
                    textStyle: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(color: const Color(0xFF2B2B2B), fontSize: 13.0, fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  CustomTextView(
                    label: allBuddiesModel.aboutYourSelf,
                    type: styleSubTitle,
                    textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: const Color(0xFF2B2B2B), fontSize: 11.0, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            GestureDetector(
              onTap: () async {
                if (allBuddiesModel.status!.isEmpty) {
                  sendFriendRequest(allBuddiesModel);
                } else if (allBuddiesModel.status == 'Requested') {
                  callAcceptReject(allBuddiesModel);
                } else if (allBuddiesModel.status == 'Response') {
                  var isChange = await Navigator.pushNamed(context, Constants.buddiesProfileScreen, arguments: allBuddiesModel);

                  if (isChange != null && isChange == true) {
                    setState(() {
                      mainLoader = true;
                    });
                    pageCount = 0;
                    totalCount = 0;
                    allBuddiesList.clear();
                    getAllBuddies('');
                  }
                } else if (allBuddiesModel.status == 'Friend') {
                  Conversation conversation = Conversation();
                  conversation.firstName = allBuddiesModel.firstName;
                  conversation.lastName = allBuddiesModel.lastName;
                  conversation.toEndUserId = allBuddiesModel.endUserId;
                  conversation.fromEndUserId = int.parse(OQDOApplication.instance.endUserID!);
                  conversation.profileImage = allBuddiesModel.profileImage;

                  var isChange = await Navigator.pushNamed(context, Constants.directFriendChatScreen, arguments: conversation);
                }
              },
              child: Image.asset(
                allBuddiesModel.status!.isNotEmpty
                    ? allBuddiesModel.status == 'Friend'
                        ? 'assets/images/ic_message_friend.png'
                        : allBuddiesModel.status == 'Requested'
                            ? 'assets/images/ic_friend_requested.png'
                            : allBuddiesModel.status == 'Response'
                                ? 'assets/images/ic_left_nav_arrow.png'
                                : 'assets/images/ic_add_friend.png'
                    : 'assets/images/ic_add_friend.png',
                height: 25,
                width: 25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget singleSearchBuddyView(AllBuddiesModel allBuddiesModel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onTap: () async {
          // await Navigator.pushNamed(context, Constants.buddiesProfileScreen,
          //     arguments: allBuddiesModel);

          var isChange = await Navigator.pushNamed(context, Constants.buddiesProfileScreen, arguments: allBuddiesModel);

          if (isChange != null && isChange == true) {
            setState(() {
              isSearch = false;
              mainLoader = true;
            });
            pageCount = 0;
            totalCount = 0;
            _searchActivityController.text = "";
            allBuddiesList.clear();
            getAllBuddies('');
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 0,
              child: ClipPath(
                clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                child: Opacity(
                  opacity: 1,
                  child: Container(
                    width: 95,
                    height: 95,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).colorScheme.onBackground),
                    child: CachedNetworkImage(
                      imageUrl: allBuddiesModel.profileImage!,
                      fit: BoxFit.fill,
                      errorWidget: (context, url, error) {
                        return Image.asset(
                          "assets/images/profile_circle.png",
                          fit: BoxFit.fill,
                          width: 50,
                          height: 50,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            // Container(
            //   height: 95,
            //   width: 95,
            //   decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(30), color: Theme.of(context).colorScheme.onBackground),
            //   child: CachedNetworkImage(
            //     imageUrl: allBuddiesModel.profileImage!,
            //     fit: BoxFit.fill,
            //   ),
            // ),
            const SizedBox(
              width: 15,
            ),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTextView(
                    label: '${allBuddiesModel.firstName} ${allBuddiesModel.lastName}',
                    maxLine: 3,
                    textOverFlow: TextOverflow.ellipsis,
                    type: styleSubTitle,
                    textStyle: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(color: const Color(0xFF2B2B2B), fontSize: 13.0, fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  CustomTextView(
                    label: allBuddiesModel.aboutYourSelf,
                    type: styleSubTitle,
                    textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: const Color(0xFF2B2B2B), fontSize: 11.0, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            GestureDetector(
              onTap: () async {
                if (allBuddiesModel.status!.isEmpty) {
                  sendFriendRequest(allBuddiesModel);
                } else if (allBuddiesModel.status == 'Requested') {
                  callAcceptReject(allBuddiesModel);
                } else if (allBuddiesModel.status == 'Response') {
                  var isChange = await Navigator.pushNamed(context, Constants.buddiesProfileScreen, arguments: allBuddiesModel);

                  if (isChange != null && isChange == true) {
                    setState(() {
                      allBuddiesList.clear();
                      allSearchBuddiesList.clear();
                      mainLoader = true;
                    });
                    pageCount = 0;
                    totalCount = 0;

                    getAllBuddies('');
                  }
                } else if (allBuddiesModel.status == 'Friend') {
                  Conversation conversation = Conversation();
                  conversation.firstName = allBuddiesModel.firstName;
                  conversation.lastName = allBuddiesModel.lastName;

                  conversation.toEndUserId = allBuddiesModel.endUserId;
                  conversation.fromEndUserId = int.parse(OQDOApplication.instance.endUserID!);
                  conversation.profileImage = allBuddiesModel.profileImage;

                  var isChange = await Navigator.pushNamed(context, Constants.directFriendChatScreen, arguments: conversation);
                }
              },
              child: Image.asset(
                allBuddiesModel.status!.isNotEmpty
                    ? allBuddiesModel.status == 'Friend'
                        ? 'assets/images/ic_message_friend.png'
                        : allBuddiesModel.status == 'Requested'
                            ? 'assets/images/ic_friend_requested.png'
                            : allBuddiesModel.status == 'Response'
                                ? 'assets/images/ic_left_nav_arrow.png'
                                : 'assets/images/ic_add_friend.png'
                    : 'assets/images/ic_add_friend.png',
                height: 25,
                width: 25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getAllBuddies(String text) async {
    try {
      String requestStr = '';
      if (isSearch) {
        requestStr =
            'FilterParamsDto.PageStart=0&FilterParamsDto.ResultPerPage=10000&FilterParamsDto.EndUserId=${OQDOApplication.instance.endUserID}&FilterParamsDto.SeachQuery=$text';
        GetAllBuddiesResponseModel getAllBuddiesResponseModel =
            await Provider.of<GetAllBuddiesReposotory>(context, listen: false).getAllBuddiesList(requestStr);
        if (!mounted) return;
        if (getAllBuddiesResponseModel.data!.isNotEmpty) {
          showLog('Response -> ${getAllBuddiesResponseModel.data!.length}');
          setState(() {
            allSearchBuddiesList.clear();
            allSearchBuddiesList.addAll(getAllBuddiesResponseModel.data!);
          });
        }
      } else {
        showLoader();
        requestStr =
            'FilterParamsDto.PageStart=$pageCount&FilterParamsDto.ResultPerPage=$resultPerPage&FilterParamsDto.EndUserId=${OQDOApplication.instance.endUserID}';
        GetAllBuddiesResponseModel getAllBuddiesResponseModel =
            await Provider.of<GetAllBuddiesReposotory>(context, listen: false).getAllBuddiesList(requestStr);
        if (!mounted) return;
        if (getAllBuddiesResponseModel.data!.isNotEmpty) {
          showLog('Response -> ${getAllBuddiesResponseModel.data!.length}');
          hideLoader();
          setState(() {
            allBuddiesList.addAll(getAllBuddiesResponseModel.data!);
            totalCount = getAllBuddiesResponseModel.totalCount!;
            pageCount = pageCount + 1;
            mainLoader = false;
          });
        } else {
          setState(() {
            mainLoader = false;
          });
        }
      }
    } on CommonException catch (error) {
      showLog('common $error');
      setState(() {
        mainLoader = false;
      });
      hideLoader();
      if (error.code == 400) {
        Map<String, dynamic> errorModel = jsonDecode(error.message);
        if (errorModel.containsKey('ModelState')) {
          Map<String, dynamic> modelState = errorModel['ModelState'];
          if (modelState.containsKey('ErrorMessage')) {
            showSnackBarColor(modelState['ErrorMessage'][0], context, true);
          } else {
            showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
          }
        } else {
          showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
        }
      } else if (error.code == 500) {
        showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      } else if (error.code == 404) {
        showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
    } on NoConnectivityException catch (_) {
      setState(() {
        mainLoader = false;
      });
      if (!mounted) return;
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (e) {
      setState(() {
        mainLoader = false;
      });
      if (!mounted) return;
      hideLoader();
      showLog(e.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  Future<void> sendFriendRequest(AllBuddiesModel allBuddiesModel) async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    try {
      await _progressDialog.show();
      Map<String, dynamic> request = {};
      request['FromEndUserId'] = OQDOApplication.instance.endUserID;
      request['ToEndUserId'] = allBuddiesModel.endUserId;
      request['IsActive'] = true;
      showLog('Request -> ${json.encode(request)}');
      var response = await Provider.of<GetAllBuddiesReposotory>(context, listen: false).sendFriendRequest(request);
      showLog('$responseTag $response');
      await _progressDialog.hide();
      if (!mounted) return;
      if (response != 0) {
        showSnackBarColor('Friend Request Sent', context, false);
        if (isSearch) {
          pageCount = 0;
          allSearchBuddiesList.clear();
          getAllBuddies(_searchActivityController.text.toString().trim());
        } else {
          pageCount = 0;
          allBuddiesList.clear();
          getAllBuddies('');
        }
        setState(() {
          mainLoader = true;
        });
      }
    } on CommonException catch (error) {
      await _progressDialog.hide();
      showLog('LOG >>> $error');
      if (error.code == 400) {
        Map errorModel = error.message;
        if (errorModel.containsKey('ModelState')) {
          Map<String, dynamic> modelState = errorModel['ModelState'];
          if (modelState.containsKey('ErrorMessage')) {
            showSnackBarColor(modelState['ErrorMessage'][0], context, true);
          } else {
            showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
          }
        } else {
          showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
        }
      } else if (error.code == 500) {
        showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      } else if (error.code == 404) {
        showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
    } on NoConnectivityException catch (_) {
      await _progressDialog.hide();
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      await _progressDialog.hide();
      showLog(error.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  Future<void> callAcceptReject(AllBuddiesModel allBuddiesModel) async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    try {
      await _progressDialog.show();
      Map<String, dynamic> request = {};
      request['FriendId'] = allBuddiesModel.friendId;
      request['Status'] = 'R';
      request['IsActive'] = false;
      showLog('Request -> ${json.encode(request)}');
      var response = await Provider.of<GetAllBuddiesReposotory>(context, listen: false).acceptRejectRequest(request);
      showLog('$responseTag $response');
      await _progressDialog.hide();
      if (response != 0) {
        if (response != 0) {
          showSnackBarColor('Friend Request Cancelled', context, false);
          if (isSearch) {
            pageCount = 0;
            allSearchBuddiesList.clear();
            getAllBuddies(_searchActivityController.text.toString().trim());
          } else {
            pageCount = 0;
            allBuddiesList.clear();
            getAllBuddies('');
          }
          setState(() {
            mainLoader = true;
          });
        }
      }
    } on CommonException catch (error) {
      await _progressDialog.hide();
      showLog('$error');
      if (error.code == 400) {
        Map errorModel = error.message;
        if (errorModel.containsKey('ModelState')) {
          Map<String, dynamic> modelState = errorModel['ModelState'];
          if (modelState.containsKey('ErrorMessage')) {
            showSnackBarColor(modelState['ErrorMessage'][0], context, true);
          } else {
            showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
          }
        } else {
          showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
        }
      } else if (error.code == 500) {
        showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      } else if (error.code == 404) {
        showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
    } on NoConnectivityException catch (_) {
      await _progressDialog.hide();
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      await _progressDialog.hide();
      showLog(error.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  @override
  void dispose() {
    _searchActivityController.dispose();
    mScrollController.dispose();
    super.dispose();
  }
}
