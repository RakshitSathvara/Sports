// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:oqdo_mobile_app/utils/textfields_widget.dart';
import 'package:oqdo_mobile_app/utils/validator.dart';
import 'package:oqdo_mobile_app/viewmodels/ProfileViewModel.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import '../../helper/helpers.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  TextEditingController oldPassword = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  late Helper hp;
  late ProgressDialog _progressDialog;
  bool hidePassword1 = true;
  bool hidePassword2 = true;
  bool hidePassword3 = true;
  bool isOldPwdVisible = false;
  bool isNewPwdVisible = false;
  bool isConfirmPwdVisible = false;

  @override
  void initState() {
    super.initState();
    hp = Helper.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(message: "Please wait...");
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
                    CustomAppBar(
                        title: 'Change Password',
                        onBack: () {
                          Navigator.of(context).pop();
                        }),
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
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextFormField(
                        controller: oldPassword,
                        read: false,
                        obscureText: hidePassword1,
                        maxlines: 1,
                        labelText: 'Old Password',
                        validator: Validator.notEmpty,
                        keyboardType: TextInputType.text,
                        onchanged: (p0) {
                          if (p0.isEmpty) {
                            setState(() {
                              isOldPwdVisible = false;
                            });
                          } else {
                            setState(() {
                              isOldPwdVisible = true;
                            });
                          }
                          return '';
                        },
                        suffixIcon: isOldPwdVisible
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
                        controller: password,
                        read: false,
                        obscureText: hidePassword2,
                        maxlines: 1,
                        maxlength: 32,
                        labelText: 'New Password',
                        validator: oldPassword.text.trim() != password.text.trim()
                            ? Validator.validatePassword
                            : (val) {
                                return "Old password and new password should not be same";
                              },
                        keyboardType: TextInputType.text,
                        onchanged: (p0) {
                          if (p0.isEmpty) {
                            setState(() {
                              isNewPwdVisible = false;
                            });
                          } else {
                            setState(() {
                              isNewPwdVisible = true;
                            });
                          }
                          return '';
                        },
                        suffixIcon: isNewPwdVisible
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
                      CustomTextFormField(
                        controller: confirmPassword,
                        read: false,
                        obscureText: hidePassword3,
                        maxlines: 1,
                        maxlength: 32,
                        validator: (val) {
                          if (val!.trim().isEmpty) {
                            return "Please enter confirm password";
                          } else if (val.trim() != password.text) {
                            return "Password mismatch";
                          }
                          return null;
                        },
                        labelText: 'Confirm Password',
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
                                    hidePassword3 = !hidePassword3;
                                  });
                                },
                                icon: Icon(
                                  !hidePassword3 ? Icons.visibility : Icons.visibility_off,
                                  color: !hidePassword3 ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).colorScheme.secondaryContainer,
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
                            Map<String, dynamic> request = {};
                            request['UserId'] = OQDOApplication.instance.userID;
                            request['OldPassword'] = oldPassword.text.toString().trim();
                            request['Password'] = password.text.toString().trim();
                            request['ConfirmPassword'] = confirmPassword.text.toString().trim();

                            changePassword(request);
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

  Future<void> changePassword(Map data) async {
    await _progressDialog.show();

    try {
      await Provider.of<ProfileViewModel>(context, listen: false).changePassword(data).then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            _progressDialog.hide();
            showSnackBarColor('Password Changed Successfully', context, false);
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.token, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.tokenType, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.expiresIn, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.refreshToken, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.userId, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.facilityId, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.coachId, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.endUserId, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.fcmToken, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.userType, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.isLogin, value: "0");
            Navigator.pushNamedAndRemoveUntil(context, Constants.LOGIN, (route) => false);
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
