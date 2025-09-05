// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/model/facility_appointment_details_model.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/viewmodels/appointment_view_model.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import '../../utils/colorsUtils.dart';

class FacilityAppointmentDetailsScreen extends StatefulWidget {
  String? bookingId;

  FacilityAppointmentDetailsScreen({Key? key, this.bookingId}) : super(key: key);

  @override
  State<FacilityAppointmentDetailsScreen> createState() => _FacilityAppointmentDetailsScreenState();
}

class _FacilityAppointmentDetailsScreenState extends State<FacilityAppointmentDetailsScreen> {
  late ProgressDialog _progressDialog;
  FacilityAppointmentDetailModel? _facilityAppointmentDetailModel;

  double totalAmount = 0.00;
  double paidAmount = 0.00;
  double payLaterAmount = 0.00;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getFacilityAppointmentDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: 'View Order',
          onBack: () {
            Navigator.pop(context);
          }),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
          height: double.infinity,
          width: double.infinity,
          color: Theme.of(context).colorScheme.onBackground,
          child: _facilityAppointmentDetailModel != null
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20.0,
                      ),
                      appointmentData(),
                      const SizedBox(
                        height: 4.0,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            if (_facilityAppointmentDetailModel!.paymentTransaction != null &&
                                _facilityAppointmentDetailModel!.paymentTransaction!.isNotEmpty) {
                              showModalBottomSheet(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                                  ),
                                  context: context,
                                  isDismissible: true,
                                  enableDrag: true,
                                  isScrollControlled: false,
                                  builder: (BuildContext ctx) {
                                    List<PaymentTransaction> tempList = [];
                                    for (int i = 0; i < _facilityAppointmentDetailModel!.paymentTransaction!.length; i++) {
                                      if (_facilityAppointmentDetailModel!.paymentTransaction![i].status == 'A' ||
                                          _facilityAppointmentDetailModel!.paymentTransaction![i].status == 'P') {
                                        tempList.add(_facilityAppointmentDetailModel!.paymentTransaction![i]);
                                      }
                                    }
                                    return _facilityTransactionBottomSheet(ctx, _facilityAppointmentDetailModel!.paymentTransaction);
                                  });
                            } else {
                              showSnackBar('No history found!', context);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 20, 4),
                            child: CustomTextView(
                              label: 'View Transaction History',
                              textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        child: CustomTextView(
                          label: 'Name: ${_facilityAppointmentDetailModel!.endUserFirstName} ${_facilityAppointmentDetailModel!.endUserLastName}',
                          textStyle:
                              Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        child: CustomTextView(
                          label: 'Email ID: ${_facilityAppointmentDetailModel!.endUserEmail}',
                          textStyle:
                              Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        child: CustomTextView(
                          label: 'Phone number: ${_facilityAppointmentDetailModel!.endUserMobileNumber}',
                          textStyle:
                              Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        child: CustomTextView(
                          label: _facilityAppointmentDetailModel!.bookingType == 'I' ? 'Booking For: Individual' : 'Booking For: Group',
                          textStyle:
                              Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        child: CustomTextView(
                          label: 'Address: ${_facilityAppointmentDetailModel!.address}',
                          maxLine: 3,
                          textOverFlow: TextOverflow.ellipsis,
                          textStyle:
                              Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        child: Row(
                          children: [
                            CustomTextView(
                              label: 'Order Id: ',
                              maxLine: 3,
                              textOverFlow: TextOverflow.ellipsis,
                              textStyle:
                                  Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w600),
                            ),
                            CustomTextView(
                              label: '${_facilityAppointmentDetailModel!.bookingNo}',
                              maxLine: 3,
                              textOverFlow: TextOverflow.ellipsis,
                              textStyle:
                                  Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: _facilityAppointmentDetailModel!.facilityBookingSlotDates!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: ((context, index) {
                          return singleAppointmentsData(index);
                        }),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        child: _paymentSummaryView(),
                      ),
                    ],
                  ),
                )
              : Container(),
        ),
      ),
    );
  }

  Widget bottomView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _paymentSummaryView(),
        // CustomTextView(
        //   label: 'Status: BLOCKED',
        //   textStyle: Theme.of(context)
        //       .textTheme
        //       .titleMedium!
        //       .copyWith(fontWeight: FontWeight.w600, color: OQDOThemeData.greyColor, fontSize: 18.0),
        // ),
        // const SizedBox(
        //   height: 10.0,
        // ),
        // CustomTextView(
        //   label: 'Order ID: ${_facilityAppointmentDetailModel!.bookingNo}',
        //   textStyle:
        //       Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor, fontSize: 18.0),
        // ),
        // const SizedBox(
        //   height: 12.0,
        // ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     CustomTextView(
        //       label: 'Total Amount',
        //       textStyle: Theme.of(context)
        //           .textTheme
        //           .titleMedium!
        //           .copyWith(fontWeight: FontWeight.w600, color: OQDOThemeData.greyColor, fontSize: 18.0),
        //     ),
        //     CustomTextView(
        //       label: 'S\$ ${_facilityAppointmentDetailModel!.totalAmt}',
        //       textStyle: Theme.of(context)
        //           .textTheme
        //           .titleMedium!
        //           .copyWith(fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor, fontSize: 18.0),
        //     ),
        //   ],
        // ),
        const SizedBox(
          height: 50.0,
        ),
      ],
    );
  }

  Widget singleAppointmentsData(int index) {
    var finalAmount = _facilityAppointmentDetailModel!.facilityBookingSlotDates![index].amount! +
        _facilityAppointmentDetailModel!.facilityBookingSlotDates![index].discountAmount!;
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10.0,
                  ),
                  CustomTextView(
                    label:
                        '${convertDateToString(_facilityAppointmentDetailModel!.facilityBookingSlotDates![index].bookingDate!).split(',')[1].split(' ')[2]} ${convertDateToString(_facilityAppointmentDetailModel!.facilityBookingSlotDates![index].bookingDate!).split(',')[1].split(' ')[1]} - ${convertDateToString(_facilityAppointmentDetailModel!.facilityBookingSlotDates![index].bookingDate!).split(',')[0]}',
                    textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20.0, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomTextView(
                        label:
                            '${_facilityAppointmentDetailModel!.facilityBookingSlotDates![index].startTime}-${_facilityAppointmentDetailModel!.facilityBookingSlotDates![index].endTime}',
                        textStyle:
                            Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 16.0, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      CustomTextView(
                        label: 'S\$ ${_facilityAppointmentDetailModel!.facilityBookingSlotDates![index].ratePerHour}/hour',
                        textStyle:
                            Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 16.0, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
              Column(
                children: [
                  _facilityAppointmentDetailModel!.facilityBookingSlotDates![index].isCancelled!
                      ? CustomTextView(
                          label: 'Cancelled',
                          textStyle:
                              Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 14.0, color: OQDOThemeData.errorColor, fontWeight: FontWeight.w500),
                        )
                      : const SizedBox(),
                  const SizedBox(
                    height: 4,
                  ),
                  CustomTextView(
                    label: 'S\$ ${finalAmount.toStringAsFixed(2)}',
                    textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20.0, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          const Divider(
            thickness: 1.0,
            color: Color(0xFFEFEFEF),
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

  Widget _paymentSummaryView() {
    return Container(
      decoration: BoxDecoration(
        color: OQDOThemeData.whiteColor,
        border: Border.all(color: OQDOThemeData.otherTextColor),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextView(
            label: 'Booking Amount',
            textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: OQDOThemeData.buttonColor,
                ),
          ),
          const SizedBox(
            height: 10,
          ),
          _buildTitleDetailsRow(title: "Paid", details: "Order fees", rate: paidAmount.toStringAsFixed(2)),
          const SizedBox(
            height: 10,
          ),
          _buildTitleDetailsRow(title: "Pay later", details: "Balance to be paid directly to the service provider", rate: payLaterAmount.toStringAsFixed(2)),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextView(
                label: "Total Amount : ",
                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 16.0, fontWeight: FontWeight.w600, color: OQDOThemeData.blackColor),
              ),
              Column(
                children: [
                  CustomTextView(
                    label: 'S\$ ${totalAmount.toStringAsFixed(2)}',
                    textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14.0, fontWeight: FontWeight.w600, color: OQDOThemeData.blackColor),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  _buildTitleDetailsRow({required String title, required String details, required String rate}) {
    return Column(
      children: [
        Row(
          children: [
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextView(
                    label: title,
                    textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14.0, fontWeight: FontWeight.w600, color: OQDOThemeData.blackColor),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  CustomTextView(
                    label: details,
                    maxLine: 2,
                    textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 12.0, fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor),
                  ),
                ],
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomTextView(
                    label: 'S\$ $rate',
                    maxLine: 2,
                    textOverFlow: TextOverflow.ellipsis,
                    textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 13.0, fontWeight: FontWeight.w600, color: OQDOThemeData.blackColor),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 3,
        ),
        const Divider(
          color: OQDOThemeData.greyColor,
        ),
      ],
    );
  }

  // _buildTitleDetailsRow({required String title, required String details, required String rate}) {
  //   return Column(
  //     children: [
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               CustomTextView(
  //                 label: title,
  //                 textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14.0, fontWeight: FontWeight.w600, color: OQDOThemeData.blackColor),
  //               ),
  //               const SizedBox(
  //                 height: 3,
  //               ),
  //               CustomTextView(
  //                 label: details,
  //                 maxLine: 2,
  //                 textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 12.0, fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor),
  //               ),
  //             ],
  //           ),
  //           Column(
  //             children: [
  //               CustomTextView(
  //                 label: 'S\$ $rate',
  //                 textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 13.0, fontWeight: FontWeight.w600, color: OQDOThemeData.blackColor),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //       const SizedBox(
  //         height: 3,
  //       ),
  //       const Divider(
  //         color: OQDOThemeData.greyColor,
  //       ),
  //     ],
  //   );
  // }

  Widget appointmentData() {
    return SizedBox(
      height: 120.0,
      child: Container(
        padding: const EdgeInsets.all(2.0),
        child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 4.0,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border.all(width: 7.0, color: const Color.fromRGBO(0, 101, 144, 0.5)),
                ),
              ),
              const SizedBox(
                width: 30.0,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CustomTextView(
                  //   label: '${_facilityAppointmentDetailModel!.facilityName}',
                  //   textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w500, fontSize: 18.0, color: OQDOThemeData.greyColor),
                  // ),
                  // const SizedBox(
                  //   height: 8.0,
                  // ),
                  CustomTextView(
                    label: '${_facilityAppointmentDetailModel!.facilitySetupTitle!.trim()}\n${_facilityAppointmentDetailModel!.facilitySetupSubTitle!.trim()}',
                    maxLine: 3,
                    textOverFlow: TextOverflow.ellipsis,
                    textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w500, fontSize: 16.0, color: OQDOThemeData.greyColor),
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  CustomTextView(
                    label: '${_facilityAppointmentDetailModel!.activityName} - ${_facilityAppointmentDetailModel!.subActivityName}',
                    textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 14.0, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Widget appointmentData() {
  //   return SizedBox(
  //     height: 120.0,
  //     child: Container(
  //       padding: const EdgeInsets.all(2.0),
  //       child: Card(
  //         semanticContainer: true,
  //         clipBehavior: Clip.antiAliasWithSaveLayer,
  //         elevation: 4.0,
  //         shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
  //         child: Row(
  //           children: [
  //             Container(
  //               decoration: BoxDecoration(
  //                 shape: BoxShape.rectangle,
  //                 border: Border.all(width: 7.0, color: const Color.fromRGBO(0, 101, 144, 0.5)),
  //               ),
  //             ),
  //             const SizedBox(width: 20.0),
  //             Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 CustomTextView(
  //                   label:
  //                       '${_facilityAppointmentDetailModel!.endUserFirstName} ${_facilityAppointmentDetailModel!.endUserLastName}',
  //                   textStyle: Theme.of(context)
  //                       .textTheme
  //                       .titleSmall!
  //                       .copyWith(fontWeight: FontWeight.w500, fontSize: 16.0, color: OQDOThemeData.greyColor),
  //                 ),
  //                 const SizedBox(
  //                   height: 8.0,
  //                 ),
  //                 CustomTextView(
  //                   label: 'Email ID : ${_facilityAppointmentDetailModel!.endUserEmail}',
  //                   maxLine: 1,
  //                   textOverFlow: TextOverflow.ellipsis,
  //                   textStyle: Theme.of(context)
  //                       .textTheme
  //                       .titleMedium!
  //                       .copyWith(fontSize: 12, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w400),
  //                 ),
  //                 const SizedBox(
  //                   height: 5,
  //                 ),
  //                 CustomTextView(
  //                   label: 'Phone : ${_facilityAppointmentDetailModel!.endUserMobileNumber}',
  //                   maxLine: 1,
  //                   textOverFlow: TextOverflow.ellipsis,
  //                   textStyle: Theme.of(context)
  //                       .textTheme
  //                       .titleMedium!
  //                       .copyWith(fontSize: 12, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w400),
  //                 ),
  //               ],
  //             ),
  //             const Spacer(),
  //             Padding(
  //               padding: const EdgeInsets.only(right: 10.0),
  //               child: CustomTextView(
  //                 label: 'Order ID: ${_facilityAppointmentDetailModel!.bookingNo}',
  //                 textStyle: Theme.of(context)
  //                     .textTheme
  //                     .bodySmall!
  //                     .copyWith(fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor, fontSize: 15.0),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Future<void> getFacilityAppointmentDetails() async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait...");
    try {
      await _progressDialog.show();
      FacilityAppointmentDetailModel facilityAppointmentDetailModel =
          await Provider.of<AppointmentViewModel>(context, listen: false).getFacilityAppointmentDetail(widget.bookingId!);
      if (!mounted) return;
      await _progressDialog.hide();
      if (facilityAppointmentDetailModel.facilityBookingId != null) {
        setState(() {
          _facilityAppointmentDetailModel = facilityAppointmentDetailModel;
        });
        double tempTotalAmount = 0.0;
        double tempPaidAmount = 0.0;
        double tempPayLaterAmount = 0.0;
        if (_facilityAppointmentDetailModel?.facilityBookingSlotDates != null) {
          for (var slot in _facilityAppointmentDetailModel!.facilityBookingSlotDates!) {
            if (!slot.isCancelled!) {
              tempTotalAmount += slot.totalAmount ?? 0.0;
              tempPaidAmount = tempPaidAmount + ((slot.amount ?? 0.0) + (slot.discountAmount ?? 0.00));
              tempPayLaterAmount += slot.totalAmount! - (slot.amount! + slot.discountAmount!);
            }
          }

          setState(() {
            totalAmount = tempTotalAmount;
            paidAmount = tempPaidAmount;
            payLaterAmount = tempPayLaterAmount;
            if (payLaterAmount.isNegative) {
              payLaterAmount = 0.0;
            }
          });
        }
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
      if (!mounted) return;
      debugPrint(error.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  Widget _facilityTransactionBottomSheet(
    BuildContext context,
    List<PaymentTransaction>? paymentTransaction,
  ) {
    return SafeArea(
        child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onBackground,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: CustomTextView(
                label: 'Transaction History',
                textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20, color: OQDOThemeData.blackColor, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Expanded(
            child: ListView.separated(
              // key: UniqueKey(),
              // physics: const AlwaysScrollableScrollPhysics(),
              //  controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: paymentTransaction!.length,
              itemBuilder: (BuildContext context, int index) {
                DateTime tempDate = DateFormat("yyyy-MM-dd'T'hh:mm:ss").parse(paymentTransaction[index].createdAt.toString());
                DateTime bookDate = DateFormat("yyyy-MM-dd'T'hh:mm:ss").parse(paymentTransaction[index].bookingDate.toString());
                String formattedDate = DateFormat('dd MMMM yyyy, E').format(tempDate);
                String bookFormatDate = DateFormat('dd/MM/yyyy').format(bookDate);

                String time = DateFormat.jm().format(DateTime.parse(paymentTransaction[index].createdAt.toString()));
                var tempAmount = paymentTransaction[index].amount;
                var tempTotalAmount = paymentTransaction[index].totalAmount;
                double payLaterAmount = 0.0;

                if (tempAmount != null && tempTotalAmount != null) {
                  payLaterAmount = tempTotalAmount - (tempAmount + paymentTransaction[index].transactionDiscountAmount!);
                  if (payLaterAmount.isNegative) {
                    payLaterAmount = 0.0;
                  }
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 4, 16, 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              "$formattedDate $time",
                              style: TextStyle(fontWeight: FontWeight.w600, color: ColorsUtils.greyText, fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          // Text(
                          //   '\$ ${paymentTransaction[index].amount}',
                          //   maxLines: 3,
                          //   style: TextStyle(
                          //       fontSize: 15,
                          //       color: ColorsUtils.greyAmount,
                          //       fontWeight: FontWeight.w600),
                          //   overflow: TextOverflow.ellipsis,
                          // ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 1, 8, 0),
                            child: Text(
                              paymentTransaction[index].isRefund == true ? "Refunded" : "Paid",
                              maxLines: 3,
                              style: TextStyle(
                                  fontSize: 15,
                                  color: paymentTransaction[index].isRefund == false ? ColorsUtils.greenAmount : ColorsUtils.redAmount,
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                            child: Text(
                              paymentTransaction[index].setupName ?? "",
                              maxLines: 3,
                              style: TextStyle(fontSize: 14, color: ColorsUtils.greyText, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 6, 16, 0),
                        child: Text(
                          'Transaction ID : ${paymentTransaction[index].trasactionId.toString()}',
                          maxLines: 3,
                          style: TextStyle(fontSize: 14, color: ColorsUtils.greyText, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Visibility(
                        visible: paymentTransaction[index].isRefund == true,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 2,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 6, 16, 0),
                              child: Text(
                                'Rate : S\$ ${paymentTransaction[index].ratePerHour}/hour',
                                maxLines: 3,
                                style: TextStyle(fontSize: 14, color: ColorsUtils.greyText, fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: paymentTransaction[index].isRefund ?? false,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 6, 8, 0),
                              child: Text(
                                "Slot Date : ${bookFormatDate.toString()},",
                                maxLines: 3,
                                style: TextStyle(fontSize: 14, color: ColorsUtils.greyText, fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                              child: Text(
                                "${paymentTransaction[index].startTime.toString()} - ${paymentTransaction[index].endTime.toString()}",
                                maxLines: 3,
                                style: TextStyle(fontSize: 14, color: ColorsUtils.greyText, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 6, 16, 0),
                        child: Text(
                          'Amount : S\$ ${paymentTransaction[index].amount?.toStringAsFixed(2) ?? 0.0} ( Order fees )',
                          maxLines: 3,
                          style: TextStyle(fontSize: 14, color: ColorsUtils.greyText, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 6, 16, 0),
                        child: Row(
                          children: [
                            Text(
                              'Payment Status : ',
                              maxLines: 3,
                              style: TextStyle(fontSize: 14, color: ColorsUtils.greyText, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              paymentTransaction[index].status == 'A'
                                  ? 'Success'
                                  : paymentTransaction[index].status == 'P'
                                      ? 'Pending'
                                      : 'Failed',
                              maxLines: 3,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: paymentTransaction[index].status == 'A'
                                      ? ColorsUtils.greenAmount
                                      : paymentTransaction[index].status == 'P'
                                          ? Colors.yellow
                                          : ColorsUtils.redAmount,
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 6, 16, 0),
                        child: Text(
                          'Amount : S\$ ${payLaterAmount.toStringAsFixed(2)} ( Balance Amount Pay Later )',
                          maxLines: 3,
                          style: TextStyle(fontSize: 14, color: ColorsUtils.greyText, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 6, 16, 0),
                        child: Row(
                          children: [
                            Text(
                              'Payment Status : ',
                              maxLines: 3,
                              style: TextStyle(fontSize: 14, color: ColorsUtils.greyText, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Out Of OQDO',
                              maxLines: 3,
                              style: TextStyle(
                                fontSize: 14,
                                color: ColorsUtils.yellowStatus,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Visibility(
                        visible: paymentTransaction[index].isRefund ?? false,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 2,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 6, 8, 0),
                                  child: Text(
                                    "Reason: ",
                                    maxLines: 3,
                                    style: TextStyle(fontSize: 14, color: ColorsUtils.greyText, fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                                  child: Text(
                                    "${paymentTransaction[index].cancelreason != null && paymentTransaction[index].cancelreason!.isNotEmpty ? paymentTransaction[index].cancelreason : paymentTransaction[index].otherReason ?? ""}",
                                    maxLines: 3,
                                    style: TextStyle(fontSize: 14, color: ColorsUtils.greyText, fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
                //   Padding(
                //   padding: const EdgeInsets.fromLTRB(16.0, 4, 16, 4),
                //   child: Column(
                //     mainAxisAlignment: MainAxisAlignment.start,
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.start,
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           Expanded(
                //             child: Text(
                //               "$formattedDate   $time",
                //               style: TextStyle(fontWeight: FontWeight.w600, color: ColorsUtils.greyText, fontSize: 15),
                //               overflow: TextOverflow.ellipsis,
                //             ),
                //           ),
                //           const SizedBox(
                //             width: 12,
                //           ),
                //           Padding(
                //             padding: const EdgeInsets.fromLTRB(0, 1, 8, 0),
                //             child: Text(
                //               paymentTransaction[index].isRefund == true ? "Refunded" : "Paid",
                //               maxLines: 3,
                //               style: TextStyle(
                //                   fontSize: 15,
                //                   color: paymentTransaction[index].isRefund == false ? ColorsUtils.greenAmount : ColorsUtils.redAmount,
                //                   fontWeight: FontWeight.w500),
                //               overflow: TextOverflow.ellipsis,
                //             ),
                //           ),
                //         ],
                //       ),
                //       const SizedBox(
                //         height: 1,
                //       ),
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.start,
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           Padding(
                //             padding: const EdgeInsets.fromLTRB(0, 6, 8, 0),
                //             child: Text(
                //               paymentTransaction[index].setupName.toString(),
                //               maxLines: 3,
                //               style: TextStyle(fontSize: 14, color: ColorsUtils.greyText, fontWeight: FontWeight.w500),
                //               overflow: TextOverflow.ellipsis,
                //             ),
                //           ),
                //         ],
                //       ),
                //       Padding(
                //         padding: const EdgeInsets.fromLTRB(0, 6, 16, 0),
                //         child: Text(
                //           'Transaction ID : ${paymentTransaction[index].trasactionId.toString()}',
                //           maxLines: 3,
                //           style: TextStyle(fontSize: 14, color: ColorsUtils.greyText, fontWeight: FontWeight.w500),
                //           overflow: TextOverflow.ellipsis,
                //         ),
                //       ),
                //       const SizedBox(
                //         height: 2,
                //       ),
                //       Padding(
                //         padding: const EdgeInsets.fromLTRB(0, 6, 16, 0),
                //         child: Text(
                //           'Amount : S\$${paymentTransaction[index].amount.toString()}',
                //           maxLines: 3,
                //           style: TextStyle(fontSize: 14, color: ColorsUtils.greyText, fontWeight: FontWeight.w500),
                //           overflow: TextOverflow.ellipsis,
                //         ),
                //       ),
                //       const SizedBox(
                //         height: 2,
                //       ),
                //       Padding(
                //         padding: const EdgeInsets.fromLTRB(0, 6, 16, 0),
                //         child: Row(
                //           children: [
                //             Text(
                //               'Payment Status : ',
                //               maxLines: 3,
                //               style: TextStyle(fontSize: 14, color: ColorsUtils.greyAmount, fontWeight: FontWeight.w500),
                //               overflow: TextOverflow.ellipsis,
                //             ),
                //             Text(
                //               paymentTransaction[index].status == 'A'
                //                   ? 'Success'
                //                   : paymentTransaction[index].status == 'P'
                //                       ? 'Pending'
                //                       : 'Failed',
                //               maxLines: 3,
                //               style: TextStyle(
                //                   fontSize: 14,
                //                   color: paymentTransaction[index].status == 'A'
                //                       ? ColorsUtils.greenAmount
                //                       : paymentTransaction[index].status == 'P'
                //                           ? Colors.yellow
                //                           : ColorsUtils.redAmount,
                //                   fontWeight: FontWeight.w500),
                //               overflow: TextOverflow.ellipsis,
                //             ),
                //           ],
                //         ),
                //       ),
                //       const SizedBox(
                //         height: 2,
                //       ),
                //       Visibility(
                //         visible: paymentTransaction[index].isRefund!,
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.start,
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Padding(
                //               padding: const EdgeInsets.fromLTRB(0, 6, 8, 0),
                //               child: Text(
                //                 "Slot Date : ${bookFormatDate.toString()},",
                //                 maxLines: 3,
                //                 style: TextStyle(fontSize: 14, color: ColorsUtils.greyText, fontWeight: FontWeight.w500),
                //                 overflow: TextOverflow.ellipsis,
                //               ),
                //             ),
                //             Padding(
                //               padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                //               child: Text(
                //                 "${paymentTransaction[index].startTime.toString()} - ${paymentTransaction[index].endTime.toString()}",
                //                 maxLines: 3,
                //                 style: TextStyle(
                //                   fontSize: 14,
                //                   color: ColorsUtils.greyText,
                //                   fontWeight: FontWeight.w600,
                //                 ),
                //                 overflow: TextOverflow.ellipsis,
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // );
              },
              separatorBuilder: (context, index) {
                return const Divider();
              },
            ),
          ),
        ],
      ),
    ));
  }
}
