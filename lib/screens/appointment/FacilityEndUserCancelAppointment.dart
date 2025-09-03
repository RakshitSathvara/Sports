// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/model/CancelFacilityAppointmentModel.dart';
import 'package:oqdo_mobile_app/model/end_user_appointment_model_details.dart';
import 'package:oqdo_mobile_app/model/facility_appointment_details_model.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/theme/app_colors.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:oqdo_mobile_app/viewmodels/appointment_view_model.dart';
import 'package:provider/provider.dart';

class FacilityEndUserCancelAppointment extends StatefulWidget {
  EndUserAppointmentPassingModel? model;
  FacilityEndUserCancelAppointment({Key? key, this.model}) : super(key: key);

  @override
  State<FacilityEndUserCancelAppointment> createState() => _FacilityEndUserCancelAppointmentState();
}

class _FacilityEndUserCancelAppointmentState extends State<FacilityEndUserCancelAppointment> {
  FacilityAppointmentDetailModel? _facilityAppointmentDetailModel;
  List<FacilityBookingSlotDates> bookingSlotList = [];
  double totalRefundAmount = 0.00;
  double totalDiscountAmount = 0.00;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getFacilityAppointmentDetails();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          child: _facilityAppointmentDetailModel != null
              ? Column(
                  children: [
                    Expanded(
                      child: Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        child: SingleChildScrollView(
                          controller: _scrollController,
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
                                      '${_facilityAppointmentDetailModel!.facilitySetupTitle!.trim()} - ${_facilityAppointmentDetailModel!.facilitySetupSubTitle!.trim()}',
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(fontSize: 20, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w500),
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: CustomTextView(
                                  label: '${_facilityAppointmentDetailModel!.activityName} - ${_facilityAppointmentDetailModel!.subActivityName}',
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(fontSize: 16, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w500),
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
                                  label: 'Order ID: ${_facilityAppointmentDetailModel!.bookingNo}',
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontSize: 14, color: AppColors.greyText, fontWeight: FontWeight.w400),
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20, right: 20),
                                child: CustomTextView(
                                  label: 'Name: ${_facilityAppointmentDetailModel!.facilityName}',
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontSize: 14, color: AppColors.greyText, fontWeight: FontWeight.w400),
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20, right: 20),
                                child: CustomTextView(
                                  label: 'Email ID: ${_facilityAppointmentDetailModel!.facilityEmail}',
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontSize: 14, color: AppColors.greyText, fontWeight: FontWeight.w400),
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20, right: 20),
                                child: CustomTextView(
                                  label: 'Phone number: ${_facilityAppointmentDetailModel!.facilityMobileNumber}',
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontSize: 14, color: AppColors.greyText, fontWeight: FontWeight.w400),
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20, right: 20),
                                child: CustomTextView(
                                  label: _facilityAppointmentDetailModel!.bookingType == 'I' ? 'Booking For: Individual' : 'Booking For: Group',
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontSize: 14, color: AppColors.greyText, fontWeight: FontWeight.w400),
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20, right: 20),
                                child: CustomTextView(
                                  label: 'Address: ${_facilityAppointmentDetailModel!.address}',
                                  maxLine: 3,
                                  textOverFlow: TextOverflow.ellipsis,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontSize: 14, color: AppColors.greyText, fontWeight: FontWeight.w400),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Divider(
                                height: 1,
                                color: AppColors.greyText.withOpacity(0.5),
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: bookingSlotList.length,
                                itemBuilder: ((context, index) {
                                  return reviewAppointmentListView(index);
                                }),
                              ),
                              const SizedBox(height: 50.0),
                              Padding(
                                padding: const EdgeInsets.only(left: 20, right: 20),
                                child: Row(
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
                                      label: 'S\$ ${totalRefundAmount.toStringAsFixed(2)}',
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15.0),
                              const Divider(
                                height: 1,
                                color: OQDOThemeData.greyColor,
                              ),
                              const SizedBox(height: 15.0),
                              Padding(
                                padding: const EdgeInsets.only(left: 20, right: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomTextView(
                                      label: 'Coupon Discount',
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(fontSize: 16.0, fontWeight: FontWeight.w500, color: OQDOThemeData.blackColor),
                                    ),
                                    CustomTextView(
                                      label: 'S\$ ${totalDiscountAmount.toStringAsFixed(2)}',
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(fontSize: 16.0, fontWeight: FontWeight.w500, color: OQDOThemeData.blackColor),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15.0),
                              const Divider(
                                height: 1,
                                color: OQDOThemeData.greyColor,
                              ),
                              const SizedBox(height: 20.0),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CustomTextView(
                                      label: 'Cancellation/Refund Policy:',
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(fontSize: 14.0, fontWeight: FontWeight.w600, color: ColorsUtils.redColor),
                                    ),
                                    const SizedBox(
                                      height: 6.0,
                                    ),
                                    CustomTextView(
                                      maxLine: 2,
                                      label:
                                          'Refundable if slot booking is cancelled ${_facilityAppointmentDetailModel!.cancellationPolicyTime} hours before start time',
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 120.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: MyButton(
                        text: 'Review Cancellation',
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
                          if (isAnySlotSelected()) {
                            CancelFacilityAppointmentModel cancelFacilityAppointmentModel = CancelFacilityAppointmentModel();
                            cancelFacilityAppointmentModel.facilityAppointmentDetailModel = _facilityAppointmentDetailModel;
                            cancelFacilityAppointmentModel.list = bookingSlotList;
                            await Navigator.of(context).pushNamed(Constants.facilityCancelAppointmentReason, arguments: cancelFacilityAppointmentModel);
                          } else {
                            showSnackBar('Select slot', context);
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 15.0,
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

  Widget reviewAppointmentListView(int index) {
    return Container(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Transform.scale(
                  scale: 1.3,
                  child: Checkbox(
                      fillColor: MaterialStateProperty.resolveWith(Utils.getColor),
                      checkColor: Theme.of(context).colorScheme.primaryContainer,
                      value: bookingSlotList[index].isSlotSelected,
                      onChanged: (value) {
                        if (value!) {
                          setState(() {
                            bookingSlotList[index].isSlotSelected = value;
                            totalAmountCalculation(value, bookingSlotList[index].amount, bookingSlotList[index].discountAmount);
                          });
                        } else {
                          setState(() {
                            bookingSlotList[index].isSlotSelected = value;
                            totalAmountCalculation(value, bookingSlotList[index].amount, bookingSlotList[index].discountAmount);
                          });
                        }
                      }),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextView(
                        maxLine: 2,
                        textOverFlow: TextOverflow.ellipsis,
                        label:
                            '${convertDateToString(bookingSlotList[index].bookingDate!).split(',')[1].split(' ')[2]} ${convertDateToString(bookingSlotList[index].bookingDate!).split(',')[1].split(' ')[1]} - ${convertDateToString(bookingSlotList[index].bookingDate!).split(',')[0]}',
                        textStyle:
                            Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 18.0, fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CustomTextView(
                            label: '${bookingSlotList[index].startTime} - ${bookingSlotList[index].endTime}',
                            textStyle:
                                Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 12.0, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          CustomTextView(
                            label: 'S\$ ${bookingSlotList[index].ratePerHour?.toStringAsFixed(2) ?? 0.00}/hour',
                            textStyle:
                                Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 12.0, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                CustomTextView(
                  label: 'Refund Amount: ',
                  textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 10.0, fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor),
                ),
                CustomTextView(
                  label: 'S\$ ${bookingSlotList[index].amount?.toStringAsFixed(2) ?? 0.00}',
                  textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 12.0, fontWeight: FontWeight.w500, color: OQDOThemeData.buttonColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void totalAmountCalculation(bool isSelected, double? amount, double? discountAmount) {
    if (isSelected) {
      setState(() {
        totalRefundAmount = double.parse(totalRefundAmount.toStringAsFixed(2)) + amount!;
        totalDiscountAmount = double.parse(totalDiscountAmount.toStringAsFixed(2)) + discountAmount!;
      });
    } else {
      setState(() {
        totalRefundAmount = double.parse(totalRefundAmount.toStringAsFixed(2)) - amount!;
        totalDiscountAmount = double.parse(totalDiscountAmount.toStringAsFixed(2)) - discountAmount!;
      });
    }
    debugPrint("Total refund amount is ===> $totalRefundAmount Amount is $amount");
  }

  String convertDateToString(String date) {
    String parsingDate = '';
    DateTime dateTime = DateFormat('yyyy-MM-dd').parse(date);
    parsingDate = DateFormat.yMMMMEEEEd().format(dateTime);
    return parsingDate;
  }

  bool isAnySlotSelected() {
    bool isFacilitySelected = false;
    for (int i = 0; i < bookingSlotList.length; i++) {
      if (bookingSlotList[i].isSlotSelected!) {
        isFacilitySelected = true;
        break;
      }
    }
    return isFacilitySelected;
  }

  Future<void> getFacilityAppointmentDetails() async {
    try {
      FacilityAppointmentDetailModel facilityAppointmentDetailModel =
          await Provider.of<AppointmentViewModel>(context, listen: false).getFacilityAppointmentDetail(widget.model!.bookingId!);
      if (facilityAppointmentDetailModel.facilityBookingId != null) {
        setState(() {
          var data = Duration(minutes: OQDOApplication.instance.configResponseModel!.cancelApplicableMinAfterEndTime);
          showLog('IN HOURS -> ${data.inHours}');
          _facilityAppointmentDetailModel = facilityAppointmentDetailModel;
          bookingSlotList.clear();
          double tempTotalRefundAmount = 0.00;
          double tempTotalDiscountAmount = 0.00;
          String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
          debugPrint('date -> ${widget.model!.selectedDate}');
          for (var i = 0; i < _facilityAppointmentDetailModel!.facilityBookingSlotDates!.length; i++) {
            if (_facilityAppointmentDetailModel!.facilityBookingSlotDates![i].bookingDate!.split('T')[0].compareTo(currentDate) < 0) {
              showLog(_facilityAppointmentDetailModel!.facilityBookingSlotDates![i].bookingDate!.toString());
              setState(() {
                _facilityAppointmentDetailModel!.facilityBookingSlotDates![i].isCancelled = true;
              });
            } else if (_facilityAppointmentDetailModel!.facilityBookingSlotDates![i].bookingDate!.split('T')[0].compareTo(currentDate) == 0) {
              if (_facilityAppointmentDetailModel!.facilityBookingSlotDates![i].isCancelled!) {
                setState(() {
                  _facilityAppointmentDetailModel!.facilityBookingSlotDates![i].isCancelled = true;
                });
              } else {
                showLog(_facilityAppointmentDetailModel!.facilityBookingSlotDates![i].bookingDate!.toString());
                String time = DateTime.now().toString();
                debugPrint('Time -> $time');
                String minutes = time.split(' ')[1].split('.')[0].split(':')[0];
                String seconds = time.split(' ')[1].split('.')[0].split(':')[1];
                int finalMinutes = int.parse(minutes);
                debugPrint('finalMinutes -> $finalMinutes');
                String finalTime = '$finalMinutes:$seconds';
                debugPrint('Time -> $finalTime');
                Duration currentTimeDuration = Duration(hours: int.parse(minutes), minutes: int.parse(seconds));
                String endMinutes = _facilityAppointmentDetailModel!.facilityBookingSlotDates![i].endTime!.split(':')[0];
                String endSeconds = _facilityAppointmentDetailModel!.facilityBookingSlotDates![i].endTime!.split(':')[1];
                int finalEndMinutes = int.parse(endMinutes) + data.inHours;

                Duration endTimeDuration = Duration(hours: int.parse(endMinutes) + data.inHours, minutes: int.parse(endSeconds));
                showLog('End Final Time -> $finalEndMinutes');
                String finalEndTime = '$finalEndMinutes:$endSeconds';

                debugPrint('End Final Time -> $finalEndTime');
                if (currentTimeDuration.compareTo(endTimeDuration) < 0) {
                  if (_facilityAppointmentDetailModel!.facilityBookingSlotDates![i].amount! > 0) {
                    setState(() {
                      bookingSlotList.add(_facilityAppointmentDetailModel!.facilityBookingSlotDates![i]);
                      tempTotalRefundAmount += _facilityAppointmentDetailModel!.facilityBookingSlotDates![i].amount ?? 0;
                      tempTotalDiscountAmount += _facilityAppointmentDetailModel!.facilityBookingSlotDates![i].discountAmount ?? 0;
                    });
                  }
                }
              }
            } else if (_facilityAppointmentDetailModel!.facilityBookingSlotDates![i].bookingDate!.split('T')[0].compareTo(currentDate) > 0) {
              if (_facilityAppointmentDetailModel!.facilityBookingSlotDates![i].isCancelled!) {
                setState(() {
                  _facilityAppointmentDetailModel!.facilityBookingSlotDates![i].isCancelled = true;
                });
              } else {
                if (_facilityAppointmentDetailModel!.facilityBookingSlotDates![i].amount! > 0) {
                  setState(() {
                    bookingSlotList.add(_facilityAppointmentDetailModel!.facilityBookingSlotDates![i]);
                    tempTotalRefundAmount += _facilityAppointmentDetailModel!.facilityBookingSlotDates![i].amount ?? 0;
                    tempTotalDiscountAmount += _facilityAppointmentDetailModel!.facilityBookingSlotDates![i].discountAmount ?? 0;
                  });
                }
              }
            }
          }
          setState(() {
            totalRefundAmount = tempTotalRefundAmount;
            totalDiscountAmount = tempTotalDiscountAmount;
          });
          debugPrint('Booking slot list -> ${bookingSlotList.length}');
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
}
