// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/model/cancel_reason_list_response_model.dart';
import 'package:oqdo_mobile_app/model/facility_list_response_model.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/textfields_widget.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:oqdo_mobile_app/utils/validator.dart';
import 'package:oqdo_mobile_app/viewmodels/service_provider_setup_viewmodel.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class AddFacilityVacationScreen extends StatefulWidget {
  const AddFacilityVacationScreen({Key? key}) : super(key: key);

  @override
  State<AddFacilityVacationScreen> createState() => _AddFacilityVacationScreenState();
}

class _AddFacilityVacationScreenState extends State<AddFacilityVacationScreen> {
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  DateTime todayDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
  DateTime selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
  late ProgressDialog _progressDialog;
  List<Data> facilitySetupList = [];
  final List<CancelReasonListResponseModel> _cancelReasonResponseModelList = [];
  var reasonValue = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getCancelReasons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OQDOThemeData.whiteColor,
      appBar: CustomAppBar(
        title: 'Add Vacation',
        onBack: () {
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: Container(
          color: OQDOThemeData.whiteColor,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Padding(
                        //   padding: const EdgeInsets.only(right: 15, top: 10),
                        //   child: Row(
                        //     children: [
                        //       const Spacer(),
                        //       GestureDetector(
                        //         onTap: () async {
                        //           await Navigator.pushNamed(context, Constants.VACATIONLISTPAGE);
                        //         },
                        //         child: Row(
                        //           mainAxisAlignment: MainAxisAlignment.end,
                        //           children: [
                        //             CustomTextView(
                        //               label: "Go to the list",
                        //               type: styleSubTitle,
                        //               textStyle: Theme.of(context).textTheme.bodyMedium,
                        //             ),
                        //             const SizedBox(
                        //               width: 10,
                        //             ),
                        //             Image.asset(
                        //               "assets/images/list_menu.png",
                        //               width: 30,
                        //               height: 30,
                        //             ),
                        //           ],
                        //         ),
                        //       )
                        //     ],
                        //   ),
                        // ),
                        // const SizedBox(
                        //   height: 20,
                        // ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10, left: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 180,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomTextView(
                                      label: "From",
                                      type: styleSubTitle,
                                      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.error),
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _selectDate(context);
                                      },
                                      child: TextField(
                                        enabled: false,
                                        controller: fromDateController,
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.shadow),
                                        decoration: InputDecoration(
                                          hintText: 'Select date',
                                          counterText: "",
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                          hintStyle: const TextStyle(
                                            color: Colors.black26,
                                          ),
                                          filled: true,
                                          suffixIcon: Padding(
                                            padding: const EdgeInsets.fromLTRB(6.0, 2.0, 8.0, 2.0),
                                            child: Image.asset(
                                              "assets/images/calendar_cicular.png",
                                              fit: BoxFit.contain,
                                              width: 18,
                                              height: 18,
                                            ),
                                          ),
                                          fillColor: Colors.white70,
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.3),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.3),
                                          ),
                                          disabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.3),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 180,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomTextView(
                                      label: "To",
                                      type: styleSubTitle,
                                      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.error),
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (fromDateController.text.toString().trim().isNotEmpty) {
                                          _selectToDate(context);
                                        } else {
                                          showSnackBar('Please select from date first', context);
                                        }
                                      },
                                      child: TextField(
                                        controller: toDateController,
                                        enabled: false,
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.shadow),
                                        decoration: InputDecoration(
                                          hintText: 'Select date',
                                          counterText: "",
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                          hintStyle: const TextStyle(color: Colors.black26),
                                          filled: true,
                                          suffixIcon: Padding(
                                            padding: const EdgeInsets.fromLTRB(6.0, 4.0, 8.0, 4.0),
                                            child: Image.asset(
                                              "assets/images/calendar_cicular.png",
                                              fit: BoxFit.contain,
                                              width: 18,
                                              height: 18,
                                            ),
                                          ),
                                          fillColor: Colors.white70,
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.3),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.3),
                                          ),
                                          disabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.3),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                          CustomTextView(
                            label: 'Reason',
                            textStyle:
                                Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 20, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            width: 35,
                          ),
                          Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _cancelReasonResponseModelList.length,
                              itemBuilder: (context, index) {
                                var model = _cancelReasonResponseModelList[index];
                                return singleCancelReasonView(model);
                              },
                            ),
                          ),
                        ]),
                        const SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10),
                          child: CustomTextFormField(
                            controller: reasonController,
                            read: false,
                            obscureText: false,
                            labelText: 'Specify your reason here',
                            validator: Validator.notEmpty,
                            keyboardType: TextInputType.text,
                            maxlines: 4,
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: CustomTextView(
                            label: 'List of facilities:',
                            textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF3A3A3A),
                                ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ListView.separated(
                          separatorBuilder: (context, index) => const Divider(
                            color: OQDOThemeData.greyColor,
                            height: 1,
                          ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: facilitySetupList.length,
                          itemBuilder: (context, index) {
                            var model = facilitySetupList[index];
                            return facilityView(model, index);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: MyButton(
                  text: 'Submit',
                  textcolor: Theme.of(context).colorScheme.onBackground,
                  textsize: 16,
                  fontWeight: FontWeight.w600,
                  letterspacing: 0.7,
                  buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                  buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                  buttonheight: 50,
                  buttonwidth: MediaQuery.of(context).size.width,
                  radius: 15,
                  onTap: () async {
                    callValidation();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget singleCancelReasonView(CancelReasonListResponseModel model) {
    return RadioListTile(
      visualDensity: const VisualDensity(horizontal: VisualDensity.minimumDensity, vertical: VisualDensity.minimumDensity),
      contentPadding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0),
      value: model.cancelReasonId.toString(),
      groupValue: reasonValue,
      activeColor: Theme.of(context).colorScheme.primary,
      title: CustomTextView(
        label: model.cancelreason,
        textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
      ),
      onChanged: (String? value) {
        setState(() {
          reasonValue = value!;
        });
      },
    );

    // return Row(
    //   children: [
    //     Radio<String>(
    //       autofocus: false,
    //       value: model.cancelReasonId.toString(),
    //       groupValue: reasonValue,
    //       activeColor: Theme.of(context).colorScheme.primary,
    //       onChanged: (String? value) {
    //         setState(() {
    //           reasonValue = value!;
    //         });
    //       },
    //       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    //     ),
    //     const SizedBox(
    //       width: 5,
    //     ),
    //     CustomTextView(
    //       label: model.cancelreason,
    //       textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
    //     ),
    //   ],
    // );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: todayDate,
      firstDate: todayDate,
      lastDate: kLastDay,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      // builder: (BuildContext context, Widget? child) {
      //   return Theme(
      //     data: ThemeData.dark().copyWith(
      //       colorScheme: ColorScheme.light(
      //         primary: Theme.of(context).colorScheme.primary,
      //         onPrimary: Colors.black,
      //         surface: Colors.white,
      //         onSurface: Colors.black,
      //       ),
      //       dialogBackgroundColor: Colors.white,
      //     ),
      //     child: child!,
      //   );
      // },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        if (toDateController.text.toString().trim().isEmpty) {
          fromDateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
        } else {
          toDateController.text = '';
          fromDateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
        }
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
      firstDate: DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
      lastDate: kLastDay,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      // builder: (BuildContext context, Widget? child) {
      //   return Theme(
      //     data: ThemeData.dark().copyWith(
      //       colorScheme: ColorScheme.light(
      //         primary: Theme.of(context).colorScheme.primary,
      //         onPrimary: Colors.black,
      //         surface: Colors.white,
      //         onSurface: Colors.black,
      //       ),
      //       dialogBackgroundColor: Colors.white,
      //     ),
      //     child: child!,
      //   );
      // },
    );
    if (picked != null) {
      String fromDateTime = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String toDateTime = DateFormat('yyyy-MM-dd').format(picked);
      if (fromDateTime.compareTo(toDateTime) == 0) {
        showSnackBar('Select a date greater than today', context);
      } else {
        // String toDate = DateFormat('yyyy-MM-dd').format(picked);
        // if (toDate.compareTo(fromDateController.text.toString().trim()) < 0) {
        //   Fluttertoast.showToast(msg: 'ToDate must be greater than FromDate', toastLength: Toast.LENGTH_SHORT);
        // } else {
        setState(() {
          toDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        });
        // }
      }
    }
  }

  Future<void> getFacilitySetupList() async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    try {
      await _progressDialog.show();
      FacilityListResponseModel facilityListResponseModel =
          await Provider.of<ServiceProviderSetupViewModel>(context, listen: false).getFacilitySetupList(OQDOApplication.instance.facilityID!);

      await _progressDialog.hide();
      setState(() {
        facilitySetupList.addAll(facilityListResponseModel.data!);
        debugPrint(facilityListResponseModel.data!.toString());
        for (int i = 0; i < facilitySetupList.length; i++) {
          facilitySetupList[i].isFacilitySelected = false;
        }
      });
    } on CommonException catch (error) {
      await _progressDialog.hide();
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
      await _progressDialog.hide();
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      await _progressDialog.hide();
      debugPrint(error.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  Future<void> getCancelReasons() async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    try {
      await _progressDialog.show();
      List<CancelReasonListResponseModel> list = await Provider.of<ServiceProviderSetupViewModel>(context, listen: false).getCancelReasonList();
      await _progressDialog.hide();
      if (list.isNotEmpty) {
        setState(() {
          _cancelReasonResponseModelList.clear();
          _cancelReasonResponseModelList.addAll(list);
          debugPrint('Length -> ${_cancelReasonResponseModelList.length}');
          _cancelReasonResponseModelList.removeWhere((element) => element.reasonFor == Constants.endUserType);
          debugPrint('Length -> ${_cancelReasonResponseModelList.length}');
        });
        getFacilitySetupList();
      }
    } on CommonException catch (error) {
      await _progressDialog.hide();
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
      await _progressDialog.hide();
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      await _progressDialog.hide();
      debugPrint(error.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  Widget facilityView(Data model, int index) {
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      visualDensity: const VisualDensity(horizontal: VisualDensity.minimumDensity, vertical: VisualDensity.minimumDensity),
      contentPadding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0),
      checkColor: Theme.of(context).colorScheme.primaryContainer,
      title: CustomTextView(
        label: model.title,
        maxLine: 2,
        textOverFlow: TextOverflow.ellipsis,
        textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 20.0, fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor),
      ),
      value: model.isFacilitySelected,
      onChanged: (value) {
        setState(() {
          model.isFacilitySelected = value;
        });
      },
    );
    // return Row(
    //   children: [
    //     Transform.scale(
    //       scale: 1.3,
    //       child: Checkbox(
    //           fillColor: MaterialStateProperty.resolveWith(Utils.getColor),
    //           checkColor: Theme.of(context).colorScheme.primaryContainer,
    //           value: model.isFacilitySelected,
    //           onChanged: (value) {
    //             setState(() {
    //               model.isFacilitySelected = value;
    //             });
    //           }),
    //     ),
    //     const SizedBox(
    //       width: 15.0,
    //     ),
    //     Flexible(
    //       child: CustomTextView(
    //         label: model.title,
    //         maxLine: 2,
    //         textOverFlow: TextOverflow.ellipsis,
    //         textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 18.0, fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor),
    //       ),
    //     ),
    //   ],
    // );
  }

  bool isAnyFacilitySelected() {
    bool isFacilitySelected = false;
    for (var i = 0; i < facilitySetupList.length; i++) {
      if (facilitySetupList[i].isFacilitySelected!) {
        isFacilitySelected = true;
        break;
      }
    }
    return isFacilitySelected;
  }

  void callValidation() {
    if (fromDateController.text.toString().trim().isEmpty) {
      showSnackBar('From date required', context);
    } else if (toDateController.text.toString().trim().isEmpty) {
      showSnackBar('To date required', context);
    } else if (reasonValue.isEmpty) {
      showSnackBar('Please select any one reason', context);
    } else if (!isAnyFacilitySelected()) {
      showSnackBar('Please select facility setup', context);
    } else {
      callVacationApiCall();
    }
  }

  Future<void> callVacationApiCall() async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    try {
      await _progressDialog.show();
      Map<String, dynamic> request = {};
      request['FacilityProviderId'] = OQDOApplication.instance.facilityID;
      request['FromDate'] = fromDateController.text.toString().trim();
      request['ToDate'] = toDateController.text.toString().trim();
      request['CancelReasonId'] = reasonValue;
      request['OtherReason'] = reasonController.text.toString().trim();

      List<Map> listMap = [];
      for (var i = 0; i < facilitySetupList.length; i++) {
        if (facilitySetupList[i].isFacilitySelected!) {
          Map map = {};
          map['FacilitySetupId'] = facilitySetupList[i].facilitySetupId;
          listMap.add(map);
        }
      }
      request['facilitySetupVacationDtos'] = listMap;
      debugPrint('facility vacation -> ${json.encode(request)}');
      String response = await Provider.of<ServiceProviderSetupViewModel>(context, listen: false).addFacilityVacationCall(request);
      await _progressDialog.hide();
      if (response.isNotEmpty) {
        showSnackBarColor('Facility vacation added', context, false);
        Navigator.of(context).pop(response);
      }
    } on CommonException catch (error) {
      await _progressDialog.hide();
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
      await _progressDialog.hide();
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      await _progressDialog.hide();
      debugPrint(error.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }
}
