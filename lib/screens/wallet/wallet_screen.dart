import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: CustomTextView(
          label: 'Wallet',
          textStyle: const TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Image.asset(
                'assets/images/ic_back.png',
                color: Colors.black,
                fit: BoxFit.contain,
              ),
              onPressed: () {
                /// Implement back funcationallity
              },
            );
          },
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              availableBalanceView(),
              Container(padding: const EdgeInsets.only(left: 10.0, right: 15.0, top: 10.0), child: availableAndBlockedBalanceView()),
            ],
          ),
        ),
      ),
    );
  }

  Widget availableBalanceView() {
    return Container(
      padding: const EdgeInsets.only(left: 15.0, right: 15, top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextView(
                label: '10000.00 \$',
                textStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25.0),
              ),
              const SizedBox(
                height: 5.0,
              ),
              CustomTextView(
                label: 'Available Balance',
                textStyle: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.black),
              )
            ],
          ),
          Stack(
            children: [
              // Container(
              //   alignment: Alignment.bottomRight,
              //   decoration: BoxDecoration(
              //     shape: BoxShape.circle,
              //     border: Border.all(width: 10.0, color: Colors.green),
              //   ),
              // ),
              Container(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset('assets/images/ic_user_mock.png'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget availableAndBlockedBalanceView() {
    return Container(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0, bottom: 20.0),
      color: Theme.of(context).colorScheme.primary,
      child: Row(
        children: [
          Column(
            children: [
              CustomTextView(
                label: '2000.00 \$',
                textStyle: const TextStyle(color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.bold),
              ),
              CustomTextView(label: 'Blocked Balance'),
            ],
          ),
          Column(
            children: [
              CustomTextView(
                label: '2000.00 \$',
                textStyle: const TextStyle(color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.bold),
              ),
              CustomTextView(label: 'Blocked Balance'),
            ],
          ),
        ],
      ),
    );
  }
}
