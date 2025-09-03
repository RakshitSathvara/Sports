// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/model/forgot_password_response_model.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:oqdo_mobile_app/utils/textfields_widget.dart';
import 'package:oqdo_mobile_app/utils/validator.dart';
import 'package:oqdo_mobile_app/viewmodels/login_view_model.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ForgotPasswordPageState createState() => ForgotPasswordPageState();
}

class ForgotPasswordPageState extends State<ForgotPasswordPage> {
  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  TextEditingController emailController = TextEditingController();
  bool isVisible = true;
  late ProgressDialog _progressDialog;
  final _formKey = GlobalKey<FormState>();

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
          child: Form(
            key: _formKey,
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
                        label: 'Forgot Password',
                        type: styleSubTitle,
                        textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      CustomTextView(
                        label: 'Please enter your email for OTP.',
                        type: styleSubTitle,
                        textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.shadow),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextFormField(
                        controller: emailController,
                        read: false,
                        obscureText: false,
                        maxlines: 1,
                        labelText: 'Email Address',
                        validator: Validator.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      MyButton(
                        text: "Send OTP",
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
                          if (_formKey.currentState!.validate()) {
                            await requestForgotPassword(email: emailController.text);
                          }
                        },
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
      ),
    );
  }

  Future<void> requestForgotPassword({required String email}) async {
    await _progressDialog.show();
    try {
      await Provider.of<LoginViewModel>(context, listen: false).requestForgotPassword(email: email).then((value) async {
        Response res = value;
        await _progressDialog.hide();
        if (res.statusCode == 500 || res.statusCode == 404) {
          showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
        } else if (res.statusCode == 200) {
          await _progressDialog.hide();
          ForgotPasswordResponseModel forgotPasswordResponseModel = ForgotPasswordResponseModel.fromJson(jsonDecode(res.body));
          if (forgotPasswordResponseModel.success == true) {
            showSnackBarColor(forgotPasswordResponseModel.message ?? "OTP sent to your email and mobile number", context, false);
            await Navigator.pushNamed(context, Constants.FORGOTOTPVERIFICATION, arguments: email);
          } else if (forgotPasswordResponseModel.message != null) {
            showSnackBarColor(forgotPasswordResponseModel.message!, context, true);
          } else {
            showSnackBarColor("We're unable to connect to server. Please contact administrator or try after some time", context, true);
          }
        } else {
          await _progressDialog.hide();
          Map<String, dynamic> errorModel = jsonDecode(res.body);
          if (errorModel.containsKey('error_description')) {
            showSnackBarColor(errorModel['error_description'], context, true);
          }
        }
      }).catchError((error) async {
        // Prevent any redirection from happening here
        await _progressDialog.hide();
        showSnackBarErrorColor(error.toString(), context, true);
        return null; // Important: return a value to prevent further propagation
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
}
