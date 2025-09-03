import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/model/calendar_view_model.dart';
import 'package:oqdo_mobile_app/model/cancel_reason_view_model.dart';
import 'package:oqdo_mobile_app/model/coach_available_slots_by_date_response_model.dart';
import 'package:oqdo_mobile_app/model/coach_get_21_days_slot_response_model.dart';
import 'package:oqdo_mobile_app/model/coach_slot_booking_model.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:oqdo_mobile_app/viewmodels/slot_management_view_model.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CoachCancelSlotScreen extends StatefulWidget {
  CalendarViewModel? calendarViewModel;

  CoachCancelSlotScreen({Key? key, this.calendarViewModel}) : super(key: key);

  @override
  State<CoachCancelSlotScreen> createState() => _CoachCancelSlotScreenState();
}

class _CoachCancelSlotScreenState extends State<CoachCancelSlotScreen> {
  late CalendarViewModel _calendarViewModel;
  String monthStr = '';
  late ProgressDialog _progressDialog;
  final List<CoachSlotBookingModel> _facilitySlotBookingModelList = [];
  DateTime? firstDate;
  DateTime? lastDate;
  DateTime? _selectedDay;
  final CalendarFormat _calendarFormat = CalendarFormat.week;
  List<CoachSlotBookingModel> _singleFacilityDatesList = [];
  final List<CoachAvailableSlotsByDateResponseModel> _availableSlotsByDateResponseModelList = [];
  int count = 0;

  bool isLoading = false;

  late DateTime lastDateForBooking;
  DateTime currentDateTime = DateTime.now();
  late PageController _pageController;
  final CalendarFormat _calendarViewFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  late String _currentDay;
  DateFormat format = DateFormat('d-MMMM-yyyy');
  DateTime? _selectedDayView;
  String initSelectedDate = '';

  @override
  void initState() {
    super.initState();
    _calendarViewModel = widget.calendarViewModel!;
    monthStr = DateFormat.yMMMM().format(_calendarViewModel.selectedDateTime!).split(' ')[0];
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _selectedDay = _calendarViewModel.selectedDateTime!;
      _currentDay = format.format(_focusedDay);
      initSelectedDate = DateFormat.yMMMMEEEEd().format(_focusedDay).split(' ')[0].split(',')[0];
      if (await NetworkConnectionInterceptor().isConnected()) {
        get21DaysFacilitySlots(
            _calendarViewModel.coachBatchSetupId, convertDateTimeToString(_calendarViewModel.selectedDateTime!), convertDateTimeToString(kLastDay));
      } else {
        showNoInternetConnectionSnackBar();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Cancel Slot',
        onBack: () async {
          Navigator.pop(context);
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
                  ? _singleFacilityDatesList[0].listOfSlots!.isNotEmpty
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
                                    const Spacer(),
                                    CustomTextView(
                                      label: 'Select a slot',
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(fontSize: 15, fontWeight: FontWeight.w500, color: const Color(0xFFABABAB)),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                isLoading
                                    ? const Expanded(
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
                                      )
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
                            textStyle:
                                Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 16, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
              const SizedBox(
                height: 20,
              ),
              count > 0
                  ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15.0, left: 20, right: 20),
                          child: MyButton(
                            text: 'Cancel slot',
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
                              CancelReasonViewModel cancelReasonViewModel = CancelReasonViewModel();
                              cancelReasonViewModel.type = 'C';
                              cancelReasonViewModel.coachBookingList = _facilitySlotBookingModelList;
                              await Navigator.of(context).pushNamed(Constants.cancelReasonScreen, arguments: cancelReasonViewModel);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 30, left: 40, right: 40),
                          child: CustomTextView(
                            label: '*Please note, refund will be issued for the booked appointment in case of cancellation.',
                            maxLine: 3,
                            textOverFlow: TextOverflow.ellipsis,
                            textStyle:
                                Theme.of(context).textTheme.titleMedium!.copyWith(color: OQDOThemeData.errorColor, fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                        ),
                      ],
                    )
                  : Container()
            ],
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
                if (await NetworkConnectionInterceptor().isConnected()) {
                  if (value != null) {
                    debugPrint('Sheet selected date -> $value');
                    DateTime passingDate = value as DateTime;
                    setState(() {
                      _selectedDay = passingDate;
                      showSlotsList();
                    });
                  }
                } else {
                  showNoInternetConnectionSnackBar();
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
              return isSameDay(_selectedDay, date);
            },
          )
        : Container();
  }

  Widget showSingleSlotItemView(int index) {
    return InkWell(
      onTap: () {
        if (!_singleFacilityDatesList[0].listOfSlots![index].isSlotCancelled!) {
          if (!_singleFacilityDatesList[0].listOfSlots![index].isSlotTimePassed) {
            setState(() {
              if (_singleFacilityDatesList[0].listOfSlots![index].isSlotSelected) {
                _singleFacilityDatesList[0].listOfSlots![index].isSlotSelected = false;
                count = checkForItemSelected();
                debugPrint('count if -> $count');
              } else {
                _singleFacilityDatesList[0].listOfSlots![index].isSlotSelected = true;
                count = checkForItemSelected();
                debugPrint('count else -> $count');
              }
            });
          }
        }
      },
      child: _singleFacilityDatesList[0].listOfSlots![index].isSlotCancelled!
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
                          label: _singleFacilityDatesList[0].listOfSlots![index].bookedSeat.toString(),
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
                      label: 'Booked',
                      textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF333333)),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ],
            )
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
                              label: _singleFacilityDatesList[0].listOfSlots![index].bookedSeat.toString(),
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
                          label: 'Booked',
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
                            color: _singleFacilityDatesList[0].listOfSlots![index].isSlotSelected ? Colors.green : Colors.blue,
                          ),
                          color: _singleFacilityDatesList[0].listOfSlots![index].isSlotSelected ? Colors.green : Colors.blue,
                        ),
                        child: Center(
                          child: CustomTextView(
                            label: '${_singleFacilityDatesList[0].listOfSlots![index].startTime} - ${_singleFacilityDatesList[0].listOfSlots![index].endTime}',
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
                              label: _singleFacilityDatesList[0].listOfSlots![index].bookedSeat.toString(),
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
                          label: 'Booked',
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
      if (!isSameDay(_selectedDay, selectedDay)) {
        setState(() {
          _selectedDay = selectedDay;
        });
        monthChangeStr();
        showSlotsList();
      }
    } else {
      showNoInternetConnectionSnackBar();
    }
  }

  void monthChangeStr() {
    setState(() {
      monthStr = DateFormat.yMMMM().format(_selectedDay!).split(' ')[0];
    });
  }

  int checkForItemSelected() {
    int facilityFreezeBookingId = 0;
    for (int i = 0; i < _facilitySlotBookingModelList.length; i++) {
      for (int j = 0; j < _facilitySlotBookingModelList[i].listOfSlots!.length; j++) {
        if (_facilitySlotBookingModelList[i].listOfSlots![j].isSlotSelected) {
          facilityFreezeBookingId = facilityFreezeBookingId + 1;
          break;
        }
      }
    }
    debugPrint('after loop -> $facilityFreezeBookingId');
    return facilityFreezeBookingId;
  }

  void showSlotsList() {
    debugPrint('Selected date -> $_selectedDay');
    String selectedDayStr = DateFormat('yyyy-MM-dd').format(_selectedDay!);
    debugPrint('formated selected date -> $selectedDayStr');

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
        String time = DateTime.now().add(Duration(minutes: OQDOApplication.instance.configResponseModel?.providerCancellationAllowedMin ?? 0)).toString();
        debugPrint('Time -> $time');
        String minutes = time.split(' ')[1].split('.')[0].split(':')[0];
        String seconds = time.split(' ')[1].split('.')[0].split(':')[1];
        int finalMinutes = int.parse(minutes);
        debugPrint('finalMinutes -> $finalMinutes');
        String finalTime = '$finalMinutes:$seconds';
        debugPrint('Time -> $finalTime');
        for (var i = 0; i < _singleFacilityDatesList[0].listOfSlots!.length; i++) {
          if (finalTime.compareTo(_singleFacilityDatesList[0].listOfSlots![i].startTime!) > 0) {
            _singleFacilityDatesList[0].listOfSlots![i].isSlotTimePassed = true;
            debugPrint(
                'Passed Date -> ${_singleFacilityDatesList[0].listOfSlots![i].endTime} -> ${_singleFacilityDatesList[0].listOfSlots![i].isSlotTimePassed}');
          }
        }

        if (_singleFacilityDatesList.isNotEmpty) {
          if (_singleFacilityDatesList[0].listOfSlots!.isNotEmpty) {
            getFacilityAvalableSlotByDate(_calendarViewModel.coachBatchSetupId, convertDateTimeToString(_selectedDay!));
          }
        } else {
          get21DaysFacilitySlots(_calendarViewModel.coachBatchSetupId, convertDateTimeToString(_selectedDay!), convertDateTimeToString(kLastDay));
        }
      });
    } else {
      setState(() {
        _singleFacilityDatesList.clear();
        _availableSlotsByDateResponseModelList.clear();
        debugPrint('element date ->  ${_facilitySlotBookingModelList[0].date}');
        _singleFacilityDatesList = _facilitySlotBookingModelList.where((element) => element.date == selectedDayStr).toList();
        debugPrint('Single slots model -> ${_singleFacilityDatesList[0].date}');
        debugPrint('Single slots model -> ${_singleFacilityDatesList[0].listOfSlots}');
        if (_singleFacilityDatesList.isNotEmpty) {
          if (_singleFacilityDatesList[0].listOfSlots!.isNotEmpty) {
            getFacilityAvalableSlotByDate(_calendarViewModel.coachBatchSetupId, convertDateTimeToString(_selectedDay!));
          }
        } else {
          get21DaysFacilitySlots(_calendarViewModel.coachBatchSetupId, convertDateTimeToString(_selectedDay!), convertDateTimeToString(kLastDay));
        }
      });
    }
  }

  Future<void> get21DaysFacilitySlots(int? facilitySetupId, String convertDateTimeToString, String passingLastDate) async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    try {
      _progressDialog.show();
      if (!mounted) return;
      List<CoachGet21DaysSlotResponseModel> list = await Provider.of<SlotManagementViewModel>(context, listen: false)
          .getCoach21DaysFacilitySlots(facilitySetupId!, convertDateTimeToString, passingLastDate);
      _progressDialog.hide();
      if (list.isNotEmpty) {
        _facilitySlotBookingModelList.clear();
        List<CoachSlotBookingModel> facilitySlotBookingModelList = [];
        for (int i = 0; i < list.length; i++) {
          CoachSlotBookingModel facilitySlotBookingModel = CoachSlotBookingModel();
          facilitySlotBookingModel.date = list[i].date;
          List<CoachSlotListModel> slotListModelList = [];
          for (int j = 0; j < list[i].slotList!.length; j++) {
            CoachSlotListModel slotListModel = CoachSlotListModel();
            slotListModel.coachBatchSetupDetailId = list[i].slotList![j].coachBatchSetupDetailId;
            slotListModel.coachBatchSetupDaySlotMapId = list[i].slotList![j].coachBatchSetupDaySlotMapId;
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
          CoachSlotBookingModel first21DaysSlotModel = _facilitySlotBookingModelList.first;
          CoachSlotBookingModel last21DaysSlotModel = _facilitySlotBookingModelList.last;
          firstDate = DateTime.parse(first21DaysSlotModel.date!);
          debugPrint('First Date -> $firstDate');
          lastDate = DateTime.parse(last21DaysSlotModel.date!);
          debugPrint('Last Date -> $lastDate');
          _selectedDay = _calendarViewModel.selectedDateTime!;
          showSlotsList();
        });
      }
    } on CommonException catch (error) {
      await _progressDialog.hide();
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
      await _progressDialog.hide();
      if (!mounted) return;
      // _singleFacilityDatesList[0].listOfSlots!.clear();
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      await _progressDialog.hide();
      if (!mounted) return;
      debugPrint(error.toString());
      // _singleFacilityDatesList[0].listOfSlots!.clear();
      _singleFacilityDatesList.clear();
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  Future<void> getFacilityAvalableSlotByDate(int? facilitySetupId, String convertDateTimeToString) async {
    try {
      showLoader();
      List<CoachAvailableSlotsByDateResponseModel> list =
          await Provider.of<SlotManagementViewModel>(context, listen: false).getCoachAvailableSlotsByDate(facilitySetupId!, convertDateTimeToString);
      hideLoader();
      if (!mounted) return;
      // debugPrint('After API call -> ${_singleFacilityDatesList[0].listOfSlots![0].coachBatchSetupDaySlotMapId}');
      if (list.isNotEmpty) {
        setState(() {
          debugPrint(_singleFacilityDatesList[0].listOfSlots![0].availableSeat.toString());
          for (int i = 0; i < _singleFacilityDatesList[0].listOfSlots!.length; i++) {
            if (_singleFacilityDatesList[0].listOfSlots![i].coachBatchSetupDaySlotMapId == list[i].coachBatchSetupDaySlotMapId) {
              _singleFacilityDatesList[0].listOfSlots![i].availableSeat = list[i].availableSeat!;
              _singleFacilityDatesList[0].listOfSlots![i].bookedSeat = list[i].bookedSeat!;
              _singleFacilityDatesList[0].listOfSlots![i].totalSeat = list[i].totalSeat!;
              _singleFacilityDatesList[0].listOfSlots![i].isSlotCancelled = list[i].isSlotCancelled;
            }
          }
        });
      }
    } on CommonException catch (error) {
      hideLoader();
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
      hideLoader();
      if (!mounted) return;
      // _singleFacilityDatesList[0].listOfSlots!.clear();
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      hideLoader();
      if (!mounted) return;
      // _singleFacilityDatesList[0].listOfSlots!.clear();
      _singleFacilityDatesList.clear();
      debugPrint(error.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
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

  Widget showCalendarSheet(StateSetter setState) {
    void _onDaySelectedView(
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
                focusedDay: _focusedDay,
                calendarFormat: _calendarViewFormat,
                headerVisible: false,
                daysOfWeekVisible: true,
                currentDay: kToday,
                daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Color(0xFF006590), fontWeight: FontWeight.w500),
                    weekendStyle: TextStyle(color: Color(0xFF006590), fontWeight: FontWeight.w500)),
                calendarStyle: CalendarStyle(
                  isTodayHighlighted: true,
                  outsideDaysVisible: false,
                  selectedDecoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                  defaultTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black),
                ),
                onCalendarCreated: (controller) {
                  _pageController = controller;
                },
                onPageChanged: (focuseDay) {
                  setState(() {
                    _focusedDay = focuseDay;
                  });
                },
                onDaySelected: _onDaySelectedView,
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
    var headerText = DateFormat.yMMMM().format(_focusedDay);
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
}
