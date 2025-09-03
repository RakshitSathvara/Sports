import 'dart:math';

import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/helper/helpers.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewOrderDetailPage extends StatefulWidget {
  @override
  _ViewOrderDetailPageState createState() => _ViewOrderDetailPageState();
}

class _ViewOrderDetailPageState extends State<ViewOrderDetailPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();

  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  double get radius => sqrt(pow(width, 2) + pow(height, 2));
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
      key: scaffoldKey,
      appBar: CustomAppBar(
        title: 'View Order',
        onBack: () {
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
          child: Container(
              width: width,
              height: height,
              color: Theme.of(context).colorScheme.onBackground,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 130.0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                      child: Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: 4.0,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                border: Border.all(width: 7.0, color: ColorsUtils.vacationList),
                              ),
                            ),
                            const SizedBox(width: 20.0),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomTextView(
                                            label: "Raj Malhotra",
                                            textStyle:
                                                Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 18)),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                          child: CustomTextView(
                                              label: "Order ID: 12345",
                                              textStyle:
                                                  Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.shadow, fontSize: 12)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    CustomTextView(
                                        label: "Email ID: raj@gmail.com ",
                                        textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.shadow, fontSize: 12)),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    CustomTextView(
                                        label: "Phone: 9999999999",
                                        textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.shadow, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: 2,
                      separatorBuilder: (context, index) {
                        return const Divider(
                          endIndent: 18,
                          indent: 18,
                        );
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextView(
                                label: '15 April - Friday',
                                type: styleSubTitle,
                                textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                              ),
                              const SizedBox(
                                height: 7,
                              ),
                              CustomTextView(
                                label: '15:00-16:00',
                                type: styleSubTitle,
                                textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      color: Theme.of(context).colorScheme.shadow,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 12,
                                    ),
                              ),
                            ],
                          ),
                        );
                      }),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: CustomTextView(
                        label: "Status: BLOCKED ",
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600, fontSize: 18)),
                  ),
                  const SizedBox(height: 3),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: CustomTextView(
                        label: "Order ID: 12354 ",
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w400, fontSize: 14)),
                  ),
                  const SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomTextView(
                            label: "Total Amount",
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600, fontSize: 16)),
                        CustomTextView(
                            label: '\$ 60/ hour ',
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w400, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ))),
    );
  }
}
