import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';

class NetworkIssueScreen extends StatefulWidget {
  const NetworkIssueScreen({super.key});

  @override
  State<NetworkIssueScreen> createState() => _NetworkIssueScreenState();
}

class _NetworkIssueScreenState extends State<NetworkIssueScreen> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    // initConnectivity();

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // // Platform messages are asynchronous, so we initialize in an async method.
  // Future<void> initConnectivity() async {
  //   late ConnectivityResult result;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     result = await _connectivity.checkConnectivity();
  //   } on PlatformException catch (e) {
  //     developer.log('Couldn\'t check connectivity status', error: e);
  //     return;
  //   }
  //
  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) {
  //     return Future.value(null);
  //   }
  //
  //   return _updateConnectionStatus(result);
  // }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
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
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: MyButton(
                text: 'Retry',
                textcolor: Theme.of(context).colorScheme.onBackground,
                textsize: 14,
                fontWeight: FontWeight.w500,
                letterspacing: 0.7,
                buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                buttonheight: 40.0,
                buttonwidth: 100,
                radius: 15,
                onTap: () async {
                  // CHECK FOR INTERNET
                  var result = await _connectivity.checkConnectivity();
                  if (result.contains(ConnectivityResult.wifi) || result.contains(ConnectivityResult.mobile)) {
                    await Navigator.pushNamedAndRemoveUntil(context, Constants.APPPAGES, (Route<dynamic> route) => false, arguments: 0);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
