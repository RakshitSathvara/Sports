import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/get_all_buddies_repository.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/edit_group_request.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/group_list_response.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class GroupDetailScreen extends StatefulWidget {
  final AllGroups? groupModel;

  const GroupDetailScreen({Key? key, this.groupModel}) : super(key: key);

  // const GroupDetailScreen(AllGroups groupModel, {Key? key}) : super(key: key);

  @override
  _GroupDetailScreenState createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final TextEditingController _searchActivityController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool insideListLoader = false;
  List<GroupFriends> groupFriendsList = [];
  GroupFriends? adminObj;
  late ProgressDialog _progressDialog;
  bool isEdit = true;

  @override
  void initState() {
    super.initState();

    if (widget.groupModel!.endUserId.toString() == OQDOApplication.instance.endUserID) {
      isEdit = true;
    } else {
      isEdit = false;
    }

    _nameController.text = widget.groupModel!.groupName.toString();
    for (int i = 0; i < widget.groupModel!.groupFriends!.length; i++) {
      if (widget.groupModel!.groupFriends![i].isAdmin == false) {
        groupFriendsList.add(widget.groupModel!.groupFriends![i]);
      } else {
        adminObj = widget.groupModel!.groupFriends![i];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
          title: 'Group Detail',
          onBack: () {
            Navigator.of(context).pop();
          },
          actions: [
            Visibility(
              visible: isEdit,
              child: GestureDetector(
                onTap: () {
                  if (_nameController.text.toString().trim().isNotEmpty) {
                    EditGroupRequest editGroupRequest = EditGroupRequest();
                    editGroupRequest.groupId = widget.groupModel!.groupId;
                    editGroupRequest.isActive = true;
                    editGroupRequest.name = _nameController.text.toString();
                    editGroupRequest.endUserId = OQDOApplication.instance.endUserID;

                    List<GroupFriendDtos> friendsList = [];
                    for (var item in groupFriendsList) {
                      //  // print(item.toFriendId);
                      GroupFriendDtos groupFriendDtos = GroupFriendDtos();
                      groupFriendDtos.isActive = true;
                      groupFriendDtos.status = "A";
                      groupFriendDtos.friendId = item.friendId;
                      groupFriendDtos.groupFriendId = item.groupFriendId;
                      friendsList.add(groupFriendDtos);
                    }

                    editGroupRequest.groupFriendDtos = friendsList;

                    editGroup(editGroupRequest.toJson());
                    // print(jsonEncode(editGroupRequest.toJson()));
                  } else {
                    showSnackBar('Please enter group name', context);
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.only(right: 12.0, top: 15, bottom: 15),
                  child: Icon(
                    Icons.done_rounded,
                    size: 25,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ]),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/ic_group_circle.png',
                      height: 50,
                      width: 50,
                      fit: BoxFit.fill,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        maxLength: 50,
                        maxLines: 1,
                        readOnly: !isEdit,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: "",
                        ),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: OQDOThemeData.blackColor, fontSize: 16.0, fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis),
                        // label: 'Group Name',
                        // maxLine: 1,
                        // textOverFlow: TextOverflow.ellipsis,
                        // type: styleSubTitle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              const Divider(
                color: Colors.grey,
              ),
              const SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: CustomTextView(
                  label: '${groupFriendsList.length + 1} Participants',
                  textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 17, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 2, top: 2),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 0,
                        child: ClipPath(
                          clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                          child: Opacity(
                            opacity: 1,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).colorScheme.onBackground),
                              child: adminObj!.profileImage != null
                                  ? CachedNetworkImage(
                                      imageUrl: adminObj!.profileImage!,
                                      fit: BoxFit.fill,
                                    )
                                  : const SizedBox(
                                      width: 0,
                                    ),
                            ),
                          ),
                        ),
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
                              label: '${adminObj!.displayFirstName} ${adminObj!.displayLastName}',
                              maxLine: 2,
                              textOverFlow: TextOverflow.ellipsis,
                              type: styleSubTitle,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(color: const Color(0xFF2B2B2B), fontSize: 14.0, fontWeight: FontWeight.w500, overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      CustomTextView(
                        label: 'Admin',
                        maxLine: 1,
                        textOverFlow: TextOverflow.ellipsis,
                        type: styleSubTitle,
                        textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Theme.of(context).colorScheme.primary, fontSize: 14.0, fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              groupFriendsList.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: groupFriendsList.length,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        GroupFriends friends = groupFriendsList[index];
                        return singleFriendView(friends, index);
                      })
                  : const SizedBox(
                      width: 0,
                    ),
              Visibility(
                visible: isEdit,
                child: GestureDetector(
                  onTap: () async {
                    for (int i = 0; i < groupFriendsList.length; i++) {
                      if (groupFriendsList[i].isAdmin!) {
                        groupFriendsList[i].isRemove = false;
                      }
                    }
                    dynamic selectedFriends = await Navigator.of(context).pushNamed(Constants.addParticipantScreen, arguments: groupFriendsList);

                    if (selectedFriends != null) {
                      // print("true");
                      for (int i = 0; i < selectedFriends.length; i++) {
                        // print(selectedFriends[i].toJson());
                      }

                      setState(() {
                        groupFriendsList.clear();
                        for (int i = 0; i < selectedFriends.length; i++) {
                          GroupFriends friend = GroupFriends();
                          friend.displayFirstName = selectedFriends[i].firstName;
                          friend.displayLastName = selectedFriends[i].lastName;
                          friend.friendId = selectedFriends[i].friendId;
                          friend.profileImage = selectedFriends[i].profileImage;
                          friend.groupFriendId = selectedFriends[i].groupFriendId;
                          friend.isRemove = selectedFriends[i].isRemove;
                          friend.fromEndUserId = selectedFriends[i].fromEndUserId;
                          friend.againsEndUserId = selectedFriends[i].againsEndUserId;
                          friend.isAdmin = selectedFriends[i].isAdmin;
                          groupFriendsList.add(friend);
                        }
                        // print(groupFriendsList.length);
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 18),
                    child: CustomTextView(
                      label: '+ Add Participant',
                      maxLine: 2,
                      textOverFlow: TextOverflow.ellipsis,
                      type: styleSubTitle,
                      textStyle: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(color: Theme.of(context).colorScheme.primary, fontSize: 16.0, fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
            ],
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

  Widget singleFriendView(GroupFriends frndObj, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2, top: 2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 0,
              child: ClipPath(
                clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                child: Opacity(
                  opacity: 1,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).colorScheme.onBackground),
                    child: frndObj.profileImage != null
                        ? CachedNetworkImage(
                            imageUrl: frndObj.profileImage!,
                            fit: BoxFit.fill,
                          )
                        : const SizedBox(
                            width: 0,
                          ),
                  ),
                ),
              ),
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
                    label: '${frndObj.displayFirstName} ${frndObj.displayLastName}',
                    maxLine: 2,
                    textOverFlow: TextOverflow.ellipsis,
                    type: styleSubTitle,
                    textStyle: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(color: const Color(0xFF2B2B2B), fontSize: 14.0, fontWeight: FontWeight.w500, overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Visibility(
              visible: isEdit,
              child: GestureDetector(
                onTap: () {
                  if (groupFriendsList.length > 1) {
                    setState(() {
                      groupFriendsList.removeAt(index);
                    });
                  } else {
                    showSnackBarColor('Minimum one friend required', context, true);
                  }
                },
                child: Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/ic_cancel_blue.png',
                    width: 16,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: frndObj.isAdmin!,
              child: CustomTextView(
                label: 'Admin',
                maxLine: 1,
                textOverFlow: TextOverflow.ellipsis,
                type: styleSubTitle,
                textStyle: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(color: Theme.of(context).colorScheme.primary, fontSize: 14.0, fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> editGroup(Map data) async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait...");
    try {
      await _progressDialog.show();
      var response = await Provider.of<GetAllBuddiesReposotory>(context, listen: false).editGroup(data);
      await _progressDialog.hide();
      if (!mounted) return;
      if (response == true) {
        showSnackBarColor("Group edited success", context, false);
        Navigator.pop(context, true);
      }
      // showLog('$response');
    } on CommonException catch (error) {
      await _progressDialog.hide();
      showLog('$error');
      if (!mounted) return;
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

// Future<void> getAllGroups(String text) async {
//   setState(() {
//     allSearchGroupList.clear();
//   });
//
//   try {
//     String requestStr = '';
//     if (isSearch) {
//       requestStr =
//           'FilterParamsDto.PageStart=0&FilterParamsDto.ResultPerPage=10000&FilterParamsDto.EndUserId=${OQDOApplication.instance.endUserID}&FilterParamsDto.SeachQuery=$text';
//       GroupListResponse groupListResponse =
//           await Provider.of<GetAllBuddiesReposotory>(context, listen: false)
//               .getAllGroupList(requestStr);
//       if (!mounted) return;
//       if (groupListResponse.data!.isNotEmpty) {
//         showLog('Response -> ${groupListResponse.data!.length}');
//         setState(() {
//           allSearchGroupList.clear();
//           allSearchGroupList.addAll(groupListResponse.data!);
//         });
//       }
//     } else {
//       showLoader();
//       requestStr =
//           'FilterParamsDto.PageStart=$pageCount&FilterParamsDto.ResultPerPage=$resultPerPage&FilterParamsDto.EndUserId=${OQDOApplication.instance.endUserID}';
//       GroupListResponse groupListResponse =
//           await Provider.of<GetAllBuddiesReposotory>(context, listen: false)
//               .getAllGroupList(requestStr);
//       if (!mounted) return;
//       if (groupListResponse.data!.isNotEmpty) {
//         showLog('Response -> ${groupListResponse.data!.length}');
//         hideLoader();
//         setState(() {
//           allGroupList.addAll(groupListResponse.data!);
//           totalCount = groupListResponse.totalCount!;
//           pageCount = pageCount + 1;
//           mainLoader = false;
//         });
//       }
//     }
//   } on CommonException catch (error) {
//     showLog('common $error');
//     setState(() {
//       mainLoader = false;
//     });
//     hideLoader();
//     if (error.code == 400) {
//       Map<String, dynamic> errorModel = jsonDecode(error.message);
//       if (errorModel.containsKey('ModelState')) {
//         Map<String, dynamic> modelState = errorModel['ModelState'];
//         if (modelState.containsKey('ErrorMessage')) {
//           showSnackBarColor(modelState['ErrorMessage'][0], context, true);
//         } else {
//           showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
//         }
//       } else {
//         showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
//       }
//     } else if (error.code == 500) {
//       showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
//     } else if (error.code == 404) {
//       showSnackBarColor('Un-Authorized request', context, true);
//     }
//   } catch (e) {
//     setState(() {
//       mainLoader = false;
//     });
//     if (!mounted) return;
//     hideLoader();
//     showLog(e.toString());
//     Fluttertoast.showToast(
//         msg: 'We\'re unable to connect to server. Please contact administrator or try after some time', toastLength: Toast.LENGTH_SHORT);
//   }
// }
}
