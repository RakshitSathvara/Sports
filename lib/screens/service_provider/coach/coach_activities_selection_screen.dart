import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';

import '../../../model/common_passing_args.dart';
import '../../../model/get_all_activity_and_sub_activity_response.dart';
import '../../../theme/oqdo_theme_data.dart';
import '../../../utils/custom_text_view.dart';
import '../../../utils/utilities.dart';

class CoachActivitiesSelectionScreen extends StatefulWidget {
  final Map<String, List<SubActivitiesBean>> endUserActivitySelection;

  const CoachActivitiesSelectionScreen({Key? key, required this.endUserActivitySelection}) : super(key: key);

  @override
  State<CoachActivitiesSelectionScreen> createState() => _CoachActivitiesSelectionScreenState();
}

class _CoachActivitiesSelectionScreenState extends State<CoachActivitiesSelectionScreen> {
  String selectedValue = '';
  List<SubActivitiesBean> selectedValuesFromKey = [];
  final ScrollController _scrollController = ScrollController();
  bool isAnyActivitySelected = false;
  String selectedActivityKey = '';

  Map<String, List<SubActivitiesBean>> endUserActivitySelection = {};

  @override
  void initState() {
    super.initState();
    setState(() {
      endUserActivitySelection = widget.endUserActivitySelection;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(context);
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: Container(
            color: Theme.of(context).colorScheme.surface,
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
                topView(textColor),
                const SizedBox(
                  height: 50.0,
                ),
                 Divider(
                  height: 1.0,
                  color: textColor,
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
                foregroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).colorScheme.surfaceVariant),
                backgroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).colorScheme.surfaceVariant),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                  ),
                ),
              ),
              onPressed: () {
                for (int i = 0; i < endUserActivitySelection.length; i++) {
                  String key = endUserActivitySelection.keys.elementAt(i);
                  List<SubActivitiesBean> values = endUserActivitySelection[key]!;
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
                    .copyWith(fontWeight: FontWeight.w400, fontSize: 16.0, decoration: TextDecoration.underline, color: textColor),
              ),
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 70.0,
            child: ElevatedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).colorScheme.primary),
                backgroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).colorScheme.primary),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              onPressed: () {
                if (selectedValue == '') {
                  Navigator.of(context).pop(context);
                } else {
                  Map<String, List<SelectedFilterValues>> selectedValues = {};

                  int count = 0;
                  endUserActivitySelection.forEach((key, value) {
                    if (key == selectedValue) {
                      List<SelectedFilterValues> data = [];
                      for (int j = 0; j < value.length; j++) {
                        if (value[j].selectedValue == true) {
                          debugPrint("$key - ${value[j].Name!} - True");
                          count = count + 1;
                          SelectedFilterValues selectedFilterValues = SelectedFilterValues();
                          selectedFilterValues.activityName = value[j].Name;
                          selectedFilterValues.subActivityId = value[j].SubActivityId;
                          data.add(selectedFilterValues);
                        }
                      }
                      selectedValues[key] = data;
                    }
                  });

                  /* int count = 0;
                    for (int i = 0;
                        i <
                            endUserActivitySelection!
                                .length;
                        i++) {
                      String key = widget
                          .endUserActivitySelection!.keys
                          .elementAt(i);
                      List<SubActivitiesBean>? values = widget
                          .endUserActivitySelection![key];

                      // print("Key >> "+key);
                      // print("Value >> "+values.length.toString());
                      List<SelectedFilterValues> data = [];
                      for (int j = 0; j < values!.length; j++) {
                        if (values[j].selectedValue! && key == selectedValue) {
                          print(key + " - " + values[j].Name! + " - " + "True");
                          count = count + 1;
                          SelectedFilterValues selectedFilterValues =
                              SelectedFilterValues();
                          selectedFilterValues.activityName = values[j].Name;
                          selectedFilterValues.subActivityId =
                              values[j].SubActivityId;
                          data.add(selectedFilterValues);
                          selectedValues[key] = data;
                        }
                      }
                    }*/

                  if (count <= 0) {
                    showSnackBarColor('Please select minimum one sub activities', context, true);
                  } else if (count > 4) {
                    showSnackBarColor('You can select maximum 4 Sub activities', context, true);
                  } else {
                    Navigator.of(context).pop(selectedValues);
                  }
                }
              },
              child: CustomTextView(
                label: 'Apply',
                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600, fontSize: 16.0, color: Theme.of(context).colorScheme.surface),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget topView(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 30.0, right: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextView(
                label: 'Activities',
                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w400, fontSize: 18.0, color: textColor),
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
            label: '(Select 4 sub activities you would like to add)',
            textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: textColor, fontWeight: FontWeight.w400, fontSize: 16.0),
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
              physics: const NeverScrollableScrollPhysics(),
              itemCount: endUserActivitySelection.length,
              itemBuilder: (context, index) {
                String key = endUserActivitySelection.keys.elementAt(index);
                return firstFilter(key);
              },
              separatorBuilder: (BuildContext context, int index) {
                return Container();
              },
            ),
          ),
          Container(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
            height: double.infinity,
          ),
          // const VerticalDivider(
          //   color: textColor,
          //   thickness: 1.0, //thickness of divider line
          // ),
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
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
      child: Row(
        children: [
          Transform.scale(
            scale: 1.3,
            child: Checkbox(
                fillColor: MaterialStateProperty.resolveWith(Utils.getColor),
                checkColor: Theme.of(context).colorScheme.primaryContainer,
                value: selectedValuesFromKey[index].selectedValue,
                onChanged: (value) {
                  if (selectedValue != selectedActivityKey) {
                    if (isAnyActivitySelected) {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context) => CupertinoAlertDialog(
                          title: CustomTextView(
                            label: '',
                            textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w400, fontSize: 18.0, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                          ),
                          content: Center(
                            child: CustomTextView(
                              label: 'Are you sure you want to change activity?',
                              maxLine: 2,
                              textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                            ),
                          ),
                          actions: [
                            CupertinoDialogAction(
                              isDefaultAction: true,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: CustomTextView(
                                label: 'No',
                                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            CupertinoDialogAction(
                              isDestructiveAction: true,
                              onPressed: () async {
                                endUserActivitySelection.forEach((activityKey, value) {
                                  if (selectedValue != activityKey) {
                                    for (int j = 0; j < value.length; j++) {
                                      setState(() {
                                        value[j].selectedValue = false;
                                      });
                                    }
                                  }
                                });
                                setState(() {
                                  isAnyActivitySelected = false;
                                  selectedValuesFromKey[index].selectedValue = value;
                                });

                                Navigator.of(context).pop();
                              },
                              child: CustomTextView(
                                label: 'Yes',
                                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: Theme.of(context).colorScheme.primary),
                              ),
                            )
                          ],
                        ),
                      );
                    } else {
                      setState(() {
                        selectedValuesFromKey[index].selectedValue = value;
                      });
                    }
                  } else {
                    setState(() {
                      selectedValuesFromKey[index].selectedValue = value;
                    });
                  }
                }),
          ),
          const SizedBox(
            width: 15.0,
          ),
          Expanded(
            child: CustomTextView(
              label: selectedValuesFromKey[index].Name,
              maxLine: 3,
              textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 16.0, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            ),
          )
        ],
      ),
    );
  }

  Widget firstFilter(String key) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            // if(selectedValue != key && ){}
            setState(() {
              selectedValue = key;
              //  print(key);
              List<SubActivitiesBean>? selectedValueList = endUserActivitySelection[key];
              //   print(selectedValueList.length);
              selectedValuesFromKey = selectedValueList!;

              endUserActivitySelection.forEach((activityKey, value) {
                for (int j = 0; j < value.length; j++) {
                  if (value[j].selectedValue == true) {
                    // setState(() {
                    isAnyActivitySelected = true;
                    selectedActivityKey = activityKey;
                    // });
                    debugPrint('$activityKey -> ${value[j].Name}');
                    break;
                  }
                }
              });

              if (_scrollController.positions.isNotEmpty) {
                _scrollController.jumpTo(0);
              }
            });
          },
          child: Container(
            height: 80.0,
            width: double.infinity,
            color: selectedValue == key ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surface,
            child: Center(
              child: CustomTextView(
                label: key,
                textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 16.0, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 1.0,
          child: Container(
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
        ),
      ],
    );
  }
}
