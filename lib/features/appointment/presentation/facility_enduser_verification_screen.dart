// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/helper/helpers.dart';
import 'package:oqdo_mobile_app/model/CancelFacilityAppointmentModel.dart';
import 'package:oqdo_mobile_app/model/facility_appointment_details_model.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/viewmodels/appointment_view_model.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import '../../theme/oqdo_theme_data.dart';

class FacilityEndUserCancelAppointmentVerificationScreen extends StatefulWidget {
  CancelFacilityAppointmentModel? cancelFacilityAppointmentModel;
  FacilityEndUserCancelAppointmentVerificationScreen({Key? key, this.cancelFacilityAppointmentModel}) : super(key: key);

  @override
  State<FacilityEndUserCancelAppointmentVerificationScreen> createState() => _FacilityEndUserCancelAppointmentVerificationScreenState();
}

class _FacilityEndUserCancelAppointmentVerificationScreenState extends State<FacilityEndUserCancelAppointmentVerificationScreen> {
  double totalAmount = 0.00;
  late ProgressDialog _progressDialog;
  List<FacilityBookingSlotDates> finalList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(message: "Please wait..");
      for (var i = 0; i < widget.cancelFacilityAppointmentModel!.list!.length; i++) {
        if (widget.cancelFacilityAppointmentModel!.list![i].isSlotSelected!) {
          setState(() {
            finalList.add(widget.cancelFacilityAppointmentModel!.list![i]);
            totalAmount = totalAmount + widget.cancelFacilityAppointmentModel!.list![i].refundedAmount!;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: 'Cancel Appointments',
          onBack: () {
            Navigator.pop(context);
          }),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Theme.of(context).colorScheme.onBackground,
          child: widget.cancelFacilityAppointmentModel!.facilityAppointmentDetailModel != null
              ? Column(
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
                        textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w500),
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
                        textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 17, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTextView(
                            label: 'Details',
                            textStyle: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(color: OQDOThemeData.otherTextColor, fontWeight: FontWeight.w600, fontSize: 12.0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: CustomTextView(
                        label: 'Order ID: ${widget.cancelFacilityAppointmentModel!.facilityAppointmentDetailModel!.bookingNo}',
                        textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: CustomTextView(
                        maxLine: 2,
                        label: 'Name: ${widget.cancelFacilityAppointmentModel!.facilityAppointmentDetailModel!.facilityName}',
                        textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: CustomTextView(
                        label: 'Email ID: ${widget.cancelFacilityAppointmentModel!.facilityAppointmentDetailModel!.facilityEmail}',
                        textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: CustomTextView(
                        label: 'Phone number: ${widget.cancelFacilityAppointmentModel!.facilityAppointmentDetailModel!.facilityMobileNumber}',
                        textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: CustomTextView(
                        label: widget.cancelFacilityAppointmentModel!.facilityAppointmentDetailModel!.bookingType == 'I'
                            ? 'Booking For: Individual'
                            : 'Booking For: Group',
                        textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: CustomTextView(
                        label: 'Address: ${widget.cancelFacilityAppointmentModel!.facilityAppointmentDetailModel!.address}',
                        maxLine: 3,
                        textOverFlow: TextOverflow.ellipsis,
                        textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: CustomTextView(
                        label: 'Cancellation Reason: ${widget.cancelFacilityAppointmentModel!.selectedReason}',
                        textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(
                      height: 1,
                      color: Color(0xFFCACACA),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: false,
                        itemCount: finalList.length,
                        itemBuilder: ((context, index) {
                          return reviewAppointmentListView(index);
                        }),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Card(
                      elevation: 8.0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          topRight: Radius.circular(15.0),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomTextView(
                                  label: 'Refund Amount',
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontSize: 16.0, fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor),
                                ),
                                CustomTextView(
                                  label: 'S\$ ${totalAmount.toStringAsFixed(2)}',
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 40.0,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(OQDOThemeData.errorColor),
                                      ),
                                      child: CustomTextView(
                                        label: 'Cancel',
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(fontSize: 16, color: OQDOThemeData.whiteColor, fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        facilityCancelRequest(context);
                                      },
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(OQDOThemeData.successColor),
                                      ),
                                      child: CustomTextView(
                                        label: 'Confirm',
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(fontSize: 16, color: OQDOThemeData.whiteColor, fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ),
    );
  }

  Widget reviewAppointmentListView(int index) {
    return Container(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextView(
                label:
                    '${convertDateToString(finalList[index].bookingDate!).split(',')[1].split(' ')[2]} ${convertDateToString(finalList[index].bookingDate!).split(',')[1].split(' ')[1]} - ${convertDateToString(finalList[index].bookingDate!).split(',')[0]}',
                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 18.0, fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor),
              ),
              const SizedBox(
                height: 5.0,
              ),
              CustomTextView(
                label: '${finalList[index].startTime} - ${finalList[index].endTime}',
                textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 12.0, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
              ),
            ],
          ),
          const Spacer(),
          RichText(
            text: TextSpan(text: 'Refund Amount: ', style: const TextStyle(color: Color(0xFF7D7D7D), fontWeight: FontWeight.w400, fontSize: 12), children: [
              TextSpan(
                text: 'S\$${finalList[index].refundedAmount?.toStringAsFixed(2) ?? 0.00}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF006590),
                  fontSize: 14,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  String convertDateToString(String date) {
    String parsingDate = '';
    DateTime dateTime = DateFormat('yyyy-MM-dd').parse(date);
    parsingDate = DateFormat.yMMMMEEEEd().format(dateTime);
    return parsingDate;
  }

  Future<void> facilityCancelRequest(BuildContext context) async {
    try {
      await _progressDialog.show();
      Map<String, dynamic> request = {};
      request['SubActivityId'] = widget.cancelFacilityAppointmentModel!.facilityAppointmentDetailModel!.subActivityId;
      request['UserId'] = OQDOApplication.instance.endUserID;
      request['CancelReasonId'] = widget.cancelFacilityAppointmentModel!.selectedReasonId;
      request['OtherReason'] = widget.cancelFacilityAppointmentModel!.otherText;
      request['FacilityBookingId'] = widget.cancelFacilityAppointmentModel!.facilityAppointmentDetailModel!.facilityBookingId;
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
      debugPrint('Request -> ${json.encode(request)}');
      var list = await Provider.of<AppointmentViewModel>(context, listen: false).facilityCancelAppointmentRequest(request);
      await _progressDialog.hide();
      if (list.isNotEmpty) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => WillPopScope(
                  onWillPop: () async => false,
                  child: AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 100.0,
                        ),
                        const SizedBox(height: 10.0),
                        CustomTextView(
                            maxLine: 4,
                            textOverFlow: TextOverflow.ellipsis,
                            label:
                                "Your Appointment has been cancelled and a refund (if applicable) has been initiated and will reflect in your account within 7-10 working days"),
                        const SizedBox(height: 20.0),
                        MyButton(
                          text: 'Return to Home',
                          textcolor: Theme.of(context).colorScheme.onBackground,
                          textsize: 14,
                          fontWeight: FontWeight.w500,
                          letterspacing: 0.7,
                          buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                          buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                          buttonheight: 40.0,
                          buttonwidth: 100,
                          radius: 15,
                          onTap: () async {
                            await Navigator.pushNamedAndRemoveUntil(context, Constants.APPPAGES, Helper.of(context).predicate, arguments: 0);
                          },
                        ),
                      ],
                    ),
                  ),
                ));
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
