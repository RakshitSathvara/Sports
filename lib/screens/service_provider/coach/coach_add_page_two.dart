// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/model/common_passing_args.dart';
import 'package:oqdo_mobile_app/screens/common_widget/view_image_screen.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/enums.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/referral_code_field.dart';
import 'package:oqdo_mobile_app/utils/textfields_widget.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import '../../../helper/helpers.dart';
import '../../../model/get_all_activity_and_sub_activity_response.dart';
import '../../../model/upload_file_response.dart';
import '../../../oqdo_application.dart';
import '../../../theme/oqdo_theme_data.dart';
import '../../../utils/string_manager.dart';
import '../../../viewmodels/end_user_resgistration_view_model.dart';

class CoachAddPageTwo extends StatefulWidget {
  final CommonPassingArgs commonPassingArgs;

  const CoachAddPageTwo(this.commonPassingArgs, {super.key});

  @override
  CoachAddPageTwoState createState() => CoachAddPageTwoState();
}

class CoachAddPageTwoState extends State<CoachAddPageTwo> {
  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  TextEditingController description = TextEditingController();
  List<String> interests = ['Basket Ball', 'Gym'];
  String? choosedinterest;
  List<TextEditingController> review = [];
  List<TextEditingController> comment = [];
  int counter = 1;
  final picker = ImagePicker();
  File? profilepic;
  late Helper hp;

  late ProgressDialog _progressDialog;
  List<SubActivitiesBean> sportsInterest = [];
  List<ActivityBean>? activityListModel = [];
  Map<String, List<SelectedFilterValues>>? selectedFilterData = {};
  List<String>? certificateUploadId = [];

  // List<File> certificateList = [];
  String? countryID = '';
  String? countryCode = '';

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
  int mobileNoLength = 0;
  bool termsAndCondition = false;
  List<String> certificateList = [];

  final otherTextController = TextEditingController();

  TextEditingController referralCode = TextEditingController();
  bool _isValid = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    hp = Helper.of(context);
    review.add(TextEditingController());
    comment.add(TextEditingController());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(message: "Please wait...");
      getAllActivity();
      getPrefData();
      _focusNode.addListener(_onFocusChange);
    });
  }

  @override
  void dispose() {
    referralCode.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void getPrefData() async {
    countryID = OQDOApplication.instance.storage.getStringValue(AppStrings.selectedCountryID);
    countryCode = OQDOApplication.instance.storage.getStringValue(AppStrings.selectedCountryCode);
    var mobileNoLengthStr = OQDOApplication.instance.storage.getStringValue(AppStrings.mobileNoLength);
    mobileNoLength = int.parse(mobileNoLengthStr.isEmpty ? "0" : mobileNoLengthStr);
    debugPrint(countryCode);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final secondaryTextColor = Theme.of(context).brightness == Brightness.dark
        ? OQDOThemeData.darkOtherTextColor
        : OQDOThemeData.otherTextColor;
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).colorScheme.surface,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Form(
                key: hp.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20.0,
                    ),
                    Center(
                      child: Image.asset(
                        "assets/images/logo.png",
                        height: 80,
                        width: 130,
                      ),
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    Center(
                      child: CustomTextView(
                        label: 'Coach',
                        type: styleSubTitle,
                        textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontSize: 22.0,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ),
                    Divider(
                      thickness: 3,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.78),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    GestureDetector(
                      onTap: () async {
                        Map<String, List<SubActivitiesBean>> interestValue = {};

                        for (int i = 0; i < activityListModel!.length; i++) {
                          // activityListModel![i].isSelected = false;
                          // activityListModel![i].SubActivities?.forEach((element) {
                          //   element.isSelected = false;
                          //   element.selectedValue = false;
                          // });
                          interestValue[activityListModel![i].Name!] = activityListModel![i].SubActivities!;
                        }

                        // widget.commonPassingArgs.endUserActivitySelection =
                        //     interestValue;
                        var data = await Navigator.pushNamed(context, Constants.coachActivityInterestFilterScreen, arguments: interestValue);
                        debugPrint(data.toString());
                        if (data != null && data != {} && data is Map) {
                          setState(() {
                            selectedFilterData = data as Map<String, List<SelectedFilterValues>>?;

                            debugPrint(selectedFilterData.toString());
                          });
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTextView(
                            label: 'Activities',
                            textStyle:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(color: const Color(0xFF818181), fontSize: 17.0, fontWeight: FontWeight.w400),
                          ),
                          Image.asset(
                            'assets/images/ic_left_nav_arrow.png',
                            height: 20.0,
                            width: 20.0,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    selectedFilterData!.isNotEmpty
                        ? Row(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: selectedFilterData!.length,
                                  itemBuilder: (context, index) {
                                    String name = selectedFilterData!.keys.elementAt(index);
                                    return Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: CustomTextView(
                                                label: "$name : ",
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: textColor),
                                              ),
                                            ),
                                            Expanded(
                                              child: Wrap(
                                                spacing: 5.0,
                                                runSpacing: 8.0,
                                                children: [for (var data in selectedFilterData![name]!) chipsWidget(data,textColor)],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10.0,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                        : CustomTextView(
                            label: '(Select the activities you would like to add)',
                            textStyle:
                                Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 15.0, fontWeight: FontWeight.w400, color: textColor),
                          ),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomTextView(
                      label: 'If the sub activity you are interested in is not in our list',
                      maxLine: 2,
                      textOverFlow: TextOverflow.ellipsis,
                      textStyle: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    CustomTextFormField(
                      labelText: 'let us know',
                      controller: otherTextController,
                      read: false,
                      obscureText: false,
                      maxlines: 1,
                      maxlength: 50,
                      keyboardType: TextInputType.text,
                      inputformat: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-z ]')),
                      ],
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    CustomTextView(
                      label: 'Upload Certification Photo(s)',
                      textStyle: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontSize: 17.0, color: secondaryTextColor, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            bottomSheetImage();
                          },
                          child: const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.transparent,
                            backgroundImage: AssetImage("assets/images/camera.png"),
                          ),
                        ),
                        const SizedBox(
                          width: 8.0,
                        ),
                        certificateList.isNotEmpty
                            ? Expanded(
                                child: GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.9,
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
                                            IconButton(
                                              icon: const Icon(Icons.close),
                                              onPressed: () {
                                                certificateList.removeAt(index);
                                                certificateUploadId!.removeAt(index);
                                                profilepic = null;
                                                setState(() {});
                                              },
                                            ),
                                            const SizedBox(
                                              width: 2,
                                            ),
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
                                            )),
                                          ],
                                        ),
                                      );
                                    }),
                              )
                            : const SizedBox(),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    CustomTextFormField(
                      controller: description,
                      read: false,
                      fillColor: Theme.of(context).colorScheme.surface,
                      obscureText: false,
                      maxlength: 250,
                      // inputformat: [
                      //   FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9 _]+')),
                      // ],
                      labelText: 'Description',
                      // validator: Validator.notEmpty,
                      keyboardType: TextInputType.text,
                      maxlines: 4,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
                        borderRadius: BorderRadius.circular(15),
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: DropdownButton<dynamic>(
                            isExpanded: true,
                            icon: Icon(Icons.keyboard_arrow_down_rounded,
                                color: Theme.of(context).colorScheme.primary),
                            dropdownColor: Theme.of(context).colorScheme.surface,
                            underline: const SizedBox(),
                            borderRadius: BorderRadius.circular(15),
                            hint: CustomTextView(
                              label: selectedPayoutMethod?.displayText ?? "Select Payout Method",
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: Theme.of(context).colorScheme.primary),
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
                                      .copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: Theme.of(context).colorScheme.primary),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
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
                            }),
                      ),
                    ),
                    Form(
                      key: payoutDetailsKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Visibility(
                            visible: selectedPayoutMethod == PayoutMethodTypeEnum.payNow,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                CustomTextFormField(
                                  controller: payNowMobileNumberController,
                                  read: false,
                                  obscureText: false,
                                  maxlines: 1,
                                  maxlength: mobileNoLength,
                                  inputformat: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  fillColor: Theme.of(context).colorScheme.surface,
                                  labelText: 'Mobile number {Linked to PayNow}',
                                  validator: (value) {
                                    if (value?.isEmpty ?? false) {
                                      return "Please enter mobile number";
                                    } else if (value!.length < mobileNoLength) {
                                      return "Please enter valid mobile number";
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                CustomTextFormField(
                                  controller: payNowIdController,
                                  read: false,
                                  obscureText: false,
                                  maxlines: 1,
                                  maxlength: 10,
                                  inputformat: [
                                    FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]+')),
                                  ],
                                  fillColor: Theme.of(context).colorScheme.surface,
                                  labelText: 'PayNow ID (UEN Number)',
                                  validator: (value) {
                                    if (value?.isEmpty ?? false) {
                                      return "Please enter PayNow ID (UEN Number)";
                                    } else if (value!.length < 5) {
                                      return "Please enter valid PayNow ID (UEN Number)";
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.text,
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
                                  height: 20,
                                ),
                                CustomTextFormField(
                                  controller: payLahMobileNumberController,
                                  read: false,
                                  obscureText: false,
                                  maxlines: 1,
                                  maxlength: mobileNoLength,
                                  inputformat: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  fillColor: Theme.of(context).colorScheme.surface,
                                  labelText: 'Mobile number {Linked to PayLah}',
                                  validator: (value) {
                                    if (value?.isEmpty ?? false) {
                                      return "Please enter mobile number";
                                    } else if (value!.length < mobileNoLength) {
                                      return "Please enter valid mobile number";
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.phone,
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
                                  height: 20,
                                ),
                                CustomTextFormField(
                                  controller: beneficiaryNameController,
                                  read: false,
                                  obscureText: false,
                                  maxlines: 1,
                                  maxlength: 50,
                                  fillColor: Theme.of(context).colorScheme.surface,
                                  labelText: 'Beneficiary name',
                                  inputformat: [
                                    FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9 ]+')),
                                  ],
                                  validator: (value) {
                                    if (value?.isEmpty ?? false) {
                                      return "Please enter beneficiary name";
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.name,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                CustomTextFormField(
                                  controller: bankNameController,
                                  read: false,
                                  obscureText: false,
                                  maxlines: 1,
                                  maxlength: 50,
                                  inputformat: [
                                    FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z ]+')),
                                  ],
                                  fillColor: Theme.of(context).colorScheme.surface,
                                  labelText: 'Bank name',
                                  validator: (value) {
                                    if (value?.isEmpty ?? false) {
                                      return "Please enter bank name";
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.text,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                CustomTextFormField(
                                  controller: bankAccountNumberController,
                                  read: false,
                                  obscureText: false,
                                  maxlines: 1,
                                  maxlength: 20,
                                  inputformat: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  fillColor: Theme.of(context).colorScheme.surface,
                                  labelText: 'Bank account number',
                                  validator: (value) {
                                    if (value?.isEmpty ?? false) {
                                      return "Please enter bank account number";
                                    } else if (value!.length < 5) {
                                      return "Please enter valid bank account number";
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                CustomTextFormField(
                                  controller: ifscCodeController,
                                  read: false,
                                  obscureText: false,
                                  maxlines: 1,
                                  maxlength: 20,
                                  inputformat: [
                                    FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]+')),
                                  ],
                                  fillColor: Theme.of(context).colorScheme.surface,
                                  labelText: 'IFSC/Swift code',
                                  validator: (value) {
                                    if (value?.isEmpty ?? false) {
                                      return "Please enter IFSC/Swift code";
                                    } else if (value!.length < 5) {
                                      return "Please enter valid IFSC/Swift code";
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.text,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    ReferralTextField(
                      suffixIcon: _isValid
                          ? Container(
                              margin: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            )
                          : null,
                      controller: referralCode,
                      onchanged: (p0) {
                        setState(() {
                          _isValid = false; // Reset validation when user types
                        });
                        return '';
                      },
                      // Add focus node to the ReferralTextField
                      focusNode: _focusNode,
                      read: false,
                      obscureText: false,
                      fillColor: Theme.of(context).colorScheme.surface,
                      labelText: 'Referral Code',
                      inputformat: [
                        FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9 ]+')),
                      ],
                      maxlength: 8,
                      maxlines: 1,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Transform.scale(
                          scale: 1.3,
                          child: Checkbox(
                              fillColor: MaterialStateProperty.resolveWith(getColor),
                              checkColor: Theme.of(context).colorScheme.primaryContainer,
                              value: termsAndCondition,
                              onChanged: (value) {
                                if (referralCode.text.isNotEmpty) {
                                  _validateReferralCode(referralCode.text.toString().trim());
                                }
                                setState(() {
                                  termsAndCondition = value!;
                                });
                              }),
                        ),
                        Flexible(
                          child: RichText(
                            text: TextSpan(
                              text: 'I have read and accept the ',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(fontSize: 17.0, fontWeight: FontWeight.w400, color: secondaryTextColor),
                              children: [
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      if (await NetworkConnectionInterceptor().isConnected()) {
                                        Map<String, dynamic> model = {};
                                        model['url'] = 'https://oqdo.com/terms-of-service/';
                                        model['title'] = 'Terms of Service';
                                        Navigator.pushNamed(context, Constants.webViewScreens, arguments: model);
                                      } else {
                                        showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
                                      }
                                    },
                                  text: 'Terms & Conditions',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 17.0,
                                      color: Theme.of(context).colorScheme.primaryContainer,
                                      decoration: TextDecoration.underline,
                                      decorationThickness: 2),
                                ),
                                TextSpan(
                                  text: ', ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(fontSize: 17.0, fontWeight: FontWeight.w400, color: secondaryTextColor),
                                ),
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      if (await NetworkConnectionInterceptor().isConnected()) {
                                        Map<String, dynamic> model = {};
                                        model['url'] = 'https://oqdo.com/privacy-policy-oqdo/';
                                        model['title'] = 'Privacy Policy';
                                        Navigator.pushNamed(context, Constants.webViewScreens, arguments: model);
                                      } else {
                                        showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
                                      }
                                    },
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 17.0,
                                      color: Theme.of(context).colorScheme.primaryContainer,
                                      decoration: TextDecoration.underline,
                                      decorationThickness: 2),
                                ),
                                TextSpan(
                                  text: ' and ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(fontSize: 17.0, fontWeight: FontWeight.w400, color: secondaryTextColor),
                                ),
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      if (await NetworkConnectionInterceptor().isConnected()) {
                                        Map<String, dynamic> model = {};
                                        model['url'] = 'https://oqdo.com/cancellation-policy/';
                                        model['title'] = 'Cancellation Policy';
                                        Navigator.pushNamed(context, Constants.webViewScreens, arguments: model);
                                      } else {
                                        showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
                                      }
                                    },
                                  text: 'Cancellation Policy',
                                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context).colorScheme.primaryContainer,
                                      decoration: TextDecoration.underline,
                                      decorationThickness: 2),
                                ),
                                TextSpan(
                                  text: '.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(fontSize: 17.0, fontWeight: FontWeight.w400, color: secondaryTextColor),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    MyButton(
                      text: "Register",
                      textcolor: Theme.of(context).colorScheme.onBackground,
                      textsize: 16,
                      fontWeight: FontWeight.w600,
                      letterspacing: 0.7,
                      buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                      buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                      buttonheight: 60,
                      buttonwidth: width,
                      radius: 15,
                      onTap: () async {
                        hideKeyboard();
                        checkForValidation(textColor);
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onFocusChange() async {
    if (!_focusNode.hasFocus) {
      final value = referralCode.text;
      if (value.isNotEmpty && value.length >= 6) {
        await _progressDialog.show();
        setState(() {});
        try {
          final isValid = await _validateReferralCode(value);
          if (!isValid) {
            referralCode.clear();
            await _progressDialog.hide();
            showSnackBarColor('Invalid referral code', context, true);
            setState(() {});
          }
        } catch (e) {
          await _progressDialog.show();
          setState(() {});
          if (mounted) {
            await _progressDialog.hide();
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error validating referral code. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          if (mounted) {
            await _progressDialog.hide();
            setState(() {});
          }
        }
      }
    }
  }

  Future<bool> _validateReferralCode(String code) async {
    bool isValid = false;

    try {
      await Provider.of<EndUserRegistrationViewModel>(context, listen: false).validateReferralCode(code).then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            await _progressDialog.hide();
            bool response = jsonDecode(res.body);
            if (response) {
              setState(() {
                _isValid = true;
                isValid = true;
              });
            } else {
              setState(() {
                _isValid = false;
                isValid = false;
              });
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
    return isValid;
  }

  chipsWidget(SelectedFilterValues item,Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.onSurface),
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
      child: CustomTextView(
        textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: textColor,
            fontSize: 13.0,
            fontWeight: FontWeight.w400),
        label: item.activityName,
      ),
    );
  }

  bottomSheetImage() async {
    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text(
                      'Photo Library',
                      style: TextStyle(
                          // fontFamily: 'Fingbanger',
                          ),
                    ),
                    onTap: () async {
                      // final serviceStatus = await Permission.storage.isGranted; not in use
                      // if (Constants.androidVersion >= 13) {
                      //   getPicFromGallery();
                      // } else {
                      //   // final serviceStatus = await Permission.storage.isGranted;
                      //   final status = await Permission.storage.request();
                      //   if (status == PermissionStatus.granted) {
                      //     getPicFromGallery();
                      //   } else if (status == PermissionStatus.denied) {
                      //     showSnackBar('Permission denied.Please Allow Permission.', context);
                      //   } else if (status == PermissionStatus.permanentlyDenied) {
                      //     await openAppSettings();
                      //   }
                      // }

                      // new code
                      if (Constants.androidVersion >= 13) {
                        getMultiplePicFromGallery();
                      } else {
                        var status = await Permission.storage.request();
                        if (status == PermissionStatus.granted) {
                          getMultiplePicFromGallery();
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
                      // final serviceStatus = await Permission.camera.isGranted;
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
            debugPrint("File size -> ${mb.toString()}");
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

  Future<void> uploadMultipleImgFiles(List<XFile> pickedFile) async {
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

    try {
      await Provider.of<EndUserRegistrationViewModel>(context, listen: false).multipleUploadFile(requestList).then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            await _progressDialog.hide();
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
            // await _progressDialog.hide();
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

  Future getPicFromCam() async {
    Navigator.pop(context);
    await _progressDialog.show();
    setState(() {});
    var pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
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
          profilepic = File(pickedFile.path);
          setState(() {});
          var bytes = File(profilepic!.path).readAsBytesSync();
          String convertedBytes = base64Encode(bytes);
          uploadFile(convertedBytes);
        } else {
          await _progressDialog.hide();
          setState(() {});
          showSnackBarErrorColor("Please select image below 10 MB", context, true);
        }
      }
    } else {
      await _progressDialog.hide();
      setState(() {});
    }
  }

  // Future getPicFromGallery() async {
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //   Navigator.pop(context);
  //   setState(() {
  //     if (pickedFile != null) {
  //       profilepic = File(pickedFile.path);
  //       certificateList.add(profilepic!);
  //       final bytes = File(profilepic!.path).readAsBytesSync();
  //       String convertedBytes = base64Encode(bytes);
  //       debugPrint(convertedBytes);
  //       debugPrint(profilepic!.path);
  //       debugPrint(profilepic!.path.split('/').last);
  //       debugPrint(profilepic!.path.split('/').last.split('.')[1]);
  //       uploadFile(convertedBytes);
  //     }
  //   });
  // }

  Future<void> getAllActivity() async {
    try {
      await _progressDialog.show();
      await Provider.of<EndUserRegistrationViewModel>(context, listen: false).getAllActivity().then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            GetAllActivityAndSubActivityResponse? getAllActivityAndSubActivityResponse = GetAllActivityAndSubActivityResponse.fromMap(jsonDecode(res.body));
            if (getAllActivityAndSubActivityResponse!.Data!.isNotEmpty) {
              await _progressDialog.hide();
              setState(() {
                activityListModel = getAllActivityAndSubActivityResponse.Data!;
              });
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

  Future<void> uploadFile(String base64File) async {
    await _progressDialog.show();
    Map uploadFileRequest = {};
    uploadFileRequest['FileStorageId'] = null;
    uploadFileRequest['FileName'] = profilepic!.path.split('/').last;
    uploadFileRequest['FileExtension'] = profilepic!.path.split('/').last.split('.')[1];
    uploadFileRequest['FilePath'] = base64File;

    try {
      await Provider.of<EndUserRegistrationViewModel>(context, listen: false).uploadFile(uploadFileRequest).then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            await _progressDialog.hide();
            UploadFileResponse? uploadFileResponse = UploadFileResponse.fromMap(jsonDecode(res.body));
            debugPrint('Upload File Response -> ${uploadFileResponse!.FileStorageId}');
            certificateUploadId!.add(uploadFileResponse.FileStorageId.toString());
            if (uploadFileResponse.FilePath != null && uploadFileResponse.FilePath!.isNotEmpty) {
              setState(() {
                certificateList.add(uploadFileResponse.FilePath!);
              });
            } else {
              showSnackBarColor("Image not uploaded", context, true);
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

  void checkForValidation(Color textColor) {
    if (selectedFilterData!.isEmpty) {
      showSnackBar('Select any Activity', context);
    } else if (selectedPayoutMethod == null) {
      showSnackBar('Select Payout Method', context);
    } else if (!payoutDetailsKey.currentState!.validate()) {
      return;
    } else if (!termsAndCondition) {
      showSnackBar('Please Accept Terms & Conditions', context);
    } else {
      coachRegistration(textColor);
    }
  }

  Future<void> coachRegistration(Color textColor) async {
    await _progressDialog.show();
    Map coachProviderRequest = {};
    coachProviderRequest['CoachId'] = null;
    coachProviderRequest['FirstName'] = widget.commonPassingArgs.coachFirstName;
    coachProviderRequest['LastName'] = widget.commonPassingArgs.coachLastName;
    coachProviderRequest['CityId'] = countryID;
    coachProviderRequest['PinCode'] = widget.commonPassingArgs.postalCode;
    coachProviderRequest['Email'] = widget.commonPassingArgs.emilID;
    coachProviderRequest['MobCountryCode'] = countryCode;
    coachProviderRequest['MobileNumber'] = widget.commonPassingArgs.mobileNo;
    coachProviderRequest['Address'] = widget.commonPassingArgs.address;
    coachProviderRequest['ICNumber'] = widget.commonPassingArgs.coachICNumber;
    coachProviderRequest['CoachRegistoryNumber'] = widget.commonPassingArgs.coachRegistryNumber;
    coachProviderRequest['ExperienceYear'] = widget.commonPassingArgs.coachEstablishmentYear;
    coachProviderRequest['OtherDescription'] = description.text.toString().trim();
    coachProviderRequest['RegServiceProviderId'] = widget.commonPassingArgs.tempRegisterId;
    coachProviderRequest['USERID'] = null;
    coachProviderRequest['CoachTitle'] = widget.commonPassingArgs.coachFirstName;
    coachProviderRequest['CoachSubTitle'] = widget.commonPassingArgs.coachLastName;
    coachProviderRequest['IsTermsAccepted'] = termsAndCondition;
    coachProviderRequest['UENRegistrationNo'] = widget.commonPassingArgs.uenNUmber;
    if (widget.commonPassingArgs.profileImageUploadId != null) {
      coachProviderRequest['ProfileImageId'] = widget.commonPassingArgs.profileImageUploadId;
    } else {
      coachProviderRequest['ProfileImageId'] = null;
    }
    coachProviderRequest['Others'] = otherTextController.text.toString().trim();
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

    coachProviderRequest['CoachSubActivityDtos'] = subActivityMapList;

    List<Map> certificateIdMap = [];
    for (int i = 0; i < certificateUploadId!.length; i++) {
      Map map = {};
      map['FileStorageId'] = certificateUploadId![i];
      certificateIdMap.add(map);
    }

    coachProviderRequest['CoachCertificationDtos'] = certificateIdMap;
    coachProviderRequest['CoachPrvReviewDtos'] = [];
    coachProviderRequest['CoachCancelPolicyDto'] = null;

    //new fields
    coachProviderRequest['PayoutMethod'] = selectedPayoutMethod!.value;
    coachProviderRequest['MobileNum'] = selectedPayoutMethod == PayoutMethodTypeEnum.payNow
        ? payNowMobileNumberController.text.trim()
        : selectedPayoutMethod == PayoutMethodTypeEnum.payLah
            ? payLahMobileNumberController.text.trim()
            : "";
    coachProviderRequest['PayNowId'] = payNowIdController.text.trim();
    coachProviderRequest['BeneficiaryName'] = beneficiaryNameController.text.trim();
    coachProviderRequest['BankName'] = bankNameController.text.trim();
    coachProviderRequest['BankAccountNumber'] = bankAccountNumberController.text.trim();
    coachProviderRequest['IFSCSwiftCode'] = ifscCodeController.text.trim();
    coachProviderRequest['ReferrerCode'] = referralCode.text.toString().trim();

    debugPrint('Request -> $coachProviderRequest');

    try {
      await Provider.of<EndUserRegistrationViewModel>(context, listen: false).coachProviderRegister(coachProviderRequest).then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            await _progressDialog.hide();
            String response = res.body;
            debugPrint("coachProviderRegister response -> $response");
            showSnackBarColor('Registration Successful', context, false);
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return WillPopScope(
                  onWillPop: () async => false,
                  child: AlertDialog(
                    title: CustomTextView(
                      label: 'Account- Pending Approval',
                      textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 18.0, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    content: CustomTextView(
                      label:
                          'Your account is presently under review. Upon completion of the approval process, you will receive an email. If you have any questions, please visit our website to contact us.',
                      maxLine: 6,
                      textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 15.0, fontWeight: FontWeight.w400, color: textColor),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () async {
                          await Navigator.pushNamedAndRemoveUntil(context, Constants.LOGIN, (r) => false);
                        },
                        child: Text(
                          'Ok',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
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
