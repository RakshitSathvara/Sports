import 'dart:math';

import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/helper/helpers.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../components/my_button.dart';

class CalendarViewPage extends StatefulWidget {
  const CalendarViewPage({Key? key}) : super(key: key);

  @override
  _CalendarViewPageState createState() => _CalendarViewPageState();
}

class _CalendarViewPageState extends State<CalendarViewPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();

  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  late Helper hp;
  DateTime focusday = DateTime.now();

  @override
  void initState() {
    super.initState();
    hp = Helper.of(context);
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
                    Container(
                      width: width,
                      height: 10,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 27, right: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              CustomTextView(
                                label: 'April',
                                type: styleSubTitle,
                                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface),
                              ),
                              CustomTextView(
                                label: '2022',
                                type: styleSubTitle,
                                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface),
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    // Navigator.of(context).pop();
                                  },
                                  icon: Icon(
                                    Icons.arrow_back_ios,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 20,
                                  )),
                              IconButton(
                                  onPressed: () {
                                    // Navigator.of(context).pop();
                                  },
                                  icon: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 20,
                                  )),
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height / 15,
                    ),
                    Column(
                      children: [
                        CustomTextView(
                          label: '28 April 2022',
                          type: styleSubTitle,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.normal),
                        ),
                        CustomTextView(
                          label: 'Thursday',
                          type: styleSubTitle,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: height / 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                        width: width,
                        // height: height / 4.5,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Theme.of(context).colorScheme.onBackground),
                        padding: const EdgeInsets.only(top: 15),
                        child: TableCalendar(
                          firstDay: DateTime.now(),
                          lastDay: DateTime.utc(2050, 3, 14),
                          focusedDay: focusday,
                          calendarFormat: CalendarFormat.month,
                          headerVisible: false,
                          daysOfWeekVisible: true,
                          // startingDayOfWeek: StartingDayOfWeek.monday,
                          selectedDayPredicate: (DateTime date) {
                            return isSameDay(focusday, date);
                          },
                          calendarStyle: CalendarStyle(
                            isTodayHighlighted: false,
                            outsideDaysVisible: false,
                            selectedDecoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                            // todayDecoration: BoxDecoration(
                            //     color: Colors.yellow.shade700,
                            //     shape: BoxShape.circle),
                            defaultTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black),
                            weekendTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xffBEBEBE)),
                          ),
                          onDaySelected: onDaySelected,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height / 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: MyButton(
                        text: "Go to Batch Setup",
                        textcolor: Theme.of(context).colorScheme.onBackground,
                        textsize: 16,
                        fontWeight: FontWeight.w600,
                        letterspacing: 0.7,
                        buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                        buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                        buttonheight: 50,
                        buttonwidth: width,
                        radius: 15,
                        onTap: () async {
                          await Navigator.pushNamed(context, Constants.BATCHSETUPPAGE);
                        },
                      ),
                    ),
                  ],
                ),
              ))),
    );
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    //print(focusedDay);
    setState(() {
      focusday = focusedDay;
    });
  }
}
