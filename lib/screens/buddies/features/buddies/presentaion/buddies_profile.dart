import 'dart:collection';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/get_all_buddies_response_model.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/get_conversation_list_response.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import '../data/get_all_buddies_repository.dart';

class BuddiesProfilePage extends StatefulWidget {
  AllBuddiesModel? allBuddiesModel;

  BuddiesProfilePage({Key? key, this.allBuddiesModel}) : super(key: key);

  @override
  _BuddiesProfilePageState createState() => _BuddiesProfilePageState();
}

class _BuddiesProfilePageState extends State<BuddiesProfilePage> {
  bool isacceptvisibile = false;
  bool unFriend = false;
  bool isCanelRequest = false;
  late ProgressDialog _progressDialog;
  List<String> sections = [];
  LinkedHashMap<String, List<EndUserSubActivities>> sectionInterest = LinkedHashMap<String, List<EndUserSubActivities>>();

  @override
  void initState() {
    super.initState();

    if (widget.allBuddiesModel!.endUserSubActivities != null) {
      var set = <String>{};
      widget.allBuddiesModel!.endUserSubActivities!.where((e) => set.add(e.activitiesName!)).toList();
      sections.addAll(set.toSet().toList());

      for (int i = 0; i < sections.length; i++) {
        var list = widget.allBuddiesModel!.endUserSubActivities!.where((f) => f.activitiesName! == sections[i]).toList();
        sectionInterest[sections[i]] = list;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: 'oqdo',
          onBack: () {
            Navigator.of(context).pop();
          }),
      body: SafeArea(
          child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const SizedBox(
              //   height: 20,
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    widget.allBuddiesModel!.profileImage!.isNotEmpty
                        ? CircleAvatar(
                            radius: 70,
                            backgroundColor: const Color(0xffFFFFFF),
                            backgroundImage: const AssetImage('assets/images/ic_profile_outer_ring.png'),
                            child: Center(
                              child: Container(
                                height: 95,
                                width: 95,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xffFFFFFF), // You can set your desired background color
                                ),
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: widget.allBuddiesModel!.profileImage!,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) {
                                      return Image.asset(
                                        "assets/images/profile_circle.png",
                                        fit: BoxFit.cover,
                                        width: 80,
                                        height: 80,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // child: CircleAvatar(
                              //   radius: 42,
                              //   backgroundColor: const Color(0xffFFFFFF),
                              //   backgroundImage: CachedNetworkImageProvider(widget.allBuddiesModel!.profileImage!),
                              // ),
                            ),
                          )
                        : Image.asset(
                            "assets/images/profile_circle.png",
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                          ),
                    const SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          CustomTextView(
                            label: '${widget.allBuddiesModel!.firstName} ${widget.allBuddiesModel!.lastName}',
                            type: styleSubTitle,
                            maxLine: 2,
                            textOverFlow: TextOverflow.ellipsis,
                            textStyle:
                                Theme.of(context).textTheme.titleSmall!.copyWith(color: const Color(0xFF2B2B2B), fontSize: 16.0, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          if (widget.allBuddiesModel!.status == "Friend")
                            CustomTextView(
                              label: 'About: ',
                              type: styleSubTitle,
                              textStyle:
                                  Theme.of(context).textTheme.titleSmall!.copyWith(color: const Color(0xFF2B2B2B), fontSize: 15.0, fontWeight: FontWeight.w600),
                            ),
                          if (widget.allBuddiesModel!.status != "Friend" && widget.allBuddiesModel!.isProfilePrivate == false)
                            CustomTextView(
                              label: 'About: ',
                              type: styleSubTitle,
                              textStyle:
                                  Theme.of(context).textTheme.titleSmall!.copyWith(color: const Color(0xFF2B2B2B), fontSize: 15.0, fontWeight: FontWeight.w600),
                            ),

                          // widget.allBuddiesModel!.status == "Friend" || widget.allBuddiesModel!.isProfilePrivate!
                          //     ? Container()
                          //     : CustomTextView(
                          //         label: 'About: ',
                          //         type: styleSubTitle,
                          //         textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                          //             color: const Color(0xFF2B2B2B), fontSize: 12.0, fontWeight: FontWeight.w600),
                          //       ),

                          if (widget.allBuddiesModel!.status == "Friend")
                            const SizedBox(
                              height: 8,
                            ),
                          if (widget.allBuddiesModel!.status != "Friend" && widget.allBuddiesModel!.isProfilePrivate == false)
                            const SizedBox(
                              height: 8,
                            ),
                          if (widget.allBuddiesModel!.status == "Friend")
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2,
                              child: CustomTextView(
                                label: '${widget.allBuddiesModel!.aboutYourSelf}',
                                type: styleSubTitle,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(color: const Color(0xFF2B2B2B), fontSize: 11.0, fontWeight: FontWeight.w400),
                              ),
                            ),
                          if (widget.allBuddiesModel!.status != "Friend" && widget.allBuddiesModel!.isProfilePrivate == false)
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2,
                              child: CustomTextView(
                                label: '${widget.allBuddiesModel!.aboutYourSelf}',
                                type: styleSubTitle,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(color: const Color(0xFF2B2B2B), fontSize: 11.0, fontWeight: FontWeight.w400),
                              ),
                            ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Visibility(
                    visible: widget.allBuddiesModel!.status == 'Friend',
                    child: Expanded(
                      child: SimpleButton(
                        text: "Send message",
                        textcolor: OQDOThemeData.buttonColor,
                        textsize: 13,
                        fontWeight: FontWeight.w600,
                        letterspacing: 0.7,
                        buttoncolor: OQDOThemeData.whiteColor,
                        buttonbordercolor: OQDOThemeData.buttonColor,
                        buttonheight: 50,
                        buttonwidth: MediaQuery.of(context).size.width / 2,
                        radius: 0,
                        onTap: () async {
                          Conversation conversation = Conversation();
                          conversation.firstName = widget.allBuddiesModel!.firstName;
                          conversation.lastName = widget.allBuddiesModel!.lastName;
                          conversation.toEndUserId = widget.allBuddiesModel!.toEndUserId;
                          conversation.fromEndUserId = widget.allBuddiesModel!.fromEndUserId ?? widget.allBuddiesModel!.endUserId;
                          conversation.profileImage = widget.allBuddiesModel!.profileImage;

                          var isChange = await Navigator.pushNamed(context, Constants.directFriendChatScreen, arguments: conversation);
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: SimpleButton(
                      text: widget.allBuddiesModel!.status!.isNotEmpty ? widget.allBuddiesModel!.status! : 'Add Friend',
                      textcolor: OQDOThemeData.whiteColor,
                      textsize: 13,
                      fontWeight: FontWeight.w600,
                      letterspacing: 0.7,
                      buttoncolor: OQDOThemeData.buttonColor,
                      buttonbordercolor: OQDOThemeData.buttonColor,
                      buttonheight: 50,
                      buttonwidth: MediaQuery.of(context).size.width / 2,
                      radius: 0,
                      onTap: () async {
                        if (widget.allBuddiesModel!.status == 'Requested') {
                          setState(() {
                            isCanelRequest = true;
                          });
                        } else if (widget.allBuddiesModel!.status == 'Response') {
                          setState(() {
                            isacceptvisibile = true;
                          });
                        } else if (widget.allBuddiesModel!.status!.isEmpty) {
                          sendFriendRequest(widget.allBuddiesModel!);
                        } else if (widget.allBuddiesModel!.status == 'Friend') {
                          setState(() {
                            unFriend = true;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              isCanelRequest
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      child: Row(
                        children: [
                          Expanded(child: Container()),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                showLog('click');
                                callCancelRequest(widget.allBuddiesModel!, 'CR');
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                        topRight: Radius.circular(10)),
                                    border: Border.all(color: const Color(0xffF1F1F1)),
                                    color: const Color(0xffF1F1F1).withOpacity(0.5)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.close,
                                      size: 20,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    CustomTextView(
                                      label: 'Cancel Request',
                                      type: styleSubTitle,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(color: const Color(0xFF2B2B2B), fontSize: 11.0, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 0.3,
                          ),
                        ],
                      ),
                    )
                  : unFriend
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                          child: Row(
                            children: [
                              Expanded(child: Container()),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    callCancelRequest(widget.allBuddiesModel!, 'FR');
                                  },
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                            topRight: Radius.circular(10)),
                                        border: Border.all(color: const Color(0xffF1F1F1)),
                                        color: const Color(0xffF1F1F1).withOpacity(0.5)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.close,
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        CustomTextView(
                                          label: 'Remove Friend',
                                          type: styleSubTitle,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(color: const Color(0xFF2B2B2B), fontSize: 11.0, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 0.3,
                              ),
                            ],
                          ),
                        )
                      : !isacceptvisibile
                          ? const SizedBox()
                          : const SizedBox(
                              height: 15,
                            ),
              !isacceptvisibile
                  ? const SizedBox()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                callAcceptReject('R', 'FR');
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                                    border: Border.all(color: const Color(0xffF1F1F1)),
                                    color: const Color(0xffF1F1F1).withOpacity(0.5)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.close,
                                      size: 20,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    CustomTextView(
                                      label: 'Decline',
                                      type: styleSubTitle,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(color: const Color(0xFF2B2B2B), fontSize: 11.0, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 0.3,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                callAcceptReject('A', '');
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                                    border: Border.all(color: const Color(0xffF1F1F1)),
                                    color: const Color(0xffF1F1F1).withOpacity(0.5)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.check,
                                      size: 20,
                                      color: Color(0xff3C80A8),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    CustomTextView(
                                      label: 'Accept',
                                      type: styleSubTitle,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(color: const Color(0xFF3C80A8), fontSize: 11.0, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
              const SizedBox(
                height: 30,
              ),
              if (widget.allBuddiesModel!.status != "Friend" && widget.allBuddiesModel!.isProfilePrivate == true)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomTextView(
                    label: 'Private Profile',
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 20, color: OQDOThemeData.blackColor, fontWeight: FontWeight.w600),
                  ),
                ),
              if (widget.allBuddiesModel!.status == "Friend")
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextView(
                        label: 'Interests',
                        type: styleSubTitle,
                        textStyle:
                            Theme.of(context).textTheme.titleMedium!.copyWith(color: const Color(0xFF2B2B2B), fontSize: 16.0, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      sectionInterest.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: sectionInterest.keys.toList().length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CustomTextView(
                                          label: sectionInterest.keys.toList()[index],
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(color: const Color(0xFF2B2B2B), fontWeight: FontWeight.w400, fontSize: 18.0),
                                        ),
                                        const SizedBox(
                                          height: 10.0,
                                        ),
                                        ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: sectionInterest[sectionInterest.keys.toList()[index]]!.length,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, indexInterest) {
                                              return Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: ColorsUtils.chipBackground,
                                                      border: Border.all(color: ColorsUtils.chipBackground),
                                                      borderRadius: const BorderRadius.all(
                                                        Radius.circular(20),
                                                      ),
                                                    ),
                                                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
                                                    child: CustomTextView(
                                                        textStyle: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium!
                                                            .copyWith(color: ColorsUtils.chipText, fontSize: 13.0, fontWeight: FontWeight.w400),
                                                        label: sectionInterest[sectionInterest.keys.toList()[index]]![indexInterest].subActivitiesName),
                                                  ),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                ],
                                              );
                                            }),
                                      ],
                                    );
                                  }),
                            )
                          : Container(),
                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
              if (widget.allBuddiesModel!.status != "Friend" && widget.allBuddiesModel!.isProfilePrivate == false)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextView(
                        label: 'Interests',
                        type: styleSubTitle,
                        textStyle:
                            Theme.of(context).textTheme.titleMedium!.copyWith(color: const Color(0xFF2B2B2B), fontSize: 16.0, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      sectionInterest.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: sectionInterest.keys.toList().length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CustomTextView(
                                          label: sectionInterest.keys.toList()[index],
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(color: const Color(0xFF2B2B2B), fontWeight: FontWeight.w400, fontSize: 18.0),
                                        ),
                                        const SizedBox(
                                          height: 10.0,
                                        ),
                                        ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: sectionInterest[sectionInterest.keys.toList()[index]]!.length,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, indexInterest) {
                                              return Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: ColorsUtils.chipBackground,
                                                      border: Border.all(color: ColorsUtils.chipBackground),
                                                      borderRadius: const BorderRadius.all(
                                                        Radius.circular(20),
                                                      ),
                                                    ),
                                                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
                                                    child: CustomTextView(
                                                        textStyle: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium!
                                                            .copyWith(color: ColorsUtils.chipText, fontSize: 13.0, fontWeight: FontWeight.w400),
                                                        label: sectionInterest[sectionInterest.keys.toList()[index]]![indexInterest].subActivitiesName),
                                                  ),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                ],
                                              );
                                            }),
                                      ],
                                    );
                                  }),
                            )
                          : Container(),
                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      )),
    );
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
      showSnackBarColor('Friend Request Sent', context, false);
      // if (response != 0) {
      //   Fluttertoast.showToast(msg: 'Friend Request Sent', toastLength: Toast.LENGTH_SHORT);
      //   await Navigator.pushNamedAndRemoveUntil(context, Constants.APPPAGES, Helper.of(context).predicate,
      //       arguments: 0);
      // }
      Navigator.pop(context, true);
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

  Future<void> callAcceptReject(String acceptReject, String type) async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    try {
      await _progressDialog.show();
      Map<String, dynamic> request = {};
      request['FriendId'] = widget.allBuddiesModel!.friendId;
      request['Status'] = acceptReject;
      request['IsActive'] = true;
      showLog('Request -> ${json.encode(request)}');
      var response = await Provider.of<GetAllBuddiesReposotory>(context, listen: false).acceptRejectRequest(request);
      showLog('$responseTag $response');
      await _progressDialog.hide();
      if (response != 0) {
        if (acceptReject == 'R') {
          if (widget.allBuddiesModel!.status == 'Friend') {
            showSnackBarColor('Friend Removed', context, false);
          } else {
            if (type == 'FR') {
              showSnackBarColor('Friend Request Rejected', context, false);
            } else {
              showSnackBarColor('Friend Request Cancelled', context, false);
            }
          }
        } else {
          showSnackBarColor('Friend Request Accepted', context, false);
        }
        Navigator.pop(context, true);
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

  Future<void> callCancelRequest(AllBuddiesModel allBuddiesModel, String type) async {
    debugPrint('c');
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait...");
    try {
      await _progressDialog.show();
      Map<String, dynamic> request = {};
      request['FriendId'] = widget.allBuddiesModel!.friendId;
      request['Status'] = 'R';
      request['IsActive'] = false;
      showLog('Request -> ${json.encode(request)}');
      var response = await Provider.of<GetAllBuddiesReposotory>(context, listen: false).acceptRejectRequest(request);
      showLog('$responseTag $response');
      await _progressDialog.hide();
      if (response != 0) {
        if (allBuddiesModel.status == 'Friend') {
          showSnackBarColor('Friend Removed', context, false);
        } else {
          if (type == 'FR') {
            showSnackBarColor('Friend Request Rejected', context, false);
          } else {
            showSnackBarColor('Friend Request Cancelled', context, false);
          }
        }
        // await Navigator.pushNamedAndRemoveUntil(context, Constants.APPPAGES, Helper.of(context).predicate,
        //     arguments: 0);
        Navigator.pop(context, true);
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
