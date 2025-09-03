import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/meetups/data/friend_list_repsonse_model.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/meetups/data/meet_up_repository.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/textfields_widget.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:oqdo_mobile_app/utils/validator.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class AddMeetupScreen extends StatefulWidget {
  const AddMeetupScreen({Key? key}) : super(key: key);

  @override
  State<AddMeetupScreen> createState() => _AddMeetupScreenState();
}

class _AddMeetupScreenState extends State<AddMeetupScreen> {
  final TextEditingController _fullMeetupNameController = TextEditingController();
  final TextEditingController _descriptionMeetupController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime todayDate = DateTime.now();
  DateTime selectedDate = DateTime.now();
  TextEditingController hourFirstFromTime = TextEditingController();
  TextEditingController hourSecondFromTime = TextEditingController();
  TextEditingController minuteFirstFromTime = TextEditingController();
  TextEditingController minuteSecondFromTime = TextEditingController();
  TextEditingController hourFirstToTime = TextEditingController();
  TextEditingController hourSecondToTime = TextEditingController();
  TextEditingController minuteFirstToTime = TextEditingController();
  TextEditingController minuteSecondToTime = TextEditingController();
  int startTimeInMinutes = 0;
  int endTimeInMinutes = 0;
  late ProgressDialog _progressDialog;
  List<FrindListResponse> friendList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getFriendList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: 'Add Meetup',
          onBack: () {
            Navigator.of(context).pop();
          }),
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: OQDOThemeData.whiteColor,
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                CustomTextFormField(
                  controller: _fullMeetupNameController,
                  read: false,
                  obscureText: false,
                  labelText: 'Full Name',
                  maxlength: 50,
                  maxlines: 1,
                  inputformat: [
                    FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9 ]+')),
                  ],
                  validator: Validator.notEmpty,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomTextFormField(
                  controller: _descriptionMeetupController,
                  read: false,
                  obscureText: false,
                  labelText: 'Description',
                  validator: Validator.notEmpty,
                  maxlength: 250,
                  // inputformat: [
                  //   FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9 _]+')),
                  // ],
                  keyboardType: TextInputType.text,
                  maxlines: 4,
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    _selectDate(context);
                  },
                  child: CustomTextFormField(
                    controller: _dateController,
                    read: true,
                    obscureText: false,
                    labelText: 'Date',
                    maxlines: 1,
                    suffixIcon: IconButton(
                      onPressed: () {
                        _selectDate(context);
                      },
                      icon: Image.asset('assets/images/ic_calendar_image.png'),
                      iconSize: 20,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomTextView(
                  label: 'Start Time',
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 70,
                          child: TextField(
                            readOnly: true,
                            autofocus: false,
                            controller: hourFirstFromTime,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: '0',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        SizedBox(
                          width: 70,
                          child: TextField(
                            readOnly: true,
                            autofocus: false,
                            controller: hourSecondFromTime,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: '0',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        CustomTextView(
                          label: ":",
                          type: styleSubTitle,
                          textStyle: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        SizedBox(
                          width: 70,
                          child: TextField(
                            readOnly: true,
                            autofocus: false,
                            controller: minuteFirstFromTime,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: '0',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        SizedBox(
                          width: 70,
                          child: TextField(
                            readOnly: true,
                            autofocus: false,
                            controller: minuteSecondFromTime,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: '0',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          initialTime: TimeOfDay.now(),
                          builder: (BuildContext context, Widget? child) {
                            return MediaQuery(
                              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                              child: child!,
                            );
                          },
                          context: context,
                        );
                        if (pickedTime != null) {
                          String selectedDayStr = DateFormat('yyyy-MM-dd').format(selectedDate);
                          debugPrint('formated selected date -> $selectedDayStr');

                          String currentDate = DateFormat('yyyy-MM-dd').format(kToday);
                          debugPrint('Current Date -> $currentDate');

                          setState(() {
                            double nowHoursData = TimeOfDay.now().hour * 60;
                            showLog('final nowHoursData -> $nowHoursData');
                            double nowMinutesData = nowHoursData + TimeOfDay.now().minute;
                            showLog('final hournowMinutesDatas -> $nowMinutesData');
                            double hoursData = pickedTime.hour * 60;
                            showLog('final hours -> $hoursData');
                            double minutesData = hoursData + pickedTime.minute;
                            if (selectedDayStr.compareTo(currentDate) == 0) {
                              if (minutesData < nowMinutesData) {
                                startTimeInMinutes = 0;
                                hourFirstFromTime.text = '';
                                hourSecondFromTime.text = '';
                                minuteFirstFromTime.text = '';
                                minuteSecondFromTime.text = '';
                                showSnackBar('Please select greater time from current time', context);
                              } else {
                                showLog('$pickedTime');
                                String hoursStr = pickedTime.hour.toString();
                                showLog('Hours -> $hoursStr');
                                String minutesStr = pickedTime.minute.toString();
                                showLog('minutes -> $minutesStr');

                                String convertedHour = hoursStr.padLeft(2, '0');
                                String convertedMinute = minutesStr.padLeft(2, '0');
                                showLog('convertedHour -> $convertedHour');
                                showLog('convertedMinute -> $convertedMinute');

                                hourFirstFromTime.text = convertedHour[0];
                                hourSecondFromTime.text = convertedHour[1];
                                minuteFirstFromTime.text = convertedMinute[0];
                                minuteSecondFromTime.text = convertedMinute[1];
                                double hoursData = pickedTime.hour * 60;
                                showLog('final hours -> $hoursData');
                                double minutesData = hoursData + pickedTime.minute;
                                showLog('final minutes -> $minutesData');
                                startTimeInMinutes = minutesData.round();
                                showLog('final minutes int-> $startTimeInMinutes');
                              }
                            } else {
                              showLog('$pickedTime');
                              String hoursStr = pickedTime.hour.toString();
                              showLog('Hours -> $hoursStr');
                              String minutesStr = pickedTime.minute.toString();
                              showLog('minutes -> $minutesStr');

                              String convertedHour = hoursStr.padLeft(2, '0');
                              String convertedMinute = minutesStr.padLeft(2, '0');
                              showLog('convertedHour -> $convertedHour');
                              showLog('convertedMinute -> $convertedMinute');

                              hourFirstFromTime.text = convertedHour[0];
                              hourSecondFromTime.text = convertedHour[1];
                              minuteFirstFromTime.text = convertedMinute[0];
                              minuteSecondFromTime.text = convertedMinute[1];
                              double hoursData = pickedTime.hour * 60;
                              showLog('final hours -> $hoursData');
                              double minutesData = hoursData + pickedTime.minute;
                              showLog('final minutes -> $minutesData');
                              startTimeInMinutes = minutesData.round();
                              showLog('final minutes int-> $startTimeInMinutes');
                            }
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
                        child: Image.asset(
                          "assets/images/pick_time.png",
                          height: 40,
                          width: 40,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomTextView(
                  label: 'End Time',
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 70,
                          child: TextField(
                            readOnly: true,
                            autofocus: false,
                            controller: hourFirstToTime,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: '0',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        SizedBox(
                          width: 70,
                          child: TextField(
                            readOnly: true,
                            autofocus: false,
                            controller: hourSecondToTime,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: '0',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        CustomTextView(
                          label: ":",
                          type: styleSubTitle,
                          textStyle: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        SizedBox(
                          width: 70,
                          child: TextField(
                            readOnly: true,
                            autofocus: false,
                            controller: minuteFirstToTime,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: '0',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        SizedBox(
                          width: 70,
                          child: TextField(
                            readOnly: true,
                            autofocus: false,
                            controller: minuteSecondToTime,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: '0',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (startTimeInMinutes > 0) {
                          TimeOfDay? pickedTime = await showTimePicker(
                            initialTime: TimeOfDay.now(),
                            builder: (BuildContext context, Widget? child) {
                              return MediaQuery(
                                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                child: child!,
                              );
                            },
                            context: context,
                          );
                          if (pickedTime != null) {
                            setState(() {
                              showLog('$pickedTime');
                              double hoursData = pickedTime.hour * 60;
                              showLog('final hours -> $hoursData');
                              double minutesData = hoursData + pickedTime.minute;
                              showLog('final minutes -> $minutesData');
                              endTimeInMinutes = minutesData.round();
                              showLog('final end time minutes int-> $endTimeInMinutes');
                              if (endTimeInMinutes <= startTimeInMinutes) {
                                endTimeInMinutes = 0;
                                hourFirstToTime.text = '';
                                hourSecondToTime.text = '';
                                minuteFirstToTime.text = '';
                                minuteSecondToTime.text = '';
                                showSnackBar('End time greater than start time', context);
                              } else {
                                String hoursStr = pickedTime.hour.toString();
                                showLog('Hours -> $hoursStr');
                                String minutesStr = pickedTime.minute.toString();
                                showLog('minutes -> $minutesStr');

                                String convertedHour = hoursStr.padLeft(2, '0');
                                String convertedMinute = minutesStr.padLeft(2, '0');
                                showLog('convertedHour -> $convertedHour');
                                showLog('convertedMinute -> $convertedMinute');

                                hourFirstToTime.text = convertedHour[0];
                                hourSecondToTime.text = convertedHour[1];
                                minuteFirstToTime.text = convertedMinute[0];
                                minuteSecondToTime.text = convertedMinute[1];
                              }
                            });
                          }
                        } else {
                          showSnackBar('Please select start time first', context);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
                        child: Image.asset(
                          "assets/images/pick_time.png",
                          height: 40,
                          width: 40,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                CustomTextView(
                  label: 'Add Friends',
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16, color: const Color(0xFF818181), fontWeight: FontWeight.w400),
                ),
                const SizedBox(
                  height: 10,
                ),
                ListView.separated(
                  separatorBuilder: (context, index) => const Divider(
                    color: OQDOThemeData.greyColor,
                    height: 1,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: friendList.length,
                  itemBuilder: (context, index) {
                    var model = friendList[index];
                    return singleFriendSelectionView(model);
                  },
                ),
                const SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: MyButton(
                    text: 'Submit',
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
                      if (_fullMeetupNameController.text.toString().trim().isEmpty) {
                        showSnackBar('Full name required', context);
                      } else if (_descriptionMeetupController.text.toString().trim().isEmpty) {
                        showSnackBar('Description required', context);
                      } else if (_dateController.text.toString().trim().isEmpty) {
                        showSnackBar('Please select date', context);
                      } else if (startTimeInMinutes <= 0) {
                        showSnackBar('Please select start time', context);
                      } else if (endTimeInMinutes <= 0) {
                        showSnackBar('Please select end time', context);
                      } else if (!isAnyFriendSelected()) {
                        showSnackBar('Please select friends', context);
                      } else {
                        addMeetup();
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget singleFriendSelectionView(FrindListResponse frindListResponse) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Transform.scale(
          scale: 1.3,
          child: Checkbox(
              fillColor: MaterialStateProperty.resolveWith(Utils.getColor),
              checkColor: Theme.of(context).colorScheme.primaryContainer,
              value: frindListResponse.isSelected,
              onChanged: (value) {
                setState(() {
                  frindListResponse.isSelected = value;
                });
              }),
        ),
        const SizedBox(
          width: 15.0,
        ),
        Flexible(
          child: CustomTextView(
            label: '${frindListResponse.firstName} ${frindListResponse.lastName}',
            maxLine: 2,
            textOverFlow: TextOverflow.ellipsis,
            textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 18.0, fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor),
          ),
        ),
      ],
    );
  }

  bool isAnyFriendSelected() {
    bool isFriendSelected = false;
    for (var i = 0; i < friendList.length; i++) {
      if (friendList[i].isSelected!) {
        isFriendSelected = true;
        break;
      }
    }
    return isFriendSelected;
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: todayDate,
      firstDate: todayDate,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      lastDate: DateTime(todayDate.year, todayDate.month, todayDate.day + 89),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        startTimeInMinutes = 0;
        endTimeInMinutes = 0;
        selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
        hourFirstFromTime.text = '';
        hourSecondFromTime.text = '';
        minuteFirstFromTime.text = '';
        minuteSecondFromTime.text = '';
        hourFirstToTime.text = '';
        hourSecondToTime.text = '';
        minuteFirstToTime.text = '';
        minuteSecondToTime.text = '';
      });
    }
  }

  Future<void> getFriendList() async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    try {
      await _progressDialog.show();
      var response = await Provider.of<MeetupRepository>(context, listen: false).getFriendList();
      showLog('$responseTag $response');
      await _progressDialog.hide();
      if (response.data!.isNotEmpty) {
        setState(() {
          friendList.addAll(response.data!);
          for (int i = 0; i < friendList.length; i++) {
            friendList[i].isSelected = false;
          }
        });
      }
    } on CommonException catch (error) {
      await _progressDialog.hide();
      showLog('$error');
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
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      await _progressDialog.hide();
      showLog(error.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  Future<void> addMeetup() async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    try {
      await _progressDialog.show();
      Map<String, dynamic> request = {};
      request['Name'] = _fullMeetupNameController.text.toString().trim();
      request['EndUserId'] = OQDOApplication.instance.endUserID;
      request['Description'] = _descriptionMeetupController.text.toString().trim();
      request['Date'] = _dateController.text.toString().trim();
      request['IsActive'] = true;
      request['EndTimeMinutes'] = endTimeInMinutes;
      request['StatTimeMinutes'] = startTimeInMinutes;

      List<Map> listMap = [];
      for (var i = 0; i < friendList.length; i++) {
        if (friendList[i].isSelected!) {
          Map map = {};
          map['FriendId'] = friendList[i].friendId;
          map['IsActive'] = true;
          listMap.add(map);
        }
      }
      request['MeetUpFriendDtos'] = listMap;

      showLog('Request -> ${json.encode(request)}');

      var response = await Provider.of<MeetupRepository>(context, listen: false).addMeetup(request);
      showLog('$responseTag $response');
      await _progressDialog.hide();
      if (response.isNotEmpty) {
        showSnackBarColor('Meetup created', context, false);
        // await Navigator.pushNamedAndRemoveUntil(context, Constants.APPPAGES, Helper.of(context).predicate,
        //     arguments: 0);
        Navigator.pop(context, true);
      }
    } on CommonException catch (error) {
      await _progressDialog.hide();
      showLog('$error');
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
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      await _progressDialog.hide();
      showLog(error.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }
}
