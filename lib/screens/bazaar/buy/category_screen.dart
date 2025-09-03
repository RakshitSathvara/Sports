import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/model/common_passing_args.dart';
import 'package:oqdo_mobile_app/screens/bazaar/ads_screen/model/subactivyt_and_activity_response_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/models/equipment_category_response_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/viewmodel/sell_viewmodel.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:provider/provider.dart';

class BuyCategoryScreen extends StatefulWidget {
  static const String routeName = '/buy-category-screen';
  const BuyCategoryScreen({super.key, this.initialFilters});

  final Map<String, dynamic>? initialFilters;

  @override
  State<BuyCategoryScreen> createState() => _BuyCategoryScreenState();
}

class _BuyCategoryScreenState extends State<BuyCategoryScreen> {
  String selectedActivityName = '';
  List<dynamic> selectedValuesFromKey = [];
  Map<String, List<SelectedFilterValues>> selectedValues = {};
  Map<int, bool> itemsSelectedValue = {};
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  List<Activity> categories = [];
  List<EquipmentCategory> equipmentCategories = [];
  bool isProductCategorySelected = false;

  static const String PRODUCT_CATEGORY_KEY = "Product Category";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getActivities();
    });
  }

  Future<void> getActivities() async {
    try {
      final value = await Provider.of<SellViewmodel>(context, listen: false).getAllActivityAndSubActivity();

      if (value.statusCode == 200) {
        final model = SubActivityAndActivityResponseModel.fromJson(jsonDecode(value.body));

        setState(() {
          categories = model.data;
        });

        // Call getAllProductCategory after successful fetching of activities
        await getAllProductCategory();

        // Initialize selections if there are initialFilters
        if (widget.initialFilters != null) {
          initializeSelections();
        } else if (categories.isNotEmpty) {
          // Default to first category if no initialFilters
          final firstCategory = categories.first;
          selectedActivityName = firstCategory.name;
          selectedValuesFromKey = firstCategory.subActivities;
          itemsSelectedValue[0] = true;
        }
      } else {
        handleError(value);
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      handleException(e);
    }
  }

  Future<void> getAllProductCategory() async {
    try {
      final value = await Provider.of<SellViewmodel>(context, listen: false).getAllEquipmentCategories();

      if (value.statusCode == 200) {
        final model = EquipmentCategoryResponseModel.fromJson(jsonDecode(value.body));
        setState(() {
          equipmentCategories = model.data;
        });
      } else {
        handleError(value);
      }
    } catch (e) {
      handleException(e);
    }
  }

  void initializeSelections() {
    if (categories.isEmpty) return;

    if (widget.initialFilters != null) {
      // Handle initializing sub activities
      if (widget.initialFilters!.containsKey('subActivities')) {
        Map<String, List<SubActivity>> subActivitiesMap = widget.initialFilters!['subActivities'] as Map<String, List<SubActivity>>;

        subActivitiesMap.forEach((activityName, subActivities) {
          // Find the matching activity in categories
          if (activityName == PRODUCT_CATEGORY_KEY) {
            // Handle product categories initialization
            return;
          }

          final matchingActivity = categories.firstWhere(
            (category) => category.name == activityName,
            orElse: () => categories.first,
          );

          // Set the first activity as the visible one
          if (activityName == subActivitiesMap.keys.first) {
            selectedActivityName = matchingActivity.name;
            selectedValuesFromKey = matchingActivity.subActivities;
            final index = categories.indexOf(matchingActivity);
            itemsSelectedValue[index] = true;
          }

          // Initialize the selectedValues map for this activity
          if (!selectedValues.containsKey(activityName)) {
            selectedValues[activityName] = [];
          }

          // Add all sub-activities from initialFilters for this activity
          for (var subActivity in subActivities) {
            selectedValues[activityName]!.add(SelectedFilterValues()
              ..activityName = subActivity.name
              ..subActivityId = subActivity.subActivityId);
          }
        });
      }

      // Handle initializing product categories
      if (widget.initialFilters!.containsKey('productCategories')) {
        Map<String, List<EquipmentCategory>> productCategoriesMap = widget.initialFilters!['productCategories'] as Map<String, List<EquipmentCategory>>;

        productCategoriesMap.forEach((activityName, productCategories) {
          // Make sure we're only handling Product Category key
          if (activityName == PRODUCT_CATEGORY_KEY) {
            // Initialize the selectedValues map for product categories
            if (!selectedValues.containsKey(PRODUCT_CATEGORY_KEY)) {
              selectedValues[PRODUCT_CATEGORY_KEY] = [];
            }

            // Add all product categories from initialFilters
            for (var category in productCategories) {
              selectedValues[PRODUCT_CATEGORY_KEY]!.add(SelectedFilterValues()
                ..activityName = category.name
                ..subActivityId = category.equipmentCategoryId);
            }

            // If this is the first item selected, make Product Category visible
            if (selectedActivityName.isEmpty && productCategories.isNotEmpty) {
              selectedActivityName = PRODUCT_CATEGORY_KEY;
              selectedValuesFromKey = equipmentCategories;
              final index = categories.length; // Product Category is after all regular categories
              itemsSelectedValue[index] = true;
              isProductCategorySelected = true;
            }
          }
        });
      }

      // Make sure UI reflects the selections
      setState(() {});
    }
  }

  void selectActivity(String activityName, int index) {
    setState(() {
      selectedActivityName = activityName;
      isProductCategorySelected = activityName == PRODUCT_CATEGORY_KEY;

      for (var i = 0; i < categories.length + 1; i++) {
        itemsSelectedValue[i] = false;
      }
      itemsSelectedValue[index] = true;

      if (activityName == PRODUCT_CATEGORY_KEY) {
        // Show equipment categories when "Product Category" is selected
        selectedValuesFromKey = equipmentCategories;
      } else {
        // Find matching activity and show its subactivities
        final activity = categories.firstWhere(
          (element) => element.name == activityName,
        );
        selectedValuesFromKey = activity.subActivities;
      }

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  void addToSelection(dynamic item) {
    if (!selectedValues.containsKey(selectedActivityName)) {
      selectedValues[selectedActivityName] = [];
    }

    if (isProductCategorySelected) {
      // Handle adding an equipment category
      EquipmentCategory category = item as EquipmentCategory;
      final alreadyExists = selectedValues[selectedActivityName]!.any((element) => element.subActivityId == category.equipmentCategoryId);

      if (!alreadyExists) {
        selectedValues[selectedActivityName]!.add(SelectedFilterValues()
          ..activityName = category.name
          ..subActivityId = category.equipmentCategoryId);
      }
    } else {
      // Handle adding a subactivity
      SubActivity subActivity = item as SubActivity;
      final alreadyExists = selectedValues[selectedActivityName]!.any((element) => element.subActivityId == subActivity.subActivityId);

      if (!alreadyExists) {
        selectedValues[selectedActivityName]!.add(SelectedFilterValues()
          ..activityName = subActivity.name
          ..subActivityId = subActivity.subActivityId);
      }
    }
  }

  void removeFromSelection(dynamic item) {
    if (isProductCategorySelected) {
      // Handle removing an equipment category
      EquipmentCategory category = item as EquipmentCategory;
      selectedValues[selectedActivityName]?.removeWhere(
        (element) => element.subActivityId == category.equipmentCategoryId,
      );
    } else {
      // Handle removing a subactivity
      SubActivity subActivity = item as SubActivity;
      selectedValues[selectedActivityName]?.removeWhere(
        (element) => element.subActivityId == subActivity.subActivityId,
      );
    }

    if (selectedValues[selectedActivityName]?.isEmpty ?? false) {
      selectedValues.remove(selectedActivityName);
    }
  }

  bool hasSelections() {
    return selectedValues.values.any((list) => list.isNotEmpty);
  }

  bool isItemSelected(dynamic item) {
    if (!selectedValues.containsKey(selectedActivityName)) {
      return false;
    }

    if (isProductCategorySelected) {
      // Check if equipment category is selected
      EquipmentCategory category = item as EquipmentCategory;
      return selectedValues[selectedActivityName]!.any((element) => element.subActivityId == category.equipmentCategoryId);
    } else {
      // Check if subactivity is selected
      SubActivity subActivity = item as SubActivity;
      return selectedValues[selectedActivityName]!.any((element) => element.subActivityId == subActivity.subActivityId);
    }
  }

  void resetSelections() {
    setState(() {
      selectedValues.clear();
      selectedActivityName = '';
      itemsSelectedValue.clear();
      isProductCategorySelected = false;
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
          child: selectedActivityName.isNotEmpty ? _buildRightPanel() : Container(),
        ),
      ],
    );
  }

  Widget _buildActivityList() {
    // Create a list that includes all activity categories plus "Product Category"
    List<Widget> items = [];

    // Add all activity categories
    for (int index = 0; index < categories.length; index++) {
      final activity = categories[index];
      final isSelected = itemsSelectedValue[index] ?? false;

      items.add(Column(
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
      ));
    }

    // Add "Product Category" as the last item
    final productCategoryIndex = categories.length;
    final isProductCategoryItemSelected = itemsSelectedValue[productCategoryIndex] ?? false;

    items.add(Column(
      children: [
        GestureDetector(
          onTap: () => selectActivity(PRODUCT_CATEGORY_KEY, productCategoryIndex),
          child: Container(
            height: 80.0,
            width: double.infinity,
            color: selectedActivityName == PRODUCT_CATEGORY_KEY ? OQDOThemeData.filterDividerColor : OQDOThemeData.whiteColor,
            child: Center(
              child: CustomTextView(
                label: PRODUCT_CATEGORY_KEY,
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
    ));

    return ListView(
      shrinkWrap: true,
      children: items,
    );
  }

  Widget _buildRightPanel() {
    if (isProductCategorySelected) {
      return _buildProductCategoryList();
    } else {
      return _buildSubActivityList();
    }
  }

  Widget _buildSubActivityList() {
    return ListView.separated(
      shrinkWrap: false,
      controller: _scrollController,
      itemCount: selectedValuesFromKey.length,
      separatorBuilder: (_, __) => Container(),
      itemBuilder: (_, index) {
        final subActivity = selectedValuesFromKey[index] as SubActivity;

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
                  value: isItemSelected(subActivity),
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

  Widget _buildProductCategoryList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: equipmentCategories.length,
      itemBuilder: (context, index) {
        final category = equipmentCategories[index];

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
                  value: isItemSelected(category),
                  onChanged: (selected) {
                    setState(() {
                      if (selected ?? false) {
                        addToSelection(category);
                      } else {
                        removeFromSelection(category);
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 15.0),
              Expanded(
                child: CustomTextView(
                  label: category.name,
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
                  showSnackBarColor('Please select at least one category or product category', context, true);
                  return;
                }

                // Create result object
                Map<String, dynamic> resultMap = {};

                // Process all selections including both sub-activities and product categories
                if (selectedValues.isNotEmpty) {
                  Map<String, List<SubActivity>> subActivities = {};
                  Map<String, List<EquipmentCategory>> productCategories = {};
                  // List<int> productCategoryIds = [];

                  selectedValues.forEach((activityName, filterValues) {
                    if (activityName == PRODUCT_CATEGORY_KEY) {
                      // Process product categories
                      // productCategoryIds = filterValues.map((filterValue) => filterValue.subActivityId!).toList();

                      final productCategoriesList = filterValues
                          .map((filterValue) => EquipmentCategory(
                                equipmentCategoryId: filterValue.subActivityId!,
                                name: filterValue.activityName!,
                                code: '',
                                imageId: 0,
                                filePath: '',
                                isActive: true,
                              ))
                          .toList();
                      productCategories[activityName] = productCategoriesList;
                    } else {
                      // Process regular sub-activities
                      final subActivitiesList = filterValues
                          .map((filterValue) => SubActivity(
                                subActivityId: filterValue.subActivityId!,
                                name: filterValue.activityName!,
                                activityId: filterValue.subActivityId!,
                              ))
                          .toList();

                      subActivities[activityName] = subActivitiesList;
                    }
                  });

                  if (subActivities.isNotEmpty) {
                    resultMap['subActivities'] = subActivities;
                  }

                  if (productCategories.isNotEmpty) {
                    resultMap['productCategories'] = productCategories;
                  }
                }

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
