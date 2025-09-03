import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/get_all_buddies_repository.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/get_conversation_list_response.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/group_list_response.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({Key? key}) : super(key: key);

  @override
  _GroupListScreenState createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  final TextEditingController _searchActivityController = TextEditingController();

  int pageCount = 0;
  int resultPerPage = 20;
  int totalCount = 0;
  bool isSearch = false;
  List<AllGroups> allGroupList = [];
  List<AllGroups> allSearchGroupList = [];
  bool mainLoader = true;
  bool insideListLoader = false;
  ScrollController mScrollController = ScrollController();
  late ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getAllGroups('');
      mScrollController.addListener(() {
        if (mScrollController.position.pixels == mScrollController.position.maxScrollExtent) {
          if (totalCount != allGroupList.length) {
            getAllGroups('');
          }
        }
      });

      _searchActivityController.addListener(() {
        if (_searchActivityController.text.isNotEmpty) {
          debugPrint('Search -> ${_searchActivityController.text}');
          setState(() {
            isSearch = true;
            getAllGroups(_searchActivityController.text);
          });
        } else {
          setState(() {
            isSearch = false;
            hideKeyboard();
            allSearchGroupList.clear();
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        elevation: 0.0,
        backgroundColor: OQDOThemeData.dividerColor,
        onPressed: () async {
          var isChange = await Navigator.of(context).pushNamed(Constants.createGroupScreen);
          // print("isChange >>> $isChange");
          if (isChange != null && isChange == true) {
            setState(() {
              isSearch = false;
              mainLoader = true;
              pageCount = 0;
              totalCount = 0;
              _searchActivityController.text = "";
              allGroupList.clear();
              allSearchGroupList.clear();
            });
            getAllGroups('');
          }
        },
        child: Image.asset(
          'assets/images/ic_create_chat.png',
          height: 26,
          width: 26,
          fit: BoxFit.fill,
          color: Colors.white,
        ),
      ),
      appBar: CustomAppBar(
          title: 'Groups',
          onBack: () {
            Navigator.of(context).pop();
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
                          hintText: 'Search your group... ',
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
                        child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: allSearchGroupList.length,
                            controller: mScrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              AllGroups allBuddiesModel = allSearchGroupList[index];
                              return singleSearchGroupView(allBuddiesModel);
                            }),
                      )
                    : mainLoader
                        ? const Expanded(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Expanded(
                            child: allGroupList.isNotEmpty
                                ? Stack(
                                    children: [
                                      ListView.builder(
                                          physics: const AlwaysScrollableScrollPhysics(),
                                          itemCount: allGroupList.length,
                                          controller: mScrollController,
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          scrollDirection: Axis.vertical,
                                          itemBuilder: (context, index) {
                                            AllGroups allBuddiesModel = allGroupList[index];
                                            return singleGroupView(allBuddiesModel);
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
                                        label: 'Groups not available',
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
    );
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

  Widget singleGroupView(AllGroups groupModel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              var isChange = await Navigator.of(context).pushNamed(Constants.groupDetailScreen, arguments: groupModel);
              // print("LOG >> $isChange");
              if (isChange != null && isChange == true) {
                setState(() {
                  isSearch = false;
                  mainLoader = true;
                  pageCount = 0;
                  totalCount = 0;
                  _searchActivityController.text = "";
                  allGroupList.clear();
                  allSearchGroupList.clear();
                });

                getAllGroups('');
              }
            },
            child: Image.asset(
              'assets/images/ic_group_circle.png',
              height: 60,
              width: 60,
              fit: BoxFit.fill,
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                Conversation conversation = Conversation();
                conversation.groupName = groupModel.groupName.toString();
                conversation.groupId = groupModel.groupId;

                var isChange = await Navigator.pushNamed(context, Constants.directGroupChatScreen, arguments: conversation);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextView(
                    label: '${groupModel.groupName}',
                    maxLine: 3,
                    textOverFlow: TextOverflow.ellipsis,
                    type: styleSubTitle,
                    textStyle: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(color: const Color(0xFF2B2B2B), fontSize: 14.0, fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  CustomTextView(
                    label: "${groupModel.groupFriends!.length} Member",
                    type: styleSubTitle,
                    textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: const Color(0xFF2B2B2B), fontSize: 12.0, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget singleSearchGroupView(AllGroups groupModel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () async {
              var isChange = await Navigator.of(context).pushNamed(Constants.groupDetailScreen, arguments: groupModel);
              // print("LOG >> $isChange");
              if (isChange != null && isChange == true) {
                setState(() {
                  isSearch = false;
                  mainLoader = true;
                  pageCount = 0;
                  totalCount = 0;
                  _searchActivityController.text = "";
                  allGroupList.clear();
                  allSearchGroupList.clear();
                });

                getAllGroups('');
              }
            },
            child: Image.asset(
              'assets/images/ic_group_circle.png',
              height: 60,
              width: 60,
              fit: BoxFit.fill,
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                Conversation conversation = Conversation();
                conversation.groupName = groupModel.groupName.toString();
                conversation.groupId = groupModel.groupId;

                var isChange = await Navigator.pushNamed(context, Constants.directGroupChatScreen, arguments: conversation);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTextView(
                    label: '${groupModel.groupName}',
                    maxLine: 3,
                    textOverFlow: TextOverflow.ellipsis,
                    type: styleSubTitle,
                    textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: const Color(0xFF2B2B2B),
                        fontSize: 14.0,
                        // fontWeight: groupModel.endUserId.toString() ==
                        //         OQDOApplication.instance.endUserID
                        //     ? FontWeight.w600
                        //     : FontWeight.w500,
                        fontWeight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  CustomTextView(
                    label: "${groupModel.groupFriends!.length} Member",
                    type: styleSubTitle,
                    textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: const Color(0xFF2B2B2B), fontSize: 12.0, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getAllGroups(String text) async {
    setState(() {
      allSearchGroupList.clear();
    });

    try {
      String requestStr = '';
      if (isSearch) {
        requestStr =
            'FilterParamsDto.PageStart=0&FilterParamsDto.ResultPerPage=10000&FilterParamsDto.EndUserId=${OQDOApplication.instance.endUserID}&FilterParamsDto.SeachQuery=$text';
        GroupListResponse groupListResponse = await Provider.of<GetAllBuddiesReposotory>(context, listen: false).getAllGroupList(requestStr);
        if (!mounted) return;
        if (groupListResponse.data!.isNotEmpty) {
          showLog('Response -> ${groupListResponse.data!.length}');
          setState(() {
            allSearchGroupList.clear();
            allSearchGroupList.addAll(groupListResponse.data!);
          });
        }
      } else {
        showLoader();
        requestStr =
            'FilterParamsDto.PageStart=$pageCount&FilterParamsDto.ResultPerPage=$resultPerPage&FilterParamsDto.EndUserId=${OQDOApplication.instance.endUserID}';
        GroupListResponse groupListResponse = await Provider.of<GetAllBuddiesReposotory>(context, listen: false).getAllGroupList(requestStr);
        if (!mounted) return;
        if (groupListResponse.data!.isNotEmpty) {
          showLog('Response -> ${groupListResponse.data!.length}');
          hideLoader();
          setState(() {
            allGroupList.addAll(groupListResponse.data!);
            totalCount = groupListResponse.totalCount!;
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
}
