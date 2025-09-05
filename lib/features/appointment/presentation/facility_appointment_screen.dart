// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
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
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:table_calendar/table_calendar.dart';

class FacilityAppointmentsScreen extends StatefulWidget {
  DateTime? dateTime;
  FacilityAppointmentsScreen({Key? key, this.dateTime}) : super(key: key);

  @override
  State<FacilityAppointmentsScreen> createState() => _FacilityAppointmentsScreenState();
}

class _FacilityAppointmentsScreenState extends State<FacilityAppointmentsScreen> {
  late ProgressDialog _progressDialog;
  List<FacilityAppointmentsResponseModel> _endUserAppointmentList = [];
  List<FacilityAppointmentsResponseModel> _endUserAppointmentResponseList = [];
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
  DateTime _focusedDay = DateTime.now();
  late String _currentDay;
  DateFormat format = DateFormat('d-MMMM-yyyy');
  DateTime? _selectedDayView;
  String initSelectedDate = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _selectedDay = widget.dateTime;
      _currentDay = format.format(_focusedDay);
      initSelectedDate = DateFormat.yMMMMEEEEd().format(_focusedDay).split(' ')[0].split(',')[0];
      getEndUserAppointments(widget.dateTime!);
      // itemPositionsListener.itemPositions.addListener(() {
      //   final indices = itemPositionsListener.itemPositions.value
      //       .where((element) {
      //         final isTopVisible = element.itemLeadingEdge >= 0;
      //         final isBottomvisible = element.itemTrailingEdge <= 1;
      //         return isTopVisible && isBottomvisible;
      //       })
      //       .map((item) => item.index)
      //       .toList();
      //   debugPrint(indices.toString());
      //   if (indices.isNotEmpty) {
      //     if (indices.last == _endUserAppointmentResponseList.length - 1) {
      //       String passingDate = convertToStringFromDate(_endUserAppointmentResponseList[indices.last].date!);
      //       getEndUserOtherAppointments(passingDate);
      //     }
      //   }
      //   debugPrint('First -> ${indices.first}');
      // });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: 'Appointments Management',
          onBack: () {
            Navigator.pop(context);
          }),
      body: SafeArea(
        child: Container(
          color: OQDOThemeData.whiteColor,
          width: MediaQuery.of(context).size.width,
          height: double.infinity,
          child: _endUserAppointmentResponseList.isNotEmpty
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
                        itemCount: _endUserAppointmentResponseList.length,
                        shrinkWrap: true,
                        itemScrollController: itemScrollController,
                        itemPositionsListener: itemPositionsListener,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          return Column(
                            key: ValueKey<String>(_endUserAppointmentResponseList[index].date!),
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
                                    label: _endUserAppointmentResponseList[index].date!.split('T')[0],
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(color: OQDOThemeData.whiteColor, fontSize: 18, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              _endUserAppointmentResponseList[index].appointmentListingSlotDtos!.isNotEmpty
                                  ? ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: _endUserAppointmentResponseList[index].appointmentListingSlotDtos!.length,
                                      itemBuilder: (BuildContext context, int subIndex) {
                                        if (_endUserAppointmentResponseList[index].appointmentListingSlotDtos!.isNotEmpty) {
                                          return singleDayEventView(subIndex, _endUserAppointmentResponseList[index].appointmentListingSlotDtos!,
                                              _endUserAppointmentResponseList[index]);
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

  Widget singleDayEventView(int index, List<FacilityAppointmentListingSlotDtos> data, FacilityAppointmentsResponseModel endUserAppointmentResponseList) {
    if (data.isNotEmpty) {
      return SizedBox(
        height: 120.0,
        child: GestureDetector(
          onTap: () async {
            if (data.isNotEmpty) {
              await Navigator.pushNamed(context, Constants.facilityAppointmentDetailScreen, arguments: data[index].bookingId.toString());
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
                          label: data[index].endUserName,
                          textStyle:
                              Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w500, fontSize: 18.0, color: OQDOThemeData.greyColor),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        CustomTextView(
                          label: data[index].setupName,
                          textStyle:
                              Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w500, fontSize: 16.0, color: OQDOThemeData.greyColor),
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
                      ? Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15, left: 5, right: 5),
                            child: CustomTextView(
                                label: 'Cancelled',
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(fontSize: 14.0, fontWeight: FontWeight.w700, color: OQDOThemeData.errorColor)),
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
                    int selectedDateIndex = _endUserAppointmentResponseList.indexOf(item);
                    scrollTo(selectedDateIndex);
                    // getEndUserAppointments(passingDate);
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
      monthChangeStr();
      var item = _endUserAppointmentResponseList.firstWhere((element) => convertToStringFromDate(element.date!) == convertDateTimeToString(_selectedDay!));
      int selectedDateIndex = _endUserAppointmentResponseList.indexOf(item);
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
      List<FacilityAppointmentsResponseModel> endUserAppointmentList = await Provider.of<AppointmentViewModel>(context, listen: false)
          .getFacilityProviderAppointments(OQDOApplication.instance.facilityID!, convertDateTimeToString(kPreviousDay), convertDateTimeToString(kLastDay));
      if (!mounted) return;
      await _progressDialog.hide();
      if (endUserAppointmentList.isNotEmpty) {
        setState(() {
          // _endUserAppointmentList.clear();
          // _endUserAppointmentResponseList.clear();
          var endUserSetList = <String>{};
          _endUserAppointmentList = endUserAppointmentList;
          _endUserAppointmentResponseList = _endUserAppointmentList.where((element) => endUserSetList.add(element.date!)).toList();
          monthStr = DateFormat.yMMMM().format(kToday).split(' ')[0];
          FacilityAppointmentsResponseModel firstDateOfAppointment = _endUserAppointmentResponseList.first;
          FacilityAppointmentsResponseModel lastDateOfAppointment = _endUserAppointmentResponseList.last;
          firstDate = DateTime.parse(firstDateOfAppointment.date!);
          debugPrint('First Date -> $firstDate');
          lastDate = DateTime.parse(lastDateOfAppointment.date!);
          debugPrint('Last Date -> $lastDate');
          for (int i = 0; i < _endUserAppointmentResponseList.length; i++) {
            DateTime dateTime = DateFormat('yyyy-MM-dd').parse(_endUserAppointmentResponseList[i].date!);
            String dateStr = DateFormat.yMMMMEEEEd().format(dateTime).split(' ')[0].split(',')[0];
            debugPrint('day -> $dateStr');
            debugPrint('day -> ${dateStr.substring(0, 3)}');
            _endUserAppointmentResponseList[i].day = dateStr.substring(0, 3);
          }
        });
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          var item = _endUserAppointmentResponseList.firstWhere((element) => convertToStringFromDate(element.date!) == convertDateTimeToString(_selectedDay!));
          int selectedDateIndex = _endUserAppointmentResponseList.indexOf(item);
          // scrollTo(selectedDateIndex);
          itemScrollController.jumpTo(
            index: selectedDateIndex,
            // duration: const Duration(milliseconds: 900),
            // curve: Curves.easeInOutCubic,
          );
          monthChangeStr();
        });
        // Timer(const Duration(seconds: 1), () {
        //   setState(() {

        //   });
        // });
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

  Future<void> getEndUserOtherAppointments(String passingDate) async {
    // _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    // _progressDialog.style(message: "Please wait..");
    try {
      // await _progressDialog.show();
      List<FacilityAppointmentsResponseModel> endUserAppointmentList = await Provider.of<AppointmentViewModel>(context, listen: false)
          .getFacilityProviderAppointments(OQDOApplication.instance.facilityID!, passingDate, convertDateTimeToString(kLastDay));
      if (!mounted) return;
      await _progressDialog.hide();
      if (endUserAppointmentList.isNotEmpty) {
        setState(() {
          var endUserSetList = <String>{};
          _endUserAppointmentList.addAll(endUserAppointmentList);
          _endUserAppointmentResponseList = _endUserAppointmentList.where((element) => endUserSetList.add(element.date!)).toList();
          FacilityAppointmentsResponseModel lastDateOfAppointment = _endUserAppointmentResponseList.last;
          lastDate = DateTime.parse(lastDateOfAppointment.date!);
          debugPrint('Last Date -> $lastDate');
          for (int i = 0; i < _endUserAppointmentResponseList.length; i++) {
            DateTime dateTime = DateFormat('yyyy-MM-dd').parse(_endUserAppointmentResponseList[i].date!);
            String dateStr = DateFormat.yMMMMEEEEd().format(dateTime).split(' ')[0].split(',')[0];
            debugPrint('day -> $dateStr');
            debugPrint('day -> ${dateStr.substring(0, 3)}');
            _endUserAppointmentResponseList[i].day = dateStr.substring(0, 3);
          }
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
      if (!mounted) return;
      // await _progressDialog.hide();
      debugPrint(error.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
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
                firstDay: kPreviousDay,
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
