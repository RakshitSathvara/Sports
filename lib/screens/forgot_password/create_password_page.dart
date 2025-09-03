// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/model/common_passing_args.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:oqdo_mobile_app/utils/textfields_widget.dart';
import 'package:oqdo_mobile_app/utils/validator.dart';
import 'package:oqdo_mobile_app/viewmodels/login_view_model.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import '../../helper/helpers.dart';

class CreatePasswordPage extends StatefulWidget {
  CreatePasswordPage({super.key, required this.userDetails});

  EmailOTPModel userDetails;

  @override
  CreatePasswordPageState createState() => CreatePasswordPageState();
}

class CreatePasswordPageState extends State<CreatePasswordPage> {
  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool hidePassword1 = true;
  bool hidePassword2 = true;
  late Helper hp;
  late ProgressDialog _progressDialog;
  bool isPwdVisible = false;
  bool isConfirmPwdVisible = false;

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
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).colorScheme.onBackground,
        child: SingleChildScrollView(
          child: Form(
            key: hp.formKey,
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
                        label: 'Create Password',
                        type: styleSubTitle,
                        textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      // CustomTextFormField(
                      //   controller: passwordController,
                      //   read: false,
                      //   obscureText: false,
                      //   maxlines: 1,
                      //   labelText: 'New Password',
                      //   validator: Validator.validatePassword,
                      //   keyboardType: TextInputType.text,
                      // ),
                      CustomTextFormField(
                        controller: passwordController,
                        read: false,
                        obscureText: hidePassword1,
                        maxlines: 1,
                        maxlength: 32,
                        fillColor: OQDOThemeData.backgroundColor,
                        labelText: 'New Password',
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
                      // CustomTextFormField(
                      //   controller: confirmPasswordController,
                      //   read: false,
                      //   obscureText: false,
                      //   maxlines: 1,
                      //   validator: (val) {
                      //     if (val!.isEmpty) {
                      //       return "Please enter confirm password";
                      //     } else if (val != passwordController.text) {
                      //       return "Password mismatched";
                      //     }
                      //     return null;
                      //   },
                      //   labelText: 'Confirm Password',
                      //   keyboardType: TextInputType.text,
                      // ),
                      CustomTextFormField(
                        controller: confirmPasswordController,
                        read: false,
                        obscureText: hidePassword1,
                        maxlines: 1,
                        maxlength: 32,
                        fillColor: OQDOThemeData.backgroundColor,
                        labelText: 'Confirm Password',
                        validator: (val) {
                          if (val!.trim().isEmpty) {
                            return "Please enter confirm password";
                          } else if (val.trim() != passwordController.text) {
                            return "Password mismatched";
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
                      MyButton(
                        text: "Update Password",
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
                          if (hp.formKey.currentState!.validate()) {
                            await createPassword(
                              email: widget.userDetails.email ?? "",
                              password: confirmPasswordController.text.trim(),
                              otp: widget.userDetails.otp ?? "",
                            );
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

  Future<void> createPassword({required String email, required String password, required String otp}) async {
    await _progressDialog.show();
    Map request = {};
    request['EmailId'] = widget.userDetails.email;
    request['NewPassword'] = confirmPasswordController.text.toString().trim();
    request['OtpText'] = widget.userDetails.otp;

    try {
      await Provider.of<LoginViewModel>(context, listen: false).createPassword(request: request).then((value) async {
        Response res = value;
        await _progressDialog.hide();
        if (res.statusCode == 500 || res.statusCode == 404) {
          showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
        } else if (res.statusCode == 200) {
          await _progressDialog.hide();
          debugPrint("Response of create password ===> $res");
          showSnackBarColor('Password reset successfully', context, false);
          await Navigator.pushNamedAndRemoveUntil(context, Constants.LOGIN, Helper.of(context).predicate);
        } else {
          Map<String, dynamic> errorModel = jsonDecode(res.body);
          if (errorModel.containsKey('ModelState')) {
            Map<String, dynamic> modelState = errorModel['ModelState'];
            if (modelState.containsKey('ErrorMessage')) {
              showSnackBarColor(modelState['ErrorMessage'][0], context, true);
            }
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
}
