// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/model/common_passing_args.dart';
import 'package:oqdo_mobile_app/model/forgot_password_response_model.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:oqdo_mobile_app/viewmodels/login_view_model.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class ForgotOTPVerificationPage extends StatefulWidget {
  ForgotOTPVerificationPage({super.key, required this.email});

  String email;

  @override
  ForgotOTPVerificationPageState createState() => ForgotOTPVerificationPageState();
}

class ForgotOTPVerificationPageState extends State<ForgotOTPVerificationPage> {
  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  TextEditingController otpController = TextEditingController();
  bool hasError = false;
  late ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(message: "Please wait..");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).colorScheme.onBackground,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.topLeft,
                children: [
                  Image.asset("assets/images/login_bg.png"),
                  Positioned(
                    top: 100,
                    left: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          "assets/images/logo.png",
                          height: 90,
                          width: 120,
                        ),
                        // const Text(
                        //   'Welcome',
                        //   style: TextStyle(
                        //       fontSize: 24,
                        //       fontWeight: FontWeight.w400,
                        //       color: Color(0xff595959)),
                        // ),
                        // const Text(
                        //   'Back!',
                        //   style: TextStyle(
                        //       fontSize: 24,
                        //       fontWeight: FontWeight.w400,
                        //       color: Color(0xff595959)),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomTextView(
                      label: 'Verification',
                      type: styleSubTitle,
                      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    CustomTextView(
                      label: 'Please enter OTP sent to your mail.',
                      type: styleSubTitle,
                      textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.shadow),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: CustomTextView(
                        label: 'Enter OTP',
                        type: styleSubTitle,
                        textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.shadow),
                      ),
                    ),
                    PinCodeTextField(
                      pinBoxHeight: 55,
                      pinBoxWidth: width / 8.0,
                      pinBoxRadius: 5,
                      autofocus: true,
                      controller: otpController,
                      // hideCharacter: true,
                      highlight: true,
                      highlightColor: Theme.of(context).colorScheme.secondaryContainer,
                      defaultBorderColor: Theme.of(context).colorScheme.secondaryContainer,
                      hasTextBorderColor: Theme.of(context).colorScheme.secondaryContainer,
                      errorBorderColor: Colors.red,
                      maxLength: 6,
                      hasError: hasError,
                      // maskCharacter: "*",
                      // //😎
                      onTextChanged: (text) {},
                      onDone: (text) async {},
                      wrapAlignment: WrapAlignment.spaceEvenly,
                      pinBoxDecoration: ProvidedPinBoxDecoration.underlinedPinBoxDecoration,
                      pinTextStyle: const TextStyle(fontSize: 25.0, color: Colors.black),
                      pinTextAnimatedSwitcherTransition: ProvidedPinBoxTextAnimation.scalingTransition,
                      pinBoxColor: Theme.of(context).colorScheme.secondaryContainer,
                      pinTextAnimatedSwitcherDuration: const Duration(milliseconds: 300),
                      //                    highlightAnimation: true,
                      //highlightPinBoxColor: Colors.red,
                      highlightAnimationBeginColor: Colors.black,
                      highlightAnimationEndColor: Colors.white12,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    MyButton(
                      text: "Verify",
                      textcolor: Theme.of(context).colorScheme.onBackground,
                      textsize: 16,
                      fontWeight: FontWeight.w600,
                      letterspacing: 0.7,
                      buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                      buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                      buttonheight: 50,
                      buttonwidth: width,
                      radius: 15,
                      onTap: () async {
                        if (otpController.text.isEmpty) {
                          showSnackBar("Please enter OTP", context);
                        } else if (otpController.text.length < 6) {
                          showSnackBar("Please enter valid OTP", context);
                        } else {
                          await verifyForgotPasswordOTP(email: widget.email, otp: otpController.text);
                        }
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomTextView(
                          label: 'If you did not receive the code, ',
                          type: styleSubTitle,
                          textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.shadow),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            resendOTP(email: widget.email);
                          },
                          child: CustomTextView(
                            label: 'Resend.',
                            type: styleSubTitle,
                            textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.secondaryContainer),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> verifyForgotPasswordOTP({required String email, required String otp}) async {
    await _progressDialog.show();
    try {
      await Provider.of<LoginViewModel>(context, listen: false).verifyForgotPasswordOTP(email: email, otp: otp).then((value) async {
        Response res = value;
        await _progressDialog.hide();
        if (res.statusCode == 500 || res.statusCode == 404) {
          showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
        } else if (res.statusCode == 200) {
          ForgotPasswordResponseModel forgotPasswordResponse = ForgotPasswordResponseModel.fromJson(jsonDecode(res.body));
          if (forgotPasswordResponse.success == true) {
            showSnackBarColor(forgotPasswordResponse.message ?? "OTP verified", context, false);
            var arguments = EmailOTPModel(email, otp);
            await Navigator.pushNamed(context, Constants.CREATEPASSWORD, arguments: arguments);
          } else {
            showSnackBarColor(
                forgotPasswordResponse.message ?? "We're unable to connect to server. Please contact administrator or try after some time", context, true);
          }
        } else {
          Map<String, dynamic> errorModel = jsonDecode(res.body);
          if (errorModel.containsKey('error_description')) {
            showSnackBarColor(errorModel['error_description'], context, true);
          }
        }
      });
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

  Future<void> resendOTP({required String email}) async {
    await _progressDialog.show();

    try {
      await Provider.of<LoginViewModel>(context, listen: false).requestForgotPassword(email: email).then((value) async {
        Response res = value;
        await _progressDialog.hide();
        if (res.statusCode == 500 || res.statusCode == 404) {
          showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
        } else if (res.statusCode == 200) {
          ForgotPasswordResponseModel forgotPasswordResponse = ForgotPasswordResponseModel.fromJson(jsonDecode(res.body));
          if (forgotPasswordResponse.success == true) {
            otpController.clear();
            showSnackBarColor(forgotPasswordResponse.message ?? "OTP Resent Successfully", context, false);
          } else {
            showSnackBarColor(
                forgotPasswordResponse.message ?? "We're unable to connect to server. Please contact administrator or try after some time", context, true);
          }
        } else {
          Map<String, dynamic> errorModel = jsonDecode(res.body);
          if (errorModel.containsKey('error_description')) {
            showSnackBarColor(errorModel['error_description'], context, true);
          }
        }
      });
    } on NoConnectivityException catch (_) {
      _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      _progressDialog.hide();
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }
}
