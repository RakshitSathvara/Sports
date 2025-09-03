// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/model/coach_appointment_details_response_model.dart' as model;
import 'package:oqdo_mobile_app/model/end_user_appointment_model_details.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/extentions.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/viewmodels/appointment_view_model.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import '../../theme/oqdo_theme_data.dart';
import '../../utils/custom_text_view.dart';
import '../../utils/textfields_widget.dart';

class EndUserCoachAppointmentDetailsScreen extends StatefulWidget {
  EndUserAppointmentPassingModel? model;

  EndUserCoachAppointmentDetailsScreen({Key? key, this.model}) : super(key: key);

  @override
  State<EndUserCoachAppointmentDetailsScreen> createState() => _EndUserCoachAppointmentDetailsScreenState();
}

class _EndUserCoachAppointmentDetailsScreenState extends State<EndUserCoachAppointmentDetailsScreen> {
  TextEditingController feedback = TextEditingController();
  model.CoachAppointmentDetailResponseModel? coachAppointmentDetailResponseModel;
  List<model.CoachBookingSlotDates> bookingSlotList = [];
  double ratingValue = 0.00;
  late ProgressDialog _progressDialog;
  bool isButtonVisible = false;
  String addressData = '';
  double totalAmount = 0.00;
  double paidAmount = 0.00;
  double payLaterAmount = 0.00;
  double discountedAmount = 0.00;
  double bookingAmount = 0.00;
  double discountPer = 0.00;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getAppointmentDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarView(),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: OQDOThemeData.whiteColor,
          child: coachAppointmentDetailResponseModel != null
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20.0,
                      ),
                      appointmentData(),
                      const SizedBox(
                        height: 10,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            debugPrint("coach");
                            if (coachAppointmentDetailResponseModel!.paymentTransaction != null &&
                                coachAppointmentDetailResponseModel!.paymentTransaction!.isNotEmpty) {
                              showModalBottomSheet(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                                  ),
                                  context: context,
                                  isDismissible: true,
                                  enableDrag: true,
                                  isScrollControlled: false,
                                  builder: (BuildContext ctx) {
                                    List<model.PaymentTransaction> tempList = [];
                                    for (int i = 0; i < coachAppointmentDetailResponseModel!.paymentTransaction!.length; i++) {
                                      if (coachAppointmentDetailResponseModel!.paymentTransaction![i].status == 'A' ||
                                          coachAppointmentDetailResponseModel!.paymentTransaction![i].status == 'P') {
                                        tempList.add(coachAppointmentDetailResponseModel!.paymentTransaction![i]);
                                      }
                                    }
                                    return _coachTransactionBottomSheet(ctx, tempList);
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
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: CustomTextView(
                          label: 'Name: ${coachAppointmentDetailResponseModel!.coachFirstName} ${coachAppointmentDetailResponseModel!.coachLastName}',
                          textStyle:
                              Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: CustomTextView(
                          label: 'Email ID: ${coachAppointmentDetailResponseModel!.coachEmail}',
                          textStyle:
                              Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: CustomTextView(
                          label: 'Phone number: ${coachAppointmentDetailResponseModel!.coachMobileNumber}',
                          textStyle:
                              Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: CustomTextView(
                          label: coachAppointmentDetailResponseModel!.bookingType == 'I' ? 'Booking For: Individual' : 'Booking For: Group',
                          textStyle:
                              Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: CustomTextView(
                          label: 'Address: $addressData',
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
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: CustomTextView(
                          label: 'Order ID: ${coachAppointmentDetailResponseModel!.bookingNo}',
                          textStyle:
                              Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                        ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: bookingSlotList.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: ((context, index) {
                          return singleAppointmentsData(index);
                        }),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                        child: bottomView(),
                      ),
                    ],
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ),
    );
  }

  Widget bottomView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _paymentSummaryView(),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     CustomTextView(
        //       label: 'Total Amount',
        //       textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600, color: OQDOThemeData.greyColor, fontSize: 18.0),
        //     ),
        //     CustomTextView(
        //       label: 'S\$ ${coachAppointmentDetailResponseModel!.totalAmt}',
        //       textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor, fontSize: 18.0),
        //     ),
        //   ],
        // ),
        // const SizedBox(
        //   height: 20,
        // ),
        // CustomTextView(
        //   label: 'Order ID: ${coachAppointmentDetailResponseModel!.bookingNo}',
        //   textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor, fontSize: 15.0),
        // ),
        const SizedBox(
          height: 25.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                CustomTextView(
                  label: 'Add Feedback',
                  textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600, color: OQDOThemeData.greyColor, fontSize: 18.0),
                ),
                const SizedBox(
                  height: 10,
                ),
                RatingBar.builder(
                  initialRating: coachAppointmentDetailResponseModel!.coachBookingReviews != null
                      ? coachAppointmentDetailResponseModel!.coachBookingReviews!.rating!
                      : 0.0,
                  minRating: 0,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 23,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 15,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      ratingValue = rating;
                    });
                  },
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                if (ratingValue == 0.00) {
                  showSnackBar('Please provide a rating before submitting your feedback.', context);
                } else {
                  callAddRating();
                }
              },
              child: Container(
                height: 50,
                width: 150,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10), topRight: Radius.circular(10)),
                    border: Border.all(color: const Color(0xffF1F1F1)),
                    color: const Color(0xffEFEFEF).withOpacity(0.5)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add,
                      size: 20,
                      color: Color(0xFF006590),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    CustomTextView(
                      label: 'Add Feedback',
                      type: styleSubTitle,
                      textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: const Color(0xFF006590), fontSize: 14.0, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 30.0,
        ),
        CustomTextFormField(
          read: false,
          obscureText: false,
          labelText: 'Add Review',
          keyboardType: TextInputType.text,
          maxlines: 4,
          controller: feedback,
        ),
        // const SizedBox(
        //   height: 30,
        // ),
        // Align(
        //   alignment: Alignment.centerRight,
        //   child: SizedBox(
        //     width: 200,
        //     child: MyButton(
        //         text: 'Add Review',
        //         textcolor: Theme.of(context).colorScheme.onBackground,
        //         textsize: 20,
        //         fontWeight: FontWeight.w400,
        //         letterspacing: 1.2,
        //         buttonwidth: 400,
        //         buttonheight: 55,
        //         buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
        //         buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
        //         radius: 15,
        //         onTap: () {
        //           if (ratingValue == 0.00 || feedback.text.toString().trim().isEmpty) {
        //             Fluttertoast.showToast(msg: 'Please add rating', toastLength: Toast.LENGTH_SHORT);
        //           } else {
        //             callAddRating();
        //           }
        //         }),
        //   ),
        // ),
        const SizedBox(
          height: 30,
        ),
        isButtonVisible
            ? MyButton(
                text: 'Cancel Appointment',
                textcolor: Theme.of(context).colorScheme.onBackground,
                textsize: 16,
                fontWeight: FontWeight.w400,
                letterspacing: 1.2,
                buttonwidth: 200,
                buttonheight: 55,
                buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                radius: 15,
                onTap: () async {
                  EndUserAppointmentPassingModel endUserAppointmentPassingModel = EndUserAppointmentPassingModel();
                  endUserAppointmentPassingModel.type = 'C';
                  endUserAppointmentPassingModel.selectedDate = widget.model!.selectedDate;
                  endUserAppointmentPassingModel.day = widget.model!.day;
                  endUserAppointmentPassingModel.bookingId = widget.model!.bookingId.toString();
                  endUserAppointmentPassingModel.isCancel = widget.model!.isCancel;
                  await Navigator.pushNamed(context, Constants.coachEndUserCancelAppointment, arguments: endUserAppointmentPassingModel);
                },
              )
            : Container(),
        const SizedBox(
          height: 30,
        ),
        const SizedBox(
          height: 30,
        ),
      ],
    );
  }

  Widget singleAppointmentsData(int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
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
                        '${convertDateToString(bookingSlotList[index].bookingDate!).split(',')[1].split(' ')[2]} ${convertDateToString(bookingSlotList[index].bookingDate!).split(',')[1].split(' ')[1]} - ${convertDateToString(bookingSlotList[index].bookingDate!).split(',')[0]}',
                    textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20.0, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomTextView(
                        label: '${bookingSlotList[index].startTime}-${bookingSlotList[index].endTime}',
                        textStyle:
                            Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 16.0, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      CustomTextView(
                        label: 'S\$ ${bookingSlotList[index].ratePerHour?.toStringAsFixed(2) ?? 0.00}/hour',
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
                  bookingSlotList[index].isSlotCancelled!
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
                    label: 'S\$ ${bookingSlotList[index].amount?.toStringAsFixed(2) ?? 0.00}',
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

  void isAnySlotCancel() {
    if (bookingSlotList.isNotEmpty) {
      for (var i = 0; i < bookingSlotList.length; i++) {
        if (!bookingSlotList[i].isCancelled!) {
          isButtonVisible = true;
          break;
        }
      }
    }
  }

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
              const SizedBox(width: 20.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 4.0,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(100))),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: CustomTextView(
                        label: widget.model!.selectedDate!.split('-')[2].split('T')[0],
                        textStyle: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontWeight: FontWeight.w700, fontSize: 18.0, color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  CustomTextView(
                    label: widget.model!.day,
                    textStyle: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.w500, fontSize: 16.0, color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
              const SizedBox(
                width: 30.0,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextView(
                    label: coachAppointmentDetailResponseModel!.setupName,
                    textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w500, fontSize: 18.0, color: OQDOThemeData.greyColor),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  CustomTextView(
                    label: '${coachAppointmentDetailResponseModel!.activityName} - ${coachAppointmentDetailResponseModel!.subActivityName}',
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

  PreferredSizeWidget appbarView() {
    return CustomAppBar(
        title: 'Appointment Details',
        onBack: () {
          Navigator.pop(context);
        });
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
          const SizedBox(
            height: 10,
          ),
          const Divider(
            color: OQDOThemeData.greyColor,
          ),
          const SizedBox(
            height: 10,
          ),
          Column(
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
                          label: discountedAmount <= 0 ? 'Coupon Discount' : 'Coupon Discount (${discountPer.toStringAsFixed(2)}%)',
                          textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              color: discountedAmount <= 0 ? OQDOThemeData.blackColor : Theme.of(context).colorScheme.secondaryContainer),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        CustomTextView(
                          label: 'Applied on booking fees (S\$ ${bookingAmount.toStringAsFixed(2)})',
                          maxLine: 2,
                          textStyle:
                              Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 12.0, fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor),
                        ).visible(discountedAmount > 0),
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
                          label: 'S\$ ${discountedAmount.toStringAsFixed(2)}',
                          maxLine: 2,
                          textOverFlow: TextOverflow.ellipsis,
                          textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              color: discountedAmount <= 0 ? OQDOThemeData.blackColor : Theme.of(context).colorScheme.secondaryContainer),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 3,
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

  Future<void> getAppointmentDetails() async {
    try {
      model.CoachAppointmentDetailResponseModel facilityAppointmentDetailModel =
          await Provider.of<AppointmentViewModel>(context, listen: false).getCoachAppointmentDetail(widget.model!.bookingId!);
      if (facilityAppointmentDetailModel.bookingNo != null) {
        setState(() {
          coachAppointmentDetailResponseModel = facilityAppointmentDetailModel;
          bookingSlotList.clear();
          double tempTotalAmount = 0.00;
          double tempPaidAmount = 0.00;
          double tempPayLater = 0.00;
          debugPrint('date -> ${widget.model!.selectedDate}');
          for (var i = 0; i < coachAppointmentDetailResponseModel!.coachBookingSlotDates!.length; i++) {
            bookingSlotList.add(coachAppointmentDetailResponseModel!.coachBookingSlotDates![i]);
            discountedAmount += coachAppointmentDetailResponseModel!.coachBookingSlotDates![i].discountAmount ?? 0.00;
            bookingAmount += coachAppointmentDetailResponseModel!.coachBookingSlotDates![i].bookingAmount! -
                coachAppointmentDetailResponseModel!.coachBookingSlotDates![i].discountAmount!;
            if (!coachAppointmentDetailResponseModel!.coachBookingSlotDates![i].isCancelled!) {
              tempPaidAmount += coachAppointmentDetailResponseModel!.coachBookingSlotDates![i].amount ?? 0.00;
              tempTotalAmount += coachAppointmentDetailResponseModel!.coachBookingSlotDates![i].totalAmount ?? 0.00;
              tempPayLater += coachAppointmentDetailResponseModel!.coachBookingSlotDates![i].totalAmount! -
                  (coachAppointmentDetailResponseModel!.coachBookingSlotDates![i].amount! +
                      coachAppointmentDetailResponseModel!.coachBookingSlotDates![i].discountAmount!);
            }
          }
          discountPer = coachAppointmentDetailResponseModel!.coachBookingSlotDates![0].discountPer ?? 0;
          totalAmount = double.parse(tempTotalAmount.toStringAsFixed(2));
          paidAmount = double.parse(tempPaidAmount.toStringAsFixed(2));
          payLaterAmount = double.parse(tempPayLater.toStringAsFixed(2));
          if (payLaterAmount.isNegative) {
            payLaterAmount = 0.00;
          }

          ratingValue =
              coachAppointmentDetailResponseModel!.coachBookingReviews != null ? coachAppointmentDetailResponseModel!.coachBookingReviews!.rating! : 0.0;

          if (facilityAppointmentDetailModel.addressType == 'E') {
            addressData =
                '${facilityAppointmentDetailModel.endUserTrainingAddress!.addressName}, ${facilityAppointmentDetailModel.endUserTrainingAddress!.address1}, ${facilityAppointmentDetailModel.endUserTrainingAddress!.address2}, ${facilityAppointmentDetailModel.endUserTrainingAddress!.cityName}, ${facilityAppointmentDetailModel.endUserTrainingAddress!.stateName}, ${facilityAppointmentDetailModel.endUserTrainingAddress!.countryName} - ${facilityAppointmentDetailModel.endUserTrainingAddress!.pincode}';
          } else {
            addressData =
                '${coachAppointmentDetailResponseModel!.coachTrainingAddress![0].addressName}, ${coachAppointmentDetailResponseModel!.coachTrainingAddress![0].address1}, ${coachAppointmentDetailResponseModel!.coachTrainingAddress![0].address2}, ${coachAppointmentDetailResponseModel!.coachTrainingAddress![0].city!.name}, ${coachAppointmentDetailResponseModel!.coachTrainingAddress![0].city!.state!.name}, ${coachAppointmentDetailResponseModel!.coachTrainingAddress![0].city!.state!.country!.name} - ${coachAppointmentDetailResponseModel!.coachTrainingAddress![0].pinCode}';
          }
          if (coachAppointmentDetailResponseModel!.coachBookingReviews != null) {
            if (coachAppointmentDetailResponseModel!.coachBookingReviews!.comment!.isEmpty) {
              feedback.text = '';
            } else {
              feedback.text = coachAppointmentDetailResponseModel!.coachBookingReviews!.comment!;
            }
          }

          showLog('Called -> ');
          // cancelAllDateBeforeTodaysDate();
          if (!widget.model!.isDirectCancel!) {
            checkForCancelSlotsBeforeCurrentDate();
          }
        });
      }
    } on CommonException catch (error) {
      debugPrint(error.toString());
      if (!mounted) return;
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
      if (!mounted) return;
      debugPrint(error.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  Future callAddRating() async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    Map<String, dynamic> request = {};
    request['CoachBookingId'] = widget.model!.bookingId!;
    request['Rating'] = ratingValue;
    request['Comment'] = feedback.text.toString().trim();
    if (coachAppointmentDetailResponseModel!.coachBookingReviews != null) {
      request['ReviewId'] = coachAppointmentDetailResponseModel!.coachBookingReviews!.reviewId.toString();
    }
    try {
      await _progressDialog.show();
      String response = '';
      if (coachAppointmentDetailResponseModel!.coachBookingReviews != null) {
        response = await Provider.of<AppointmentViewModel>(context, listen: false).coachEditReviewRequest(request);
      } else {
        response = await Provider.of<AppointmentViewModel>(context, listen: false).coachAddReviewRequest(request);
      }
      await _progressDialog.hide();
      if (response.isNotEmpty) {
        showSnackBarColor('Feedback added', context, false);
        // feedback.text = '';
      }
    } on CommonException catch (error) {
      await _progressDialog.hide();
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
      debugPrint(error.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  void checkForCancelSlotsBeforeCurrentDate() {
    String currentDateInStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    debugPrint('CurrentDateINStr -> $currentDateInStr');
    for (var slotDates in bookingSlotList) {
      if (slotDates.isCancelled!) {
        setState(() {
          slotDates.isSlotCancelled = true;
        });
      }
      if (slotDates.bookingDate!.split('T')[0].compareTo(currentDateInStr) < 0) {
        setState(() {
          slotDates.isCancelled = true;
        });
      } else if (slotDates.bookingDate!.split('T')[0].compareTo(currentDateInStr) == 0) {
        if (slotDates.isCancelled!) {
          setState(() {
            slotDates.isCancelled = true;
          });
        } else {
          String currentTime = DateTime.now().toString();
          String hours = currentTime.split(' ')[1].split('.')[0].split(':')[0];
          String minutes = currentTime.split(' ')[1].split('.')[0].split(':')[1];
          Duration currentTimeDuration = Duration(hours: int.parse(hours), minutes: int.parse(minutes));
          debugPrint('CurrentTime in Duration -> $currentTimeDuration');
          String startTimeHours = slotDates.startTime!.split(':')[0];
          String startTimeMinutes = slotDates.startTime!.split(':')[1];
          Duration startTimeDuration = Duration(hours: int.parse(startTimeHours), minutes: int.parse(startTimeMinutes));
          debugPrint('startTimeDuration in Duration -> $startTimeDuration');
          if (startTimeDuration.compareTo(currentTimeDuration) < 0) {
            setState(() {
              slotDates.isCancelled = true;
            });
          } else if (startTimeDuration.compareTo(currentTimeDuration) == 0) {
            setState(() {
              slotDates.isCancelled = false;
            });
          } else {
            setState(() {
              slotDates.isCancelled = slotDates.isCancelled;
            });
          }
        }
      } else if (slotDates.bookingDate!.split('T')[0].compareTo(currentDateInStr) > 0) {
        setState(() {
          slotDates.isCancelled = slotDates.isCancelled;
        });
      }
    }
    isAnySlotCancel();
  }

  Widget _coachTransactionBottomSheet(
    BuildContext context,
    List<model.PaymentTransaction>? paymentTransaction,
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

                var tempAmount = (paymentTransaction[index].amount ?? 0.00) - (paymentTransaction[index].transactionDiscountAmount ?? 0.00);
                var tempTotalAmount = paymentTransaction[index].totalAmount ?? 0.00;
                double payLaterAmount = 0.00;

                if (tempAmount != 0.00 && tempTotalAmount != 0.00) {
                  payLaterAmount = double.parse((tempTotalAmount - tempAmount).toStringAsFixed(2));
                  if (payLaterAmount.isNegative) {
                    payLaterAmount = 0.00;
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
                        child: Text(
                          'Coupon Discount : S\$ ${paymentTransaction[index].transactionDiscountAmount?.toStringAsFixed(2) ?? 0.0}',
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
                        child: Text(
                          'Coupon Code : ${coachAppointmentDetailResponseModel?.referralCouponText ?? '-'}',
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
