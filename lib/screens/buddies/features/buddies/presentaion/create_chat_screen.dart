import 'dart:convert';

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
import 'package:provider/provider.dart';

class CreateChatScreen extends StatefulWidget {
  const CreateChatScreen({Key? key}) : super(key: key);

  @override
  _CreateChatScreenState createState() => _CreateChatScreenState();
}

class _CreateChatScreenState extends State<CreateChatScreen> {
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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getAllFriends('');

      mScrollController.addListener(() {
        if (mScrollController.position.pixels == mScrollController.position.maxScrollExtent) {
          if (totalCount != allBuddiesList.length) {
            getAllFriends('');
          }
        }
      });

      _searchActivityController.addListener(() {
        if (_searchActivityController.text.isNotEmpty) {
          debugPrint('Search -> ${_searchActivityController.text}');
          setState(() {
            isSearch = true;
            getAllFriends(_searchActivityController.text);
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
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
        appBar: CustomAppBar(
            title: 'Your Friends',
            onBack: () {
              Navigator.of(context).pop(true);
            }),
        body: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            hintText: 'Search your friends...',
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(Constants.createGroupScreen);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/ic_group_blue.png',
                            height: 18,
                            width: 18,
                            fit: BoxFit.fill,
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          CustomTextView(
                            label: 'Create Group',
                            maxLine: 1,
                            textOverFlow: TextOverflow.ellipsis,
                            type: styleSubTitle,
                            textStyle: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(color: OQDOThemeData.dividerColor, fontSize: 16.0, fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const Divider(
                    endIndent: 10,
                    indent: 10,
                    height: 4,
                    color: OQDOThemeData.dividerColor,
                  ),
                  isSearch
                      ? Expanded(
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: allSearchBuddiesList.length,
                            controller: mScrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              AllBuddiesModel allBuddiesModel = allSearchBuddiesList[index];
                              return singleBuddyView(allBuddiesModel);
                            },
                            separatorBuilder: (context, index) {
                              return const Divider(
                                height: 0.9,
                                color: OQDOThemeData.filterDividerColor,
                              );
                            },
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
                                        ListView.separated(
                                          physics: const AlwaysScrollableScrollPhysics(),
                                          itemCount: allBuddiesList.length,
                                          controller: mScrollController,
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          scrollDirection: Axis.vertical,
                                          itemBuilder: (context, index) {
                                            AllBuddiesModel allBuddiesModel = allBuddiesList[index];
                                            return singleBuddyView(allBuddiesModel);
                                          },
                                          separatorBuilder: (context, index) {
                                            return const Divider(
                                              height: 0.8,
                                              color: OQDOThemeData.filterDividerColor,
                                            );
                                          },
                                        ),
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

  Future<bool> _willPopCallback() async {
    // await showDialog or Show add banners or whatever
    // then
    Navigator.of(context).pop(true);
    return Future.value(true);
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
      padding: const EdgeInsets.only(top: 7, bottom: 7),
      child: GestureDetector(
        onTap: () async {
          // await Navigator.pushNamed(context, Constants.buddiesProfileScreen,
          //     arguments: allBuddiesModel);

          Conversation conversation = Conversation();
          conversation.firstName = allBuddiesModel.firstName;
          conversation.lastName = allBuddiesModel.lastName;
          conversation.toEndUserId = allBuddiesModel.toEndUserId;
          conversation.fromEndUserId = allBuddiesModel.fromEndUserId;
          conversation.profileImage = allBuddiesModel.profileImage;

          await Navigator.pushNamed(context, Constants.friendChatScreen, arguments: conversation);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  CustomTextView(
                    label: '${allBuddiesModel.firstName} ${allBuddiesModel.lastName}',
                    maxLine: 3,
                    textOverFlow: TextOverflow.ellipsis,
                    type: styleSubTitle,
                    textStyle: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(color: OQDOThemeData.blackColor, fontSize: 15.0, fontWeight: FontWeight.w500, overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getAllFriends(String text) async {
    try {
      String requestStr = '';
      if (isSearch) {
        requestStr =
            'FilterParamsDto.PageStart=0&FilterParamsDto.ResultPerPage=10000&FilterParamsDto.EndUserId=${OQDOApplication.instance.endUserID}&FilterParamsDto.SeachQuery=$text';
        GetAllBuddiesResponseModel getAllBuddiesResponseModel =
            await Provider.of<GetAllBuddiesReposotory>(context, listen: false).getAllFriendsList(requestStr);
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
            await Provider.of<GetAllBuddiesReposotory>(context, listen: false).getAllFriendsList(requestStr);
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
      if (!mounted) return;
      setState(() {
        mainLoader = false;
      });

      hideLoader();
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        mainLoader = false;
      });

      hideLoader();
      showLog(e.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }
}
