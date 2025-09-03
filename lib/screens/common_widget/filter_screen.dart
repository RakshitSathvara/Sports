import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/model/common_passing_args.dart';
import 'package:oqdo_mobile_app/model/get_all_activity_and_sub_activity_response.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';

import '../../model/activity_model.dart';
import '../../theme/oqdo_theme_data.dart';
import '../../utils/custom_text_view.dart';

class FilterViewScreen extends StatefulWidget {
  CommonPassingArgs? commonPassingArgs;

  FilterViewScreen({Key? key, this.commonPassingArgs}) : super(key: key);

  @override
  State<FilterViewScreen> createState() => _FilterViewScreenState();
}

class _FilterViewScreenState extends State<FilterViewScreen> {
  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;
  bool isSelected = true;
  bool isNotSelected = false;
  List<ActivityModel> activityModelList = [];

  String selectedValue = '';
  List<SubActivitiesBean> selectedValuesFromKey = [];
  Map<String, List<SelectedFilterValues>> selectedValues = {};
  List<String> selectedSubValue = [];
  Map<int, bool> itemsSelectedValue = {};
  List<int> selectedSubActivityId = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    debugPrint(widget.commonPassingArgs!.endUserActivitySelection.toString());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: 'oqdo',
          onBack: () {
            Navigator.pop(context);
          }),
      body: SafeArea(
        child: Container(
          color: Theme.of(context).colorScheme.onBackground,
          width: width,
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20.0,
              ),
              topView(),
              const SizedBox(
                height: 20.0,
              ),
              selectionView(),
              const SizedBox(
                height: 30.0,
              ),
              Expanded(child: filterView()),
              bottomBtnView(),
            ],
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
                onPressed: () {},
                child: CustomTextView(
                  label: 'Cancel',
                  textStyle: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.w400, fontSize: 16.0, decoration: TextDecoration.underline, color: OQDOThemeData.blackColor),
                )),
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
                  for (int i = 0; i < widget.commonPassingArgs!.endUserActivitySelection!.length; i++) {
                    String key = widget.commonPassingArgs!.endUserActivitySelection!.keys.elementAt(i);
                    List<SubActivitiesBean> values = widget.commonPassingArgs!.endUserActivitySelection![key];
                    List<SelectedFilterValues> data = [];
                    for (int j = 0; j < values.length; j++) {
                      if (values[j].selectedValue!) {
                        SelectedFilterValues selectedFilterValues = SelectedFilterValues();
                        selectedFilterValues.activityName = values[j].Name;
                        selectedFilterValues.subActivityId = values[j].SubActivityId;
                        data.add(selectedFilterValues);
                        selectedValues[key] = data;
                      }
                    }
                  }
                  // print(selectedValues);
                  Navigator.of(context).pop(selectedValues);
                },
                child: CustomTextView(
                  label: 'Apply',
                  textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600, fontSize: 16.0, color: OQDOThemeData.whiteColor),
                )),
          ),
        )
      ],
    );
  }

  Widget topView() {
    return Container(
      padding: const EdgeInsets.only(left: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextView(
            label: 'Filter By',
            textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600, fontSize: 18.0, color: OQDOThemeData.greyColor),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: CustomTextView(
                  label: 'Clear All',
                  textStyle: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(fontSize: 14.0, fontWeight: FontWeight.w400, decoration: TextDecoration.underline, color: OQDOThemeData.otherTextColor),
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(shape: const CircleBorder(), backgroundColor: OQDOThemeData.backgroundColor),
                child: Image.asset(
                  'assets/images/ic_filter.png',
                  height: 20.0,
                  width: 20.0,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget selectionView() {
    return Container(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                border: Border.all(width: 5.0, color: OQDOThemeData.backgroundColor),
              ),
              child: SizedBox(
                height: 100.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? OQDOThemeData.dividerColor : OQDOThemeData.backgroundColor,
                    shape: BoxShape.rectangle,
                    borderRadius: const BorderRadius.all(Radius.circular(2.0)),
                  ),
                  child: Center(
                    child: CustomTextView(
                      label: 'Group Booking',
                      textStyle: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(fontWeight: FontWeight.w500, fontSize: 15.0, color: isSelected ? OQDOThemeData.whiteColor : OQDOThemeData.blackColor),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 20.0,
          ),
          Expanded(
            child: Container(
              height: 100.0,
              decoration: BoxDecoration(
                color: OQDOThemeData.whiteColor,
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Center(
                child: CustomTextView(
                  label: 'Individual Booking',
                  textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: OQDOThemeData.greyColor, fontSize: 15.0, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget filterView() {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.commonPassingArgs!.endUserActivitySelection!.length,
              itemBuilder: (context, index) {
                String key = widget.commonPassingArgs!.endUserActivitySelection!.keys.elementAt(index);
                bool? isSelected = itemsSelectedValue[index] ?? false;
                return firstFilter(key, index, isSelected);
              },
              separatorBuilder: (BuildContext context, int index) {
                return Container();
              },
            ),
          ),
          const VerticalDivider(
            color: OQDOThemeData.filterDividerColor,
            thickness: 1.0,
          ),
          selectedValue != ""
              ? Flexible(
                  flex: 3,
                  fit: FlexFit.tight,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextView(
                label: selectedValuesFromKey[index].Name,
                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 16.0, fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor),
              ),
            ],
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
              debugPrint("OnClick : $index + ${itemsSelectedValue[index]}");
              List<SubActivitiesBean> selectedValueList = widget.commonPassingArgs!.endUserActivitySelection![key];
              selectedValuesFromKey = selectedValueList;
              if (_scrollController.positions.isNotEmpty) {
                _scrollController.jumpTo(0);
              }
            });
          },
          child: SizedBox(
            height: 80.0,
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
