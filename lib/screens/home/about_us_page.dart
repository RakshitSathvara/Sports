import 'dart:math';

import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';

import '../../helper/helpers.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  TextEditingController oldPassword = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confrimPassword = TextEditingController();
  bool isvisible = true;
  late Helper hp;

  @override
  void initState() {
    super.initState();
    hp = Helper.of(context);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: CustomAppBar(
          title: 'About Us',
          onBack: () {
            Navigator.of(context).pop();
          }),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).colorScheme.onBackground,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(children: [
                  const SizedBox(
                    height: 16,
                  ),
                  CustomTextView(
                    label:
                        '   Welcome to oqdo™ the one-stop-shop that connects all sports (and hobby) enthusiasts with each other!\n   oqdo™ is designed to make it easy for you to find exactly what you’re looking for. Whether it be buddies to play tennis with, or a basketball court to book for you and your friends; or even a coach to teach you how to spin a football just right – we’ve got you covered!\n   Our mission is to improve and further boost accessibility to the world of sports (and hobbies) and we have created a space where enthusiasts, coaches and facilities alike can come together to help us on this journey – so sign up to oqdo™ today and let’s get moving!',
                    type: styleSubTitle,
                    maxLine: 30,
                    textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.black),
                  ),
                ]),
              ),
              const SizedBox(
                height: 32,
              ),
              // Align(
              //   alignment: Alignment.center,
              //   child: Row(
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Image.asset(
              //         "assets/images/ic_fb.png",
              //         width: 35,
              //         fit: BoxFit.contain,
              //       ),
              //       const SizedBox(
              //         width: 20,
              //       ),
              //       Image.asset(
              //         "assets/images/ic_twitter.png",
              //         width: 35,
              //         fit: BoxFit.contain,
              //       ),
              //       const SizedBox(
              //         width: 20,
              //       ),
              //       Image.asset(
              //         "assets/images/ic_insta.png",
              //         width: 35,
              //         fit: BoxFit.contain,
              //       ),
              //       const SizedBox(
              //         width: 20,
              //       ),
              //       Image.asset(
              //         "assets/images/ic_linked.png",
              //         width: 35,
              //         fit: BoxFit.contain,
              //       ),
              //     ],
              //   ),
              // ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: height / 1.50,
                decoration: const BoxDecoration(
                  image: DecorationImage(image: AssetImage('assets/images/about_bg.png'), fit: BoxFit.contain),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
