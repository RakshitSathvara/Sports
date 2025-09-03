import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../components/my_button.dart';

class CalendarServiceProviderPage extends StatefulWidget {
  const CalendarServiceProviderPage({Key? key}) : super(key: key);

  @override
  _CalendarServiceProviderPageState createState() => _CalendarServiceProviderPageState();
}

class _CalendarServiceProviderPageState extends State<CalendarServiceProviderPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  double get height => MediaQuery.of(context).size.height;
  double get width => MediaQuery.of(context).size.width;
  late DateTime lastDateForBooking;
  DateTime currentDateTime = DateTime.now();
  late PageController _pageController;
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  late String _currentDay;
  DateFormat format = DateFormat('d-MMMM-yyyy');
  DateTime? _selectedDay;
  String initSelectedDate = '';

  @override
  void initState() {
    super.initState();
    lastDateForBooking = DateTime(currentDateTime.year, currentDateTime.month, currentDateTime.day);
    _currentDay = format.format(_focusedDay);
    initSelectedDate = DateFormat.yMMMMEEEEd().format(_focusedDay).split(' ')[0].split(',')[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: Container(
          width: width,
          height: height,
          color: Theme.of(context).colorScheme.onBackground,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0, 18, 18),
                    child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(
                          Icons.add_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all<Color>(
                              Theme.of(context).colorScheme.onBackground,
                            ),
                            backgroundColor: MaterialStateProperty.all<Color>(
                              ColorsUtils.greyButton,
                            )),
                        label: Text(
                          "Add Vacation",
                          style: TextStyle(color: Theme.of(context).colorScheme.primary),
                        )),
                  ),
                ),
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
                    firstDay: kFirstDay,
                    lastDay: kLastOfCalendarDay,
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
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
                          text: 'Appointment',
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
                            Navigator.pushNamed(context, Constants.BATCHSETUPPAGE);
                          },
                        ),
                      )
                    : Container(),
              ],
            ),
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
    });
  }
}
