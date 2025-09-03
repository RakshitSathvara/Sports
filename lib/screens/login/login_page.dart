import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/helper/helpers.dart';
import 'package:oqdo_mobile_app/model/login_response_model.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  TextEditingController username = TextEditingController(); // text: kDebugMode ? 'chp' : ''
  TextEditingController password = TextEditingController(); // text: kDebugMode ? 'Asd@123' : ''
  bool isvisible = true;
  late Helper hp;
  late ProgressDialog _progressDialog;
  bool isPwdVisible = false;

  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    hp = Helper.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(message: "Please wait..");
    });
    getToken();
  }

  getToken() async {
    var deviceState = await OneSignal.User.getOnesignalId();
    if (deviceState == null || deviceState.isEmpty) return;
    setState(() {
      OQDOApplication.instance.fcmToken = deviceState.toString();
    });
    showLog('IsSubscribed getOnesignalId ===> ${deviceState}');

    final pushSubscription = OneSignal.User.pushSubscription;
    print("IsSubscribed Id ===> ${pushSubscription.id}");
    print("IsSubscribed optedIn ===> ${pushSubscription.optedIn}");
    if (pushSubscription.optedIn == true) {
      setState(() {
        OQDOApplication.instance.fcmToken = pushSubscription.id;
      });
      print("IsSubscribed fcmToken 1 ===> ${OQDOApplication.instance.fcmToken}");
    } else {
      await pushSubscription.optIn();

      pushSubscription.addObserver((state) {
        print("IsSubscribed optedIn ===> ${OneSignal.User.pushSubscription.optedIn}");
        print("IsSubscribed id ===> ${OneSignal.User.pushSubscription.id}");
        print("IsSubscribed token ===> ${OneSignal.User.pushSubscription.token}");
        print("IsSubscribed json ===> ${state.current.jsonRepresentation()}");
        setState(() {
          OQDOApplication.instance.fcmToken = OneSignal.User.pushSubscription.id;
        });
        print("IsSubscribed fcmToken 2 ===> ${OQDOApplication.instance.fcmToken}");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: OQDOThemeData.whiteColor,
        child: SingleChildScrollView(
          child: Form(
            key: hp.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    Container(
                      width: width / 1.1,
                      height: height / 2.0,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage('assets/images/login_bg.png'),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 100,
                      left: 30,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            "assets/images/logo.png",
                            height: 100,
                            width: 140,
                          ),
                          CustomTextView(
                            label: 'Welcome',
                            textStyle:
                                Theme.of(context).textTheme.titleLarge!.copyWith(color: const Color(0xff595959), fontSize: 24.0, fontWeight: FontWeight.w400),
                          ),
                          CustomTextView(
                            label: 'Back',
                            textStyle:
                                Theme.of(context).textTheme.titleLarge!.copyWith(color: const Color(0xff595959), fontSize: 24.0, fontWeight: FontWeight.w400),
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
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: AutofillGroup(
                    onDisposeAction: isLoggedIn ? AutofillContextAction.commit : AutofillContextAction.cancel,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        CustomTextFormField(
                          autofillHints: const [AutofillHints.username],
                          controller: username,
                          read: false,
                          obscureText: false,
                          labelText: 'Username/Email',
                          fillColor: OQDOThemeData.backgroundColor,
                          validator: Validator.notEmpty,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        CustomTextFormField(
                          autofillHints: const [AutofillHints.password],
                          controller: password,
                          read: false,
                          obscureText: isvisible,
                          maxlines: 1,
                          fillColor: OQDOThemeData.backgroundColor,
                          labelText: 'Password',
                          validator: Validator.validateLoginPassword,
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
                                      isvisible = !isvisible;
                                    });
                                  },
                                  icon: Icon(
                                    !isvisible ? Icons.visibility : Icons.visibility_off,
                                    color: !isvisible ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).colorScheme.secondaryContainer,
                                    size: 20.0,
                                  ))
                              : null,
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, Constants.FORGOTPASSWORD);
                          },
                          child: CustomTextView(
                            label: 'Forgot Password?',
                            type: styleSubTitle,
                            textStyle: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(fontSize: 18.0, color: const Color.fromRGBO(0, 101, 144, 1), fontWeight: FontWeight.w400),
                          ),
                        ),
                        const SizedBox(
                          height: 50.0,
                        ),
                        MyButton(
                          text: "Sign In",
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
                            if (hp.formKey.currentState!.validate()) {
                              if (username.text.toString().trim().contains('@')) {
                                if ((!RegExp(
                                        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                                    .hasMatch(username.text.toString().trim()))) {
                                  showSnackBarColor('Please enter a valid E-mail', context, true);
                                } else {
                                  login();
                                }
                              } else {
                                login();
                              }
                            }
                          },
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, Constants.PREREGISTER);
                            },
                            child: RichText(
                              text: TextSpan(
                                text: 'New to the App? ',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(fontSize: 17.0, fontWeight: FontWeight.w400, color: OQDOThemeData.otherTextColor),
                                children: [
                                  TextSpan(
                                    text: 'Sign up ',
                                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17.0, color: Theme.of(context).colorScheme.primaryContainer),
                                  ),
                                  TextSpan(
                                    text: 'from here.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(fontSize: 17.0, fontWeight: FontWeight.w400, color: OQDOThemeData.otherTextColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    await _progressDialog.show();
    try {
      await Provider.of<LoginViewModel>(context, listen: false)
          .login(username.text.toString().trim(), password.text.toString().trim(), OQDOApplication.instance.fcmToken.toString())
          .then((value) async {
        Response res = value;
        _progressDialog.hide();
        if (res.statusCode == 500 || res.statusCode == 404) {
          showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
        } else if (res.statusCode == 200) {
          LoginResponseModel? loginResponseModel = LoginResponseModel.fromMap(jsonDecode(res.body));
          if (loginResponseModel!.accessToken != null) {
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.token, value: loginResponseModel.accessToken!);
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.tokenType, value: loginResponseModel.tokenType!);
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.expiresIn, value: loginResponseModel.expiresIn.toString());
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.refreshToken, value: loginResponseModel.refreshToken!);
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.userId, value: loginResponseModel.UserId!);
            debugPrint('user id -> ${loginResponseModel.UserId}');
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.facilityId, value: loginResponseModel.FacilityId!);
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.coachId, value: loginResponseModel.CoachId!);
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.endUserId, value: loginResponseModel.EndUserId!);
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.fcmToken, value: loginResponseModel.Fcm!);
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.userType, value: loginResponseModel.UserType!);
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.isLogin, value: '1');
            debugPrint('TOKEN -> ${loginResponseModel.accessToken!}');

            OQDOApplication.instance.isLogin = OQDOApplication.instance.storage.getStringValue(AppStrings.isLogin);
            OQDOApplication.instance.userType = OQDOApplication.instance.storage.getStringValue(AppStrings.userType);
            OQDOApplication.instance.endUserID = OQDOApplication.instance.storage.getStringValue(AppStrings.endUserId);
            OQDOApplication.instance.coachID = OQDOApplication.instance.storage.getStringValue(AppStrings.coachId);
            OQDOApplication.instance.facilityID = OQDOApplication.instance.storage.getStringValue(AppStrings.facilityId);
            OQDOApplication.instance.userID = OQDOApplication.instance.storage.getStringValue(AppStrings.userId);
            OQDOApplication.instance.tokenType = OQDOApplication.instance.storage.getStringValue(AppStrings.tokenType);
            OQDOApplication.instance.token = OQDOApplication.instance.storage.getStringValue(AppStrings.token);

            setState(() {
              isLoggedIn = true;
            });

            WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
              TextInput.finishAutofillContext();
              await Navigator.pushNamedAndRemoveUntil(context, Constants.APPPAGES, Helper.of(context).predicate, arguments: 0);
            });
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
