import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/model/otp_verification_response.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_edit_text.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import '../../../helper/helpers.dart';
import '../../../model/common_passing_args.dart';
import '../../../theme/oqdo_theme_data.dart';
import '../../../viewmodels/end_user_resgistration_view_model.dart';

class FacilityOTPPage extends StatefulWidget {
  final CommonPassingArgs commonPassingArgs;

  const FacilityOTPPage(this.commonPassingArgs, {super.key});

  @override
  _FacilityOTPPageState createState() => _FacilityOTPPageState(commonPassingArgs);
}

class _FacilityOTPPageState extends State<FacilityOTPPage> {
  MediaQueryData get dimensions => MediaQuery.of(context);
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  TextEditingController phone = TextEditingController();
  TextEditingController otp = TextEditingController();
  late Helper hp;

  final CommonPassingArgs _commonPassingArgs;
  late ProgressDialog _progressDialog;

  _FacilityOTPPageState(this._commonPassingArgs);

  @override
  void initState() {
    super.initState();
    hp = Helper.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(message: "Please wait..");
    });
  }

  @override
  Widget build(BuildContext context) {
    var ph = MediaQuery.of(context).size.height;
    phone.text = _commonPassingArgs.mobileNo!;
    return Scaffold(
      backgroundColor: OQDOThemeData.backgroundColor,
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.only(top: 30.0, left: 30, right: 30, bottom: 0.0),
        child: Form(
          key: hp.formKey,
          child: SingleChildScrollView(
            reverse: true,
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
                  textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: OQDOThemeData.dividerColor, fontSize: 17.0, fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 40,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: CustomTextView(
                    label: 'Phone Number',
                    textStyle: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: const Color.fromRGBO(129, 129, 129, 1), fontWeight: FontWeight.w400, fontSize: 17.0),
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
                    textStyle: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: const Color.fromRGBO(129, 129, 129, 1), fontWeight: FontWeight.w400, fontSize: 17.0),
                  ),
                ),
                PinCodeTextField(
                  pinBoxHeight: 55,
                  pinBoxWidth: MediaQuery.of(context).size.width / 8,
                  pinBoxRadius: 5,
                  autofocus: true,
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
                  onDone: (text) async {},
                  wrapAlignment: WrapAlignment.spaceEvenly,
                  pinBoxDecoration: ProvidedPinBoxDecoration.underlinedPinBoxDecoration,
                  pinTextStyle: const TextStyle(fontSize: 25.0, color: Colors.black),
                  pinTextAnimatedSwitcherTransition: ProvidedPinBoxTextAnimation.scalingTransition,
                  pinBoxColor: Theme.of(context).colorScheme.primary,
                  pinTextAnimatedSwitcherDuration: const Duration(milliseconds: 300),
                  //                    highlightAnimation: true,
                  //highlightPinBoxColor: Colors.red,
                  highlightAnimationBeginColor: Colors.black,
                  highlightAnimationEndColor: Colors.white12,
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
                    onTap: () {
                      varifyOTP();
                    }),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTextView(
                      label: 'Didn’t receive an OTP? ',
                      type: styleSubTitle,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: const Color.fromRGBO(129, 129, 129, 1), fontWeight: FontWeight.w400, fontSize: 18.0),
                    ),
                    GestureDetector(
                      onTap: () {
                        // print('click');
                        sendOTP(widget.commonPassingArgs.tempRegisterId!.toString());
                      },
                      child: CustomTextView(
                        label: 'Resend OTP',
                        type: styleSubTitle,
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(color: const Color.fromRGBO(0, 101, 144, 1), fontWeight: FontWeight.w400, fontSize: 18.0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
            await progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            await progressDialog.hide();
            String response = res.body;
            if (response.isNotEmpty) {
              sendEmailOtp(number);
              otp.clear();
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

  Future<void> sendEmailOtp(String number) async {
    ProgressDialog progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    progressDialog.style(message: "Please wait..");

    try {
      await progressDialog.show();
      await Provider.of<EndUserRegistrationViewModel>(context, listen: false).sendEmailOtp(number).then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            await progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            await progressDialog.hide();
            String response = res.body;
            // print('Email Response -> $response');
            if (response.isNotEmpty) {
              showSnackBarColor('OTP Sent Successfully', context, false);
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

  Future<void> varifyOTP() async {
    ProgressDialog progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    progressDialog.style(message: "Please wait..");
    if (otp.text.toString().trim().length < 6) {
      showSnackBar('Please enter OTP', context);
    } else {
      Map otpVerifyRequest = {};
      otpVerifyRequest['serviceProviderId'] = _commonPassingArgs.tempRegisterId;
      otpVerifyRequest['mobileNumber'] = phone.text.toString().trim();
      otpVerifyRequest['emailAddress'] = null;
      otpVerifyRequest['otpText'] = otp.text.toString().trim();

      try {
        await progressDialog.show();
        await Provider.of<EndUserRegistrationViewModel>(context, listen: false).otpVerification(otpVerifyRequest).then(
          (value) async {
            Response res = value;

            if (res.statusCode == 500 || res.statusCode == 404) {
              await progressDialog.hide();
              showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
            } else if (res.statusCode == 200) {
              await progressDialog.hide();
              OtpVerificationResponse? response = OtpVerificationResponse.fromMap(jsonDecode(res.body));
              if (response!.IsSuccess!) {
                showSnackBarColor('OTP Verified', context, false);
                Navigator.of(context).pushNamed(Constants.FACILITYADDONE, arguments: _commonPassingArgs);
              } else {
                showSnackBarColor(response.Message!, context, true);
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
}
