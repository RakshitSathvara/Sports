import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/model/common_passing_args.dart';
import 'package:oqdo_mobile_app/screens/bazaar/ads_screen/intent/ads_intent.dart';
import 'package:oqdo_mobile_app/screens/bazaar/ads_screen/model/subactivyt_and_activity_response_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/ads_screen/viewmodel/ads_view_model.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:provider/provider.dart';

class CategoryScreen extends StatefulWidget {
  static const String routeName = '/category-screen';
  const CategoryScreen({super.key, this.intent});

  final AdsIntent? intent;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String selectedActivityName = '';
  List<SubActivity> selectedValuesFromKey = [];
  Map<String, List<SelectedFilterValues>> selectedValues = {};
  Map<int, bool> itemsSelectedValue = {};
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  List<Activity> categories = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getActivities();
    });
  }

  Future<void> getActivities() async {
    try {
      final value = await Provider.of<AdsViewModel>(context, listen: false).getAllSubActivity();

      if (value.statusCode == 200) {
        final model = SubActivityAndActivityResponseModel.fromJson(jsonDecode(value.body));

        setState(() {
          categories = model.data;
          _isLoading = false;
        });

        initializeSelections();
      } else {
        handleError(value);
      }
    } catch (e) {
      handleException(e);
    }
  }

  void initializeSelections() {
    if (categories.isEmpty) return;

    if (widget.intent != null && widget.intent!.activityMap.isNotEmpty) {
      // Initialize selections from intent
      widget.intent!.activityMap.forEach((activityName, subActivities) {
        // Find the matching activity in categories
        final matchingActivity = categories.firstWhere(
          (category) => category.name == activityName,
          orElse: () => categories.first,
        );

        // Set the first activity as the visible one
        if (activityName == widget.intent!.activityMap.keys.first) {
          selectedActivityName = matchingActivity.name;
          selectedValuesFromKey = matchingActivity.subActivities;
          final index = categories.indexOf(matchingActivity);
          itemsSelectedValue[index] = true;
        }

        // Initialize the selectedValues map for this activity
        if (!selectedValues.containsKey(activityName)) {
          selectedValues[activityName] = [];
        }

        // Add all sub-activities from intent for this activity
        for (var subActivity in subActivities) {
          selectedValues[activityName]!.add(SelectedFilterValues()
            ..activityName = subActivity.name
            ..subActivityId = subActivity.subActivityId);
        }
      });

      // Make sure UI reflects the selections
      setState(() {});
    } else {
      // Default to first category if no intent
      final firstCategory = categories.first;
      selectedActivityName = firstCategory.name;
      selectedValuesFromKey = firstCategory.subActivities;
      itemsSelectedValue[0] = true;
    }
  }

  void selectActivity(String activityName, int index) {
    setState(() {
      selectedActivityName = activityName;
      itemsSelectedValue[index] = !(itemsSelectedValue[index] ?? false);

      final activity = categories.firstWhere(
        (element) => element.name == activityName,
      );
      selectedValuesFromKey = activity.subActivities;

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  void addToSelection(SubActivity subActivity) {
    if (!selectedValues.containsKey(selectedActivityName)) {
      selectedValues[selectedActivityName] = [];
    }

    final alreadyExists = selectedValues[selectedActivityName]!.any((element) => element.subActivityId == subActivity.subActivityId);

    if (!alreadyExists) {
      selectedValues[selectedActivityName]!.add(SelectedFilterValues()
        ..activityName = subActivity.name
        ..subActivityId = subActivity.subActivityId);
    }
  }

  void removeFromSelection(SubActivity subActivity) {
    selectedValues[selectedActivityName]?.removeWhere(
      (element) => element.subActivityId == subActivity.subActivityId,
    );

    if (selectedValues[selectedActivityName]?.isEmpty ?? false) {
      selectedValues.remove(selectedActivityName);
    }
  }

  bool hasSelections() {
    return selectedValues.values.any((list) => list.isNotEmpty);
  }

  bool isSubActivitySelected(SubActivity subActivity) {
    return selectedValues[selectedActivityName]?.any(
          (element) => element.subActivityId == subActivity.subActivityId,
        ) ??
        false;
  }

  void resetSelections() {
    setState(() {
      selectedValues.clear();
      selectedActivityName = '';
      itemsSelectedValue.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Filter',
        onBack: () => Navigator.pop(context),
        isIconColorBlack: false,
        backgroundColor: const Color(0xFF006989),
      ),
      body: WillPopScope(
        onWillPop: () async {
          resetSelections();
          Navigator.of(context).pop();
          return false;
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildHeader(),
            ),
            Expanded(
              child: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildFilterView(),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextView(
          label: 'Used For',
          textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 18.0,
                color: OQDOThemeData.otherTextColor,
              ),
        ),
        const SizedBox(height: 15.0),
        CustomTextView(
          label: '(Select categories)',
          textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: OQDOThemeData.blackColor,
                fontWeight: FontWeight.w400,
                fontSize: 16.0,
              ),
        ),
      ],
    );
  }

  Widget _buildFilterView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 2,
          fit: FlexFit.tight,
          child: _buildActivityList(),
        ),
        Container(
          color: const Color.fromRGBO(227, 227, 227, 1.0),
          width: 1,
          height: double.infinity,
        ),
        Flexible(
          flex: 3,
          fit: FlexFit.tight,
          child: selectedActivityName.isNotEmpty ? _buildSubActivityList() : Container(),
        ),
      ],
    );
  }

  Widget _buildActivityList() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: categories.length,
      separatorBuilder: (_, __) => Container(),
      itemBuilder: (context, index) {
        final activity = categories[index];
        final isSelected = itemsSelectedValue[index] ?? false;

        return Column(
          children: [
            GestureDetector(
              onTap: () => selectActivity(activity.name, index),
              child: Container(
                height: 80.0,
                width: double.infinity,
                color: selectedActivityName == activity.name ? OQDOThemeData.filterDividerColor : OQDOThemeData.whiteColor,
                child: Center(
                  child: CustomTextView(
                    label: activity.name,
                    textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontSize: 16.0,
                          color: OQDOThemeData.greyColor,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
            ),
            Container(
              height: 1.0,
              color: OQDOThemeData.filterDividerColor,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubActivityList() {
    return ListView.separated(
      shrinkWrap: false,
      controller: _scrollController,
      itemCount: selectedValuesFromKey.length,
      separatorBuilder: (_, __) => Container(),
      itemBuilder: (_, index) {
        final subActivity = selectedValuesFromKey[index];

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
                  value: isSubActivitySelected(subActivity),
                  onChanged: (selected) {
                    setState(() {
                      if (selected ?? false) {
                        addToSelection(subActivity);
                      } else {
                        removeFromSelection(subActivity);
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 15.0),
              Expanded(
                child: CustomTextView(
                  label: subActivity.name,
                  maxLine: 2,
                  textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                        color: OQDOThemeData.greyColor,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 70.0,
            child: ElevatedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(const Color(0xFFCECECE)),
                backgroundColor: MaterialStateProperty.all(const Color(0xFFCECECE)),
                shape: MaterialStateProperty.all(
                  const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: BorderSide(color: Color(0xFFCECECE)),
                  ),
                ),
              ),
              onPressed: () {
                resetSelections();
                Navigator.of(context).pop();
              },
              child: CustomTextView(
                label: 'Cancel',
                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 16.0,
                      decoration: TextDecoration.underline,
                      color: OQDOThemeData.blackColor,
                    ),
              ),
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 70.0,
            child: ElevatedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(const Color(0xFF006590)),
                backgroundColor: MaterialStateProperty.all(const Color(0xFF006590)),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: BorderSide(
                      color: hasSelections() ? const Color(0xFF006590) : const Color(0xFFCECECE),
                    ),
                  ),
                ),
              ),
              onPressed: () {
                if (!hasSelections()) {
                  showSnackBarColor('Please select at least one activity', context, true);
                  return;
                }

                // Convert selectedValues to the new Map format
                Map<String, List<SubActivity>> resultMap = {};

                selectedValues.forEach((activityName, filterValues) {
                  final subActivities = filterValues
                      .map((filterValue) => SubActivity(
                            subActivityId: filterValue.subActivityId!,
                            name: filterValue.activityName!,
                            activityId: filterValue.subActivityId!,
                          ))
                      .toList();

                  resultMap[activityName] = subActivities;
                });

                Navigator.of(context).pop(resultMap);
              },
              child: CustomTextView(
                label: 'Apply',
                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0,
                      color: OQDOThemeData.whiteColor,
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void handleError(Response res) {
    setState(() => _isLoading = false);
    if (res.statusCode == 500 || res.statusCode == 404) {
      showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
    } else {
      final errorModel = jsonDecode(res.body);
      if (errorModel['ModelState']?['ErrorMessage'] != null) {
        showSnackBarColor(errorModel['ModelState']['ErrorMessage'][0], context, true);
      }
    }
  }

  void handleException(dynamic e) {
    setState(() => _isLoading = false);
    if (e is NoConnectivityException) {
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } else if (e is TimeoutException) {
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } else if (e is ServerException) {
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } else if (e is ServerException) {
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } else {
      showSnackBarErrorColor(e.toString(), context, true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
