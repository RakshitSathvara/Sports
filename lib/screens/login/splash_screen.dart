import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/helper/helpers.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/ConnectivityService.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  MySplashState createState() => MySplashState();
}

class MySplashState extends State<Splash> {
  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  late Helper hp;

  @override
  void initState() {
    checkInternetConnectivity();
    removeOneSignalNotification();
    super.initState();
  }

  Future<void> removeOneSignalNotification() async {
    try {
      await OneSignal.Notifications.clearAll();
    } catch (_) {}
  }

  Future<void> checkInternetConnectivity() async {
    bool isConnected = await ConnectivityService.isInternetConnected();
    if (isConnected) {
      hp = Helper.of(context);
      Timer(const Duration(seconds: 2), () async {
        String? countryName = OQDOApplication.instance.storage
            .getStringValue(AppStrings.selectedCountryName);
        OQDOApplication.instance.isLogin =
            OQDOApplication.instance.storage.getStringValue(AppStrings.isLogin);
        OQDOApplication.instance.userType = OQDOApplication.instance.storage
            .getStringValue(AppStrings.userType);
        OQDOApplication.instance.endUserID = OQDOApplication.instance.storage
            .getStringValue(AppStrings.endUserId);
        OQDOApplication.instance.coachID =
            OQDOApplication.instance.storage.getStringValue(AppStrings.coachId);
        OQDOApplication.instance.facilityID = OQDOApplication.instance.storage
            .getStringValue(AppStrings.facilityId);
        OQDOApplication.instance.userID =
            OQDOApplication.instance.storage.getStringValue(AppStrings.userId);
        OQDOApplication.instance.tokenType = OQDOApplication.instance.storage
            .getStringValue(AppStrings.tokenType);
        OQDOApplication.instance.token =
            OQDOApplication.instance.storage.getStringValue(AppStrings.token);
        // print(countryName);
        navigate(countryName);
      });
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.network_check_rounded,
                  color: Colors.red,
                  size: 100.0,
                ),
                const SizedBox(height: 10.0),
                CustomTextView(
                  maxLine: 4,
                  textOverFlow: TextOverflow.ellipsis,
                  label: "Slow or No Internet.",
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: OQDOThemeData.blackColor,
                        fontSize: 20,
                      ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  "Please check your internet settings",
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: OQDOThemeData.blackColor,
                        fontSize: 16,
                      ),
                ),
                const SizedBox(height: 20.0),
                MyButton(
                  text: 'Retry',
                  textcolor: Theme.of(context).colorScheme.onBackground,
                  textsize: 14,
                  fontWeight: FontWeight.w500,
                  letterspacing: 0.7,
                  buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                  buttonbordercolor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  buttonheight: 40.0,
                  buttonwidth: 100,
                  radius: 15,
                  onTap: () async {
                    Navigator.of(context).pop(false);
                    checkInternetConnectivity();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  navigate(String token) async {
    if (token.isEmpty) {
      // if (OQDOApplication.instance.isLogin!.isEmpty || OQDOApplication.instance.isLogin == null || OQDOApplication.instance.isLogin! == '0') {
      await Navigator.pushNamedAndRemoveUntil(
          context, Constants.LOCATIONCHOOSEPAGE, Helper.of(context).predicate);
      // } else {
      //   await Navigator.pushNamedAndRemoveUntil(context, Constants.APPPAGES, Helper.of(context).predicate, arguments: 0);
      // }
    } else {
      await Navigator.pushNamedAndRemoveUntil(
          context, Constants.APPPAGES, Helper.of(context).predicate,
          arguments: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: height / 1.7,
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/splash_bg_main.png'),
                  fit: BoxFit.fill),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Image.asset(
              "assets/images/logo.png",
              height: height / 8,
              width: width / 2,
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Image.asset('assets/images/splash_text.png'),
        ],
      ),
    );
  }
}
