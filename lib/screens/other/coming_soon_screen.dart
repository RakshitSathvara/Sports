import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '',
        onBack: () {
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: Image.asset(
              'assets/images/ic_coming_soon.png',
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}
