import 'dart:math';

import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/helper/helpers.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../components/my_button.dart';

class BatchSetupPage extends StatefulWidget {
  @override
  _BatchSetupPageState createState() => _BatchSetupPageState();
}

class _BatchSetupPageState extends State<BatchSetupPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();

  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  late Helper hp;
  DateTime focusDay = DateTime.now();

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
      appBar: CustomAppBar(
          title: 'oqdo',
          onBack: () {
            Navigator.of(context).pop();
          }),
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
                          CustomTextView(
                            label: 'April',
                            type: styleSubTitle,
                            textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          IconButton(
                              onPressed: () {
                                // Navigator.of(context).pop();
                              },
                              icon: Icon(
                                Icons.date_range,
                                color: Theme.of(context).colorScheme.primary,
                                size: 25,
                              ))
                        ],
                      ),
                    ),
                    Container(
                      width: width,
                      height: 10,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    const SizedBox(
                      height: 10,
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
                          focusedDay: focusDay,
                          calendarFormat: CalendarFormat.week,
                          headerVisible: false,
                          daysOfWeekVisible: true,
                          daysOfWeekHeight: 35,
                          // startingDayOfWeek: StartingDayOfWeek.monday,
                          selectedDayPredicate: (DateTime date) {
                            return isSameDay(focusDay, date);
                          },
                          calendarStyle: CalendarStyle(
                            isTodayHighlighted: false,
                            outsideDaysVisible: false,
                            selectedDecoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, shape: BoxShape.circle),
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
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: CustomTextView(
                          label: 'Batches',
                          type: styleSubTitle,
                          textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: width,
                      height: 10,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 20, crossAxisSpacing: 70, childAspectRatio: 4),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                            child: Center(
                              child: CustomTextView(
                                label: '11:00 - 11:30',
                                type: styleSubTitle,
                                textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.onSurface),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                            child: Center(
                              child: CustomTextView(
                                label: '11:00 - 11:30',
                                type: styleSubTitle,
                                textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.onSurface),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                            child: Center(
                              child: CustomTextView(
                                label: '11:00 - 11:30',
                                type: styleSubTitle,
                                textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.onSurface),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                            child: Center(
                              child: CustomTextView(
                                label: '11:00 - 11:30',
                                type: styleSubTitle,
                                textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.onSurface),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                            child: Center(
                              child: CustomTextView(
                                label: '11:00 - 11:30',
                                type: styleSubTitle,
                                textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.onSurface),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                            child: Center(
                              child: CustomTextView(
                                label: '11:00 - 11:30',
                                type: styleSubTitle,
                                textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.onSurface),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                            child: Center(
                              child: CustomTextView(
                                label: '11:00 - 11:30',
                                type: styleSubTitle,
                                textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.onSurface),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                            child: Center(
                              child: CustomTextView(
                                label: '11:00 - 11:30',
                                type: styleSubTitle,
                                textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.onSurface),
                              ),
                            ),
                          ),
                        ]),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 27, right: 15),
                    //   child: Align(
                    //     alignment: Alignment.centerLeft,
                    //     child: Container(
                    //       padding: const EdgeInsets.all(12),
                    //       decoration: BoxDecoration(
                    //         border: Border.all(
                    //           color: Theme.of(context).colorScheme.primary,
                    //         ),
                    //         color: Theme.of(context).colorScheme.onBackground,
                    //       ),
                    //       child: CustomTextView(
                    //         label: '11:00 - 11:30',
                    //         type: styleSubTitle,
                    //         textStyle: Theme.of(context)
                    //             .textTheme
                    //             .titleSmall!
                    //             .copyWith(
                    //                 color: Theme.of(context)
                    //                     .colorScheme
                    //                     .onSurface),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    SizedBox(
                      height: height / 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: MyButton(
                        text: "Save",
                        textcolor: Theme.of(context).colorScheme.onBackground,
                        textsize: 16,
                        fontWeight: FontWeight.w600,
                        letterspacing: 0.7,
                        buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                        buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                        buttonheight: 50,
                        buttonwidth: width,
                        radius: 15,
                        onTap: () async {},
                      ),
                    ),
                  ],
                ),
              ))),
    );
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      focusDay = focusedDay;
    });
  }
}
