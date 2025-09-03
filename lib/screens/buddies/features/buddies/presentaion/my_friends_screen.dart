import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/get_all_buddies_repository.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/get_all_buddies_response_model.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class MyFriendsScreen extends StatefulWidget {
  const MyFriendsScreen({Key? key}) : super(key: key);

  @override
  _MyFriendsScreenState createState() => _MyFriendsScreenState();
}

class _MyFriendsScreenState extends State<MyFriendsScreen> {
  final TextEditingController _searchActivityController = TextEditingController();
  int pageCount = 0;
  int resultPerPage = 20;

  //int totalCount = 0;
  List<AllBuddiesModel> allFriendsList = [];
  List<AllBuddiesModel> allPendingFriendsList = [];
  bool pendingFrnd = true;
  bool myFrnd = false;
  ScrollController mScrollController = ScrollController();
  late ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getAllFriends('');
      getAllPendingFriends();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: 'Your Friends',
          onBack: () {
            Navigator.of(context).pop();
          }),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Visibility(
                  visible: allPendingFriendsList.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 8),
                    child: CustomTextView(
                      label: 'Friend Requests',
                      textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 16, color: OQDOThemeData.blackColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                pendingFrnd
                    ? const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : allPendingFriendsList.isNotEmpty
                        ? ListView.builder(
                            itemCount: allPendingFriendsList.length,
                            controller: mScrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              AllBuddiesModel friendsList = allPendingFriendsList[index];
                              return singlePendingFriendView(friendsList, index);
                            })
                        : const SizedBox(height: 0),
                allPendingFriendsList.isNotEmpty
                    ? const Divider(
                        height: 1,
                        color: Colors.black87,
                      )
                    : const SizedBox(
                        height: 0,
                      ),
                const SizedBox(
                  height: 5,
                ),
                Visibility(
                  visible: allFriendsList.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 8),
                    child: CustomTextView(
                      label: 'My Friends',
                      textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 16, color: OQDOThemeData.blackColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                myFrnd
                    ? const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : allFriendsList.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: allFriendsList.length,
                            controller: mScrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              AllBuddiesModel friendsList = allFriendsList[index];
                              return singleFriendView(friendsList, index);
                            })
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget singleFriendView(AllBuddiesModel frndObj, int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, bottom: 7),
      child: GestureDetector(
        onTap: () async {
          frndObj.status = "Friend";
          var isChange = await Navigator.pushNamed(context, Constants.buddiesProfileScreen, arguments: frndObj);

          if (isChange != null && isChange == true) {
            setState(() {
              myFrnd = true;
            });
            allFriendsList.clear();
            getAllFriends('');
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            frndObj.profileImage!.isNotEmpty
                ? Card(
                    elevation: 0,
                    child: ClipPath(
                      clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                      child: Opacity(
                        opacity: 1,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).colorScheme.onBackground),
                          child: CachedNetworkImage(
                            imageUrl: frndObj.profileImage!,
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
                    width: 50,
                    height: 50,
                  ),
            const SizedBox(
              width: 15,
            ),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextView(
                    label: '${frndObj.firstName} ${frndObj.lastName}',
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
                    label: '${frndObj.aboutYourSelf}',
                    maxLine: 3,
                    textOverFlow: TextOverflow.ellipsis,
                    type: styleSubTitle,
                    textStyle: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(color: const Color(0xFF2B2B2B), fontSize: 11.0, fontWeight: FontWeight.w400, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  showConfirmationDialog(context, frndObj, index);
                  // callCancelRequest(frndObj, index);
                },
                child: Image.asset(
                  'assets/images/ic_cancel_blue.png',
                  height: 16,
                  width: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget singlePendingFriendView(AllBuddiesModel frndObj, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7, top: 7),
      child: GestureDetector(
        onTap: () async {
          frndObj.status = "Response";
          var isChange = await Navigator.pushNamed(context, Constants.buddiesProfileScreen, arguments: frndObj);

          if (isChange != null && isChange == true) {
            setState(() {
              pendingFrnd = true;
            });
            allPendingFriendsList.clear();
            getAllPendingFriends();
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            frndObj.profileImage!.isNotEmpty
                ? Card(
                    elevation: 0,
                    child: ClipPath(
                      clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                      child: Opacity(
                        opacity: 1,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).colorScheme.onBackground),
                          child: CachedNetworkImage(
                            imageUrl: frndObj.profileImage!,
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
                    width: 50,
                    height: 50,
                  ),
            const SizedBox(
              width: 15,
            ),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextView(
                    label: '${frndObj.firstName} ${frndObj.lastName}',
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
                    label: '${frndObj.aboutYourSelf}',
                    maxLine: 3,
                    textOverFlow: TextOverflow.ellipsis,
                    type: styleSubTitle,
                    textStyle: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(color: const Color(0xFF2B2B2B), fontSize: 11.0, fontWeight: FontWeight.w400, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Align(
              alignment: Alignment.center,
              child: Row(
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1, style: BorderStyle.solid),
                            borderRadius: const BorderRadius.all(Radius.zero))),
                    child: Text(
                      'Delete',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 10),
                    ),
                    onPressed: () {
                      callAcceptReject('R', frndObj, index);
                    },
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.zero))),
                    child: Text(
                      "Confirm",
                      style: TextStyle(color: Theme.of(context).colorScheme.onBackground, fontSize: 10),
                    ),
                    onPressed: () {
                      callAcceptReject('A', frndObj, index);
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getAllFriends(String text) async {
    setState(() {
      myFrnd = true;
    });
    try {
      String requestStr = '';
      requestStr =
          'FilterParamsDto.PageStart=$pageCount&FilterParamsDto.ResultPerPage=$resultPerPage&FilterParamsDto.EndUserId=${OQDOApplication.instance.endUserID}';
      GetAllBuddiesResponseModel getAllFriendsResponse = await Provider.of<GetAllBuddiesReposotory>(context, listen: false).getAllFriendsList(requestStr);
      if (!mounted) return;
      if (getAllFriendsResponse.data!.isNotEmpty) {
        showLog('Response -> ${getAllFriendsResponse.data!.length}');
        setState(() {
          allFriendsList.addAll(getAllFriendsResponse.data!);
          // totalCount = getAllFriendsResponse.totalCount!;
          // pageCount = pageCount + 1;
        });
      }

      setState(() {
        myFrnd = false;
      });
    } on CommonException catch (error) {
      showLog('common $error');
      setState(() {
        myFrnd = false;
      });
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
        myFrnd = false;
      });
      if (!mounted) return;
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (e) {
      setState(() {
        myFrnd = false;
      });
      if (!mounted) return;
      showLog(e.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  Future<void> getAllPendingFriends() async {
    setState(() {
      pendingFrnd = true;
    });
    try {
      String requestStr = '';
      requestStr =
          'FilterParamsDto.PageStart=$pageCount&FilterParamsDto.ResultPerPage=$resultPerPage&FilterParamsDto.EndUserId=${OQDOApplication.instance.endUserID}';
      GetAllBuddiesResponseModel getAllFriendsResponse =
          await Provider.of<GetAllBuddiesReposotory>(context, listen: false).getAllPendingFriendsList(requestStr);
      if (!mounted) return;
      if (getAllFriendsResponse.data!.isNotEmpty) {
        showLog('Response -> ${getAllFriendsResponse.data!.length}');
        setState(() {
          allPendingFriendsList.addAll(getAllFriendsResponse.data!);
          //totalCount = getAllFriendsResponse.totalCount!;
          //pageCount = pageCount + 1;
        });
      }
      setState(() {
        pendingFrnd = false;
      });
    } on CommonException catch (error) {
      showLog('common $error');
      setState(() {
        pendingFrnd = false;
      });
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
        pendingFrnd = false;
      });
      if (!mounted) return;
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (e) {
      setState(() {
        pendingFrnd = false;
      });
      if (!mounted) return;
      showLog(e.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  Future<void> callCancelRequest(AllBuddiesModel friendsList, int index) async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait...");
    try {
      await _progressDialog.show();
      Map<String, dynamic> request = {};
      request['FriendId'] = friendsList.friendId;
      request['Status'] = 'R';
      request['IsActive'] = false;
      showLog('Request -> ${json.encode(request)}');
      var response = await Provider.of<GetAllBuddiesReposotory>(context, listen: false).acceptRejectRequest(request);
      showLog('$responseTag $response');
      await _progressDialog.hide();
      if (response != 0) {
        setState(() {
          allFriendsList.removeAt(index);
        });
        showSnackBarColor('Friend Removed', context, false);
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

  showConfirmationDialog(BuildContext context, AllBuddiesModel friendsObj, int index) {
    // set up the button
    Widget yesButton = TextButton(
      child: const Text("Yes"),
      onPressed: () {
        Navigator.of(context).pop();
        callCancelRequest(friendsObj, index);
      },
    );

    // set up the button
    Widget noButton = TextButton(
      child: const Text("No"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text(
        "Remove Friend",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      content: const Text("Are you sure want to remove friend?"),
      actions: [yesButton, noButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> callAcceptReject(String acceptReject, AllBuddiesModel allBuddiesModel, int index) async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait...");
    try {
      await _progressDialog.show();
      Map<String, dynamic> request = {};
      request['FriendId'] = allBuddiesModel.friendId;
      request['Status'] = acceptReject;
      request['IsActive'] = true;
      showLog('Request -> ${json.encode(request)}');
      var response = await Provider.of<GetAllBuddiesReposotory>(context, listen: false).acceptRejectRequest(request);
      showLog('$responseTag $response');
      await _progressDialog.hide();
      if (response != 0) {
        if (acceptReject == 'R') {
          showSnackBarColor('Friend Request Rejected', context, false);
        } else {
          showSnackBarColor('Friend Request Accepted', context, false);
          setState(() {
            myFrnd = true;
            allFriendsList.clear();
          });
          getAllFriends('');
        }

        setState(() {
          allPendingFriendsList.removeAt(index);
        });
        // await Navigator.pushNamedAndRemoveUntil(context, Constants.APPPAGES, Helper.of(context).predicate,
        //     arguments: 0);
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
}
