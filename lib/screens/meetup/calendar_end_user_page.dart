import 'dart:math';

import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/helper/helpers.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../components/my_button.dart';

class CalendarEndUserPage extends StatefulWidget {
  const CalendarEndUserPage({Key? key}) : super(key: key);

  @override
  _CalendarEndUserPageState createState() => _CalendarEndUserPageState();
}

class _CalendarEndUserPageState extends State<CalendarEndUserPage> {
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
    // TODO: implement build
    return Scaffold(
      key: scaffoldKey,
      // appBar: AppBar(
      //   elevation: 0,
      //   leading: IconButton(
      //       onPressed: () {
      //         Navigator.of(context).pop();
      //       },
      //       icon: Icon(
      //         Icons.arrow_back,
      //         color: Theme.of(context).colorScheme.onSurface,
      //       )),
      //   backgroundColor: Theme.of(context).colorScheme.onBackground,
      //   title: Text(
      //     "OQDO",
      //     style: Theme.of(context)
      //         .textTheme
      //         .titleMedium!
      //         .copyWith(color: Theme.of(context).colorScheme.onSurface),
      //   ),
      //   centerTitle: true,
      // ),
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
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0, 18, 18),
                        child: ElevatedButton.icon(
                            onPressed: () {
                              /* do something here */
                            },
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
                            width: 10,
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
                    const SizedBox(
                      height: 25,
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
                    const SizedBox(
                      height: 25,
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
                    const SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: MyButton(
                        text: "Appointments",
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
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ))),
    );
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    // print(focusedDay);
    setState(() {
      focusday = focusedDay;
    });
  }
}
