import 'dart:math';

import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';

class ChooseServiceProviderPage extends StatefulWidget {
  const ChooseServiceProviderPage({super.key});

  @override
  _ChooseServiceProviderPageState createState() => _ChooseServiceProviderPageState();
}

class _ChooseServiceProviderPageState extends State<ChooseServiceProviderPage> {
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
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: OQDOThemeData.backgroundColor,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.topLeft,
                children: [
                  Container(
                    width: width / 1.1,
                    height: height / 2.1,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage('assets/images/login_bg.png'),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 100,
                    left: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          "assets/images/logo.png",
                          height: 200,
                          width: 180,
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20.0,
                    ),
                    CustomTextView(
                      label: 'Type of Service Provider',
                      type: styleSubTitle,
                      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: const Color(0xFF3A3A3A), fontWeight: FontWeight.w400, fontSize: 20.0),
                    ),
                    const SizedBox(
                      height: 60,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: MyButtonWithoutBackground(
                        text: "Facility",
                        textcolor: Theme.of(context).colorScheme.secondaryContainer,
                        textsize: 16.0,
                        fontWeight: FontWeight.w600,
                        letterspacing: 1.0,
                        buttoncolor: OQDOThemeData.backgroundColor,
                        buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                        buttonheight: 60,
                        buttonwidth: width,
                        radius: 15,
                        onTap: () async {
                          await Navigator.pushNamed(context, Constants.FACILITYADD);
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: MyButtonWithoutBackground(
                        text: "Coach",
                        textcolor: Theme.of(context).colorScheme.secondaryContainer,
                        textsize: 16,
                        fontWeight: FontWeight.w600,
                        letterspacing: 1.0,
                        buttoncolor: OQDOThemeData.backgroundColor,
                        buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                        buttonheight: 60,
                        buttonwidth: width,
                        radius: 15,
                        onTap: () async {
                          await Navigator.pushNamed(context, Constants.COACHADD);
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 30,
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
