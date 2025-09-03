// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/helper/helpers.dart';
import 'package:oqdo_mobile_app/model/common_passing_args.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/textfields_widget.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import '../../../model/location_selection_response_model.dart';
import '../../../oqdo_application.dart';
import '../../../request_models/end_user_registration_temp_req_model.dart';
import '../../../utils/string_manager.dart';
import '../../../utils/validator.dart';
import '../../../viewmodels/end_user_resgistration_view_model.dart';

class FacilityAddPage extends StatefulWidget {
  const FacilityAddPage({super.key});

  @override
  FacilityAddPageState createState() => FacilityAddPageState();
}

class FacilityAddPageState extends State<FacilityAddPage> {
  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  TextEditingController fullName = TextEditingController();
  TextEditingController postalcode = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confrimpassword = TextEditingController();
  TextEditingController phone = TextEditingController();
  late Helper hp;
  List<DataBean>? location = [];
  String? choosedlocation;
  int? selectedCityId;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late ProgressDialog _progressDialog;
  int? tempRegistrationNumber;
  String? countryCode = '';
  String? selectedCityCountryCode = '';
  String? selectedCityID = '';
  TextEditingController countryCodeController = TextEditingController();
  String? mobileNoLengthStr = '';
  int? mobileNoLength = 0;
  bool hidePassword1 = true;
  bool hidePassword2 = true;

  CommonPassingArgs commonPassingArgs = CommonPassingArgs();
  bool isPwdVisible = false;
  bool isConfirmPwdVisible = false;

  @override
  void initState() {
    super.initState();
    hp = Helper.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(message: "Please wait..");
      // getAllCity();
      getShredPrefValues();
    });
  }

  void getShredPrefValues() async {
    choosedlocation = OQDOApplication.instance.storage.getStringValue(AppStrings.selectedCountryName);
    selectedCityCountryCode = OQDOApplication.instance.storage.getStringValue(AppStrings.selectedCountryCode);
    selectedCityID = OQDOApplication.instance.storage.getStringValue(AppStrings.selectedCountryID);
    debugPrint(choosedlocation);
    mobileNoLengthStr = OQDOApplication.instance.storage.getStringValue(AppStrings.mobileNoLength);
    mobileNoLength = int.parse(mobileNoLengthStr!);
    countryCodeController.text = selectedCityCountryCode!;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: OQDOThemeData.backgroundColor,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Form(
                key: formKey,
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
                        label: 'Facility',
                        type: styleSubTitle,
                        textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontSize: 22.0,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF006590),
                            ),
                      ),
                    ),
                    const Divider(
                      thickness: 3,
                      color: Color.fromRGBO(0, 101, 144, 0.78),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomTextFormField(
                      controller: fullName,
                      read: false,
                      obscureText: false,
                      maxlines: 1,
                      maxlength: 50,
                      inputformat: [
                        FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9_ ]+')),
                      ],
                      fillColor: OQDOThemeData.backgroundColor,
                      labelText: 'Facility Name',
                      validator: Validator.notEmpty,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: CustomTextView(
                        label: 'Select City',
                        textStyle: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: const Color.fromRGBO(129, 129, 129, 1), fontWeight: FontWeight.w600, fontSize: 17.0),
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
                        borderRadius: BorderRadius.circular(15),
                        color: OQDOThemeData.backgroundColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: DropdownButton<dynamic>(
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: OQDOThemeData.dividerColor),
                            dropdownColor: Theme.of(context).colorScheme.onBackground,
                            underline: const SizedBox(),
                            borderRadius: BorderRadius.circular(15),
                            hint: CustomTextView(
                              label: choosedlocation ?? "City",
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: OQDOThemeData.dividerColor),
                            ),
                            value: choosedlocation,
                            items: location!.map((country) {
                              return DropdownMenuItem(
                                value: country.CountryName,
                                child: CustomTextView(
                                  label: country.CountryName!,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: OQDOThemeData.dividerColor),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              debugPrint('Selected city : - $value');
                              SchedulerBinding.instance.addPostFrameCallback((_) {
                                setState(() {
                                  choosedlocation = value;
                                });
                                checkForSelectedCity();
                              });
                            }),
                      ),
                    ),
                    // const SizedBox(
                    //   height: 20.0,
                    // ),
                    // Align(
                    //   alignment: Alignment.topLeft,
                    //   child: CustomTextView(
                    //     label: 'Postal Code',
                    //     type: styleSubTitle,
                    //     textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: const Color.fromRGBO(129, 129, 129, 1), fontWeight: FontWeight.w400, fontSize: 16.0),
                    //   ),
                    // ),
                    // PinCodeTextField(
                    //   pinBoxHeight: 55,
                    //   pinBoxWidth: width / 7.5,
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
                    //   //😎
                    //   onTextChanged: (text) {},
                    //   onDone: (text) async {},
                    //   wrapAlignment: WrapAlignment.spaceEvenly,
                    //   pinBoxDecoration: ProvidedPinBoxDecoration.underlinedPinBoxDecoration,
                    //   pinTextStyle: const TextStyle(fontSize: 35.0, color: Colors.black),
                    //   pinTextAnimatedSwitcherTransition: ProvidedPinBoxTextAnimation.scalingTransition,
                    //   pinBoxColor: Theme.of(context).colorScheme.secondaryContainer,
                    //   pinTextAnimatedSwitcherDuration: const Duration(milliseconds: 300),
                    //   //                    highlightAnimation: true,
                    //   //highlightPinBoxColor: Colors.red,
                    //   highlightAnimationBeginColor: Colors.black,
                    //   highlightAnimationEndColor: Colors.white12,
                    //   keyboardType: TextInputType.number,
                    // ),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomTextFormField(
                      controller: username,
                      read: false,
                      obscureText: false,
                      labelText: 'Username',
                      maxlines: 1,
                      maxlength: 50,
                      inputformat: [
                        FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]+')),
                      ],
                      oncomplete: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        if (username.text.toString().trim().isNotEmpty) {
                          checkForUsername();
                        }
                      },
                      fillColor: OQDOThemeData.backgroundColor,
                      validator: Validator.notEmpty,
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    const SizedBox(
                      height: 30,
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
                      fillColor: OQDOThemeData.backgroundColor,
                      labelText: 'Email Address',
                      validator: Validator.validateEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomTextFormField(
                      controller: password,
                      read: false,
                      obscureText: hidePassword1,
                      labelText: 'Password',
                      maxlines: 1,
                      maxlength: 32,
                      fillColor: OQDOThemeData.backgroundColor,
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
                      height: 30,
                    ),
                    CustomTextFormField(
                      controller: confrimpassword,
                      read: false,
                      obscureText: hidePassword2,
                      maxlines: 1,
                      maxlength: 32,
                      fillColor: OQDOThemeData.backgroundColor,
                      labelText: 'Confirm Password',
                      validator: (val) {
                        if (val!.trim().isEmpty) {
                          return "Please enter confirm password";
                        } else if (val.trim() != password.text) {
                          return "Password Mismatch";
                        }
                        return null;
                      },
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
                      keyboardType: TextInputType.text,
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
                      height: 30,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomTextFormField(labelText: '', obscureText: false, controller: countryCodeController, read: true),
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
                                  validator: (val) {
                                    if (val!.trim().isEmpty) {
                                      return "Please enter the phone number";
                                    } else if (phone.text.length != mobileNoLength) {
                                      return 'Enter valid phone number';
                                    }
                                    return null;
                                  },
                                  labelText: 'Phone Number',
                                  fillColor: OQDOThemeData.backgroundColor,
                                  // validator: Validator.validateMobile,
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
                                  maxlength: mobileNoLength == 8 ? 8 : 10,
                                  oncomplete: () {
                                    FocusManager.instance.primaryFocus?.unfocus();
                                    if (phone.text.toString().trim().isNotEmpty) {
                                      checkForMobileNo();
                                    }
                                  },
                                  validator: (val) {
                                    if (val!.trim().isEmpty) {
                                      return "Please enter the phone number";
                                    } else if (phone.text.length != mobileNoLength) {
                                      return 'Enter valid phone number';
                                    }
                                    return null;
                                  },
                                  labelText: 'Phone Number',
                                  fillColor: OQDOThemeData.backgroundColor,
                                  // validator: Validator.validateMobile,
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
                      height: 40,
                    ),
                    MyButton(
                      text: "Continue",
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
                        if (formKey.currentState!.validate()) {
                          checkForValidation();
                        }
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

  void checkForSelectedCity() {
    List<DataBean> selectedCityList = location!.where((element) => element.CountryName == choosedlocation).toList();
    commonPassingArgs.selectedCityDetails = selectedCityList;
    selectedCityId = selectedCityList[0].CityId;
    countryCode = selectedCityList[0].CountryCode;
    debugPrint('selected City ID : $selectedCityId');
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
            var response = jsonDecode(res.body);
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
          String response = res.body;
          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            await _progressDialog.hide();
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
            String response = res.body;
            await _progressDialog.hide();
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

  Future<void> tempEndUserRegistrationApiCall() async {
    EndUserRegistrationTempReqModel endUserRegistrationTempReqModel = EndUserRegistrationTempReqModel();
    endUserRegistrationTempReqModel.regServiceProviderId = null;
    endUserRegistrationTempReqModel.registrationType = 'F';
    endUserRegistrationTempReqModel.firstName = fullName.text.toString().trim();
    endUserRegistrationTempReqModel.lastName = fullName.text.toString().trim();
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
    ProgressDialog progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    progressDialog.style(message: "Please wait..");

    try {
      await progressDialog.show();
      await Provider.of<EndUserRegistrationViewModel>(context, listen: false).tempEnduserRegistration(endUserRegistrationTempReqModel.toJson()).then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            progressDialog.hide().whenComplete(() => {});
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            String response = res.body;
            tempRegistrationNumber = int.parse(response);
            progressDialog.hide().whenComplete(() => {});
            if (response.isNotEmpty) {
              commonPassingArgs.mobileNo = phone.text.toString().trim();
              commonPassingArgs.emilID = email.text.toString().trim();
              commonPassingArgs.tempRegisterId = int.parse(response);
              commonPassingArgs.facilityName = fullName.text.toString().trim();
              sendOTP(response);
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

  Future<void> sendOTP(String number) async {
    ProgressDialog progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    progressDialog.style(message: "Please wait..");
    try {
      await progressDialog.show();
      await Provider.of<EndUserRegistrationViewModel>(context, listen: false).sendSMSOtp(number).then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            await progressDialog.hide().whenComplete(() => {});
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            String response = res.body;
            await progressDialog.hide().whenComplete(() => {});
            if (response.isNotEmpty) {
              sendEmailOtp(number);
            }
          } else {
            await progressDialog.hide().whenComplete(() => {});
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
      await progressDialog.hide().whenComplete(() => {});
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      await progressDialog.hide().whenComplete(() => {});
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      await progressDialog.hide().whenComplete(() => {});
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      await progressDialog.hide().whenComplete(() => {});
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  Future<void> sendEmailOtp(String number) async {
    ProgressDialog progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    progressDialog.style(message: "Please wait..");

    try {
      await progressDialog.show();
      await Provider.of<EndUserRegistrationViewModel>(context, listen: false).sendEmailOtp(number).then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            progressDialog.hide().whenComplete(() => {});
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            await progressDialog.hide();
            String response = res.body;
            debugPrint('Email Response -> $response');
            if (response.isNotEmpty) {
              showSnackBarColor('OTP Sent Successfully', context, false);
              Navigator.of(context).pushNamed(Constants.FACILITYOTP, arguments: commonPassingArgs);
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

  void checkForValidation() {
    if (choosedlocation != null) {
      tempEndUserRegistrationApiCall();
    } else {
      showSnackBarColor('Please select city', context, true);
    }
  }
}
