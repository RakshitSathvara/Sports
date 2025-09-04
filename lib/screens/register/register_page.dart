// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/model/common_passing_args.dart';
import 'package:oqdo_mobile_app/model/get_all_activity_and_sub_activity_response.dart';
import 'package:oqdo_mobile_app/model/location_selection_response_model.dart';
import 'package:oqdo_mobile_app/model/otp_verification_response.dart';
import 'package:oqdo_mobile_app/model/upload_file_response.dart';
import 'package:oqdo_mobile_app/request_models/end_user_registration_temp_req_model.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_edit_text.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/referral_code_field.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:oqdo_mobile_app/utils/textfields_widget.dart';
import 'package:oqdo_mobile_app/viewmodels/end_user_resgistration_view_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import '../../helper/helpers.dart';
import '../../oqdo_application.dart';
import '../../utils/validator.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  // TextEditingController postalcode = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confrimpassword = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController otp = TextEditingController();
  TextEditingController icNumber = TextEditingController();
  TextEditingController aboutyourself = TextEditingController();
  List<String> interests = ['Basket Ball', 'Gym'];

  TextEditingController referralCode = TextEditingController();
  String? choosedinterest;
  final picker = ImagePicker();

  // File? profilepic;
  CroppedFile? croppedFile;
  int _currentStep = 0;
  late Helper hp;
  List<DataBean>? location = [];
  // String? choosedlocation;
  // int? selectedCityId;
  String? countryCode = '';
  // DataBean? selectedLocation;
  bool? makeProfilePrivate = false;
  late ProgressDialog _progressDialog;
  int? tempRegistrationNumber;
  bool hidePassword1 = true;
  bool hidePassword2 = true;

  //Activity & Sub-Activity
  List<ActivityBean> activityListModel = [];
  List<SubActivitiesBean> sportsInterest = [];
  List<SubActivitiesBean> hobbiesInterest = [];
  List<SubActivitiesBean> lifeStyleInterest = [];
  List<File> selectedimage = [];
  Map<String, List<SelectedFilterValues>>? selectedFilterData = {};
  CommonPassingArgs commonPassingArgs = CommonPassingArgs();
  String? uploadedFileId = '';
  String? selectedCityCountryCode = '';
  String? selectedCityID = '';
  String? mobileNoLengthStr = '';
  int? mobileNoLength = 0;
  TextEditingController countryCodeController = TextEditingController();
  bool isPwdVisible = false;
  bool isConfirmPwdVisible = false;
  bool termsAndCondition = false;
  final otherTextController = TextEditingController();

  bool _isValid = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    hp = Helper.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(message: "Please wait..");
      // getAllCity();
      getShredPrefValues();
      getAllActivity();
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

  void getShredPrefValues() async {
    // choosedlocation = OQDOApplication.instance.storage.getStringValue(AppStrings.selectedCountryName);
    selectedCityCountryCode = OQDOApplication.instance.storage.getStringValue(AppStrings.selectedCountryCode);
    selectedCityID = OQDOApplication.instance.storage.getStringValue(AppStrings.selectedCountryID);
    debugPrint(selectedCityID);
    mobileNoLengthStr = OQDOApplication.instance.storage.getStringValue(AppStrings.mobileNoLength);
    mobileNoLength = int.parse(mobileNoLengthStr!);
    countryCodeController.text = selectedCityCountryCode!;
  }

  _stepState(int step) {
    if (_currentStep > step) {
      return StepState.complete;
    } else {
      return StepState.indexed;
    }
  }

  _steps() => [
        Step(
          title: CustomTextView(
            label: 'Create Account',
            textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12.0,
                color: Theme.of(context).colorScheme.onBackground),
          ),
          content: firstForm(),
          state: _stepState(0),
          isActive: _currentStep == 0,
        ),
        Step(
          title: CustomTextView(
            label: 'Verify',
            textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12.0,
                color: Theme.of(context).colorScheme.onBackground),
          ),
          content: SecondSignupPage(
            phone: phone,
            otp: otp,
            onTap: () {
              hideKeyboard();
              verifyOTP();
            },
            resend: () {
              sendOTP(tempRegistrationNumber.toString(), "s");
            },
          ),
          state: _stepState(1),
          isActive: _currentStep == 1,
        ),
        Step(
          title: CustomTextView(
            label: 'About Yourself',
            textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12.0,
                color: Theme.of(context).colorScheme.onBackground),
          ),
          content: thirdForm(),
          state: _stepState(2),
          isActive: _currentStep == 2,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Theme.of(context).colorScheme.background,
        padding: const EdgeInsets.only(top: 30, left: 0, right: 0),
        child: Theme(
          data: ThemeData(
            canvasColor: Theme.of(context).colorScheme.background,
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: Stepper(
            elevation: 0,
            // onStepTapped: (step) => setState(() => _currentStep = step),
            onStepContinue: () {
              setState(() {
                if (_currentStep < _steps().length - 1) {
                  _currentStep += 1;
                } else {
                  _currentStep = 0;
                }
              });
            },
            onStepCancel: () {
              setState(() {
                if (_currentStep > 0) {
                  _currentStep -= 1;
                } else {
                  _currentStep = 0;
                }
              });
            },
            controlsBuilder: (BuildContext context, ControlsDetails controls) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: <Widget>[
                    if (_currentStep != 1)
                      Expanded(
                        child: MyButton(
                          text: _currentStep == 0 ? 'Sign up' : 'Set Up Your Profile',
                          textcolor: _currentStep == 0 ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).colorScheme.onBackground,
                          textsize: 16,
                          fontWeight: FontWeight.w600,
                          letterspacing: 0.7,
                          buttoncolor: _currentStep == 0
                              ? Theme.of(context).colorScheme.background
                              : Theme.of(context).colorScheme.secondaryContainer,
                          buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                          buttonheight: 60,
                          imagePath: _currentStep == 0 ? 'assets/images/ic_btn_arrow.png' : 'assets/images/ic_btn.png',
                          buttonwidth: width,
                          radius: 15,
                          onTap: () async {
                            hideKeyboard();
                            if (_currentStep == 0) {
                              checkFirstStepValidation();
                            } else if (_currentStep > 1) {
                              lastStepValidation();
                            }
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
            type: StepperType.horizontal,
            currentStep: _currentStep,
            steps: _steps(),
          ),
        ),
      ),
    );
  }

  Widget firstForm() {
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextFormField(
              controller: firstNameController,
              read: false,
              obscureText: false,
              fillColor: Theme.of(context).colorScheme.background,
              labelText: 'First Name',
              inputformat: [
                FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9 ]+')),
              ],
              maxlength: 50,
              maxlines: 1,
              validator: Validator.notEmpty,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(
              height: 20.0,
            ),
            CustomTextFormField(
              controller: lastNameController,
              read: false,
              obscureText: false,
              fillColor: Theme.of(context).colorScheme.background,
              labelText: 'Last Name',
              maxlines: 1,
              inputformat: [
                FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9 ]+')),
              ],
              maxlength: 50,
              validator: Validator.notEmpty,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(
              height: 20,
            ),
            // CustomTextView(
            //   label: 'City',
            //   type: styleSubTitle,
            //   textStyle:
            //       Theme.of(context).textTheme.titleMedium!.copyWith(color: const Color.fromRGBO(129, 129, 129, 1), fontWeight: FontWeight.w600, fontSize: 17.0),
            // ),
            // const SizedBox(
            //   height: 20,
            // ),
            // Container(
            //   decoration: BoxDecoration(
            //     border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
            //     borderRadius: BorderRadius.circular(15),
            //     color: OQDOThemeData.backgroundColor,
            //   ),
            //   child: Padding(
            //     padding: const EdgeInsets.only(left: 10, right: 10),
            //     child: DropdownButton<dynamic>(
            //         isExpanded: true,
            //         icon: const Icon(Icons.keyboard_arrow_down_rounded, color: OQDOThemeData.dividerColor),
            //         dropdownColor: Theme.of(context).colorScheme.onBackground,
            //         underline: const SizedBox(),
            //         borderRadius: BorderRadius.circular(15),
            //         hint: CustomTextView(
            //           label: choosedlocation ?? "City",
            //           textStyle:
            //               Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: OQDOThemeData.dividerColor),
            //         ),
            //         value: choosedlocation,
            //         items: location!.map((country) {
            //           return DropdownMenuItem(
            //             value: country.CountryName,
            //             child: CustomTextView(
            //               label: country.CountryName!,
            //               textStyle:
            //                   Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: OQDOThemeData.dividerColor),
            //             ),
            //           );
            //         }).toList(),
            //         onChanged: (value) {
            //           debugPrint('Selected city : - $value');
            //           SchedulerBinding.instance.addPostFrameCallback((_) {
            //             setState(() {
            //               choosedlocation = value;
            //             });
            //             // checkForSelectedCity();
            //           });
            //         }),
            //   ),
            // ),
            // const SizedBox(
            //   height: 25.0,
            // ),
            // Align(
            //   alignment: Alignment.topLeft,
            //   child: CustomTextView(
            //     label: 'Postal Code',
            //     type: styleSubTitle,
            //     textStyle:
            //         Theme.of(context).textTheme.bodyLarge!.copyWith(color: const Color.fromRGBO(129, 129, 129, 1), fontWeight: FontWeight.w400, fontSize: 16.0),
            //   ),
            // ),
            // PinCodeTextField(
            //   pinBoxHeight: 55,
            //   pinBoxWidth: width / 8.0,
            //   pinBoxRadius: 5,
            //   autofocus: false,
            //   controller: postalcode,
            //   hideCharacter: false,
            //   highlight: true,
            //   highlightColor: Theme.of(context).colorScheme.secondaryContainer,
            //   defaultBorderColor: const Color.fromRGBO(0, 101, 144, 0.53),
            //   hasTextBorderColor: const Color.fromRGBO(0, 101, 144, 0.53),
            //   errorBorderColor: Colors.red,
            //   maxLength: 6,
            //   hasError: false,
            //   maskCharacter: "*",
            //   onTextChanged: (text) {},
            //   onDone: (text) async {},
            //   wrapAlignment: WrapAlignment.spaceEvenly,
            //   pinBoxDecoration: ProvidedPinBoxDecoration.underlinedPinBoxDecoration,
            //   pinTextStyle: const TextStyle(fontSize: 25.0, color: Colors.black),
            //   pinTextAnimatedSwitcherTransition: ProvidedPinBoxTextAnimation.scalingTransition,
            //   pinBoxColor: Theme.of(context).colorScheme.secondaryContainer,
            //   pinTextAnimatedSwitcherDuration: const Duration(milliseconds: 300),
            //   highlightAnimationBeginColor: Colors.black,
            //   highlightAnimationEndColor: Colors.white12,
            //   keyboardType: TextInputType.number,
            // ),
            // const SizedBox(
            //   height: 30,
            // ),
            CustomTextFormField(
              controller: username,
              read: false,
              maxlines: 1,
              obscureText: false,
              labelText: 'Username',
              inputformat: [
                FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]+')),
              ],
              maxlength: 50,
              oncomplete: () {
                FocusManager.instance.primaryFocus?.unfocus();
                if (username.text.toString().trim().isNotEmpty) {
                  checkForUsername();
                }
              },
              // onchanged: (val){
              //   if(isValidInput(val??"")){
              //     username.text = val?.replaceAll(' ', '')??"";
              //     username.value = TextEditingValue(
              //       text: username.text.replaceAll(' ', ''),
              //       selection: TextSelection.fromPosition(
              //         TextPosition(offset: username.text.length),
              //       ),
              //     );
              //     return val?.replaceAll(' ', '')??"";
              //   }else{
              //     username.text ="";
              //   return "";
              //   }
              // },
              fillColor: Theme.of(context).colorScheme.background,
              validator: Validator.notEmpty,
              keyboardType: TextInputType.visiblePassword,
            ),
            const SizedBox(
              height: 20,
            ),
            CustomTextFormField(
              controller: email,
              read: false,
              obscureText: false,
              maxlines: 1,
              maxlength: 50,
              oncomplete: () {
                FocusManager.instance.primaryFocus?.unfocus();
                if (email.text.toString().trim().isNotEmpty) {
                  checkForEmail();
                }
              },
              labelText: 'Email Address',
              fillColor: Theme.of(context).colorScheme.background,
              validator: Validator.validateEmail,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(
              height: 20,
            ),
            CustomTextFormField(
              controller: password,
              read: false,
              obscureText: hidePassword1,
              maxlines: 1,
              maxlength: 32,
              fillColor: Theme.of(context).colorScheme.background,
              labelText: 'Password',
              validator: Validator.validatePassword,
              keyboardType: TextInputType.text,
              onchanged: (p0) {
                if (p0.isEmpty) {
                  setState(() {
                    isPwdVisible = false;
                  });
                } else {
                  setState(() {
                    isPwdVisible = true;
                  });
                }
                return '';
              },
              suffixIcon: isPwdVisible
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          hidePassword1 = !hidePassword1;
                        });
                      },
                      icon: Icon(
                        !hidePassword1 ? Icons.visibility : Icons.visibility_off,
                        color: !hidePassword1 ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).colorScheme.secondaryContainer,
                        size: 20.0,
                      ),
                    )
                  : null,
            ),
            const SizedBox(
              height: 20,
            ),
            CustomTextFormField(
              controller: confrimpassword,
              read: false,
              maxlines: 1,
              maxlength: 32,
              fillColor: Theme.of(context).colorScheme.background,
              obscureText: hidePassword2,
              labelText: 'Confirm Password',
              validator: (val) {
                if (val!.trim().isEmpty) {
                  return "Please enter confirm password";
                } else if (val.trim() != password.text) {
                  return "Password Mismatch";
                }
                return null;
              },
              keyboardType: TextInputType.text,
              onchanged: (p0) {
                if (p0.isEmpty) {
                  setState(() {
                    isConfirmPwdVisible = false;
                  });
                } else {
                  setState(() {
                    isConfirmPwdVisible = true;
                  });
                }
                return '';
              },
              suffixIcon: isConfirmPwdVisible
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          hidePassword2 = !hidePassword2;
                        });
                      },
                      icon: Icon(
                        !hidePassword2 ? Icons.visibility : Icons.visibility_off,
                        color: !hidePassword2 ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).colorScheme.secondaryContainer,
                        size: 20.0,
                      ),
                    )
                  : null,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    labelText: '',
                    obscureText: false,
                    controller: countryCodeController,
                    read: true,
                    fillColor: Theme.of(context).colorScheme.background,
                    borderColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                ),
                const SizedBox(
                  width: 8.0,
                ),
                mobileNoLength! > 0
                    ? Expanded(
                        flex: 4,
                        child: CustomTextFormField(
                          controller: phone,
                          read: false,
                          obscureText: false,
                          maxlines: 1,
                          maxlength: mobileNoLength!,
                          oncomplete: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            if (phone.text.toString().trim().isNotEmpty) {
                              checkForMobileNo();
                            }
                          },
                          labelText: 'Phone Number',
                          fillColor: Theme.of(context).colorScheme.background,
                          validator: Validator.validateMobile,
                          inputformat: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          keyboardType: TextInputType.number,
                        ),
                      )
                    : Expanded(
                        flex: 4,
                        child: CustomTextFormField(
                          controller: phone,
                          read: false,
                          obscureText: false,
                          maxlines: 1,
                          maxlength: 10,
                          oncomplete: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            if (phone.text.toString().trim().isNotEmpty) {
                              checkForMobileNo();
                            }
                          },
                          labelText: 'Phone Number',
                          fillColor: Theme.of(context).colorScheme.background,
                          validator: Validator.validateMobile,
                          inputformat: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          keyboardType: TextInputType.number,
                        ),
                      ),
              ],
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
                      child: Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.onPrimary,
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
              fillColor: Theme.of(context).colorScheme.background,
              borderColor: Theme.of(context).colorScheme.primaryContainer,
              labelText: 'Referral Code',
              inputformat: [
                FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9 ]+')),
              ],
              maxlength: 8,
              maxlines: 1,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(
              height: 30,
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
                          .copyWith(
                              fontSize: 17.0,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onBackground),
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
                              .copyWith(
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
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
                              .copyWith(
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
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
                              .copyWith(
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget thirdForm() {
    return SingleChildScrollView(
      child: Form(
        key: hp.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            CustomTextFormField(
              controller: icNumber,
              read: false,
              obscureText: false,
              maxlines: 1,
              maxlength: 4,
              inputformat: [FilteringTextInputFormatter.digitsOnly],
              fillColor: Theme.of(context).colorScheme.background,
              borderColor: Theme.of(context).colorScheme.primaryContainer,
              labelText: 'IC Number (Last 4 Digits)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(
              height: 20,
            ),
            CustomTextFormField(
              controller: aboutyourself,
              read: false,
              obscureText: false,
              maxlines: 3,
              maxlength: 250,
              fillColor: Theme.of(context).colorScheme.background,
              borderColor: Theme.of(context).colorScheme.primaryContainer,
              labelText: 'About Yourself',
              keyboardType: TextInputType.text,
            ),
          ],
        ),
      ),
    );
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return const Color(0xFFD9D9D9);
    }
    return const Color(0xFFD9D9D9);
  }

  chipsWidget(SelectedFilterValues item) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        border: Border.all(color: Theme.of(context).colorScheme.onBackground),
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
      child: CustomTextView(
          textStyle: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.7),
                  fontSize: 13.0,
                  fontWeight: FontWeight.w400),
          label: item.activityName),
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
                      if (Constants.androidVersion >= 13) {
                        getPicFromGallery();
                      } else {
                        // final serviceStatus = await Permission.storage.isGranted;
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

  Future getPicFromCam() async {
    var pickedFile = await picker.pickImage(source: ImageSource.camera);
    Navigator.pop(context);
    setState(() async {
      if (pickedFile != null) {
        _cropImage(pickedFile);
        // final byte = (await pickedFile.readAsBytes()).lengthInBytes;
        // final kb = byte / 1024;
        // final mb = kb / 1024;
        // debugPrint("File size -> ${mb.toString()}");
        // if (mb < 10.0) {
        //   croppedFile = m;
        //   debugPrint("profile pic Camera-> $profilepic");
        //   final bytes = File(profilepic!.path).readAsBytesSync();
        //   String convertedBytes = base64Encode(bytes);
        //   debugPrint(convertedBytes);
        //   debugPrint(profilepic!.path);
        //   debugPrint(profilepic!.path.split('/').last);
        //   debugPrint(profilepic!.path.split('/').last.split('.')[1]);

        //   uploadFile(convertedBytes);
        // } else {
        //   showSnackBarErrorColor("Please select image below 10 MB", context, true);
        // }
      }
    });
  }

  Future getPicFromGallery() async {
    var pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);
    Navigator.pop(context);
    setState(() async {
      if (pickedFile != null) {
        _cropImage(pickedFile);
      }
    });
  }

  Future<void> _cropImage(XFile pickedFile) async {
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
      var byte = (await pickedFile.readAsBytes()).lengthInBytes;
      var kb = byte / 1024;
      var mb = kb / 1024;
      debugPrint("File size -> ${mb.toString()}");
      if (mb < 10.0) {
        croppedFile = mCroppedFile;
        setState(() {});
        debugPrint("profile pic gallery-> $croppedFile");
        var bytes = File(croppedFile!.path).readAsBytesSync();
        String convertedBytes = base64Encode(bytes);
        debugPrint(convertedBytes);
        debugPrint(croppedFile!.path);
        debugPrint(croppedFile!.path.split('/').last);
        debugPrint(croppedFile!.path.split('/').last.split('.')[1]);
        uploadFile(convertedBytes);
      } else {
        showSnackBarErrorColor("Please select image below 10 MB", context, true);
      }
    } else {
      setState(() {});
    }
  }

  Future<void> getAllCity() async {
    try {
      await _progressDialog.show();
      await Provider.of<EndUserRegistrationViewModel>(context, listen: false).getAllCities().then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            LocationSelectionResponseModel? locationSelectionResponseModel = LocationSelectionResponseModel.fromMap(jsonDecode(res.body));
            if (locationSelectionResponseModel!.Data!.isNotEmpty) {
              await _progressDialog.hide();
              setState(() {
                location = locationSelectionResponseModel.Data!;
              });
              getAllActivity();
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

  Future<void> checkForUsername() async {
    try {
      await _progressDialog.show();
      await Provider.of<EndUserRegistrationViewModel>(context, listen: false).checkUserNameExists(username.text.toString().trim()).then(
        (value) async {
          Response res = value;
          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            await _progressDialog.hide();
            String response = res.body;
            if (response == 'false') {
              setState(() {
                username.text = "";
              });
              showSnackBarColor('Username already taken', context, true);
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

  Future<void> checkForEmail() async {
    try {
      await _progressDialog.show();
      await Provider.of<EndUserRegistrationViewModel>(context, listen: false).checkEmailExists(email.text.toString().trim()).then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            await _progressDialog.hide();
            String response = res.body;
            if (response == 'false') {
              setState(() {
                email.text = "";
              });
              showSnackBarColor('Email-ID already in use', context, true);
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

  Future<void> checkForMobileNo() async {
    try {
      await _progressDialog.show();
      await Provider.of<EndUserRegistrationViewModel>(context, listen: false).checkForMobileNoExists(phone.text.toString().trim()).then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            await _progressDialog.hide();
            String response = res.body;
            if (response == 'false') {
              setState(() {
                phone.text = "";
              });
              showSnackBarColor('Phone number already in use', context, true);
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

  void checkFirstStepValidation() {
    if (formKey.currentState!.validate()) {
      // if (choosedlocation != null) {
        if ((referralCode.text.trim().isNotEmpty) && (!_isValid)) {
          showSnackBar('Referral code is invalid', context);
        } else {
          if (!termsAndCondition) {
            showSnackBar('Please Accept Terms & Conditions', context);
          } else {
            tempEndUserRegistrationApiCall();
          }
        }
      // } else {
      //   showSnackBarColor('Please select city', context, true);
      // }
    }
  }

  void onContinue() {
    setState(() {
      if (_currentStep < _steps().length - 1) {
        _currentStep += 1;
      } else {
        // _currentStep = 0;

        // if verify otp success, call third step API
        // ensures that the step is 2nd step (Verify)
        if (_currentStep == 1) {
          endUserRegistration();
        }
      }
    });
  }

  // void checkForSelectedCity() {
  //   List<DataBean> selectedCityList = location!.where((element) => element.CountryName == choosedlocation).toList();
  //   selectedCityId = selectedCityList[0].CityId;
  //   countryCode = selectedCityList[0].CountryCode;
  //   debugPrint('selected City ID : $selectedCityId');
  // }

  Future<void> tempEndUserRegistrationApiCall() async {
    EndUserRegistrationTempReqModel endUserRegistrationTempReqModel = EndUserRegistrationTempReqModel();
    endUserRegistrationTempReqModel.regServiceProviderId = null;
    endUserRegistrationTempReqModel.registrationType = 'E';
    endUserRegistrationTempReqModel.firstName = firstNameController.text.toString().trim();
    endUserRegistrationTempReqModel.lastName = lastNameController.text.toString().trim();
    endUserRegistrationTempReqModel.cityId = int.parse(selectedCityID!);
    // if (postalcode.text.toString().trim().isNotEmpty) {
    //   endUserRegistrationTempReqModel.pinCode = postalcode.text.toString().trim();
    // } else {
      endUserRegistrationTempReqModel.pinCode = null;
    // }
    endUserRegistrationTempReqModel.userName = username.text.toString().trim();
    endUserRegistrationTempReqModel.email = email.text.toString().trim();
    endUserRegistrationTempReqModel.password = password.text.toString().trim();
    endUserRegistrationTempReqModel.confirmPassword = confrimpassword.text.toString().trim();
    endUserRegistrationTempReqModel.mobileNumber = phone.text.toString().trim();
    endUserRegistrationTempReqModel.uenRegistrationNo = null;
    endUserRegistrationTempReqModel.establishmentYear = null;
    endUserRegistrationTempReqModel.otherDescription = null;

    debugPrint(endUserRegistrationTempReqModel.toJson().toString());

    try {
      await _progressDialog.show();
      await Provider.of<EndUserRegistrationViewModel>(context, listen: false).tempEnduserRegistration(endUserRegistrationTempReqModel.toJson()).then(
        (value) async {
          Response res = value;
          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            String response = res.body;
            tempRegistrationNumber = int.parse(response);
            await _progressDialog.hide();
            if (response.isNotEmpty) {
              sendOTP(response, "f");
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

  Future<void> sendOTP(String number, String type) async {
    try {
      await _progressDialog.show();
      await Provider.of<EndUserRegistrationViewModel>(context, listen: false).sendSMSOtp(number).then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            await _progressDialog.hide();
            String response = res.body;
            if (response.isNotEmpty) {
              sendEmailOtp(number, type);
              if (type == "s") {
                otp.clear();
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

  Future<void> sendEmailOtp(String number, String type) async {
    try {
      await _progressDialog.show();
      await Provider.of<EndUserRegistrationViewModel>(context, listen: false).sendEmailOtp(number).then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            await _progressDialog.hide();
            String response = res.body;
            debugPrint('Email Response -> $response');
            showSnackBarColor('OTP Sent Successfully', context, false);
            if (type == "f") {
              onContinue();
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

  Future<void> verifyOTP() async {
    if (otp.text.toString().trim().length < 6) {
      showSnackBar('6 digit OTP required', context);
    } else {
      Map otpVerifyRequest = {};
      otpVerifyRequest['serviceProviderId'] = tempRegistrationNumber;
      otpVerifyRequest['mobileNumber'] = phone.text.toString().trim();
      otpVerifyRequest['emailAddress'] = email.text.toString().trim();
      otpVerifyRequest['otpText'] = otp.text.toString().trim();

      try {
        await _progressDialog.show();
        await Provider.of<EndUserRegistrationViewModel>(context, listen: false).otpVerification(otpVerifyRequest).then(
          (value) async {
            Response res = value;

            if (res.statusCode == 500 || res.statusCode == 404) {
              await _progressDialog.hide();
              showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
            } else if (res.statusCode == 200) {
              await _progressDialog.hide();
              OtpVerificationResponse? response = OtpVerificationResponse.fromMap(jsonDecode(res.body));
              if (response!.IsSuccess!) {
                // showSnackBarColor(response.Message!, context, false);
                onContinue();
              } else {
                await _progressDialog.hide();
                showSnackBarColor(response.Message!, context, true);
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

  void lastStepValidation() {
    if (hp.formKey.currentState!.validate()) {
      if (icNumber.text.toString().trim().isNotEmpty && icNumber.text.toString().trim().length < 4) {
        showSnackBarColor('4 digit IC Number is required', context, true);
      } else if (!termsAndCondition) {
        showSnackBar('Please Accept Terms & Conditions', context);
      } else {
        endUserRegistration();
      }
    }
  }

  Future<void> uploadFile(String base64File) async {
    await _progressDialog.show();
    Map uploadFileRequest = {};
    uploadFileRequest['FileStorageId'] = null;
    uploadFileRequest['FileName'] = croppedFile!.path.split('/').last;
    uploadFileRequest['FileExtension'] = croppedFile!.path.split('/').last.split('.')[1];
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
            uploadedFileId = uploadFileResponse.FileStorageId.toString();
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

  Future<void> endUserRegistration() async {
    await _progressDialog.show();
    Map endUseRegisterRequest = {};
    endUseRegisterRequest['EndUserId'] = '';
    endUseRegisterRequest['RegServiceProviderId'] = tempRegistrationNumber;
    endUseRegisterRequest['UserId'] = '';
    endUseRegisterRequest['FirstName'] = firstNameController.text.toString().trim();
    endUseRegisterRequest['LastName'] = lastNameController.text.toString().trim();
    endUseRegisterRequest['IcNo'] = icNumber.text.toString().trim();
    endUseRegisterRequest['AboutYourSelf'] = aboutyourself.text.toString().trim();
    endUseRegisterRequest['ProfileImageId'] = uploadedFileId;
    endUseRegisterRequest['IsProfilePrivate'] = makeProfilePrivate;
    endUseRegisterRequest['IsActive'] = true;
    endUseRegisterRequest['Status'] = "A";
    endUseRegisterRequest['IsTermsAccepted'] = termsAndCondition;
    endUseRegisterRequest['Others'] = otherTextController.text.toString().trim();

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

    List<Map> passingMap = [];
    for (int i = 0; i < data.length; i++) {
      Map map = {};
      map['EndUserSubActivityId'] = '';
      map['EndUserId'] = '';
      map['SubActivityId'] = data[i];
      passingMap.add(map);
    }

    debugPrint(passingMap.toString());

    endUseRegisterRequest['EndUserSubActivityDtos'] = passingMap;
    endUseRegisterRequest['ReferrerCode'] = referralCode.text.toString().trim();
    debugPrint(endUseRegisterRequest.toString());
    debugPrint(json.encode(endUseRegisterRequest));

    try {
      await Provider.of<EndUserRegistrationViewModel>(context, listen: false).endUserRegister(endUseRegisterRequest).then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            await _progressDialog.hide();
            String response = res.body;
            debugPrint('enduser register response -> $response');
            showSnackBarColor('Registration successful', context, false);
            await Navigator.pushNamedAndRemoveUntil(context, Constants.LOGIN, (r) => false);
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

  bool isValidInput(String input) {
    RegExp regex = RegExp(r'^[a-zA-Z0-9 ]+');
    return regex.hasMatch(input);
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
}

class SecondSignupPage extends StatelessWidget {
  final TextEditingController phone;
  final TextEditingController otp;
  final VoidCallback onTap;
  final VoidCallback resend;

  const SecondSignupPage({super.key, required this.phone, required this.otp, required this.onTap, required this.resend});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 20.0,
          ),
          Image.asset(
            "assets/images/otp_img.png",
            width: 300.0,
            height: 300.0,
            fit: BoxFit.contain,
          ),
          const SizedBox(
            height: 30,
          ),
          CustomTextView(
            label: 'An OTP is sent to your number via SMS.',
            type: styleSubTitle,
            textStyle: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 17.0,
                    fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 40,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: CustomTextView(
              label: 'Phone Number',
              textStyle:
                  Theme.of(context).textTheme.titleMedium!.copyWith(color: const Color.fromRGBO(129, 129, 129, 1), fontWeight: FontWeight.w400, fontSize: 17.0),
            ),
          ),
          CustomEditText(
            controller: phone,
            isReadOnly: true,
            autoFocus: false,
            decoration: const InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color.fromRGBO(0, 101, 144, 0.53)),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color.fromRGBO(0, 101, 144, 0.53)),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: CustomTextView(
              label: 'Enter OTP',
              type: styleSubTitle,
              textStyle:
                  Theme.of(context).textTheme.bodyLarge!.copyWith(color: const Color.fromRGBO(129, 129, 129, 1), fontWeight: FontWeight.w400, fontSize: 17.0),
            ),
          ),
          PinCodeTextField(
            pinBoxHeight: 55,
            pinBoxWidth: MediaQuery.of(context).size.width / 8,
            pinBoxRadius: 5,
            autofocus: false,
            controller: otp,
            hideCharacter: false,
            highlight: true,
            highlightColor: const Color.fromRGBO(0, 101, 144, 1),
            defaultBorderColor: const Color.fromRGBO(0, 101, 144, 1),
            hasTextBorderColor: const Color.fromRGBO(0, 101, 144, 1),
            errorBorderColor: Colors.red,
            maxLength: 6,
            hasError: false,
            maskCharacter: "*",
            onTextChanged: (text) {},
            onDone: (text) async {
              FocusManager.instance.primaryFocus?.unfocus();
              debugPrint('done call');
            },
            wrapAlignment: WrapAlignment.spaceEvenly,
            pinBoxDecoration: ProvidedPinBoxDecoration.underlinedPinBoxDecoration,
            pinTextStyle: TextStyle(
                fontSize: 25.0,
                color: Theme.of(context).colorScheme.onBackground),
            pinTextAnimatedSwitcherTransition: ProvidedPinBoxTextAnimation.scalingTransition,
            pinBoxColor: Theme.of(context).colorScheme.primary,
            pinTextAnimatedSwitcherDuration: const Duration(milliseconds: 100),
            //                    highlightAnimation: true,
            //highlightPinBoxColor: Colors.red,
            highlightAnimationBeginColor:
                Theme.of(context).colorScheme.onBackground,
            highlightAnimationEndColor:
                Theme.of(context).colorScheme.onBackground.withOpacity(0.07),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(
            height: 40,
          ),
          MyButton(
              text: "Verify",
              textcolor: Theme.of(context).colorScheme.onBackground,
              textsize: 16.0,
              fontWeight: FontWeight.w600,
              letterspacing: 0.7,
              buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
              buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
              buttonheight: 60,
              buttonwidth: MediaQuery.of(context).size.width,
              radius: 15,
              onTap: onTap),
          const SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextView(
                label: 'Didn’t receive an OTP? ',
                type: styleSubTitle,
                textStyle:
                    Theme.of(context).textTheme.bodyLarge!.copyWith(color: const Color.fromRGBO(129, 129, 129, 1), fontWeight: FontWeight.w400, fontSize: 18.0),
              ),
              GestureDetector(
                onTap: resend,
                child: CustomTextView(
                  label: 'Resend OTP',
                  type: styleSubTitle,
                  textStyle:
                      Theme.of(context).textTheme.bodyLarge!.copyWith(color: const Color.fromRGBO(0, 101, 144, 1), fontWeight: FontWeight.w400, fontSize: 18.0),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}
