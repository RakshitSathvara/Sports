// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:math' as math;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/helper/helpers.dart';
import 'package:oqdo_mobile_app/main.dart';
import 'package:oqdo_mobile_app/model/coach_profile_response.dart';
import 'package:oqdo_mobile_app/model/end_user_profile_response.dart';
import 'package:oqdo_mobile_app/model/facility_profile_response.dart';
import 'package:oqdo_mobile_app/model/selecte_home_model.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/get_all_buddies_repository.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/domain/chat_provider.dart';
import 'package:oqdo_mobile_app/screens/cancellation%20request/coach_cancellation_request_page.dart';
import 'package:oqdo_mobile_app/screens/cancellation%20request/facility_cancellation_request_page.dart';
import 'package:oqdo_mobile_app/screens/home/conversation_screen.dart';
import 'package:oqdo_mobile_app/screens/home/end_user_calendar_screen.dart';
import 'package:oqdo_mobile_app/screens/home/homepage.dart';
import 'package:oqdo_mobile_app/screens/home/service_provider_calendar_screen.dart';
import 'package:oqdo_mobile_app/screens/profile/coach_profile.dart';
import 'package:oqdo_mobile_app/screens/profile/facility_profile.dart';
import 'package:oqdo_mobile_app/screens/profile/learner_profile.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/ConnectivityService.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/extentions.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:oqdo_mobile_app/viewmodels/DashboardViewModel.dart';
import 'package:oqdo_mobile_app/viewmodels/appointment_view_model.dart';
import 'package:oqdo_mobile_app/viewmodels/notification_provider.dart';
import 'package:oqdo_mobile_app/viewmodels/service_providers_cancellation_view_model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:oqdo_mobile_app/widgets/theme_toggle_widgets.dart';

// import 'package:signalr_flutter/signalr_api.dart';
// import 'package:signalr_flutter/signalr_flutter.dart';

import '../../viewmodels/ProfileViewModel.dart';

class DashboardPages extends StatefulWidget {
  final int tabNumber;

  const DashboardPages({Key? key, required this.tabNumber}) : super(key: key);

  @override
  DashboardPagesState createState() => DashboardPagesState();
}

class DashboardPagesState extends State<DashboardPages> with SingleTickerProviderStateMixin {
  late int index;
  late Widget page;
  late DateTime currentBackPressTime;
  bool isPageSet = false;
  String signalRStatus = "disconnected";

  // late SignalR signalR;

  // bool isLogin = true;

  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  String? isLogin = '0';
  late ProgressDialog _progressDialog;
  String? firstName = '';
  String? emailId = '';
  String? profilePicPath = '';
  late CoachProfileResponseModel coachProfileResponseModel;
  static late StreamSubscription<List<ConnectivityResult>> _subscription;

  final NetworkConnectivity _networkConnectivity = NetworkConnectivity.instance;
  String string = '';
  PackageInfo? packageInfo;

  // bool _isMenuOpen = false;

  bool _isFabOpen = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    setInternetConnectivityListner(context);
    OQDOApplication.instance.isAppIsInBackground = 1;
    // getNotificationData();

    setState(() {
      index = widget.tabNumber;
    });

    selectTab(index);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      coachProfileResponseModel = CoachProfileResponseModel();
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(message: "Please wait..");
      getNotificationData();
    });
    getData();

    debugPrint('${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}');

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // setInternetConnectivityListner(context);
  }

  getNotificationData() {
    OneSignal.Notifications.addClickListener((OSNotificationClickEvent result) async {
      // _lastNotificationId = result.notification.notificationId;

      if (OQDOApplication.instance.lastNotificationId == result.notification.notificationId) {
        return;
      } else {
        OQDOApplication.instance.lastNotificationId = result.notification.notificationId;
        print('notification addForegroundWillDisplayListener');
        var additionalData = result.notification.additionalData;
        debugPrint('type -> ${additionalData?['type'].toString()}');

        // Only handle notification navigation if the app is in background
        // This prevents duplicate navigation actions
        // if (OQDOApplication.instance.isAppIsInBackground != 1) {
        //   return;
        // }

        // App is in background, handle navigation
        isLogin = OQDOApplication.instance.storage.getStringValue(AppStrings.isLogin);

        debugPrint('isLogin -> ${OQDOApplication.instance.isLogin}');
        debugPrint('type -> ${additionalData?['type'].toString()}');
        debugPrint('user type -> ${OQDOApplication.instance.userType}');

        if (additionalData != null && additionalData.containsKey('type')) {
          String type = additionalData['type'].toString();

          // Handle navigation based on notification type
          switch (type) {
            case "1":
              // Home
              navigatorKey.currentState?.pushNamedAndRemoveUntil(Constants.APPPAGES, Helper.of(context).predicate, arguments: 0);
              debugPrint('redirect to Home');
              break;

            case "2":
              // Appointments
              if (OQDOApplication.instance.isLogin == '1') {
                if (OQDOApplication.instance.userType == Constants.endUserType) {
                  navigatorKey.currentState?.pushNamed(Constants.endUserAppointmentScreen, arguments: DateTime.now());
                } else if (OQDOApplication.instance.userType == Constants.facilityType) {
                  navigatorKey.currentState?.pushNamed(Constants.facilityAppointmentScreen, arguments: DateTime.now());
                } else {
                  navigatorKey.currentState?.pushNamed(Constants.coachAppointmentScreen, arguments: DateTime.now());
                }
                debugPrint('redirect to Appointments');
              }
              break;

            case "3":
              // Setup
              if (OQDOApplication.instance.isLogin == '1') {
                if (OQDOApplication.instance.userType == Constants.facilityType) {
                  navigatorKey.currentState?.pushNamed(Constants.FACILITYSETUPPAGE);
                } else if (OQDOApplication.instance.userType == Constants.coachType) {
                  navigatorKey.currentState?.pushNamed(Constants.BATCHSETUPLISTPAGE);
                }
              }
              break;

            case "4":
              // FriendList
              if (OQDOApplication.instance.userType == Constants.endUserType && OQDOApplication.instance.isLogin == '1') {
                navigatorKey.currentState?.pushNamed(Constants.myFriendsScreen);
              }
              break;

            case "5":
              // Chat
              if (OQDOApplication.instance.userType == Constants.endUserType && OQDOApplication.instance.isLogin == '1') {
                navigatorKey.currentState?.pushNamedAndRemoveUntil(Constants.APPPAGES, Helper.of(context).predicate, arguments: 3);
              }
              break;

            case "6":
              // Meetups
              if (OQDOApplication.instance.userType == Constants.endUserType && OQDOApplication.instance.isLogin == '1') {
                navigatorKey.currentState?.pushNamed(Constants.listMeetup, arguments: DateTime.now());
              }
              break;

            case "7":
              // Bazaar home screen with arg 3
              if (OQDOApplication.instance.isLogin == "1") {
                navigatorKey.currentState?.pushNamed(Constants.bazaarHomeScreen, arguments: 3);
              }
              break;

            case "8":
              // Bazaar home screen with arg 1
              if (OQDOApplication.instance.isLogin == "1") {
                navigatorKey.currentState?.pushNamed(Constants.bazaarHomeScreen, arguments: 1);
              }
              break;

            default:
              // Default to home page
              navigatorKey.currentState?.pushNamedAndRemoveUntil(Constants.APPPAGES, Helper.of(context).predicate, arguments: 0);
              debugPrint('redirect to default');
              break;
          }
        }
      }
    });
  }

  // getNotificationData() {
  //   OneSignal.Notifications.addClickListener((OSNotificationClickEvent result) async {
  //     var additionalData = result.notification.additionalData;
  //     debugPrint('type -> ${additionalData?['type'].toString()}');
  //     if (OQDOApplication.instance.isAppIsInBackground != 1) {
  //       navigatorKey.currentState?.pushNamedAndRemoveUntil(Constants.APPPAGES, Helper.of(context).predicate, arguments: 0);
  //     } else {
  //       isLogin = OQDOApplication.instance.storage.getStringValue(AppStrings.isLogin);

  //       var additionalData = result.notification.additionalData;
  //       debugPrint('isLogin -> ${OQDOApplication.instance.isLogin}');
  //       debugPrint('type -> ${additionalData?['type'].toString()}');
  //       debugPrint('user type -> ${OQDOApplication.instance.userType}');
  //       if (additionalData != null) {
  //         if (additionalData.containsKey('type')) {
  //           String type = additionalData['type'].toString();
  //           if (type == "1") {
  //             navigatorKey.currentState?.pushNamedAndRemoveUntil(Constants.APPPAGES, Helper.of(context).predicate, arguments: 0);
  //             debugPrint('redirect to Home');
  //           } else if (type == "2") {
  //             if (OQDOApplication.instance.isLogin == '1') {
  //               if (OQDOApplication.instance.userType == Constants.endUserType) {
  //                 navigatorKey.currentState?.pushNamed(Constants.endUserAppointmentScreen, arguments: DateTime.now());
  //                 debugPrint('redirect to Appointments');
  //               } else {
  //                 if (OQDOApplication.instance.userType == Constants.facilityType) {
  //                   navigatorKey.currentState?.pushNamed(Constants.facilityAppointmentScreen, arguments: DateTime.now());
  //                   debugPrint('redirect to Appointments');
  //                 } else {
  //                   navigatorKey.currentState?.pushNamed(Constants.coachAppointmentScreen, arguments: DateTime.now());
  //                   debugPrint('redirect to Appointments');
  //                 }
  //               }
  //             }
  //           } else if (type == "3") {
  //             if (OQDOApplication.instance.isLogin == '1') {
  //               if (OQDOApplication.instance.userType == Constants.facilityType) {
  //                 navigatorKey.currentState?.pushNamed(Constants.FACILITYSETUPPAGE);
  //                 debugPrint('redirect to Setup');
  //               } else if (OQDOApplication.instance.userType == Constants.coachType) {
  //                 navigatorKey.currentState?.pushNamed(Constants.BATCHSETUPLISTPAGE);
  //                 debugPrint('redirect to Setup');
  //               }
  //             }
  //           } else if (type == "4") {
  //             if (OQDOApplication.instance.userType == Constants.endUserType) {
  //               if (OQDOApplication.instance.isLogin == '1') {
  //                 navigatorKey.currentState?.pushNamed(Constants.myFriendsScreen);
  //                 debugPrint('redirect to FriendList');
  //               }
  //             }
  //           } else if (type == "5") {
  //             if (OQDOApplication.instance.userType == Constants.endUserType) {
  //               if (OQDOApplication.instance.isLogin == '1') {
  //                 navigatorKey.currentState?.pushNamedAndRemoveUntil(Constants.APPPAGES, Helper.of(context).predicate, arguments: 3);
  //                 debugPrint('redirect to chat');
  //               }
  //             }
  //           } else if (type == "6") {
  //             if (OQDOApplication.instance.userType == Constants.endUserType) {
  //               if (OQDOApplication.instance.isLogin == '1') {
  //                 navigatorKey.currentState?.pushNamed(Constants.listMeetup, arguments: DateTime.now());
  //                 debugPrint('redirect to meetups');
  //               }
  //             }
  //           }
  //           else if(type == "7"){
  //             if(OQDOApplication.instance.isLogin == "1"){
  //               navigatorKey.currentState?.pushNamed(Constants.bazaarHomeScreen, arguments: 3);
  //             }
  //           }
  //           else if(type == "8"){
  //             if(OQDOApplication.instance.isLogin == "1"){
  //               navigatorKey.currentState?.pushNamed(Constants.bazaarHomeScreen, arguments: 1);
  //             }
  //           }
  //           else {
  //             navigatorKey.currentState?.pushNamedAndRemoveUntil(Constants.APPPAGES, Helper.of(context).predicate, arguments: 0);
  //             debugPrint('redirect to defualt');
  //           }
  //         }
  //       }
  //     }
  //   });
  // }

  void setInternetConnectivityListner(mContext) {
    _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      if (result.contains(ConnectivityResult.none)) {
        showNoInternetConnectionSnackBar();
      } else {
        dismissNoInternetConnectionSnackBar();
      }
    });
  }

  Future<void> dialogOpen(BuildContext mContext) {
    return showDialog(
      context: mContext,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.network_check_rounded,
                color: Theme.of(mContext).colorScheme.error,
                size: 100.0,
              ),
              const SizedBox(height: 10.0),
              CustomTextView(
                maxLine: 4,
                textOverFlow: TextOverflow.ellipsis,
                label: "Slow or No Internet.",
                textStyle: Theme.of(mContext).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(mContext).colorScheme.onSurface,
                      fontSize: 20,
                    ),
              ),
              const SizedBox(height: 10.0),
              Text(
                "Please check your internet settings",
                textAlign: TextAlign.center,
                maxLines: 4,
                style: Theme.of(mContext).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(mContext).colorScheme.onSurface,
                      fontSize: 16,
                    ),
              ),
              const SizedBox(height: 20.0),
              MyButton(
                text: 'Retry',
                textcolor: Theme.of(mContext).colorScheme.onBackground,
                textsize: 14,
                fontWeight: FontWeight.w500,
                letterspacing: 0.7,
                buttoncolor: Theme.of(mContext).colorScheme.secondaryContainer,
                buttonbordercolor: Theme.of(mContext).colorScheme.secondaryContainer,
                buttonheight: 40.0,
                buttonwidth: 100,
                radius: 15,
                onTap: () async {
                  Navigator.pop(mContext);
                  checkInternetConnectivity(mContext);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> checkInternetConnectivity(mContext) async {
    bool isConnected = await ConnectivityService.isInternetConnected();
    debugPrint("connected $isConnected");
    if (isConnected) {
      debugPrint("connected 1$isConnected");
      await Navigator.pushNamedAndRemoveUntil(mContext, Constants.APPPAGES, Helper.of(mContext).predicate, arguments: 0);
    } else {
      showDialog(
        context: mContext,
        barrierDismissible: false,
        builder: (_) => WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.network_check_rounded,
                  color: Theme.of(mContext).colorScheme.error,
                  size: 100.0,
                ),
                const SizedBox(height: 10.0),
                CustomTextView(
                  maxLine: 4,
                  textOverFlow: TextOverflow.ellipsis,
                  label: "Slow or No Internet.",
                  textStyle: Theme.of(mContext).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(mContext).colorScheme.onSurface,
                        fontSize: 20,
                      ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  "Please check your internet settings",
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  style: Theme.of(mContext).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(mContext).colorScheme.onSurface,
                        fontSize: 16,
                      ),
                ),
                const SizedBox(height: 20.0),
                MyButton(
                  text: 'Retry',
                  textcolor: Theme.of(mContext).colorScheme.onBackground,
                  textsize: 14,
                  fontWeight: FontWeight.w500,
                  letterspacing: 0.7,
                  buttoncolor: Theme.of(mContext).colorScheme.secondaryContainer,
                  buttonbordercolor: Theme.of(mContext).colorScheme.secondaryContainer,
                  buttonheight: 40.0,
                  buttonwidth: 100,
                  radius: 15,
                  onTap: () async {
                    debugPrint("Click ->");
                    Navigator.pop(mContext);
                    await checkInternetConnectivity(mContext);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void getData() async {
    isLogin = OQDOApplication.instance.storage.getStringValue(AppStrings.isLogin);
    debugPrint("isLogin -> $isLogin");
    if (isLogin == '1') {
      OQDOApplication.instance.userType = OQDOApplication.instance.storage.getStringValue(AppStrings.userType);
      OQDOApplication.instance.isLogin = OQDOApplication.instance.storage.getStringValue(AppStrings.isLogin);
      OQDOApplication.instance.endUserID = OQDOApplication.instance.storage.getStringValue(AppStrings.endUserId);
      OQDOApplication.instance.coachID = OQDOApplication.instance.storage.getStringValue(AppStrings.coachId);
      OQDOApplication.instance.facilityID = OQDOApplication.instance.storage.getStringValue(AppStrings.facilityId);
      OQDOApplication.instance.userID = OQDOApplication.instance.storage.getStringValue(AppStrings.userId);

      checkForUser();
    }

    packageInfo = await PackageInfo.fromPlatform();
    setState(() {});
    // version = packageInfo.version;
  }

  void checkForUser() async {
    if (await hasNetwork()) {
      if (OQDOApplication.instance.userType == Constants.endUserType) {
        await getEndUserData();
      } else if (OQDOApplication.instance.userType == Constants.facilityType) {
        await getFacilityUserData();
      } else {
        await getCoachUserData();
      }
    } else {
      dialogOpen(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        _onWillPop();
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              _scaffoldKey.currentState!.openDrawer();
            },
            icon: ImageIcon(
              const AssetImage("assets/images/menu_icon.png"),
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.background,
          title: Text(
            "oqdo",
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 20.0),
          ),
          centerTitle: true,
          actions: [
            const ThemeToggleButton(),
            (isLogin != '1')
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    child: MyButton(
                      text: 'Login',
                      textcolor: Theme.of(context).colorScheme.onSecondary,
                      textsize: 14,
                      fontWeight: FontWeight.w400,
                      letterspacing: 1.2,
                      buttonwidth: 100,
                      buttonheight: 40,
                      buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                      buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                      radius: 10,
                      hideImage: true,
                      elevation: 0,
                      onTap: () async {
                        Timer(const Duration(microseconds: 500), () {
                          Navigator.of(context).pushNamed(Constants.LOGIN);
                        });
                      },
                    ),
                  )
                : isLogin == '1' && (OQDOApplication.instance.userType == Constants.facilityType || OQDOApplication.instance.userType == Constants.coachType)
                    ? const SizedBox()
                    : GestureDetector(
                        onTap: () async {
                          if (isLogin == '1') {
                            SelectedHomeModel selectedHomeModel = SelectedHomeModel();
                            await Navigator.pushNamed(context, Constants.facilityFavoritesList, arguments: selectedHomeModel);
                          } else {
                            showSnackBarColor('Please login', context, true);
                            Timer(const Duration(microseconds: 500), () {
                              Navigator.of(context).pushNamed(Constants.LOGIN);
                            });
                          }
                        },
                        child: Image.asset(
                          "assets/images/ic_fav.png",
                          height: 30,
                          width: 30,
                        )),
            IconButton(
              onPressed: () async {
                if (isLogin != null && isLogin == '1') {
                  Navigator.of(context).pushNamed(Constants.notification);
                } else {
                  showSnackBarColor('Please login', context, true);
                  Timer(const Duration(microseconds: 500), () {
                    Navigator.of(context).pushNamed(Constants.LOGIN);
                  });
                }
              },
              icon: Stack(
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/notify_icon.png',
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      width: 30,
                      height: 30,
                    ),
                  ),
                  Provider.of<NotificationProvider>(context).isNewNotification
                      ? Positioned(
                          top: 10,
                          right: 5,
                          child: Container(
                            width: 10,
                            height: 10,
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ).visible(isLogin == '1'),
          ],
        ),
        drawer: Container(
          width: 350,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.background,
            ],
          )),
          child: ListTileTheme(
            textColor: Theme.of(context).colorScheme.onBackground,
            iconColor: Theme.of(context).colorScheme.onBackground,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Consumer<ChatProvider>(
                  builder: (context, viewModel, child) {
                    return Container(
                      margin: const EdgeInsets.fromLTRB(0, 50.0, 0, 0),
                      child: Row(
                        children: [
                          isLogin == '1'
                              ? Padding(
                                  padding: const EdgeInsets.fromLTRB(20.0, 0, 0, 0),
                                  child: CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.background,
                                    radius: 25,
                                    child: CircleAvatar(
                                      radius: 25,
                                      backgroundImage: Image.network(
                                        viewModel.profileImagePathStr != null ? viewModel.profileImagePathStr! : '',
                                        // OQDOApplication.instance.profileImage != null ? OQDOApplication.instance.profileImage! : '',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, trace) {
                                          return Image.asset(
                                            "assets/images/profile_circle.png",
                                            fit: BoxFit.fill,
                                            width: 50,
                                            height: 50,
                                          );
                                        },
                                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child; // Image is fully loaded, display it.
                                          } else {
                                            return Center(
                                              child: SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  color: Theme.of(context).colorScheme.onBackground,
                                                  value: loadingProgress.expectedTotalBytes != null
                                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                      : null,
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ).image,
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.fromLTRB(20.0, 0, 0, 0),
                                  child: Image.asset(
                                    "assets/images/profile_circle.png",
                                    fit: BoxFit.fill,
                                    width: 50,
                                    height: 50,
                                  ),
                                ),
                          const SizedBox(
                            width: 18,
                          ),
                          isLogin == '1'
                              ? Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Consumer<ChatProvider>(
                                        builder: (context, value, child) {
                                          return CustomTextView(
                                            label: value.userName,
                                            textOverFlow: TextOverflow.ellipsis,
                                            maxLine: 2,
                                            textStyle:
                                                Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 21),
                                          );
                                        },
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      CustomTextView(
                                        label: emailId,
                                        textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                      ),
                                    ],
                                  ),
                                )
                              : Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      _scaffoldKey.currentState?.closeDrawer();
                                      await Navigator.pushNamed(context, Constants.LOGIN);
                                    },
                                    child: CustomTextView(
                                      label: 'Sign In/ Sign Up',
                                      textOverFlow: TextOverflow.ellipsis,
                                      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 22),
                                    ),
                                  ),
                                ),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16.0),
                Divider(
                  color: Theme.of(context).colorScheme.shadow,
                  height: 1.5,
                ),
                const SizedBox(height: 15.0),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: const BorderRadius.all(Radius.circular(10.0)), // inner circle color
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.of(context).pop();
                                selectTab(0);
                              },
                              trailing: Image.asset(
                                "assets/images/drawer_arrow.png",
                                fit: BoxFit.cover,
                                height: 30,
                                width: 30,
                              ),
                              leading: Image.asset(
                                "assets/images/drawer_home.png",
                                fit: BoxFit.cover,
                                height: 25,
                                width: 25,
                              ),
                              title: Text(
                                'Home',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontFamily: 'SFPro',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 12.0,
                          ),
                          // Appointment
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: const BorderRadius.all(Radius.circular(10.0)), // inner circle color
                            ),
                            child: ListTile(
                              onTap: () async {
                                if (OQDOApplication.instance.isLogin == '1') {
                                  if (OQDOApplication.instance.userType == Constants.endUserType) {
                                    await Navigator.pushNamed(context, Constants.endUserAppointmentScreen, arguments: DateTime.now());
                                  } else {
                                    if (OQDOApplication.instance.userType == Constants.facilityType) {
                                      await Navigator.pushNamed(context, Constants.facilityAppointmentScreen, arguments: DateTime.now());
                                    } else {
                                      await Navigator.pushNamed(context, Constants.coachAppointmentScreen, arguments: DateTime.now());
                                    }
                                  }
                                } else {
                                  Navigator.of(context).pop();
                                  showSnackBarColor('Please login', context, true);
                                  Timer(const Duration(microseconds: 500), () {
                                    Navigator.of(context).pushNamed(Constants.LOGIN);
                                  });
                                }
                              },
                              trailing: Image.asset(
                                "assets/images/drawer_arrow.png",
                                fit: BoxFit.cover,
                                height: 30,
                                width: 30,
                              ),
                              leading: Image.asset(
                                "assets/images/drawer_appointment.png",
                                fit: BoxFit.cover,
                                width: 25,
                                height: 25,
                              ),
                              title: Text(
                                'Appointments',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontFamily: 'SFPro',
                                ),
                              ),
                            ),
                          ),
                          const Visibility(
                            visible: true,
                            child: SizedBox(
                              height: 12.0,
                            ),
                          ),
                          // Transaction History
                          Visibility(
                            visible: isLogin == '1' && OQDOApplication.instance.userType == Constants.endUserType,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: Theme.of(context).colorScheme.surfaceVariant,
                                borderRadius: const BorderRadius.all(Radius.circular(10.0)), // inner circle color
                              ),
                              child: ListTile(
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  await Navigator.pushNamed(context, Constants.transaction);
                                },
                                trailing: Image.asset(
                                  "assets/images/drawer_arrow.png",
                                  fit: BoxFit.cover,
                                  height: 30,
                                  width: 30,
                                ),
                                leading: Image.asset(
                                  "assets/images/drawer_transaction_history.png",
                                  fit: BoxFit.cover,
                                  width: 25,
                                  height: 25,
                                ),
                                title: Text(
                                  'Transaction History',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontFamily: 'SFPro',
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Visibility(
                            visible: isLogin == '1' && OQDOApplication.instance.userType == Constants.endUserType,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 12.0,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: Theme.of(context).colorScheme.surfaceVariant,
                                    borderRadius: const BorderRadius.all(Radius.circular(10.0)), // inner circle color
                                  ),
                                  child: ListTile(
                                    onTap: () async {
                                      Navigator.of(context).pop();
                                      await Navigator.pushNamed(context, Constants.enduserCancellationRequestPage);
                                    },
                                    trailing: Image.asset(
                                      "assets/images/drawer_arrow.png",
                                      fit: BoxFit.cover,
                                      height: 30,
                                      width: 30,
                                    ),
                                    leading: Image.asset(
                                      "assets/images/drawer_cancellation_requests.png",
                                      fit: BoxFit.cover,
                                      width: 25,
                                      height: 25,
                                    ),
                                    title: Text('Cancellation Requests',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontFamily: 'SFPro',
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: isLogin == "1" && OQDOApplication.instance.userType == Constants.endUserType,
                            child: const SizedBox(
                              height: 12.0,
                            ),
                          ),
                          // Profile
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: const BorderRadius.all(Radius.circular(10.0)), // inner circle color
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.of(context).pop();
                                selectTab(4);
                              },
                              trailing: Image.asset(
                                "assets/images/drawer_arrow.png",
                                fit: BoxFit.cover,
                                height: 30,
                                width: 30,
                              ),
                              leading: Image.asset(
                                "assets/images/drawer_profile.png",
                                fit: BoxFit.cover,
                                width: 25,
                                height: 25,
                              ),
                              title: Text('Profile',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontFamily: 'SFPro',
                                  )),
                            ),
                          ),
                          const SizedBox(
                            height: 12.0,
                          ),
                          OQDOApplication.instance.userType == Constants.facilityType || OQDOApplication.instance.userType == Constants.coachType
                              ? Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        color: Theme.of(context).colorScheme.surfaceVariant,
                                        borderRadius: const BorderRadius.all(Radius.circular(10.0)), // inner circle color
                                      ),
                                      child: ListTile(
                                        onTap: () async {
                                          if (isLogin == '1') {
                                            if (OQDOApplication.instance.userType == Constants.facilityType) {
                                              Navigator.of(context).pop();
                                              await Navigator.pushNamed(context, Constants.FACILITYSETUPPAGE);
                                            } else {
                                              Navigator.of(context).pop();
                                              await Navigator.pushNamed(context, Constants.BATCHSETUPLISTPAGE);
                                            }
                                          } else {
                                            showSnackBarColor('Please login', context, true);
                                            Timer(const Duration(microseconds: 500), () {
                                              Navigator.of(context).pushNamed(Constants.LOGIN);
                                            });
                                          }
                                        },
                                        trailing: Image.asset(
                                          "assets/images/drawer_arrow.png",
                                          fit: BoxFit.cover,
                                          height: 30,
                                          width: 30,
                                        ),
                                        leading: Image.asset(
                                          "assets/images/drawer_setup.png",
                                          fit: BoxFit.cover,
                                          width: 25,
                                          height: 25,
                                        ),
                                        title: Text('Setup',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontFamily: 'SFPro',
                                            )),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 12.0,
                                    )
                                  ],
                                )
                              : Container(),
                          // Buddies
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: const BorderRadius.all(Radius.circular(10.0)), // inner circle color
                            ),
                            child: ListTile(
                              onTap: () async {
                                Navigator.of(context).pop();
                                if (await NetworkConnectionInterceptor().isConnected()) {
                                  Map<String, dynamic> model = {};
                                  model['url'] = 'https://oqdo.com/contact/';
                                  model['title'] = 'Contact Us';
                                  await Navigator.pushNamed(context, Constants.webViewScreens, arguments: model);
                                } else {
                                  showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
                                }
                              },
                              trailing: Image.asset(
                                "assets/images/drawer_arrow.png",
                                fit: BoxFit.cover,
                                height: 30,
                                width: 30,
                              ),
                              leading: Image.asset(
                                "assets/images/drawer_contact_us.png",
                                fit: BoxFit.cover,
                                width: 25,
                                height: 25,
                              ),
                              title: Text('Contact Us',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontFamily: 'SFPro',
                                  )),
                            ),
                          ),
                          const SizedBox(
                            height: 12.0,
                          ),
                          isLogin == '1'
                              ? OQDOApplication.instance.userType == Constants.endUserType
                                  ? Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        color: Theme.of(context).colorScheme.surfaceVariant,
                                        borderRadius: const BorderRadius.all(Radius.circular(10.0)), // inner circle color
                                      ),
                                      child: ListTile(
                                        onTap: () async {
                                          if (isLogin == '1') {
                                            Navigator.of(context).pushNamed(Constants.searchBuddiesScreen);
                                          } else {
                                            showSnackBarColor('Please login', context, true);
                                            Timer(const Duration(microseconds: 500), () {
                                              Navigator.of(context).pushNamed(Constants.LOGIN);
                                            });
                                          }
                                        },
                                        trailing: Image.asset(
                                          "assets/images/drawer_arrow.png",
                                          fit: BoxFit.cover,
                                          height: 30,
                                          width: 30,
                                        ),
                                        leading: Image.asset(
                                          "assets/images/drawer_buddies.png",
                                          fit: BoxFit.cover,
                                          width: 25,
                                          height: 25,
                                        ),
                                        title: Text('Buddies',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontFamily: 'SFPro',
                                            )),
                                      ),
                                    )
                                  : Container()
                              : Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        color: Theme.of(context).colorScheme.surfaceVariant,
                                        borderRadius: const BorderRadius.all(Radius.circular(10.0)), // inner circle color
                                      ),
                                      child: ListTile(
                                        onTap: () async {
                                          if (isLogin == '1') {
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pushNamed(Constants.searchBuddiesScreen);
                                          } else {
                                            showSnackBarColor('Please login', context, true);
                                            Timer(const Duration(microseconds: 500), () {
                                              Navigator.of(context).pushNamed(Constants.LOGIN);
                                            });
                                          }
                                        },
                                        trailing: Image.asset(
                                          "assets/images/drawer_arrow.png",
                                          fit: BoxFit.cover,
                                          height: 30,
                                          width: 30,
                                        ),
                                        leading: Image.asset(
                                          "assets/images/drawer_buddies.png",
                                          fit: BoxFit.cover,
                                          width: 25,
                                          height: 25,
                                        ),
                                        title: Text('Buddies',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontFamily: 'SFPro',
                                            )),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                  ],
                                ),
                          isLogin == '1' && OQDOApplication.instance.userType == Constants.endUserType
                              ? const SizedBox(
                                  height: 12,
                                )
                              : Container(),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: const BorderRadius.all(Radius.circular(10.0)), // inner circle color
                            ),
                            child: ListTile(
                              onTap: () async {
                                Navigator.of(context).pop();
                                if (await NetworkConnectionInterceptor().isConnected()) {
                                  Map<String, dynamic> model = {};
                                  model['url'] = 'https://oqdo.com/about-us/';
                                  model['title'] = 'About Us';
                                  await Navigator.pushNamed(context, Constants.webViewScreens, arguments: model);
                                } else {
                                  showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
                                }
                                // Navigator.of(context).pop();
                                // await Navigator.pushNamed(context, Constants.aboutUs);
                              },
                              trailing: Image.asset(
                                "assets/images/drawer_arrow.png",
                                fit: BoxFit.cover,
                                height: 30,
                                width: 30,
                              ),
                              leading: Image.asset(
                                "assets/images/drawer_about_us.png",
                                fit: BoxFit.cover,
                                width: 25,
                                height: 25,
                              ),
                              title: Text('About Us',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontFamily: 'SFPro',
                                  )),
                            ),
                          ),
                          const SizedBox(
                            height: 12.0,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: const BorderRadius.all(Radius.circular(10.0)), // inner circle color
                            ),
                            child: ListTile(
                              onTap: () async {
                                Navigator.of(context).pop();
                                if (await NetworkConnectionInterceptor().isConnected()) {
                                  Map<String, dynamic> model = {};
                                  model['url'] = 'https://oqdo.com/privacy-policy-oqdo/';
                                  model['title'] = 'Privacy Policy';
                                  await Navigator.pushNamed(context, Constants.webViewScreens, arguments: model);
                                } else {
                                  showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
                                }
                              },
                              trailing: Image.asset(
                                "assets/images/drawer_arrow.png",
                                fit: BoxFit.cover,
                                height: 30,
                                width: 30,
                              ),
                              leading: Image.asset(
                                "assets/images/drawer_privacy_policy.png",
                                fit: BoxFit.cover,
                                width: 25,
                                height: 25,
                              ),
                              title: Text('Privacy Policy',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontFamily: 'SFPro',
                                  )),
                            ),
                          ),
                          const SizedBox(
                            height: 12.0,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: const BorderRadius.all(Radius.circular(10.0)), // inner circle color
                            ),
                            child: ListTile(
                              onTap: () async {
                                Navigator.of(context).pop();
                                if (await NetworkConnectionInterceptor().isConnected()) {
                                  Map<String, dynamic> model = {};
                                  model['url'] = 'https://oqdo.com/cancellation-policy/';
                                  model['title'] = 'Cancellation Policy';
                                  await Navigator.pushNamed(context, Constants.webViewScreens, arguments: model);
                                } else {
                                  showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
                                }
                              },
                              trailing: Image.asset(
                                "assets/images/drawer_arrow.png",
                                fit: BoxFit.cover,
                                height: 30,
                                width: 30,
                              ),
                              leading: Image.asset(
                                "assets/images/drawer_cancellation_policy.png",
                                fit: BoxFit.cover,
                                width: 25,
                                height: 25,
                              ),
                              title: Text('Cancellation Policy',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontFamily: 'SFPro',
                                  )),
                            ),
                          ),
                          const SizedBox(
                            height: 12.0,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: const BorderRadius.all(Radius.circular(10.0)), // inner circle color
                            ),
                            child: ListTile(
                              onTap: () async {
                                Navigator.of(context).pop();
                                //open webview
                                if (await NetworkConnectionInterceptor().isConnected()) {
                                  Map<String, dynamic> model = {};
                                  model['url'] = 'https://oqdo.com/terms-of-service/';
                                  model['title'] = 'Terms of Service';
                                  await Navigator.pushNamed(context, Constants.webViewScreens, arguments: model);
                                } else {
                                  showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
                                }
                              },
                              trailing: Image.asset(
                                "assets/images/drawer_arrow.png",
                                fit: BoxFit.cover,
                                height: 30,
                                width: 30,
                              ),
                              leading: Image.asset(
                                "assets/images/drawer_terms_of_service.png",
                                fit: BoxFit.cover,
                                width: 25,
                                height: 25,
                              ),
                              title: Text('Terms of Service',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontFamily: 'SFPro',
                                  )),
                            ),
                          ),
                          const SizedBox(
                            height: 12.0,
                          ),

                          Visibility(
                            visible: isLogin != null && isLogin == '1',
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: Theme.of(context).colorScheme.surfaceVariant,
                                borderRadius: const BorderRadius.all(Radius.circular(10.0)), // inner circle color
                              ),
                              child: ListTile(
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  await Navigator.pushNamed(context, Constants.changePassword);
                                },
                                trailing: Image.asset(
                                  "assets/images/drawer_arrow.png",
                                  fit: BoxFit.cover,
                                  height: 30,
                                  width: 30,
                                ),
                                leading: Image.asset(
                                  "assets/images/drawer_change_password.png",
                                  fit: BoxFit.cover,
                                  width: 25,
                                  height: 25,
                                ),
                                title: Text('Change Password',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontFamily: 'SFPro',
                                    )),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 40.0,
                          ),
                          isLogin == '1'
                              ? ListTile(
                                  onTap: () async {
                                    logoutCall();
                                  },
                                  leading: Image.asset(
                                    "assets/images/drawer_logout.png",
                                    fit: BoxFit.cover,
                                    width: 30,
                                    height: 30,
                                  ),
                                  title: Text('Logout',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.error,
                                        fontFamily: 'SFPro',
                                      )),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                ),
                CustomTextView(
                  label: 'v${packageInfo?.version}',
                  textStyle: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        body: isPageSet
            ? Stack(
                children: [
                  page,
                  Positioned(
                    bottom: 50,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: _isFabOpen ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withAlpha((0.1 * 255).toInt()),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  if (_isFabOpen) {
                                    _toggleFab();
                                    if (isLogin == '1') {
                                      Navigator.of(context).pushNamed(Constants.bazaarHomeScreen, arguments: 2);
                                    } else {
                                      showSnackBarColor('Please login', context, true);
                                      Timer(const Duration(microseconds: 500), () {
                                        Navigator.of(context).pushNamed(Constants.LOGIN);
                                      });
                                    }
                                  }
                                },
                                icon: Image.asset(
                                  'assets/images/ic_equipment.png',
                                  fit: BoxFit.contain,
                                  height: 20,
                                  width: 20,
                                ),
                                label: Text(
                                  'Equipments',
                                  style: TextStyle(
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      fontFamily: 'SFPro',
                                      fontWeight: FontWeight.w500),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 1,
                                height: 24,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () {
                                  if (_isFabOpen) {
                                    _toggleFab();
                                    Navigator.of(context).pushNamed(Constants.bazaarHomeScreen, arguments: 4);
                                  }
                                },
                                icon: Image.asset(
                                  'assets/images/ic_ads.png',
                                  fit: BoxFit.contain,
                                  height: 20,
                                  width: 20,
                                ),
                                label: Text(
                                  'Ads',
                                  style: TextStyle(
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      fontFamily: 'SFPro',
                                      fontWeight: FontWeight.w500),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : ChangeNotifierProvider(
                create: (context) => DashboardViewModel(),
                child: Stack(
                  children: [
                    const Homepage(),
                    Positioned(
                      bottom: 50,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: _isFabOpen ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withAlpha((0.1 * 255).toInt()),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    if (_isFabOpen) {
                                      _toggleFab();
                                      if (isLogin == '1') {
                                        Navigator.of(context).pushNamed(Constants.bazaarHomeScreen, arguments: 2);
                                      } else {
                                        showSnackBarColor('Please login', context, true);
                                        Timer(const Duration(microseconds: 500), () {
                                          Navigator.of(context).pushNamed(Constants.LOGIN);
                                        });
                                      }
                                    }
                                  },
                                  icon: Image.asset(
                                    'assets/images/ic_equipment.png',
                                    fit: BoxFit.contain,
                                    height: 20,
                                    width: 20,
                                  ),
                                  label: Text(
                                    'Equipments',
                                    style: TextStyle(
                                        color: Theme.of(context).colorScheme.onPrimary,
                                        fontFamily: 'SFPro',
                                        fontWeight: FontWeight.w500),
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 1,
                                  height: 24,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: () {
                                    if (_isFabOpen) {
                                      _toggleFab();
                                      Navigator.of(context).pushNamed(Constants.bazaarHomeScreen, arguments: 4);
                                    }
                                  },
                                  icon: Image.asset(
                                    'assets/images/ic_ads.png',
                                    fit: BoxFit.contain,
                                    height: 20,
                                    width: 20,
                                  ),
                                  label: Text(
                                    'Ads',
                                    style: TextStyle(
                                        color: Theme.of(context).colorScheme.onPrimary,
                                        fontFamily: 'SFPro',
                                        fontWeight: FontWeight.w500),
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        backgroundColor: Theme.of(context).colorScheme.background,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
            onPressed: _toggleFab,
            mini: false,
            backgroundColor: Theme.of(context).colorScheme.primary,
            disabledElevation: 0,
            elevation: 0,
            clipBehavior: Clip.none,
            foregroundColor: Theme.of(context).colorScheme.primary,
            splashColor: Theme.of(context).colorScheme.primary,
            autofocus: false,
            hoverColor: Theme.of(context).colorScheme.primary,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animation.value * math.pi * (2 / 4),
                  child: Image.asset(
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                    !_isFabOpen ? 'assets/images/ic_bottom_shop.png' : 'assets/images/ic_bottom_close.png',
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                );
              },
            )),
        bottomNavigationBar: BottomNavigationBar(
          unselectedItemColor: Theme.of(context).colorScheme.onSurface,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.background,
          unselectedLabelStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
              fontSize: 12),
          selectedLabelStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
              fontSize: 12),
          items: [
            const BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/images/ic_bottom_home.png"),
              ),
              label: "HOME",
            ),
            const BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/images/ic_bottom_calendar.png"),
              ),
              label: "CALENDAR",
            ),
            const BottomNavigationBarItem(
              icon: SizedBox(
                width: 50,
              ),
              label: "",
            ),
            isLogin == "1"
                ? OQDOApplication.instance.userType == Constants.coachType || OQDOApplication.instance.userType == Constants.facilityType
                    ? const BottomNavigationBarItem(
                        icon: ImageIcon(
                          AssetImage("assets/images/ic_close.png"),
                        ),
                        label: "CANCEL",
                      )
                    : const BottomNavigationBarItem(
                        icon: ImageIcon(
                          AssetImage("assets/images/ic_bottom_messages.png"),
                        ),
                        label: "MESSAGES",
                      )
                : const BottomNavigationBarItem(
                    icon: ImageIcon(
                      AssetImage("assets/images/ic_bottom_messages.png"),
                    ),
                    label: "MESSAGES",
                  ),
            const BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/images/ic_bottom_user.png"),
              ),
              label: "PROFILE",
            ),
          ],
          currentIndex: index,
          onTap: selectTab,
        ),
        resizeToAvoidBottomInset: false,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _subscription.cancel();
    _networkConnectivity.disposeStream();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabOpen = !_isFabOpen;
      if (_isFabOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void selectTab(int i) {
    if (i == 4 && OQDOApplication.instance.isLogin == '0') {
      showSnackBarColor('Please login', context, true);
      Timer(const Duration(microseconds: 500), () {
        Navigator.of(context).pushNamed(Constants.LOGIN);
      });
      return;
    }

    if (i == 3 && OQDOApplication.instance.isLogin == '0') {
      showSnackBarColor('Please login', context, true);
      Timer(const Duration(microseconds: 500), () {
        Navigator.of(context).pushNamed(Constants.LOGIN);
      });
      return;
    }

    if (i == 1 && OQDOApplication.instance.isLogin == '0') {
      showSnackBarColor('Please login', context, true);
      Timer(const Duration(microseconds: 500), () {
        Navigator.of(context).pushNamed(Constants.LOGIN);
      });
      return;
    }

    if (i == 1 && OQDOApplication.instance.isLogin == null) {
      showSnackBarColor('Please login', context, true);
      Timer(const Duration(microseconds: 500), () {
        Navigator.of(context).pushNamed(Constants.LOGIN);
      });
      return;
    }

    if (i == 3 && OQDOApplication.instance.isLogin == null) {
      showSnackBarColor('Please login', context, true);
      Timer(const Duration(microseconds: 500), () {
        Navigator.of(context).pushNamed(Constants.LOGIN);
      });
      return;
    }

    if (i == 4 && OQDOApplication.instance.isLogin == null) {
      showSnackBarColor('Please login', context, true);
      Timer(const Duration(microseconds: 500), () {
        Navigator.of(context).pushNamed(Constants.LOGIN);
      });
      return;
    }

    if (i == 1 && OQDOApplication.instance.isLogin!.isEmpty) {
      showSnackBarColor('Please login', context, true);
      Timer(const Duration(microseconds: 500), () {
        Navigator.of(context).pushNamed(Constants.LOGIN);
      });
      return;
    }

    if (i == 3 && OQDOApplication.instance.isLogin!.isEmpty) {
      showSnackBarColor('Please login', context, true);
      Timer(const Duration(microseconds: 500), () {
        Navigator.of(context).pushNamed(Constants.LOGIN);
      });
      return;
    }

    if (i == 4 && OQDOApplication.instance.isLogin!.isEmpty) {
      showSnackBarColor('Please login', context, true);
      Timer(const Duration(microseconds: 500), () {
        Navigator.of(context).pushNamed(Constants.LOGIN);
      });
      return;
    }

    setState(() {
      index = i;
      switch (index) {
        case 0:
          page = ChangeNotifierProvider(create: (context) => DashboardViewModel(), child: const Homepage());
          break;
        case 1:
          if (OQDOApplication.instance.isLogin == null) {
          } else {
            page = OQDOApplication.instance.userType == Constants.endUserType
                ? ChangeNotifierProvider(
                    create: (context) => AppointmentViewModel(),
                    child: const EndUserCalendarViewScreen(),
                  )
                : ChangeNotifierProvider(
                    create: (context) => AppointmentViewModel(),
                    child: const ServiceProviderCalendarScreen(),
                  );
          }
          break;
        case 2:
          //   page = const AppointmentScreen();
          // page = Center(
          //   child: Padding(
          //     padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          //     child: Image.asset(
          //       'assets/images/ic_coming_soon.png',
          //       fit: BoxFit.fill,
          //     ),
          //   ),
          // );

          break;
        case 3:
          if (OQDOApplication.instance.isLogin == null) {
          } else {
            if (OQDOApplication.instance.userType == Constants.coachType) {
              page = ChangeNotifierProvider(
                create: (context) => ServiceProvidersCancellationViewModel(),
                child: const CoachCancellationRequestPage(),
              );
            } else if (OQDOApplication.instance.userType == Constants.facilityType) {
              page = ChangeNotifierProvider(
                create: (context) => ServiceProvidersCancellationViewModel(),
                child: const FacilityCancellationRequestPage(),
              );
            } else {
              page = ChangeNotifierProvider(
                create: (BuildContext context) => GetAllBuddiesReposotory(),
                child: const ConversationScreen(),
              );
            }
          }
          break;
        case 4:
          if (OQDOApplication.instance.isLogin == null) {
          } else {
            if (OQDOApplication.instance.userType == Constants.coachType) {
              page = const CoachProfilePage();
            } else if (OQDOApplication.instance.userType == Constants.facilityType) {
              page = const FacilityProfilePage();
            } else {
              page = const LearnerProfilePage();
            }
          }
          break;
        default:
          page = ChangeNotifierProvider(create: (context) => DashboardViewModel(), child: const Homepage());
          break;
      }
      isPageSet = true;
    });
  }

  Future<void> getEndUserData() async {
    try {
      await Provider.of<ProfileViewModel>(context, listen: false).getEndUserProfile(OQDOApplication.instance.endUserID!).then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500) {
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 401) {
            Provider.of<NotificationProvider>(context, listen: false).updateStatus(false);
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.token, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.tokenType, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.expiresIn, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.refreshToken, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.userId, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.facilityId, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.coachId, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.endUserId, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.fcmToken, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.userType, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.isLogin, value: "0");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.selectedCountryName, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.selectedCountryID, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.selectedCountryCode, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.mobileNoLength, value: "");
            Navigator.pushNamedAndRemoveUntil(context, Constants.LOCATIONCHOOSEPAGE, (route) => false);
            showSnackBarColor('Un-Authorized access. Please try to login again', context, true);
          } else if (res.statusCode == 200) {
            EndUserProfileResponseModel endUserProfileResponseModel = EndUserProfileResponseModel.fromJson(jsonDecode(res.body));
            if (endUserProfileResponseModel.firstName != null) {
              setState(() {
                firstName = '${endUserProfileResponseModel.firstName!} ${endUserProfileResponseModel.lastName!}';
                OQDOApplication.instance.userName = '${endUserProfileResponseModel.firstName!} ${endUserProfileResponseModel.lastName!}';
                context.read<ChatProvider>().setUserName('${endUserProfileResponseModel.firstName!} ${endUserProfileResponseModel.lastName!}');
                emailId = endUserProfileResponseModel.regEmail;
                profilePicPath = endUserProfileResponseModel.profileImage;

                OQDOApplication.instance.profileImage = endUserProfileResponseModel.profileImage;
                OQDOApplication.instance.name = '${endUserProfileResponseModel.firstName!} ${endUserProfileResponseModel.lastName!}';
                OQDOApplication.instance.email = endUserProfileResponseModel.regEmail!;
                OQDOApplication.instance.phone = endUserProfileResponseModel.mobileNumber!;
                OQDOApplication.instance.zipcode = endUserProfileResponseModel.pinCode!;
                OQDOApplication.instance.country = endUserProfileResponseModel.countryName!;
                OQDOApplication.instance.city = endUserProfileResponseModel.cityName!;
                context.read<ChatProvider>().setProfileImagePath(endUserProfileResponseModel.profileImage!);
              });
            }
          } else {
            Map<String, dynamic> errorModel = jsonDecode(res.body);
            if (errorModel.containsKey('error_description')) {
              showSnackBarColor(errorModel['error_description'], context, true);
            }
          }
        },
      );
    } on NoConnectivityException catch (_) {
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      debugPrint(exception.toString());
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  Future<void> getFacilityUserData() async {
    try {
      await Provider.of<ProfileViewModel>(context, listen: false).getFacilityUserProfile(OQDOApplication.instance.facilityID!).then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 401) {
            Provider.of<NotificationProvider>(context, listen: false).updateStatus(false);
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.token, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.tokenType, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.expiresIn, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.refreshToken, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.userId, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.facilityId, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.coachId, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.endUserId, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.fcmToken, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.userType, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.isLogin, value: "0");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.selectedCountryName, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.selectedCountryID, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.selectedCountryCode, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.mobileNoLength, value: "");
            Navigator.pushNamedAndRemoveUntil(context, Constants.LOCATIONCHOOSEPAGE, (route) => false);
            showSnackBarColor('Un-Authorized access. Please try to login again', context, true);
          } else if (res.statusCode == 200) {
            FacilityProfileResponse facilityProfileResponseModel = FacilityProfileResponse.fromJson(jsonDecode(res.body));
            if (facilityProfileResponseModel.facilityName != null) {
              setState(() {
                firstName = facilityProfileResponseModel.facilityName!;
                OQDOApplication.instance.userName = facilityProfileResponseModel.facilityName!;
                OQDOApplication.instance.profileImage = facilityProfileResponseModel.profileImage;
                context.read<ChatProvider>().setUserName(facilityProfileResponseModel.facilityName!);
                emailId = facilityProfileResponseModel.email;
                profilePicPath = facilityProfileResponseModel.profileImage;
                Provider.of<ChatProvider>(context, listen: false).setProfileImagePath(facilityProfileResponseModel.profileImage!);
              });
            }
          } else {
            Map<String, dynamic> errorModel = jsonDecode(res.body);
            if (errorModel.containsKey('error_description')) {
              showSnackBarColor(errorModel['error_description'], context, true);
            }
          }
        },
      );
    } on NoConnectivityException catch (_) {
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  Future<void> getCoachUserData() async {
    try {
      await Provider.of<ProfileViewModel>(context, listen: false).getCoachUserProfile(OQDOApplication.instance.coachID!).then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 401) {
            Provider.of<NotificationProvider>(context, listen: false).updateStatus(false);
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.token, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.tokenType, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.expiresIn, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.refreshToken, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.userId, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.facilityId, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.coachId, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.endUserId, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.fcmToken, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.userType, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.isLogin, value: "0");
            // await OQDOApplication.instance.storage.deleteAll();
            Navigator.pushNamedAndRemoveUntil(context, Constants.LOCATIONCHOOSEPAGE, (route) => false);
            showSnackBarColor('Un-Authorized access. Please try to login again', context, true);
          } else if (res.statusCode == 200) {
            coachProfileResponseModel = CoachProfileResponseModel.fromJson(jsonDecode(res.body));
            if (coachProfileResponseModel.firstName != null) {
              setState(() {
                firstName = '${coachProfileResponseModel.firstName!} ${coachProfileResponseModel.lastName!}';
                OQDOApplication.instance.userName = '${coachProfileResponseModel.firstName!} ${coachProfileResponseModel.lastName!}';
                OQDOApplication.instance.profileImage = coachProfileResponseModel.profileImage;
                context.read<ChatProvider>().setUserName('${coachProfileResponseModel.firstName!} ${coachProfileResponseModel.lastName!}');
                emailId = coachProfileResponseModel.emailId;
                profilePicPath = coachProfileResponseModel.profileImage;
                Provider.of<ChatProvider>(context, listen: false).setProfileImagePath(coachProfileResponseModel.profileImage!);
              });
            }
            debugPrint(coachProfileResponseModel.firstName);
          } else {
            Map<String, dynamic> errorModel = jsonDecode(res.body);
            if (errorModel.containsKey('error_description')) {
              showSnackBarColor(errorModel['error_description'], context, true);
            }
          }
        },
      );
    } on NoConnectivityException catch (_) {
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  Future<void> logoutCall() async {
    try {
      await _progressDialog.show();
      var response = await Provider.of<ProfileViewModel>(context, listen: false).logout(OQDOApplication.instance.userID.toString());
      Provider.of<NotificationProvider>(context, listen: false).updateStatus(false);
      // await OQDOApplication.instance.storage.setStringValue(key: AppStrings.token, value: "");
      // await OQDOApplication.instance.storage.setStringValue(key: AppStrings.tokenType, value: "");
      // await OQDOApplication.instance.storage.setStringValue(key: AppStrings.expiresIn, value: "");
      // await OQDOApplication.instance.storage.setStringValue(key: AppStrings.refreshToken, value: "");
      // await OQDOApplication.instance.storage.setStringValue(key: AppStrings.userId, value: "");
      // await OQDOApplication.instance.storage.setStringValue(key: AppStrings.facilityId, value: "");
      // await OQDOApplication.instance.storage.setStringValue(key: AppStrings.coachId, value: "");
      // await OQDOApplication.instance.storage.setStringValue(key: AppStrings.endUserId, value: "");
      // await OQDOApplication.instance.storage.setStringValue(key: AppStrings.fcmToken, value: "");
      // await OQDOApplication.instance.storage.setStringValue(key: AppStrings.userType, value: "");
      // await OQDOApplication.instance.storage.setStringValue(key: AppStrings.selectedCountryName, value: "");
      // await OQDOApplication.instance.storage.setStringValue(key: AppStrings.selectedCountryID, value: "");
      // await OQDOApplication.instance.storage.setStringValue(key: AppStrings.selectedCountryCode, value: "");
      // await OQDOApplication.instance.storage.setStringValue(key: AppStrings.mobileNoLength, value: "");
      // await OQDOApplication.instance.storage.setStringValue(key: AppStrings.isLogin, value: "0");
      // Provider.of<ChatProvider>(context, listen: false).setUserName('');
      // await OQDOApplication.instance.storage.deleteAll();
      if (response == '') {
        await _progressDialog.hide();
        Provider.of<NotificationProvider>(context, listen: false).updateStatus(false);
        await OQDOApplication.instance.storage.setStringValue(key: AppStrings.token, value: "");
        await OQDOApplication.instance.storage.setStringValue(key: AppStrings.tokenType, value: "");
        await OQDOApplication.instance.storage.setStringValue(key: AppStrings.expiresIn, value: "");
        await OQDOApplication.instance.storage.setStringValue(key: AppStrings.refreshToken, value: "");
        await OQDOApplication.instance.storage.setStringValue(key: AppStrings.userId, value: "");
        await OQDOApplication.instance.storage.setStringValue(key: AppStrings.facilityId, value: "");
        await OQDOApplication.instance.storage.setStringValue(key: AppStrings.coachId, value: "");
        await OQDOApplication.instance.storage.setStringValue(key: AppStrings.endUserId, value: "");
        await OQDOApplication.instance.storage.setStringValue(key: AppStrings.fcmToken, value: "");
        await OQDOApplication.instance.storage.setStringValue(key: AppStrings.userType, value: "");
        await OQDOApplication.instance.storage.setStringValue(key: AppStrings.isLogin, value: "0");
        await OQDOApplication.instance.storage.setStringValue(key: AppStrings.selectedCountryName, value: "");
        await OQDOApplication.instance.storage.setStringValue(key: AppStrings.selectedCountryID, value: "");
        await OQDOApplication.instance.storage.setStringValue(key: AppStrings.selectedCountryCode, value: "");
        await OQDOApplication.instance.storage.setStringValue(key: AppStrings.mobileNoLength, value: "");
        // await OQDOApplication.instance.storage.deleteAll();
        Navigator.pushNamedAndRemoveUntil(context, Constants.LOCATIONCHOOSEPAGE, (route) => false);
      } else {
        await _progressDialog.hide();
        Timer(const Duration(milliseconds: 500), () async {
          Provider.of<NotificationProvider>(context, listen: false).updateStatus(false);
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.token, value: "");
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.tokenType, value: "");
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.expiresIn, value: "");
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.refreshToken, value: "");
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.userId, value: "");
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.facilityId, value: "");
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.coachId, value: "");
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.endUserId, value: "");
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.fcmToken, value: "");
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.userType, value: "");
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.isLogin, value: "0");
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.selectedCountryName, value: "");
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.selectedCountryID, value: "");
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.selectedCountryCode, value: "");
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.mobileNoLength, value: "");
          // await OQDOApplication.instance.storage.deleteAll();
          Navigator.pushNamedAndRemoveUntil(context, Constants.LOCATIONCHOOSEPAGE, (route) => false);
        });
      }
    } on CommonException catch (error) {
      await _progressDialog.hide();
      debugPrint("${error.code}");
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
        Timer(const Duration(milliseconds: 500), () async {
          Provider.of<NotificationProvider>(context, listen: false).updateStatus(false);
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.token, value: "");
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.tokenType, value: "");
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.expiresIn, value: "");
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.refreshToken, value: "");
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.userId, value: "");
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.facilityId, value: "");
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.coachId, value: "");
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.endUserId, value: "");
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.fcmToken, value: "");
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.userType, value: "");
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.isLogin, value: "0");
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.selectedCountryName, value: "");
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.selectedCountryID, value: "");
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.selectedCountryCode, value: "");
          await OQDOApplication.instance.storage.setStringValue(key: AppStrings.mobileNoLength, value: "");
          // await OQDOApplication.instance.storage.deleteAll();
          Navigator.pushNamedAndRemoveUntil(context, Constants.LOCATIONCHOOSEPAGE, (route) => false);
        });
      }
    } on NoConnectivityException catch (_) {
      await _progressDialog.hide();
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      await _progressDialog.hide();
      debugPrint(error.toString());
    }
  }

  Future<bool> _onWillPop() async {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeDrawer();
      return false;
    } else if (index != 0) {
      index = 0;
      selectTab(index);
      return Future.value(false);
    } else {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Are you sure?'),
              content: const Text('Do you want to exit an App'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    SystemNavigator.pop();
                    exit(0);
                  },
                  child: const Text('Yes'),
                ),
              ],
            ),
          ) ??
          false;
    }
  }

// Future<bool> onWillPop() async {
//   if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
//     _scaffoldKey.currentState?.closeDrawer();
//     return false;
//   } else {
//     if (index != 0) {
//       index = 0;
//       selectTab(index);
//       return Future.value(false);
//     } else {
//       return await showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: const Text('Are you sure?'),
//               content: const Text('Do you want to exit an App'),
//               actions: <Widget>[
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(false),
//                   child: const Text('No'),
//                 ),
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(true),
//                   child: const Text('Yes'),
//                 ),
//               ],
//             ),
//           ) ??
//           false;
//     }
//   }
// }
}
