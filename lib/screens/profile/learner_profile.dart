// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/helper/helpers.dart';
import 'package:oqdo_mobile_app/model/EndUserAddressResponseModel.dart';
import 'package:oqdo_mobile_app/model/common_passing_args.dart';
import 'package:oqdo_mobile_app/model/end_user_profile_response.dart';
import 'package:oqdo_mobile_app/model/get_all_activity_and_sub_activity_response.dart';
import 'package:oqdo_mobile_app/model/upload_file_response.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/domain/chat_provider.dart';
import 'package:oqdo_mobile_app/screens/profile/intent/refer_earn_intent.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/close_account_popup.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:oqdo_mobile_app/viewmodels/ProfileViewModel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class LearnerProfilePage extends StatefulWidget {
  const LearnerProfilePage({Key? key}) : super(key: key);

  @override
  LearnerProfilePageState createState() => LearnerProfilePageState();
}

class LearnerProfilePageState extends State<LearnerProfilePage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  MediaQueryData get dimensions => MediaQuery.of(context);
  Map<String, List<SelectedFilterValues>>? selectedFilterData = {};

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  late Helper hp;
  TextEditingController hoursController = TextEditingController();
  TextEditingController minsController = TextEditingController();
  bool isEditProfile = false;
  bool isEditContact = false;
  bool isEditWork = false;
  String selectedHour = "";
  String selectedMinute = "";
  EndUserProfileResponseModel endUserProfileResponseModel = EndUserProfileResponseModel();
  late ProgressDialog progressDialog;
  String userName = '';
  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController postalController = TextEditingController();
  TextEditingController icNumberController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool? makeProfilePrivate = false;
  List<EndUserAddressResponseModel> endUserAddressList = [];
  int? mobileNumberLength;
  int? profileId;
  String? profileImage;
  CroppedFile? croppedFile;
  bool? isImageSelectedFromFile = false;

  // File? profileImageFile;
  var picker = ImagePicker();
  int? mobileNoLength = 0;
  String? mobileNoLengthStr = '';
  List<ActivityBean> activityListModel = [];
  CommonPassingArgs commonPassingArgs = CommonPassingArgs();
  bool? isActivityChanges = false;
  List<String> sections = [];
  LinkedHashMap<String, List<EndUserSubActivityDto>> sectionInterest = LinkedHashMap<String, List<EndUserSubActivityDto>>();
  bool isCircularProgressLoading = true;
  bool isCloseAccount = false;

  @override
  void initState() {
    super.initState();
    progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    progressDialog.style(message: "Please wait..");
    getUserProfile();
    getSharedPrefData();
  }

  void getSharedPrefData() async {
    // String? numberLength = OQDOApplication.instance.storage.getStringValue(AppStrings.mobileNoLength);
    String numberLength = '8';
    mobileNumberLength = int.parse(numberLength);
    // mobileNoLengthStr = OQDOApplication.instance.storage.getStringValue(AppStrings.mobileNoLength);
    mobileNoLengthStr = '8';
    mobileNoLength = int.parse(mobileNoLengthStr!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: endUserProfileResponseModel.firstName != null
            ? Container(
                width: width,
                height: height,
                color: ColorsUtils.white,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextView(
                            label: "Profile", type: styleSubTitle, textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (isEditProfile) {
                                  bottomSheetImage();
                                }
                              },
                              child: croppedFile == null
                                  ? Card(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      child: SizedBox(
                                        height: 70,
                                        width: 70,
                                        child: Image.network(
                                          OQDOApplication.instance.profileImage ?? "",
                                          fit: BoxFit.cover,
                                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, error, trace) {
                                            return ClipRRect(
                                              borderRadius: BorderRadius.circular(10.0),
                                              child: const SizedBox(
                                                height: 70,
                                                width: 70,
                                                child: Icon(Icons.account_circle_rounded, size: 70),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  : Card(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      child: SizedBox(
                                        height: 70,
                                        width: 70,
                                        child: Image.file(
                                          File(croppedFile!.path),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(
                              width: 18,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  CustomTextView(
                                    label: OQDOApplication.instance.userName,
                                    textOverFlow: TextOverflow.ellipsis,
                                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 20),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  CustomTextView(
                                    label: userName,
                                    textOverFlow: TextOverflow.ellipsis,
                                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.primary, fontSize: 18),
                                  ),
                                  // CustomTextView(
                                  //   label: endUserProfileResponseModel.userId.toString(),
                                  //   textStyle: Theme.of(context)
                                  //       .textTheme
                                  //       .bodyMedium!
                                  //       .copyWith(color: Theme.of(context).colorScheme.primary, fontSize: 14),
                                  // ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            isEditProfile
                                ? GestureDetector(
                                    onTap: () {
                                      hideKeyboard();
                                      if (croppedFile != null) {
                                        // profileImageFile = File(pickedFile.path);
                                        var bytes = File(croppedFile!.path).readAsBytesSync();
                                        String convertedBytes = base64Encode(bytes);
                                        uploadFile(convertedBytes);
                                      } else if (endUserAddressList.isEmpty) {
                                        showSnackBarColor('Please add training address', context, true);
                                      } else {
                                        updateEndUserProfileCall(context);
                                      }
                                    },
                                    child: Image.asset(
                                      "assets/images/ic_save.png",
                                      fit: BoxFit.scaleDown,
                                      height: 30,
                                      width: 30,
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isEditProfile = true;
                                      });
                                    },
                                    child: Image.asset(
                                      "assets/images/ic_edit.png",
                                      fit: BoxFit.scaleDown,
                                      height: 30,
                                      width: 30,
                                    ),
                                  ),
                          ],
                        ),
                        const SizedBox(
                          height: 26,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextView(
                              label: 'Contact Details',
                              textOverFlow: TextOverflow.ellipsis,
                              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 20),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            isEditContact
                                ? GestureDetector(
                                    onTap: () {
                                      hideKeyboard();
                                      if (croppedFile != null) {
                                        // profileImageFile = File(pickedFile.path);
                                        var bytes = File(croppedFile!.path).readAsBytesSync();
                                        String convertedBytes = base64Encode(bytes);
                                        uploadFile(convertedBytes);
                                      } else if (endUserAddressList.isEmpty) {
                                        showSnackBarColor('Please add training address', context, true);
                                      } else {
                                        updateEndUserProfileCall(context);
                                      }
                                    },
                                    child: Image.asset(
                                      "assets/images/ic_save.png",
                                      fit: BoxFit.scaleDown,
                                      height: 30,
                                      width: 30,
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isEditContact = true;
                                      });
                                    },
                                    child: Image.asset(
                                      "assets/images/ic_edit.png",
                                      fit: BoxFit.scaleDown,
                                      height: 30,
                                      width: 30,
                                    ),
                                  ),
                          ],
                        ),

                        // name
                        const SizedBox(
                          height: 8,
                        ),
                        CustomTextView(
                            label: "Name",
                            type: styleSubTitle,
                            textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: ColorsUtils.subTitle, fontSize: 14)),
                        const SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          enabled: isEditContact,
                          controller: nameController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          maxLines: 1,
                          maxLength: 50,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9 ]+')),
                          ],
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16, color: Theme.of(context).colorScheme.primary),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                            border: UnderlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        CustomTextView(
                            label: "Last Name",
                            type: styleSubTitle,
                            textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: ColorsUtils.subTitle, fontSize: 14)),
                        const SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          enabled: isEditContact,
                          controller: lastNameController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          maxLines: 1,
                          maxLength: 50,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9 ]+')),
                          ],
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16, color: Theme.of(context).colorScheme.primary),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                            border: UnderlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        CustomTextView(
                          label: "Email",
                          type: styleSubTitle,
                          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: ColorsUtils.subTitle.withOpacity(0.5), fontSize: 14),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          enabled: false,
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                              ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorsUtils.subTitle.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),

                        //phone no.
                        const SizedBox(
                          height: 16,
                        ),
                        CustomTextView(
                          label: "Phone Number",
                          type: styleSubTitle,
                          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: ColorsUtils.subTitle.withOpacity(0.5), fontSize: 14),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          enabled: false,
                          controller: phoneController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          maxLines: 1,
                          autofocus: false,
                          maxLength: mobileNoLength ?? 10,
                          // validator: Validator.validateMobile,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                              ),
                          decoration: InputDecoration(
                            isDense: true,
                            counterText: '',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorsUtils.subTitle.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                        // mobileNoLength! > 8
                        //     ? TextFormField(
                        //         enabled: false,
                        //         controller: phoneController,
                        //         keyboardType: TextInputType.number,
                        //         textInputAction: TextInputAction.next,
                        //         maxLines: 1,
                        //         autofocus: false,
                        //         maxLength: 10,
                        //         validator: Validator.validateMobile,
                        //         inputFormatters: [
                        //           FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        //           FilteringTextInputFormatter.digitsOnly,
                        //         ],
                        //         style: Theme.of(context)
                        //             .textTheme
                        //             .bodyMedium!
                        //             .copyWith(fontSize: 16, color: Theme.of(context).colorScheme.primary),
                        //         decoration: const InputDecoration(
                        //           isDense: true,
                        //           counterText: '',
                        //           contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                        //           border: UnderlineInputBorder(),
                        //         ),
                        //       )
                        //     : TextFormField(
                        //         enabled: isEditContact,
                        //         controller: phoneController,
                        //         keyboardType: TextInputType.number,
                        //         textInputAction: TextInputAction.next,
                        //         maxLines: 1,
                        //         autofocus: false,
                        //         maxLength: 8,
                        //         validator: Validator.validateMobile,
                        //         inputFormatters: [
                        //           FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        //           FilteringTextInputFormatter.digitsOnly,
                        //         ],
                        //         style: Theme.of(context)
                        //             .textTheme
                        //             .bodyMedium!
                        //             .copyWith(fontSize: 16, color: Theme.of(context).colorScheme.primary),
                        //         decoration: const InputDecoration(
                        //           isDense: true,
                        //           counterText: '',
                        //           contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                        //           border: UnderlineInputBorder(),
                        //         ),
                        //       ),
                        const SizedBox(
                          height: 16,
                        ),
                        CustomTextView(
                          label: "Postal Code",
                          type: styleSubTitle,
                          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: ColorsUtils.subTitle,
                                fontSize: 14,
                              ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          enabled: isEditContact,
                          controller: postalController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          maxLines: 1,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          maxLength: 6,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16, color: Theme.of(context).colorScheme.primary),
                          decoration: const InputDecoration(
                            isDense: true,
                            counterText: '',
                            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                            border: UnderlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Row(
                          children: [
                            Transform.scale(
                              scale: 1.3,
                              child: Checkbox(
                                  fillColor: MaterialStateProperty.resolveWith(getColor),
                                  checkColor: Theme.of(context).colorScheme.primaryContainer,
                                  value: makeProfilePrivate,
                                  onChanged: (value) {
                                    setState(() {
                                      if (isEditContact) {
                                        makeProfilePrivate = value;
                                      }
                                    });
                                  }),
                            ),
                            CustomTextView(
                              label: 'Make your profile private',
                              textStyle:
                                  Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.onBackground, fontSize: 14.0, fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 26,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextView(
                              label: 'Other Details',
                              textOverFlow: TextOverflow.ellipsis,
                              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 20),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            isEditWork
                                ? GestureDetector(
                                    onTap: () {
                                      hideKeyboard();
                                      if (croppedFile != null) {
                                        // profileImageFile = File(pickedFile.path);
                                        var bytes = File(croppedFile!.path).readAsBytesSync();
                                        String convertedBytes = base64Encode(bytes);
                                        uploadFile(convertedBytes);
                                      } else if (endUserAddressList.isEmpty) {
                                        showSnackBarColor('Please add training address', context, true);
                                      } else {
                                        updateEndUserProfileCall(context);
                                      }
                                    },
                                    child: Image.asset(
                                      "assets/images/ic_save.png",
                                      fit: BoxFit.scaleDown,
                                      height: 22,
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isEditWork = true;
                                      });
                                    },
                                    child: Image.asset(
                                      "assets/images/ic_edit.png",
                                      fit: BoxFit.scaleDown,
                                      height: 30,
                                      width: 30,
                                    ),
                                  ),
                          ],
                        ),

                        // ic no
                        const SizedBox(
                          height: 16,
                        ),
                        CustomTextView(
                          label: "IC Number",
                          type: styleSubTitle,
                          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: ColorsUtils.subTitle,
                                fontSize: 14,
                              ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          enabled: isEditWork,
                          controller: icNumberController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          maxLines: 1,
                          maxLength: 4,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]+')),
                          ],
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16, color: Theme.of(context).colorScheme.primary),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                            border: UnderlineInputBorder(),
                          ),
                        ),

                        //activity
                        const SizedBox(
                          height: 16,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CustomTextView(
                              label: 'Interests',
                              textOverFlow: TextOverflow.ellipsis,
                              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (isEditWork) {
                                  for (var activity in activityListModel) {
                                    if (isActivityChanges ?? false) {
                                      for (var key in selectedFilterData!.keys) {
                                        if (activity.Name == key) {
                                          for (var subActivity in activity.SubActivities!) {
                                            for (var addedSubActivity in selectedFilterData![key]!) {
                                              if (subActivity.SubActivityId == addedSubActivity.subActivityId) {
                                                subActivity.selectedValue = true;
                                              }
                                            }
                                          }
                                        }
                                      }
                                    } else {
                                      for (var key in sectionInterest.keys) {
                                        if (activity.Name == key) {
                                          for (var subActivity in activity.SubActivities!) {
                                            for (var addedSubActivity in sectionInterest[key]!) {
                                              if (subActivity.SubActivityId == addedSubActivity.subActivityId) {
                                                subActivity.selectedValue = true;
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                  Map<String, List<SubActivitiesBean>> interestValue = {};
                                  for (int i = 0; i < activityListModel.length; i++) {
                                    interestValue[activityListModel[i].Name!] = activityListModel[i].SubActivities!;
                                  }
                                  commonPassingArgs.endUserActivitySelection = interestValue;
                                  var data = await Navigator.pushNamed(context, Constants.activityInterestFilterScreen, arguments: commonPassingArgs);
                                  debugPrint(data.toString());
                                  if (data != null) {
                                    setState(() {
                                      selectedFilterData = data as Map<String, List<SelectedFilterValues>>?;
                                      isActivityChanges = true;
                                      debugPrint(selectedFilterData.toString());
                                    });
                                  } /*else{
                                    setState(() {
                                      for (var activity in activityListModel) {
                                        for (var key in sectionInterest.keys) {
                                          if (activity.Name == key) {
                                            for (var subActivity in activity.SubActivities!) {
                                              for (var addedSubActivity in sectionInterest[key]!) {
                                                if (subActivity.SubActivityId == addedSubActivity.subActivityId) {
                                                  subActivity.selectedValue = true;
                                                }else{
                                                  subActivity.selectedValue = false;
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                      Map<String, List<SubActivitiesBean>> interestValue = {};
                                      for (int i = 0; i < activityListModel.length; i++) {
                                        interestValue[activityListModel[i].Name!] = activityListModel[i].SubActivities!;
                                      }
                                      commonPassingArgs.endUserActivitySelection = interestValue;
                                    });
                                  }*/
                                }
                              },
                              child: isEditWork
                                  ? Image.asset(
                                      "assets/images/ic_add.png",
                                      fit: BoxFit.fitWidth,
                                      height: 50,
                                      width: 50,
                                    )
                                  : const SizedBox(),
                            ),
                          ],
                        ),
                        !isActivityChanges!
                            ? sectionInterest.isNotEmpty
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
                                                    .copyWith(color: ColorsUtils.chipText, fontWeight: FontWeight.w400, fontSize: 18.0),
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
                                                              label: sectionInterest[sectionInterest.keys.toList()[index]]![indexInterest].subActivityName),
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
                                : Container()
                            : selectedFilterData?.isNotEmpty ?? false
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: selectedFilterData!.length,
                                    itemBuilder: (context, index) {
                                      String name = selectedFilterData!.keys.elementAt(index);
                                      return Wrap(
                                        children: [
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                                                child: CustomTextView(
                                                  label: name,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(fontSize: 12.0, fontWeight: FontWeight.w400, color: ColorsUtils.subTitle),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 8.0,
                                              ),
                                              Wrap(
                                                spacing: 10.0,
                                                runSpacing: 8.0,
                                                children: [
                                                  for (var item in selectedFilterData![name]!) chipsWidget(item),
                                                  const SizedBox(
                                                    height: 5.0,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 8.0,
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  )
                                : CustomTextView(
                                    label: '(Select your interests)',
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(fontSize: 15.0, fontWeight: FontWeight.w400, color: Theme.of(context).colorScheme.onBackground),
                                  ),
                        //description.
                        const SizedBox(
                          height: 26,
                        ),
                        CustomTextView(
                            label: "About Yourself",
                            type: styleSubTitle,
                            textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: ColorsUtils.subTitle, fontSize: 14)),
                        const SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          enabled: isEditWork,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.done,
                          minLines: 1,
                          maxLines: 3,
                          controller: descriptionController,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16, color: Theme.of(context).colorScheme.primary),
                          decoration: const InputDecoration(
                            isDense: true,
                            counterText: '',
                            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                            border: UnderlineInputBorder(),
                          ),
                        ),

                        //training address
                        const SizedBox(
                          height: 26,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: CustomTextView(
                                label: 'Training Address',
                                textOverFlow: TextOverflow.ellipsis,
                                textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 20),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (isEditWork) {
                                  Navigator.pushNamed(context, Constants.endUserTrainingAddress).then((value) {
                                    if (value != null) {
                                      bool data = value as bool;
                                      if (data) {
                                        Future.delayed(const Duration(milliseconds: 200), () {
                                          getEndUserAddress();
                                        });
                                      }
                                    }
                                  });
                                }
                              },
                              child: isEditWork
                                  ? Image.asset(
                                      "assets/images/ic_add.png",
                                      fit: BoxFit.fitWidth,
                                      height: 50,
                                      width: 50,
                                    )
                                  : const SizedBox(),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        endUserAddressList.isNotEmpty
                            ? ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: endUserAddressList.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      children: [
                                        // Image.asset(
                                        //   'assets/images/ic_edit.png',
                                        //   width: 25,
                                        //   height: 25,
                                        // ),
                                        // const SizedBox(
                                        //   width: 20,
                                        // ),
                                        Visibility(
                                          visible: isEditWork,
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                // edit training address
                                                Navigator.pushNamed(context, Constants.endUserTrainingAddress, arguments: endUserAddressList[index])
                                                    .then((value) {
                                                  if (value != null) {
                                                    bool data = value as bool;
                                                    if (data) {
                                                      getEndUserAddress();
                                                    }
                                                  }
                                                });
                                              },
                                              child: Image.asset(
                                                'assets/images/ic_edit.png',
                                                width: 25,
                                                fit: BoxFit.fill,
                                                height: 25,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CustomTextView(
                                                label: endUserAddressList[index].addressName,
                                                textOverFlow: TextOverflow.ellipsis,
                                                maxLine: 2,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(fontSize: 14.0, fontWeight: FontWeight.bold, color: ColorsUtils.subTitle),
                                              ),
                                              const SizedBox(
                                                height: 8.0,
                                              ),
                                              CustomTextView(
                                                label:
                                                    '${endUserAddressList[index].address1!},${endUserAddressList[index].address2!},${endUserAddressList[index].cityName!} - ${endUserAddressList[index].pinCode!}',
                                                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14.0, color: ColorsUtils.subTitle),
                                                maxLine: 2,
                                                textOverFlow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Visibility(
                                          visible: isEditWork,
                                          child: GestureDetector(
                                            onTap: () {
                                              showDeleteAlertDialog(endUserAddressList[index]);
                                            },
                                            child: Image.asset(
                                              'assets/images/ic_profile_delete.png',
                                              width: 25,
                                              fit: BoxFit.fill,
                                              height: 25,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return const Divider();
                                },
                              )
                            : Container(),
                        const Divider(),

                        const SizedBox(
                          height: 15,
                        ),

                        InkWell(
                          onTap: () {
                            if (endUserProfileResponseModel.referralCode != OQDOApplication.instance.configResponseModel!.defaultRefCode) {
                              ReferEarnIntent intent =
                                  ReferEarnIntent(referCode: endUserProfileResponseModel.referralCode, userType: OQDOApplication.instance.userType);
                              Navigator.of(context).pushNamed(Constants.referEarnScreen, arguments: intent);
                            } else {
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => WillPopScope(
                                        onWillPop: () async => false,
                                        child: AlertDialog(
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.cancel,
                                                color: ColorsUtils.redColor,
                                                size: 100.0,
                                              ),
                                              const SizedBox(height: 10.0),
                                              const Text(
                                                  "There appears to have been an error in generating your referral code during the registration process. Please contact Oqdo to obtain a new one."),
                                              const SizedBox(height: 20.0),
                                              MyButton(
                                                text: 'Okay',
                                                textcolor: Theme.of(context).colorScheme.onBackground,
                                                textsize: 14,
                                                fontWeight: FontWeight.w500,
                                                letterspacing: 0.7,
                                                buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                                                buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                                                buttonheight: 40.0,
                                                buttonwidth: 100,
                                                radius: 15,
                                                onTap: () async {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ));
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0), // Adjust radius as needed
                              color: ColorsUtils.referEarnColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8),
                                          child: Image.asset(
                                            'assets/images/ic_earn.png',
                                            height: 30,
                                            width: 30,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            "Refer and Earn",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: ColorsUtils.white,
                                              fontSize: 20.0, // Adjust font size as needed
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Image.asset(
                                    'assets/images/ic_refer_earn_arrow.png',
                                    fit: BoxFit.contain,
                                    width: 30,
                                    height: 30,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        //close account
                        !isCloseAccount
                            ? InkWell(
                                onTap: () {
                                  openCloseAccountDialog();
                                },
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0), // Adjust radius as needed
                                    color: ColorsUtils.closeAccountColor,
                                  ),
                                  child: const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        "Close Account",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 18.0, // Adjust font size as needed
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  'Account Closure Request in Process',
                                  style: TextStyle(color: ColorsUtils.redColor, fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Center(
                child: isCircularProgressLoading
                    ? const CircularProgressIndicator()
                    : CustomTextView(
                        label: 'User not found',
                        textStyle:
                            Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onBackground, fontSize: 16.0),
                      ),
              ),
      ),
    );
  }

  chipsWidget(SelectedFilterValues item) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsUtils.chipBackground,
        border: Border.all(color: ColorsUtils.chipBackground),
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
      child: CustomTextView(
          textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: ColorsUtils.chipText, fontSize: 13.0, fontWeight: FontWeight.w400),
          label: item.activityName),
    );
  }

  Future<void> getUserProfile() async {
    try {
      await Provider.of<ProfileViewModel>(context, listen: false).getEndUserProfile(OQDOApplication.instance.endUserID!).then(
        (value) async {
          Response res = value;
          if (res.statusCode == 500 || res.statusCode == 404) {
            setState(() {
              isCircularProgressLoading = false;
            });
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            endUserProfileResponseModel = EndUserProfileResponseModel.fromJson(jsonDecode(res.body));
            setState(() {
              isCircularProgressLoading = false;
              userName = endUserProfileResponseModel.userName ?? '';
              nameController.text = endUserProfileResponseModel.firstName ?? '';
              lastNameController.text = endUserProfileResponseModel.lastName ?? '';
              emailController.text = endUserProfileResponseModel.regEmail ?? "";
              phoneController.text = endUserProfileResponseModel.mobileNumber ?? "";
              postalController.text = endUserProfileResponseModel.pinCode ?? "";
              profileId = endUserProfileResponseModel.profileImageId;
              profileImage = endUserProfileResponseModel.profileImage;
              descriptionController.text = endUserProfileResponseModel.aboutYourSelf ?? "";
              debugPrint('Profile image ->${profileImage ?? ""}');
              if (endUserProfileResponseModel.isProfilePrivate ?? false) {
                makeProfilePrivate = true;
              } else {
                makeProfilePrivate = false;
              }
              icNumberController.text = endUserProfileResponseModel.icNo!;

              if (endUserProfileResponseModel.endUserSubActivityDto != null) {
                var set = <String>{};
                endUserProfileResponseModel.endUserSubActivityDto!.where((e) => set.add(e.activityName!)).toList();
                sections.addAll(set.toSet().toList());

                for (int i = 0; i < sections.length; i++) {
                  var list = endUserProfileResponseModel.endUserSubActivityDto!.where((f) => f.activityName! == sections[i]).toList();
                  sectionInterest[sections[i]] = list;
                }
              }

              if (endUserProfileResponseModel.accountClosureStatus == null || endUserProfileResponseModel.accountClosureStatus == 'R') {
                isCloseAccount = false;
              } else {
                isCloseAccount = true;
              }
            });
            getEndUserAddress();
            getAllActivity();
          } else {
            setState(() {
              isCircularProgressLoading = false;
            });
            Map<String, dynamic> errorModel = jsonDecode(res.body);
            if (errorModel.containsKey('ModelState')) {
              Map<String, dynamic> modelState = errorModel['ModelState'];
              if (modelState.containsKey('ErrorMessage')) {
                showSnackBarColor(modelState['ErrorMessage'][0], context, true);
              }
            }
          }
        },
      );
    } on NoConnectivityException catch (_) {
      setState(() {
        isCircularProgressLoading = false;
      });
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      setState(() {
        isCircularProgressLoading = false;
      });
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      setState(() {
        isCircularProgressLoading = false;
      });
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      setState(() {
        isCircularProgressLoading = false;
      });
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  Future<void> getAllActivity() async {
    try {
      await Provider.of<ProfileViewModel>(context, listen: false).getAllActivity().then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            GetAllActivityAndSubActivityResponse? getAllActivityAndSubActivityResponse = GetAllActivityAndSubActivityResponse.fromMap(jsonDecode(res.body));
            if (getAllActivityAndSubActivityResponse!.Data!.isNotEmpty) {
              setState(() {
                activityListModel = getAllActivityAndSubActivityResponse.Data!;
              });
            }
          } else {
            Map<String, dynamic> errorModel = jsonDecode(res.body);
            if (errorModel.containsKey('ModelState')) {
              Map<String, dynamic> modelState = errorModel['ModelState'];
              if (modelState.containsKey('ErrorMessage')) {
                showSnackBarColor(modelState['ErrorMessage'][0], context, true);
              }
            }
          }
        },
      );
    } on NoConnectivityException catch (_) {
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  Future<void> getEndUserAddress() async {
    if (progressDialog.isShowing()) {
      await progressDialog.hide();
    }

    try {
      await progressDialog.show();
      await Provider.of<ProfileViewModel>(context, listen: false).getEndUserAddress(OQDOApplication.instance.endUserID!).then(
        (value) async {
          Response res = value;
          if (res.statusCode == 500 || res.statusCode == 404) {
            await progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            await progressDialog.hide();
            List body = jsonDecode(res.body);
            List<EndUserAddressResponseModel> list = [];
            for (int i = 0; i < body.length; i++) {
              EndUserAddressResponseModel endUserAddressResponseModel = EndUserAddressResponseModel.fromJson(body[i]);
              list.add(endUserAddressResponseModel);
            }
            if (list.isNotEmpty) {
              await progressDialog.hide();
              setState(() {
                endUserAddressList.clear();
                endUserAddressList = list;
              });
            } else {
              setState(() {
                endUserAddressList.clear();
              });
              await progressDialog.hide();
            }
          } else {
            await progressDialog.hide();
            Map<String, dynamic> errorModel = jsonDecode(res.body);
            if (errorModel.containsKey('ModelState')) {
              Map<String, dynamic> modelState = errorModel['ModelState'];
              if (modelState.containsKey('ErrorMessage')) {
                showSnackBarColor(modelState['ErrorMessage'][0], context, true);
              }
            }
          }
        },
      );
    } on NoConnectivityException catch (_) {
      await progressDialog.hide();
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      await progressDialog.hide();
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      await progressDialog.hide();
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      await progressDialog.hide();
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  void showDeleteAlertDialog(EndUserAddressResponseModel model) => showCupertinoDialog(
        context: context,
        builder: ((context) {
          return CupertinoAlertDialog(
            title: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: CustomTextView(
                label: 'Training Address',
                textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.onBackground, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            content: CustomTextView(
              label: 'Are you sure you want to delete Training Address?',
              maxLine: 2,
              textOverFlow: TextOverflow.ellipsis,
              textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onBackground, fontSize: 16, fontWeight: FontWeight.w400),
            ),
            actions: [
              CupertinoDialogAction(
                  child: CustomTextView(label: 'Yes'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    deleteEndUserAddressCall(model);
                  }),
              CupertinoDialogAction(
                  child: CustomTextView(label: 'No'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ],
          );
        }),
      );

  Future<void> deleteEndUserAddressCall(EndUserAddressResponseModel model) async {
    // progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    // progressDialog.style(message: "Please wait..");
    if (progressDialog.isShowing()) {
      await progressDialog.hide();
    }

    try {
      await progressDialog.show();
      Map<String, dynamic> request = {};
      request['EndUserTrainingAddressId'] = model.endUserTrainingAddressId;
      await Provider.of<ProfileViewModel>(context, listen: false).deleteEndUserAddress(request).then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            await progressDialog.hide().whenComplete(() {});
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            await progressDialog.hide().whenComplete(() {});
            String response = res.body;
            if (response.isNotEmpty) {
              await progressDialog.hide();
              showSnackBarColor('Delete Successfully', context, false);
              Future.delayed(const Duration(milliseconds: 200), () {
                getEndUserAddress();
              });
            } else {
              await progressDialog.hide().whenComplete(() {});
            }
          } else {
            await progressDialog.hide().whenComplete(() {});
            Map<String, dynamic> errorModel = jsonDecode(res.body);
            if (errorModel.containsKey('ModelState')) {
              Map<String, dynamic> modelState = errorModel['ModelState'];
              if (modelState.containsKey('ErrorMessage')) {
                showSnackBarColor(modelState['ErrorMessage'][0], context, true);
              }
            }
          }
        },
      );
    } on NoConnectivityException catch (_) {
      await progressDialog.hide().whenComplete(() {});
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      await progressDialog.hide().whenComplete(() {});
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      await progressDialog.hide().whenComplete(() {});
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      await progressDialog.hide().whenComplete(() {});
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  Future<void> updateEndUserProfileCall(BuildContext context) async {
    if (nameController.text.toString().trim().isEmpty) {
      showSnackBar('Name required', context);
    }
    // else if (emailController.text.toString().trim().isEmpty) {
    //   showSnackBar('Email required', context);
    // }
    // else if (phoneController.text.trim().isEmpty) {
    //   showSnackBar('Phone required', context);
    // } else if (phoneController.text.toString().trim().length != mobileNumberLength) {
    //   showSnackBar('Enter valid phone number', context);
    // }
    else if (icNumberController.text.toString().trim().isNotEmpty && icNumberController.text.toString().trim().length < 4) {
      showSnackBar('4 digit IC Number is required', context);
    } else if (postalController.text.toString().trim().isNotEmpty && postalController.text.toString().trim().length < 6) {
      showSnackBar('6 digit postal code is required', context);
    } else {
      // progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      // progressDialog.style(message: "Please wait..");

      try {
        setState(() {
          isEditWork = false;
          isEditContact = false;
          isEditProfile = false;
        });

        progressDialog.show();
        Map<String, dynamic> request = {};
        request['EndUserId'] = OQDOApplication.instance.endUserID;
        request['RegServiceProviderId'] = endUserProfileResponseModel.regServiceProviderId;
        request['UserId'] = OQDOApplication.instance.userID;
        request['FirstName'] = nameController.text.toString().trim();
        request['LastName'] = lastNameController.text.toString().trim();
        request['IcNo'] = icNumberController.text.toString().trim();
        request['AboutYourSelf'] = descriptionController.text.toString().trim();
        request['ProfileImageId'] = profileId;
        request['IsProfilePrivate'] = makeProfilePrivate;
        request['IsActive'] = true;
        request['Status'] = endUserProfileResponseModel.status;
        request['PinCode'] = postalController.text.trim();

        if (isActivityChanges ?? false) {
          List<String> data = [];
          for (int i = 0; i < selectedFilterData!.keys.length; i++) {
            String key = selectedFilterData!.keys.elementAt(i);
            List<SelectedFilterValues> value = selectedFilterData![key]!;
            debugPrint("length -> ${value.length}");
            for (var element in value) {
              data.add(element.subActivityId.toString());
            }
          }
          debugPrint(data.length.toString());

          List<Map> subActivityMapList = [];
          for (int i = 0; i < data.length; i++) {
            Map map = {};
            map['SubActivityId'] = data[i];
            subActivityMapList.add(map);
          }

          debugPrint(subActivityMapList.toString());
          request['EndUserSubActivityDtos'] = subActivityMapList;
        } else {
          List<Map<String, dynamic>> list = [];
          for (int i = 0; i < endUserProfileResponseModel.endUserSubActivityDto!.length; i++) {
            Map<String, dynamic> map = {};

            map['SubActivityId'] = endUserProfileResponseModel.endUserSubActivityDto![i].subActivityId;
            list.add(map);
          }
          request['EndUserSubActivityDtos'] = list;
        }
        debugPrint(request.toString());
        await Provider.of<ProfileViewModel>(context, listen: false).endUserProfileUpdate(request).then(
          (value) async {
            Response res = value;

            if (res.statusCode == 500 || res.statusCode == 404) {
              progressDialog.hide().whenComplete(() => {});
              showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
            } else if (res.statusCode == 200) {
              progressDialog.hide().whenComplete(() => {});
              String response = res.body;
              if (response.isNotEmpty) {
                showSnackBarColor('Profile updated successfully', context, false);
                setState(() {
                  OQDOApplication.instance.userName = '${nameController.text.toString().trim()} ${lastNameController.text.toString().trim()}';
                  context.read<ChatProvider>().setUserName('${nameController.text.toString().trim()} ${lastNameController.text.toString().trim()}');
                  isEditWork = false;
                  isEditContact = false;
                  isEditProfile = false;
                });
              }
            } else {
              progressDialog.hide().whenComplete(() => {});
              Map<String, dynamic> errorModel = jsonDecode(res.body);
              if (errorModel.containsKey('ModelState')) {
                Map<String, dynamic> modelState = errorModel['ModelState'];
                if (modelState.containsKey('ErrorMessage')) {
                  showSnackBarColor(modelState['ErrorMessage'][0], context, true);
                }
              }
            }
          },
        );
      } on NoConnectivityException catch (_) {
        progressDialog.hide().whenComplete(() => {});
        showSnackBarErrorColor(AppStrings.noInternet, context, true);
      } on TimeoutException catch (_) {
        progressDialog.hide().whenComplete(() => {});
        showSnackBarErrorColor(AppStrings.timeout, context, true);
      } on ServerException catch (_) {
        progressDialog.hide().whenComplete(() => {});
        showSnackBarErrorColor(AppStrings.serverError, context, true);
      } catch (exception) {
        progressDialog.hide().whenComplete(() => {});
        showSnackBarErrorColor(exception.toString(), context, true);
      }
    }
  }

  bottomSheetImage() async {
    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text(
                      'Photo Library',
                      style: TextStyle(
                          // fontFamily: 'Fingbanger',
                          ),
                    ),
                    onTap: () async {
                      if (Constants.androidVersion >= 13) {
                        getPicFromGallery();
                      } else {
                        // var serviceStatus = await Permission.storage.isGranted;
                        var status = await Permission.storage.request();
                        if (status == PermissionStatus.granted) {
                          getPicFromGallery();
                        } else if (status == PermissionStatus.denied) {
                          showSnackBar('Permission denied.Please Allow Permission.', context);
                        } else if (status == PermissionStatus.permanentlyDenied) {
                          await openAppSettings();
                        }
                      }
                    }),
                ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text(
                      'Camera',
                      style: TextStyle(
                          // fontFamily: 'Fingbanger',
                          ),
                    ),
                    onTap: () async {
                      var status = await Permission.camera.request();
                      if (status == PermissionStatus.granted) {
                        getPicFromCam();
                      } else if (status == PermissionStatus.denied) {
                        if (status == PermissionStatus.granted) {
                          getPicFromCam();
                        } else {
                          showSnackBar('Permission denied.Please Allow Permission.', context);
                        }
                      } else if (status == PermissionStatus.permanentlyDenied) {
                        await openAppSettings();
                      }
                    } //getPicFromCam
                    ),
              ],
            ),
          );
        });
  }

  Future getPicFromCam() async {
    Navigator.pop(context);
    await progressDialog.show();
    setState(() {});
    var pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _cropImage(pickedFile);
    } else {
      await progressDialog.hide();
      setState(() {});
    }
  }

  Future getPicFromGallery() async {
    Navigator.pop(context);
    await progressDialog.show();
    setState(() {});
    var pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);
    if (pickedFile != null) {
      _cropImage(pickedFile);
      // var byte = await File(pickedFile.path).length();
      // var kb = byte / 1024;
      // var mb = kb / 1024;
      // debugPrint("File size -> ${mb.toString()}");
      // if (mb < 10.0) {
      //   await progressDialog.hide();
      //   profileImageFile = File(pickedFile.path);
      //   setState(() {});
      //   var bytes = File(profileImageFile!.path).readAsBytesSync();
      //   String convertedBytes = base64Encode(bytes);
      //   // uploadFile(convertedBytes);
      // } else {
      //   await progressDialog.hide();
      //   setState(() {});
      //   showSnackBarErrorColor("Please select image below 10 MB", context, true);
      // }
    } else {
      await progressDialog.hide();
      setState(() {});
    }
  }

  Future<void> _cropImage(XFile pickedFile) async {
    var mCroppedFile = await ImageCropper().cropImage(sourcePath: pickedFile.path, compressFormat: ImageCompressFormat.jpg, compressQuality: 100, uiSettings: [
      AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: OQDOThemeData.buttonColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false),
      IOSUiSettings(
        title: 'Cropper',
      ),
    ]);

    if (mCroppedFile != null) {
      var byte = await File(mCroppedFile.path).length();
      var kb = byte / 1024;
      var mb = kb / 1024;
      debugPrint("File size -> ${mb.toString()}");
      if (mb < 10.0) {
        await progressDialog.hide();
        croppedFile = mCroppedFile;
        setState(() {});
        var bytes = File(mCroppedFile.path).readAsBytesSync();
        String convertedBytes = base64Encode(bytes);
        // uploadFile(convertedBytes);
      } else {
        await progressDialog.hide();
        setState(() {});
        showSnackBarErrorColor("Please select image below 10 MB", context, true);
      }
    } else {
      await progressDialog.hide();
      setState(() {});
    }
  }

  Future<void> uploadFile(String base64File) async {
    hideKeyboard();
    // progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    // progressDialog.style(message: "Please wait..");

    await progressDialog.show();
    Map uploadFileRequest = {};
    uploadFileRequest['FileStorageId'] = null;
    uploadFileRequest['FileName'] = croppedFile!.path.split('/').last;
    uploadFileRequest['FileExtension'] = croppedFile!.path.split('/').last.split('.')[1];
    uploadFileRequest['FilePath'] = base64File;

    try {
      await Provider.of<ProfileViewModel>(context, listen: false).uploadFile(uploadFileRequest).then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            progressDialog.hide().whenComplete(() => {});
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            progressDialog.hide().whenComplete(() => {});
            UploadFileResponse? uploadFileResponse = UploadFileResponse.fromMap(jsonDecode(res.body));
            debugPrint('Upload File Response -> ${uploadFileResponse!.FileStorageId}');
            Provider.of<ChatProvider>(context, listen: false).setProfileImagePath(uploadFileResponse.FilePath!);
            setState(() {
              OQDOApplication.instance.profileImage = uploadFileResponse.FilePath;
            });
            isImageSelectedFromFile = true;
            profileId = uploadFileResponse.FileStorageId;
            if (endUserAddressList.isEmpty) {
              showSnackBarColor('Please add training address', context, true);
            } else {
              updateEndUserProfileCall(context);
            }
          } else {
            progressDialog.hide().whenComplete(() => {});
            Map<String, dynamic> errorModel = jsonDecode(res.body);
            if (errorModel.containsKey('ModelState')) {
              Map<String, dynamic> modelState = errorModel['ModelState'];
              if (modelState.containsKey('ErrorMessage')) {
                showSnackBarColor(modelState['ErrorMessage'][0], context, true);
              }
            }
          }
        },
      );
    } on NoConnectivityException catch (_) {
      progressDialog.hide().whenComplete(() => {});
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      progressDialog.hide().whenComplete(() => {});
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      progressDialog.hide().whenComplete(() => {});
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      progressDialog.hide().whenComplete(() => {});
      showSnackBarErrorColor(exception.toString(), context, true);
    }

    try {
      UploadFileResponse uploadFileResponse = await Provider.of<ProfileViewModel>(context, listen: false).uploadFile(uploadFileRequest);
      progressDialog.hide().whenComplete(() => {});
      debugPrint('Upload File Response -> ${uploadFileResponse.FileStorageId}');
      Provider.of<ChatProvider>(context, listen: false).setProfileImagePath(uploadFileResponse.FilePath!);
      setState(() {
        OQDOApplication.instance.profileImage = uploadFileResponse.FilePath;
      });
      isImageSelectedFromFile = true;
      profileId = uploadFileResponse.FileStorageId;
      if (endUserAddressList.isEmpty) {
        showSnackBarColor('Please add training address', context, true);
      } else {
        updateEndUserProfileCall(context);
      }
    } on CommonException catch (error) {
      progressDialog.hide().whenComplete(() => {});
      debugPrint(error.message);
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
      } else {
        showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
    } on NoConnectivityException catch (_) {
      progressDialog.hide().whenComplete(() => {});
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      progressDialog.hide().whenComplete(() => {});
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  openCloseAccountDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CloseAccountDialog(
        no: () async {
          Navigator.pop(context);
        },
        yes: () async {
          Navigator.pop(context);
          callAccountClose();
        },
      ),
    );
  }

  Future<void> callAccountClose() async {
    try {
      await progressDialog.show();
      Map<String, dynamic> request = {};
      request['EndUserId'] = OQDOApplication.instance.endUserID!;
      request['AccountClosureStatus'] = 'P';
      await Provider.of<ProfileViewModel>(context, listen: false).endUserAccountClose(request).then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            await progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            String response = res.body;
            if (response.isNotEmpty) {
              await progressDialog.hide();
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return WillPopScope(
                    onWillPop: () async => false,
                    child: AlertDialog(
                      title: const Text(''),
                      content: const Text(
                          'We have received your request to close your account. Our Support Team will now proceed to review and process your request, which may take up to 72 hours. If you require further assistance, please don\'t hesitate to reach out to us via our website.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() {
                              isCloseAccount = true;
                            });
                          },
                            child: Text(
                              'Close',
                              style: TextStyle(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          } else {
            await progressDialog.hide();
            Map<String, dynamic> errorModel = jsonDecode(res.body);
            if (errorModel.containsKey('ModelState')) {
              Map<String, dynamic> modelState = errorModel['ModelState'];
              if (modelState.containsKey('ErrorMessage')) {
                showSnackBarColor(modelState['ErrorMessage'][0], context, true);
              }
            }
          }
        },
      );
    } on NoConnectivityException catch (_) {
      await progressDialog.hide();
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      await progressDialog.hide();
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      await progressDialog.hide();
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      await progressDialog.hide();
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }
}
