import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/model/notification_response.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:oqdo_mobile_app/viewmodels/ProfileViewModel.dart';
import 'package:oqdo_mobile_app/viewmodels/notification_provider.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import '../../helper/helpers.dart';
import '../../main.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  MediaQueryData get dimensions => MediaQuery.of(context);
  final ScrollController _scrollController = ScrollController();

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  late Helper hp;
  TextEditingController search = TextEditingController();
  List<NotificationItem> notifications = [];
  bool isLoading = false;
  bool isMainLoading = false;
  int pageCount = 0;
  int resultPerPage = 20;
  int totalCount = 0;
  late ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    hp = Helper.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getNotification();
      _scrollController.addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          if (totalCount != notifications.length + 1) {
            getNotification();
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Notifications',
        onBack: () {
          Navigator.of(context).pop();
        },
        actions: [
          GestureDetector(
            onTap: notifications.length > 0
                ? () {
                    deleteAllNotification();
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Align(
                  alignment: Alignment.center,
                  child: CustomTextView(
                    label: 'Clear All',
                    textStyle: TextStyle(
                      color:
                          notifications.length > 0 ? Colors.red : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  )),
            ),
          )
        ],
      ),
      body: Container(
        width: width,
        height: height,
        color: Theme.of(context).colorScheme.onBackground,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: isMainLoading
              ? Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(
                        Theme.of(context).colorScheme.primary),
                  ),
                )
              : notifications.isNotEmpty
                  ? Stack(
                      children: [
                        ListView.separated(
                          // key: UniqueKey(),
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: _scrollController,
                          itemCount: notifications.length,
                          itemBuilder: (BuildContext context, int index) {
                            DateTime tempDate =
                                DateFormat("yyyy-MM-dd'T'hh:mm:ss").parse(
                                    notifications[index].validTill.toString());
                            String formattedDate =
                                DateFormat('yyyy-MM-dd').format(tempDate);

                            String time = DateFormat.jm().format(DateTime.parse(
                                notifications[index].validTill.toString()));

                            return GestureDetector(
                              onTap: () {
                                getNotificationData(
                                    notifications[index].deepLinkType ?? 0);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 6),
                                          child: CircleAvatar(
                                            radius: 4,
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Text(
                                            notifications[index]
                                                .notificationTemplateType
                                                .toString(),
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "$formattedDate $time",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black38,
                                              fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                16, 6, 16, 0),
                                            child: Text(
                                              notifications[index]
                                                  .content
                                                  .toString(),
                                              maxLines: 5,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w500),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            deleteSingleNotification(
                                                notifications[index]
                                                    .notificationHistoryId
                                                    .toString(),
                                                index);
                                          },
                                          child: Icon(
                                            Icons.delete_outline,
                                            size: 30,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return const Divider();
                          },
                        ),
                        isLoading
                            ? Align(
                                alignment: Alignment.bottomCenter,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                      Theme.of(context).colorScheme.primary),
                                ),
                              )
                            : const SizedBox(
                                width: 0,
                                height: 0,
                              ),
                      ],
                    )
                  : isLoading
                      ? Align(
                          alignment: Alignment.bottomCenter,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                                Theme.of(context).colorScheme.primary),
                          ),
                        )
                      : const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Text('No Notification Found!'),
                          ),
                        ),
        ),
      ),
    );
  }

  getNotificationData(int type) {
    if (type == 1) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
          Constants.APPPAGES, Helper.of(context).predicate,
          arguments: 0);
      debugPrint('redirect to Home');
    } else if (type == 2) {
      if (OQDOApplication.instance.isLogin == '1') {
        if (OQDOApplication.instance.userType == Constants.endUserType) {
          navigatorKey.currentState?.pushNamed(
              Constants.endUserAppointmentScreen,
              arguments: DateTime.now());
          debugPrint('redirect to Appointments');
        } else {
          if (OQDOApplication.instance.userType == Constants.facilityType) {
            navigatorKey.currentState?.pushNamed(
                Constants.facilityAppointmentScreen,
                arguments: DateTime.now());
            debugPrint('redirect to Appointments');
          } else {
            navigatorKey.currentState?.pushNamed(
                Constants.coachAppointmentScreen,
                arguments: DateTime.now());
            debugPrint('redirect to Appointments');
          }
        }
      }
    } else if (type == 3) {
      if (OQDOApplication.instance.isLogin == '1') {
        if (OQDOApplication.instance.userType == Constants.facilityType) {
          navigatorKey.currentState?.pushNamed(Constants.FACILITYSETUPPAGE);
          debugPrint('redirect to Setup');
        } else if (OQDOApplication.instance.userType == Constants.coachType) {
          navigatorKey.currentState?.pushNamed(Constants.BATCHSETUPLISTPAGE);
          debugPrint('redirect to Setup');
        }
      }
    } else if (type == 4) {
      if (OQDOApplication.instance.userType == Constants.endUserType) {
        if (OQDOApplication.instance.isLogin == '1') {
          navigatorKey.currentState?.pushNamed(Constants.myFriendsScreen);
          debugPrint('redirect to FriendList');
        }
      }
    } else if (type == 5) {
      if (OQDOApplication.instance.userType == Constants.endUserType) {
        if (OQDOApplication.instance.isLogin == '1') {
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
              Constants.APPPAGES, Helper.of(context).predicate,
              arguments: 3);
          debugPrint('redirect to chat');
        }
      }
    } else if (type == 6) {
      if (OQDOApplication.instance.userType == Constants.endUserType) {
        if (OQDOApplication.instance.isLogin == '1') {
          navigatorKey.currentState
              ?.pushNamed(Constants.listMeetup, arguments: DateTime.now());
          debugPrint('redirect to meetups');
        }
      }
    } else if (type == 7) {
      if (OQDOApplication.instance.isLogin == '1') {
        navigatorKey.currentState
            ?.pushNamed(Constants.bazaarHomeScreen, arguments: 3);
      }
    } else if (type == 8) {
      if (OQDOApplication.instance.isLogin == '1') {
        navigatorKey.currentState
            ?.pushNamed(Constants.bazaarHomeScreen, arguments: 1);
      }
    } else {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
          Constants.APPPAGES, Helper.of(context).predicate,
          arguments: 0);
      debugPrint('redirect to defualt');
    }
  }

  Future<void> getNotification() async {
    setState(() {
      isLoading = true;
      if (pageCount == 0) {
        isMainLoading = true;
      }
    });

    try {
      String requestStr = '';
      requestStr =
          'FilterParamsDto.PageStart=$pageCount&FilterParamsDto.ResultPerPage=$resultPerPage&FilterParamsDto.UserId=${OQDOApplication.instance.userID}';
      await Provider.of<ProfileViewModel>(context, listen: false)
          .getNotification(requestStr)
          .then(
        (value) async {
          Response res = value;
          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            if (!mounted) return;
            setState(() {
              isLoading = false;
              if (isMainLoading) {
                isMainLoading = false;
              }
            });
            showSnackBarErrorColor(
                AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            if (!mounted) return;
            NotificationResponse notificationResponse =
                NotificationResponse.fromJson(jsonDecode(res.body));
            if (notificationResponse.data != null &&
                notificationResponse.data!.isNotEmpty) {
              setState(() {
                isLoading = false;
                if (isMainLoading) {
                  isMainLoading = false;
                }
                notifications.addAll(notificationResponse.data!);
                totalCount = notificationResponse.totalCount!;
                pageCount = pageCount + 1;
              });
              Provider.of<NotificationProvider>(context, listen: false)
                  .updateStatus(false);
            } else {
              setState(() {
                isLoading = false;
                if (isMainLoading) {
                  isMainLoading = false;
                }
              });
            }
          } else {
            await _progressDialog.hide();
            if (!mounted) return;
            setState(() {
              isLoading = false;
              if (isMainLoading) {
                isMainLoading = false;
              }
            });
            Map<String, dynamic> errorModel = jsonDecode(res.body);
            if (errorModel.containsKey('ModelState')) {
              Map<String, dynamic> modelState = errorModel['ModelState'];
              if (modelState.containsKey('ErrorMessage')) {
                showSnackBarColor(modelState['ErrorMessage'][0], context, true);
              }
            }
          }
        },
      );
    } on NoConnectivityException catch (_) {
      await _progressDialog.hide();
      setState(() {
        isLoading = false;
        if (isMainLoading) {
          isMainLoading = false;
        }
      });
      if (!mounted) return;
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      await _progressDialog.hide();
      setState(() {
        isLoading = false;
        if (isMainLoading) {
          isMainLoading = false;
        }
      });
      if (!mounted) return;
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      await _progressDialog.hide();
      setState(() {
        isLoading = false;
        if (isMainLoading) {
          isMainLoading = false;
        }
      });
      if (!mounted) return;
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      await _progressDialog.hide();
      setState(() {
        isLoading = false;
        if (isMainLoading) {
          isMainLoading = false;
        }
      });
      if (!mounted) return;
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  Future<void> deleteSingleNotification(
      String notificationId, int index) async {
    _progressDialog = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");

    try {
      await _progressDialog.show();
      await Provider.of<ProfileViewModel>(context, listen: false)
          .deleteSingleNotification(notificationId)
          .then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(
                AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            await _progressDialog.hide();
            String list = res.body;
            if (list.isNotEmpty) {
              setState(() {
                notifications.removeAt(index);
                totalCount = totalCount - 2;
              });
              showSnackBarColor('Notification deleted', context, false);
              debugPrint('Notification Count -> ${notifications.length}');
              debugPrint('total Count -> $totalCount');
              // getNotification();
            }
          } else {
            await _progressDialog.hide();
            Map<String, dynamic> errorModel = jsonDecode(res.body);
            if (errorModel.containsKey('ModelState')) {
              Map<String, dynamic> modelState = errorModel['ModelState'];
              if (modelState.containsKey('ErrorMessage')) {
                showSnackBarColor(modelState['ErrorMessage'][0], context, true);
              }
            }
          }
        },
      );
    } on NoConnectivityException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      await _progressDialog.hide();
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  Future<void> deleteAllNotification() async {
    _progressDialog = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");

    try {
      await _progressDialog.show();
      await Provider.of<ProfileViewModel>(context, listen: false)
          .deleteAllNotifications(OQDOApplication.instance.userID!)
          .then(
        (value) async {
          Response res = value;
          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(
                AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            await _progressDialog.hide();
            String list = res.body;
            if (list.isNotEmpty) {
              showSnackBarColor('Notifications deleted', context, false);
              notifications.clear();
              setState(() {
                notifications.clear();
              });
              // getNotification();
            }
          } else {
            await _progressDialog.hide();
            Map<String, dynamic> errorModel = jsonDecode(res.body);
            if (errorModel.containsKey('ModelState')) {
              Map<String, dynamic> modelState = errorModel['ModelState'];
              if (modelState.containsKey('ErrorMessage')) {
                showSnackBarColor(modelState['ErrorMessage'][0], context, true);
              }
            }
          }
        },
      );
    } on NoConnectivityException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      await _progressDialog.hide();
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }
}
