import 'dart:math';

import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/helper/helpers.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';

class CancellationRequestPage extends StatefulWidget {
  const CancellationRequestPage({Key? key}) : super(key: key);

  @override
  _CancellationRequestPageState createState() => _CancellationRequestPageState();
}

class _CancellationRequestPageState extends State<CancellationRequestPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();

  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  late Helper hp;
  List<bool> _isChecked = [];

  @override
  void initState() {
    super.initState();
    hp = Helper.of(context);

    // facility length
    _isChecked = List<bool>.filled(3, false);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onBackground,
      key: scaffoldKey,
      appBar: CustomAppBar(
        title: 'Cancellation Request',
        onBack: () {
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 0),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 12.0),
                  child: createFacilityList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                child: MyButton(
                  text: "Submit",
                  textcolor: Theme.of(context).colorScheme.onBackground,
                  textsize: 16,
                  fontWeight: FontWeight.w600,
                  letterspacing: 0.7,
                  buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                  buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                  buttonheight: 50,
                  buttonwidth: width,
                  radius: 15,
                  onTap: () async {
                    if (hp.formKey.currentState!.validate()) {
                      // await Navigator.pushNamed(
                      //     context, Constants.FORGOTOTPVERIFICATION);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget createFacilityList() {
    return ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: 3,
        separatorBuilder: (context, index) {
          return const Divider();
        },
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 6, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 50.0,
                  width: 50.0,
                  child: Transform.scale(
                    scale: 1.4,
                    child: Checkbox(
                      value: _isChecked[index],
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (val) {
                        setState(() {
                          _isChecked[index] = val!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextView(
                      label: '15 April - Friday ',
                      type: styleSubTitle,
                      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 6.0),
                    CustomTextView(
                      label: '14:00 - 15:00',
                      type: styleSubTitle,
                      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: ColorsUtils.chipText, fontSize: 12),
                    ),
                    const SizedBox(height: 6.0),
                    CustomTextView(
                      label: 'Initiated On - 18-04-2022, 09:30',
                      type: styleSubTitle,
                      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: ColorsUtils.chipText, fontSize: 12),
                    ),
                    CustomTextView(
                      label: 'Time Left to Reject 02:30:00',
                      type: styleSubTitle,
                      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: ColorsUtils.chipText, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}
