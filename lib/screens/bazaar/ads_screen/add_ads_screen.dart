import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/screens/bazaar/ads_screen/viewmodel/ads_view_model.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:oqdo_mobile_app/utils/textfields_widget.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class AddAdsScreen extends StatefulWidget {
  const AddAdsScreen({super.key});

  @override
  State<AddAdsScreen> createState() => _AddAdsScreenState();
}

class _AddAdsScreenState extends State<AddAdsScreen> {
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    // Basic email validation regex
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }
    if (value.length < 8) {
      return 'Please enter a valid mobile number';
    }
    return null;
  }

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _organizationNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool termsAndCondition = false;

  late ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(message: "Please wait..");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        backgroundColor: Color(0xFF006590),
        title: 'Advertisements',
        isIconColorBlack: false,
        onBack: () {
          Navigator.pop(context);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 25,
                    children: [
                      Text(
                        'Request to Post Ad',
                        style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black, fontSize: 16, fontFamily: 'SFPro'),
                      ),
                      CustomTextFormField(
                        read: false,
                        obscureText: false,
                        maxlines: 1,
                        maxlength: 50,
                        inputformat: [
                          FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z ]+')),
                        ],
                        fillColor: OQDOThemeData.backgroundColor,
                        labelText: 'Full Name',
                        hintText: 'Enter Full Name',
                        keyboardType: TextInputType.text,
                        validator: (value) => validateRequired(value, 'Full Name'),
                        controller: _fullNameController,
                      ),
                      CustomTextFormField(
                        read: false,
                        obscureText: false,
                        maxlines: 1,
                        maxlength: 100,
                        inputformat: [
                          FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z ]+')),
                        ],
                        fillColor: OQDOThemeData.backgroundColor,
                        labelText: 'Name of Organization',
                        hintText: 'Enter Organization Name',
                        keyboardType: TextInputType.text,
                        validator: (value) => validateRequired(value, 'Organization Name'),
                        controller: _organizationNameController,
                      ),
                      CustomTextFormField(
                        read: false,
                        obscureText: false,
                        maxlines: 1,
                        maxlength: 50,
                        fillColor: OQDOThemeData.backgroundColor,
                        labelText: 'Email Address',
                        hintText: 'Enter Email Address',
                        keyboardType: TextInputType.text,
                        validator: (value) => validateEmail(value),
                        controller: _emailController,
                      ),
                      CustomTextFormField(
                        read: false,
                        obscureText: false,
                        maxlines: 1,
                        maxlength: 8,
                        inputformat: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        fillColor: OQDOThemeData.backgroundColor,
                        labelText: 'Mobile Number',
                        hintText: 'Enter Mobile Number',
                        keyboardType: TextInputType.number,
                        validator: (value) => validateMobile(value),
                        controller: _mobileController,
                      ),
                      CustomTextFormField(
                        read: false,
                        obscureText: false,
                        maxlines: 5,
                        maxlength: 500,
                        fillColor: OQDOThemeData.backgroundColor,
                        labelText: 'Description',
                        keyboardType: TextInputType.text,
                        validator: (value) => validateRequired(value, 'Description'),
                        controller: _descriptionController,
                      ),
                      Row(
                        children: [
                          Transform.scale(
                            scale: 1.3,
                            child: Checkbox(
                                fillColor: WidgetStateProperty.resolveWith(getColor),
                                checkColor: Theme.of(context).colorScheme.primaryContainer,
                                value: termsAndCondition,
                                onChanged: (value) {
                                  setState(() {
                                    termsAndCondition = value!;
                                  });
                                }),
                          ),
                          Flexible(
                            child: RichText(
                              text: TextSpan(
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
                                text: 'I have read and accept the terms & conditions',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17.0,
                                    fontFamily: 'Montserrat',
                                    color: const Color(0xFF006590),
                                    decoration: TextDecoration.underline,
                                    decorationThickness: 2),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (!termsAndCondition) {
                      showSnackBarColor('Please accept the terms and Conditions', context, true);
                      return;
                    }
                    final formData = {
                      'FullName': _fullNameController.text.toString().trim(),
                      'OrganisationName': _organizationNameController.text.toString().trim(),
                      'EmailAddress': _emailController.text.toString().trim(),
                      'MobileNo': _mobileController.text.toString().trim(),
                      'Description': _descriptionController.text.toString().trim(),
                    };
                    debugPrint('formData: $formData');
                    callCreateLeadApi(formData);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF006590),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Send Request',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'SFPro',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> callCreateLeadApi(Map<String, dynamic> formData) async {
    try {
      _progressDialog.show();
      await Provider.of<AdsViewModel>(context, listen: false).createLead(formData).then(
        (value) async {
          Response res = value;
          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            await _progressDialog.hide();
            int response = jsonDecode(res.body);
            if (response > 0) {
              showSnackBarColor('Ads lead created successfully', context, false);
              Navigator.pop(context);
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
