import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/helper/helpers.dart';
import 'package:oqdo_mobile_app/model/cancel_reason_list_response_model.dart';
import 'package:oqdo_mobile_app/model/cancel_reason_view_model.dart';
import 'package:oqdo_mobile_app/model/coach_cancel_slot_response_model.dart';
import 'package:oqdo_mobile_app/repository/facility_slot_cancel_response_model.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/textfields_widget.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:oqdo_mobile_app/viewmodels/appointment_view_model.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class CancelReasonScreen extends StatefulWidget {
  CancelReasonViewModel? cancelReasonViewModel;

  CancelReasonScreen({Key? key, this.cancelReasonViewModel}) : super(key: key);

  @override
  State<CancelReasonScreen> createState() => _CancelReasonScreenState();
}

class _CancelReasonScreenState extends State<CancelReasonScreen> {
  late ProgressDialog _progressDialog;
  final List<CancelReasonListResponseModel> _cancelReasonResponseModelList = [];
  var reasonValue = ' ';
  final TextEditingController _otherReason = TextEditingController();

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
      appBar: CustomAppBar(
        title: 'Select a reason',
        onBack: () async {
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: Container(
          color: OQDOThemeData.whiteColor,
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
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
                          height: 50,
                        ),
                        CustomTextFormField(
                          read: false,
                          obscureText: false,
                          labelText: 'If Other, Type Here',
                          keyboardType: TextInputType.text,
                          maxlines: 4,
                          controller: _otherReason,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
                child: MyButton(
                  text: 'Submit',
                  textcolor: Theme.of(context).colorScheme.onBackground,
                  textsize: 16,
                  fontWeight: FontWeight.w600,
                  letterspacing: 0.7,
                  buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                  buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                  buttonheight: 55.0,
                  buttonwidth: MediaQuery.of(context).size.width,
                  radius: 15,
                  onTap: () async {
                    if (reasonValue == ' ') {
                      showSnackBar('Please select reason', context);
                    } else {
                      if (widget.cancelReasonViewModel!.type == 'F') {
                        callFacilityCancelSlot();
                      } else {
                        callCoachCancelSlot();
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget singleCancelReasonView(CancelReasonListResponseModel model) {
    return Row(
      children: [
        Radio<String>(
          autofocus: false,
          value: model.cancelReasonId.toString(),
          groupValue: reasonValue,
          activeColor: Theme.of(context).colorScheme.primary,
          onChanged: (String? value) {
            setState(() {
              reasonValue = value!;
            });
          },
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        const SizedBox(
          width: 5,
        ),
        CustomTextView(
          label: model.cancelreason,
          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
        ),
      ],
    );
  }

  Future<void> getCancelReasons() async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    try {
      await _progressDialog.show();
      List<CancelReasonListResponseModel> list = await Provider.of<AppointmentViewModel>(context, listen: false).getCancelReasonList();
      await _progressDialog.hide();
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

  Future<void> callFacilityCancelSlot() async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    try {
      await _progressDialog.show();

      Map<String, dynamic> request = {};
      request['SlotDate'] = convertDateTimeToString(DateTime.now());
      request['CancelReasonId'] = reasonValue;
      request['Remark'] = _otherReason.text.toString().trim();

      List<Map<String, dynamic>> data = [];
      for (int i = 0; i < widget.cancelReasonViewModel!.facilityBookingList!.length; i++) {
        for (int j = 0; j < widget.cancelReasonViewModel!.facilityBookingList![i].listOfSlots!.length; j++) {
          Map<String, dynamic> request = {};
          if (widget.cancelReasonViewModel!.facilityBookingList![i].listOfSlots![j].isSlotSelected) {
            request['FacilitySetupDaySlotMapId'] = widget.cancelReasonViewModel!.facilityBookingList![i].listOfSlots![j].facilitySetupDaySlotMapId;
            request['SlotDate'] = widget.cancelReasonViewModel!.facilityBookingList![i].date;
            data.add(request);
          }
        }
      }
      request['facilityCancelSetupSlotMapDtos'] = data;
      debugPrint('request -> ${json.encode(request)}');

      List<FacilitySlotCancelResponseModel> list = await Provider.of<AppointmentViewModel>(context, listen: false).facilitySlotCancelRequest(request);
      await _progressDialog.hide();
      if (list.isNotEmpty) {
        showSnackBarColor('Facility slot cancelled', context, false);
        await Navigator.pushNamedAndRemoveUntil(context, Constants.APPPAGES, Helper.of(context).predicate, arguments: 0);
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

  Future<void> callCoachCancelSlot() async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    try {
      await _progressDialog.show();
      Map<String, dynamic> request = {};
      request['SlotDate'] = convertDateTimeToString(DateTime.now());
      request['CancelReasonId'] = reasonValue;
      request['Remark'] = _otherReason.text.toString().trim();

      List<Map<String, dynamic>> data = [];
      for (int i = 0; i < widget.cancelReasonViewModel!.coachBookingList!.length; i++) {
        for (int j = 0; j < widget.cancelReasonViewModel!.coachBookingList![i].listOfSlots!.length; j++) {
          Map<String, dynamic> request = {};
          if (widget.cancelReasonViewModel!.coachBookingList![i].listOfSlots![j].isSlotSelected) {
            request['coachBatchSetupDaySlotMapId'] = widget.cancelReasonViewModel!.coachBookingList![i].listOfSlots![j].coachBatchSetupDaySlotMapId;
            request['SlotDate'] = widget.cancelReasonViewModel!.coachBookingList![i].date;
            data.add(request);
          }
        }
      }
      request['coachCancelBatchSetupSlotMapDtos'] = data;
      debugPrint('request -> ${json.encode(request)}');

      List<CoachSlotCancelResponseModel> list = await Provider.of<AppointmentViewModel>(context, listen: false).coachSlotCancelRequest(request);
      await _progressDialog.hide();
      if (list.isNotEmpty) {
        showSnackBarColor('Coach slot cancelled', context, false);

        await Navigator.pushNamedAndRemoveUntil(context, Constants.APPPAGES, Helper.of(context).predicate, arguments: 0);
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
      //showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context,true);
    }
  }
}
