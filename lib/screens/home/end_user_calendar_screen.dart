// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/model/end_user_appoinments_model.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/meetups/data/meetup_response_model.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:oqdo_mobile_app/viewmodels/appointment_view_model.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class EndUserCalendarViewScreen extends StatefulWidget {
  const EndUserCalendarViewScreen({Key? key}) : super(key: key);

  @override
  State<EndUserCalendarViewScreen> createState() => _EndUserCalendarViewScreenState();
}

class _EndUserCalendarViewScreenState extends State<EndUserCalendarViewScreen> {
  late DateTime lastDateForBooking;
  DateTime currentDateTime = DateTime.now();
  late PageController _pageController;
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  late String _currentDay;
  DateFormat format = DateFormat('d-MMMM-yyyy');
  DateTime? _selectedDay;
  String initSelectedDate = '';
  late ProgressDialog _progressDialog;
  List<DateTime> calendarDateList = [];
  List<MeetupResponse> allMeetupList = [];
  List<EndUserAppointmentsResponseModel> allAppointmentList = [];
  String meetupStr = '';
  String appointmentStr = '';

  @override
  void initState() {
    super.initState();
    lastDateForBooking = DateTime(currentDateTime.year, currentDateTime.month, currentDateTime.day + 90);
    _currentDay = format.format(_focusedDay);
    initSelectedDate = DateFormat.yMMMMEEEEd().format(_focusedDay).split(' ')[0].split(',')[0];
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (OQDOApplication.instance.isLogin == '1') {
        getEndUserAppointments(kPreviousDay);
      } else {
        showSnackBarColor('Please login', context, true);
        Timer(const Duration(microseconds: 500), () {
          Navigator.of(context).pushReplacementNamed(Constants.LOGIN);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: OQDOThemeData.whiteColor,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: calendarHeader(),
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
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  headerVisible: false,
                  daysOfWeekVisible: true,
                  eventLoader: (day) => calendarDateList.where((element) => isSameDay(element, day)).toList(),
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
                  onDaySelected: _onDaySelected,
                  selectedDayPredicate: (DateTime date) {
                    return isSameDay(_selectedDay, date);
                  },
                ),
              ),
              const SizedBox(
                height: 60,
              ),
              _selectedDay != null
                  ? /* Padding(
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
                          await Navigator.pushNamed(context, Constants.endUserAppointmentScreen);
                        },
                      ),
                    ) */
                  Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 60,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(
                                    const Color(0xffED8000),
                                  ),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18.0),
                                        side: const BorderSide(
                                          color: Color(0xffED8000),
                                        )),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pushNamed(Constants.listMeetup, arguments: _focusedDay).then((value) async {
                                    if (value != null && value == true) {
                                      _selectedDay = null;
                                      _focusedDay = DateTime.now();
                                      await getEndUserAppointments(kPreviousDay);
                                    }
                                  });
                                },
                                child: CustomTextView(
                                  label: meetupStr,
                                  textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 60,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(
                                    const Color(0xff006590),
                                  ),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: const BorderSide(
                                        color: Color(0xff006590),
                                      ),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(context, Constants.endUserAppointmentScreen, arguments: _focusedDay);
                                },
                                child: CustomTextView(
                                  label: appointmentStr,
                                  textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget calendarHeader() {
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

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (OQDOApplication.instance.isLogin == '1') {
      if (!isSameDay(_selectedDay, selectedDay)) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          initSelectedDate = DateFormat.yMMMMEEEEd().format(_focusedDay).split(' ')[0].split(',')[0];
        });
        if (calendarDateList.isNotEmpty) {
          dateChange();
        } else {
          meetupStr = 'Meet Up';
          appointmentStr = 'Appointments';
        }
      }
    } else {
      showSnackBarColor('Please login', context, true);
      Timer(const Duration(microseconds: 500), () {
        Navigator.of(context).pushReplacementNamed(Constants.LOGIN);
      });
    }
  }

  void dateChange() {
    setState(() {
      _currentDay = format.format(_focusedDay);
      initSelectedDate = DateFormat.yMMMMEEEEd().format(_focusedDay).split(' ')[0].split(',')[0];
      var strDate = DateFormat('yyyy-MM-dd').format(_focusedDay);
      debugPrint('current date -> $_currentDay');
      debugPrint('current date -> $strDate');
      List<MeetupResponse> response = allMeetupList.where((element) => element.date!.split('T')[0] == strDate).toList();
      List<EndUserAppointmentsResponseModel> appointmentList = allAppointmentList.where((element) => element.date!.split('T')[0] == strDate).toList();
      debugPrint('meetup -> ${response[0].meetUps!.length}');
      if (response[0].meetUps!.isNotEmpty) {
        meetupStr = 'Meet Up (${response[0].meetUps!.length})';
      } else {
        meetupStr = 'Meet Up';
      }

      if (appointmentList[0].appointmentListingSlotDtos!.isNotEmpty) {
        List<AppointmentListingSlotDtos> tempList = [];
        for (var element in appointmentList[0].appointmentListingSlotDtos!) {
          if (!element.isCancel!) {
            tempList.add(element);
          }
        }
        if (tempList.isNotEmpty) {
          appointmentStr = 'Appointments (${tempList.length.toString()})';
        } else {
          appointmentStr = 'Appointments';
        }
      } else {
        appointmentStr = 'Appointments';
      }
    });
  }

  Future<void> getEndUserAppointments(DateTime passingDate) async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    try {
      await _progressDialog.show();
      List<EndUserAppointmentsResponseModel> endUserAppointmentList = await Provider.of<AppointmentViewModel>(context, listen: false)
          .getEndUserAppointments(OQDOApplication.instance.endUserID!, convertDateTimeToString(passingDate), convertDateTimeToString(kLastDay));

      if (endUserAppointmentList.isNotEmpty) {
        allAppointmentList.clear();
        calendarDateList.clear();
        setState(() {
          allAppointmentList.addAll(endUserAppointmentList);
          for (var i = 0; i < endUserAppointmentList.length; i++) {
            if (endUserAppointmentList[i].appointmentListingSlotDtos!.isNotEmpty) {
              for (var element in endUserAppointmentList[i].appointmentListingSlotDtos!) {
                if (!element.isCancel!) {
                  DateTime date = DateFormat('yyyy-MM-dd').parse(endUserAppointmentList[i].date!.split('T')[0]);
                  calendarDateList.add(date);
                  break;
                }
              }
            }
          }
          getAllMeetupList();
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

  Future<void> getAllMeetupList() async {
    try {
      MeetupResponseModel meetupResponseModel = await Provider.of<AppointmentViewModel>(context, listen: false)
          .getAllMeetupList(convertDateTimeToString(kPreviousDay), convertDateTimeToString(kLastDay));
      if (!mounted) return;
      await _progressDialog.hide();
      if (meetupResponseModel.data!.isNotEmpty) {
        allMeetupList.clear();
        setState(() {
          allMeetupList.addAll(meetupResponseModel.data!);
          for (var i = 0; i < meetupResponseModel.data!.length; i++) {
            if (meetupResponseModel.data![i].date!.isNotEmpty) {
              if (meetupResponseModel.data![i].meetUps!.isNotEmpty) {
                if (allAppointmentList[i].appointmentListingSlotDtos!.isNotEmpty) {
                  String appointmentEventDate = allAppointmentList[i].date!.split('T')[0];
                  debugPrint('appointmentEventDate -> $appointmentEventDate');
                  String meetUpDate = meetupResponseModel.data![i].date!.split('T')[0];
                  debugPrint('meetup date -> $meetUpDate');
                  if (appointmentEventDate.compareTo(meetUpDate) == 0) {
                  } else {
                    DateTime date = DateFormat('yyyy-MM-dd').parse(meetupResponseModel.data![i].date!.split('T')[0]);
                    calendarDateList.add(date);
                  }
                } else {
                  DateTime date = DateFormat('yyyy-MM-dd').parse(meetupResponseModel.data![i].date!.split('T')[0]);
                  calendarDateList.add(date);
                }
              }
            }
          }
        });
      }
    } on CommonException catch (error) {
      await _progressDialog.hide();
      showLog(error.toString());
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
      } else if (error.code == 500) {
        showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      } else if (error.code == 404) {
        showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
    } on NoConnectivityException catch (_) {
      await _progressDialog.hide();
      if (!mounted) return;
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      await _progressDialog.hide();
      if (!mounted) return;
      showLog(error.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }
}
