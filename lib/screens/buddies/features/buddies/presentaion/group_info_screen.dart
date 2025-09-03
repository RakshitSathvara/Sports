import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
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

class GroupInfoScreen extends StatefulWidget {
  final Conversation? groupModel;

  const GroupInfoScreen({Key? key, this.groupModel}) : super(key: key);

  @override
  _GroupInfoScreenState createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  final TextEditingController _searchActivityController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool insideListLoader = false;
  List<GroupFriends> groupFriendsList = [];
  late ProgressDialog _progressDialog;
  bool isEdit = true;
  int? endUserId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getGroupInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
          title: 'Group Detail',
          onBack: () {
            Navigator.of(context).pop();
          }),
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
                        readOnly: true,
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
                  label: '${groupFriendsList.length} Participants',
                  textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 17, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w500),
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
    //print(endUserId);
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
            Visibility(
              visible: endUserId == frndObj.fromEndUserId,
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

  // Future<void> getGroupInfo() async {
  //   _progressDialog = ProgressDialog(context,
  //       type: ProgressDialogType.normal, isDismissible: true);
  //   _progressDialog.style(message: "Please wait...");
  //   try {
  //     String requestStr = '';
  //     requestStr = 'Id=${widget.groupModel!.groupId}';
  //
  //     await _progressDialog.show();
  //     GroupInfoResponse response =
  //         await Provider.of<GetAllBuddiesReposotory>(context, listen: false)
  //             .getGroupInfo(requestStr);
  //     await _progressDialog.hide();
  //     if (!mounted) return;
  //     if (response != null) {
  //       setState(() {
  //         endUserId = response.endUserId;
  //         _nameController.text = response.name.toString();
  //         groupFriendsList.addAll(response.groupFriends!);
  //       });
  //     }
  //   } on CommonException catch (error) {
  //     await _progressDialog.hide();
  //     showLog('$error');
  //     if (!mounted) return;
  //     if (error.code == 400) {
  //       Map errorModel = error.message;
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
  //   } catch (error) {
  //     await _progressDialog.hide();
  //     showLog(error.toString());
  //     Fluttertoast.showToast(
  //         msg: 'We\'re unable to connect to server. Please contact administrator or try after some time', toastLength: Toast.LENGTH_SHORT);
  //   }
  // }

  Future<void> getGroupInfo() async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait...");
    _progressDialog.show();

    try {
      String requestStr = '';
      requestStr = 'FilterParamsDto.GroupId=${widget.groupModel!.groupId.toString()}&FilterParamsDto.EndUserId=${OQDOApplication.instance.endUserID}';
      GroupListResponse groupListResponse = await Provider.of<GetAllBuddiesReposotory>(context, listen: false).getAllGroupList(requestStr);
      await _progressDialog.hide();
      if (!mounted) return;
      if (groupListResponse.data!.isNotEmpty) {
        showLog('Response -> ${groupListResponse.data!.length}');

        setState(() {
          endUserId = groupListResponse.data![0].endUserId;
          _nameController.text = groupListResponse.data![0].groupName.toString();
          groupFriendsList.addAll(groupListResponse.data![0].groupFriends!);
        });
      }
    } on CommonException catch (error) {
      showLog('common $error');
      await _progressDialog.hide();
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
      await _progressDialog.hide();
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (e) {
      await _progressDialog.hide();
      if (!mounted) return;
      showLog(e.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }
}
