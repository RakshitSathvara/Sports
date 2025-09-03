import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/model/CancelFacilityAppointmentModel.dart';
import 'package:oqdo_mobile_app/model/cancel_reason_list_response_model.dart';
import 'package:oqdo_mobile_app/model/facility_cancel_appointment_verify_response_model.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/viewmodels/appointment_view_model.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import '../../components/my_button.dart';
import '../../theme/oqdo_theme_data.dart';
import '../../utils/constants.dart';
import '../../utils/custom_text_view.dart';
import '../../utils/textfields_widget.dart';

class CancelFacilityAppointmentReasonScreen extends StatefulWidget {
  CancelFacilityAppointmentModel? cancelFacilityAppointmentModel;

  CancelFacilityAppointmentReasonScreen({Key? key, this.cancelFacilityAppointmentModel}) : super(key: key);

  @override
  State<CancelFacilityAppointmentReasonScreen> createState() => _CancelFacilityAppointmentReasonScreenState();
}

class _CancelFacilityAppointmentReasonScreenState extends State<CancelFacilityAppointmentReasonScreen> {
  final List<CancelReasonListResponseModel> _cancelReasonResponseModelList = [];
  var reasonValue = ' ';
  final TextEditingController _otherReason = TextEditingController();
  late ProgressDialog _progressDialog;
  String selectedReasonStr = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(message: "Please wait..");
      getCancelReasons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarView(),
      body: SafeArea(
        child: Container(
          color: Theme.of(context).colorScheme.onBackground,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: _cancelReasonResponseModelList.isNotEmpty
              ? Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: CustomTextView(
                                label:
                                    '${widget.cancelFacilityAppointmentModel!.facilityAppointmentDetailModel!.facilitySetupTitle!.trim()} - ${widget.cancelFacilityAppointmentModel!.facilityAppointmentDetailModel!.facilitySetupSubTitle!.trim()}',
                                textStyle:
                                    Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: CustomTextView(
                                label:
                                    '${widget.cancelFacilityAppointmentModel!.facilityAppointmentDetailModel!.activityName} - ${widget.cancelFacilityAppointmentModel!.facilityAppointmentDetailModel!.subActivityName}',
                                textStyle:
                                    Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 17, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(
                              height: 40.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                              child: CustomTextView(
                                label: 'Select Reason For Cancelling Appointment',
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(fontSize: 18.0, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w400),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _cancelReasonResponseModelList.length,
                              itemBuilder: (context, index) {
                                var model = _cancelReasonResponseModelList[index];
                                return singleCancelReasonView(model);
                              },
                            ),
                            const SizedBox(
                              height: 40.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                              child: CustomTextFormField(
                                read: false,
                                obscureText: false,
                                labelText: 'If Other, Type Here',
                                keyboardType: TextInputType.text,
                                maxlines: 4,
                                controller: _otherReason,
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                              child: MyButton(
                                text: "Submit",
                                textcolor: Theme.of(context).colorScheme.onBackground,
                                textsize: 20,
                                fontWeight: FontWeight.w600,
                                letterspacing: 1.2,
                                buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                                buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                                buttonheight: 55,
                                buttonwidth: MediaQuery.of(context).size.width,
                                radius: 15,
                                onTap: () async {
                                  if (reasonValue == ' ') {
                                    showSnackBar('Please select reason', context);
                                  } else {
                                    _showAlertDialog(context);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ),
    );
  }

  Widget singleCancelReasonView(CancelReasonListResponseModel model) {
    return RadioListTile(
      visualDensity: const VisualDensity(horizontal: VisualDensity.minimumDensity, vertical: VisualDensity.minimumDensity),
      contentPadding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0),
      title: CustomTextView(
        label: model.cancelreason,
        textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
      ),
      activeColor: Theme.of(context).colorScheme.primary,
      value: model.cancelReasonId.toString(),
      groupValue: reasonValue,
      onChanged: (String? value) {
        setState(() {
          reasonValue = value!;
          getReasonStr(reasonValue);
        });
      },
    );

    // Row(
    //   children: [
    //     Radio<String>(
    //       autofocus: false,
    //       value: model.cancelReasonId.toString(),
    //       groupValue: reasonValue,
    //       activeColor: Theme.of(context).colorScheme.primary,
    //       onChanged: (String? value) {
    //         setState(() {
    //           reasonValue = value!;
    //           getReasonStr(reasonValue);
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

  PreferredSizeWidget appbarView() {
    return CustomAppBar(
        title: 'Cancel Appointments',
        onBack: () {
          Navigator.pop(context);
        });
  }

  void _showAlertDialog(BuildContext dialogContext) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: CustomTextView(
          label: '',
          textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w400, fontSize: 18.0, color: OQDOThemeData.greyColor),
        ),
        content: Center(
          child: CustomTextView(
            label: 'Are you sure you want to\ncancel this appointment?',
            maxLine: 2,
            textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 16.0, fontWeight: FontWeight.w600, color: OQDOThemeData.greyColor),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: CustomTextView(
              label: 'No',
              textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: OQDOThemeData.dialogActionColor),
            ),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(context).pop();
              verifyFacilityCancellationRequest();
            },
            child: CustomTextView(
              label: 'Yes',
              textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: OQDOThemeData.dialogActionColor),
            ),
          )
        ],
      ),
    );
  }

  Future<void> getCancelReasons() async {
    try {
      List<CancelReasonListResponseModel> list = await Provider.of<AppointmentViewModel>(context, listen: false).getCancelReasonList();
      if (list.isNotEmpty) {
        setState(() {
          _cancelReasonResponseModelList.clear();
          _cancelReasonResponseModelList.addAll(list);
          debugPrint('Length -> ${_cancelReasonResponseModelList.length}');
          _cancelReasonResponseModelList.removeWhere((element) => element.reasonFor == Constants.endUserType);
          debugPrint('Length -> ${_cancelReasonResponseModelList.length}');
        });
      }
    } on CommonException catch (error) {
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
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      debugPrint(error.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  Future<void> verifyFacilityCancellationRequest() async {
    try {
      await _progressDialog.show();
      Map<String, dynamic> request = {};
      request['UserId'] = OQDOApplication.instance.endUserID;
      request['CancelReasonId'] = reasonValue;
      request['OtherReason'] = _otherReason.text.toString().trim();
      List<Map<String, dynamic>> data = [];
      for (var i = 0; i < widget.cancelFacilityAppointmentModel!.list!.length; i++) {
        Map<String, dynamic> selectedFacilityReq = {};
        if (widget.cancelFacilityAppointmentModel!.list![i].isSlotSelected!) {
          selectedFacilityReq['SlotMapId'] = widget.cancelFacilityAppointmentModel!.list![i].facilitySetupDaySlotMapId;
          selectedFacilityReq['BookingDate'] = widget.cancelFacilityAppointmentModel!.list![i].bookingDate!.split('T')[0];
          data.add(selectedFacilityReq);
        }
      }
      request['FacilityCancelAppointmentSlotDtos'] = data;
      FacilityCancelAppointmentVerificationResponseModel response =
          await Provider.of<AppointmentViewModel>(context, listen: false).verifyFacilityCancelAppointmentCancel(request);
      await _progressDialog.hide();
      showLog('Response -> $response');
      if (response.facilityCancelAppointmentSlotDtos!.isNotEmpty) {
        showLog('Name -> ${response.facilityCancelAppointmentSlotDtos![0].refundedAmount}');
        for (var i = 0; i < widget.cancelFacilityAppointmentModel!.list!.length; i++) {
          for (var j = 0; j < response.facilityCancelAppointmentSlotDtos!.length; j++) {
            if (widget.cancelFacilityAppointmentModel!.list![i].facilitySetupDaySlotMapId == response.facilityCancelAppointmentSlotDtos![j].slotMapId) {
              setState(() {
                widget.cancelFacilityAppointmentModel!.list![i].refundedAmount = response.facilityCancelAppointmentSlotDtos![j].refundedAmount;
              });
            }
          }
        }
        widget.cancelFacilityAppointmentModel!.selectedReasonId = reasonValue;
        widget.cancelFacilityAppointmentModel!.selectedReason = selectedReasonStr;
        widget.cancelFacilityAppointmentModel!.otherText = _otherReason.text.toString().trim();
        showSnackBarColor('Eligibility to receive refund checked', context, false);
        Navigator.of(context).pushNamed(Constants.facilityVerifyCancelApppointment, arguments: widget.cancelFacilityAppointmentModel);
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

  void getReasonStr(String reasonData) {
    List<CancelReasonListResponseModel> list = _cancelReasonResponseModelList.where((element) => element.cancelReasonId == int.parse(reasonData)).toList();
    setState(() {
      selectedReasonStr = list[0].cancelreason!;
    });
  }
}
