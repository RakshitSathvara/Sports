import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/model/common_passing_args.dart';
import 'package:oqdo_mobile_app/model/get_all_activity_and_sub_activity_response.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';

class FilterWidgetScreen extends StatefulWidget {
  String? type;
  List<ActivityBean>? activityListModel = [];

  FilterWidgetScreen({Key? key, this.type, this.activityListModel}) : super(key: key);

  @override
  State<FilterWidgetScreen> createState() => _FilterWidgetScreenState();
}

class _FilterWidgetScreenState extends State<FilterWidgetScreen> {
  List<String>? filterList = ['Facilities', 'Coaches'];
  String? selectedTypeValue;
  Map<String, List<SelectedFilterValues>>? selectedFilterData = {};

  @override
  void initState() {
    super.initState();
    if (widget.type == 'F') {
      selectedTypeValue = 'Facilities';
    } else {
      selectedTypeValue = 'Coaches';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        selectionTypeWithFilterView(),
        DropdownButton<dynamic>(
          isExpanded: false,
          underline: const SizedBox(),
          dropdownColor: Theme.of(context).colorScheme.onBackground,
          hint: CustomTextView(
            label: filterList![0],
            textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: OQDOThemeData.greyColor, fontSize: 20.0, fontWeight: FontWeight.w300),
          ),
          value: selectedTypeValue,
          items: filterList!.map((interest) {
            return DropdownMenuItem(
              value: interest,
              child: CustomTextView(
                label: interest.toString(),
                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: OQDOThemeData.greyColor, fontSize: 20.0, fontWeight: FontWeight.w300),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedTypeValue = value as String;
              if (selectedTypeValue == 'Facilities') {
                Navigator.pushNamed(context, Constants.FACILITIESLISTPAGE);
              } else {
                Navigator.pushNamed(context, Constants.COACHLISTPAGE);
              }
            });
          },
        ),
      ],
    );
  }

  Widget selectionTypeWithFilterView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomTextView(
          label: 'Book',
          textStyle: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(fontWeight: FontWeight.bold, fontSize: 20.0, color: OQDOThemeData.greyColor, fontStyle: FontStyle.normal),
        ),
        InkWell(
          onTap: () async {
            debugPrint('filter -> ${widget.activityListModel!.length}');
            Map<String, List<SubActivitiesBean>> interestValue = {};
            for (int i = 0; i < widget.activityListModel!.length; i++) {
              interestValue[widget.activityListModel![i].Name!] = widget.activityListModel![i].SubActivities!;
            }
            CommonPassingArgs commonPassingArgs = CommonPassingArgs();
            commonPassingArgs.endUserActivitySelection = interestValue;
            var data = await Navigator.pushNamed(context, Constants.filterViewScreen, arguments: commonPassingArgs);
            // print('onclick$data');
            if (data != null) {
              setState(() {
                selectedFilterData = data as Map<String, List<SelectedFilterValues>>?;
              });
              debugPrint(selectedFilterData.toString());
            }
          },
          child: SizedBox(
            height: 20.0,
            width: 20.0,
            child: Image.asset(
              'assets/images/ic_filter.png',
            ),
          ),
        ),
      ],
    );
  }
}
