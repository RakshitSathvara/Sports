// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/helper/helpers.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:oqdo_mobile_app/utils/textfields_widget.dart';
import 'package:oqdo_mobile_app/utils/validator.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import '../../model/coach_profile_response.dart';
import '../../model/coach_training_address.dart';
import '../../model/get_all_activity_and_sub_activity_response.dart';
import '../../utils/constants.dart';
import '../../viewmodels/service_provider_setup_viewmodel.dart';

// ignore: must_be_immutable
class CoachTrainingAddressPage extends StatefulWidget {
  String? type;
  CoachTrainingAddress? model;

  CoachTrainingAddressPage({Key? key, this.type, this.model}) : super(key: key);

  @override
  CoachTrainingAddressPageState createState() => CoachTrainingAddressPageState();
}

class CoachTrainingAddressPageState extends State<CoachTrainingAddressPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  TextEditingController titleController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController address2Controller = TextEditingController();
  TextEditingController postalcode = TextEditingController();
  late Helper hp;
  late ProgressDialog progressDialog;
  List<ActivityBean> activityListModel = [];
  List<ActivityBean> subActivity = [];
  String? choosedinterest;
  String? choosediActivity;
  int? selectedSubActivityID;
  String? cityId;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    hp = Helper.of(context);
    if (widget.model != null) {
      _isEdit = true;
    } else {
      _isEdit = false;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      progressDialog.style(message: "Please wait..");
      getAllActivity();
      cityId = OQDOApplication.instance.storage.getStringValue(AppStrings.selectedCountryID);
      debugPrint(cityId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onBackground,
      key: scaffoldKey,
      appBar: CustomAppBar(
        title: 'Training Address',
        onBack: () {
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: hp.formKey,
            child: Container(
              color: Theme.of(context).colorScheme.onBackground,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    // Container(
                    //   decoration: BoxDecoration(
                    //     border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
                    //     borderRadius: BorderRadius.circular(15),
                    //     color: Theme.of(context).colorScheme.onBackground,
                    //   ),
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(left: 10, right: 10),
                    //     child: DropdownButton<dynamic>(
                    //         isExpanded: true,
                    //         underline: const SizedBox(),
                    //         borderRadius: BorderRadius.circular(15),
                    //         dropdownColor: Theme.of(context).colorScheme.onBackground,
                    //         hint: Text(
                    //           "Select One",
                    //           style:
                    //               Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.primaryContainer),
                    //         ),
                    //         value: choosedinterest,
                    //         items: activityListModel.map((interest) {
                    //           return DropdownMenuItem(
                    //             value: interest.Name,
                    //             child: CustomTextView(label: interest.Name),
                    //           );
                    //         }).toList(),
                    //         onChanged: (value) {
                    //           setState(() {
                    //             choosedinterest = value;
                    //             debugPrint(choosedinterest);
                    //             getSubActivity(false);
                    //           });
                    //         }),
                    //   ),
                    // ),
                    // subActivity.isNotEmpty
                    //     ? Column(
                    //         children: [
                    //           const SizedBox(
                    //             height: 20,
                    //           ),
                    //           Container(
                    //             decoration: BoxDecoration(
                    //               border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
                    //               borderRadius: BorderRadius.circular(15),
                    //               color: Theme.of(context).colorScheme.onBackground,
                    //             ),
                    //             child: Padding(
                    //               padding: const EdgeInsets.only(left: 10, right: 10),
                    //               child: DropdownButton<dynamic>(
                    //                   isExpanded: true,
                    //                   underline: const SizedBox(),
                    //                   borderRadius: BorderRadius.circular(15),
                    //                   dropdownColor: Theme.of(context).colorScheme.onBackground,
                    //                   hint: Text(
                    //                     "Select One",
                    //                     style: Theme.of(context)
                    //                         .textTheme
                    //                         .titleSmall!
                    //                         .copyWith(color: Theme.of(context).colorScheme.primaryContainer),
                    //                   ),
                    //                   value: choosediActivity,
                    //                   items: subActivity[0].SubActivities!.map((interest) {
                    //                     return DropdownMenuItem(
                    //                       value: interest.Name,
                    //                       child: Text(interest.Name!),
                    //                     );
                    //                   }).toList(),
                    //                   onChanged: (value) {
                    //                     setState(() {
                    //                       choosediActivity = value;
                    //                     });
                    //                     getSubActivityID();
                    //                   }),
                    //             ),
                    //           ),
                    //         ],
                    //       )
                    //     : Container(),
                    // const SizedBox(
                    //   height: 28,
                    // ),
                    CustomTextFormField(
                      controller: titleController,
                      read: false,
                      obscureText: false,
                      labelText: 'Address Title',
                      validator: Validator.notEmpty,
                      keyboardType: TextInputType.text,
                      maxlines: 1,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomTextFormField(
                      controller: addressController,
                      read: false,
                      obscureText: false,
                      labelText: 'Address',
                      validator: Validator.notEmpty,
                      keyboardType: TextInputType.text,
                      maxlines: 4,
                      maxlength: 200,
                    ),
                    const SizedBox(
                      height: 28,
                    ),
                    CustomTextFormField(
                      controller: address2Controller,
                      read: false,
                      obscureText: false,
                      labelText: 'Address 2',
                      validator: Validator.notEmpty,
                      keyboardType: TextInputType.text,
                      maxlines: 4,
                      maxlength: 200,
                    ),
                    const SizedBox(
                      height: 28,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: CustomTextView(
                          label: 'Postal Code',
                          type: styleSubTitle,
                          textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.shadow),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: PinCodeTextField(
                        pinBoxHeight: 55,
                        pinBoxWidth: width / 8.0,
                        pinBoxRadius: 5,
                        autofocus: false,
                        controller: postalcode,
                        hideCharacter: false,
                        highlight: true,
                        highlightColor: Theme.of(context).colorScheme.secondaryContainer,
                        defaultBorderColor: Theme.of(context).colorScheme.secondaryContainer,
                        hasTextBorderColor: Theme.of(context).colorScheme.secondaryContainer,
                        errorBorderColor: Colors.red,
                        maxLength: 6,
                        hasError: false,
                        maskCharacter: "*",
                        //😎
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
                    ),
                    const SizedBox(
                      height: 28,
                    ),
                    MyButton(
                      text: "Save",
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
                          // if (selectedSubActivityID == null) {
                          //   showSnackBar('Please select activity & sub activity', context);
                          // } else
                          if (postalcode.text.toString().trim().length < 6) {
                            showSnackBar('Postal code required', context);
                          } else {
                            if (widget.type == "c") {
                              callAddAddress();
                            } else {
                              callEndUserAddress(context);
                            }
                          }
                        }
                      },
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

  Future<void> getAllActivity() async {
    try {
      await progressDialog.show();
      GetAllActivityAndSubActivityResponse getAllActivityAndSubActivityResponse =
          await Provider.of<ServiceProviderSetupViewModel>(context, listen: false).getAllActivity();

      if (getAllActivityAndSubActivityResponse.Data!.isNotEmpty) {
        activityListModel = getAllActivityAndSubActivityResponse.Data!;
        // debugPrint('Id -> ${widget.model!.activityId}');
        if (widget.model != null) {
          var activity = activityListModel.where((element) => element.ActivityId == widget.model?.activityId);
          choosedinterest = activity.first.Name;
          debugPrint(activity.toString());
          getSubActivity(true);
          titleController.text = widget.model?.addressName ?? "";
          addressController.text = widget.model?.address1 ?? "";
          address2Controller.text = widget.model?.address2 ?? "";
          postalcode.text = widget.model?.pinCode ?? "";
        }
        await progressDialog.hide();
        setState(() {});
      }
    } on CommonException catch (error) {
      await progressDialog.hide();
      debugPrint(error.message);
    } on NoConnectivityException catch (_) {
      await progressDialog.hide();
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      await progressDialog.hide();
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  void getSubActivity(bool fromInit) {
    subActivity.clear();
    choosediActivity = null;
    subActivity = activityListModel.where((element) => element.Name == choosedinterest).toList();
    selectedSubActivityID = widget.model?.subActivityId;
    if (fromInit) {
      var tempSubActivity = subActivity.first.SubActivities;
      var tempSubActivityModel = tempSubActivity?.where((element) => element.SubActivityId == selectedSubActivityID).toList();
      choosediActivity = tempSubActivityModel?.first.Name;
    }
    setState(() {});

    debugPrint(subActivity.toString());
  }

  void getSubActivityID() {
    List<SubActivitiesBean> selectedSubActivity = subActivity[0].SubActivities!.where((element) => element.Name == choosediActivity).toList();

    selectedSubActivityID = selectedSubActivity[0].SubActivityId;
    debugPrint(selectedSubActivityID.toString());
  }

  void callAddAddress() {
    Map addAddressMap = {};
    addAddressMap['CoachId'] = OQDOApplication.instance.coachID;
    addAddressMap['SubActivityId'] = selectedSubActivityID;
    addAddressMap['AddressName'] = titleController.text.toString().trim();
    addAddressMap['Address1'] = addressController.text.toString().trim();
    addAddressMap['Address2'] = address2Controller.text.toString().trim();
    addAddressMap['CityId'] = cityId;
    addAddressMap['PinCode'] = postalcode.text.toString().trim();
    addAddressMap['IsActive'] = true;
    if (_isEdit) {
      addAddressMap['CoachTrainingAddressId'] = widget.model?.coachTrainingAddressId;
    }
    debugPrint(json.encode(addAddressMap));
    callAddAddressApi(addAddressMap);
  }

  Future<void> callAddAddressApi(Map addAddressMap) async {
    try {
      await progressDialog.show();
      var response = await Provider.of<ServiceProviderSetupViewModel>(context, listen: false).addCoachTrainingAddress(addAddressMap, _isEdit);
      debugPrint(response);
      await progressDialog.hide();
      if (response != null) {
        if (_isEdit) {
          showSnackBarColor('Address Updated Successfully', context, false);
        } else {
          showSnackBarColor('Address Added Successfully', context, false);
        }
        CoachTrainingAddressDtos coachTrainingAddressDtos = CoachTrainingAddressDtos();
        coachTrainingAddressDtos.cityId = int.parse(cityId!);
        coachTrainingAddressDtos.addressName = titleController.text.toString().trim();
        coachTrainingAddressDtos.address1 = addressController.text.toString().trim();
        coachTrainingAddressDtos.address2 = address2Controller.text.toString().trim();
        coachTrainingAddressDtos.cityName = OQDOApplication.instance.storage.getStringValue(AppStrings.selectedCountryName);
        coachTrainingAddressDtos.pinCode = postalcode.text.toString().trim();
        debugPrint(coachTrainingAddressDtos.cityName);
        Navigator.pop(context, coachTrainingAddressDtos);
      }
    } on CommonException catch (error) {
      await progressDialog.hide();
      debugPrint(error.toString());
      if (error.code == 400) {
        Map<String, dynamic> errorModel = jsonDecode(error.message);
        if (errorModel.containsKey('ModelState')) {
          Map<String, dynamic> modelState = errorModel['ModelState'];
          if (modelState.containsKey('ErrorMessage')) {
            showSnackBarColor(modelState['ErrorMessage'][0], context, true);
          } else {
            showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
          }
        } else {
          showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
        }
      } else {
        showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
    } on NoConnectivityException catch (_) {
      await progressDialog.hide();
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      await progressDialog.hide();
    }
  }

  void callEndUserAddress(BuildContext context) {
    Map<String, dynamic> endUserMap = {};
    endUserMap['EndUserId'] = OQDOApplication.instance.endUserID;
    endUserMap['SubActivityId'] = selectedSubActivityID;
    endUserMap['AddressName'] = titleController.text.toString().trim();
    endUserMap['Address1'] = addressController.text.toString().trim();
    endUserMap['Address2'] = address2Controller.text.toString().trim();
    endUserMap['CityId'] = cityId;
    endUserMap['PinCode'] = postalcode.text.toString().trim();
    endUserMap['IsActive'] = true;
    endUserMap['EndUserTrainingAddressId'] = '';
    callEndUserApiCall(endUserMap, context);
  }

  void callEndUserApiCall(addEndUserMap, BuildContext buildContext) async {
    try {
      await progressDialog.show();
      String response = await Provider.of<ServiceProviderSetupViewModel>(buildContext, listen: false).addEditEndUserAddress(addEndUserMap, _isEdit);
      await progressDialog.hide();
      if (response.isNotEmpty) {
        goBack();
      }
    } on CommonException catch (error) {
      await progressDialog.hide();
      debugPrint(error.toString());
      if (error.code == 400) {
        Map<String, dynamic> errorModel = jsonDecode(error.message);
        if (errorModel.containsKey('ModelState')) {
          Map<String, dynamic> modelState = errorModel['ModelState'];
          if (modelState.containsKey('ErrorMessage')) {
            showSnackBarColor(modelState['ErrorMessage'][0], context, true);
          } else {
            showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
          }
        } else {
          showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
        }
      } else {
        showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
    } on NoConnectivityException catch (_) {
      await progressDialog.hide();
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      await progressDialog.hide();
      debugPrint(error.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  void goBack() {
    Navigator.pop(context, true);
  }
}
