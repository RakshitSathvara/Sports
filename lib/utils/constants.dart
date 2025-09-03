import 'dart:io';
import 'dart:math' as math;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:oqdo_mobile_app/main.dart';
import 'package:oqdo_mobile_app/model/PopularSportsResponseModel.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';

class Constants {
  static const String APP_NAME = 'OQDO';

  //Stripe Key
  // static String stripeKey = 'pk_test_51M95mODhKWfy8s83EMobpRUTU5NZxyaqNtYrZ8zuXr6DzqRokoI42mvYICZl5SezddYhQoEXbDUC4bQwCgMe5M4J00Y2JAKs5b'; // TESTING

  static String stripeKey = 'pk_live_51M95mODhKWfy8s83aV2c8XNxazP85QGkqezmioBKG1DU0fhN1cZSTRzREnfNbUuK1iRhYD3iAvspSD65YeZGKeJf004y0cL6IQ'; //LIVE

  //API URL Constants

  // static const String BASE_URL = 'http://192.168.24.144/OqdoApi'; // Local
  // static const String SOCKET_BASE_URL = 'http://192.168.24.144/OqdoApi';

  // static const String BASE_URL = 'https://api-oqdo-qa.azurewebsites.net'; // QA
  // static const String SOCKET_BASE_URL = 'https://oqdo-chathub-qa.azurewebsites.net'; // QA

  // static const String BASE_URL = 'https://api-oqdo-uat.azurewebsites.net'; //UAT
  // static const String SOCKET_BASE_URL = 'https://oqdo-chathub-uat.azurewebsites.net'; // UAT

  static const String BASE_URL = 'https://merlion.oqdo.com'; //LIVE
  static const String SOCKET_BASE_URL = 'https://merlion-chat.oqdo.com'; // LIVE

  static String platForm = '';
  static double androidVersion = 0.0;
  static const androidSecret = 'jHM{H+d|i9}1+4pR6[xj/ETmz(y9Q)%m@lqX\'jX83IgpieG#/d]+T*nu];&gt;\$tED';
  static const iosSecret = 'jHM{H+d|i9}1+4pR6[xj/ETmz(y9Q)%m@lqX\'jX83IgpieG#/d]+T*nu];&gt;\$tED';
  static const oneSignalAppId = '05d6a95c-d894-4dc4-bb41-3feffab029ae';

  // Shared Key
  static const String TOKEN = 'token';
  static const String USERID = 'user_id';
  static const String NAME = 'name';
  static const String IMAGE = 'image';

  //Route Key constants
  static const String APPPAGES = '/pages';
  static const String LOCATIONCHOOSEPAGE = '/location_choose_page';
  static const String PRELOGIN = '/Prelogin';
  static const String LOGIN = '/login';
  static const String PREREGISTER = '/Preregister';
  static const String REGISTER = '/register';
  static const String FORGOTPASSWORD = '/forgot_password';
  static const String FORGOTOTPVERIFICATION = '/forgot_otp_verification';
  static const String CREATEPASSWORD = '/create_password';
  static const String changePassword = '/change_password';
  static const String contactUs = '/contact_us';
  static const String aboutUs = '/about_us';
  static const String CHOOSESERVICEPROVIDER = '/choose_service_provider';
  static const String FACILITYADD = '/facility_add';
  static const String FACILITYOTP = '/facility_otp';
  static const String FACILITYADDONE = '/facility_add_one';
  static const String FACILITYADDTWO = '/facility_add_two';
  static const String COACHADD = '/coach_add';
  static const String COACHOTP = '/coach_otp';
  static const String COACHADDONE = '/coach_add_one';
  static const String COACHADDTWO = '/coach_add_two';
  static const String CALENDARVIEWPAGE = '/calendar_view_page';
  static const String BATCHSETUPPAGE = '/batch_setup_page';
  static const String BATCHSETUPLISTPAGE = '/batch_setup_list_page';
  static const String COACHLISTPAGE = '/coach_list_page';
  static const String FACILITIESLISTPAGE = '/facilities_list_page';
  static const String FACILITYSETUPPAGE = '/facility_setup_page';
  static const String ADDFACILITYPAGE = '/add_facility_page';
  static const String ADDBATCHSETUPPAGE = '/add_batch_setup_page';
  static const String CALENDARSERVICEPROVIDERPAGE = '/calendar_service_provider_page';
  static const String ADDFACILITYVACATIONPAGE = '/add_facility_vacation_page';
  static const String VACATIONLISTPAGE = '/vacation_list_page';
  static const String VIEWORDERDETAILPAGE = '/view_order_detail_page';
  static const String CANCELLATIONREQUESTPAGE = '/cancellation_request_page';
  static const String coach_detail_booking_screen = '/coach_detail_booking_screen';
  static const String facilityDetailsScreen = '/facility_detail_screen';
  static const String coachDetailScreen = '/coach_detail_screen';
  static const String facilityCoachReviewScreen = '/facility_coach_review_screen';
  static const String cancelSelectedSlotAppointmentScreen = '/cancel_selected_slot_appointment_screen';
  static const String filterViewScreen = '/filter_view_screen';
  static const String reviewAppointmentScreen = '/review_appointment_screen';
  static const String appointmentsScreen = '/appointments_screen';
  static const String appointmentDetailsScreen = '/appointment_detail_screen';
  static const String cancelAppointmentReasonScreen = '/cancel_appointment_reason_screen';
  static const String cancelAppointmentScreen = '/cancel_appointment_screen';
  static const String activityInterestFilterScreen = '/activity_interest_filter_screen';
  static const String coachActivityInterestFilterScreen = '/coach_activity_interest_filter_screen';
  static const String editFacilitySetup = '/edit_facility_setup';
  static const String editBatchSetup = '/edit_batch_setup';
  static const String endUserType = "E";
  static const String facilityType = "F";
  static const String coachType = "C";
  static const String profileCoach = '/coach_profile';
  static const String profileFacility = '/facility_profile';
  static const String profileEndUser = '/end_user_profile';
  static const String addTrainingAddress = '/add_training_address_screen';
  static const String comingSoonScreen = '/coming_soon_screen';
  static const String endUserTrainingAddress = '/end_user_address';
  static const String slotManagementCaledaerScreen = '/slot_management_caledaer_screen';
  static const String slotSelectionScreen = '/slot_selection_screen';
  static const String coachSlotSelectionScreen = '/coach_slot_selection_screen';
  static const String coachReviewBookingScreen = '/coach_review_booking_screen';
  static const String endUserAppointmentScreen = '/end_user_appointment_screen';
  static const String facilityAppointmentScreen = '/facility_appointment_screen';
  static const String coachAppointmentScreen = '/coach_appointment_screen';
  static const String facilityAppointmentDetailScreen = '/facility_appointment_detail_screen';
  static const String coachAppointmentDetailScreen = '/coach_appointment_detail_screen';
  static const String facilityCancelSlotScreen = '/facility_cancel_slot_screen';
  static const String coachBatchCancelSlotScreen = '/coach_batch_cancel_slot_screen';
  static const String cancelReasonScreen = '/cancel_reason_screen';
  static const String endUserCalendarScreen = '/end_user_calendar_screen';
  static const String coachVacationScreen = '/coach_vacation_screen';
  static const String coachVacationListScreen = '/coach_vacation_list_screen';
  static const String endUserAppointmentFacilityDetails = '/end_user_appointment_facility_details';
  static const String endUserAppointmentCoachDetails = '/end_user_appointment_coach_details';
  static const String facilityEndUserCancelAppointment = '/facility_end_user_cancel_appointment';
  static const String coachEndUserCancelAppointment = '/coach_end_user_cancel_appointment';
  static const String facilityCancelAppointmentReason = '/facility_cancel_appointment_reason';
  static const String coachCancelAppointmentReason = '/coach_cancel_appointment_reason';
  static const String homeScreenActivitySelectionScreen = '/home_screen_activity_selection_screen';
  static const String selectedActivityHomeScreen = 'selected_home_screen_home_activity';
  static const String searchBuddiesScreen = '/search_buddies_screen';
  static const String groupListScreen = '/group_list_screen';
  static const String myFriendsScreen = '/my_friends_screen';
  static const String buddiesProfileScreen = '/buddies_profile_screen';
  static const String addParticipantScreen = '/add_participant_screen';
  static const String createChatScreen = '/create_chat_screen';
  static const String createGroupScreen = '/create_group_screen';
  static const String groupDetailScreen = '/group_detail_screen';
  static const String groupInfoScreen = '/group_info_screen';
  static const String friendChatScreen = '/friend_chat_screen';
  static const String directFriendChatScreen = '/direct_friend_chat_screen';
  static const String groupChatScreen = '/group_chat_screen';
  static const String directGroupChatScreen = '/direct_group_chat_screen';
  static const String facilityVerifyCancelApppointment = '/verify_facility_cancel_appointment';
  static const String coachVerifyCancelApppointment = '/verify_coach_cancel_appointment';
  static const String addMeetup = '/add_meetup_screen';
  static const String listMeetup = '/list_meetup_screen';
  static const String meetupDetails = '/details_meetup_screen';
  static const String notification = '/notification_screen';
  static const String transaction = '/transaction_screen';
  static const String enduserCancellationRequestPage = '/enduser_cancellation_request_list_screen';
  static const networkIssueScreen = '/network_issue_screen';
  static const String webViewScreens = '/webview_screen';
  static const String facilityFavoritesList = '/favorites_facility_list';
  static const String coachFavoritesList = '/favorites_coach_list';
  static const String couponScreen = '/coupon_screen';
  static const String referEarnScreen = '/refer_earn_screen';
  static const String bazaarHomeScreen = '/baazar_home_screen';
  static const String addAdsScreen = '/add_ads_screen';
  static const String sellProductListScreen = '/sell_product_list_screen';
  static const String sellProductDetailScreen = '/sell_product_detail_screen';
  static const String chatDetailsScreen = '/chat_details_screen';
  static const String sellProductScreen = '/sell_product_screen';
  static const String buyingChatScreen = '/buying_chat_screen';
  static const String sellingChatScreen = '/selling_chat_screen';

  static List<PopularSportsResponseModel>? categoryList;

  static const String internetConnectionErrorMsg = 'Offline. Please check your internet connection';

  // static const int timeOutValueInSeconds = 30;
  static const double androidAppVersion = 2.5; //latest version 2.4 to 2.5 - App version 2.5
  static const double iosAppVersion = 2.5; //latest version 2.4 to 2.5 - iOS version 2.5
  static const String accountCloseErrorMsg = 'Your account will be closed in a few minutes and you will no longer be able to use this account';
  int isAppInBackground = 0;
}

class CommonException implements Exception {
  final int code;
  final dynamic message;

  CommonException({this.code = 500, this.message = "Error occured!!!"});

  @override
  String toString() => 'CommonException($code, $message)';
}

void showSnackBar(String text, BuildContext context) {
  Fluttertoast.showToast(
    msg: text,
    fontSize: 14,
  );
  // ScaffoldMessenger.of(context).showSnackBar(
  //   SnackBar(
  //     content: Text(text, style: const TextStyle(fontSize: 14), maxLines: 5),
  //   ),
  // );
}

void showSnackBarColor(String text, BuildContext context, bool isError) {
  // Fluttertoast.showToast(
  //   msg: text,
  //   fontSize: 14,
  //   textColor: OQDOThemeData.whiteColor,
  //   backgroundColor: isError ? OQDOThemeData.errorColor : OQDOThemeData.successColor,
  // );
  if (isNoInternetConnectionSnackBarVisible) return;
  var snackBar = SnackBar(
      content: CustomTextView(
          label: text,
          maxLine: 5,
          textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(color: OQDOThemeData.whiteColor, fontSize: 16.0, fontWeight: FontWeight.w500)),
      backgroundColor: isError ? OQDOThemeData.errorColor : OQDOThemeData.successColor,
      behavior: SnackBarBehavior.floating);

  rootScaffoldMessangerKey.currentState?.removeCurrentSnackBar();
  rootScaffoldMessangerKey.currentState?.showSnackBar(snackBar);

  // ScaffoldMessenger.of(context).showSnackBar(
  //   SnackBar(
  //       content: CustomTextView(
  //           label: text, maxLine: 5, textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(color: OQDOThemeData.whiteColor, fontSize: 16.0, fontWeight: FontWeight.w500)),
  //       backgroundColor: isError ? OQDOThemeData.errorColor : OQDOThemeData.successColor,
  //       behavior: SnackBarBehavior.floating),
  // );
}

bool isNoInternetConnectionSnackBarVisible = false;

void showNoInternetConnectionSnackBar() {
  isNoInternetConnectionSnackBarVisible = true;
  var snackBar = SnackBar(
    content: CustomTextView(
        label: Constants.internetConnectionErrorMsg,
        maxLine: 5,
        textStyle: const TextStyle(color: OQDOThemeData.whiteColor, fontSize: 16.0, fontWeight: FontWeight.w500)),
    backgroundColor: OQDOThemeData.errorColor,
    behavior: SnackBarBehavior.floating,
    dismissDirection: DismissDirection.none,
    duration: const Duration(days: 1),
  );

  rootScaffoldMessangerKey.currentState?.removeCurrentSnackBar();
  rootScaffoldMessangerKey.currentState?.showSnackBar(snackBar);
}

void dismissNoInternetConnectionSnackBar() {
  isNoInternetConnectionSnackBarVisible = false;
  rootScaffoldMessangerKey.currentState?.removeCurrentSnackBar();
}

void showSnackBarErrorColor(String text, BuildContext context, bool isError) {
  if (isNoInternetConnectionSnackBarVisible) return;

  var snackBar = SnackBar(
    content: CustomTextView(
        label: text,
        maxLine: 5,
        textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(color: OQDOThemeData.whiteColor, fontSize: 16.0, fontWeight: FontWeight.w500)),
    backgroundColor: isError ? OQDOThemeData.errorColor : OQDOThemeData.successColor,
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 5),
  );

  rootScaffoldMessangerKey.currentState?.removeCurrentSnackBar();
  rootScaffoldMessangerKey.currentState?.showSnackBar(snackBar);

  // ScaffoldMessenger.of(context).showSnackBar(
  //   ,
  // );
}

String checkForPlatForm(BuildContext context) {
  String platForm = '';

  if (Theme.of(context).platform == TargetPlatform.iOS) {
    platForm = "IOSApp";
  } else {
    platForm = "AndroidApp";
  }
  return platForm;
}

void hideKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}

void showLog(String msg) {
  if (kDebugMode) {
    print('LOG -> $msg');
  }
}

String convertUtcToSgt(String utcTimeString) {
  // Parse the UTC time string to a DateTime object
  DateTime utcDateTime = DateTime.parse(utcTimeString);

  // checking the time zone in config

  var hours = (OQDOApplication.instance.configResponseModel?.timeZoneId ?? "").contains("Singapore") ? 8 : 5;

  var minutes = (OQDOApplication.instance.configResponseModel?.timeZoneId ?? "").contains("Singapore") ? 0 : 30;

  // Calculate the Singapore Time (SGT) offset (UTC+8)
  Duration sgtOffset = Duration(hours: hours, minutes: minutes);

  // Add the offset to the UTC time to get SGT time
  DateTime sgtDateTime = utcDateTime.add(sgtOffset);

  // Format the SGT time as a string
  String sgtTimeString = sgtDateTime.toLocal().toString();

  return sgtTimeString;
}

Future<void> checkAndSetOSVersionOfAndroid() async {
  //OS version
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  Constants.androidVersion = double.parse(androidInfo.version.release);
  debugPrint("============== Android Version is ${Constants.androidVersion} ===============");
}

Duration convertMinutesToDuration(int totalMinutes) {
  if (totalMinutes < 0) {
    return const Duration(hours: 0, minutes: 0);
  }

  int hours = totalMinutes ~/ 60;
  int minutes = totalMinutes % 60;

  return Duration(hours: hours, minutes: minutes);
}

Future<bool> hasNetwork() async {
  try {
    var result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({this.decimalRange}) : assert(decimalRange == null || decimalRange > 0);

  final int? decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    if (decimalRange != null) {
      String value = newValue.text;

      if (value.contains(".") && value.substring(value.indexOf(".") + 1).length > (decimalRange ?? 2)) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      } else if (value == ".") {
        truncated = "0.";

        newSelection = newValue.selection.copyWith(
          baseOffset: math.min(truncated.length, truncated.length + 1),
          extentOffset: math.min(truncated.length, truncated.length + 1),
        );
      }

      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return newValue;
  }
}
