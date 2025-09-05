// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/model/calendar_view_model.dart';
import 'package:oqdo_mobile_app/model/facility_booking_list_response_model.dart';
import 'package:oqdo_mobile_app/model/facility_booking_response.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/features/appointment/presentation/intent/selected_coupon_intent.dart';
import 'package:oqdo_mobile_app/features/appointment/presentation/views/appointment_btn_view.dart';
import 'package:oqdo_mobile_app/features/appointment/presentation/views/selected_discount_view.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/extentions.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:oqdo_mobile_app/viewmodels/slot_management_view_model.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import '../../components/my_button.dart';
import '../../helper/helpers.dart';
import '../../theme/oqdo_theme_data.dart';
import '../../utils/custom_text_view.dart';

class ReviewAppointmentScreen extends StatefulWidget {
  CalendarViewModel? calendarViewModel;

  ReviewAppointmentScreen({Key? key, this.calendarViewModel}) : super(key: key);

  @override
  State<ReviewAppointmentScreen> createState() => _ReviewAppointmentScreenState();
}

class _ReviewAppointmentScreenState extends State<ReviewAppointmentScreen> {
  late ProgressDialog _progressDialog;
  FacilityBookingListModelResponse? _facilityBookingListModelResponse;
  double totalAmount = 0.00;
  Timer? bookingRemainingTimer;
  Duration bookingTimeDuration = const Duration(seconds: 300);
  bool isHomeVisible = false;
  bool isBack = true;
  String cancellationTime = '';
  double payNowAmount = 0.0;
  double payLaterAmount = 0.0;

  DateTime bookingStartTime = DateTime.now();
  late StreamSubscription<FGBGType> subscription;
  final ScrollController _scrollController = ScrollController();
  bool isCouponSelected = false;
  late SelectedCouponIntent selectedCouponIntent;
  double discountedAmount = 0.0;
  bool isPaymentSheetVisible = false;

  @override
  void initState() {
    super.initState();
    bookingStartTime = widget.calendarViewModel!.bookingStartTime!;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      startBookingTimer();
      getFreezeBooking();

      subscription = FGBGEvents.instance.stream.listen((event) {
        // FGBGType.foreground or FGBGType.background
        debugPrint("FGBGEvents :===> event : ${(event.name)}");
        if (event == FGBGType.foreground) {
          bookingRemainingTimer?.cancel();
          addTimer();
          startBookingTimer();
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    subscription.cancel();
    bookingRemainingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');

    var timerDifference = DateTime.now().difference(bookingStartTime);
    var differenceInSeconds = bookingTimeDuration.inSeconds - timerDifference.inSeconds;
    var remainingTimeDiff = Duration(seconds: (differenceInSeconds > 0) ? differenceInSeconds : 0);

    var minutes = strDigits(remainingTimeDiff.inMinutes.remainder(60));
    var seconds = strDigits(remainingTimeDiff.inSeconds.remainder(60));

    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
        appBar: CustomAppBar(
            title: 'Review Appointments',
            onBack: () async {
              if (isHomeVisible) {
                await Navigator.pushNamedAndRemoveUntil(context, Constants.APPPAGES, Helper.of(context).predicate, arguments: 0);
              } else {
                Navigator.pop(context);
              }
            }),
        body: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Theme.of(context).colorScheme.onBackground,
            child: _facilityBookingListModelResponse != null
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
                                const SizedBox(height: 20.0),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: CustomTextView(
                                    maxLine: 2,
                                    label:
                                        '${widget.calendarViewModel!.getFacilityByIdModel!.title} - ${widget.calendarViewModel!.getFacilityByIdModel!.subTitle}',
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(fontSize: 20, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                const SizedBox(height: 15.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Center(
                                        child: CustomTextView(
                                          label: 'Slots',
                                          textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                fontSize: 16,
                                                color: OQDOThemeData.otherTextColor.withOpacity(0.6),
                                                fontWeight: FontWeight.w500,
                                                decoration: TextDecoration.underline,
                                              ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: CustomTextView(
                                        label: 'Order fees',
                                        isStrikeThrough: true,
                                        textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                                              fontSize: 16,
                                              color: OQDOThemeData.otherTextColor.withOpacity(0.6),
                                              fontWeight: FontWeight.w500,
                                              decoration: TextDecoration.underline,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20.0),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _facilityBookingListModelResponse!.facilityBookingFreezeSlots!.length,
                                  itemBuilder: ((context, index) {
                                    return reviewAppointmentListView(index);
                                  }),
                                ),
                                !isCouponSelected
                                    ? GestureDetector(
                                        onTap: () async {
                                          final result = await Navigator.pushNamed(context, Constants.couponScreen);
                                          if (result != null) {
                                            selectedCouponIntent = result as SelectedCouponIntent;
                                            setState(() {
                                              isCouponSelected = true;
                                              calculateDiscount();
                                            });
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0099FA).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: const Color(0xFF0099FA).withOpacity(0.5), width: 2),
                                          ),
                                          padding: const EdgeInsets.all(15.0),
                                          margin: const EdgeInsets.all(10.0),
                                          child: Row(
                                            children: [
                                              Image.asset(
                                                'assets/images/ic_view_offer.png',
                                                height: 20,
                                                width: 20,
                                              ),
                                              const SizedBox(width: 8.0),
                                              const Text(
                                                'View All Coupons',
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  color: Color(0xFF0099FA),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : SelectedDiscountView(
                                        percentage: '${selectedCouponIntent.discount} %',
                                        couponCode: selectedCouponIntent.couponName,
                                        onRemove: () {
                                          setState(() {
                                            isCouponSelected = false;
                                            discountedAmount = 0.0;
                                            selectedCouponIntent = SelectedCouponIntent(couponName: '', discount: 0.0, couponId: 0, discountAmount: 0.0);
                                            calculateDiscount();
                                          });
                                        },
                                      ),
                                const SizedBox(height: 20.0),
                                _paymentSummaryView(),
                                const SizedBox(height: 20.0),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: CustomTextView(
                                    label: 'Cancellation/Refund Policy:',
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(fontSize: 14.0, fontWeight: FontWeight.w600, color: ColorsUtils.redColor),
                                  ),
                                ),
                                const SizedBox(height: 6.0),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: CustomTextView(
                                    maxLine: 2,
                                    label: 'Refundable if slot booking is cancelled $cancellationTime hours before start time',
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
                                  ),
                                ),
                                const SizedBox(height: 100.0), // Bottom padding for scrollable content
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Fixed bottom section
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, -3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            !isHomeVisible
                                ? CustomTextView(
                                    label: 'Time remaining $minutes:$seconds minutes',
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(color: OQDOThemeData.greyColor, fontSize: 16, fontWeight: FontWeight.w400),
                                  )
                                : CustomTextView(
                                    maxLine: 2,
                                    label: 'Booking timeout. Please Return to Home and book again.',
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(fontWeight: FontWeight.w700, color: OQDOThemeData.errorColor, fontSize: 20),
                                  ),
                            const SizedBox(height: 20.0),
                            !isHomeVisible
                                ? AppointmentButton(
                                    amount: isCouponSelected ? payNowAmount - discountedAmount : payNowAmount,
                                    onPressed: () {
                                      if (isAnySlotSelected()) {
                                        if (!isPaymentSheetVisible) {
                                          facilityAppointmentBooking();
                                        }
                                      } else {
                                        showSnackBar('Select slot', context);
                                      }
                                    },
                                  )
                                : MyButton(
                                    text: 'Return to Home',
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
                                      await Navigator.pushNamedAndRemoveUntil(context, Constants.APPPAGES, Helper.of(context).predicate, arguments: 0);
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
        ),
      ),
    );
  }

  void calculateDiscount() {
    if (isCouponSelected && selectedCouponIntent.discount > 0) {
      discountedAmount = 0.0;
      totalAmount = 0.0;
      payNowAmount = 0.0;
      payLaterAmount = 0.0;
      for (var slot in _facilityBookingListModelResponse!.facilityBookingFreezeSlots!) {
        if (slot.isSlotSelected!) {
          discountedAmount += ((slot.amount! * selectedCouponIntent.discount / 100) * 100).round() / 100;
          slot.discountAmount = ((slot.amount! * selectedCouponIntent.discount / 100) * 100).round() / 100;
          payNowAmount = payNowAmount + slot.amount!;
          totalAmount = totalAmount + (slot.totalAmount!);
          payLaterAmount = totalAmount - payNowAmount;
        }
      }
    } else {
      var finalAmount = 0.0;
      totalAmount = 0.0;
      for (var slot in _facilityBookingListModelResponse!.facilityBookingFreezeSlots!) {
        if (slot.isSlotSelected!) {
          finalAmount += slot.amount!;
          totalAmount = totalAmount + slot.totalAmount!;
          payNowAmount = finalAmount;
          payLaterAmount = totalAmount - payNowAmount;
        }
      }
    }
  }

  Future<bool> _willPopCallback() async {
    if (isBack) {
      Navigator.pop(context);
    }
    return Future.value(true);
  }

  Widget reviewAppointmentListView(int index) {
    return Container(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 20.0),
      child: Row(
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
                      value: _facilityBookingListModelResponse!.facilityBookingFreezeSlots![index].isSlotSelected,
                      onChanged: (value) {
                        if (value!) {
                          setState(() {
                            _facilityBookingListModelResponse!.facilityBookingFreezeSlots![index].isSlotSelected = value;
                            totalAmountCalculation(value, _facilityBookingListModelResponse!.facilityBookingFreezeSlots![index].totalAmount ?? 0.00,
                                _facilityBookingListModelResponse!.facilityBookingFreezeSlots![index].amount ?? 0.00);
                          });
                        } else {
                          setState(() {
                            _facilityBookingListModelResponse!.facilityBookingFreezeSlots![index].isSlotSelected = value;
                            totalAmountCalculation(value, _facilityBookingListModelResponse!.facilityBookingFreezeSlots![index].totalAmount ?? 0.00,
                                _facilityBookingListModelResponse!.facilityBookingFreezeSlots![index].amount ?? 0.00);
                          });
                        }
                      }),
                ),
                const SizedBox(
                  width: 15.0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextView(
                        maxLine: 2,
                        textOverFlow: TextOverflow.ellipsis,
                        label:
                            '${convertDateToString(_facilityBookingListModelResponse!.facilityBookingFreezeSlots![index].bookingDate!).split(',')[1].split(' ')[2]} ${convertDateToString(_facilityBookingListModelResponse!.facilityBookingFreezeSlots![index].bookingDate!).split(',')[1].split(' ')[1]} - ${convertDateToString(_facilityBookingListModelResponse!.facilityBookingFreezeSlots![index].bookingDate!).split(',')[0]}',
                        textStyle:
                            Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 18.0, fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        children: [
                          CustomTextView(
                            label:
                                '${_facilityBookingListModelResponse!.facilityBookingFreezeSlots![index].startTime} - ${_facilityBookingListModelResponse!.facilityBookingFreezeSlots![index].endTime}',
                            textStyle:
                                Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 12.0, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          CustomTextView(
                            label: 'S\$ ${_facilityBookingListModelResponse?.facilityBookingFreezeSlots?[index].ratePerHour?.toStringAsFixed(2) ?? 0.00}/hour',
                            textStyle:
                                Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 12.0, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: CustomTextView(
                label: 'S\$ ${_facilityBookingListModelResponse?.facilityBookingFreezeSlots?[index].amount?.toStringAsFixed(2) ?? 0.00}',
                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 16.0, fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void addTimer() {
    var timerDifference = DateTime.now().difference(bookingStartTime);

    if (timerDifference.inSeconds >= bookingTimeDuration.inSeconds) {
      bookingRemainingTimer?.cancel();
      isHomeVisible = true;
    }

    if (!mounted) return;
    setState(() {});
  }

  void startBookingTimer() {
    bookingRemainingTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      addTimer();
    });
  }

  bool isAnySlotSelected() {
    bool isFacilitySelected = false;
    for (int i = 0; i < _facilityBookingListModelResponse!.facilityBookingFreezeSlots!.length; i++) {
      if (_facilityBookingListModelResponse!.facilityBookingFreezeSlots![i].isSlotSelected!) {
        isFacilitySelected = true;
        break;
      }
    }
    return isFacilitySelected;
  }

  Future<void> getFreezeBooking() async {
    try {
      FacilityBookingListModelResponse response =
          await Provider.of<SlotManagementViewModel>(context, listen: false).getFreezeBooking(widget.calendarViewModel!.facilityFreezeId.toString());
      if (response.facilityBookingFreezeId != 0) {
        setState(() {
          _facilityBookingListModelResponse = response;
          totalAmount = _facilityBookingListModelResponse!.totalAmount!;
          payNowAmount = _facilityBookingListModelResponse!.amount!;
          payLaterAmount = totalAmount - payNowAmount;
          cancellationTime = response.cancellationPolicyTime!;
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

  String convertDateToString(String date) {
    String parsingDate = '';
    DateTime dateTime = DateFormat('yyyy-MM-dd').parse(date);
    parsingDate = DateFormat.yMMMMEEEEd().format(dateTime);
    return parsingDate;
  }

  void totalAmountCalculation(bool isSelected, double? fullAmount, double? bookingAmount) {
    if (isSelected) {
      setState(() {
        // Recalculate discount if coupon is selected
        if (isCouponSelected) {
          calculateDiscount();
        } else {
          totalAmount = double.parse(totalAmount.toStringAsFixed(2)) + fullAmount!;
          payNowAmount = double.parse(payNowAmount.toStringAsFixed(2)) + bookingAmount!;
          payLaterAmount = double.parse(totalAmount.toStringAsFixed(2)) - payNowAmount;
        }
      });
    } else {
      setState(() {
        // Recalculate discount if coupon is selected
        if (isCouponSelected) {
          calculateDiscount();
        } else {
          totalAmount = double.parse(totalAmount.toStringAsFixed(2)) - fullAmount!;
          payNowAmount = double.parse(payNowAmount.toStringAsFixed(2)) - bookingAmount!;
          payLaterAmount = double.parse(totalAmount.toStringAsFixed(2)) - payNowAmount;
        }
      });
    }
  }

  Future<void> facilityAppointmentBooking() async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    try {
      await _progressDialog.show();
      Map<String, dynamic> request = {};
      request['TransactionDate'] = convertDateTimeToString(kToday);
      request['EndUserId'] = OQDOApplication.instance.endUserID;
      request['FacilitySetupDetailId'] = widget.calendarViewModel!.getFacilityByIdModel!.facilitySetupDetailId;
      request['FacilityBookingFreezeId'] = widget.calendarViewModel!.facilityFreezeId;
      request['TotalAmt'] = !isCouponSelected ? payNowAmount : (payNowAmount - discountedAmount);
      List<Map> facilityBookingSlotDateDtos = [];
      for (int i = 0; i < _facilityBookingListModelResponse!.facilityBookingFreezeSlots!.length; i++) {
        Map map = {};
        if (_facilityBookingListModelResponse!.facilityBookingFreezeSlots![i].isSlotSelected!) {
          map['BookingDate'] = _facilityBookingListModelResponse!.facilityBookingFreezeSlots![i].bookingDate;
          map['FacilitySetupDaySlotMapId'] = _facilityBookingListModelResponse!.facilityBookingFreezeSlots![i].facilitySetupDaySlotMapId;
          facilityBookingSlotDateDtos.add(map);
        }
      }
      request['FacilityBookingSlotDateDtos'] = facilityBookingSlotDateDtos;
      request['FacilityProviderId'] = widget.calendarViewModel!.getFacilityByIdModel!.facilityProviderId;
      request['EndUserReferralActivityId'] = !isCouponSelected ? null : selectedCouponIntent.couponId;
      debugPrint('facilityAppointmentBooking -> ${jsonEncode(request)}');
      FacilityBookingResponse response = await Provider.of<SlotManagementViewModel>(context, listen: false).facilitySlotBooking(request);
      await _progressDialog.hide();
      if (!mounted) return;
      bookingRemainingTimer!.cancel();
      isPaymentSheetVisible = true;
      setState(() {});
      makePayment(response.paymentSecret!, response.facilityBookingId!);
    } on CommonException catch (error) {
      await _progressDialog.hide();
      if (!mounted) return;
      debugPrint(error.toString());
      if (error.code == 400) {
        Map<String, dynamic> errorModel = jsonDecode(error.message);
        if (errorModel.containsKey('ModelState')) {
          Map<String, dynamic> modelState = errorModel['ModelState'];
          if (modelState.containsKey('ErrorMessage')) {
            showSnackBarColor(modelState['ErrorMessage'][0], context, true);
            if (modelState['ErrorMessage'][0].toString().toLowerCase().contains('expire')) {
              setState(() {
                isHomeVisible = true;
              });
            }
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

  // Stripe Integration
  Future<void> makePayment(String secret, int facilityBookingId) async {
    isBack = false;
    String userId = OQDOApplication.instance.userID ?? "";
    String name = OQDOApplication.instance.name ?? "";
    String phone = OQDOApplication.instance.phone ?? "";
    String email = OQDOApplication.instance.email ?? "";
    String country = OQDOApplication.instance.country ?? "";
    String city = OQDOApplication.instance.city ?? "";
    String zipCode = OQDOApplication.instance.zipcode ?? "";

    try {
      //STEP 2: Initialize Payment Sheet

      var gpay = PaymentSheetGooglePay(merchantCountryCode: "SG", currencyCode: "SGD", testEnv: false);

      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: secret,
                  returnURL: 'https://oqdo.com/',
                  customerId: userId,
                  billingDetails: BillingDetails(
                      name: name,
                      address: Address(country: 'SG', city: city, line1: "", line2: "", postalCode: zipCode, state: ""),
                      phone: phone,
                      email: email),
                  billingDetailsCollectionConfiguration: const BillingDetailsCollectionConfiguration(address: AddressCollectionMode.automatic),
                  //Gotten from payment intent
                  style: ThemeMode.light,
                  googlePay: gpay,
                  applePay: const PaymentSheetApplePay(merchantCountryCode: 'SG', buttonType: PlatformButtonType.buy),
                  appearance: const PaymentSheetAppearance(
                      colors: PaymentSheetAppearanceColors(primary: OQDOThemeData.dividerColor),
                      primaryButton: PaymentSheetPrimaryButtonAppearance(
                          colors: PaymentSheetPrimaryButtonTheme(
                              light: PaymentSheetPrimaryButtonThemeColors(background: OQDOThemeData.dividerColor, text: Colors.white)))),
                  merchantDisplayName: 'OQDO'))
          .then((value) {});

      //STEP 3: Display Payment sheet
      displayPaymentSheet(secret, facilityBookingId);
    } catch (err) {
      debugPrint(err.toString());
      throw Exception(err);
    }
  }

  displayPaymentSheet(String secret, int facilityBookingId) async {
    String paymentID = "";
    try {
      var paymentIntent = await Stripe.instance.retrievePaymentIntent(secret);
      paymentID = paymentIntent.id;
      await Stripe.instance.presentPaymentSheet().then((value) {
        debugPrint("response -> ${value}");
        validateFacilityPaymentActivity(paymentID, facilityBookingId);
        // successBooking(paymentID, facilityBookingId);
      }).onError((error, stackTrace) {
        debugPrint("CALL 1 -----------");
        debugPrint(error.toString());
        failedBooking(paymentID, facilityBookingId);
        throw Exception(error);
      });
    } on StripeException catch (e) {
      debugPrint("CALL 2 -----------");
      debugPrint('Error is:---> $e');
      failedBooking(paymentID, facilityBookingId);
    } catch (e) {
      debugPrint("CALL 3 -----------");
      debugPrint('$e');
      // failedBooking(paymentID,coachBookingId);
    }
  }

  Future<void> validateFacilityPaymentActivity(String paymentID, int facilityBookingId) async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait...");
    try {
      await _progressDialog.show();
      Map<String, dynamic> request = {};
      request['PaymentActivityId'] = 0;
      request['FacilityBookingId'] = facilityBookingId;
      request['CoachBookingId'] = 0;
      request['FacilityBookingSlotId'] = widget.calendarViewModel!.facilityFreezeId;
      request['CoachBookingSlotId'] = 0;
      request['CoachBookingFreezeId'] = 0;
      request['FacilityBookingFreezeId'] = widget.calendarViewModel!.facilityFreezeId;
      request['OrderId'] = paymentID;
      request['IsCoach'] = false;
      request['Amount'] = !isCouponSelected ? payNowAmount : (payNowAmount - discountedAmount);
      request['Status'] = 'S';
      request['Request'] = 'Success';
      request['Response'] = 'Success';
      request['IsRefund'] = true;
      debugPrint('validateFacilityPaymentActivity -> ${jsonEncode(request)}');
      var response = await Provider.of<SlotManagementViewModel>(context, listen: false).validateFacilityPaymentActivity(request);
      await _progressDialog.hide();
      if (!mounted) return;
      if (response) {
        successBooking(paymentID, facilityBookingId);
      } else {
        failedBooking(paymentID, facilityBookingId);
      }
    } on CommonException catch (error) {
      await _progressDialog.hide();
      if (!mounted) return;
      debugPrint(error.toString());
    } on NoConnectivityException catch (_) {
      await _progressDialog.hide();
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      await _progressDialog.hide();
      if (!mounted) return;
      debugPrint(error.toString());
    }
  }

  Future<void> successBooking(String paymentId, int facilityBookingId) async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait...");
    try {
      await _progressDialog.show();
      Map<String, dynamic> request = {};
      request['FacilityBookingId'] = facilityBookingId;
      request['OrderId'] = paymentId;
      request['Amount'] = !isCouponSelected ? payNowAmount : (payNowAmount - discountedAmount);
      request['EndUserReferralActivityId'] = !isCouponSelected ? null : selectedCouponIntent.couponId;
      debugPrint('DATA -> ${jsonEncode(request)}');

      bool response = await Provider.of<SlotManagementViewModel>(context, listen: false).successFacilityBooking(request);
      await _progressDialog.hide();
      if (!mounted) return;
      if (response) {
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
                        const Text("Payment Successful!"),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text("Check the Calendar tab for all booked appointments"),
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
                            showSnackBarColor('Facility booked', context, false);
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
      if (!mounted) return;
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

  Future<void> failedBooking(String paymentId, int facilityBookingId) async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait...");
    try {
      await _progressDialog.show();
      Map<String, dynamic> request = {};
      request['FacilityBookingId'] = facilityBookingId;
      request['OrderId'] = paymentId;
      request['Amount'] = !isCouponSelected ? payNowAmount : (payNowAmount - discountedAmount);
      bool response = await Provider.of<SlotManagementViewModel>(context, listen: false).failedFacilityBooking(request);
      await _progressDialog.hide();
      if (!mounted) return;
      if (response) {
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
                          Icons.cancel,
                          color: Colors.red,
                          size: 100.0,
                        ),
                        const SizedBox(height: 10.0),
                        const Text("Payment failed. No appointments booked. If funds were deducted, a refund will be processed within 7-10 working days."),
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
                            showSnackBarColor('Facility Booking Failed', context, true);
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
      if (!mounted) return;
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
        showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
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

  Widget _paymentSummaryView() {
    return isAnySlotSelected()
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: OQDOThemeData.whiteColor,
                border: Border.all(color: OQDOThemeData.otherTextColor),
              ),
              padding: const EdgeInsets.all(10.0),
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
                  _buildTitleDetailsRow(title: "Immediate Payment", details: "Order fees", rate: payNowAmount.toStringAsFixed(2)),
                  const SizedBox(
                    height: 10,
                  ),
                  _buildTitleDetailsRow(
                      title: "Pay later", details: "Balance to be paid directly to the service provider", rate: payLaterAmount.toStringAsFixed(2)),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomTextView(
                        label: "Total Amount : ",
                        textStyle:
                            Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 16.0, fontWeight: FontWeight.w600, color: OQDOThemeData.blackColor),
                      ),
                      Column(
                        children: [
                          CustomTextView(
                            label: 'S\$ ${totalAmount.toStringAsFixed(2)}',
                            textStyle:
                                Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14.0, fontWeight: FontWeight.w600, color: OQDOThemeData.blackColor),
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
                                  label: !isCouponSelected ? 'Coupon Discount' : 'Coupon Discount (${selectedCouponIntent.discount}%)',
                                  textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                      color: !isCouponSelected ? OQDOThemeData.blackColor : Theme.of(context).colorScheme.secondaryContainer),
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                CustomTextView(
                                  label: 'Applied on booking fees',
                                  maxLine: 2,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontSize: 12.0, fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor),
                                ).visible(isCouponSelected),
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
                                      color: !isCouponSelected ? OQDOThemeData.blackColor : Theme.of(context).colorScheme.secondaryContainer),
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
            ),
          )
        : const SizedBox();
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
//         children: [
//           Flexible(
//             flex: 1,
//             fit: FlexFit.tight,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CustomTextView(
//                   label: title,
//                   textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14.0, fontWeight: FontWeight.w600, color: OQDOThemeData.blackColor),
//                 ),
//                 const SizedBox(
//                   height: 3,
//                 ),
//                 CustomTextView(
//                   label: details,
//                   maxLine: 2,
//                   textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 12.0, fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor),
//                 ),
//               ],
//             ),
//           ),
//           Flexible(
//             fit: FlexFit.tight,
//             flex: 1,
//             child: Column(
//               children: [
//                 CustomTextView(
//                   label: 'S\$ $rate',
//                   maxLine: 2,
//                   textOverFlow: TextOverflow.ellipsis,
//                   textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 13.0, fontWeight: FontWeight.w600, color: OQDOThemeData.blackColor),
//                 ),
//               ],
//             ),
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
}
