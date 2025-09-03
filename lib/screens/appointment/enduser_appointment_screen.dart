// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/helper/helpers.dart';
import 'package:oqdo_mobile_app/model/cancel_reason_list_response_model.dart';
import 'package:oqdo_mobile_app/model/coach_appointment_details_response_model.dart' as model;
import 'package:oqdo_mobile_app/model/end_user_appoinments_model.dart';
import 'package:oqdo_mobile_app/model/end_user_appointment_model_details.dart';
import 'package:oqdo_mobile_app/model/facility_appointment_details_model.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:oqdo_mobile_app/viewmodels/appointment_view_model.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:table_calendar/table_calendar.dart';

class EndUserAppointmentsScreen extends StatefulWidget {
  DateTime? selectedDate;

  EndUserAppointmentsScreen({Key? key, this.selectedDate}) : super(key: key);

  @override
  State<EndUserAppointmentsScreen> createState() => _EndUserAppointmentsScreenState();
}

class _EndUserAppointmentsScreenState extends State<EndUserAppointmentsScreen> {
  late ProgressDialog _progressDialog;
  List<EndUserAppointmentsResponseModel> _endUserAppointmentList = [];

  // List<EndUserAppointmentsResponseModel> _endUserAppointmentResponseList = [];
  String monthStr = '';
  DateTime? firstDate;
  DateTime? lastDate;
  DateTime? _selectedDay;
  final CalendarFormat _calendarFormat = CalendarFormat.week;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  int? firstItemIndex;
  int? lastItemIndex;

  late DateTime lastDateForBooking;
  DateTime currentDateTime = DateTime.now();
  late PageController _pageController;
  final CalendarFormat _calendarViewFormat = CalendarFormat.month;
  DateTime? _focusedDay;
  late String _currentDay;
  DateFormat format = DateFormat('d-MMMM-yyyy');
  DateTime? _selectedDayView;
  String initSelectedDate = '';

  model.CoachAppointmentDetailResponseModel? coachAppointmentDetailResponseModel;
  var reasonValue = ' ';
  FacilityAppointmentDetailModel? _facilityAppointmentDetailModel;
  String addressData = '';
  final List<CancelReasonListResponseModel> _cancelReasonResponseModelList = [];
  String selectedReasonStr = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _selectedDay = widget.selectedDate!;
      _focusedDay = DateTime.now();
      // reasonValue = OQDOApplication.instance.configResponseModel!.didntShowReasonId!;
      // debugPrint(reasonValue);
      _currentDay = format.format(_focusedDay!);
      initSelectedDate = DateFormat.yMMMMEEEEd().format(_focusedDay!).split(' ')[0].split(',')[0];
      getEndUserAppointments(widget.selectedDate!);
      getCancelReasons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: 'Appointments Management',
          onBack: () async {
            Navigator.pop(context);
          }),
      body: SafeArea(
        child: Container(
          color: OQDOThemeData.whiteColor,
          width: MediaQuery.of(context).size.width,
          height: double.infinity,
          child: _endUserAppointmentList.isNotEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    headerView(),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30, left: 10.0, right: 10, bottom: 20),
                      child: calendarView(),
                    ),
                    Expanded(
                      child: ScrollablePositionedList.builder(
                        itemCount: _endUserAppointmentList.length,
                        shrinkWrap: true,
                        itemScrollController: itemScrollController,
                        itemPositionsListener: itemPositionsListener,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          return Column(
                            key: ValueKey<String>(_endUserAppointmentList[index].date!),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0, top: 5),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF006590),
                                      border: Border.all(color: OQDOThemeData.dividerColor),
                                      borderRadius: const BorderRadius.all(Radius.circular(10))),
                                  child: CustomTextView(
                                    label: _endUserAppointmentList[index].date!.split('T')[0],
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(color: OQDOThemeData.whiteColor, fontSize: 18, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              _endUserAppointmentList[index].appointmentListingSlotDtos!.isNotEmpty
                                  ? ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: _endUserAppointmentList[index].appointmentListingSlotDtos!.length,
                                      itemBuilder: (BuildContext context, int subIndex) {
                                        if (_endUserAppointmentList[index].appointmentListingSlotDtos!.isNotEmpty) {
                                          return singleDayEventView(
                                              subIndex, _endUserAppointmentList[index].appointmentListingSlotDtos!, _endUserAppointmentList[index]);
                                        } else {
                                          return SizedBox(
                                            height: 40.0,
                                            child: CustomTextView(label: 'No data available,'),
                                          );
                                        }
                                      },
                                    )
                                  : SizedBox(
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
                                              CustomTextView(
                                                label: 'No Appointments',
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge!
                                                    .copyWith(fontWeight: FontWeight.w500, fontSize: 20.0, color: OQDOThemeData.greyColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                            ],
                          );
                        },
                      ),
                    )
                  ],
                )
              : Container(),
        ),
      ),
    );
  }

  Widget singleDayEventView(int index, List<AppointmentListingSlotDtos> data, EndUserAppointmentsResponseModel endUserAppointmentResponseList) {
    if (data.isNotEmpty) {
      return SizedBox(
        height: 120.0,
        child: InkWell(
          onTap: () async {
            debugPrint('facility or coach -> ${data[index].isFacility}');
            if (data[index].isFacility!) {
              EndUserAppointmentPassingModel endUserAppointmentPassingModel = EndUserAppointmentPassingModel();
              endUserAppointmentPassingModel.type = 'F';
              endUserAppointmentPassingModel.selectedDate = endUserAppointmentResponseList.date;
              endUserAppointmentPassingModel.day = endUserAppointmentResponseList.day;
              endUserAppointmentPassingModel.bookingId = data[index].bookingId.toString();
              endUserAppointmentPassingModel.isCancel = data[index].isCancel;
              endUserAppointmentPassingModel.isDirectCancel = data[index].isDirectSlotCancel;
              await Navigator.pushNamed(context, Constants.endUserAppointmentFacilityDetails, arguments: endUserAppointmentPassingModel);
            } else {
              EndUserAppointmentPassingModel endUserAppointmentPassingModel = EndUserAppointmentPassingModel();
              endUserAppointmentPassingModel.type = 'C';
              endUserAppointmentPassingModel.selectedDate = endUserAppointmentResponseList.date;
              endUserAppointmentPassingModel.day = endUserAppointmentResponseList.day;
              endUserAppointmentPassingModel.bookingId = data[index].bookingId.toString();
              endUserAppointmentPassingModel.isCancel = data[index].isCancel;
              endUserAppointmentPassingModel.isDirectCancel = data[index].isDirectSlotCancel;
              await Navigator.pushNamed(context, Constants.endUserAppointmentCoachDetails, arguments: endUserAppointmentPassingModel);
            }
          },
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
                            label: endUserAppointmentResponseList.date!.split('-')[2].split('T')[0],
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
                        label: endUserAppointmentResponseList.day,
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
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextView(
                          label: data[index].setupName,
                          maxLine: 2,
                          textOverFlow: TextOverflow.ellipsis,
                          textStyle:
                              Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w500, fontSize: 15.0, color: OQDOThemeData.greyColor),
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        Row(
                          children: [
                            CustomTextView(
                              label: '${data[index].startTime} - ${data[index].endTime}',
                              textStyle:
                                  Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 14.0, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            CustomTextView(
                              label: 'S\$ ${data[index].ratePerHour?.toStringAsFixed(2) ?? 0}/hour',
                              textStyle:
                                  Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 14.0, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  data[index].isCancel!
                      ? Container(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: CustomTextView(
                            label: 'Cancelled',
                            textStyle:
                                Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 14.0, fontWeight: FontWeight.w700, color: OQDOThemeData.errorColor),
                          ),
                        )
                      : data[index].isPastSlot!
                          ? const SizedBox()
                          : data[index].isDirectSlotCancel! || data[index].isNotDirectSlotCancel!
                              ? GestureDetector(
                                  onTap: () async {
                                    if (data[index].isDirectSlotCancel!) {
                                      if (data[index].isFacility!) {
                                        getFacilityAppointmentDetails(data[index].bookingId, data[index].setupDaySlotMapId);
                                      } else {
                                        getAppointmentDetails(data[index].bookingId!, data[index].setupDaySlotMapId);
                                      }
                                    } else {
                                      if (data[index].isFacility!) {
                                        EndUserAppointmentPassingModel endUserAppointmentPassingModel = EndUserAppointmentPassingModel();
                                        endUserAppointmentPassingModel.type = 'F';
                                        endUserAppointmentPassingModel.selectedDate = endUserAppointmentResponseList.date;
                                        endUserAppointmentPassingModel.day = endUserAppointmentResponseList.day;
                                        endUserAppointmentPassingModel.bookingId = data[index].bookingId.toString();
                                        endUserAppointmentPassingModel.isCancel = data[index].isCancel;
                                        endUserAppointmentPassingModel.isDirectCancel = data[index].isDirectSlotCancel;
                                        await Navigator.pushNamed(context, Constants.endUserAppointmentFacilityDetails,
                                            arguments: endUserAppointmentPassingModel);
                                      } else {
                                        EndUserAppointmentPassingModel endUserAppointmentPassingModel = EndUserAppointmentPassingModel();
                                        endUserAppointmentPassingModel.type = 'C';
                                        endUserAppointmentPassingModel.selectedDate = endUserAppointmentResponseList.date;
                                        endUserAppointmentPassingModel.day = endUserAppointmentResponseList.day;
                                        endUserAppointmentPassingModel.bookingId = data[index].bookingId.toString();
                                        endUserAppointmentPassingModel.isCancel = data[index].isCancel;
                                        endUserAppointmentPassingModel.isDirectCancel = data[index].isDirectSlotCancel;
                                        await Navigator.pushNamed(context, Constants.endUserAppointmentCoachDetails, arguments: endUserAppointmentPassingModel);
                                      }
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 15.0),
                                    child: Image.asset(
                                      'assets/images/ic_cancel_appointment.png',
                                      height: 20,
                                      width: 20,
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox(
        height: 30.0,
      );
    }
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
            onTap: () {
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
              ).then((value) {
                if (value != null) {
                  debugPrint('Sheet selected date -> $value');
                  DateTime passingDate = value as DateTime;
                  setState(() {
                    _selectedDay = passingDate;
                    monthChangeStr();
                    var item =
                        _endUserAppointmentList.firstWhere((element) => convertToStringFromDate(element.date!) == convertDateTimeToString(_selectedDay!));
                    int selectedDateIndex = _endUserAppointmentList.indexOf(item);
                    scrollTo(selectedDateIndex);
                  });
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
            firstDay: kPreviousDay,
            lastDay: lastDate!,
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

  void scrollTo(int index) => itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOutCubic,
      );

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
      });
      debugPrint(convertDateTimeToString(_selectedDay!));
      var listData = _endUserAppointmentList.where((element) => convertToStringFromDate(element.date!) == '2023-04-18').toList();
      debugPrint('Data -> ${listData.length}');
      monthChangeStr();
      var item = _endUserAppointmentList.where((element) => convertToStringFromDate(element.date!) == convertDateTimeToString(_selectedDay!)).toList();
      int selectedDateIndex = _endUserAppointmentList.indexOf(item[0]);
      scrollTo(selectedDateIndex);
    }
  }

  void monthChangeStr() {
    setState(() {
      monthStr = DateFormat.yMMMM().format(_selectedDay!).split(' ')[0];
    });
  }

  Future<void> getEndUserAppointments(DateTime passingDate) async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    try {
      await _progressDialog.show();
      List<EndUserAppointmentsResponseModel> endUserAppointmentList = await Provider.of<AppointmentViewModel>(context, listen: false)
          .getEndUserAppointments(OQDOApplication.instance.endUserID!, convertDateTimeToString(kPreviousDay), convertDateTimeToString(kLastDay));
      if (!mounted) return;
      await _progressDialog.hide();
      if (endUserAppointmentList.isNotEmpty) {
        setState(() {
          // _endUserAppointmentList.clear();
          // _endUserAppointmentResponseList.clear();
          // var endUserSetList = <String>{};
          _endUserAppointmentList = endUserAppointmentList;
          // _endUserAppointmentResponseList =
          //     _endUserAppointmentList.where((element) => endUserSetList.add(element.date!)).toList();
          //
          monthStr = DateFormat.yMMMM().format(kToday).split(' ')[0];
          EndUserAppointmentsResponseModel firstDateOfAppointment = _endUserAppointmentList.first;
          EndUserAppointmentsResponseModel lastDateOfAppointment = _endUserAppointmentList.last;
          firstDate = DateTime.parse(firstDateOfAppointment.date!);
          debugPrint('First Date -> $firstDate');
          lastDate = DateTime.parse(lastDateOfAppointment.date!);
          debugPrint('Last Date -> $lastDate');
          for (int i = 0; i < _endUserAppointmentList.length; i++) {
            DateTime dateTime = DateFormat('yyyy-MM-dd').parse(_endUserAppointmentList[i].date!);
            String dateStr = DateFormat.yMMMMEEEEd().format(dateTime).split(' ')[0].split(',')[0];
            debugPrint('day -> $dateStr');
            debugPrint('day -> ${dateStr.substring(0, 3)}');
            _endUserAppointmentList[i].day = dateStr.substring(0, 3);
          }
        });
        // showCancelData();
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          var item = _endUserAppointmentList.firstWhere((element) => convertToStringFromDate(element.date!) == convertDateTimeToString(_selectedDay!));
          int selectedDateIndex = _endUserAppointmentList.indexOf(item);
          // scrollTo(selectedDateIndex);
          itemScrollController.jumpTo(
            index: selectedDateIndex,
          );
          monthChangeStr();
        });
        // cancelAllDateBeforeTodaysDate();
        checkForCancelAppointment();
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

  void showCancelData() {
    String selectedDayStr = DateFormat('yyyy-MM-dd').format(_selectedDay!);
    debugPrint('formated selected date -> $selectedDayStr');

    String currentDate = DateFormat('yyyy-MM-dd').format(kToday);
    debugPrint('Current Date -> $currentDate');

    if (selectedDayStr.compareTo(currentDate) < 0) {
      setState(() {
        for (int i = 0; i < _endUserAppointmentList.length; i++) {
          for (int j = 0; j < _endUserAppointmentList[i].appointmentListingSlotDtos!.length; j++) {
            _endUserAppointmentList[i].appointmentListingSlotDtos![j].isCancel = false;
          }
        }
      });
    } else if (selectedDayStr.compareTo(currentDate) == 0) {
      setState(() {
        String time = DateTime.now().toString();
        debugPrint('Time -> $time');
        String minutes = time.split(' ')[1].split('.')[0].split(':')[0];
        String seconds = time.split(' ')[1].split('.')[0].split(':')[1];
        int finalMinutes = int.parse(minutes) + 1;
        debugPrint('finalMinutes -> $finalMinutes');
        String finalTime = '$finalMinutes:$seconds';
        debugPrint('Time -> $finalTime');
        for (int i = 0; i < _endUserAppointmentList.length; i++) {
          for (int j = 0; j < _endUserAppointmentList[i].appointmentListingSlotDtos!.length; j++) {
            if (finalTime.compareTo(_endUserAppointmentList[i].appointmentListingSlotDtos![j].endTime!) > 0) {
              _endUserAppointmentList[i].appointmentListingSlotDtos![j].isCancel = false;
            }
          }
        }
      });
    }
  }

  Future<void> getEndUserOtherAppointments(String passingDate) async {
    // _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    // _progressDialog.style(message: "Please wait..");
    try {
      // await _progressDialog.show();
      List<EndUserAppointmentsResponseModel> endUserAppointmentList = await Provider.of<AppointmentViewModel>(context, listen: false)
          .getEndUserAppointments(OQDOApplication.instance.endUserID!, passingDate, convertDateTimeToString(kLastDay));
      if (!mounted) return;
      await _progressDialog.hide();
      if (endUserAppointmentList.isNotEmpty) {
        setState(() {
          // var endUserSetList = <String>{};
          _endUserAppointmentList.addAll(endUserAppointmentList);
          // _endUserAppointmentResponseList =
          //     _endUserAppointmentList.where((element) => endUserSetList.add(element.date!)).toList();
          // EndUserAppointmentsResponseModel lastDateOfAppointment = _endUserAppointmentResponseList.last;
          // lastDate = DateTime.parse(lastDateOfAppointment.date!);
          // debugPrint('Last Date -> $lastDate');
          // for (int i = 0; i < _endUserAppointmentResponseList.length; i++) {
          //   DateTime dateTime = DateFormat('yyyy-MM-dd').parse(_endUserAppointmentResponseList[i].date!);
          //   String dateStr = DateFormat.yMMMMEEEEd().format(dateTime).split(' ')[0].split(',')[0];
          //   debugPrint('day -> $dateStr');
          //   debugPrint('day -> ${dateStr.substring(0, 3)}');
          //   _endUserAppointmentResponseList[i].day = dateStr.substring(0, 3);
          // }
        });
      }
    } on CommonException catch (error) {
      // await _progressDialog.hide();
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
      // await _progressDialog.hide();
      if (!mounted) return;
      debugPrint(error.toString());
      // Fluttertoast.showToast(
      //     msg: "We\'re unable to connect to server. Please contact administrator or try after some time", toastLength: Toast.LENGTH_SHORT);
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
          _currentDay = format.format(_focusedDay!);
          initSelectedDate = DateFormat.yMMMMEEEEd().format(_focusedDay!).split(' ')[0].split(',')[0];
        });
        // showCancelData();
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
                firstDay: kPreviousDay,
                lastDay: kLastDay,
                focusedDay: _focusedDay!,
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
    var headerText = DateFormat.yMMMM().format(_focusedDay!);
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

  void checkForCancelAppointment() {
    String currentDateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    for (int i = 0; i < _endUserAppointmentList.length; i++) {
      EndUserAppointmentsResponseModel endUserAppointmentsResponseModel = _endUserAppointmentList[i];
      if (endUserAppointmentsResponseModel.date!.split('T')[0].compareTo(currentDateStr) < 0) {
        //past date
        for (var slots in endUserAppointmentsResponseModel.appointmentListingSlotDtos!) {
          setState(() {
            if (slots.isCancel!) {
              slots.isPastSlot = true;
              slots.isCancel = true;
              slots.isDirectSlotCancel = false;
              slots.isNotDirectSlotCancel = false;
            } else {
              slots.isPastSlot = true;
              slots.isCancel = false;
              slots.isDirectSlotCancel = false;
              slots.isNotDirectSlotCancel = false;
            }
          });
        }
      } else if (endUserAppointmentsResponseModel.date!.split('T')[0].compareTo(currentDateStr) > 0) {
        //future dates
        debugPrint('Greater Dates -> ${endUserAppointmentsResponseModel.date}');
        for (var slots in endUserAppointmentsResponseModel.appointmentListingSlotDtos!) {
          setState(() {
            if (slots.isCancel!) {
              slots.isPastSlot = false;
              slots.isCancel = true;
              slots.isDirectSlotCancel = false;
              slots.isNotDirectSlotCancel = false;
            } else {
              slots.isPastSlot = false;
              slots.isCancel = false;
              slots.isDirectSlotCancel = false;
              slots.isNotDirectSlotCancel = true;
            }

            // if (slots.isCancel!) {
            //   slots.isCancel = slots.isCancel;
            //   slots.isDirectSlotCancel = false;
            // } else {
            //   slots.isCancel = false;
            //   slots.isDirectSlotCancel = false;
            // }
          });
        }
      } else if (endUserAppointmentsResponseModel.date!.split('T')[0].compareTo(currentDateStr) == 0) {
        //current date
        String currentTime = DateTime.now().toString();
        String minutes = currentTime.split(' ')[1].split('.')[0].split(':')[0];
        String seconds = currentTime.split(' ')[1].split('.')[0].split(':')[1];
        // int finalMinutes = int.parse(minutes);
        // String finalCurrentTime = '$finalMinutes:$seconds';
        Duration cancelSlotRefundPolicyTime = Duration(minutes: OQDOApplication.instance.configResponseModel!.cancelApplicableMinAfterEndTime);
        Duration currentTimeSlotDuration = Duration(hours: int.parse(minutes), minutes: int.parse(seconds));
        for (var currentDateTimeSlots in endUserAppointmentsResponseModel.appointmentListingSlotDtos!) {
          if (currentDateTimeSlots.isCancel!) {
            setState(() {
              currentDateTimeSlots.isPastSlot = false;
              currentDateTimeSlots.isCancel = true;
              currentDateTimeSlots.isDirectSlotCancel = false;
              currentDateTimeSlots.isNotDirectSlotCancel = false;
            });
          } else {
            String checkingDateTimeMinutes = currentDateTimeSlots.endTime!.split(':')[0];
            String checkingDateTimeSeconds = currentDateTimeSlots.endTime!.split(':')[1];
            // int finalEndMinutes = int.parse(checkingDateTimeMinutes) + cancelSlotRefundPolicyTime.inHours;
            // showLog('End Final Time -> $finalEndMinutes');
            // String finalCheckingDateTime = '$finalEndMinutes:$checkingDateTimeSeconds';
            Duration endTimeDuration =
                Duration(hours: int.parse(checkingDateTimeMinutes) + cancelSlotRefundPolicyTime.inHours, minutes: int.parse(checkingDateTimeSeconds));
            if (endTimeDuration.compareTo(currentTimeSlotDuration) < 0) {
              setState(() {
                currentDateTimeSlots.isPastSlot = true;
                currentDateTimeSlots.isCancel = false;
                currentDateTimeSlots.isDirectSlotCancel = false;
                currentDateTimeSlots.isNotDirectSlotCancel = false;
              });
            } else {
              String checkingStartDateTimeMinutes = currentDateTimeSlots.startTime!.split(':')[0];
              String checkingStartDateTimeSeconds = currentDateTimeSlots.startTime!.split(':')[1];
              // int finalStartMinutes = int.parse(checkingStartDateTimeMinutes);
              Duration startTimeDuration = Duration(hours: int.parse(checkingStartDateTimeMinutes), minutes: int.parse(checkingStartDateTimeSeconds));
              if (currentTimeSlotDuration.compareTo(startTimeDuration) >= 0 && currentTimeSlotDuration.compareTo(endTimeDuration) <= 0) {
                setState(() {
                  currentDateTimeSlots.isPastSlot = false;
                  currentDateTimeSlots.isCancel = false;
                  currentDateTimeSlots.isDirectSlotCancel = true;
                  currentDateTimeSlots.isNotDirectSlotCancel = false;
                });
              } else {
                setState(() {
                  currentDateTimeSlots.isPastSlot = false;
                  currentDateTimeSlots.isCancel = false;
                  currentDateTimeSlots.isDirectSlotCancel = false;
                  currentDateTimeSlots.isNotDirectSlotCancel = true;
                });
              }
            }
          }
        }
      }
    }
  }

  void cancelAllDateBeforeTodaysDate() {
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    showLog(currentDate);
    var data = Duration(minutes: OQDOApplication.instance.configResponseModel!.cancelApplicableMinAfterEndTime);
    showLog('IN HOURS -> ${data.inHours}');
    for (var i = 0; i < _endUserAppointmentList.length; i++) {
      if (_endUserAppointmentList[i].date!.split('T')[0].compareTo(currentDate) < 0) {
        showLog(_endUserAppointmentList[i].date.toString());
        for (var j = 0; j < _endUserAppointmentList[i].appointmentListingSlotDtos!.length; j++) {
          setState(() {
            _endUserAppointmentList[i].appointmentListingSlotDtos![j].isCancel = true;
          });
        }
      } else if (_endUserAppointmentList[i].date!.split('T')[0].compareTo(currentDate) == 0) {
        showLog(_endUserAppointmentList[i].date.toString());
        String time = DateTime.now().toString();
        debugPrint('Time -> $time');
        String minutes = time.split(' ')[1].split('.')[0].split(':')[0];
        String seconds = time.split(' ')[1].split('.')[0].split(':')[1];
        int finalMinutes = int.parse(minutes);
        debugPrint('finalMinutes -> $finalMinutes');
        String finalTime = '$finalMinutes:$seconds';
        debugPrint('Time -> $finalTime');
        for (var j = 0; j < _endUserAppointmentList[i].appointmentListingSlotDtos!.length; j++) {
          if (!_endUserAppointmentList[i].appointmentListingSlotDtos![j].isCancel!) {
            String endminutes = _endUserAppointmentList[i].appointmentListingSlotDtos![j].endTime!.split(':')[0];
            String endSeconds = _endUserAppointmentList[i].appointmentListingSlotDtos![j].endTime!.split(':')[1];
            int finalEndMinutes = int.parse(endminutes) + data.inHours;
            showLog('End Final Time -> $finalEndMinutes');
            String finalEndTime = '$finalEndMinutes:$endSeconds';
            debugPrint('End Final Time -> $finalEndTime');
            if (finalTime.compareTo(finalEndTime) == 0) {
              showLog(
                  'time less than current Date & Time -> ${_endUserAppointmentList[i].date} - ${_endUserAppointmentList[i].appointmentListingSlotDtos![j].startTime} - ${_endUserAppointmentList[i].appointmentListingSlotDtos![j].startTime}');
              setState(() {
                _endUserAppointmentList[i].appointmentListingSlotDtos![j].isCancel = false;
                _endUserAppointmentList[i].appointmentListingSlotDtos![j].isDirectSlotCancel = true;
              });
            } else if (finalTime.compareTo(finalEndTime) < 0) {
              setState(() {
                _endUserAppointmentList[i].appointmentListingSlotDtos![j].isCancel = false;
              });
            } else {
              showLog(
                  'time less than current Date & Time else -> ${_endUserAppointmentList[i].date} - ${_endUserAppointmentList[i].appointmentListingSlotDtos![j].startTime} - ${_endUserAppointmentList[i].appointmentListingSlotDtos![j].startTime}');
              setState(() {
                _endUserAppointmentList[i].appointmentListingSlotDtos![j].isCancel = true;
              });
            }
          }
        }
      } else {
        for (var j = 0; j < _endUserAppointmentList[i].appointmentListingSlotDtos!.length; j++) {
          setState(() {
            _endUserAppointmentList[i].appointmentListingSlotDtos![j].isCancel = _endUserAppointmentList[i].appointmentListingSlotDtos![j].isCancel;
          });
        }
      }
    }
  }

  Widget _buildCancelData(
    BuildContext context,
    FacilityAppointmentDetailModel? facilityAppointmentDetailModel,
    int? setupDaySlotMapId,
  ) {
    return SafeArea(
      child: StatefulBuilder(builder: (BuildContext context, StateSetter bottomSheetState) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onBackground,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          ),
          child: SingleChildScrollView(
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
                      label: '${_facilityAppointmentDetailModel!.facilitySetupTitle} - ${_facilityAppointmentDetailModel!.facilitySetupSubTitle}',
                      textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w500),
                    ),
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
                        textStyle:
                            Theme.of(context).textTheme.titleSmall!.copyWith(color: OQDOThemeData.otherTextColor, fontWeight: FontWeight.w600, fontSize: 12.0),
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
                    textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: CustomTextView(
                    label: 'Name: ${_facilityAppointmentDetailModel!.facilityName}',
                    textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: CustomTextView(
                    label: 'Email ID: ${_facilityAppointmentDetailModel!.facilityEmail}',
                    textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: CustomTextView(
                    label: 'Phone number: ${_facilityAppointmentDetailModel!.facilityMobileNumber}',
                    textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: CustomTextView(
                    label: _facilityAppointmentDetailModel!.bookingType == 'I' ? 'Booking For: Individual' : 'Booking For: Group',
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
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: CustomTextView(
                    label: 'Cancel Reason',
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _cancelReasonResponseModelList.length,
                  itemBuilder: (context, index) {
                    var model = _cancelReasonResponseModelList[index];
                    return singleCancelReasonView(model, bottomSheetState);
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 18),
                        child: SimpleButton(
                          text: "Close",
                          textcolor: Theme.of(context).colorScheme.onBackground,
                          textsize: 14,
                          fontWeight: FontWeight.w600,
                          letterspacing: 0.7,
                          buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                          buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                          buttonheight: 60,
                          buttonwidth: MediaQuery.of(context).size.width,
                          radius: 15,
                          onTap: () async {
                            reasonValue = ' ';
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 18),
                        child: SimpleButton(
                          text: "Cancel Appointment",
                          textcolor: Theme.of(context).colorScheme.onBackground,
                          textsize: 14,
                          fontWeight: FontWeight.w600,
                          letterspacing: 0.7,
                          buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                          buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                          buttonheight: 60,
                          buttonwidth: MediaQuery.of(context).size.width,
                          radius: 15,
                          onTap: () async {
                            if (reasonValue == ' ') {
                              showSnackBar('Please select reason', context);
                            } else {
                              Navigator.pop(context);
                              facilityCancelRequest(facilityAppointmentDetailModel, setupDaySlotMapId);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget singleCancelReasonView(CancelReasonListResponseModel model, StateSetter bottomSheetState) {
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
        bottomSheetState(() {
          reasonValue = value!;
          // getReasonStr(reasonValue);
        });
      },
    );
  }

  void getReasonStr(String reasonData) {
    List<CancelReasonListResponseModel> list = _cancelReasonResponseModelList.where((element) => element.cancelReasonId == int.parse(reasonData)).toList();
    setState(() {
      selectedReasonStr = list[0].cancelreason!;
    });
  }

  Widget _coachDirectCancelBottomSheet(
    BuildContext context,
    model.CoachAppointmentDetailResponseModel? coachAppointmentDetailResponseModel,
    int? setupDaySlotMapId,
  ) {
    if (coachAppointmentDetailResponseModel!.addressType == 'E') {
      addressData =
          '${coachAppointmentDetailResponseModel.endUserTrainingAddress!.addressName}, ${coachAppointmentDetailResponseModel.endUserTrainingAddress!.address1}, ${coachAppointmentDetailResponseModel.endUserTrainingAddress!.address2}, ${coachAppointmentDetailResponseModel.endUserTrainingAddress!.cityName}, ${coachAppointmentDetailResponseModel.endUserTrainingAddress!.stateName}, ${coachAppointmentDetailResponseModel.endUserTrainingAddress!.countryName} - ${coachAppointmentDetailResponseModel.endUserTrainingAddress!.pincode}';
    } else {
      addressData =
          '${coachAppointmentDetailResponseModel.coachTrainingAddress![0].addressName}, ${coachAppointmentDetailResponseModel.coachTrainingAddress![0].address1}, ${coachAppointmentDetailResponseModel.coachTrainingAddress![0].address2}, ${coachAppointmentDetailResponseModel.coachTrainingAddress![0].city!.name}, ${coachAppointmentDetailResponseModel.coachTrainingAddress![0].city!.state!.name}, ${coachAppointmentDetailResponseModel.coachTrainingAddress![0].city!.state!.country!.name} - ${coachAppointmentDetailResponseModel.coachTrainingAddress![0].pinCode}';
    }
    // if (coachAppointmentDetailResponseModel!.coachTrainingAddress!.isEmpty) {
    //   addressData =
    //       '${coachAppointmentDetailResponseModel.endUserTrainingAddress!.addressName}, ${coachAppointmentDetailResponseModel.endUserTrainingAddress!.address1}, ${coachAppointmentDetailResponseModel.endUserTrainingAddress!.address2}, ${coachAppointmentDetailResponseModel.endUserTrainingAddress!.cityName}, ${coachAppointmentDetailResponseModel.endUserTrainingAddress!.stateName}, ${coachAppointmentDetailResponseModel.endUserTrainingAddress!.countryName} - ${coachAppointmentDetailResponseModel.endUserTrainingAddress!.pincode}';
    // } else {
    //   addressData =
    //       '${coachAppointmentDetailResponseModel.coachTrainingAddress![0].addressName}, ${coachAppointmentDetailResponseModel.coachTrainingAddress![0].address1}, ${coachAppointmentDetailResponseModel.coachTrainingAddress![0].address2}, ${coachAppointmentDetailResponseModel.coachTrainingAddress![0].city!.name}, ${coachAppointmentDetailResponseModel.coachTrainingAddress![0].city!.state!.name}, ${coachAppointmentDetailResponseModel.coachTrainingAddress![0].city!.state!.country!.name} - ${coachAppointmentDetailResponseModel.coachTrainingAddress![0].pinCode}';
    // }
    return SafeArea(
      child: StatefulBuilder(builder: (BuildContext context, StateSetter bottomSheetState) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onBackground,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          ),
          child: SingleChildScrollView(
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
                      label: '${coachAppointmentDetailResponseModel.coachFirstName} - ${coachAppointmentDetailResponseModel.coachLastName}',
                      textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w500),
                    ),
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
                        textStyle:
                            Theme.of(context).textTheme.titleSmall!.copyWith(color: OQDOThemeData.otherTextColor, fontWeight: FontWeight.w600, fontSize: 12.0),
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
                    label: 'Order ID: ${coachAppointmentDetailResponseModel.bookingNo}',
                    textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: CustomTextView(
                    label: 'Name: ${coachAppointmentDetailResponseModel.coachFirstName} ${coachAppointmentDetailResponseModel.coachLastName}',
                    textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: CustomTextView(
                    label: 'Email ID: ${coachAppointmentDetailResponseModel.coachEmail}',
                    textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: CustomTextView(
                    label: 'Phone number: ${coachAppointmentDetailResponseModel.coachMobileNumber}',
                    textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: CustomTextView(
                    label: coachAppointmentDetailResponseModel.bookingType == 'I' ? 'Booking For: Individual' : 'Booking For: Group',
                    textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: CustomTextView(
                    label: 'Address: $addressData',
                    maxLine: 2,
                    textOverFlow: TextOverflow.ellipsis,
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
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: CustomTextView(
                    label: 'Cancel Reason',
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _cancelReasonResponseModelList.length,
                  itemBuilder: (context, index) {
                    var model = _cancelReasonResponseModelList[index];
                    return singleCancelReasonView(model, bottomSheetState);
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 18),
                        child: SimpleButton(
                          text: "Close",
                          textcolor: Theme.of(context).colorScheme.onBackground,
                          textsize: 14,
                          fontWeight: FontWeight.w600,
                          letterspacing: 0.7,
                          buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                          buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                          buttonheight: 60,
                          buttonwidth: MediaQuery.of(context).size.width,
                          radius: 15,
                          onTap: () async {
                            reasonValue = ' ';
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 18),
                        child: SimpleButton(
                          text: "Cancel Appointment",
                          textcolor: Theme.of(context).colorScheme.onBackground,
                          textsize: 14,
                          fontWeight: FontWeight.w600,
                          letterspacing: 0.7,
                          buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                          buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                          buttonheight: 60,
                          buttonwidth: MediaQuery.of(context).size.width,
                          radius: 15,
                          onTap: () async {
                            if (reasonValue == ' ') {
                              showSnackBar('Please select reason', context);
                            } else {
                              Navigator.pop(context);
                              coachCancelRequest(coachAppointmentDetailResponseModel, setupDaySlotMapId);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> getAppointmentDetails(int bookingId, int? setupDaySlotMapId) async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    try {
      await _progressDialog.show();
      model.CoachAppointmentDetailResponseModel facilityAppointmentDetailModel =
          await Provider.of<AppointmentViewModel>(context, listen: false).getCoachAppointmentDetail(bookingId.toString());
      if (!mounted) return;
      await _progressDialog.hide();
      if (facilityAppointmentDetailModel.bookingNo != null) {
        setState(() {
          var data = Duration(minutes: OQDOApplication.instance.configResponseModel!.cancelApplicableMinAfterEndTime);
          showLog('IN HOURS -> ${data.inHours}');
          coachAppointmentDetailResponseModel = facilityAppointmentDetailModel;
          showModalBottomSheet(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              context: context,
              isDismissible: false,
              enableDrag: false,
              isScrollControlled: true,
              builder: (BuildContext ctx) {
                return _coachDirectCancelBottomSheet(ctx, coachAppointmentDetailResponseModel, setupDaySlotMapId);
              });
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
      if (!mounted) return;
      debugPrint(error.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  Future<void> getCancelReasons() async {
    try {
      List<CancelReasonListResponseModel> list = await Provider.of<AppointmentViewModel>(context, listen: false).getCancelReasonList();
      if (list.isNotEmpty) {
        setState(() {
          _cancelReasonResponseModelList.clear();
          _cancelReasonResponseModelList.addAll(list);
          debugPrint('Length -> ${_cancelReasonResponseModelList.length}');
          _cancelReasonResponseModelList.removeWhere((element) => element.reasonFor != Constants.endUserType);
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

  Future<void> getFacilityAppointmentDetails(int? bookingId, int? setupDaySlotMapId) async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    try {
      await _progressDialog.show();
      FacilityAppointmentDetailModel facilityAppointmentDetailModel =
          await Provider.of<AppointmentViewModel>(context, listen: false).getFacilityAppointmentDetail(bookingId!.toString());
      if (!mounted) return;
      await _progressDialog.hide();
      if (facilityAppointmentDetailModel.facilityBookingId != null) {
        setState(() {
          _facilityAppointmentDetailModel = facilityAppointmentDetailModel;
          showModalBottomSheet(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              context: context,
              isDismissible: false,
              enableDrag: false,
              isScrollControlled: true,
              builder: (BuildContext ctx) {
                return _buildCancelData(ctx, _facilityAppointmentDetailModel, setupDaySlotMapId);
              });
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
      if (!mounted) return;
      debugPrint(error.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  Future<void> facilityCancelRequest(FacilityAppointmentDetailModel? facilityAppointmentDetailModel, int? setupDaySlotMapId) async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    try {
      await _progressDialog.show();
      Map<String, dynamic> request = {};
      request['SubActivityId'] = facilityAppointmentDetailModel!.subActivityId;
      request['UserId'] = OQDOApplication.instance.endUserID;
      request['CancelReasonId'] = reasonValue;
      request['OtherReason'] = '';
      request['FacilityBookingId'] = facilityAppointmentDetailModel.facilityBookingId;
      List<Map<String, dynamic>> data = [];
      for (var i = 0; i < facilityAppointmentDetailModel.facilityBookingSlotDates!.length; i++) {
        Map<String, dynamic> selectedFacilityReq = {};
        if (setupDaySlotMapId == facilityAppointmentDetailModel.facilityBookingSlotDates![i].facilitySetupDaySlotMapId) {
          selectedFacilityReq['SlotMapId'] = facilityAppointmentDetailModel.facilityBookingSlotDates![i].facilitySetupDaySlotMapId;
          selectedFacilityReq['BookingDate'] = facilityAppointmentDetailModel.facilityBookingSlotDates![i].bookingDate!.split('T')[0];
          data.add(selectedFacilityReq);
        }
      }
      request['FacilityCancelAppointmentSlotDtos'] = data;
      debugPrint('Request -> ${json.encode(request)}');
      var list = await Provider.of<AppointmentViewModel>(context, listen: false).facilityCancelAppointmentRequest(request);
      if (!mounted) return;
      await _progressDialog.hide();
      if (list.isNotEmpty) {
        Navigator.of(context).pop();
        showSnackBarColor('Your Cancellation Request has been sent to the Service Provider for approval. Once approved, you will be refunded.', context, false);
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
      if (!mounted) return;
      debugPrint(error.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  Future<void> coachCancelRequest(model.CoachAppointmentDetailResponseModel coachAppointmentDetailResponseModel, int? setupDaySlotMapId) async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    try {
      await _progressDialog.show();
      Map<String, dynamic> request = {};
      request['UserId'] = OQDOApplication.instance.endUserID;
      request['CancelReasonId'] = reasonValue;
      request['OtherReason'] = '';
      request['CoachBookingId'] = coachAppointmentDetailResponseModel.coachBookingId;
      List<Map<String, dynamic>> data = [];
      for (var i = 0; i < coachAppointmentDetailResponseModel.coachBookingSlotDates!.length; i++) {
        Map<String, dynamic> selectedFacilityReq = {};
        if (setupDaySlotMapId == coachAppointmentDetailResponseModel.coachBookingSlotDates![i].coachBatchSetupDaySlotMapId) {
          selectedFacilityReq['SlotMapId'] = coachAppointmentDetailResponseModel.coachBookingSlotDates![i].coachBatchSetupDaySlotMapId;
          selectedFacilityReq['BookingDate'] = coachAppointmentDetailResponseModel.coachBookingSlotDates![i].bookingDate!.split('T')[0];
          data.add(selectedFacilityReq);
        }
      }
      request['CoachCancelAppointmentSlotDtos'] = data;
      debugPrint('Request -> ${json.encode(request)}');
      var list = await Provider.of<AppointmentViewModel>(context, listen: false).coachCancelAppointmentRequest(request);
      await _progressDialog.hide();
      if (list.isNotEmpty) {
        Navigator.of(context).pop();
        showSnackBarColor('Your Cancellation Request has been sent to the Service Provider for approval. Once approved, you will be refunded.', context, false);
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
}

// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:intl/intl.dart';
// import 'package:oqdo_mobile_app/components/my_button.dart';
// import 'package:oqdo_mobile_app/helper/helpers.dart';
// import 'package:oqdo_mobile_app/model/coach_appointment_details_response_model.dart' as model;
// import 'package:oqdo_mobile_app/model/end_user_appoinments_model.dart';
// import 'package:oqdo_mobile_app/model/end_user_appointment_model_details.dart';
// import 'package:oqdo_mobile_app/model/facility_appointment_details_model.dart';
// import 'package:oqdo_mobile_app/oqdo_application.dart';
// import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
// import 'package:oqdo_mobile_app/utils/constants.dart';
// import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
// import 'package:oqdo_mobile_app/utils/utilities.dart';
// import 'package:oqdo_mobile_app/viewmodels/appointment_view_model.dart';
// import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
// import 'package:provider/provider.dart';
// import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
// import 'package:table_calendar/table_calendar.dart';

// class EndUserAppointmentsScreen extends StatefulWidget {
//   DateTime? selectedDate;

//   EndUserAppointmentsScreen({Key? key, this.selectedDate}) : super(key: key);

//   @override
//   State<EndUserAppointmentsScreen> createState() => _EndUserAppointmentsScreenState();
// }

// class _EndUserAppointmentsScreenState extends State<EndUserAppointmentsScreen> {
//   late ProgressDialog _progressDialog;
//   List<EndUserAppointmentsResponseModel> _endUserAppointmentList = [];

//   // List<EndUserAppointmentsResponseModel> _endUserAppointmentResponseList = [];
//   String monthStr = '';
//   DateTime? firstDate;
//   DateTime? lastDate;
//   DateTime? _selectedDay;
//   final CalendarFormat _calendarFormat = CalendarFormat.week;
//   final ItemScrollController itemScrollController = ItemScrollController();
//   final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
//   int? firstItemIndex;
//   int? lastItemIndex;

//   late DateTime lastDateForBooking;
//   DateTime currentDateTime = DateTime.now();
//   late PageController _pageController;
//   final CalendarFormat _calendarViewFormat = CalendarFormat.month;
//   DateTime? _focusedDay;
//   late String _currentDay;
//   DateFormat format = DateFormat('d-MMMM-yyyy');
//   DateTime? _selectedDayView;
//   String initSelectedDate = '';

//   model.CoachAppointmentDetailResponseModel? coachAppointmentDetailResponseModel;
//   var reasonValue = '';
//   FacilityAppointmentDetailModel? _facilityAppointmentDetailModel;
//   String addressData = '';

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       _selectedDay = widget.selectedDate!;
//       _focusedDay = DateTime.now();
//       reasonValue = OQDOApplication.instance.configResponseModel!.didntShowReasonId!;
//       debugPrint(reasonValue);
//       _currentDay = format.format(_focusedDay!);
//       initSelectedDate = DateFormat.yMMMMEEEEd().format(_focusedDay!).split(' ')[0].split(',')[0];
//       getEndUserAppointments(widget.selectedDate!);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0.0,
//         backgroundColor: Theme.of(context).colorScheme.onBackground,
//         leading: IconButton(
//           onPressed: () async {
//             Navigator.pop(context);
//           },
//           icon: ImageIcon(
//             const AssetImage("assets/images/ic_back.png"),
//             color: Theme.of(context).colorScheme.onSurface,
//           ),
//         ),
//         title: CustomTextView(
//           label: 'Appointments Management',
//           textStyle: Theme.of(context)
//               .textTheme
//               .titleMedium!
//               .copyWith(fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor, fontSize: 16.0),
//         ),
//       ),
//       body: SafeArea(
//         child: Container(
//           color: OQDOThemeData.whiteColor,
//           width: MediaQuery.of(context).size.width,
//           height: double.infinity,
//           child: _endUserAppointmentList.isNotEmpty
//               ? Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     headerView(),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(top: 30, left: 10.0, right: 10, bottom: 20),
//                       child: calendarView(),
//                     ),
//                     Expanded(
//                       child: ScrollablePositionedList.builder(
//                         itemCount: _endUserAppointmentList.length,
//                         shrinkWrap: true,
//                         itemScrollController: itemScrollController,
//                         itemPositionsListener: itemPositionsListener,
//                         scrollDirection: Axis.vertical,
//                         itemBuilder: (context, index) {
//                           return Column(
//                             key: ValueKey<String>(_endUserAppointmentList[index].date!),
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.only(left: 20.0, top: 5),
//                                 child: Container(
//                                   padding: const EdgeInsets.all(8),
//                                   decoration: BoxDecoration(
//                                       color: const Color(0xFF006590),
//                                       border: Border.all(color: OQDOThemeData.dividerColor),
//                                       borderRadius: const BorderRadius.all(Radius.circular(10))),
//                                   child: CustomTextView(
//                                     label: _endUserAppointmentList[index].date!.split('T')[0],
//                                     textStyle: Theme.of(context)
//                                         .textTheme
//                                         .bodyMedium!
//                                         .copyWith(color: OQDOThemeData.whiteColor, fontSize: 18, fontWeight: FontWeight.w500),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 8.0),
//                               _endUserAppointmentList[index].appointmentListingSlotDtos!.isNotEmpty
//                                   ? ListView.builder(
//                                       shrinkWrap: true,
//                                       physics: const NeverScrollableScrollPhysics(),
//                                       itemCount: _endUserAppointmentList[index].appointmentListingSlotDtos!.length,
//                                       itemBuilder: (BuildContext context, int subIndex) {
//                                         if (_endUserAppointmentList[index].appointmentListingSlotDtos!.isNotEmpty) {
//                                           return singleDayEventView(subIndex, _endUserAppointmentList[index].appointmentListingSlotDtos!,
//                                               _endUserAppointmentList[index]);
//                                         } else {
//                                           return SizedBox(
//                                             height: 40.0,
//                                             child: CustomTextView(label: 'No data available,'),
//                                           );
//                                         }
//                                       },
//                                     )
//                                   : SizedBox(
//                                       height: 120.0,
//                                       child: Container(
//                                         padding: const EdgeInsets.all(2.0),
//                                         child: Card(
//                                           semanticContainer: true,
//                                           clipBehavior: Clip.antiAliasWithSaveLayer,
//                                           elevation: 4.0,
//                                           shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
//                                           child: Row(
//                                             children: [
//                                               Container(
//                                                 decoration: BoxDecoration(
//                                                   shape: BoxShape.rectangle,
//                                                   border: Border.all(width: 7.0, color: const Color.fromRGBO(0, 101, 144, 0.5)),
//                                                 ),
//                                               ),
//                                               const SizedBox(width: 20.0),
//                                               CustomTextView(
//                                                 label: 'No Appointments',
//                                                 textStyle: Theme.of(context)
//                                                     .textTheme
//                                                     .titleLarge!
//                                                     .copyWith(fontWeight: FontWeight.w500, fontSize: 20.0, color: OQDOThemeData.greyColor),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     )
//                             ],
//                           );
//                         },
//                       ),
//                     )
//                   ],
//                 )
//               : Container(),
//         ),
//       ),
//     );
//   }

//   Widget singleDayEventView(
//       int index, List<AppointmentListingSlotDtos> data, EndUserAppointmentsResponseModel endUserAppointmentResponseList) {
//     if (data.isNotEmpty) {
//       return SizedBox(
//         height: 120.0,
//         child: InkWell(
//           onTap: () async {
//             debugPrint('facility or coach -> ${data[index].isFacility}');
//             if (data[index].isFacility!) {
//               EndUserAppointmentPassingModel endUserAppointmentPassingModel = EndUserAppointmentPassingModel();
//               endUserAppointmentPassingModel.type = 'F';
//               endUserAppointmentPassingModel.selectedDate = endUserAppointmentResponseList.date;
//               endUserAppointmentPassingModel.day = endUserAppointmentResponseList.day;
//               endUserAppointmentPassingModel.bookingId = data[index].bookingId.toString();
//               endUserAppointmentPassingModel.isCancel = data[index].isCancel;
//               endUserAppointmentPassingModel.isDirectCancel = data[index].isDirectSlotCancel;
//               await Navigator.pushNamed(context, Constants.endUserAppointmentFacilityDetails, arguments: endUserAppointmentPassingModel);
//             } else {
//               EndUserAppointmentPassingModel endUserAppointmentPassingModel = EndUserAppointmentPassingModel();
//               endUserAppointmentPassingModel.type = 'C';
//               endUserAppointmentPassingModel.selectedDate = endUserAppointmentResponseList.date;
//               endUserAppointmentPassingModel.day = endUserAppointmentResponseList.day;
//               endUserAppointmentPassingModel.bookingId = data[index].bookingId.toString();
//               endUserAppointmentPassingModel.isCancel = data[index].isCancel;
//               endUserAppointmentPassingModel.isDirectCancel = data[index].isDirectSlotCancel;
//               await Navigator.pushNamed(context, Constants.endUserAppointmentCoachDetails, arguments: endUserAppointmentPassingModel);
//             }
//           },
//           child: Container(
//             padding: const EdgeInsets.all(2.0),
//             child: Card(
//               semanticContainer: true,
//               clipBehavior: Clip.antiAliasWithSaveLayer,
//               elevation: 4.0,
//               shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
//               child: Row(
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       shape: BoxShape.rectangle,
//                       border: Border.all(width: 7.0, color: const Color.fromRGBO(0, 101, 144, 0.5)),
//                     ),
//                   ),
//                   const SizedBox(width: 20.0),
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Card(
//                         elevation: 4.0,
//                         shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(100))),
//                         child: Padding(
//                           padding: const EdgeInsets.all(10.0),
//                           child: CustomTextView(
//                             label: endUserAppointmentResponseList.date!.split('-')[2].split('T')[0],
//                             textStyle: Theme.of(context)
//                                 .textTheme
//                                 .titleLarge!
//                                 .copyWith(fontWeight: FontWeight.w700, fontSize: 18.0, color: Theme.of(context).colorScheme.primary),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 8.0,
//                       ),
//                       CustomTextView(
//                         label: endUserAppointmentResponseList.day,
//                         textStyle: Theme.of(context)
//                             .textTheme
//                             .titleMedium!
//                             .copyWith(fontWeight: FontWeight.w500, fontSize: 16.0, color: Theme.of(context).colorScheme.primary),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(
//                     width: 30.0,
//                   ),
//                   Expanded(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         CustomTextView(
//                           label: data[index].setupName,
//                           maxLine: 2,
//                           textOverFlow: TextOverflow.ellipsis,
//                           textStyle: Theme.of(context)
//                               .textTheme
//                               .titleSmall!
//                               .copyWith(fontWeight: FontWeight.w500, fontSize: 15.0, color: OQDOThemeData.greyColor),
//                         ),
//                         const SizedBox(
//                           height: 8.0,
//                         ),
//                         CustomTextView(
//                           label: '${data[index].startTime} - ${data[index].endTime}',
//                           textStyle: Theme.of(context)
//                               .textTheme
//                               .titleSmall!
//                               .copyWith(fontSize: 14.0, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
//                         )
//                       ],
//                     ),
//                   ),
//                   data[index].isPastSlot!
//                       ? data[index].isCancel!
//                           ? Container(
//                               padding: const EdgeInsets.only(right: 15.0),
//                               child: CustomTextView(
//                                 label: 'Cancelled',
//                                 textStyle: Theme.of(context)
//                                     .textTheme
//                                     .titleSmall!
//                                     .copyWith(fontSize: 14.0, fontWeight: FontWeight.w700, color: OQDOThemeData.errorColor),
//                               ),
//                             )
//                           : data[index].isPastSlot!
//                               ? const SizedBox()
//                               : data[index].isCancel!
//                                   ?
//                                   Container(
//                               padding: const EdgeInsets.only(right: 15.0),
//                               child: CustomTextView(
//                                 label: 'Cancelled',
//                                 textStyle: Theme.of(context)
//                                     .textTheme
//                                     .titleSmall!
//                                     .copyWith(fontSize: 14.0, fontWeight: FontWeight.w700, color: OQDOThemeData.errorColor),
//                               ),
//                             ):
//                                   GestureDetector(
//                                       onTap: () async {
//                                         if (data[index].isDirectSlotCancel!) {
//                                           if (data[index].isFacility!) {
//                                             getFacilityAppointmentDetails(data[index].bookingId, data[index].setupDaySlotMapId);
//                                           } else {
//                                             getAppointmentDetails(data[index].bookingId!, data[index].setupDaySlotMapId);
//                                           }
//                                         } else {
//                                           if (data[index].isFacility!) {
//                                             EndUserAppointmentPassingModel endUserAppointmentPassingModel =
//                                                 EndUserAppointmentPassingModel();
//                                             endUserAppointmentPassingModel.type = 'F';
//                                             endUserAppointmentPassingModel.selectedDate = endUserAppointmentResponseList.date;
//                                             endUserAppointmentPassingModel.day = endUserAppointmentResponseList.day;
//                                             endUserAppointmentPassingModel.bookingId = data[index].bookingId.toString();
//                                             endUserAppointmentPassingModel.isCancel = data[index].isCancel;
//                                             endUserAppointmentPassingModel.isDirectCancel = data[index].isDirectSlotCancel;
//                                             await Navigator.pushNamed(context, Constants.endUserAppointmentFacilityDetails,
//                                                 arguments: endUserAppointmentPassingModel);
//                                           } else {
//                                             EndUserAppointmentPassingModel endUserAppointmentPassingModel =
//                                                 EndUserAppointmentPassingModel();
//                                             endUserAppointmentPassingModel.type = 'C';
//                                             endUserAppointmentPassingModel.selectedDate = endUserAppointmentResponseList.date;
//                                             endUserAppointmentPassingModel.day = endUserAppointmentResponseList.day;
//                                             endUserAppointmentPassingModel.bookingId = data[index].bookingId.toString();
//                                             endUserAppointmentPassingModel.isCancel = data[index].isCancel;
//                                             endUserAppointmentPassingModel.isDirectCancel = data[index].isDirectSlotCancel;
//                                             await Navigator.pushNamed(context, Constants.endUserAppointmentCoachDetails,
//                                                 arguments: endUserAppointmentPassingModel);
//                                           }
//                                         }
//                                       },
//                                       child: Padding(
//                                         padding: const EdgeInsets.only(right: 15.0),
//                                         child: Image.asset(
//                                           'assets/images/ic_cancel_appointment.png',
//                                           height: 20,
//                                           width: 20,
//                                         ),
//                                       ),
//                                     )

//                       : const SizedBox(),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     } else {
//       return const SizedBox(
//         height: 30.0,
//       );
//     }
//   }

//   Widget headerView() {
//     return Padding(
//       padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
//       child: Row(
//         children: [
//           CustomTextView(
//             label: monthStr,
//             textStyle:
//                 Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20, fontWeight: FontWeight.w500, color: const Color(0xFF333333)),
//           ),
//           const Spacer(),
//           GestureDetector(
//             onTap: () {
//               showModalBottomSheet(
//                 context: context,
//                 builder: (context) {
//                   return StatefulBuilder(
//                     builder: (context, setState) {
//                       return showCalendarSheet(setState);
//                     },
//                   );
//                 },
//                 enableDrag: true,
//                 isDismissible: true,
//                 isScrollControlled: true,
//               ).then((value) {
//                 if (value != null) {
//                   debugPrint('Sheet selected date -> $value');
//                   DateTime passingDate = value as DateTime;
//                   setState(() {
//                     _selectedDay = passingDate;
//                     monthChangeStr();
//                     final item = _endUserAppointmentList
//                         .firstWhere((element) => convertToStringFromDate(element.date!) == convertDateTimeToString(_selectedDay!));
//                     final int selectedDateIndex = _endUserAppointmentList.indexOf(item);
//                     scrollTo(selectedDateIndex);
//                   });
//                 }
//               });
//             },
//             child: Image.asset(
//               'assets/images/calendar_cicular.png',
//               height: 25,
//               width: 25,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget calendarView() {
//     return firstDate != null
//         ? TableCalendar(
//             focusedDay: _selectedDay!,
//             firstDay: kPreviousDay,
//             lastDay: lastDate!,
//             calendarFormat: _calendarFormat,
//             headerVisible: false,
//             daysOfWeekVisible: true,
//             daysOfWeekStyle: const DaysOfWeekStyle(
//                 weekdayStyle: TextStyle(color: Color(0xFF006590), fontWeight: FontWeight.w500),
//                 weekendStyle: TextStyle(color: Color(0xFF006590), fontWeight: FontWeight.w500)),
//             calendarStyle: CalendarStyle(
//               isTodayHighlighted: false,
//               outsideDaysVisible: false,
//               selectedDecoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
//               defaultTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black),
//             ),
//             onDaySelected: _onDaySelected,
//             selectedDayPredicate: (DateTime date) {
//               return isSameDay(_selectedDay, date);
//             },
//           )
//         : Container();
//   }

//   void scrollTo(int index) => itemScrollController.scrollTo(
//         index: index,
//         duration: const Duration(milliseconds: 900),
//         curve: Curves.easeInOutCubic,
//       );

//   void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
//     if (!isSameDay(_selectedDay, selectedDay)) {
//       setState(() {
//         _selectedDay = selectedDay;
//       });
//       debugPrint(convertDateTimeToString(_selectedDay!));
//       final listData = _endUserAppointmentList.where((element) => convertToStringFromDate(element.date!) == '2023-04-18').toList();
//       debugPrint('Data -> ${listData.length}');
//       monthChangeStr();
//       final item = _endUserAppointmentList
//           .where((element) => convertToStringFromDate(element.date!) == convertDateTimeToString(_selectedDay!))
//           .toList();
//       final int selectedDateIndex = _endUserAppointmentList.indexOf(item[0]);
//       scrollTo(selectedDateIndex);
//     }
//   }

//   void monthChangeStr() {
//     setState(() {
//       monthStr = DateFormat.yMMMM().format(_selectedDay!).split(' ')[0];
//     });
//   }

//   Future<void> getEndUserAppointments(DateTime passingDate) async {
//     _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
//     _progressDialog.style(message: "Please wait..");
//     try {
//       await _progressDialog.show();
//       List<EndUserAppointmentsResponseModel> endUserAppointmentList = await Provider.of<AppointmentViewModel>(context, listen: false)
//           .getEndUserAppointments(
//               OQDOApplication.instance.endUserID!, convertDateTimeToString(kPreviousDay), convertDateTimeToString(kLastDay));
//       if (!mounted) return;
//       await _progressDialog.hide();
//       if (endUserAppointmentList.isNotEmpty) {
//         setState(() {
//           // _endUserAppointmentList.clear();
//           // _endUserAppointmentResponseList.clear();
//           // var endUserSetList = <String>{};
//           _endUserAppointmentList = endUserAppointmentList;
//           // _endUserAppointmentResponseList =
//           //     _endUserAppointmentList.where((element) => endUserSetList.add(element.date!)).toList();
//           //
//           monthStr = DateFormat.yMMMM().format(kToday).split(' ')[0];
//           EndUserAppointmentsResponseModel firstDateOfAppointment = _endUserAppointmentList.first;
//           EndUserAppointmentsResponseModel lastDateOfAppointment = _endUserAppointmentList.last;
//           firstDate = DateTime.parse(firstDateOfAppointment.date!);
//           debugPrint('First Date -> $firstDate');
//           lastDate = DateTime.parse(lastDateOfAppointment.date!);
//           debugPrint('Last Date -> $lastDate');
//           for (int i = 0; i < _endUserAppointmentList.length; i++) {
//             DateTime dateTime = DateFormat('yyyy-MM-dd').parse(_endUserAppointmentList[i].date!);
//             String dateStr = DateFormat.yMMMMEEEEd().format(dateTime).split(' ')[0].split(',')[0];
//             debugPrint('day -> $dateStr');
//             debugPrint('day -> ${dateStr.substring(0, 3)}');
//             _endUserAppointmentList[i].day = dateStr.substring(0, 3);
//           }
//         });
//         // showCancelData();
//         WidgetsBinding.instance.addPostFrameCallback((_) async {
//           final item = _endUserAppointmentList
//               .firstWhere((element) => convertToStringFromDate(element.date!) == convertDateTimeToString(_selectedDay!));
//           final int selectedDateIndex = _endUserAppointmentList.indexOf(item);
//           // scrollTo(selectedDateIndex);
//           itemScrollController.jumpTo(
//             index: selectedDateIndex,
//           );
//           monthChangeStr();
//         });
//         // cancelAllDateBeforeTodaysDate();
//         checkForCancelAppointment();
//       }
//     } on CommonException catch (error) {
//       await _progressDialog.hide();
//       debugPrint(error.toString());
//       if (error.code == 400) {
//         Map<String, dynamic> errorModel = jsonDecode(error.message);
//         if (errorModel.containsKey('ModelState')) {
//           Map<String, dynamic> modelState = errorModel['ModelState'];
//           if (modelState.containsKey('ErrorMessage')) {
//             showSnackBarColor(modelState['ErrorMessage'][0], context, true);
//           } else {
//             showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
//           }
//         } else {
//           showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
//         }
//       } else {
//         showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
//       }
//     } catch (error) {
//       await _progressDialog.hide();
//       if (!mounted) return;
//       debugPrint(error.toString());
//       showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context,true);
//     }
//   }

//   void showCancelData() {
//     String selectedDayStr = DateFormat('yyyy-MM-dd').format(_selectedDay!);
//     debugPrint('formated selected date -> $selectedDayStr');

//     String currentDate = DateFormat('yyyy-MM-dd').format(kToday);
//     debugPrint('Current Date -> $currentDate');

//     if (selectedDayStr.compareTo(currentDate) < 0) {
//       setState(() {
//         for (int i = 0; i < _endUserAppointmentList.length; i++) {
//           for (int j = 0; j < _endUserAppointmentList[i].appointmentListingSlotDtos!.length; j++) {
//             _endUserAppointmentList[i].appointmentListingSlotDtos![j].isCancel = false;
//           }
//         }
//       });
//     } else if (selectedDayStr.compareTo(currentDate) == 0) {
//       setState(() {
//         String time = DateTime.now().toString();
//         debugPrint('Time -> $time');
//         String minutes = time.split(' ')[1].split('.')[0].split(':')[0];
//         String seconds = time.split(' ')[1].split('.')[0].split(':')[1];
//         int finalMinutes = int.parse(minutes) + 1;
//         debugPrint('finalMinutes -> $finalMinutes');
//         String finalTime = '$finalMinutes:$seconds';
//         debugPrint('Time -> $finalTime');
//         for (int i = 0; i < _endUserAppointmentList.length; i++) {
//           for (int j = 0; j < _endUserAppointmentList[i].appointmentListingSlotDtos!.length; j++) {
//             if (finalTime.compareTo(_endUserAppointmentList[i].appointmentListingSlotDtos![j].endTime!) > 0) {
//               _endUserAppointmentList[i].appointmentListingSlotDtos![j].isCancel = false;
//             }
//           }
//         }
//       });
//     }
//   }

//   Future<void> getEndUserOtherAppointments(String passingDate) async {
//     // _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
//     // _progressDialog.style(message: "Please wait..");
//     try {
//       // await _progressDialog.show();
//       List<EndUserAppointmentsResponseModel> endUserAppointmentList = await Provider.of<AppointmentViewModel>(context, listen: false)
//           .getEndUserAppointments(OQDOApplication.instance.endUserID!, passingDate, convertDateTimeToString(kLastDay));
//       if (!mounted) return;
//       await _progressDialog.hide();
//       if (endUserAppointmentList.isNotEmpty) {
//         setState(() {
//           // var endUserSetList = <String>{};
//           _endUserAppointmentList.addAll(endUserAppointmentList);
//           // _endUserAppointmentResponseList =
//           //     _endUserAppointmentList.where((element) => endUserSetList.add(element.date!)).toList();
//           // EndUserAppointmentsResponseModel lastDateOfAppointment = _endUserAppointmentResponseList.last;
//           // lastDate = DateTime.parse(lastDateOfAppointment.date!);
//           // debugPrint('Last Date -> $lastDate');
//           // for (int i = 0; i < _endUserAppointmentResponseList.length; i++) {
//           //   DateTime dateTime = DateFormat('yyyy-MM-dd').parse(_endUserAppointmentResponseList[i].date!);
//           //   String dateStr = DateFormat.yMMMMEEEEd().format(dateTime).split(' ')[0].split(',')[0];
//           //   debugPrint('day -> $dateStr');
//           //   debugPrint('day -> ${dateStr.substring(0, 3)}');
//           //   _endUserAppointmentResponseList[i].day = dateStr.substring(0, 3);
//           // }
//         });
//       }
//     } on CommonException catch (error) {
//       // await _progressDialog.hide();
//       debugPrint(error.toString());
//       if (error.code == 400) {
//         Map<String, dynamic> errorModel = jsonDecode(error.message);
//         if (errorModel.containsKey('ModelState')) {
//           Map<String, dynamic> modelState = errorModel['ModelState'];
//           if (modelState.containsKey('ErrorMessage')) {
//             showSnackBarColor(modelState['ErrorMessage'][0], context, true);
//           } else {
//             showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
//           }
//         } else {
//           showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
//         }
//       } else {
//         showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
//       }
//     } catch (error) {
//       // await _progressDialog.hide();
//       if (!mounted) return;
//       debugPrint(error.toString());
//       // Fluttertoast.showToast(
//       //     msg: "We\'re unable to connect to server. Please contact administrator or try after some time", toastLength: Toast.LENGTH_SHORT);
//     }
//   }

//   Widget showCalendarSheet(StateSetter setState) {
//     void _onDaySelectedView(
//       DateTime selectedDay,
//       DateTime focusedDay,
//     ) {
//       if (!isSameDay(_selectedDayView, selectedDay)) {
//         setState(() {
//           _selectedDayView = selectedDay;
//           _focusedDay = focusedDay;
//           _currentDay = format.format(_focusedDay!);
//           initSelectedDate = DateFormat.yMMMMEEEEd().format(_focusedDay!).split(' ')[0].split(',')[0];
//         });
//         // showCancelData();
//       }
//     }

//     return Container(
//       color: OQDOThemeData.whiteColor,
//       width: MediaQuery.of(context).size.width,
//       height: MediaQuery.of(context).size.height / 1.2,
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(top: 30),
//               child: calendarHeader(setState),
//             ),
//             const SizedBox(
//               height: 30,
//             ),
//             CustomTextView(
//               label: '${_currentDay.split("-")[0]} ${_currentDay.split('-')[1]} ${_currentDay.split('-')[2]}',
//               textStyle: Theme.of(context)
//                   .textTheme
//                   .titleLarge!
//                   .copyWith(fontSize: 21, color: const Color(0xFF333333), fontWeight: FontWeight.w500),
//             ),
//             const SizedBox(
//               height: 3,
//             ),
//             CustomTextView(
//               label: initSelectedDate,
//               textStyle: Theme.of(context)
//                   .textTheme
//                   .titleLarge!
//                   .copyWith(fontSize: 21, color: const Color(0xFF333333), fontWeight: FontWeight.w500),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(top: 40, left: 25, right: 25),
//               child: TableCalendar(
//                 firstDay: kPreviousDay,
//                 lastDay: kLastDay,
//                 focusedDay: _focusedDay!,
//                 calendarFormat: _calendarViewFormat,
//                 headerVisible: false,
//                 daysOfWeekVisible: true,
//                 currentDay: kToday,
//                 daysOfWeekStyle: const DaysOfWeekStyle(
//                     weekdayStyle: TextStyle(color: Color(0xFF006590), fontWeight: FontWeight.w500),
//                     weekendStyle: TextStyle(color: Color(0xFF006590), fontWeight: FontWeight.w500)),
//                 calendarStyle: CalendarStyle(
//                   isTodayHighlighted: true,
//                   outsideDaysVisible: false,
//                   selectedDecoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
//                   defaultTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black),
//                 ),
//                 onCalendarCreated: (controller) {
//                   _pageController = controller;
//                 },
//                 onPageChanged: (focuseDay) {
//                   setState(() {
//                     _focusedDay = focuseDay;
//                   });
//                 },
//                 onDaySelected: _onDaySelectedView,
//                 selectedDayPredicate: (DateTime date) {
//                   return isSameDay(_selectedDayView, date);
//                 },
//               ),
//             ),
//             const SizedBox(
//               height: 30,
//             ),
//             _selectedDayView != null
//                 ? Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
//                     child: MyButton(
//                       text: 'Continue',
//                       textcolor: Theme.of(context).colorScheme.onBackground,
//                       textsize: 16,
//                       fontWeight: FontWeight.w600,
//                       letterspacing: 0.7,
//                       buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
//                       buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
//                       buttonheight: 50,
//                       buttonwidth: MediaQuery.of(context).size.width,
//                       radius: 15,
//                       onTap: () async {
//                         Navigator.of(context).pop(_selectedDayView);
//                       },
//                     ),
//                   )
//                 : Container(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget calendarHeader(StateSetter setState) {
//     final headerText = DateFormat.yMMMM().format(_focusedDay!);
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 30),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               CustomTextView(
//                 label: headerText.split(' ')[0],
//                 textStyle: Theme.of(context)
//                     .textTheme
//                     .titleLarge!
//                     .copyWith(fontSize: 21, fontWeight: FontWeight.w700, color: const Color(0xFF333333)),
//               ),
//               const SizedBox(
//                 height: 5,
//               ),
//               CustomTextView(
//                 label: headerText.split(' ')[1],
//                 textStyle: Theme.of(context)
//                     .textTheme
//                     .titleLarge!
//                     .copyWith(fontSize: 21, fontWeight: FontWeight.w700, color: const Color(0xFF333333)),
//               ),
//             ],
//           ),
//           Row(
//             children: [
//               GestureDetector(
//                 onTap: () => onLeftArrowTap(),
//                 child: Image.asset(
//                   'assets/images/ic_calendar_pre.png',
//                   width: 30,
//                   height: 30,
//                 ),
//               ),
//               const SizedBox(
//                 width: 30,
//               ),
//               GestureDetector(
//                 onTap: () => onRightArrowTap(),
//                 child: Image.asset(
//                   'assets/images/ic_calendar_next.png',
//                   width: 30,
//                   height: 30,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   onLeftArrowTap() {
//     _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
//   }

//   onRightArrowTap() {
//     _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
//   }

//   void checkForCancelAppointment() {
//     String currentDateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
//     for (int i = 0; i < _endUserAppointmentList.length; i++) {
//       EndUserAppointmentsResponseModel endUserAppointmentsResponseModel = _endUserAppointmentList[i];
//       if (endUserAppointmentsResponseModel.date!.split('T')[0].compareTo(currentDateStr) < 0) {
//         for (var slots in endUserAppointmentsResponseModel.appointmentListingSlotDtos!) {
//           setState(() {
//             slots.isCancel = false;
//             slots.isPastSlot = true;
//           });
//         }
//       } else if (endUserAppointmentsResponseModel.date!.split('T')[0].compareTo(currentDateStr) > 0) {
//         debugPrint('Greater Dates -> ${endUserAppointmentsResponseModel.date}');
//         for (var slots in endUserAppointmentsResponseModel.appointmentListingSlotDtos!) {
//           setState(() {
//             slots.isDirectSlotCancel = false;
//           });
//         }
//       } else if (endUserAppointmentsResponseModel.date!.split('T')[0].compareTo(currentDateStr) == 0) {
//         String currentTime = DateTime.now().toString();
//         String minutes = currentTime.split(' ')[1].split('.')[0].split(':')[0];
//         String seconds = currentTime.split(' ')[1].split('.')[0].split(':')[1];
//         // int finalMinutes = int.parse(minutes);
//         // String finalCurrentTime = '$finalMinutes:$seconds';
//         Duration cancelSlotRefundPolicyTime =
//             Duration(minutes: int.parse(OQDOApplication.instance.configResponseModel!.cancelApplicableMinAfterEndTime!));
//         Duration currentTimeSlotDuration = Duration(hours: int.parse(minutes), minutes: int.parse(seconds));
//         for (var currentDateTimeSlots in endUserAppointmentsResponseModel.appointmentListingSlotDtos!) {
//           if (currentDateTimeSlots.isCancel!) {
//             setState(() {
//               currentDateTimeSlots.isCancel = true;
//               currentDateTimeSlots.isDirectSlotCancel = false;
//             });
//           } else {
//             String checkingDateTimeMinutes = currentDateTimeSlots.endTime!.split(':')[0];
//             String checkingDateTimeSeconds = currentDateTimeSlots.endTime!.split(':')[1];
//             // int finalEndMinutes = int.parse(checkingDateTimeMinutes) + cancelSlotRefundPolicyTime.inHours;
//             // showLog('End Final Time -> $finalEndMinutes');
//             // String finalCheckingDateTime = '$finalEndMinutes:$checkingDateTimeSeconds';
//             Duration endTimeDuration = Duration(
//                 hours: int.parse(checkingDateTimeMinutes) + cancelSlotRefundPolicyTime.inHours,
//                 minutes: int.parse(checkingDateTimeSeconds));
//             if (endTimeDuration.compareTo(currentTimeSlotDuration) < 0) {
//               setState(() {
//                 currentDateTimeSlots.isCancel = true;
//                 currentDateTimeSlots.isDirectSlotCancel = false;
//               });
//             } else {
//               String checkingStartDateTimeMinutes = currentDateTimeSlots.startTime!.split(':')[0];
//               String checkingStartDateTimeSeconds = currentDateTimeSlots.startTime!.split(':')[1];
//               // int finalStartMinutes = int.parse(checkingStartDateTimeMinutes);
//               Duration startTimeDuration =
//                   Duration(hours: int.parse(checkingStartDateTimeMinutes), minutes: int.parse(checkingStartDateTimeSeconds));
//               if (currentTimeSlotDuration.compareTo(startTimeDuration) >= 0 && currentTimeSlotDuration.compareTo(endTimeDuration) <= 0) {
//                 setState(() {
//                   currentDateTimeSlots.isCancel = false;
//                   currentDateTimeSlots.isDirectSlotCancel = true;
//                 });
//               } else {
//                 setState(() {
//                   currentDateTimeSlots.isCancel = false;
//                   currentDateTimeSlots.isDirectSlotCancel = false;
//                 });
//               }
//             }
//           }
//         }
//       }
//     }
//   }

//   void cancelAllDateBeforeTodaysDate() {
//     String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
//     showLog(currentDate);
//     var data = Duration(minutes: int.parse(OQDOApplication.instance.configResponseModel!.cancelApplicableMinAfterEndTime!));
//     showLog('IN HOURS -> ${data.inHours}');
//     for (var i = 0; i < _endUserAppointmentList.length; i++) {
//       if (_endUserAppointmentList[i].date!.split('T')[0].compareTo(currentDate) < 0) {
//         showLog(_endUserAppointmentList[i].date.toString());
//         for (var j = 0; j < _endUserAppointmentList[i].appointmentListingSlotDtos!.length; j++) {
//           setState(() {
//             _endUserAppointmentList[i].appointmentListingSlotDtos![j].isCancel = true;
//           });
//         }
//       } else if (_endUserAppointmentList[i].date!.split('T')[0].compareTo(currentDate) == 0) {
//         showLog(_endUserAppointmentList[i].date.toString());
//         String time = DateTime.now().toString();
//         debugPrint('Time -> $time');
//         String minutes = time.split(' ')[1].split('.')[0].split(':')[0];
//         String seconds = time.split(' ')[1].split('.')[0].split(':')[1];
//         int finalMinutes = int.parse(minutes);
//         debugPrint('finalMinutes -> $finalMinutes');
//         String finalTime = '$finalMinutes:$seconds';
//         debugPrint('Time -> $finalTime');
//         for (var j = 0; j < _endUserAppointmentList[i].appointmentListingSlotDtos!.length; j++) {
//           if (!_endUserAppointmentList[i].appointmentListingSlotDtos![j].isCancel!) {
//             String endminutes = _endUserAppointmentList[i].appointmentListingSlotDtos![j].endTime!.split(':')[0];
//             String endSeconds = _endUserAppointmentList[i].appointmentListingSlotDtos![j].endTime!.split(':')[1];
//             int finalEndMinutes = int.parse(endminutes) + data.inHours;
//             showLog('End Final Time -> $finalEndMinutes');
//             String finalEndTime = '$finalEndMinutes:$endSeconds';
//             debugPrint('End Final Time -> $finalEndTime');
//             if (finalTime.compareTo(finalEndTime) == 0) {
//               showLog(
//                   'time less than current Date & Time -> ${_endUserAppointmentList[i].date} - ${_endUserAppointmentList[i].appointmentListingSlotDtos![j].startTime} - ${_endUserAppointmentList[i].appointmentListingSlotDtos![j].startTime}');
//               setState(() {
//                 _endUserAppointmentList[i].appointmentListingSlotDtos![j].isCancel = false;
//                 _endUserAppointmentList[i].appointmentListingSlotDtos![j].isDirectSlotCancel = true;
//               });
//             } else if (finalTime.compareTo(finalEndTime) < 0) {
//               setState(() {
//                 _endUserAppointmentList[i].appointmentListingSlotDtos![j].isCancel = false;
//               });
//             } else {
//               showLog(
//                   'time less than current Date & Time else -> ${_endUserAppointmentList[i].date} - ${_endUserAppointmentList[i].appointmentListingSlotDtos![j].startTime} - ${_endUserAppointmentList[i].appointmentListingSlotDtos![j].startTime}');
//               setState(() {
//                 _endUserAppointmentList[i].appointmentListingSlotDtos![j].isCancel = true;
//               });
//             }
//           }
//         }
//       } else {
//         for (var j = 0; j < _endUserAppointmentList[i].appointmentListingSlotDtos!.length; j++) {
//           setState(() {
//             _endUserAppointmentList[i].appointmentListingSlotDtos![j].isCancel =
//                 _endUserAppointmentList[i].appointmentListingSlotDtos![j].isCancel;
//           });
//         }
//       }
//     }
//   }

//   Widget _buildCancelData(
//     BuildContext context,
//     FacilityAppointmentDetailModel? facilityAppointmentDetailModel,
//     int? setupDaySlotMapId,
//   ) {
//     return SafeArea(
//       child: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
//         return Container(
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.onBackground,
//             borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
//           ),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 Align(
//                   alignment: Alignment.center,
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 20.0),
//                     child: CustomTextView(
//                       label:
//                           '${_facilityAppointmentDetailModel!.facilitySetupTitle} - ${_facilityAppointmentDetailModel!.facilitySetupSubTitle}',
//                       textStyle: Theme.of(context)
//                           .textTheme
//                           .titleLarge!
//                           .copyWith(fontSize: 20, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w500),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 5.0,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 20.0, right: 20),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       CustomTextView(
//                         label: 'Details',
//                         textStyle: Theme.of(context)
//                             .textTheme
//                             .titleSmall!
//                             .copyWith(color: OQDOThemeData.otherTextColor, fontWeight: FontWeight.w600, fontSize: 12.0),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 20, right: 20),
//                   child: CustomTextView(
//                     label: 'Order ID: ${_facilityAppointmentDetailModel!.bookingNo}',
//                     textStyle: Theme.of(context)
//                         .textTheme
//                         .titleMedium!
//                         .copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 8,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 20, right: 20),
//                   child: CustomTextView(
//                     label: 'Name: ${_facilityAppointmentDetailModel!.endUserFirstName} ${_facilityAppointmentDetailModel!.endUserLastName}',
//                     textStyle: Theme.of(context)
//                         .textTheme
//                         .titleMedium!
//                         .copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 8,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 20, right: 20),
//                   child: CustomTextView(
//                     label: 'Email ID: ${_facilityAppointmentDetailModel!.endUserEmail}',
//                     textStyle: Theme.of(context)
//                         .textTheme
//                         .titleMedium!
//                         .copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 8,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 20, right: 20),
//                   child: CustomTextView(
//                     label: 'Phone number: ${_facilityAppointmentDetailModel!.endUserMobileNumber}',
//                     textStyle: Theme.of(context)
//                         .textTheme
//                         .titleMedium!
//                         .copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 8,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 20, right: 20),
//                   child: CustomTextView(
//                     label: _facilityAppointmentDetailModel!.bookingType == 'I' ? 'Booking For: Individual' : 'Booking For: Group',
//                     textStyle: Theme.of(context)
//                         .textTheme
//                         .titleMedium!
//                         .copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 const Divider(
//                   height: 1,
//                   color: Color(0xFFCACACA),
//                 ),
//                 const SizedBox(
//                   height: 20.0,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 10.0),
//                   child: CustomTextView(
//                     label: 'Cancel Reason',
//                     textStyle: Theme.of(context)
//                         .textTheme
//                         .bodyMedium!
//                         .copyWith(fontSize: 15, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 8,
//                 ),
//                 Row(
//                   children: [
//                     Radio<String>(
//                       autofocus: false,
//                       value: reasonValue,
//                       groupValue: reasonValue,
//                       activeColor: Theme.of(context).colorScheme.primary,
//                       onChanged: (String? value) {
//                         setState(() {
//                           reasonValue = value!;
//                           showLog('data -> $reasonValue');
//                         });
//                       },
//                       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     ),
//                     const SizedBox(
//                       width: 5,
//                     ),
//                     CustomTextView(
//                       label: 'Service Provider Didn\'t Show Up',
//                       textStyle: Theme.of(context)
//                           .textTheme
//                           .bodyMedium!
//                           .copyWith(fontSize: 15, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 18),
//                         child: SimpleButton(
//                           text: "Close",
//                           textcolor: Theme.of(context).colorScheme.onBackground,
//                           textsize: 14,
//                           fontWeight: FontWeight.w600,
//                           letterspacing: 0.7,
//                           buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
//                           buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
//                           buttonheight: 60,
//                           buttonwidth: MediaQuery.of(context).size.width,
//                           radius: 15,
//                           onTap: () async {
//                             reasonValue = '';
//                             Navigator.pop(context);
//                           },
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 18),
//                         child: SimpleButton(
//                           text: "Cancel Appointment",
//                           textcolor: Theme.of(context).colorScheme.onBackground,
//                           textsize: 14,
//                           fontWeight: FontWeight.w600,
//                           letterspacing: 0.7,
//                           buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
//                           buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
//                           buttonheight: 60,
//                           buttonwidth: MediaQuery.of(context).size.width,
//                           radius: 15,
//                           onTap: () async {
//                             // if (reasonValue.isEmpty) {
//                             //   showSnackBar('Please select reason', context);
//                             // } else {
//                             Navigator.pop(context);
//                             facilityCancelRequest(facilityAppointmentDetailModel, setupDaySlotMapId);
//                             // }
//                           },
//                         ),
//                       ),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }

//   Widget _coachDirectCancelBottomSheet(
//     BuildContext context,
//     model.CoachAppointmentDetailResponseModel? coachAppointmentDetailResponseModel,
//     int? setupDaySlotMapId,
//   ) {
//     if (coachAppointmentDetailResponseModel!.coachTrainingAddress!.isEmpty) {
//       addressData =
//           '${coachAppointmentDetailResponseModel.endUserTrainingAddress!.addressName}, ${coachAppointmentDetailResponseModel.endUserTrainingAddress!.address1}, ${coachAppointmentDetailResponseModel.endUserTrainingAddress!.address2}, ${coachAppointmentDetailResponseModel.endUserTrainingAddress!.cityName}, ${coachAppointmentDetailResponseModel.endUserTrainingAddress!.stateName}, ${coachAppointmentDetailResponseModel.endUserTrainingAddress!.countryName} - ${coachAppointmentDetailResponseModel.endUserTrainingAddress!.pincode}';
//     } else {
//       addressData =
//           '${coachAppointmentDetailResponseModel.coachTrainingAddress![0].addressName}, ${coachAppointmentDetailResponseModel.coachTrainingAddress![0].address1}, ${coachAppointmentDetailResponseModel.coachTrainingAddress![0].address2}, ${coachAppointmentDetailResponseModel.coachTrainingAddress![0].city!.name}, ${coachAppointmentDetailResponseModel.coachTrainingAddress![0].city!.state!.name}, ${coachAppointmentDetailResponseModel.coachTrainingAddress![0].city!.state!.country!.name} - ${coachAppointmentDetailResponseModel.coachTrainingAddress![0].pinCode}';
//     }
//     return SafeArea(
//       child: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
//         return Container(
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.onBackground,
//             borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
//           ),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 Align(
//                   alignment: Alignment.center,
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 20.0),
//                     child: CustomTextView(
//                       label: '${coachAppointmentDetailResponseModel.coachFirstName} - ${coachAppointmentDetailResponseModel.coachLastName}',
//                       textStyle: Theme.of(context)
//                           .textTheme
//                           .titleLarge!
//                           .copyWith(fontSize: 20, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w500),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 5.0,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 20.0, right: 20),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       CustomTextView(
//                         label: 'Details',
//                         textStyle: Theme.of(context)
//                             .textTheme
//                             .titleSmall!
//                             .copyWith(color: OQDOThemeData.otherTextColor, fontWeight: FontWeight.w600, fontSize: 12.0),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 20, right: 20),
//                   child: CustomTextView(
//                     label: 'Order ID: ${coachAppointmentDetailResponseModel.bookingNo}',
//                     textStyle: Theme.of(context)
//                         .textTheme
//                         .titleMedium!
//                         .copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 8,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 20, right: 20),
//                   child: CustomTextView(
//                     label:
//                         'Name: ${coachAppointmentDetailResponseModel.endUserFirstName} ${coachAppointmentDetailResponseModel.endUserLastName}',
//                     textStyle: Theme.of(context)
//                         .textTheme
//                         .titleMedium!
//                         .copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 8,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 20, right: 20),
//                   child: CustomTextView(
//                     label: 'Email ID: ${coachAppointmentDetailResponseModel.endUserEmail}',
//                     textStyle: Theme.of(context)
//                         .textTheme
//                         .titleMedium!
//                         .copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 8,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 20, right: 20),
//                   child: CustomTextView(
//                     label: 'Phone number: ${coachAppointmentDetailResponseModel.endUserMobileNumber}',
//                     textStyle: Theme.of(context)
//                         .textTheme
//                         .titleMedium!
//                         .copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 8,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 20, right: 20),
//                   child: CustomTextView(
//                     label: coachAppointmentDetailResponseModel.bookingType == 'I' ? 'Booking For: Individual' : 'Booking For: Group',
//                     textStyle: Theme.of(context)
//                         .textTheme
//                         .titleMedium!
//                         .copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 8,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 20, right: 20),
//                   child: CustomTextView(
//                     label: 'Address: $addressData',
//                     maxLine: 2,
//                     textOverFlow: TextOverflow.ellipsis,
//                     textStyle: Theme.of(context)
//                         .textTheme
//                         .titleMedium!
//                         .copyWith(fontSize: 14, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 const Divider(
//                   height: 1,
//                   color: Color(0xFFCACACA),
//                 ),
//                 const SizedBox(
//                   height: 20.0,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 10.0),
//                   child: CustomTextView(
//                     label: 'Cancel Reason',
//                     textStyle: Theme.of(context)
//                         .textTheme
//                         .bodyMedium!
//                         .copyWith(fontSize: 15, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 8,
//                 ),
//                 Row(
//                   children: [
//                     Radio<String>(
//                       autofocus: false,
//                       value: reasonValue,
//                       groupValue: reasonValue,
//                       activeColor: Theme.of(context).colorScheme.primary,
//                       onChanged: (String? value) {
//                         setState(() {
//                           reasonValue = value!;
//                           showLog('data -> $reasonValue');
//                         });
//                       },
//                       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     ),
//                     const SizedBox(
//                       width: 5,
//                     ),
//                     CustomTextView(
//                       label: 'Service Provider Didn\'t Show Up',
//                       textStyle: Theme.of(context)
//                           .textTheme
//                           .bodyMedium!
//                           .copyWith(fontSize: 15, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 18),
//                         child: SimpleButton(
//                           text: "Close",
//                           textcolor: Theme.of(context).colorScheme.onBackground,
//                           textsize: 14,
//                           fontWeight: FontWeight.w600,
//                           letterspacing: 0.7,
//                           buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
//                           buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
//                           buttonheight: 60,
//                           buttonwidth: MediaQuery.of(context).size.width,
//                           radius: 15,
//                           onTap: () async {
//                             reasonValue = '';
//                             Navigator.pop(context);
//                           },
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 18),
//                         child: SimpleButton(
//                           text: "Cancel Appointment",
//                           textcolor: Theme.of(context).colorScheme.onBackground,
//                           textsize: 14,
//                           fontWeight: FontWeight.w600,
//                           letterspacing: 0.7,
//                           buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
//                           buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
//                           buttonheight: 60,
//                           buttonwidth: MediaQuery.of(context).size.width,
//                           radius: 15,
//                           onTap: () async {
//                             // if (reasonValue.isEmpty) {
//                             //   showSnackBar('Please select reason', context);
//                             // } else {
//                             Navigator.pop(context);
//                             coachCancelRequest(coachAppointmentDetailResponseModel, setupDaySlotMapId);
//                             // }
//                           },
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }

//   Future<void> getAppointmentDetails(int bookingId, int? setupDaySlotMapId) async {
//     _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
//     _progressDialog.style(message: "Please wait..");
//     try {
//       await _progressDialog.show();
//       model.CoachAppointmentDetailResponseModel facilityAppointmentDetailModel =
//           await Provider.of<AppointmentViewModel>(context, listen: false).getCoachAppointmentDetail(bookingId.toString());
//       if (!mounted) return;
//       await _progressDialog.hide();
//       if (facilityAppointmentDetailModel.bookingNo != null) {
//         setState(() {
//           var data = Duration(minutes: int.parse(OQDOApplication.instance.configResponseModel!.cancelApplicableMinAfterEndTime!));
//           showLog('IN HOURS -> ${data.inHours}');
//           coachAppointmentDetailResponseModel = facilityAppointmentDetailModel;
//           showModalBottomSheet(
//               shape: const RoundedRectangleBorder(
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//               ),
//               context: context,
//               isDismissible: false,
//               enableDrag: false,
//               isScrollControlled: true,
//               builder: (BuildContext ctx) {
//                 return _coachDirectCancelBottomSheet(ctx, coachAppointmentDetailResponseModel, setupDaySlotMapId);
//               });
//         });
//       }
//     } on CommonException catch (error) {
//       await _progressDialog.hide();
//       debugPrint(error.toString());
//       if (error.code == 400) {
//         Map<String, dynamic> errorModel = jsonDecode(error.message);
//         if (errorModel.containsKey('ModelState')) {
//           Map<String, dynamic> modelState = errorModel['ModelState'];
//           if (modelState.containsKey('ErrorMessage')) {
//             showSnackBarColor(modelState['ErrorMessage'][0], context, true);
//           } else {
//             showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
//           }
//         } else {
//           showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
//         }
//       } else {
//         showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
//       }
//     } catch (error) {
//       await _progressDialog.hide();
//       if (!mounted) return;
//       debugPrint(error.toString());
//       showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context,true);
//     }
//   }

//   Future<void> getFacilityAppointmentDetails(int? bookingId, int? setupDaySlotMapId) async {
//     _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
//     _progressDialog.style(message: "Please wait..");
//     try {
//       await _progressDialog.show();
//       FacilityAppointmentDetailModel facilityAppointmentDetailModel =
//           await Provider.of<AppointmentViewModel>(context, listen: false).getFacilityAppointmentDetail(bookingId!.toString());
//       if (!mounted) return;
//       await _progressDialog.hide();
//       if (facilityAppointmentDetailModel.facilityBookingId != null) {
//         setState(() {
//           _facilityAppointmentDetailModel = facilityAppointmentDetailModel;
//           showModalBottomSheet(
//               shape: const RoundedRectangleBorder(
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//               ),
//               context: context,
//               isDismissible: false,
//               enableDrag: false,
//               isScrollControlled: true,
//               builder: (BuildContext ctx) {
//                 return _buildCancelData(ctx, _facilityAppointmentDetailModel, setupDaySlotMapId);
//               });
//         });
//       }
//     } on CommonException catch (error) {
//       await _progressDialog.hide();
//       debugPrint(error.toString());
//       if (error.code == 400) {
//         Map<String, dynamic> errorModel = jsonDecode(error.message);
//         if (errorModel.containsKey('ModelState')) {
//           Map<String, dynamic> modelState = errorModel['ModelState'];
//           if (modelState.containsKey('ErrorMessage')) {
//             showSnackBarColor(modelState['ErrorMessage'][0], context, true);
//           } else {
//             showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
//           }
//         } else {
//           showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
//         }
//       } else {
//         showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
//       }
//     } catch (error) {
//       await _progressDialog.hide();
//       if (!mounted) return;
//       debugPrint(error.toString());
//       showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context,true);
//     }
//   }

//   Future<void> facilityCancelRequest(FacilityAppointmentDetailModel? facilityAppointmentDetailModel, int? setupDaySlotMapId) async {
//     _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
//     _progressDialog.style(message: "Please wait..");
//     try {
//       await _progressDialog.show();
//       Map<String, dynamic> request = {};
//       request['SubActivityId'] = facilityAppointmentDetailModel!.subActivityId;
//       request['UserId'] = OQDOApplication.instance.endUserID;
//       request['CancelReasonId'] = OQDOApplication.instance.configResponseModel!.didntShowReasonId!;
//       request['OtherReason'] = '';
//       List<Map<String, dynamic>> data = [];
//       for (var i = 0; i < facilityAppointmentDetailModel.facilityBookingSlotDates!.length; i++) {
//         Map<String, dynamic> selectedFacilityReq = {};
//         if (setupDaySlotMapId == facilityAppointmentDetailModel.facilityBookingSlotDates![i].facilitySetupDaySlotMapId) {
//           selectedFacilityReq['SlotMapId'] = facilityAppointmentDetailModel.facilityBookingSlotDates![i].facilitySetupDaySlotMapId;
//           selectedFacilityReq['BookingDate'] = facilityAppointmentDetailModel.facilityBookingSlotDates![i].bookingDate!.split('T')[0];
//           data.add(selectedFacilityReq);
//         }
//       }
//       request['FacilityCancelAppointmentSlotDtos'] = data;
//       debugPrint('Request -> ${json.encode(request)}');
//       var list = await Provider.of<AppointmentViewModel>(context, listen: false).facilityCancelAppointmentRequest(request);
//       if (!mounted) return;
//       await _progressDialog.hide();
//       if (list.isNotEmpty) {
//         Navigator.of(context).pop();
//         Fluttertoast.showToast(
//             msg: 'Your Cancellation Request has been sent to the Service Provider for approval. Once approved, you will be refunded.',
//             toastLength: Toast.LENGTH_LONG);
//         await Navigator.pushNamedAndRemoveUntil(context, Constants.APPPAGES, Helper.of(context).predicate, arguments: 0);
//       }
//     } on CommonException catch (error) {
//       await _progressDialog.hide();
//       debugPrint(error.toString());
//       if (error.code == 400) {
//         Map<String, dynamic> errorModel = jsonDecode(error.message);
//         if (errorModel.containsKey('ModelState')) {
//           Map<String, dynamic> modelState = errorModel['ModelState'];
//           if (modelState.containsKey('ErrorMessage')) {
//             showSnackBarColor(modelState['ErrorMessage'][0], context, true);
//           } else {
//             showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
//           }
//         } else {
//           showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
//         }
//       } else {
//         showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
//       }
//     } catch (error) {
//       await _progressDialog.hide();
//       if (!mounted) return;
//       debugPrint(error.toString());
//       showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context,true);
//     }
//   }

//   Future<void> coachCancelRequest(
//       model.CoachAppointmentDetailResponseModel coachAppointmentDetailResponseModel, int? setupDaySlotMapId) async {
//     _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
//     _progressDialog.style(message: "Please wait..");
//     try {
//       await _progressDialog.show();
//       Map<String, dynamic> request = {};
//       request['UserId'] = OQDOApplication.instance.endUserID;
//       request['CancelReasonId'] = OQDOApplication.instance.configResponseModel!.didntShowReasonId!;
//       request['OtherReason'] = '';
//       List<Map<String, dynamic>> data = [];
//       for (var i = 0; i < coachAppointmentDetailResponseModel.coachBookingSlotDates!.length; i++) {
//         Map<String, dynamic> selectedFacilityReq = {};
//         if (setupDaySlotMapId == coachAppointmentDetailResponseModel.coachBookingSlotDates![i].coachBatchSetupDaySlotMapId) {
//           selectedFacilityReq['SlotMapId'] = coachAppointmentDetailResponseModel.coachBookingSlotDates![i].coachBatchSetupDaySlotMapId;
//           selectedFacilityReq['BookingDate'] = coachAppointmentDetailResponseModel.coachBookingSlotDates![i].bookingDate!.split('T')[0];
//           data.add(selectedFacilityReq);
//         }
//       }
//       request['CoachCancelAppointmentSlotDtos'] = data;
//       debugPrint('Request -> ${json.encode(request)}');
//       var list = await Provider.of<AppointmentViewModel>(context, listen: false).coachCancelAppointmentRequest(request);
//       await _progressDialog.hide();
//       if (list.isNotEmpty) {
//         Navigator.of(context).pop();
//         Fluttertoast.showToast(
//             msg: 'Your Cancellation Request has been sent to the Service Provider for approval. Once approved, you will be refunded.',
//             toastLength: Toast.LENGTH_LONG);
//         await Navigator.pushNamedAndRemoveUntil(context, Constants.APPPAGES, Helper.of(context).predicate, arguments: 0);
//       }
//     } on CommonException catch (error) {
//       await _progressDialog.hide();
//       debugPrint(error.toString());
//       if (error.code == 400) {
//         Map<String, dynamic> errorModel = jsonDecode(error.message);
//         if (errorModel.containsKey('ModelState')) {
//           Map<String, dynamic> modelState = errorModel['ModelState'];
//           if (modelState.containsKey('ErrorMessage')) {
//             showSnackBarColor(modelState['ErrorMessage'][0], context, true);
//           } else {
//             showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
//           }
//         } else {
//           showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
//         }
//       } else {
//         showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
//       }
//     } catch (error) {
//       await _progressDialog.hide();
//       debugPrint(error.toString());
//       showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context,true);
//     }
//   }
// }
