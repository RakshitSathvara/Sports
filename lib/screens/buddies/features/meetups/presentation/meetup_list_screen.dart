import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/meetups/data/meet_up_repository.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/meetups/data/meetup_response_model.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:table_calendar/table_calendar.dart';

class MeetupListScreen extends StatefulWidget {
  DateTime? dateTime;

  MeetupListScreen({Key? key, this.dateTime}) : super(key: key);

  @override
  State<MeetupListScreen> createState() => _MeetupListScreenState();
}

class _MeetupListScreenState extends State<MeetupListScreen> {
  List<MeetupResponse> allMeetupList = [];
  String monthStr = '';
  late ProgressDialog _progressDialog;
  DateTime? firstDate;
  DateTime? lastDate;
  DateTime? _selectedDay;
  final CalendarFormat _calendarFormat = CalendarFormat.week;
  late String _currentDay;
  DateFormat format = DateFormat('d-MMMM-yyyy');
  String initSelectedDate = '';
  bool isLoading = false;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  bool _isChanged = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      monthStr = DateFormat.yMMMM().format(widget.dateTime!).split(' ')[0];
      _selectedDay = widget.dateTime!;
      firstDate = kToday;
      lastDate = DateTime(firstDate!.year, firstDate!.month, firstDate!.day + 89);
      _currentDay = format.format(DateTime.now());
      initSelectedDate = DateFormat.yMMMMEEEEd().format(DateTime.now()).split(' ')[0].split(',')[0];
      getAllMeetupList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_isChanged);
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBar(
            title: 'Meetup',
            onBack: () {
              Navigator.of(context).pop(_isChanged);
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            var result = await Navigator.of(context).pushNamed(Constants.addMeetup);
            if (result != null && result == true) {
              _isChanged = true;
              monthStr = DateFormat.yMMMM().format(widget.dateTime!).split(' ')[0];
              _selectedDay = widget.dateTime!;
              firstDate = widget.dateTime!;
              lastDate = DateTime(firstDate!.year, firstDate!.month, firstDate!.day + 89);
              _currentDay = format.format(DateTime.now());
              initSelectedDate = DateFormat.yMMMMEEEEd().format(DateTime.now()).split(' ')[0].split(',')[0];
              getAllMeetupList();
            } else {
              _isChanged = false;
            }
          },
          child: Image.asset(
            'assets/images/ic_add_fab.png',
            height: 30,
            width: 30,
          ),
        ),
        body: SafeArea(
            child: Container(
          color: OQDOThemeData.whiteColor,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              headerView(),
              Padding(
                padding: const EdgeInsets.only(top: 30, left: 10.0, right: 10),
                child: calendarView(),
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
                  : allMeetupList.isNotEmpty
                      ? Expanded(
                          child: ScrollablePositionedList.builder(
                          itemCount: allMeetupList.length,
                          shrinkWrap: true,
                          itemScrollController: itemScrollController,
                          itemPositionsListener: itemPositionsListener,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, index) {
                            return Column(
                              key: ValueKey<String>(allMeetupList[index].date!),
                              children: [
                                allMeetupList[index].meetUps!.isNotEmpty
                                    ? ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: allMeetupList[index].meetUps!.length,
                                        itemBuilder: (context, subIndex) {
                                          var model = allMeetupList[index].meetUps![subIndex];
                                          return singleMeetupView(allMeetupList[index], model);
                                        },
                                      )
                                    : SizedBox(
                                        height: 120.0,
                                        child: InkWell(
                                          onTap: () async {},
                                          child: Container(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Card(
                                              semanticContainer: true,
                                              color: const Color.fromRGBO(237, 237, 237, 1),
                                              clipBehavior: Clip.antiAliasWithSaveLayer,
                                              elevation: 4.0,
                                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 20.0),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Card(
                                                          elevation: 4.0,
                                                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(100))),
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(10.0),
                                                            child: CustomTextView(
                                                              label: allMeetupList[index].date!.split('-')[2].split('T')[0],
                                                              textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                                                                  fontWeight: FontWeight.w700, fontSize: 18.0, color: Theme.of(context).colorScheme.primary),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 8.0,
                                                        ),
                                                        CustomTextView(
                                                          label: allMeetupList[index].day,
                                                          textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                              fontWeight: FontWeight.w500, fontSize: 16.0, color: Theme.of(context).colorScheme.primary),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 30.0,
                                                  ),
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      CustomTextView(
                                                        label: 'No Events',
                                                        maxLine: 2,
                                                        textOverFlow: TextOverflow.ellipsis,
                                                        textStyle: Theme.of(context)
                                                            .textTheme
                                                            .titleSmall!
                                                            .copyWith(fontWeight: FontWeight.w500, fontSize: 15.0, color: OQDOThemeData.greyColor),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            );
                          },
                        ))
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
                                label: 'No meetup available',
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(fontSize: 16, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
            ],
          ),
        )),
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
          // GestureDetector(
          //   onTap: () async {},
          //   child: Image.asset(
          //     'assets/images/calendar_cicular.png',
          //     height: 25,
          //     width: 25,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget calendarView() {
    return firstDate != null
        ? TableCalendar(
            focusedDay: _selectedDay!,
            firstDay: kPreviousDay,
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

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
      });
      monthChangeStr();
      var item = allMeetupList.firstWhere((element) => convertToStringFromDate(element.date!) == convertDateTimeToString(_selectedDay!));
      int selectedDateIndex = allMeetupList.indexOf(item);
      scrollTo(selectedDateIndex);
    }
  }

  void monthChangeStr() {
    setState(() {
      monthStr = DateFormat.yMMMM().format(_selectedDay!).split(' ')[0];
    });
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

  void scrollTo(int index) => itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOutCubic,
      );

  Future<void> getAllMeetupList() async {
    try {
      showLoader();
      MeetupResponseModel meetupResponseModel = await Provider.of<MeetupRepository>(context, listen: false)
          .getAllMeetupList(convertDateTimeToString(kPreviousDay), convertDateTimeToString(lastDate!));
      if (!mounted) return;
      hideLoader();
      if (meetupResponseModel.data!.isNotEmpty) {
        setState(() {
          allMeetupList.clear();
          allMeetupList.addAll(meetupResponseModel.data!);
          showLog(allMeetupList.length.toString());
          for (int i = 0; i < allMeetupList.length; i++) {
            DateTime dateTime = DateFormat('yyyy-MM-dd').parse(allMeetupList[i].date!);
            String dateStr = DateFormat.yMMMMEEEEd().format(dateTime).split(' ')[0].split(',')[0];
            debugPrint('day -> $dateStr');
            debugPrint('day -> ${dateStr.substring(0, 3)}');
            allMeetupList[i].day = dateStr.substring(0, 3);
          }
        });
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          var item = allMeetupList.firstWhere((element) => convertToStringFromDate(element.date!) == convertDateTimeToString(_selectedDay!));
          int selectedDateIndex = allMeetupList.indexOf(item);

          itemScrollController.jumpTo(
            index: selectedDateIndex,
          );
        });
      }
    } on CommonException catch (error) {
      hideLoader();
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
      hideLoader();
      if (!mounted) return;
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      hideLoader();
      if (!mounted) return;
      showLog(error.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  Widget singleMeetupView(MeetupResponse allMeetupList, MeetUps model) {
    return SizedBox(
      height: 120.0,
      child: InkWell(
        onTap: () async {
          Navigator.of(context).pushNamed(Constants.meetupDetails, arguments: model);
        },
        child: Container(
          padding: const EdgeInsets.all(2.0),
          child: Card(
            semanticContainer: true,
            color: model.isCreator! ? const Color.fromRGBO(255, 250, 235, 1) : const Color.fromRGBO(234, 242, 246, 1),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            elevation: 4.0,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        elevation: 4.0,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(100))),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: CustomTextView(
                            label: model.date!.split('-')[2].split('T')[0],
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
                        label: allMeetupList.day,
                        textStyle: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontWeight: FontWeight.w500, fontSize: 16.0, color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
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
                        label: model.name,
                        maxLine: 2,
                        textOverFlow: TextOverflow.ellipsis,
                        textStyle:
                            Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w500, fontSize: 15.0, color: OQDOThemeData.greyColor),
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      CustomTextView(
                        label: '${model.startFrom} - ${model.endAt}',
                        textStyle:
                            Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 14.0, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
