import 'dart:math';

import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/model/transaction_list_response.dart';
import 'package:oqdo_mobile_app/screens/home/all_transaction_list.dart';
import 'package:oqdo_mobile_app/screens/home/refund_transaction_list.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';

import '../../helper/helpers.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({Key? key}) : super(key: key);

  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  MediaQueryData get dimensions => MediaQuery.of(context);
  final ScrollController _scrollController = ScrollController();

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  late Helper hp;
  List<Transaction> transactions = [];
  bool isLoading = false;
  int pageCount = 0;
  int resultPerPage = 20;
  int totalCount = 0;
  TabController? controller;
  int selectedTab = 1;

  @override
  void initState() {
    super.initState();
    hp = Helper.of(context);
    controller = TabController(length: 2, vsync: this);
    controller!.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
              title: 'Transaction History',
              onBack: () {
                Navigator.of(context).pop();
              }),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 0),
                child: Container(
                  decoration: BoxDecoration(
                    // shape: BoxShape.circle,
                    color: ColorsUtils.greyTab,
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                  ),
                  child: SizedBox(
                    child: TabBar(
                      controller: controller,
                      isScrollable: false,
                      labelPadding: const EdgeInsets.all(0),
                      indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          // Creates border
                          color: Theme.of(context).colorScheme.primary),
                      onTap: (value) {
                        setState(() {});
                      },
                      //Change background color from here
                      tabs: [
                        Tab(
                            child: CustomTextView(
                          label: 'Payments',
                          textStyle: TextStyle(fontSize: 16, color: controller!.index == 0 ? OQDOThemeData.whiteColor : Theme.of(context).colorScheme.primary),
                        )),
                        Tab(
                            child: CustomTextView(
                          label: 'Refunds',
                          textStyle: TextStyle(fontSize: 16, color: controller!.index == 1 ? OQDOThemeData.whiteColor : Theme.of(context).colorScheme.primary),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  // physics: const NeverScrollableScrollPhysics(),
                  controller: controller,
                  children: const [
                    AllTransactionList(),
                    RefundTransactionList(),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
