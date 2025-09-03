import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/helper/helpers.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/meetups/data/meet_up_repository.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/meetups/data/meetup_response_model.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/textfields_widget.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class MeetupDetailsScreen extends StatefulWidget {
  MeetUps? meetupResponse;

  MeetupDetailsScreen({Key? key, this.meetupResponse}) : super(key: key);

  @override
  State<MeetupDetailsScreen> createState() => _MeetupDetailsScreenState();
}

class _MeetupDetailsScreenState extends State<MeetupDetailsScreen> {
  String day = '';
  late ProgressDialog _progressDialog;
  final TextEditingController _descriptionMeetupController = TextEditingController();
  bool isNotViewOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      DateTime dateTime = DateFormat('yyyy-MM-dd').parse(widget.meetupResponse!.date!);
      String dateStr = DateFormat.yMMMMEEEEd().format(dateTime).split(' ')[0].split(',')[0];
      var currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      if (widget.meetupResponse!.date!.split('T')[0].compareTo(currentDate) >= 0) {
        isNotViewOnly = true;
      } else {
        isNotViewOnly = false;
      }
      setState(() {
        day = dateStr.substring(0, 3);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: 'Meetup Details',
          onBack: () {
            Navigator.of(context).pop();
          }),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: OQDOThemeData.whiteColor,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20.0,
                ),
                appointmentData(),
                isNotViewOnly
                    ? !widget.meetupResponse!.isCreator!
                        ? widget.meetupResponse!.status == 'P' || widget.meetupResponse!.status == 'NA'
                            ? Column(
                                children: [
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SimpleButton(
                                          text: "Deny",
                                          textcolor: OQDOThemeData.buttonColor,
                                          textsize: 13,
                                          fontWeight: FontWeight.w600,
                                          letterspacing: 0.7,
                                          buttoncolor: OQDOThemeData.whiteColor,
                                          buttonbordercolor: OQDOThemeData.buttonColor,
                                          buttonheight: 50,
                                          buttonwidth: MediaQuery.of(context).size.width / 2,
                                          radius: 0,
                                          onTap: () async {
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return Dialog(
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)), //this right here
                                                    child: Container(
                                                      color: OQDOThemeData.whiteColor,
                                                      height: 300,
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(12.0),
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            CustomTextView(
                                                              label: 'Add Remarks',
                                                              textStyle: Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium!
                                                                  .copyWith(fontSize: 18, color: OQDOThemeData.blackColor, fontWeight: FontWeight.bold),
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            CustomTextFormField(
                                                              controller: _descriptionMeetupController,
                                                              read: false,
                                                              obscureText: false,
                                                              labelText: 'Add remarks for your selection',
                                                              maxlength: 250,
                                                              inputformat: [
                                                                FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9 _]+')),
                                                              ],
                                                              keyboardType: TextInputType.text,
                                                              maxlines: 4,
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: SimpleButton(
                                                                    text: "Cancel",
                                                                    textcolor: OQDOThemeData.buttonColor,
                                                                    textsize: 13,
                                                                    fontWeight: FontWeight.w600,
                                                                    letterspacing: 0.7,
                                                                    buttoncolor: OQDOThemeData.whiteColor,
                                                                    buttonbordercolor: OQDOThemeData.buttonColor,
                                                                    buttonheight: 50,
                                                                    buttonwidth: MediaQuery.of(context).size.width / 2,
                                                                    radius: 0,
                                                                    onTap: () async {
                                                                      Navigator.pop(context);
                                                                    },
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: SimpleButton(
                                                                    text: 'Send',
                                                                    textcolor: OQDOThemeData.whiteColor,
                                                                    textsize: 13,
                                                                    fontWeight: FontWeight.w600,
                                                                    letterspacing: 0.7,
                                                                    buttoncolor: OQDOThemeData.buttonColor,
                                                                    buttonbordercolor: OQDOThemeData.buttonColor,
                                                                    buttonheight: 50,
                                                                    buttonwidth: MediaQuery.of(context).size.width / 2,
                                                                    radius: 0,
                                                                    onTap: () async {
                                                                      Navigator.pop(context);
                                                                      acceptRejectMeetup('R', _descriptionMeetupController.text.toString().trim());
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                });
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: SimpleButton(
                                          text: 'Accept',
                                          textcolor: OQDOThemeData.whiteColor,
                                          textsize: 13,
                                          fontWeight: FontWeight.w600,
                                          letterspacing: 0.7,
                                          buttoncolor: OQDOThemeData.buttonColor,
                                          buttonbordercolor: OQDOThemeData.buttonColor,
                                          buttonheight: 50,
                                          buttonwidth: MediaQuery.of(context).size.width / 2,
                                          radius: 0,
                                          onTap: () async {
                                            acceptRejectMeetup('A', '');
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                ],
                              )
                            : const SizedBox(
                                height: 30,
                              )
                        : const SizedBox(
                            height: 30,
                          )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: CustomTextView(
                    label: 'Creator',
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18, color: const Color(0xff2B2B2B), fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: CustomTextView(
                    label: '${widget.meetupResponse!.firstName} ${widget.meetupResponse!.lastName}',
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, color: const Color(0xff2B2B2B), fontWeight: FontWeight.w400),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: CustomTextView(
                    label: 'Description',
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18, color: const Color(0xff2B2B2B), fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: CustomTextView(
                    label: widget.meetupResponse!.description,
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, color: const Color(0xff2B2B2B), fontWeight: FontWeight.w400),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: CustomTextView(
                    label: 'Meetup Details',
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18, color: const Color(0xff2B2B2B), fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      CustomTextView(
                        label: 'Date: ',
                        textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2B2B2B),
                              fontSize: 16,
                            ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      CustomTextView(
                        label: widget.meetupResponse!.date!.split('T')[0],
                        textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF2B2B2B),
                              fontSize: 16,
                            ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      CustomTextView(
                        label: 'Time: ',
                        textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2B2B2B),
                              fontSize: 16,
                            ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      CustomTextView(
                        label: '${widget.meetupResponse!.startFrom} - ${widget.meetupResponse!.endAt}',
                        textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF2B2B2B),
                              fontSize: 16,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: CustomTextView(
                    label: 'Friends',
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18, color: const Color(0xff2B2B2B), fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.meetupResponse!.meetUpFriends!.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return singleFriendsView(index);
                  },
                ),
                const SizedBox(
                  height: 40,
                ),
                isNotViewOnly
                    ? widget.meetupResponse!.isCreator!
                        ? Align(
                            alignment: Alignment.center,
                            child: SimpleButton(
                              text: "Cancel Meetup",
                              textcolor: OQDOThemeData.buttonColor,
                              textsize: 13,
                              fontWeight: FontWeight.w600,
                              letterspacing: 0.7,
                              buttoncolor: OQDOThemeData.whiteColor,
                              buttonbordercolor: OQDOThemeData.buttonColor,
                              buttonheight: 50,
                              buttonwidth: MediaQuery.of(context).size.width / 2,
                              radius: 0,
                              onTap: () async {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)), //this right here
                                        child: Container(
                                          color: OQDOThemeData.whiteColor,
                                          height: 300,
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                CustomTextView(
                                                  label: 'Add Remarks',
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(fontSize: 18, color: OQDOThemeData.blackColor, fontWeight: FontWeight.bold),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                CustomTextFormField(
                                                  controller: _descriptionMeetupController,
                                                  read: false,
                                                  obscureText: false,
                                                  labelText: 'Add remarks for your selection',
                                                  maxlength: 250,
                                                  inputformat: [
                                                    FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9 _]+')),
                                                  ],
                                                  keyboardType: TextInputType.text,
                                                  maxlines: 4,
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: SimpleButton(
                                                        text: "Cancel",
                                                        textcolor: OQDOThemeData.buttonColor,
                                                        textsize: 13,
                                                        fontWeight: FontWeight.w600,
                                                        letterspacing: 0.7,
                                                        buttoncolor: OQDOThemeData.whiteColor,
                                                        buttonbordercolor: OQDOThemeData.buttonColor,
                                                        buttonheight: 50,
                                                        buttonwidth: MediaQuery.of(context).size.width / 2,
                                                        radius: 0,
                                                        onTap: () async {
                                                          Navigator.pop(context);
                                                        },
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: SimpleButton(
                                                        text: 'Send',
                                                        textcolor: OQDOThemeData.whiteColor,
                                                        textsize: 13,
                                                        fontWeight: FontWeight.w600,
                                                        letterspacing: 0.7,
                                                        buttoncolor: OQDOThemeData.buttonColor,
                                                        buttonbordercolor: OQDOThemeData.buttonColor,
                                                        buttonheight: 50,
                                                        buttonwidth: MediaQuery.of(context).size.width / 2,
                                                        radius: 0,
                                                        onTap: () async {
                                                          Navigator.pop(context);
                                                          deleteMeetup(_descriptionMeetupController.text.toString().trim());
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    });
                              },
                            ),
                          )
                        : Container()
                    : Container(),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget appointmentData() {
    return SizedBox(
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
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 4.0,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(100))),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: CustomTextView(
                        label: widget.meetupResponse!.date!.split('-')[2].split('T')[0],
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
                    label: day,
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
              CustomTextView(
                label: widget.meetupResponse!.name,
                textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w500, fontSize: 18.0, color: OQDOThemeData.greyColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget singleFriendsView(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Row(
            children: [
              CustomTextView(
                label: '${widget.meetupResponse!.meetUpFriends![index].displayFirstName} ${widget.meetupResponse!.meetUpFriends![index].displayLastName}',
                textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, color: const Color(0xff2B2B2B), fontWeight: FontWeight.w400),
              ),
              const Spacer(),
              Image.asset(
                widget.meetupResponse!.meetUpFriends![index].status == 'P'
                    ? 'assets/images/ic_meetup_pending.png'
                    : widget.meetupResponse!.meetUpFriends![index].status == 'R'
                        ? 'assets/images/ic_meetup_rejected.png'
                        : 'assets/images/ic_meetup_accepted.png',
                height: 30,
                width: 30,
                fit: BoxFit.fill,
              ),
            ],
          ),
          const Divider(
            color: Color(0xFFCFCFCF),
          )
        ],
      ),
    );
  }

  Future<void> acceptRejectMeetup(String type, String remarks) async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    try {
      await _progressDialog.show();
      Map<String, dynamic> request = {};
      request['MeetUpFriendId'] = widget.meetupResponse!.meetUpFriendId;
      request['Status'] = type;
      request['Remarks'] = remarks;
      showLog('Request -> ${json.encode(request)}');
      var response = await Provider.of<MeetupRepository>(context, listen: false).acceptRejectRequest(request);
      showLog('$responseTag $response');
      await _progressDialog.hide();
      if (response.isNotEmpty) {
        if (type == 'A') {
          showSnackBarColor('Meetup accepted', context, false);
        } else {
          showSnackBarColor('Meetup rejected', context, false);
        }
        await Navigator.pushNamedAndRemoveUntil(context, Constants.APPPAGES, Helper.of(context).predicate, arguments: 0);
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

  Future<void> deleteMeetup(String remarks) async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    try {
      await _progressDialog.show();
      Map<String, dynamic> request = {};
      request['MeetUpId'] = widget.meetupResponse!.meetUpId;
      request['EndUserId'] = OQDOApplication.instance.endUserID;
      request['Remarks'] = remarks;
      showLog('Request -> ${json.encode(request)}');
      var response = await Provider.of<MeetupRepository>(context, listen: false).deleteMeetup(request);
      showLog('$responseTag $response');
      await _progressDialog.hide();
      if (response.isNotEmpty) {
        showSnackBarColor('Meetup deleted', context, false);
        await Navigator.pushNamedAndRemoveUntil(context, Constants.APPPAGES, Helper.of(context).predicate, arguments: 0);
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
