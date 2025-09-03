import 'dart:math';

import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helper/helpers.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({Key? key}) : super(key: key);

  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    hp = Helper.of(context);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: 'Contact Us',
        onBack: () {
          Navigator.of(context).pop();
        },
        isIconColorBlack: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        isTextColor: false,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).colorScheme.onBackground,
        child: SingleChildScrollView(
          child: Form(
            key: hp.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 200,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        Positioned(
                          top: 50,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Image.asset(
                                  "assets/images/contact_us_icon.png",
                                  width: 400,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 150,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(children: [
                    const Icon(
                      Icons.call,
                      size: 24,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    CustomTextView(
                      label: 'Phone Number',
                      type: styleSubTitle,
                      textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    GestureDetector(
                      onTap: () {
                        openDialApp();
                      },
                      child: CustomTextView(
                        label: '+65 84247072',
                        type: styleSubTitle,
                        textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(
                  height: 24,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(children: [
                    const Icon(
                      Icons.email_outlined,
                      size: 24,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    CustomTextView(
                      label: 'Email ID',
                      type: styleSubTitle,
                      textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    GestureDetector(
                      onTap: () {
                        openMailApp();
                      },
                      child: CustomTextView(
                        label: 'admin@oqdo.com',
                        type: styleSubTitle,
                        textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(
                  height: 24,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(children: [
                    const Icon(
                      Icons.location_on_sharp,
                      size: 24,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    CustomTextView(
                      label: 'Location',
                      type: styleSubTitle,
                      textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Flexible(
                      child: CustomTextView(
                        label: '60 Paya Lebar Road\n#07-54 Paya Lebar Square\nSingapore 409051',
                        type: styleSubTitle,
                        maxLine: 5,
                        textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(
                  height: 60,
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 24),
                //   child: CustomTextView(
                //     label: 'Or Find Us On Social Media',
                //     type: styleSubTitle,
                //     textStyle: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface),
                //   ),
                // ),
                // const SizedBox(
                //   height: 24,
                // ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 24),
                //   child: Row(
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
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void openMailApp() async {
    Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'admin@oqdo.com',
    );

    await launchUrl(emailLaunchUri);
  }

  void openDialApp() async {
    Uri dialLaunchUri = Uri(
      scheme: 'tel',
      path: '+65 84247072',
    );

    await launchUrl(dialLaunchUri);
  }
}
