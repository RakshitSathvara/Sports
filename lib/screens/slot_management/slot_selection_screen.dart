// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/helper/helpers.dart';
import 'package:oqdo_mobile_app/model/available_slots_by_date_response_model.dart';
import 'package:oqdo_mobile_app/model/calendar_view_model.dart';
import 'package:oqdo_mobile_app/model/facility_slot_booking_model.dart';
import 'package:oqdo_mobile_app/model/freeze_facility_response_model.dart';
import 'package:oqdo_mobile_app/model/get_21_days_slot_response_model.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/coutdown_timer.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:oqdo_mobile_app/viewmodels/slot_management_view_model.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class SlotSelectionScreen extends StatefulWidget {
  CalendarViewModel? calendarViewModel;

  SlotSelectionScreen({Key? key, this.calendarViewModel}) : super(key: key);

  @override
  State<SlotSelectionScreen> createState() => _SlotSelectionScreenState();
}

class _SlotSelectionScreenState extends State<SlotSelectionScreen> {
  late CalendarViewModel _calendarViewModel;
  String monthStr = '';
  late ProgressDialog _progressDialog;
  final List<FacilitySlotBookingModel> _facilitySlotBookingModelList = [];
  DateTime? firstDate;
  DateTime? lastDate;
  DateTime? _selectedDay;
  final CalendarFormat _calendarFormat = CalendarFormat.week;
  List<FacilitySlotBookingModel> _singleFacilityDatesList = [];
  final List<AvailableSlotsByDateResponseModel> _availableSlotsByDateResponseModelList = [];
  double totalAmount = 0.00;
  late DateTime lastDateForBooking;
  DateTime currentDateTime = DateTime.now();
  late PageController _pageController;
  final CalendarFormat _calendarViewFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  late String _currentDay;
  DateFormat format = DateFormat('d-MMMM-yyyy');
  DateTime? _selectedDayView;
  String initSelectedDate = '';
  bool isTimingShow = false;
  bool isHomeVisible = false;
  int unFreezeCount = 0;
  bool isLoading = false;

  Duration bookingTimeDuration = const Duration(seconds: 300);
  Timer? bookingRemainingTimer;
  bool isBookingTimer = false;
  DateTime bookingStartTime = DateTime.now();
  late StreamSubscription<FGBGType> subscription;

  // DateTime? _endDateTime;
  List<SlotListModel> unFreezeCountList = [];
  int minutes = 0;
  int seconds = 0;

  @override
  void initState() {
    super.initState();
    _calendarViewModel = widget.calendarViewModel!;
    monthStr = DateFormat.yMMMM().format(_calendarViewModel.selectedDateTime!).split(' ')[0];
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _selectedDay = _calendarViewModel.selectedDateTime!;
      // _endDateTime = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day + 89);
      _currentDay = format.format(_focusedDay);
      initSelectedDate = DateFormat.yMMMMEEEEd().format(_focusedDay).split(' ')[0].split(',')[0];
      if (_calendarViewModel.type == 'F') {
        get21DaysFacilitySlots(_calendarViewModel.getFacilityByIdModel!.facilitySetupId, convertDateTimeToString(kFirstDay), convertDateTimeToString(kLastDay));
      }
    });

    // subscription = FGBGEvents.stream.listen((event) {
    //   // FGBGType.foreground or FGBGType.background
    //   debugPrint("FGBGEvents :===> event : ${(event.name)}");
    //   if (event == FGBGType.foreground) {
    //     if (isBookingTimer) {
    //       bookingRemainingTimer?.cancel();
    //       addTimer();
    //       startBookingTimer();
    //     }
    //   }
    // });
  }

  @override
  void dispose() {
    // subscription.cancel();
    // bookingRemainingTimer?.cancel();
    super.dispose();
    debugPrint("=== >>> Dispose called <<< ===");
  }

  @override
  Widget build(BuildContext context) {
    // String strDigits(int n) => n.toString().padLeft(2, '0');

    // var timerDifference = DateTime.now().difference(bookingStartTime);
    // var differenceInSeconds = bookingTimeDuration.inSeconds - timerDifference.inSeconds;
    // var remainingTimeDiff = Duration(seconds: (differenceInSeconds > 0) ? differenceInSeconds : 0);

    // var minutes = strDigits(remainingTimeDiff.inMinutes.remainder(60));
    // var seconds = strDigits(remainingTimeDiff.inSeconds.remainder(60));

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: CustomAppBar(
          title: '',
          onBack: () async {
            if (totalAmount > 0) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Slot Booking'),
                  content: const Text('Are you sure you want to cancel and Exit?\n\nIf you leave now you\'ll have to start from scratch next time.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('No, Continue Booking'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        unFreezeSelectedSlots();
                      },
                      child: const Text('Yes, Cancel and Exit'),
                    ),
                  ],
                ),
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
        body: SafeArea(
          child: Container(
            color: OQDOThemeData.whiteColor,
            width: MediaQuery.of(context).size.width,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                headerView(),
                Padding(
                  padding: const EdgeInsets.only(top: 30, left: 10.0, right: 10),
                  child: calendarView(),
                ),
                const SizedBox(
                  height: 30,
                ),
                _singleFacilityDatesList.isNotEmpty
                    ? _singleFacilityDatesList[0].listOfSlots?.isNotEmpty ?? false
                        ? Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      CustomTextView(
                                        label: 'Batches',
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(fontSize: 20, fontWeight: FontWeight.w500, color: const Color(0xFF333333)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  isLoading
                                      ? const Flexible(
                                          flex: 1,
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                      : Flexible(
                                          child: GridView.builder(
                                              shrinkWrap: false,
                                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2, mainAxisSpacing: 15, crossAxisSpacing: 50, childAspectRatio: 4),
                                              itemBuilder: (context, index) {
                                                return showSingleSlotItemView(index);
                                              },
                                              itemCount: _singleFacilityDatesList[0].listOfSlots!.length),
                                        ),
                                ],
                              ),
                            ),
                          )
                        : Expanded(
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/images/ic_empty_view.png',
                                  fit: BoxFit.fill,
                                  height: 400,
                                  width: 400,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                CustomTextView(
                                  label: 'Slot not available',
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontSize: 16, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          )
                    : Container(),
                const SizedBox(
                  height: 20,
                ),
                totalAmount > 0
                    ? Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                          children: [
                            CustomTextView(
                              label: 'Total Amount',
                              textStyle:
                                  Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 18, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            CustomTextView(
                              label: 'S\$ ${totalAmount.toStringAsFixed(2)}',
                              textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                                    fontWeight: FontWeight.w400,
                                    color: OQDOThemeData.greyColor,
                                    fontSize: 20,
                                  ),
                            )
                          ],
                        ),
                      )
                    : Container(),
                const SizedBox(
                  height: 15,
                ),
                isHomeVisible
                    ? Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                        child: CustomTextView(
                          maxLine: 3,
                          label: 'Booking timeout. Please Return to Home and book again.',
                          textStyle:
                              Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700, color: OQDOThemeData.errorColor, fontSize: 18),
                        ),
                      )
                    : isTimingShow
                        ? CountdownTimerWidget(
                            onFinish: () {
                              setState(() {
                                totalAmount = 0.00;
                                isHomeVisible = true;
                                _facilitySlotBookingModelList.clear();
                                _singleFacilityDatesList.clear();
                                _availableSlotsByDateResponseModelList.clear();
                              });
                            },
                            onTimerUpdate: (remainingSeconds) {
                              minutes = (remainingSeconds / 60).floor();
                              seconds = remainingSeconds % 60;
                            },
                          )
                        : Container(),
                const SizedBox(
                  height: 30,
                ),
                totalAmount > 0
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 15.0, left: 20, right: 20),
                        child: MyButton(
                          text: 'Review Appointment',
                          textcolor: Theme.of(context).colorScheme.onBackground,
                          textsize: 16,
                          fontWeight: FontWeight.w600,
                          letterspacing: 0.7,
                          buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                          buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                          buttonheight: 60,
                          buttonwidth: MediaQuery.of(context).size.width,
                          radius: 15,
                          onTap: () async {
                            if (isHomeVisible) {
                              await Navigator.pushNamedAndRemoveUntil(context, Constants.APPPAGES, Helper.of(context).predicate, arguments: 0);
                            } else {
                              _calendarViewModel.facilityFreezeId = checkForFreezeFacilityBookingId();
                              _calendarViewModel.remainingTime = '$minutes-$seconds';
                              _calendarViewModel.bookingStartTime = bookingStartTime;
                              Navigator.of(context).pushNamed(Constants.reviewAppointmentScreen, arguments: _calendarViewModel);
                            }
                          },
                        ),
                      )
                    : isHomeVisible
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 15.0, left: 20, right: 20),
                            child: MyButton(
                              text: 'Return to Home',
                              textcolor: Theme.of(context).colorScheme.onBackground,
                              textsize: 16,
                              fontWeight: FontWeight.w600,
                              letterspacing: 0.7,
                              buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                              buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                              buttonheight: 60,
                              buttonwidth: MediaQuery.of(context).size.width,
                              radius: 15,
                              onTap: () async {
                                await Navigator.pushNamedAndRemoveUntil(context, Constants.APPPAGES, Helper.of(context).predicate, arguments: 0);
                              },
                            ),
                          )
                        : Container()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget headerView() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
      child: Row(
        children: [
          CustomTextView(
            label: monthStr,
            textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20, fontWeight: FontWeight.w500, color: const Color(0xFF333333)),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return showCalendarSheet(setState);
                    },
                  );
                },
                enableDrag: true,
                isDismissible: true,
                isScrollControlled: true,
              ).then((value) async {
                if (value != null) {
                  if (await NetworkConnectionInterceptor().isConnected()) {
                    debugPrint('Sheet selected date -> $value');
                    DateTime passingDate = value as DateTime;
                    setState(() {
                      _selectedDay = passingDate;
                      showSlotsList();
                      monthChangeStr();
                    });
                  } else {
                    showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
                  }
                }
              });
            },
            child: Image.asset(
              'assets/images/calendar_cicular.png',
              height: 25,
              width: 25,
            ),
          ),
        ],
      ),
    );
  }

  Widget calendarView() {
    return firstDate != null
        ? TableCalendar(
            focusedDay: _selectedDay!,
            firstDay: kFirstDay,
            lastDay: kLastDay,
            calendarFormat: _calendarFormat,
            headerVisible: false,
            daysOfWeekVisible: true,
            daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Color(0xFF006590), fontWeight: FontWeight.w500),
                weekendStyle: TextStyle(color: Color(0xFF006590), fontWeight: FontWeight.w500)),
            calendarStyle: CalendarStyle(
              isTodayHighlighted: false,
              outsideDaysVisible: false,
              selectedDecoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
              defaultTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black),
            ),
            onDaySelected: _onDaySelected,
            selectedDayPredicate: (DateTime date) {
              return isSameDay(_selectedDay!, date);
            },
          )
        : Container();
  }

  Widget showSingleSlotItemView(int index) {
    return InkWell(
      onTap: () async {
        if (await NetworkConnectionInterceptor().isConnected()) {
          if (!_singleFacilityDatesList[0].listOfSlots![index].isSlotTimePassed) {
            if (_singleFacilityDatesList[0].listOfSlots![index].availableSeat > 0) {
              _singleFacilityDatesList[0].listOfSlots![index].isSlotSelected
                  ? unFreezeFacilityBookingCall(_singleFacilityDatesList[0].listOfSlots![index], 'S')
                  : freezeFacilityBookingCall(_singleFacilityDatesList[0].listOfSlots![index]);
            } else {
              if (_singleFacilityDatesList[0].listOfSlots![index].isSlotSelected) {
                unFreezeFacilityBookingCall(_singleFacilityDatesList[0].listOfSlots![index], 'S');
              }
            }
          }
        } else {
          showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
        }
      },
      child: _singleFacilityDatesList[0].listOfSlots![index].availableSeat < 0
          ? Container()
          : _singleFacilityDatesList[0].listOfSlots![index].isSlotTimePassed
              ? Row(
                  children: [
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          color: const Color(0xFFCCCCCC),
                        ),
                        child: Center(
                          child: CustomTextView(
                            label: '${_singleFacilityDatesList[0].listOfSlots![index].startTime} - ${_singleFacilityDatesList[0].listOfSlots![index].endTime}',
                            type: styleSubTitle,
                            textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: OQDOThemeData.greyColor),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Column(
                      children: [
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            CustomTextView(
                              label: _singleFacilityDatesList[0].listOfSlots![index].availableSeat.toString(),
                              textStyle:
                                  Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 14, color: OQDOThemeData.blackColor, fontWeight: FontWeight.w300),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Image.asset(
                              'assets/images/ic_booked_timeslots.png',
                              width: 15,
                              height: 15,
                            ),
                          ],
                        ),
                        CustomTextView(
                          label: 'Available',
                          textStyle:
                              Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF333333)),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  ],
                )
              : _singleFacilityDatesList[0].listOfSlots![index].availableSeat > 0
                  ? Row(
                      children: [
                        Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: _singleFacilityDatesList[0].listOfSlots![index].isSlotSelected ? Colors.green : Colors.blue),
                                color: _singleFacilityDatesList[0].listOfSlots![index].isSlotSelected ? Colors.green : Colors.blue),
                            child: Center(
                              child: CustomTextView(
                                label:
                                    '${_singleFacilityDatesList[0].listOfSlots![index].startTime} - ${_singleFacilityDatesList[0].listOfSlots![index].endTime}',
                                type: styleSubTitle,
                                textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: OQDOThemeData.whiteColor),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Column(
                          children: [
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                CustomTextView(
                                  label: _singleFacilityDatesList[0].listOfSlots![index].availableSeat.toString(),
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(fontSize: 14, color: OQDOThemeData.blackColor, fontWeight: FontWeight.w300),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Image.asset(
                                  'assets/images/ic_booked_timeslots.png',
                                  width: 15,
                                  height: 15,
                                ),
                              ],
                            ),
                            CustomTextView(
                              label: 'Available',
                              textStyle:
                                  Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF333333)),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _singleFacilityDatesList[0].listOfSlots![index].isSlotSelected ? Colors.green : const Color(0xFFCCCCCC),
                              ),
                              color: _singleFacilityDatesList[0].listOfSlots![index].isSlotSelected ? Colors.green : const Color(0xFFCCCCCC),
                            ),
                            child: Center(
                              child: CustomTextView(
                                label:
                                    '${_singleFacilityDatesList[0].listOfSlots![index].startTime} - ${_singleFacilityDatesList[0].listOfSlots![index].endTime}',
                                type: styleSubTitle,
                                textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.onSurface),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Column(
                          children: [
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                CustomTextView(
                                  label: _singleFacilityDatesList[0].listOfSlots![index].availableSeat.toString(),
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(fontSize: 14, color: OQDOThemeData.blackColor, fontWeight: FontWeight.w300),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Image.asset(
                                  'assets/images/ic_booked_timeslots.png',
                                  width: 15,
                                  height: 15,
                                ),
                              ],
                            ),
                            CustomTextView(
                              label: 'Available',
                              textStyle:
                                  Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF333333)),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ],
                    ),
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    if (await NetworkConnectionInterceptor().isConnected()) {
      debugPrint('On calendar change -> $selectedDay');
      if (!isSameDay(_selectedDay, selectedDay)) {
        setState(() {
          _selectedDay = selectedDay;
        });
        monthChangeStr();
        showSlotsList();
      }
    } else {
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    }
  }

  void monthChangeStr() {
    setState(() {
      monthStr = DateFormat.yMMMM().format(_selectedDay!).split(' ')[0];
    });
  }

  String checkForAvailableSlots(int? facilitySetupDaySlotMapId, int index) {
    List<AvailableSlotsByDateResponseModel> availableSlotsModelList =
        _availableSlotsByDateResponseModelList.where((element) => element.facilitySetupDaySlotMapId == facilitySetupDaySlotMapId!).toList();

    return availableSlotsModelList[0].availableSeat.toString();
  }

  void addTimer() {
    var timerDifference = DateTime.now().difference(bookingStartTime);

    if (timerDifference.inSeconds >= bookingTimeDuration.inSeconds) {
      bookingRemainingTimer?.cancel();
      totalAmount = 0.00;
      isHomeVisible = true;
      _facilitySlotBookingModelList.clear();
      _singleFacilityDatesList.clear();
      _availableSlotsByDateResponseModelList.clear();
    }

    if (!mounted) return;
    setState(() {});
  }

  void startBookingTimer() {
    bookingRemainingTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      addTimer();
    });
  }

  String checkForFreezeFacilityBookingId() {
    String facilityFreezeBookingId = '';
    for (int i = 0; i < _facilitySlotBookingModelList.length; i++) {
      for (int j = 0; j < _facilitySlotBookingModelList[i].listOfSlots!.length; j++) {
        if (_facilitySlotBookingModelList[i].listOfSlots![j].facilityBookingFreezeId.isNotEmpty) {
          debugPrint('facilityFreezeBookingId -> $facilityFreezeBookingId');
          facilityFreezeBookingId = _facilitySlotBookingModelList[i].listOfSlots![j].facilityBookingFreezeId.toString();
          break;
        }
      }
    }
    debugPrint('after loop -> $facilityFreezeBookingId');
    return facilityFreezeBookingId;
  }

  double getTotalAmountFromList() {
    double totalAmount = 0.00;
    for (int i = 0; i < _facilitySlotBookingModelList.length; i++) {
      for (int j = 0; j < _facilitySlotBookingModelList[i].listOfSlots!.length; j++) {
        debugPrint('getTotalAmountFromList -> ${_facilitySlotBookingModelList[i].listOfSlots![j].totalAmount}');
        totalAmount = _facilitySlotBookingModelList[i].listOfSlots![j].totalAmount;
      }
    }
    debugPrint('getTotalAmountFromList -> $totalAmount');
    return totalAmount;
  }

  void showSlotsList() {
    debugPrint('Selected date -> $_selectedDay');
    String selectedDayStr = DateFormat('yyyy-MM-dd').format(_selectedDay!);
    debugPrint('formatted selected date -> $selectedDayStr');

    String currentDate = DateFormat('yyyy-MM-dd').format(kToday);
    debugPrint('Current Date -> $currentDate');

    if (selectedDayStr.compareTo(currentDate) == 0) {
      setState(() {
        _singleFacilityDatesList.clear();
        _availableSlotsByDateResponseModelList.clear();
        debugPrint('element date -> ${_facilitySlotBookingModelList[0].date}');
        _singleFacilityDatesList = _facilitySlotBookingModelList.where((element) => element.date == selectedDayStr).toList();
        debugPrint('Single slots model -> ${_singleFacilityDatesList[0].date}');
        debugPrint('Single slots model -> ${_singleFacilityDatesList[0].listOfSlots}');
        String time = DateTime.now().toString();
        debugPrint('Time -> $time');
        String hours = time.split(' ')[1].split('.')[0].split(':')[0];
        String minutes = time.split(' ')[1].split('.')[0].split(':')[1];
        Duration currentTimeDuration = Duration(hours: int.parse(hours), minutes: int.parse(minutes));
        int finalMinutes = int.parse(hours) + 1;
        // int finalMinutes = int.parse(minutes);
        debugPrint('finalMinutes -> $finalMinutes');
        // String finalTime = '$finalMinutes:$minutes';
        debugPrint('Time -> $currentTimeDuration');
        for (var i = 0; i < _singleFacilityDatesList[0].listOfSlots!.length; i++) {
          String startTimeHours = _singleFacilityDatesList[0].listOfSlots![i].startTime!.split(':')[0];
          String startTimeMinutes = _singleFacilityDatesList[0].listOfSlots![i].startTime!.split(':')[1];
          Duration startTimeInDuration = Duration(hours: int.parse(startTimeHours), minutes: int.parse(startTimeMinutes));
          if (startTimeInDuration.compareTo(currentTimeDuration) <= 0) {
            _singleFacilityDatesList[0].listOfSlots![i].isSlotTimePassed = true;
            debugPrint(
                'Passed Date -> ${_singleFacilityDatesList[0].listOfSlots![i].endTime} -> ${_singleFacilityDatesList[0].listOfSlots![i].isSlotTimePassed}');
          }
        }
        if (_singleFacilityDatesList.isNotEmpty) {
          if (_singleFacilityDatesList[0].listOfSlots!.isNotEmpty) {
            getFacilityAvailableSlotByDate(_calendarViewModel.getFacilityByIdModel!.facilitySetupId, convertDateTimeToString(_selectedDay!));
          }
        } else {
          get21DaysFacilitySlots(
              _calendarViewModel.getFacilityByIdModel!.facilitySetupId, convertDateTimeToString(_selectedDay!), convertDateTimeToString(kLastDay));
        }
      });
    } else {
      setState(() {
        _singleFacilityDatesList.clear();
        _availableSlotsByDateResponseModelList.clear();
        debugPrint('element date -> ${_facilitySlotBookingModelList[0].date}');
        _singleFacilityDatesList = _facilitySlotBookingModelList.where((element) => element.date == selectedDayStr).toList();
        debugPrint('single facility date list length -> ${_singleFacilityDatesList.length}');
        if (_singleFacilityDatesList.isNotEmpty) {
          if (_singleFacilityDatesList[0].listOfSlots!.isNotEmpty) {
            getFacilityAvailableSlotByDate(_calendarViewModel.getFacilityByIdModel!.facilitySetupId, convertDateTimeToString(_selectedDay!));
          }
        } else {
          get21DaysFacilitySlots(
              _calendarViewModel.getFacilityByIdModel!.facilitySetupId, convertDateTimeToString(_selectedDay!), convertDateTimeToString(kLastDay));
        }
      });
    }
  }

  Future<void> get21DaysFacilitySlots(int? facilitySetupId, String convertDateTimeToString, String passingLastDate) async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    try {
      await _progressDialog.show();
      List<Get21DaysSlotResponseModel> list =
          await Provider.of<SlotManagementViewModel>(context, listen: false).get21DaysFacilitySlots(facilitySetupId!, convertDateTimeToString, passingLastDate);
      await _progressDialog.hide();
      if (list.isNotEmpty) {
        _facilitySlotBookingModelList.clear();
        List<FacilitySlotBookingModel> facilitySlotBookingModelList = [];
        for (int i = 0; i < list.length; i++) {
          FacilitySlotBookingModel facilitySlotBookingModel = FacilitySlotBookingModel();
          facilitySlotBookingModel.date = list[i].date;
          List<SlotListModel> slotListModelList = [];
          for (int j = 0; j < list[i].slotList!.length; j++) {
            SlotListModel slotListModel = SlotListModel();
            slotListModel.facilitySetupDaySlotMapId = list[i].slotList![j].facilitySetupDaySlotMapId;
            slotListModel.facilitySetupDetailId = list[i].slotList![j].facilitySetupDetailId;
            slotListModel.startTime = list[i].slotList![j].startTime;
            slotListModel.endTime = list[i].slotList![j].endTime;
            slotListModelList.add(slotListModel);
          }
          facilitySlotBookingModel.listOfSlots = slotListModelList;
          facilitySlotBookingModelList.add(facilitySlotBookingModel);
        }

        setState(() {
          _facilitySlotBookingModelList.addAll(facilitySlotBookingModelList);
          debugPrint('facility slot booking -> ${_facilitySlotBookingModelList.toString()}');
          FacilitySlotBookingModel first21DaysSlotModel = _facilitySlotBookingModelList.first;
          FacilitySlotBookingModel last21DaysSlotModel = _facilitySlotBookingModelList.last;
          firstDate = DateTime.parse(first21DaysSlotModel.date!);
          debugPrint('First Date -> $firstDate');
          lastDate = DateTime.parse(last21DaysSlotModel.date!);
          debugPrint('Last Date -> $lastDate');
          showSlotsList();
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

  Future<void> getFacilityAvailableSlotByDate(int? facilitySetupId, String convertDateTimeToString) async {
    try {
      showLoader();
      List<AvailableSlotsByDateResponseModel> list =
          await Provider.of<SlotManagementViewModel>(context, listen: false).getFacilityAvailableSlotsByDate(facilitySetupId!, convertDateTimeToString);
      hideLoader();
      debugPrint('After API call -> ${_singleFacilityDatesList[0].listOfSlots![0].facilitySetupDaySlotMapId}');
      if (list.isNotEmpty) {
        setState(() {
          for (int i = 0; i < _singleFacilityDatesList[0].listOfSlots!.length; i++) {
            if (_singleFacilityDatesList[0].listOfSlots![i].facilitySetupDaySlotMapId == list[i].facilitySetupDaySlotMapId) {
              _singleFacilityDatesList[0].listOfSlots![i].availableSeat = list[i].availableSeat!;
              _singleFacilityDatesList[0].listOfSlots![i].bookedSeat = list[i].bookedSeat!;
              _singleFacilityDatesList[0].listOfSlots![i].totalSeat = list[i].totalSeat!;
            }
          }
        });
      }
    } on CommonException catch (error) {
      hideLoader();
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
      hideLoader();
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      hideLoader();
      debugPrint(error.toString());
      // showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  Future<void> freezeFacilityBookingCall(SlotListModel slotList) async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    Map<String, dynamic> request = {};
    request['EndUserId'] = OQDOApplication.instance.endUserID.toString();
    request['FacilitySetupDetailId'] = _calendarViewModel.getFacilityByIdModel!.facilitySetupDetailId.toString();
    request['IsSlotSelected'] = true;
    request['FacilityBookingFreezeId'] = checkForFreezeFacilityBookingId() != ' ' ? checkForFreezeFacilityBookingId() : '';
    request['BookingDate'] = convertDateTimeToString(_selectedDay!);
    request['FacilitySetupDaySlotMapId'] = slotList.facilitySetupDaySlotMapId;
    debugPrint('request -> $request');
    try {
      await _progressDialog.show();
      FreezeFacilityResponseModel response = await Provider.of<SlotManagementViewModel>(context, listen: false).freezeFacilityBooking(request);
      await _progressDialog.hide();
      if (response.facilitySetupDaySlotMapId! > 0) {
        if (slotList.facilitySetupDaySlotMapId == response.facilitySetupDaySlotMapId) {
          setState(() {
            slotList.facilityBookingFreezeId = response.facilityBookingFreezeId.toString();
            slotList.isSlotSelected = response.isSlotSelected!;
            slotList.bookingDate = convertDateTimeToString(_selectedDay!);
            slotList.totalAmount = response.totalAmount!;
            totalAmount = response.totalAmount!;
            slotList.availableSeat = slotList.availableSeat - 1;
            slotList.isMeetupConflict = response.isMeetupConflict ?? false;
            if (slotList.isMeetupConflict) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return WillPopScope(
                    onWillPop: () async => false,
                    child: AlertDialog(
                      content: CustomTextView(
                        label:
                            'It appears that you have a scheduled meetup at the chosen time. To prevent any conflicts, you can either unfreeze the slot or request a time change from the meetup creator',
                        maxLine: 5,
                        textStyle: const TextStyle(fontSize: 15, color: Colors.black),
                        textOverFlow: TextOverflow.ellipsis,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Okay'),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            isTimingShow = true;

            if (!isBookingTimer) {
              isBookingTimer = true;
              bookingStartTime = DateTime.now();
              // startBookingTimer();
            }
          });
          // getFacilityAvailableSlotByDate(
          //     _calendarViewModel.getFacilityByIdModel!.facilitySetupId, convertDateTimeToString(_selectedDay!));
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
      }
      if (error.code == 401) {
        showSnackBarColor('Unauthorized! Login again...', context, true);
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

  Future<void> unFreezeFacilityBookingCall(SlotListModel slotList, String type) async {
    Map<String, dynamic> request = {};
    request['EndUserId'] = OQDOApplication.instance.endUserID.toString();
    request['FacilitySetupDetailId'] = _calendarViewModel.getFacilityByIdModel!.facilitySetupDetailId.toString();
    request['IsSlotSelected'] = false;
    request['FacilityBookingFreezeId'] = checkForFreezeFacilityBookingId() != ' ' ? checkForFreezeFacilityBookingId() : '';
    request['BookingDate'] = convertDateTimeToString(_selectedDay!);
    request['FacilitySetupDaySlotMapId'] = slotList.facilitySetupDaySlotMapId;
    debugPrint('request -> $request');
    try {
      await _progressDialog.show();
      FreezeFacilityResponseModel response = await Provider.of<SlotManagementViewModel>(context, listen: false).unFreezeFacilityBooking(request);
      await _progressDialog.hide();
      if (response.facilitySetupDaySlotMapId! > 0) {
        if (slotList.facilitySetupDaySlotMapId == response.facilitySetupDaySlotMapId) {
          setState(() {
            slotList.facilityBookingFreezeId = response.facilityBookingFreezeId.toString();
            slotList.isSlotSelected = response.isSlotSelected!;
            slotList.totalAmount = response.totalAmount!;
            totalAmount = response.totalAmount!;
            slotList.facilityBookingFreezeId = '';
            slotList.availableSeat = slotList.availableSeat + 1;
          });
          // getFacilityAvailableSlotByDate(
          //     _calendarViewModel.getFacilityByIdModel!.facilitySetupId, convertDateTimeToString(_selectedDay!));
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
            if (modelState['ErrorMessage'][0].toString().toLowerCase().contains('expire')) {
              setState(() {
                totalAmount = 0.00;
                isHomeVisible = true;
                _facilitySlotBookingModelList.clear();
                _singleFacilityDatesList.clear();
                _availableSlotsByDateResponseModelList.clear();
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
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
      await _progressDialog.hide();
    } catch (error) {
      await _progressDialog.hide();
      debugPrint(error.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  Future<bool> onWillPop() async {
    if (totalAmount <= 0.00) {
      return Future.value(true);
    } else {
      return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: const Text('Slot Booking'),
                    content: const Text('Are you sure you want to cancel and Exit?\nIf you leave now you\'ll have to start from scratch next time.'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('No, Continue Booking'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          unFreezeSelectedSlots();
                        },
                        child: const Text('Yes, Cancel and Exit'),
                      ),
                    ],
                  )) ??
          false;
    }
  }

  Widget showCalendarSheet(StateSetter setState) {
    void onDaySelectedView(
      DateTime selectedDay,
      DateTime focusedDay,
    ) {
      if (!isSameDay(_selectedDayView, selectedDay)) {
        setState(() {
          _selectedDayView = selectedDay;
          _focusedDay = focusedDay;
          _currentDay = format.format(_focusedDay);
          initSelectedDate = DateFormat.yMMMMEEEEd().format(_focusedDay).split(' ')[0].split(',')[0];
        });
      }
    }

    return Container(
      color: OQDOThemeData.whiteColor,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 1.2,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: calendarHeader(setState),
            ),
            const SizedBox(
              height: 30,
            ),
            CustomTextView(
              label: '${_currentDay.split("-")[0]} ${_currentDay.split('-')[1]} ${_currentDay.split('-')[2]}',
              textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 21, color: const Color(0xFF333333), fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 3,
            ),
            CustomTextView(
              label: initSelectedDate,
              textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 21, color: const Color(0xFF333333), fontWeight: FontWeight.w500),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 25, right: 25),
              child: TableCalendar(
                firstDay: kFirstDay,
                lastDay: kLastDay,
                focusedDay: _selectedDay!,
                calendarFormat: _calendarViewFormat,
                headerVisible: false,
                daysOfWeekVisible: true,
                currentDay: kToday,
                daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Color(0xFF006590), fontWeight: FontWeight.w500),
                    weekendStyle: TextStyle(color: Color(0xFF006590), fontWeight: FontWeight.w500)),
                calendarStyle: CalendarStyle(
                  isTodayHighlighted: false,
                  outsideDaysVisible: false,
                  selectedDecoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                  defaultTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black),
                ),
                onCalendarCreated: (controller) {
                  _pageController = controller;
                },
                onPageChanged: (focuseDay) {
                  setState(() {
                    _selectedDay = focuseDay;
                  });
                },
                onDaySelected: onDaySelectedView,
                selectedDayPredicate: (DateTime date) {
                  return isSameDay(_selectedDayView, date);
                },
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            _selectedDayView != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                    child: MyButton(
                      text: 'Continue',
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
                        Navigator.of(context).pop(_selectedDayView);
                      },
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget calendarHeader(StateSetter setState) {
    var headerText = DateFormat.yMMMM().format(_selectedDay!);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextView(
                label: headerText.split(' ')[0],
                textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 21, fontWeight: FontWeight.w700, color: const Color(0xFF333333)),
              ),
              const SizedBox(
                height: 5,
              ),
              CustomTextView(
                label: headerText.split(' ')[1],
                textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 21, fontWeight: FontWeight.w700, color: const Color(0xFF333333)),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => onLeftArrowTap(),
                child: Image.asset(
                  'assets/images/ic_calendar_pre.png',
                  width: 30,
                  height: 30,
                ),
              ),
              const SizedBox(
                width: 30,
              ),
              GestureDetector(
                onTap: () => onRightArrowTap(),
                child: Image.asset(
                  'assets/images/ic_calendar_next.png',
                  width: 30,
                  height: 30,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  onLeftArrowTap() {
    _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  onRightArrowTap() {
    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  void showLoader() {
    setState(() {
      isLoading = true;
    });
  }

  void hideLoader() {
    setState(() {
      isLoading = false;
    });
  }

  void unFreezeSelectedSlots() {
    for (var i = 0; i < _facilitySlotBookingModelList.length; i++) {
      debugPrint('length -> ${_facilitySlotBookingModelList.length}');
      for (int j = 0; j < _facilitySlotBookingModelList[i].listOfSlots!.length; j++) {
        if (_facilitySlotBookingModelList[i].listOfSlots![j].isSlotSelected) {
          unFreezeCountList.add(_facilitySlotBookingModelList[i].listOfSlots![j]);
        }
      }
    }
    unFreezeAllSelectedSlot();
  }

  /// Asynchronously removes the freeze status from all selected slots.
  ///
  /// This method is responsible for unfreezing any previously frozen slots
  /// that have been selected. The operation is performed asynchronously
  /// and returns a Future that completes when all slots have been unfrozen.
  Future<void> unFreezeAllSelectedSlot() async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    try {
      if (unFreezeCountList.isNotEmpty) {
        await _progressDialog.show();

        // Create list of request objects
        List<Map<String, dynamic>> requestList = unFreezeCountList.map((slot) {
          return {
            'EndUserId': OQDOApplication.instance.endUserID.toString(),
            'FacilitySetupDetailId': _calendarViewModel.getFacilityByIdModel!.facilitySetupDetailId.toString(),
            'IsSlotSelected': false,
            'FacilityBookingFreezeId': checkForFreezeFacilityBookingId() != ' ' ? checkForFreezeFacilityBookingId() : '',
            'BookingDate': slot.bookingDate,
            'FacilitySetupDaySlotMapId': slot.facilitySetupDaySlotMapId
          };
        }).toList();

        // Make single API call with list of requests
        bool response = await Provider.of<SlotManagementViewModel>(context, listen: false).unFreezeFacilityBookingList(requestList);

        await _progressDialog.hide();

        if (response) {
          Navigator.of(context).pop(true);
        } else {
          showSnackBarColor('error', context, true);
        }
      } else {
        Navigator.of(context).pop(true);
      }
    } on CommonException catch (error) {
      await _progressDialog.hide();
      setState(() {});
      debugPrint('error -> $error');
      if (error.code == 400) {
        Map<String, dynamic> errorModel = jsonDecode(error.message);
        if (errorModel.containsKey('ModelState')) {
          Map<String, dynamic> modelState = errorModel['ModelState'];
          if (modelState.containsKey('ErrorMessage')) {
            showSnackBarColor(modelState['ErrorMessage'][0], context, true);
            if (modelState['ErrorMessage'][0].toString().toLowerCase().contains('expire')) {
              setState(() {
                totalAmount = 0.00;
                isHomeVisible = true;
                _facilitySlotBookingModelList.clear();
                _singleFacilityDatesList.clear();
                _availableSlotsByDateResponseModelList.clear();
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
      // totalAmount = 0;
      // isHomeVisible = true;
      // setState(() {});
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      await _progressDialog.hide();
      // totalAmount = 0;
      // isHomeVisible = true;
      // setState(() {});
      debugPrint('error -> $error');
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  // Future<void> unFreezeAllSelectedSlot() async {
  //   _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
  //   _progressDialog.style(message: "Please wait..");
  //   try {
  //     for (int i = 0; i < unFreezeCountList.length; i++) {
  //       if (unFreezeCountList.isNotEmpty) {
  //         await _progressDialog.show();
  //         Map<String, dynamic> request = {};
  //         request['EndUserId'] = OQDOApplication.instance.endUserID.toString();
  //         request['FacilitySetupDetailId'] = _calendarViewModel.getFacilityByIdModel!.facilitySetupDetailId.toString();
  //         request['IsSlotSelected'] = false;
  //         request['FacilityBookingFreezeId'] = checkForFreezeFacilityBookingId() != ' ' ? checkForFreezeFacilityBookingId() : '';
  //         request['BookingDate'] = unFreezeCountList[i].bookingDate;
  //         request['FacilitySetupDaySlotMapId'] = unFreezeCountList[i].facilitySetupDaySlotMapId;
  //         FreezeFacilityResponseModel response = await Provider.of<SlotManagementViewModel>(context, listen: false).unFreezeFacilityBooking(request);
  //         await _progressDialog.hide();
  //         if (response.totalAmount! <= 0.0) {
  //           Navigator.of(context).pop(true);
  //         }
  //       } else {
  //         Navigator.of(context).pop(true);
  //       }
  //     }
  //   } on CommonException catch (error) {
  //     await _progressDialog.hide();
  //     setState(() {});
  //     debugPrint('error -> $error');
  //     if (error.code == 400) {
  //       Map<String, dynamic> errorModel = jsonDecode(error.message);
  //       if (errorModel.containsKey('ModelState')) {
  //         Map<String, dynamic> modelState = errorModel['ModelState'];
  //         if (modelState.containsKey('ErrorMessage')) {
  //           showSnackBarColor(modelState['ErrorMessage'][0], context, true);
  //           if (modelState['ErrorMessage'][0].toString().toLowerCase().contains('expire')) {
  //             setState(() {
  //               totalAmount = 0.00;
  //               isHomeVisible = true;
  //               _facilitySlotBookingModelList.clear();
  //               _singleFacilityDatesList.clear();
  //               _availableSlotsByDateResponseModelList.clear();
  //             });
  //           }
  //         } else {
  //           showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
  //         }
  //       } else {
  //         showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
  //       }
  //     } else {
  //       showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
  //     }
  //   } on NoConnectivityException catch (_) {
  //     await _progressDialog.hide();
  //     // totalAmount = 0;
  //     // isHomeVisible = true;
  //     // setState(() {});
  //     showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
  //   } catch (error) {
  //     await _progressDialog.hide();
  //     // totalAmount = 0;
  //     // isHomeVisible = true;
  //     // setState(() {});
  //     debugPrint('error -> $error');
  //     showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
  //   }
  // }
}
