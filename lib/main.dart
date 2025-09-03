import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/utils/analytics_helper.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/shared_preferences_manager.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessangerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AnalyticsHelper.init();
  await SharedPreferencesManager().initialize();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // transparent status bar
    ),
  );

  await OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize(Constants.oneSignalAppId);
  OneSignal.Notifications.requestPermission(true);


  getToken();

  if (Platform.isAndroid) {
    await checkAndSetOSVersionOfAndroid();
  }

  Stripe.publishableKey = Constants.stripeKey;
  Stripe.merchantIdentifier = 'merchant.com.oqdo';
  await Stripe.instance.applySettings();

  runApp(OQDOApplication());
}

getToken() async {
  var deviceState = await OneSignal.User.getOnesignalId();
  if (deviceState == null || deviceState.isEmpty) return;

  final pushSubscription = OneSignal.User.pushSubscription;
  print("IsSubscribed (main) Id ===> ${pushSubscription.id}");
  print("IsSubscribed (main) optedIn ===> ${pushSubscription.optedIn}");

  if (pushSubscription.optedIn == true) {
    OQDOApplication.instance.fcmToken = pushSubscription.id;
    print("IsSubscribed fcmToken 1 ===> ${OQDOApplication.instance.fcmToken}");
  } else {
    await pushSubscription.optIn();

    pushSubscription.addObserver((state) {
      print(
          "IsSubscribed (main) optedIn ===> ${OneSignal.User.pushSubscription.optedIn}");
      print(
          "IsSubscribed (main) id ===> ${OneSignal.User.pushSubscription.id}");
      print(
          "IsSubscribed (main) token ===> ${OneSignal.User.pushSubscription.token}");
      print(
          "IsSubscribed (main) json ===> ${state.current.jsonRepresentation()}");

      OQDOApplication.instance.fcmToken = OneSignal.User.pushSubscription.id;
      print(
          "IsSubscribed (main) fcmToken 2 ===> ${OQDOApplication.instance.fcmToken}");
    });
  }
}
