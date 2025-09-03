import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/model/common_passing_args.dart';

import '../../model/get_all_activity_and_sub_activity_response.dart';
import '../../theme/oqdo_theme_data.dart';
import '../../utils/custom_text_view.dart';
import '../../utils/utilities.dart';

class ActivityInterestFilterScreen extends StatefulWidget {
  final CommonPassingArgs commonPassingArgs;

  const ActivityInterestFilterScreen({Key? key, required this.commonPassingArgs}) : super(key: key);

  @override
  State<ActivityInterestFilterScreen> createState() => _ActivityInterestFilterScreenState();
}

class _ActivityInterestFilterScreenState extends State<ActivityInterestFilterScreen> {
  String selectedValue = '';
  List<SubActivitiesBean> selectedValuesFromKey = [];
  Map<String, List<SelectedFilterValues>> selectedValues = {};
  List<String> selectedSubValue = [];
  Map<int, bool> itemsSelectedValue = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // print(widget.commonPassingArgs.endUserActivitySelection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          for (int i = 0; i < widget.commonPassingArgs.endUserActivitySelection!.length; i++) {
            String key = widget.commonPassingArgs.endUserActivitySelection!.keys.elementAt(i);
            List<SubActivitiesBean> values = widget.commonPassingArgs.endUserActivitySelection![key];
            List<SelectedFilterValues> data = [];
            for (int j = 0; j < values.length; j++) {
              values[j].selectedValue = false;
            }
          }

          // for (int j = 0; j < selectedValuesFromKey.length; j++) {
          //   if (selectedValuesFromKey[j].selectedValue!) {
          //     selectedValuesFromKey[j].selectedValue = false;
          //   }
          // }
          // selectedSubValue = null;
          Navigator.of(context).pop(null);
          return false;
        },
        child: SafeArea(
          child: Container(
            color: OQDOThemeData.backgroundColor,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20.0,
                ),
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 130.0,
                    width: 200.0,
                  ),
                ),
                topView(),
                const SizedBox(
                  height: 50.0,
                ),
                const Divider(
                  height: 1.0,
                  color: OQDOThemeData.filterDividerColor,
                ),
                Expanded(child: filterView()),
                bottomBtnView(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget bottomBtnView() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 70.0,
            child: ElevatedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(const Color(0xFFCECECE)),
                backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFCECECE)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: BorderSide(
                      color: Color(0xFFCECECE),
                    ),
                  ),
                ),
              ),
              onPressed: () {
                for (int i = 0; i < widget.commonPassingArgs.endUserActivitySelection!.length; i++) {
                  String key = widget.commonPassingArgs.endUserActivitySelection!.keys.elementAt(i);
                  List<SubActivitiesBean> values = widget.commonPassingArgs.endUserActivitySelection![key];
                  List<SelectedFilterValues> data = [];
                  for (int j = 0; j < values.length; j++) {
                    values[j].selectedValue = false;
                  }
                }

                // for (int j = 0; j < selectedValuesFromKey.length; j++) {
                //   if (selectedValuesFromKey[j].selectedValue!) {
                //     selectedValuesFromKey[j].selectedValue = false;
                //   }
                // }
                // selectedSubValue = null;
                Navigator.of(context).pop(null);
              },
              child: CustomTextView(
                label: 'Cancel',
                textStyle: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.w400, fontSize: 16.0, decoration: TextDecoration.underline, color: OQDOThemeData.blackColor),
              ),
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 70.0,
            child: ElevatedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(const Color(0xFF006590)),
                backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF006590)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: BorderSide(
                      color: Color(0xFF006590),
                    ),
                  ),
                ),
              ),
              onPressed: () {
                for (int i = 0; i < widget.commonPassingArgs.endUserActivitySelection!.length; i++) {
                  String key = widget.commonPassingArgs.endUserActivitySelection!.keys.elementAt(i);
                  List<SubActivitiesBean> values = widget.commonPassingArgs.endUserActivitySelection![key];
                  List<SelectedFilterValues> data = [];
                  for (int j = 0; j < values.length; j++) {
                    if (values[j].selectedValue!) {
                      SelectedFilterValues selectedFilterValues = SelectedFilterValues();
                      selectedFilterValues.activityName = values[j].Name;
                      selectedFilterValues.subActivityId = values[j].SubActivityId;
                      data.add(selectedFilterValues);
                      selectedValues[key] = data;
                    } else {}
                  }
                }
                // print(selectedValues);
                Navigator.of(context).pop(selectedValues);
              },
              child: CustomTextView(
                label: 'Apply',
                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600, fontSize: 16.0, color: OQDOThemeData.whiteColor),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget topView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 30.0, right: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextView(
                label: 'Interests',
                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w400, fontSize: 18.0, color: OQDOThemeData.otherTextColor),
              ),
              // const Icon(
              //   Icons.keyboard_arrow_down_rounded,
              //   color: OQDOThemeData.dividerColor,
              // ),
            ],
          ),
        ),
        const SizedBox(
          height: 15.0,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30.0),
          child: CustomTextView(
            label: '(Select your interests)',
            textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: OQDOThemeData.blackColor, fontWeight: FontWeight.w400, fontSize: 16.0),
          ),
        ),
      ],
    );
  }

  Widget filterView() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.commonPassingArgs.endUserActivitySelection!.length,
              itemBuilder: (context, index) {
                String key = widget.commonPassingArgs.endUserActivitySelection!.keys.elementAt(index);
                bool? isSelected = itemsSelectedValue[index] ?? false;
                return firstFilter(key, index, isSelected);
              },
              separatorBuilder: (BuildContext context, int index) {
                return Container();
              },
            ),
          ),
          Container(
            color: const Color.fromRGBO(227, 227, 227, 1.0),
            width: 1,
            height: double.infinity,
          ),
          selectedValue != ""
              ? Flexible(
                  flex: 3,
                  fit: FlexFit.loose,
                  child: ListView.separated(
                    shrinkWrap: false,
                    controller: _scrollController,
                    itemCount: selectedValuesFromKey.length,
                    itemBuilder: (context, index) {
                      return reviewAppointmentSingleView(index);
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Container();
                    },
                  ),
                )
              : Flexible(
                  flex: 3,
                  fit: FlexFit.tight,
                  child: Container(),
                ),
        ],
      ),
    );
  }

  Widget reviewAppointmentSingleView(int index) {
    return Container(
      padding: const EdgeInsets.only(left: 10.0, right: 20.0, top: 20.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.scale(
            scale: 1.3,
            child: Checkbox(
                fillColor: MaterialStateProperty.resolveWith(Utils.getColor),
                checkColor: Theme.of(context).colorScheme.primaryContainer,
                value: selectedValuesFromKey[index].selectedValue,
                onChanged: (value) {
                  setState(() {
                    selectedValuesFromKey[index].selectedValue = value;
                  });
                }),
          ),
          const SizedBox(
            width: 15.0,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: CustomTextView(
                    label: "${selectedValuesFromKey[index].Name}",
                    maxLine: 2,
                    textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 18.0, fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget firstFilter(String key, int index, bool isSelected) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              selectedValue = key;
              if (index == index) {
                itemsSelectedValue[index] = !isSelected;
              }
              // itemsSelectedValue[index] = !isSelected;
              // data[index]['selected'] = !data[index]['isSelected'];
              debugPrint("OnClick : $index + ${itemsSelectedValue[index]}");
              List<SubActivitiesBean> selectedValueList = widget.commonPassingArgs.endUserActivitySelection![key];
              selectedValuesFromKey = selectedValueList;
              // selectedValuesFromKey[index].isSelected = true;
              if (_scrollController.positions.isNotEmpty) {
                _scrollController.jumpTo(0);
              }
            });
          },
          child: Container(
            height: 80.0,
            width: double.infinity,
            color: selectedValue == key ? OQDOThemeData.filterDividerColor : OQDOThemeData.whiteColor,
            child: Center(
              child: CustomTextView(
                label: key,
                textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 16.0, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 1.0,
          child: Container(
            color: OQDOThemeData.filterDividerColor,
          ),
        ),
      ],
    );
  }
}
