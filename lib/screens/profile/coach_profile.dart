// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/helper/helpers.dart';
import 'package:oqdo_mobile_app/model/coach_training_address.dart';
import 'package:oqdo_mobile_app/model/common_passing_args.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/domain/chat_provider.dart';
import 'package:oqdo_mobile_app/screens/common_widget/view_image_screen.dart';
import 'package:oqdo_mobile_app/screens/profile/intent/refer_earn_intent.dart';
import 'package:oqdo_mobile_app/utils/close_account_popup.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/enums.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:oqdo_mobile_app/utils/textfields_widget.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:oqdo_mobile_app/utils/validator.dart';
import 'package:oqdo_mobile_app/viewmodels/ProfileViewModel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import '../../model/coach_profile_response.dart';
import '../../model/get_all_activity_and_sub_activity_response.dart';
import '../../model/upload_file_response.dart';
import '../../utils/constants.dart';

class CoachProfilePage extends StatefulWidget {
  const CoachProfilePage({Key? key}) : super(key: key);

  @override
  CoachProfilePageState createState() => CoachProfilePageState();
}

class CoachProfilePageState extends State<CoachProfilePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  MediaQueryData get dimensions => MediaQuery.of(context);

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
  bool isEditPayoutMethod = false;
  bool isEditCancellationPolicy = false;
  String selectedHour = "0";
  String selectedMinute = "00";
  String userName = '';
  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailIdController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController postalController = TextEditingController();
  TextEditingController uenNumberController = TextEditingController();
  TextEditingController icNumberController = TextEditingController();
  TextEditingController coachRegistryIdController = TextEditingController();
  TextEditingController coachExperienceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController coachCertificatesController = TextEditingController();
  TextEditingController cancellationHoursController = TextEditingController();
  TextEditingController cancellationMinutesController = TextEditingController();
  final effectiveDateController = TextEditingController();
  File? profileImageFile;
  CroppedFile? croppedFile;
  bool? isImageSelectedFromFile = false;
  final picker = ImagePicker();
  late ProgressDialog _progressDialog;
  int? profileImageId;
  String? countryId;
  String? cityId;
  String? countryName;
  List<ActivityBean> activityListModel = [];
  Map<String, List<SelectedFilterValues>>? selectedFilterData = {};
  Map? endUserActivitySelection;
  int? selectedActivityId;
  List<CoachTrainingAddress>? coachTrainingAddressList = [];
  List<String> sections = [];
  LinkedHashMap<String, List<CoachSubActivityDtos>> sectionInterest = LinkedHashMap<String, List<CoachSubActivityDtos>>();
  List<String> certificateList = [];
  List<String>? certificateUploadId = [];
  File? profilepic;
  String uploadedImagePath = '';

  // CommonPassingArgs commonPassingArgs = CommonPassingArgs();
  bool? isActivityChanges = false;

  // final Duration _defaultSlotDuration = const Duration(hours: 00, minutes: 60);
  int _slotTimeInMins = 60;
  CoachProfileResponseModel coachProfileResponseModel = CoachProfileResponseModel();

  // new fields
  int? mobileNoLength = 0;
  List<PayoutMethodTypeEnum> payoutMethods = [
    PayoutMethodTypeEnum.payNow,
    PayoutMethodTypeEnum.payLah,
    PayoutMethodTypeEnum.bankDetails,
  ];
  PayoutMethodTypeEnum? selectedPayoutMethod;
  final payNowMobileNumberController = TextEditingController();
  final payNowIdController = TextEditingController();
  final payLahMobileNumberController = TextEditingController();
  final beneficiaryNameController = TextEditingController();
  final bankNameController = TextEditingController();
  final bankAccountNumberController = TextEditingController();
  final ifscCodeController = TextEditingController();
  final payoutDetailsKey = GlobalKey<FormState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  int maxCancellationMin = OQDOApplication.instance.configResponseModel?.maxCancellationPolicyMin ?? 0;
  Duration maxAllowedCancellationTime = const Duration(hours: 0, minutes: 0);
  String uploadedProfileFilePath = '';
  bool isCloseAccount = false;
  String currentEffectiveDate = '';

  InputDecoration _inputDecoration(BuildContext context,
      {String? counterText, TextStyle? errorStyle}) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      border: const UnderlineInputBorder(),
      enabledBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.onSurface)),
      focusedBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.primary)),
      disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.5))),
      counterText: counterText,
      errorStyle: errorStyle,
    );
  }

  @override
  void initState() {
    super.initState();
    maxAllowedCancellationTime = convertMinutesToDuration(maxCancellationMin);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(message: "Please wait...");
      cityId = OQDOApplication.instance.storage.getStringValue(AppStrings.selectedCountryID);
      // debugPrint('CityId ->' + cityId.toString());
      getCoachDetails();
    });
  }

  void setSlotValue(CoachProfileResponseModel coachProfileResponseModel) {
    if (coachProfileResponseModel.coachCancelPolicyDto == null) {
      // String finalTime = formatDuration(_defaultSlotDuration);
      // debugPrint('Init Slot Time -> $finalTime');
      //
      // String hrs = finalTime.split(":")[0];
      // String mins = finalTime.split(":")[1];
      // debugPrint(hrs);

      // selectedHour = hrs;
      // selectedMinute = mins;
      cancellationHoursController.text = '00';
      cancellationMinutesController.text = '00';
    } else {
      var lastCoachCancellationPolicy = coachProfileResponseModel.coachCancelPolicyDto;
      debugPrint('last policy -> ${lastCoachCancellationPolicy?.cancelMinute}');

      Duration cancelPolicyTime = Duration(minutes: lastCoachCancellationPolicy?.cancelMinute ?? 0);
      String finalTime = formatDuration(cancelPolicyTime);
      // String effectiveDate = lastCoachCancellationPolicy?.effectiveDate ?? "";
      // if (effectiveDate.isNotEmpty) {
      //   DateTime tempDate = DateTime.parse(effectiveDate);
      //   effectiveDateController.text = DateFormat("dd-MM-yyyy").format(tempDate);
      // }

      DateTime tempDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
      effectiveDateController.text = DateFormat("dd-MM-yyyy").format(tempDate);

      if (coachProfileResponseModel.coachCancelPolicyDto!.effectiveDate != null) {
        DateTime currentEffectiveDateStr = DateTime.parse(coachProfileResponseModel.coachCancelPolicyDto!.effectiveDate ?? '');

        currentEffectiveDate = DateFormat("dd-MM-yyyy").format(currentEffectiveDateStr);
      }

      String hrs = finalTime.split(":")[0];
      String mins = finalTime.split(":")[1];
      debugPrint(hrs);

      cancellationHoursController.text = hrs;
      cancellationMinutesController.text = mins;
      // selectedHour = hrs;
      // selectedMinute = mins;
    }
  }

  Future<void> calculateCancellationTimeInMinutes(String hours, String minutes) async {
    int hrs = int.parse(hours.isEmpty ? "00" : hours);
    int mins = int.parse(minutes.isEmpty ? "00" : minutes);
    int totalMins = (hrs * 60) + mins;
    debugPrint('Total Mins -> $totalMins');
    _slotTimeInMins = totalMins;
  }

  void setCoachValues(CoachProfileResponseModel coachProfileResponseModel) async {
    debugPrint(coachProfileResponseModel.firstName!);
    debugPrint('Profile image -> ${coachProfileResponseModel.profileImageId}');
    userName = coachProfileResponseModel.userName ?? '';
    nameController.text = coachProfileResponseModel.firstName ?? '';
    lastNameController.text = coachProfileResponseModel.lastName ?? '';
    emailIdController.text = coachProfileResponseModel.emailId!;
    phoneNumberController.text = coachProfileResponseModel.mobileNumber!;
    addressController.text = coachProfileResponseModel.address!;
    postalController.text = coachProfileResponseModel.pinCode!;
    icNumberController.text = coachProfileResponseModel.iCNumber!.replaceAll(".(?=.{4})", "*");
    coachRegistryIdController.text = coachProfileResponseModel.coachRegistoryNumber ?? '';
    coachExperienceController.text = coachProfileResponseModel.experienceYear == null ? '' : coachProfileResponseModel.experienceYear.toString();
    uenNumberController.text = coachProfileResponseModel.UENRegistrationNo == null ? '' : coachProfileResponseModel.UENRegistrationNo.toString();
    descriptionController.text = coachProfileResponseModel.otherDescription ?? '';
    debugPrint('Profile image -> ${coachProfileResponseModel.profileImageId}');
    profileImageId = coachProfileResponseModel.profileImageId;
    countryId = coachProfileResponseModel.mobCountryCode;
    countryName = coachProfileResponseModel.cityName;
    // new fields
    mobileNoLength = coachProfileResponseModel.mobCountryCode == "+65" ? 8 : 10;
    selectedPayoutMethod = coachProfileResponseModel.payoutMethod;
    if (selectedPayoutMethod == PayoutMethodTypeEnum.payNow) {
      payNowMobileNumberController.text = coachProfileResponseModel.mobileNum ?? "";
      payNowIdController.text = coachProfileResponseModel.payNowId ?? "";
    } else if (selectedPayoutMethod == PayoutMethodTypeEnum.payLah) {
      payLahMobileNumberController.text = coachProfileResponseModel.mobileNum ?? "";
    } else {
      bankAccountNumberController.text = coachProfileResponseModel.bankAccountNumber ?? "";
      bankNameController.text = coachProfileResponseModel.bankName ?? "";
      beneficiaryNameController.text = coachProfileResponseModel.beneficiaryName ?? "";
      ifscCodeController.text = coachProfileResponseModel.ifscSwiftCode ?? "";
    }
    if (coachProfileResponseModel.coachSubActivityDtos != null && coachProfileResponseModel.coachSubActivityDtos!.isNotEmpty) {
      setActivityAndSubActivityData();
    }
    debugPrint(coachProfileResponseModel.coachTrainingAddressDtos.toString());
    debugPrint(coachProfileResponseModel.profileImage);
    debugPrint(icNumberController.text);

    if (coachProfileResponseModel.coachSubActivityDtos != null) {
      var set = <String>{};
      coachProfileResponseModel.coachSubActivityDtos!.where((e) => set.add(e.activityName!)).toList();
      sections.addAll(set.toSet().toList());

      for (int i = 0; i < sections.length; i++) {
        var list = coachProfileResponseModel.coachSubActivityDtos!.where((f) => f.activityName! == sections[i]).toList();
        sectionInterest[sections[i]] = list;
      }
    }
    if (coachProfileResponseModel.coachCertificationDtos != null) {
      for (var certificate in coachProfileResponseModel.coachCertificationDtos!) {
        if (certificate.coachCertificationFileBase64 != null && certificate.coachCertificationFileBase64!.isNotEmpty) {
          certificateList.add(certificate.coachCertificationFileBase64!);
          certificateUploadId!.add("${certificate.coachCertificationFileStorageId ?? 0}");
        }
      }
    }
  }

  void setActivityAndSubActivityData() {
    selectedActivityId = coachProfileResponseModel.coachSubActivityDtos![0].activityId;
  }

  @override
  Widget build(BuildContext context) {
    return coachProfileResponseModel.coachTitle != null
        ? Scaffold(
            key: scaffoldKey,
            body: SafeArea(
              child: Container(
                width: width,
                height: height,
                color: ColorsUtils.white,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
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
                                    bottomSheetImage(false);
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
                                            coachProfileResponseModel.profileImage ?? "",
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
                              // Expanded(
                              //   child: Column(
                              //     mainAxisAlignment: MainAxisAlignment.start,
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [
                              //       const SizedBox(
                              //         height: 4,
                              //       ),
                              //       Text(
                              //         userName,
                              //         overflow: TextOverflow.ellipsis,
                              //         style: Theme.of(context)
                              //             .textTheme
                              //             .bodyMedium!
                              //             .copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 20),
                              //       ),
                              //       const SizedBox(
                              //         height: 2,
                              //       ),
                              //       Text(
                              //         coachProfileResponseModel.loginId!,
                              //         style: Theme.of(context)
                              //             .textTheme
                              //             .bodyMedium!
                              //             .copyWith(color: Theme.of(context).colorScheme.primary, fontSize: 12),
                              //       ),
                              //       const SizedBox(
                              //         height: 10,
                              //       ),
                              //       Text(
                              //         '',
                              //         style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: ColorsUtils.subTitle, fontSize: 14),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              const SizedBox(
                                width: 8,
                              ),
                              isEditProfile
                                  ? GestureDetector(
                                      onTap: () {
                                        hideKeyboard();
                                        if (formKey.currentState!.validate()) {
                                          if (postalController.text.toString().trim().isEmpty ||
                                              (postalController.text.toString().trim().isNotEmpty && postalController.text.toString().trim().length < 6)) {
                                            showSnackBar('6 digit postal code is required', context);
                                          } else if (icNumberController.text.toString().trim().length < 4) {
                                            showSnackBarColor('4 digit IC Number is required', context, true);
                                          } else if (effectiveDateController.text.trim().isNotEmpty && isEditCancellationPolicy) {
                                            hideKeyboard();

                                            int addedHours = int.parse(cancellationHoursController.text.isEmpty ? "0" : cancellationHoursController.text);
                                            int addedMinutes = int.parse(cancellationMinutesController.text.isEmpty ? "0" : cancellationMinutesController.text);

                                            if (effectiveDateController.text.trim().isEmpty) {
                                              showSnackBar('Please select effective date', context);
                                            } else if (addedMinutes > 59) {
                                              showSnackBar('Invalid minutes, minutes must be less than 60', context);
                                            } else if (maxAllowedCancellationTime.inMinutes > 0) {
                                              if (addedMinutes > 59) {
                                                showSnackBar('Invalid minutes, minutes must be less than 60', context);
                                              } else if (addedHours > maxAllowedCancellationTime.inHours) {
                                                showSnackBar(
                                                    'Cancellation Policy time should be max ${maxAllowedCancellationTime.inDays} days(${convertMinutesToValidationText(maxAllowedCancellationTime.inMinutes)})',
                                                    context);
                                              } else if (addedHours == maxAllowedCancellationTime.inHours && addedMinutes > 0) {
                                                showSnackBar(
                                                    'Cancellation Policy time should be max ${maxAllowedCancellationTime.inDays} days(${convertMinutesToValidationText(maxAllowedCancellationTime.inMinutes)})',
                                                    context);
                                              } else {
                                                callUpdateApi(context);
                                              }
                                            } else {
                                              callUpdateApi(context);
                                            }
                                          } else {
                                            callUpdateApi(context);
                                          }
                                        }
                                        // callUpdateApi(context);
                                      },
                                      child: Image.asset(
                                        "assets/images/ic_save.png",
                                        fit: BoxFit.scaleDown,
                                        height: 22,
                                        width: 22,
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
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                        height: 22,
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
                              Text(
                                'Contact Details',
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 20),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              isEditContact
                                  ? GestureDetector(
                                      onTap: () {
                                        hideKeyboard();
                                        if (formKey.currentState!.validate()) {
                                          // if (isEditCancellationPolicy) {
                                          if (postalController.text.toString().trim().isEmpty ||
                                              (postalController.text.toString().trim().isNotEmpty && postalController.text.toString().trim().length < 6)) {
                                            showSnackBar('6 digit postal code is required', context);
                                          } else if (icNumberController.text.toString().trim().length < 4) {
                                            showSnackBarColor('4 digit IC Number is required', context, true);
                                          } else if (effectiveDateController.text.trim().isNotEmpty && isEditCancellationPolicy) {
                                            hideKeyboard();

                                            int addedHours = int.parse(cancellationHoursController.text.isEmpty ? "0" : cancellationHoursController.text);
                                            int addedMinutes = int.parse(cancellationMinutesController.text.isEmpty ? "0" : cancellationMinutesController.text);

                                            if (effectiveDateController.text.trim().isEmpty) {
                                              showSnackBar('Please select effective date', context);
                                            } else if (addedMinutes > 59) {
                                              showSnackBar('Invalid minutes, minutes must be less than 60', context);
                                            } else if (maxAllowedCancellationTime.inMinutes > 0) {
                                              if (addedMinutes > 59) {
                                                showSnackBar('Invalid minutes, minutes must be less than 60', context);
                                              } else if (addedHours > maxAllowedCancellationTime.inHours) {
                                                showSnackBar(
                                                    'Cancellation Policy time should be max ${maxAllowedCancellationTime.inDays} days(${convertMinutesToValidationText(maxAllowedCancellationTime.inMinutes)})',
                                                    context);
                                              } else if (addedHours == maxAllowedCancellationTime.inHours && addedMinutes > 0) {
                                                showSnackBar(
                                                    'Cancellation Policy time should be max ${maxAllowedCancellationTime.inDays} days(${convertMinutesToValidationText(maxAllowedCancellationTime.inMinutes)})',
                                                    context);
                                              } else {
                                                callUpdateApi(context);
                                              }
                                            } else {
                                              callUpdateApi(context);
                                            }
                                          } else {
                                            callUpdateApi(context);
                                          }
                                          // callUpdateApi(context);
                                        }
                                      },
                                      child: Image.asset(
                                        "assets/images/ic_save.png",
                                        fit: BoxFit.scaleDown,
                                        height: 22,
                                        width: 22,
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
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                        height: 22,
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
                            controller: nameController,
                            autofocus: false,
                            enabled: isEditContact,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            maxLines: 1,
                            validator: Validator.notEmpty,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16, color: Theme.of(context).colorScheme.primary),
                            decoration: _inputDecoration(context),
                          ),
                          const SizedBox(height: 6),
                          CustomTextView(
                              label: "Last Name",
                              type: styleSubTitle,
                              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: ColorsUtils.subTitle, fontSize: 14)),
                          const SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            controller: lastNameController,
                            autofocus: false,
                            enabled: isEditContact,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            validator: Validator.notEmpty,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16, color: Theme.of(context).colorScheme.primary),
                            decoration: _inputDecoration(context),
                          ),
                          //email
                          const SizedBox(
                            height: 16,
                          ),
                          CustomTextView(
                              label: "Email",
                              type: styleSubTitle,
                              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: ColorsUtils.subTitle.withOpacity(0.5), fontSize: 14)),
                          const SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            controller: emailIdController,
                            autofocus: false,
                            enabled: false,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            // validator: Validator.validateEmail,
                            maxLines: 1,
                            style:
                                Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                            decoration: _inputDecoration(context),
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
                            controller: phoneNumberController,
                            autofocus: false,
                            enabled: false,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            maxLines: 1,
                            maxLength: mobileNoLength,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                ),
                            decoration: _inputDecoration(context, counterText: ''),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          CustomTextView(
                              label: "Address",
                              type: styleSubTitle,
                              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: ColorsUtils.subTitle, fontSize: 14)),
                          const SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            enabled: isEditContact,
                            controller: addressController,
                            autofocus: false,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.done,
                            minLines: 3,
                            validator: Validator.notEmpty,
                            maxLines: 3,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16, color: Theme.of(context).colorScheme.primary),
                            decoration: _inputDecoration(context, counterText: ''),
                          ),
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
                            decoration: _inputDecoration(context, counterText: ''),
                          ),
                          const SizedBox(
                            height: 26,
                          ),

                          // ------ work detail section -----------
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Work Details',
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 20),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              isEditWork
                                  ? GestureDetector(
                                      onTap: () {
                                        hideKeyboard();
                                        if (formKey.currentState!.validate()) {
                                          if (postalController.text.toString().trim().isEmpty ||
                                              (postalController.text.toString().trim().isNotEmpty && postalController.text.toString().trim().length < 6)) {
                                            showSnackBar('6 digit postal code is required', context);
                                          } else if (icNumberController.text.toString().trim().length < 4) {
                                            showSnackBarColor('4 digit IC Number is required', context, true);
                                          } else if (effectiveDateController.text.trim().isNotEmpty && isEditCancellationPolicy) {
                                            // if (isEditCancellationPolicy) {
                                            hideKeyboard();

                                            int addedHours = int.parse(cancellationHoursController.text.isEmpty ? "0" : cancellationHoursController.text);
                                            int addedMinutes = int.parse(cancellationMinutesController.text.isEmpty ? "0" : cancellationMinutesController.text);

                                            if (effectiveDateController.text.trim().isEmpty) {
                                              showSnackBar('Please select effective date', context);
                                            } else if (addedMinutes > 59) {
                                              showSnackBar('Invalid minutes, minutes must be less than 60', context);
                                            } else if (maxAllowedCancellationTime.inMinutes > 0) {
                                              if (addedMinutes > 59) {
                                                showSnackBar('Invalid minutes, minutes must be less than 60', context);
                                              } else if (addedHours > maxAllowedCancellationTime.inHours) {
                                                showSnackBar(
                                                    'Cancellation Policy time should be max ${maxAllowedCancellationTime.inDays} days(${convertMinutesToValidationText(maxAllowedCancellationTime.inMinutes)})',
                                                    context);
                                              } else if (addedHours == maxAllowedCancellationTime.inHours && addedMinutes > 0) {
                                                showSnackBar(
                                                    'Cancellation Policy time should be max ${maxAllowedCancellationTime.inDays} days(${convertMinutesToValidationText(maxAllowedCancellationTime.inMinutes)})',
                                                    context);
                                              } else {
                                                callUpdateApi(context);
                                              }
                                            } else {
                                              callUpdateApi(context);
                                            }
                                          } else {
                                            callUpdateApi(context);
                                          }
                                        }
                                        // callUpdateApi(context);
                                      },
                                      child: Image.asset(
                                        "assets/images/ic_save.png",
                                        fit: BoxFit.scaleDown,
                                        height: 22,
                                        width: 22,
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
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                        height: 22,
                                      ),
                                    ),
                            ],
                          ),

                          // ic no
                          const SizedBox(
                            height: 8,
                          ),
                          CustomTextView(
                              label: "IC Number (Last 4 Digits)",
                              type: styleSubTitle,
                              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: ColorsUtils.subTitle, fontSize: 14)),
                          const SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            controller: icNumberController,
                            autofocus: false,
                            enabled: isEditWork,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            maxLines: 1,
                            maxLength: 4,
                            validator: Validator.notEmpty,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]+')),
                            ],
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16, color: Theme.of(context).colorScheme.primary),
                            decoration: _inputDecoration(context,
                                errorStyle:
                                    const TextStyle(color: ColorsUtils.redColor)),
                          ),

                          // coach id
                          const SizedBox(
                            height: 16,
                          ),
                          CustomTextView(
                              label: "Coach Registry Number",
                              type: styleSubTitle,
                              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: ColorsUtils.subTitle, fontSize: 14)),
                          const SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            controller: coachRegistryIdController,
                            autofocus: false,
                            // validator: Validator.notEmpty,
                            enabled: isEditWork,
                            maxLength: 30,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]+')),
                            ],
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16, color: Theme.of(context).colorScheme.primary),
                            decoration: _inputDecoration(context,
                                errorStyle:
                                    const TextStyle(color: ColorsUtils.redColor)),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          CustomTextView(
                              label: "UEN Number",
                              type: styleSubTitle,
                              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: ColorsUtils.subTitle, fontSize: 14)),
                          const SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            controller: uenNumberController,
                            autofocus: false,
                            enabled: isEditWork,
                            maxLength: 12,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]+')),
                            ],
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16, color: Theme.of(context).colorScheme.primary),
                            decoration: _inputDecoration(context,
                                errorStyle:
                                    const TextStyle(color: ColorsUtils.redColor)),
                          ),
                          //experience
                          const SizedBox(
                            height: 16,
                          ),
                          CustomTextView(
                              label: "Experience (year(s))",
                              type: styleSubTitle,
                              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: ColorsUtils.subTitle, fontSize: 14)),
                          const SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            controller: coachExperienceController,
                            autofocus: false,
                            enabled: isEditWork,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            maxLines: 1,
                            validator: Validator.notEmpty,
                            maxLength: 2,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16, color: Theme.of(context).colorScheme.primary),
                            decoration: _inputDecoration(context,
                                counterText: '',
                                errorStyle:
                                    const TextStyle(color: ColorsUtils.redColor)),
                          ),
                          //description.
                          const SizedBox(
                            height: 16,
                          ),
                          CustomTextView(
                              label: "Description",
                              type: styleSubTitle,
                              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: ColorsUtils.subTitle, fontSize: 14)),
                          const SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            controller: descriptionController,
                            autofocus: false,
                            enabled: isEditWork,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.done,
                            maxLines: 3,
                            // validator: Validator.notEmpty,
                            maxLength: 250,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16, color: Theme.of(context).colorScheme.primary),
                            decoration: _inputDecoration(context, counterText: ''),
                          ),

                          //certificate.
                          const SizedBox(
                            height: 16,
                          ),
                          CustomTextView(
                            label: 'Certification Photo(s)',
                            textStyle: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                    fontSize: 17.0,
                                    color: ColorsUtils.greyText,
                                    fontWeight: FontWeight.w400),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (isEditWork) {
                                    // if (certificateList.length >= 10) {
                                    //   showSnackBar('Maximum 10 certificates allowed', context);
                                    // } else {
                                    bottomSheetImage(true);
                                    // }
                                  }
                                },
                                child: const CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: AssetImage("assets/images/camera.png"),
                                ),
                              ),
                              const SizedBox(
                                width: 10.0,
                              ),
                              certificateList.isNotEmpty
                                  ? Expanded(
                                      child: GridView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            childAspectRatio: 1,
                                            crossAxisSpacing: 0,
                                            mainAxisSpacing: 0,
                                          ),
                                          itemCount: certificateList.length,
                                          itemBuilder: (context, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ViewImageScreen(
                                                      url: certificateList[index],
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Row(
                                                children: [
                                                  isEditWork
                                                      ? IconButton(
                                                          icon: const Icon(Icons.close),
                                                          onPressed: () {
                                                            certificateList.removeAt(index);
                                                            certificateUploadId!.removeAt(index);
                                                            profilepic = null;
                                                            setState(() {});
                                                          },
                                                        )
                                                      : const SizedBox(),
                                                  Expanded(
                                                    child: Image.network(
                                                      certificateList[index],
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
                                                            child: Icon(Icons.image_not_supported_outlined, size: 70),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                          // CustomTextView(
                          //     label: "Certificate",
                          //     type: styleSubTitle,
                          //     textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: ColorsUtils.subTitle, fontSize: 14)),
                          // const SizedBox(
                          //   height: 8,
                          // ),
                          // TextFormField(
                          //   keyboardType: TextInputType.text,
                          //   textInputAction: TextInputAction.done,
                          //   maxLines: 1,
                          //   enabled: isEditWork,
                          //   style:
                          //       Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16, color: Theme.of(context).colorScheme.primary),
                          //   decoration: const InputDecoration(
                          //     isDense: true,
                          //     counterText: '',
                          //     contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                          //     border: UnderlineInputBorder(),
                          //   ),
                          // ),
                          const SizedBox(
                            height: 16,
                          ),

                          //activity
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Activities',
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  if (isEditWork) {
                                    for (var activity in activityListModel) {
                                      for (var subActivity in activity.SubActivities!) {
                                        subActivity.selectedValue = false;
                                      }
                                    }
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
                                      activityListModel[i].isSelected = false;
                                      // activityListModel[i].SubActivities?.forEach((element) {
                                      //   element.isSelected = false;
                                      //   element.selectedValue = false;
                                      // });
                                      interestValue[activityListModel[i].Name!] = activityListModel[i].SubActivities!;
                                    }
                                    //commonPassingArgs.endUserActivitySelection = interestValue;
                                    var data = await Navigator.pushNamed(context, Constants.coachActivityInterestFilterScreen, arguments: interestValue);
                                    debugPrint(data.toString());
                                    if (data != null && data != {} && data is Map) {
                                      setState(() {
                                        selectedFilterData = data as Map<String, List<SelectedFilterValues>>?;
                                        isActivityChanges = true;
                                        debugPrint(selectedFilterData.toString());
                                      });
                                    }
                                  }
                                },
                                child: isEditWork
                                    ? Image.asset(
                                        "assets/images/ic_add.png",
                                        fit: BoxFit.fitWidth,
                                        height: 40,
                                        width: 40,
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
                                                      .copyWith(
                                                          color: ColorsUtils.chipText,
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 18.0),
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
                              : selectedFilterData != null || selectedFilterData!.isNotEmpty
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
                                          .copyWith(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w400,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground),
                                    ),
                          const SizedBox(
                            height: 26,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Training Address',
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 20),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  if (isEditWork) {
                                    Navigator.of(context).pushNamed(Constants.addTrainingAddress).then((value) {
                                      debugPrint(value.toString());
                                      if (value != null) {
                                        setState(() {
                                          // CoachTrainingAddressDtos model = value as CoachTrainingAddressDtos;
                                          getCoachTrainingCenterAddress();
                                        });
                                      }
                                    });
                                  }
                                },
                                child: isEditWork
                                    ? Image.asset(
                                        "assets/images/ic_add.png",
                                        fit: BoxFit.fitWidth,
                                        height: 40,
                                        width: 40,
                                      )
                                    : const SizedBox(),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: coachTrainingAddressList?.length ?? 0,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Visibility(
                                      visible: isEditWork,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: GestureDetector(
                                          onTap: () async {
                                            if (isEditWork) {
                                              Navigator.of(context)
                                                  .pushNamed(Constants.addTrainingAddress, arguments: coachTrainingAddressList?[index])
                                                  .then((value) {
                                                debugPrint(value.toString());
                                                if (value != null) {
                                                  setState(() {
                                                    // CoachTrainingAddressDtos model = value as CoachTrainingAddressDtos;
                                                    getCoachTrainingCenterAddress();
                                                  });
                                                }
                                              });
                                            }
                                          },
                                          child: Image.asset(
                                            "assets/images/ic_edit.png",
                                            fit: BoxFit.fitWidth,
                                            color: Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : Colors.black,
                                            height: 30,
        width: 30,
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
                                            label: coachTrainingAddressList![index].addressName,
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
                                                "${coachTrainingAddressList![index].address1 ?? ""} ${coachTrainingAddressList![index].address2 ?? ""} ${coachTrainingAddressList![index].pinCode ?? ""} ${coachTrainingAddressList![index].cityName ?? ""}",
                                            textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14.0, color: ColorsUtils.subTitle),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Visibility(
                                    //   visible: isEditWork,
                                    //   child: Center(
                                    //     child: GestureDetector(
                                    //       child: Image.asset(
                                    //         'assets/images/ic_profile_delete.png',
                                    //         fit: BoxFit.fill,
                                    //         height: 25,
                                    //         width: 25,
                                    //       ),
                                    //       onTap: () {
                                    //         if (isEditWork) {
                                    //           showDeleteAlertDialog(coachTrainingAddressList![index]);
                                    //         }
                                    //       },
                                    //     ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const Divider();
                            },
                          ),
                          const Divider(),
                          const SizedBox(
                            height: 16,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Cancellation Policy',
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 20),
                              ),
                              isEditCancellationPolicy
                                  ? GestureDetector(
                                      onTap: () {
                                        hideKeyboard();

                                        int addedHours = int.parse(cancellationHoursController.text.isEmpty ? "0" : cancellationHoursController.text);
                                        int addedMinutes = int.parse(cancellationMinutesController.text.isEmpty ? "0" : cancellationMinutesController.text);
                                        if (postalController.text.toString().trim().isEmpty ||
                                            (postalController.text.toString().trim().isNotEmpty && postalController.text.toString().trim().length < 6)) {
                                          showSnackBar('6 digit postal code is required', context);
                                        } else if (icNumberController.text.toString().trim().length < 4) {
                                          showSnackBarColor('4 digit IC Number is required', context, true);
                                        } else if (effectiveDateController.text.trim().isEmpty) {
                                          showSnackBar('Please select effective date', context);
                                        } else if (addedMinutes > 59) {
                                          showSnackBar('Invalid minutes, minutes must be less than 60', context);
                                        } else if (maxAllowedCancellationTime.inMinutes > 0) {
                                          if (addedMinutes > 59) {
                                            showSnackBar('Invalid minutes, minutes must be less than 60', context);
                                          } else if (addedHours > maxAllowedCancellationTime.inHours) {
                                            showSnackBar(
                                                'Cancellation Policy time should be max ${maxAllowedCancellationTime.inDays} days(${convertMinutesToValidationText(maxAllowedCancellationTime.inMinutes)})',
                                                context);
                                          } else if (addedHours == maxAllowedCancellationTime.inHours && addedMinutes > 0) {
                                            showSnackBar(
                                                'Cancellation Policy time should be max ${maxAllowedCancellationTime.inDays} days(${convertMinutesToValidationText(maxAllowedCancellationTime.inMinutes)})',
                                                context);
                                          } else {
                                            callUpdateApi(context);
                                          }
                                        } else {
                                          callUpdateApi(context);
                                        }
                                      },
                                      child: Image.asset(
                                        "assets/images/ic_save.png",
                                        fit: BoxFit.scaleDown,
                                        height: 22,
                                        width: 22,
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isEditCancellationPolicy = true;
                                        });
                                      },
                                      child: Image.asset(
                                        "assets/images/ic_edit.png",
                                        fit: BoxFit.scaleDown,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                        height: 22,
                                      ),
                                    ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextView(
                                label: 'Refundable if cancelled before click here to read more. ',
                                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14.0, color: ColorsUtils.subTitle),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              CustomTextView(
                                label:
                                    'Cancellation Policy time should be max ${maxAllowedCancellationTime.inDays} days\n(${convertMinutesToValidationText(maxAllowedCancellationTime.inMinutes)})',
                                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14.0, color: ColorsUtils.subTitle),
                                maxLine: 2,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 6,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Column(
                                              children: [
                                                // Container(
                                                //   decoration: BoxDecoration(
                                                //     color: ColorsUtils.edittextBackProfile,
                                                //   ),
                                                //   height: 35,
                                                //   width: 35,
                                                //   child: Center(
                                                //     child: Text(
                                                //       selectedHour,
                                                //       style: TextStyle(fontSize: 14, color: ColorsUtils.subTitle),
                                                //     ),
                                                //   ),
                                                // ),
                                                SizedBox(
                                                  height: 48,
                                                  width: 60,
                                                  child: CustomTextFormField(
                                                    controller: cancellationHoursController,
                                                    hintText: '00',
                                                    fillColor: ColorsUtils.edittextBackProfile,
                                                    fontSize: 14,
                                                    centerText: true,
                                                    keyboardType: TextInputType.number,
                                                    inputformat: [FilteringTextInputFormatter.digitsOnly],
                                                    read: !isEditCancellationPolicy,
                                                    obscureText: false,
                                                    labelText: '',
                                                    borderColor: Colors.transparent,
                                                    borderRadius: 0,
                                                    maxlength: 3,
                                                    maxlines: 1,
                                                  ),
                                                ),
                                                CustomTextView(
                                                  label: 'hours',
                                                  textAlign: TextAlign.center,
                                                  textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 12.0, color: ColorsUtils.subTitle),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 15,
                                            ),
                                            Column(
                                              children: [
                                                // Container(
                                                //   decoration: BoxDecoration(
                                                //     color: ColorsUtils.edittextBackProfile,
                                                //   ),
                                                //   width: 35,
                                                //   height: 35,
                                                //   child: Center(
                                                //     child: Text(
                                                //       selectedMinute,
                                                //       style: TextStyle(fontSize: 14, color: ColorsUtils.subTitle),
                                                //     ),
                                                //   ),
                                                // ),
                                                SizedBox(
                                                  height: 48,
                                                  width: 60,
                                                  child: CustomTextFormField(
                                                    controller: cancellationMinutesController,
                                                    fillColor: ColorsUtils.edittextBackProfile,
                                                    hintText: '00',
                                                    fontSize: 14,
                                                    centerText: true,
                                                    keyboardType: TextInputType.number,
                                                    inputformat: [FilteringTextInputFormatter.digitsOnly],
                                                    read: !isEditCancellationPolicy,
                                                    obscureText: false,
                                                    labelText: '',
                                                    borderColor: Colors.transparent,
                                                    borderRadius: 0,
                                                    maxlength: 2,
                                                    maxlines: 1,
                                                  ),
                                                ),
                                                CustomTextView(
                                                  label: 'minutes',
                                                  textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 12.0, color: ColorsUtils.subTitle),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                if (isEditCancellationPolicy) {
                                                  var time = await showDurationPicker(
                                                    context: context,
                                                    initialTime: Duration(
                                                        hours: int.parse(cancellationHoursController.text.isEmpty ? "0" : cancellationHoursController.text),
                                                        minutes:
                                                            int.parse(cancellationMinutesController.text.isEmpty ? "60" : cancellationMinutesController.text)),
                                                  );
                                                  if (time != null) {
                                                    if (time.inMinutes > maxAllowedCancellationTime.inMinutes) {
                                                      showSnackBar(
                                                          'Cancellation Policy time should be max ${maxAllowedCancellationTime.inDays} days(${convertMinutesToValidationText(maxAllowedCancellationTime.inMinutes)})',
                                                          context);
                                                    } else {
                                                      _slotTimeInMins = time.inMinutes;
                                                      String finalTime = formatDuration(time);
                                                      debugPrint(finalTime);
                                                      String hrs = finalTime.split(":")[0];
                                                      String mins = finalTime.split(":")[1];

                                                      setState(() {
                                                        cancellationHoursController.text = hrs;
                                                        cancellationMinutesController.text = mins;
                                                      });
                                                    }
                                                  }
                                                }
                                              },
                                              child: SizedBox(
                                                width: 30,
                                                height: 30,
                                                child: Image.asset(
                                                  "assets/images/pick_time.png",
                                                  fit: BoxFit.fitWidth,
                                                  height: 30,
                                                  width: 30,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 8,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                                          child: GestureDetector(
                                            onTap: () {
                                              if (isEditCancellationPolicy) {
                                                _selectDate(context);
                                              }
                                            },
                                            child: CustomTextFormField(
                                              controller: effectiveDateController,
                                              read: true,
                                              obscureText: false,
                                              labelText: 'Effective Date',
                                              maxlines: 1,
                                              suffixIcon: IconButton(
                                                onPressed: () {
                                                  if (isEditCancellationPolicy) {
                                                    _selectDate(context);
                                                  }
                                                },
                                                icon: Image.asset('assets/images/ic_calendar_image.png'),
                                                iconSize: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // const SizedBox(
                                  //   height: 10,
                                  // ),
                                  // isEditCancellationPolicy
                                  //     ? CustomTextView(
                                  //         label: 'Current Effective Date: ${currentEffectiveDate.isEmpty ? 'N/A' : currentEffectiveDate}',
                                  //         textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                                  //       )
                                  //     : const SizedBox(),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomTextView(
                            label: 'Current Effective Date: ${currentEffectiveDate.isEmpty ? 'N/A' : currentEffectiveDate}',
                            textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onBackground),
                          ),
                          const SizedBox(
                            height: 26,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payout Method',
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 20),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              isEditPayoutMethod
                                  ? GestureDetector(
                                      onTap: () {
                                        hideKeyboard();
                                        if (formKey.currentState!.validate()) {
                                          hideKeyboard();
                                          if (postalController.text.toString().trim().isEmpty ||
                                              (postalController.text.toString().trim().isNotEmpty && postalController.text.toString().trim().length < 6)) {
                                            showSnackBar('6 digit postal code is required', context);
                                          } else if (icNumberController.text.toString().trim().length < 4) {
                                            showSnackBarColor('4 digit IC Number is required', context, true);
                                          } else if (selectedPayoutMethod == null) {
                                            showSnackBar('Please select payout method', context);
                                          } else if (payoutDetailsKey.currentState!.validate()) {
                                            // if (isEditCancellationPolicy) {
                                            if (effectiveDateController.text.trim().isNotEmpty && isEditCancellationPolicy) {
                                              hideKeyboard();

                                              int addedHours = int.parse(cancellationHoursController.text.isEmpty ? "0" : cancellationHoursController.text);
                                              int addedMinutes =
                                                  int.parse(cancellationMinutesController.text.isEmpty ? "0" : cancellationMinutesController.text);

                                              if (effectiveDateController.text.trim().isEmpty) {
                                                showSnackBar('Please select effective date', context);
                                              } else if (addedMinutes > 59) {
                                                showSnackBar('Invalid minutes, minutes must be less than 60', context);
                                              } else if (maxAllowedCancellationTime.inMinutes > 0) {
                                                if (addedMinutes > 59) {
                                                  showSnackBar('Invalid minutes, minutes must be less than 60', context);
                                                } else if (addedHours > maxAllowedCancellationTime.inHours) {
                                                  showSnackBar(
                                                      'Cancellation Policy time should be max ${maxAllowedCancellationTime.inDays} days(${convertMinutesToValidationText(maxAllowedCancellationTime.inMinutes)})',
                                                      context);
                                                } else if (addedHours == maxAllowedCancellationTime.inHours && addedMinutes > 0) {
                                                  showSnackBar(
                                                      'Cancellation Policy time should be max ${maxAllowedCancellationTime.inDays} days(${convertMinutesToValidationText(maxAllowedCancellationTime.inMinutes)})',
                                                      context);
                                                } else {
                                                  callUpdateApi(context);
                                                }
                                              } else {
                                                callUpdateApi(context);
                                              }
                                            } else {
                                              callUpdateApi(context);
                                            }

                                            // callUpdateApi(context);
                                          }
                                        }
                                      },
                                      child: Image.asset(
                                        "assets/images/ic_save.png",
                                        fit: BoxFit.scaleDown,
                                        height: 22,
                                        width: 22,
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isEditPayoutMethod = true;
                                        });
                                      },
                                      child: Image.asset(
                                        "assets/images/ic_edit.png",
                                        fit: BoxFit.scaleDown,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                        height: 22,
                                      ),
                                    ),
                            ],
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          // payout dropdown
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
                              borderRadius: BorderRadius.circular(15),
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              child: DropdownButton<dynamic>(
                                isExpanded: true,
                                icon: Icon(Icons.keyboard_arrow_down_rounded,
                                    color: Theme.of(context).colorScheme.primary),
                                dropdownColor: Theme.of(context).colorScheme.onBackground,
                                underline: const SizedBox(),
                                borderRadius: BorderRadius.circular(15),
                                hint: CustomTextView(
                                  label: selectedPayoutMethod?.displayText ?? "Select Payout Method",
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w400,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                ),
                                value: selectedPayoutMethod,
                                items: payoutMethods.map((method) {
                                  return DropdownMenuItem(
                                    value: method,
                                    child: CustomTextView(
                                      label: method.displayText,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w400,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                    ),
                                  );
                                }).toList(),
                                onChanged: isEditPayoutMethod
                                    ? (value) {
                                        debugPrint('Selected payout method : - $value');
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          if (value != selectedPayoutMethod) {
                                            payNowIdController.clear();
                                            payNowMobileNumberController.clear();
                                            payLahMobileNumberController.clear();
                                            bankAccountNumberController.clear();
                                            ifscCodeController.clear();
                                            beneficiaryNameController.clear();
                                            bankNameController.clear();
                                            setState(() {
                                              selectedPayoutMethod = value;
                                            });
                                          }
                                          // checkForSelectedCity();
                                        });
                                      }
                                    : null,
                              ),
                            ),
                          ),
                          Form(
                            key: payoutDetailsKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Visibility(
                                  visible: selectedPayoutMethod == PayoutMethodTypeEnum.payNow,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      CustomTextView(
                                          label: "Mobile number {Linked to PayNow}",
                                          type: styleSubTitle,
                                          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: ColorsUtils.subTitle, fontSize: 14)),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      TextFormField(
                                        enabled: isEditPayoutMethod,
                                        autofocus: false,
                                        controller: payNowMobileNumberController,
                                        keyboardType: TextInputType.phone,
                                        textInputAction: TextInputAction.done,
                                        minLines: 1,
                                        maxLines: 1,
                                        maxLength: mobileNoLength ?? 12,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                          FilteringTextInputFormatter.digitsOnly,
                                        ],
                                        validator: (value) {
                                          if (value?.isEmpty ?? false) {
                                            return "Please enter mobile number";
                                          } else if (value!.trim().length < mobileNoLength!) {
                                            return "Please enter valid mobile number";
                                          }
                                          return null;
                                        },
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16, color: Theme.of(context).colorScheme.primary),
                                        decoration: _inputDecoration(context,
                                            counterText: '',
                                            errorStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    fontSize: 12,
                                                    color: ColorsUtils.redColor)),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      CustomTextView(
                                          label: "PayNow ID (UEN Number)",
                                          type: styleSubTitle,
                                          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: ColorsUtils.subTitle, fontSize: 14)),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      TextFormField(
                                        enabled: isEditPayoutMethod,
                                        autofocus: false,
                                        controller: payNowIdController,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.done,
                                        minLines: 1,
                                        maxLines: 1,
                                        maxLength: 10,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]+')),
                                        ],
                                        validator: (value) {
                                          if (value?.isEmpty ?? false) {
                                            return "Please enter PayNow ID (UEN Number)";
                                          } else if (value!.length < 5) {
                                            return "Please enter valid PayNow ID (UEN Number)";
                                          }
                                          return null;
                                        },
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16, color: Theme.of(context).colorScheme.primary),
                                        decoration: _inputDecoration(context,
                                            counterText: '',
                                            errorStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    fontSize: 12,
                                                    color: ColorsUtils.redColor)),
                                      ),
                                    ],
                                  ),
                                ),
                                // pay lah fields
                                Visibility(
                                  visible: selectedPayoutMethod == PayoutMethodTypeEnum.payLah,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      CustomTextView(
                                          label: "Mobile number {Linked to PayLah}",
                                          type: styleSubTitle,
                                          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: ColorsUtils.subTitle, fontSize: 14)),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      TextFormField(
                                        enabled: isEditPayoutMethod,
                                        autofocus: false,
                                        controller: payLahMobileNumberController,
                                        keyboardType: TextInputType.phone,
                                        textInputAction: TextInputAction.done,
                                        minLines: 1,
                                        maxLines: 1,
                                        maxLength: mobileNoLength ?? 12,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                          FilteringTextInputFormatter.digitsOnly,
                                        ],
                                        validator: (value) {
                                          if (value?.isEmpty ?? false) {
                                            return "Please enter mobile number";
                                          } else if (value!.trim().length < mobileNoLength!) {
                                            return "Please enter valid mobile number";
                                          }
                                          return null;
                                        },
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16, color: Theme.of(context).colorScheme.primary),
                                        decoration: _inputDecoration(context,
                                            counterText: '',
                                            errorStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    fontSize: 12,
                                                    color: ColorsUtils.redColor)),
                                      ),
                                    ],
                                  ),
                                ),
                                // bank details fields
                                Visibility(
                                  visible: selectedPayoutMethod == PayoutMethodTypeEnum.bankDetails,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      CustomTextView(
                                          label: "Beneficiary name",
                                          type: styleSubTitle,
                                          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: ColorsUtils.subTitle, fontSize: 14)),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      TextFormField(
                                        enabled: isEditPayoutMethod,
                                        autofocus: false,
                                        controller: beneficiaryNameController,
                                        keyboardType: TextInputType.name,
                                        textInputAction: TextInputAction.done,
                                        minLines: 1,
                                        maxLines: 1,
                                        maxLength: 50,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9 ]+')),
                                        ],
                                        validator: (value) {
                                          if (value?.isEmpty ?? false) {
                                            return "Please enter beneficiary name";
                                          }
                                          return null;
                                        },
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16, color: Theme.of(context).colorScheme.primary),
                                        decoration: _inputDecoration(context,
                                            counterText: '',
        errorStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    fontSize: 12,
                                                    color: ColorsUtils.redColor)),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      CustomTextView(
                                          label: "Bank name",
                                          type: styleSubTitle,
                                          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: ColorsUtils.subTitle, fontSize: 14)),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      TextFormField(
                                        enabled: isEditPayoutMethod,
                                        autofocus: false,
                                        controller: bankNameController,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.done,
                                        minLines: 1,
                                        maxLines: 1,
                                        maxLength: 50,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z ]+')),
                                        ],
                                        validator: (value) {
                                          if (value?.isEmpty ?? false) {
                                            return "Please enter bank name";
                                          }
                                          return null;
                                        },
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16, color: Theme.of(context).colorScheme.primary),
                                        decoration: _inputDecoration(context,
                                            counterText: '',
                                            errorStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    fontSize: 12,
                                                    color: ColorsUtils.redColor)),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      CustomTextView(
                                          label: "Bank account number",
                                          type: styleSubTitle,
                                          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: ColorsUtils.subTitle, fontSize: 14)),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      TextFormField(
                                        enabled: isEditPayoutMethod,
                                        autofocus: false,
                                        controller: bankAccountNumberController,
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.done,
                                        minLines: 1,
                                        maxLines: 1,
                                        maxLength: 20,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                          FilteringTextInputFormatter.digitsOnly,
                                        ],
                                        validator: (value) {
                                          if (value?.isEmpty ?? false) {
                                            return "Please enter bank account number";
                                          } else if (value!.length < 5) {
                                            return "Please enter valid bank account number";
                                          }
                                          return null;
                                        },
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16, color: Theme.of(context).colorScheme.primary),
                                        decoration: _inputDecoration(context,
                                            counterText: '',
                                            errorStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    fontSize: 12,
                                                    color: ColorsUtils.redColor)),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      CustomTextView(
                                          label: "IFSC/Swift code",
                                          type: styleSubTitle,
                                          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: ColorsUtils.subTitle, fontSize: 14)),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      TextFormField(
                                        enabled: isEditPayoutMethod,
                                        autofocus: false,
                                        controller: ifscCodeController,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.done,
                                        minLines: 1,
                                        maxLines: 1,
                                        maxLength: 20,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]+')),
                                        ],
                                        validator: (value) {
                                          if (value?.isEmpty ?? false) {
                                            return "Please enter IFSC/Swift code";
                                          } else if (value!.length < 5) {
                                            return "Please enter valid IFSC/Swift code";
                                          }
                                          return null;
                                        },
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16, color: Theme.of(context).colorScheme.primary),
                                        decoration: _inputDecoration(context,
                                            counterText: '',
                                            errorStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    fontSize: 12,
                                                    color: ColorsUtils.redColor)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                            height: 15,
                          ),

                          InkWell(
                            onTap: () {
                              if (coachProfileResponseModel.referrerCode != OQDOApplication.instance.configResponseModel!.defaultRefCode) {
                                ReferEarnIntent intent =
                                    ReferEarnIntent(referCode: coachProfileResponseModel.referrerCode, userType: OQDOApplication.instance.userType);
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
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          "Close Account",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ColorsUtils.white,
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
                                    style: TextStyle(
                                        color: ColorsUtils.redColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ),
                          const SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        : Container();
  }

  openCloseAccountDialog() async {
    showDialog(
      context: context,
      barrierDismissible: true,
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

  bottomSheetImage(bool forCertificate) async {
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
                        if (forCertificate) {
                          getMultiplePicFromGallery();
                        } else {
                          getPicFromGallery(forCertificate);
                        }
                      } else {
                        var status = await Permission.storage.request();
                        if (status == PermissionStatus.granted) {
                          if (forCertificate) {
                            getMultiplePicFromGallery();
                          } else {
                            getPicFromGallery(forCertificate);
                          }
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
                        getPicFromCam(forCertificate);
                      } else if (status == PermissionStatus.denied) {
                        if (status == PermissionStatus.granted) {
                          getPicFromCam(forCertificate);
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

  Future getPicFromCam(bool forCertificate) async {
    Navigator.pop(context);
    await _progressDialog.show();
    setState(() {});
    var pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 60);

    if (pickedFile != null) {
      if (forCertificate) {
        var finalSize = certificateList.length + 1;
        if (finalSize > 4) {
          await _progressDialog.hide();
          setState(() {});
          showSnackBar('Maximum 4 images allowed', context);
        } else {
          var byte = await File(pickedFile.path).length();
          var kb = byte / 1024;
          var mb = kb / 1024;
          debugPrint("File size -> ${mb.toString()}");
          if (mb < 10.0) {
            await _progressDialog.hide();
            profileImageFile = File(pickedFile.path);
            setState(() {});
            var bytes = File(profileImageFile!.path).readAsBytesSync();
            String convertedBytes = base64Encode(bytes);
            uploadFile(convertedBytes, forCertificate);
          } else {
            await _progressDialog.hide();
            setState(() {});
            showSnackBarErrorColor("Please select image below 10 MB", context, true);
          }
        }
      } else {
        _cropImage(pickedFile, forCertificate);
        // final byte = await File(pickedFile.path).length();
        // final kb = byte / 1024;
        // final mb = kb / 1024;
        // debugPrint("File size -> ${mb.toString()}");
        // if (mb < 10.0) {
        //   await _progressDialog.hide();
        //   profileImageFile = File(pickedFile.path);
        //   setState(() {});
        //   final bytes = File(profileImageFile!.path).readAsBytesSync();
        //   String convertedBytes = base64Encode(bytes);
        //   uploadFile(convertedBytes, forCertificate);
        // } else {
        //   await _progressDialog.hide();
        //   setState(() {});
        //   showSnackBarErrorColor("Please select image below 10 MB", context, true);
        // }
      }
    } else {
      await _progressDialog.hide();
      setState(() {});
    }
  }

  Future getPicFromGallery(bool forCertificate) async {
    Navigator.pop(context);
    await _progressDialog.show();
    setState(() {});
    var pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);

    if (pickedFile != null) {
      _cropImage(pickedFile, forCertificate);
    } else {
      await _progressDialog.hide();
      setState(() {});
    }

    // if (pickedFile != null) {
    //   final byte = await File(pickedFile.path).length();
    //   final kb = byte / 1024;
    //   final mb = kb / 1024;
    //   debugPrint("File size -> ${mb.toString()}");
    //   if (mb < 10.0) {
    //     await _progressDialog.hide();
    //     profileImageFile = File(pickedFile.path);
    //     setState(() {});
    //     final bytes = File(profileImageFile!.path).readAsBytesSync();
    //     String convertedBytes = base64Encode(bytes);
    //     uploadFile(convertedBytes, forCertificate);
    //   } else {
    //     await _progressDialog.hide();
    //     setState(() {});
    //     showSnackBarErrorColor("Please select image below 10 MB", context, true);
    //   }
    // }
  }

  Future<void> _cropImage(XFile pickedFile, bool forCertificate) async {
    var mCroppedFile = await ImageCropper().cropImage(sourcePath: pickedFile.path, compressFormat: ImageCompressFormat.jpg, compressQuality: 100, uiSettings: [
      AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Theme.of(context).colorScheme.primary,
          toolbarWidgetColor: Theme.of(context).colorScheme.onPrimary,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false),
      IOSUiSettings(
        title: 'Cropper',
      ),
    ]);

    if (mCroppedFile != null) {
      // setState(() async{
      var byte = await File(mCroppedFile.path).length();
      var kb = byte / 1024;
      var mb = kb / 1024;
      debugPrint("File size -> ${mb.toString()}");
      if (mb < 10.0) {
        await _progressDialog.hide();
        croppedFile = mCroppedFile;
        setState(() {});
        var bytes = File(mCroppedFile.path).readAsBytesSync();
        String convertedBytes = base64Encode(bytes);
        uploadFile(convertedBytes, forCertificate);
      } else {
        await _progressDialog.hide();
        setState(() {});
        showSnackBarErrorColor("Please select image below 10 MB", context, true);
      }
      // });
    } else {
      await _progressDialog.hide();
      setState(() {});
    }
  }

  Future getMultiplePicFromGallery() async {
    Navigator.pop(context);
    await _progressDialog.show();
    setState(() {});
    var pickedFile = await picker.pickMultiImage(imageQuality: 60);

    if (pickedFile.isNotEmpty) {
      if (pickedFile.length > 4) {
        await _progressDialog.hide();
        setState(() {});
        showSnackBar('Maximum 4 images allowed', context);
        return;
      } else {
        var finalSize = certificateList.length + pickedFile.length;
        if (finalSize > 4) {
          await _progressDialog.hide();
          setState(() {});
          showSnackBar('Maximum 4 images allowed', context);
        } else {
          double maxMb = 0.00;
          for (int i = 0; i < pickedFile.length; i++) {
            var byte = await File(pickedFile[i].path).length();
            var kb = byte / 1024;
            var mb = kb / 1024;
            if (mb > 10.0) {
              await _progressDialog.hide();
              maxMb = 0.0;
              setState(() {});
              showSnackBarErrorColor("Please select image below 10 MB", context, true);
              return;
            } else {
              maxMb = maxMb + mb;
            }
          }
          await _progressDialog.hide();
          setState(() {});
          if (maxMb < 40) {
            uploadMultipleImgFiles(pickedFile);
          } else {
            showSnackBarErrorColor("Please select image below 40 MB", context, true);
          }
        }
      }
    } else {
      await _progressDialog.hide();
      setState(() {});
    }
  }

  Future<void> uploadFile(String base64File, bool forCertificate) async {
    await _progressDialog.show();
    Map uploadFileRequest = {};
    uploadFileRequest['FileStorageId'] = null;
    uploadFileRequest['FileName'] = forCertificate ? profileImageFile!.path.split('/').last : croppedFile!.path.split('/').last;
    uploadFileRequest['FileExtension'] =
        forCertificate ? profileImageFile!.path.split('/').last.split('.')[1] : croppedFile!.path.split('/').last.split('.')[1];
    uploadFileRequest['FilePath'] = base64File;

    try {
      await Provider.of<ProfileViewModel>(context, listen: false).uploadFile(uploadFileRequest).then(
        (value) async {
          Response res = value;
          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            await _progressDialog.hide();
            UploadFileResponse? uploadFileResponse = UploadFileResponse.fromMap(jsonDecode(res.body));
            debugPrint('Upload File Response -> ${uploadFileResponse!.FileStorageId}');
            if (forCertificate) {
              certificateUploadId!.add(uploadFileResponse.FileStorageId.toString());
              if (uploadFileResponse.FilePath != null && uploadFileResponse.FilePath!.isNotEmpty) {
                setState(() {
                  certificateList.add(uploadFileResponse.FilePath!);
                });
              } else {
                showSnackBarColor("Image not uploaded", context, true);
              }
              profileImageFile = null;
              croppedFile = null;
            } else {
              setState(() {
                uploadedImagePath = uploadFileResponse.FilePath!;
                profileImageId = uploadFileResponse.FileStorageId;
              });
              // Provider.of<ChatProvider>(context, listen: false).setProfileImagePath(uploadFileResponse.FilePath!);
            }
          } else {
            await _progressDialog.hide();
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
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      await _progressDialog.hide();
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  Future<void> uploadMultipleImgFiles(List<XFile> pickedFile) async {
    try {
      await _progressDialog.show();
      List<Map<String, dynamic>> requestList = [];

      for (int i = 0; i < pickedFile.length; i++) {
        Map<String, dynamic> uploadFileRequest = {};
        uploadFileRequest['FileStorageId'] = null;
        uploadFileRequest['FileName'] = pickedFile[i].path.split('/').last;
        uploadFileRequest['FileExtension'] = pickedFile[i].path.split('/').last.split('.')[1];
        var bytes = File(pickedFile[i].path).readAsBytesSync();
        String convertedBytes = base64Encode(bytes);
        uploadFileRequest['FilePath'] = convertedBytes;
        requestList.add(uploadFileRequest);
      }
      await Provider.of<ProfileViewModel>(context, listen: false).multipleUploadFile(requestList).then(
        (value) async {
          Response res = value;
          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            List<dynamic> bodyList = jsonDecode(res.body);
            List<UploadFileResponse?> uploadFileResponse = bodyList.map((e) => UploadFileResponse.fromMap(e)).toList();
            debugPrint('Upload File Response -> ${uploadFileResponse[0]!.FileStorageId}');

            for (var i = 0; i < uploadFileResponse.length; i++) {
              certificateUploadId!.add(uploadFileResponse[i]!.FileStorageId.toString());
              if (uploadFileResponse[i]!.FilePath != null && uploadFileResponse[i]!.FilePath!.isNotEmpty) {
                setState(() {
                  certificateList.add(uploadFileResponse[i]!.FilePath!);
                });
              } else {
                showSnackBarColor("Image not uploaded", context, true);
              }
            }
          } else {
            await _progressDialog.hide();
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
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      await _progressDialog.hide();
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  // Future<void> uploadMultipleImgFiles(List<XFile> pickedFile) async {
  //   await _progressDialog.show();
  //   for (int i = 0; i < pickedFile.length; i++) {
  //     Map uploadFileRequest = {};
  //     uploadFileRequest['FileStorageId'] = null;
  //     uploadFileRequest['FileName'] = pickedFile[i].path.split('/').last;
  //     uploadFileRequest['FileExtension'] = pickedFile[i].path.split('/').last.split('.')[1];
  //     final bytes = File(pickedFile[i].path).readAsBytesSync();
  //     String convertedBytes = base64Encode(bytes);
  //     uploadFileRequest['FilePath'] = convertedBytes;
  //     try {
  //       UploadFileResponse uploadFileResponse =
  //           await Provider.of<ProfileViewModel>(context, listen: false).uploadFile(uploadFileRequest);
  //       debugPrint('Upload File Response -> ${uploadFileResponse.FileStorageId}');
  //       certificateUploadId!.add(uploadFileResponse.FileStorageId.toString());
  //       if (uploadFileResponse.FilePath != null && uploadFileResponse.FilePath!.isNotEmpty) {
  //         setState(() {
  //           certificateList.add(uploadFileResponse.FilePath!);
  //         });
  //       } else {
  //         showSnackBarColor("Image not uploaded", context, true);
  //       }
  //     } on CommonException catch (error) {
  //       await _progressDialog.hide();
  //       if (error.code == 400) {
  //         Map<String, dynamic> errorModel = jsonDecode(error.message);
  //         if (errorModel.containsKey('ModelState')) {
  //           Map<String, dynamic> modelState = errorModel['ModelState'];
  //           if (modelState.containsKey('ErrorMessage')) {
  //             showSnackBarColor(modelState['ErrorMessage'][0], context, true);
  //           } else {
  //             showSnackBarColor(
  //                 'We\'re unable to connect to server. Please contact administrator or try after some time',
  //                 context,
  //                 true);
  //           }
  //         } else {
  //           showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time',
  //               context, true);
  //         }
  //       } else {
  //         showSnackBarColor(
  //             'We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
  //       }
  //       debugPrint(error.message);
  //     } on NoConnectivityException catch (_) {
  //       await _progressDialog.hide();
  //       showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
  //     } catch (error) {
  //       await _progressDialog.hide();
  //       showSnackBarErrorColor(
  //           'We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
  //     }
  //   }
  //   await _progressDialog.hide();
  // }

  Future<void> getAllActivity() async {
    try {
      await Provider.of<ProfileViewModel>(context, listen: false).getAllActivity().then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            GetAllActivityAndSubActivityResponse? getAllActivityAndSubActivityResponse = GetAllActivityAndSubActivityResponse.fromMap(jsonDecode(res.body));
            if (getAllActivityAndSubActivityResponse!.Data!.isNotEmpty) {
              getCoachTrainingCenterAddress();
              setState(() {
                activityListModel = getAllActivityAndSubActivityResponse.Data!;
                //setSelectedActivityData();
              });
              await _progressDialog.hide();
            } else {
              await _progressDialog.hide();
            }
          } else {
            await _progressDialog.hide();
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
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      await _progressDialog.hide();
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  void setSelectedActivityData() {
    List<ActivityBean> selectedActivityList = activityListModel.where((element) => element.ActivityId == selectedActivityId).toList();
    List<SubActivitiesBean> subActivityList = [];
    for (int i = 0; i < coachProfileResponseModel.coachSubActivityDtos!.length; i++) {
      for (int j = 0; j < selectedActivityList.length; j++) {
        if (coachProfileResponseModel.coachSubActivityDtos![i].subActivityId == selectedActivityList[j].SubActivities![j].SubActivityId) {
          SubActivitiesBean subActivitiesBean = SubActivitiesBean();
          subActivitiesBean.Name = selectedActivityList[j].SubActivities![j].Name;
          subActivitiesBean.SubActivityId = selectedActivityList[j].SubActivities![j].SubActivityId;
          subActivitiesBean.isSelected = true;
          subActivitiesBean.ActivityId = selectedActivityList[j].SubActivities![j].ActivityId;
          subActivityList.add(subActivitiesBean);
        }
      }
    }
  }

  Future<void> callUpdateApi(BuildContext context) async {
    if (postalController.text.toString().trim().isNotEmpty && postalController.text.toString().trim().length < 6) {
      showSnackBar('6 digit postal code is required', context);
    } else {
      await _progressDialog.show();
      setState(() {
        isEditWork = false;
        isEditContact = false;
        isEditProfile = false;
        isEditPayoutMethod = false;
        isEditCancellationPolicy = false;
      });
      Map apiCall = {};
      apiCall['CoachId'] = OQDOApplication.instance.coachID;
      apiCall['FirstName'] = nameController.text.toString().trim();
      apiCall['LastName'] = lastNameController.text.toString().trim();
      apiCall['CityId'] = cityId;
      apiCall['PinCode'] = coachProfileResponseModel.pinCode;
      apiCall['Email'] = emailIdController.text.toString().trim();
      apiCall['MobCountryCode'] = OQDOApplication.instance.storage.getStringValue(AppStrings.selectedCountryCode);
      apiCall['MobileNumber'] = phoneNumberController.text.toString().trim();
      apiCall['Address'] = addressController.text.toString().trim();
      apiCall['ICNumber'] = icNumberController.text.toString().trim();
      apiCall['CoachRegistoryNumber'] = coachRegistryIdController.text.toString().trim();
      apiCall['ExperienceYear'] = coachExperienceController.text.toString().trim();
      apiCall['OtherDescription'] = descriptionController.text.toString().trim();
      apiCall['RegServiceProviderId'] = coachProfileResponseModel.RegServiceProviderId;
      apiCall['ProfileImageId'] = profileImageId;
      apiCall['USERID'] = coachProfileResponseModel.userId;
      apiCall['CoachTitle'] = nameController.text.toString().trim();
      apiCall['CoachSubTitle'] = nameController.text.toString().trim();

      // new fields
      apiCall['PayoutMethod'] = selectedPayoutMethod?.value;
      apiCall['MobileNum'] = selectedPayoutMethod == PayoutMethodTypeEnum.payNow
          ? payNowMobileNumberController.text
          : selectedPayoutMethod == PayoutMethodTypeEnum.payLah
              ? payLahMobileNumberController.text
              : "";
      apiCall['PayNowId'] = payNowIdController.text;
      apiCall['BeneficiaryName'] = beneficiaryNameController.text;
      apiCall['BankName'] = bankNameController.text;
      apiCall['BankAccountNumber'] = bankAccountNumberController.text;
      apiCall['IFSCSwiftCode'] = ifscCodeController.text;
      apiCall['UENRegistrationNo'] = uenNumberController.text.toString().trim();

      if (isActivityChanges!) {
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
        apiCall['CoachSubActivityDtos'] = subActivityMapList;
      } else {
        List<Map<String, dynamic>> list = [];
        for (int i = 0; i < coachProfileResponseModel.coachSubActivityDtos!.length; i++) {
          Map<String, dynamic> map = {};
          map['SubActivityId'] = coachProfileResponseModel.coachSubActivityDtos![i].subActivityId;
          list.add(map);
        }
        apiCall['CoachSubActivityDtos'] = list;
      }
      List<Map> certificateIdMap = [];
      if (certificateUploadId != null && certificateUploadId!.isNotEmpty) {
        for (int i = 0; i < certificateUploadId!.length; i++) {
          Map map = {};
          map['FileStorageId'] = certificateUploadId![i];
          certificateIdMap.add(map);
        }
      }

      apiCall['CoachCertificationDtos'] = certificateIdMap;
      apiCall['CoachPrvReviewDtos'] = [];
      DateTime effectiveDate;
      String formattedDate = '';
      if (effectiveDateController.text.trim().isNotEmpty) {
        effectiveDate = DateFormat("dd-MM-yyyy").parseStrict(effectiveDateController.text);
        formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(effectiveDate);
      }

      if (cancellationHoursController.text.isNotEmpty || cancellationMinutesController.text.isNotEmpty) {
        await calculateCancellationTimeInMinutes(cancellationHoursController.text.trim(), cancellationMinutesController.text.trim());
      }

      apiCall['CoachCancelPolicyDto'] = {'EffectiveDate': formattedDate, 'CancelMinute': _slotTimeInMins.toString()};
      // apiCall['CoachCancelPolicyDto'] = null;

      try {
        await Provider.of<ProfileViewModel>(context, listen: false).coachProviderRegister(apiCall).then(
          (value) async {
            Response res = value;

            if (res.statusCode == 500 || res.statusCode == 404) {
              await _progressDialog.hide();
              setState(() {
                // OQDOApplication.instance.userName = '${nameController.text.toString().trim()} ${lastNameController.text.toString().trim()}';
                // context.read<ChatProvider>().setUserName('${nameController.text.toString().trim()} ${lastNameController.text.toString().trim()}');
                isEditWork = false;
                isEditContact = false;
                isEditProfile = false;
                isEditPayoutMethod = false;
                isEditCancellationPolicy = false;
              });
              showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
            } else if (res.statusCode == 200) {
              await _progressDialog.hide();
              setState(() {
                OQDOApplication.instance.profileImage = uploadedProfileFilePath;
                if (uploadedImagePath.isNotEmpty) {
                  Provider.of<ChatProvider>(context, listen: false).setProfileImagePath(uploadedImagePath);
                }
              });
              String response = res.body;
              debugPrint("callUpdateApi response -> $response");
              showSnackBarColor('Profile updated successfully', context, false);
              setState(() {
                OQDOApplication.instance.userName = '${nameController.text.toString().trim()} ${lastNameController.text.toString().trim()}';
                context.read<ChatProvider>().setUserName('${nameController.text.toString().trim()} ${lastNameController.text.toString().trim()}');
                isEditWork = false;
                isEditContact = false;
                isEditProfile = false;
                isEditPayoutMethod = false;
                isEditCancellationPolicy = false;
                currentEffectiveDate = effectiveDateController.text;
              });
            } else {
              await _progressDialog.hide();
              setState(() {
                // OQDOApplication.instance.userName = '${nameController.text.toString().trim()} ${lastNameController.text.toString().trim()}';
                // context.read<ChatProvider>().setUserName('${nameController.text.toString().trim()} ${lastNameController.text.toString().trim()}');
                isEditWork = false;
                isEditContact = false;
                isEditProfile = false;
                isEditPayoutMethod = false;
                isEditCancellationPolicy = false;
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
        await _progressDialog.hide();
        setState(() {
          // OQDOApplication.instance.userName = '${nameController.text.toString().trim()} ${lastNameController.text.toString().trim()}';
          // context.read<ChatProvider>().setUserName('${nameController.text.toString().trim()} ${lastNameController.text.toString().trim()}');
          isEditWork = false;
          isEditContact = false;
          isEditProfile = false;
          isEditPayoutMethod = false;
          isEditCancellationPolicy = false;
        });
        showSnackBarErrorColor(AppStrings.noInternet, context, true);
      } on TimeoutException catch (_) {
        await _progressDialog.hide();
        setState(() {
          // OQDOApplication.instance.userName = '${nameController.text.toString().trim()} ${lastNameController.text.toString().trim()}';
          // context.read<ChatProvider>().setUserName('${nameController.text.toString().trim()} ${lastNameController.text.toString().trim()}');
          isEditWork = false;
          isEditContact = false;
          isEditProfile = false;
          isEditPayoutMethod = false;
          isEditCancellationPolicy = false;
        });
        showSnackBarErrorColor(AppStrings.timeout, context, true);
      } on ServerException catch (_) {
        await _progressDialog.hide();
        setState(() {
          // OQDOApplication.instance.userName = '${nameController.text.toString().trim()} ${lastNameController.text.toString().trim()}';
          // context.read<ChatProvider>().setUserName('${nameController.text.toString().trim()} ${lastNameController.text.toString().trim()}');
          isEditWork = false;
          isEditContact = false;
          isEditProfile = false;
          isEditPayoutMethod = false;
          isEditCancellationPolicy = false;
        });
        showSnackBarErrorColor(AppStrings.serverError, context, true);
      } catch (exception) {
        await _progressDialog.hide();
        setState(() {
          // OQDOApplication.instance.userName = '${nameController.text.toString().trim()} ${lastNameController.text.toString().trim()}';
          // context.read<ChatProvider>().setUserName('${nameController.text.toString().trim()} ${lastNameController.text.toString().trim()}');
          isEditWork = false;
          isEditContact = false;
          isEditProfile = false;
          isEditPayoutMethod = false;
          isEditCancellationPolicy = false;
        });
        showSnackBarErrorColor(exception.toString(), context, true);
      }
    }
  }

  void showDeleteAlertDialog(CoachTrainingAddress model) => showCupertinoDialog(
        context: context,
        builder: ((context) {
          return CupertinoAlertDialog(
            title: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: CustomTextView(
                label: 'Training Address',
                textStyle: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
              ),
            ),
            content: CustomTextView(
              label: 'Are you sure you want to delete Training Address?',
              maxLine: 2,
              textStyle: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 18,
                      fontWeight: FontWeight.w400),
            ),
            actions: [
              CupertinoDialogAction(
                  child: CustomTextView(label: 'Yes'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    deleteTrainingAddressCall(model);
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

  Future<void> deleteTrainingAddressCall(CoachTrainingAddress model) async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");

    try {
      await _progressDialog.show();
      Map<String, dynamic> request = {};
      request['CoachTrainingAddressId'] = model.coachTrainingAddressId;
      request['CoachId'] = model.coachId;
      // request['SubActivityId'] = ;
      request['AddressName'] = model.addressName;
      request['Address1'] = model.address1;
      request['Address2'] = model.address2;
      request['CityId'] = model.cityId;
      request['PinCode'] = model.pinCode;
      request['IsActive'] = false;

      await Provider.of<ProfileViewModel>(context, listen: false).deleteCoachAddress(request).then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            await _progressDialog.hide();
            String response = res.body;
            if (response.isNotEmpty) {
              showSnackBarColor('Delete Successfully', context, false);
              getCoachTrainingCenterAddress();
            }
          } else {
            await _progressDialog.hide();
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
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      await _progressDialog.hide();
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  Future<void> getCoachTrainingCenterAddress() async {
    try {
      await _progressDialog.show();
      await Provider.of<ProfileViewModel>(context, listen: false).getCoachTrainingAddress(OQDOApplication.instance.coachID!).then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            await _progressDialog.hide();
            List body = jsonDecode(res.body);
            List<CoachTrainingAddress> list = [];
            for (int i = 0; i < body.length; i++) {
              CoachTrainingAddress coachTrainingAddress = CoachTrainingAddress.fromJson(body[i]);
              list.add(coachTrainingAddress);
            }
            debugPrint("Coach training address -> $list");
            setState(() {
              coachTrainingAddressList = list;
            });
            debugPrint(coachTrainingAddressList.toString());
          } else {
            await _progressDialog.hide();
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
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      await _progressDialog.hide();
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  Future<void> getCoachDetails() async {
    try {
      await _progressDialog.show();
      await Provider.of<ProfileViewModel>(context, listen: false).getCoachUserProfile(OQDOApplication.instance.coachID!).then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            coachProfileResponseModel = CoachProfileResponseModel.fromJson(jsonDecode(res.body));
            if (coachProfileResponseModel.coachTitle != null) {
              setState(() {
                setCoachValues(coachProfileResponseModel);
                setSlotValue(coachProfileResponseModel);

                if (coachProfileResponseModel.accountClosureStatus == null || coachProfileResponseModel.accountClosureStatus == 'R') {
                  isCloseAccount = false;
                } else {
                  isCloseAccount = true;
                }
              });
            }
            getAllActivity();
          } else {
            await _progressDialog.hide();
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
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      await _progressDialog.hide();
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1),
      firstDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      lastDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 89),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            dialogBackgroundColor: Theme.of(context).colorScheme.surface,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        effectiveDateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  String convertMinutesToValidationText(int totalMinutes) {
    if (totalMinutes < 0) {
      return "";
    }

    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    return "$hours ${hours == 1 ? "hour" : "hours"} and $minutes ${minutes == 1 ? "minute" : "minutes"}";
  }

  Future<void> callAccountClose() async {
    try {
      await _progressDialog.show();
      Map<String, dynamic> request = {};
      request['CoachId'] = OQDOApplication.instance.coachID!;
      request['AccountClosureStatus'] = 'P';
      await Provider.of<ProfileViewModel>(context, listen: false).coachUserAccountClose(request).then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            String response = res.body;
            if (response.isNotEmpty) {
              await _progressDialog.hide();
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
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onBackground,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          } else {
            await _progressDialog.hide();
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
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      await _progressDialog.hide();
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }
}
