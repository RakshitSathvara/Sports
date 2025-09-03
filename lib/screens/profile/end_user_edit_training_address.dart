import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';

class EndUserEditAddressScreen extends StatefulWidget {
  const EndUserEditAddressScreen({Key? key}) : super(key: key);

  @override
  State<EndUserEditAddressScreen> createState() => _EndUserEditAddressScreenState();
}

class _EndUserEditAddressScreenState extends State<EndUserEditAddressScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Training Address',
        onBack: () {
          Navigator.pop(context);
        },
      ),
      backgroundColor: Theme.of(context).colorScheme.onBackground,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 40),
          width: double.infinity,
          height: double.infinity,
          child: const SingleChildScrollView(
            child: Column(
              children: [],
            ),
          ),
        ),
      ),
    );
  }
}
