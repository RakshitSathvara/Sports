import 'dart:async';
import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/helper/helpers.dart';
import 'package:oqdo_mobile_app/main.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/screens/bazaar/ads_screen/ads_screen.dart';
import 'package:oqdo_mobile_app/screens/bazaar/ads_screen/viewmodel/ads_view_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/buy/buy_screen.dart';
import 'package:oqdo_mobile_app/screens/bazaar/chats/chats_screen.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/sell_screen.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/viewmodel/sell_viewmodel.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:provider/provider.dart';

class BazaarHomeScreen extends StatefulWidget {
  final int tabNumber;

  const BazaarHomeScreen({super.key, required this.tabNumber});

  @override
  State<BazaarHomeScreen> createState() => _BazaarHomeScreenState();
}

class _BazaarHomeScreenState extends State<BazaarHomeScreen> {
  late int index;
  bool isPageSet = false;
  late Widget page;
  String? isLogin = '0';

  @override
  void initState() {
    super.initState();
    index = widget.tabNumber;
    getData();
  }

  void getData() async {
    isLogin = OQDOApplication.instance.storage.getStringValue(AppStrings.isLogin);
    debugPrint("isLogin -> $isLogin");
    setState(() {
      selectTab(index);
    });
    // version = packageInfo.version;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          index = 0;
          selectTab(index);
          Future.value(false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          elevation: 0.0,
          leadingWidth: 0.0,
          leading: const SizedBox(),
          title: Text(
            index == 0
                ? "Home"
                : index == 1
                    ? "OQDO - Bazaar"
                    : index == 2
                        ? "OQDO - Bazaar"
                        : index == 3
                            ? "Chats"
                            : "OQDO - Advertisements",
            style: TextStyle(color: Colors.white, fontFamily: 'SFPro', fontWeight: FontWeight.w700, fontSize: 17),
          ),
          backgroundColor: const Color(0xFF006590),
        ),
        body: isPageSet ? page : ChangeNotifierProvider(create: (context) => SellViewmodel(), child: const BuyScreen()),
        bottomNavigationBar: BottomNavigationBar(
          elevation: 8,
          backgroundColor: Color(0xFFFFFFFF),
          unselectedLabelStyle: TextStyle(color: Theme.of(context).colorScheme.shadow, fontWeight: FontWeight.w500, fontSize: 12),
          selectedLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500, fontSize: 12),
          unselectedItemColor: Theme.of(context).colorScheme.shadow,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          type: BottomNavigationBarType.fixed,
          currentIndex: index,
          onTap: selectTab,
          items: [
            const BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/images/ic_bottom_home.png"),
              ),
              label: "HOME",
            ),
            const BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/images/ic_bottom_sell.png"),
              ),
              label: 'SELL',
            ),
            const BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/images/ic_bottom_buy.png"),
              ),
              label: 'BUY',
            ),
            const BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/images/ic_bottom_chats.png"),
              ),
              label: 'CHATS',
            ),
            const BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/images/ic_ads.png"),
              ),
              label: "ADS",
            ),
          ],
        ),
      ),
    );
  }

  void selectTab(int i) {
    setState(() {
      index = i;

      // Check if user is logged in for screens that require authentication
      if ((index == 1 || index == 2 || index == 3) && isLogin != '1') {
        // User not logged in and trying to access SELL, CHATS or ADS
        showSnackBarColor('Please login', context, true);
        Timer(const Duration(milliseconds: 500), () {
          Navigator.of(context).pushNamed(Constants.LOGIN);
        });
        // Reset index to previous or default tab
        index = 4; // Set to BUY screen as default
        page = ChangeNotifierProvider(create: (context) => AdsViewModel(), child: const AdsScreen());
      } else {
        // User is logged in or accessing screens that don't require login
        switch (index) {
          case 0:
            Navigator.pushNamedAndRemoveUntil(context, Constants.APPPAGES, Helper.of(context).predicate, arguments: 0);
            break;
          case 1:
            page = ChangeNotifierProvider(create: (context) => SellViewmodel(), child: const SellScreen());
            break;
          case 2:
            page = ChangeNotifierProvider(create: (context) => SellViewmodel(), child: const BuyScreen());
            break;
          case 3:
            page = const ChatsScreen();
            break;
          case 4:
            page = ChangeNotifierProvider(create: (context) => AdsViewModel(), child: const AdsScreen());
            break;
          default:
            page = ChangeNotifierProvider(create: (context) => SellViewmodel(), child: const BuyScreen());
            break;
        }
      }
      isPageSet = true;
    });
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to exit a Bazaar?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  // Future<bool> onWillPop() async {
  //   return await showDialog(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //           title: const Text('Are you sure?'),
  //           content: const Text('Do you want to exit a Bazaar?'),
  //           actions: <Widget>[
  //             TextButton(
  //               onPressed: () => Navigator.of(context).pop(false),
  //               child: const Text('No'),
  //             ),
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //                 Navigator.of(context).pop();
  //               },
  //               child: const Text('Yes'),
  //             ),
  //           ],
  //         ),
  //       ) ??
  //       false;
  // }
}
