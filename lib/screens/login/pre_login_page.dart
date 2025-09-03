import 'dart:math';

import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_edit_text.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';

class PreLoginPage extends StatefulWidget {
  @override
  _PreLoginPageState createState() => _PreLoginPageState();
}

class _PreLoginPageState extends State<PreLoginPage> {
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(width, 2) + pow(height, 2));

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var ph = MediaQuery.of(context).size.height;
    // TODO: implement build
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).colorScheme.onBackground,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.topLeft,
                children: [
                  Image.asset("assets/images/login_bg.png"),
                  Positioned(
                    top: 100,
                    left: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          "assets/images/logo.png",
                          height: 90,
                          width: 120,
                        ),
                        const Text(
                          'Welcome',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff595959)),
                        ),
                        const Text(
                          'Back!',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff595959)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    MyButton(
                      text: "Sign In",
                      textcolor: Theme.of(context).colorScheme.onBackground,
                      textsize: 16,
                      fontWeight: FontWeight.w600,
                      letterspacing: 0.7,
                      buttoncolor:
                          Theme.of(context).colorScheme.secondaryContainer,
                      buttonbordercolor:
                          Theme.of(context).colorScheme.secondaryContainer,
                      buttonheight: 50,
                      buttonwidth: width,
                      radius: 15,
                      onTap: () async {
                        await Navigator.pushNamed(context, Constants.LOGIN);
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    MyButton(
                      text: "Sign Up",
                      textcolor:
                          Theme.of(context).colorScheme.secondaryContainer,
                      textsize: 16,
                      fontWeight: FontWeight.w600,
                      letterspacing: 0.7,
                      buttoncolor: Theme.of(context).colorScheme.onBackground,
                      buttonbordercolor:
                          Theme.of(context).colorScheme.secondaryContainer,
                      buttonheight: 50,
                      buttonwidth: width,
                      radius: 15,
                      onTap: () async {
                        await Navigator.pushNamed(
                            context, Constants.PREREGISTER);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
