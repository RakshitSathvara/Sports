import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/model/coach_appointments_response_model.dart';
import 'package:oqdo_mobile_app/model/facility_appointment_resopnse_model.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:oqdo_mobile_app/viewmodels/appointment_view_model.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class ServiceProviderCalendarScreen extends StatefulWidget {
  const ServiceProviderCalendarScreen({Key? key}) : super(key: key);

  @override
  State<ServiceProviderCalendarScreen> createState() => _ServiceProviderCalendarScreenState();
}

class _ServiceProviderCalendarScreenState extends State<ServiceProviderCalendarScreen> {
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

  @override
  void initState() {
    super.initState();
    lastDateForBooking = DateTime(currentDateTime.year, currentDateTime.month, currentDateTime.day + 90);
    _currentDay = format.format(_focusedDay);
    initSelectedDate = DateFormat.yMMMMEEEEd().format(_focusedDay).split(' ')[0].split(',')[0];
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (OQDOApplication.instance.userType == Constants.facilityType) {
        getFacilityAppointments(kToday);
      } else {
        getCoachAppointments(kToday);
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
                height: 30,
              ),
              _selectedDay != null
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
                          if (OQDOApplication.instance.userType == Constants.facilityType) {
                            await Navigator.pushNamed(context, Constants.facilityAppointmentScreen, arguments: _selectedDay);
                          } else {
                            await Navigator.pushNamed(context, Constants.coachAppointmentScreen, arguments: _selectedDay);
                          }
                        },
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
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        initSelectedDate = DateFormat.yMMMMEEEEd().format(_focusedDay).split(' ')[0].split(',')[0];
      });
      dateChange();
    }
  }

  void dateChange() {
    setState(() {
      _currentDay = format.format(_focusedDay);
      initSelectedDate = DateFormat.yMMMMEEEEd().format(_focusedDay).split(' ')[0].split(',')[0];
    });
  }

  Future<void> getFacilityAppointments(DateTime passingDate) async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    try {
      await _progressDialog.show();
      List<FacilityAppointmentsResponseModel> endUserAppointmentList = await Provider.of<AppointmentViewModel>(context, listen: false)
          .getFacilityProviderAppointments(OQDOApplication.instance.facilityID!, convertDateTimeToString(kPreviousDay), convertDateTimeToString(kLastDay));
      await _progressDialog.hide();
      if (endUserAppointmentList.isNotEmpty) {
        setState(() {
          for (var i = 0; i < endUserAppointmentList.length; i++) {
            if (endUserAppointmentList[i].appointmentListingSlotDtos!.isNotEmpty) {
              for (var element in endUserAppointmentList[i].appointmentListingSlotDtos!) {
                if (!element.isCancel!) {
                  DateTime date = DateFormat('yyyy-MM-dd').parse(endUserAppointmentList[i].date!.split('T')[0]);
                  calendarDateList.add(date);
                  break;
                }
              }
              // DateTime date = DateFormat('yyyy-MM-dd').parse(endUserAppointmentList[i].date!.split('T')[0]);
              // calendarDateList.add(date);
            }
          }
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

  Future<void> getCoachAppointments(DateTime passingDate) async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    try {
      await _progressDialog.show();
      List<CoachAppointmentsResponseModel> endUserAppointmentList = await Provider.of<AppointmentViewModel>(context, listen: false)
          .getCoachProviderAppointments(OQDOApplication.instance.coachID!, convertDateTimeToString(kPreviousDay), convertDateTimeToString(kLastDay));
      await _progressDialog.hide();
      if (endUserAppointmentList.isNotEmpty) {
        setState(() {
          for (var i = 0; i < endUserAppointmentList.length; i++) {
            if (endUserAppointmentList[i].appointmentListingSlotDtos!.isNotEmpty) {
              for (var element in endUserAppointmentList[i].appointmentListingSlotDtos!) {
                if (!element.isCancel!) {
                  DateTime date = DateFormat('yyyy-MM-dd').parse(endUserAppointmentList[i].date!.split('T')[0]);
                  calendarDateList.add(date);
                  break;
                }
              }
              // DateTime date = DateFormat('yyyy-MM-dd').parse(endUserAppointmentList[i].date!.split('T')[0]);
              // calendarDateList.add(date);
            }
          }
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
}
