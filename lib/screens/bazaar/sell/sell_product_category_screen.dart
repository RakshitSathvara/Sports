import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/screens/bazaar/ads_screen/model/subactivyt_and_activity_response_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/models/edit_view_equipment_intent_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/models/sell_equipment_response_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/viewmodel/sell_viewmodel.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:provider/provider.dart';

class SellProductCategoryScreen extends StatefulWidget {
  static const String routeName = '/sell-product-category';
  const SellProductCategoryScreen({super.key, required this.editViewEquipmentIntentModel});
  final EditViewEquipmentIntentModel editViewEquipmentIntentModel;

  @override
  State<SellProductCategoryScreen> createState() => _SellProductCategoryScreenState();
}

class _SellProductCategoryScreenState extends State<SellProductCategoryScreen> {
  List<Activity> categories = [];
  Set<int> selectedSubActivities = {};
  String postExpiryDate = '';

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getAllActivitys();
    });
    super.initState();
  }

  Map<Activity, List<SubActivity>> getSelectedActivityMap() {
    Map<Activity, List<SubActivity>> activityMap = {};

    for (var category in categories) {
      List<SubActivity> selectedSubs = category.subActivities.where((sub) => selectedSubActivities.contains(sub.subActivityId)).toList();

      if (selectedSubs.isNotEmpty) {
        activityMap[category] = selectedSubs;
      }
    }

    return activityMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Product Category',
        onBack: () => Navigator.pop(context),
        isIconColorBlack: false,
        backgroundColor: const Color(0xFF006989),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Used For',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'SFPro',
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(color: Color(0xFFE3E3E3)),
                    ),
                  ),
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            for (var category in categories) {
                              category.isExpanded = categories[index].activityId == category.activityId;
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: categories[index].isExpanded ? Colors.white : Colors.transparent,
                            border: Border(
                              bottom: BorderSide(color: Color(0xFFE3E3E3)),
                            ),
                          ),
                          child: Text(
                            categories[index].name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: categories[index].isExpanded ? 'SFPro' : 'Montserrat',
                              fontWeight: categories[index].isExpanded ? FontWeight.w700 : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: categories.where((c) => c.isExpanded).length,
                          itemBuilder: (context, index) {
                            final category = categories.firstWhere((c) => c.isExpanded);
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: category.subActivities.length,
                              itemBuilder: (context, subIndex) {
                                final subActivity = category.subActivities[subIndex];

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
                                          value: selectedSubActivities.contains(subActivity.subActivityId),
                                          onChanged: (value) {
                                            setState(() {
                                              if (value == true) {
                                                selectedSubActivities.add(subActivity.subActivityId);
                                              } else {
                                                selectedSubActivities.remove(subActivity.subActivityId);
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
                                // return CheckboxListTile(
                                //   title: Text(
                                //     subActivity.name,
                                //     style: TextStyle(fontSize: 14),
                                //   ),
                                //   value: selectedSubActivities.contains(subActivity.subActivityId),
                                //   onChanged: (bool? value) {
                                //     setState(() {
                                //       if (value == true) {
                                //         selectedSubActivities.add(subActivity.subActivityId);
                                //       } else {
                                //         selectedSubActivities.remove(subActivity.subActivityId);
                                //       }
                                //     });
                                //   },
                                //   controlAffinity: ListTileControlAffinity.leading,
                                //   activeColor: Color(0xFF006989),
                                //   contentPadding: EdgeInsets.symmetric(horizontal: 16),
                                // );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 70.0,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        foregroundColor: WidgetStateProperty.all<Color>(const Color(0xFFCECECE)),
                        backgroundColor: WidgetStateProperty.all<Color>(const Color(0xFFCECECE)),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                            side: BorderSide(
                              color: Color(0xFFCECECE),
                            ),
                          ),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: CustomTextView(
                        label: 'Cancel',
                        textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w400,
                              fontSize: 16.0,
                              decoration: TextDecoration.underline,
                              color: OQDOThemeData.blackColor,
                              fontFamily: 'SFPro',
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
                        foregroundColor: WidgetStateProperty.all<Color>(const Color(0xFF006590)),
                        backgroundColor: WidgetStateProperty.all<Color>(selectedSubActivities.isEmpty ? const Color(0xFFCECECE) : const Color(0xFF006590)),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                            side: BorderSide(
                              color: selectedSubActivities.isEmpty ? const Color(0xFFCECECE) : const Color(0xFF006590),
                            ),
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (selectedSubActivities.isNotEmpty) {
                          // Create list of EquipmentSubActivity from selected activities
                          List<EquipmentSubActivity> newEquipmentSubActivities = [];

                          // For each category
                          for (var category in categories) {
                            // Get selected sub activities from this category
                            for (var subActivity in category.subActivities) {
                              if (selectedSubActivities.contains(subActivity.subActivityId)) {
                                // Create EquipmentSubActivity instance
                                newEquipmentSubActivities.add(EquipmentSubActivity(
                                  equipmentSubActivityId: 0, // Set to 0 for new selections
                                  subActivityId: subActivity.subActivityId,
                                  name: subActivity.name,
                                ));
                              }
                            }
                          }
                          var model = SellEquipmentResponseModel(
                              equipmentId: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.equipmentId,
                              title: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.title,
                              brand: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.brand,
                              description: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.description,
                              postDate: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.postDate,
                              price: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.price,
                              isActive: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.isActive,
                              sysUserId: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.sysUserId,
                              equipmentCategoryId: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.equipmentCategoryId,
                              isEquipmentOwner: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.isEquipmentOwner,
                              fullName: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.fullName,
                              mobileNumber: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.mobileNumber,
                              email: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.email,
                              userType: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.userType,
                              expiryDate: DateTime.parse(postExpiryDate),
                              isFavourite: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.isFavourite,
                              sellEquipmentCategory: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.sellEquipmentCategory,
                              equipmentStatusId: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.equipmentStatusId,
                              equipmentStatus: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.equipmentStatus,
                              equipmentSubActivities: newEquipmentSubActivities,
                              equipmentImages: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.equipmentImages,
                              equipmentConditionId: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.equipmentConditionId,
                              sellEquipmentCondition: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.sellEquipmentCondition,
                              equipmentChatId: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.equipmentChatId);

                          var intent = EditViewEquipmentIntentModel(
                            equipmentId: widget.editViewEquipmentIntentModel.equipmentId,
                            isEdit: widget.editViewEquipmentIntentModel.isEdit,
                            sellEquipmentResponseModel: model,
                          );

                          Navigator.pushNamed(context, Constants.sellProductDetailScreen, arguments: intent);
                        }
                      },
                      child: CustomTextView(
                        label: 'Apply',
                        textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                              color: selectedSubActivities.isEmpty ? Colors.grey[600] : OQDOThemeData.whiteColor,
                              fontFamily: 'SFPro',
                            ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getAllActivitys() async {
    try {
      await Provider.of<SellViewmodel>(context, listen: false).getAllActivityAndSubActivity().then(
        (value) {
          Response res = value;
          if (res.statusCode == 500 || res.statusCode == 404) {
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            SubActivityAndActivityResponseModel model = SubActivityAndActivityResponseModel.fromJson(jsonDecode(res.body));
            if (model.data.isNotEmpty) {
              int expiryDays = int.parse(OQDOApplication.instance.configResponseModel!.equipmentDefualtExpiryDays);
              postExpiryDate = DateTime.now().add(Duration(days: expiryDays)).toString();

              setState(() {
                categories = model.data;
                categories.first.isExpanded = true;

                // Check if in edit mode and we have equipment details
                if (widget.editViewEquipmentIntentModel.isEdit && widget.editViewEquipmentIntentModel.sellEquipmentResponseModel != null) {
                  // Get the equipment sub activities from the model
                  final equipmentSubActivities = widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.equipmentSubActivities;

                  // Clear any existing selections
                  selectedSubActivities.clear();

                  // For each category
                  for (var category in categories) {
                    // For each sub-activity in the category
                    for (var subActivity in category.subActivities) {
                      // Check if this sub-activity exists in equipment sub activities
                      bool exists = equipmentSubActivities.any((equipSubActivity) => equipSubActivity.subActivityId == subActivity.subActivityId);

                      // If it exists, add to selected set
                      if (exists) {
                        selectedSubActivities.add(subActivity.subActivityId);

                        // Expand this category
                        for (var c in categories) {
                          c.isExpanded = (c.activityId == category.activityId);
                        }
                      }
                    }
                  }
                }
              });
            }
          } else {
            Map<String, dynamic> errorModel = jsonDecode(res.body);
            if (errorModel.containsKey('ModelState')) {
              Map<String, dynamic> modelState = errorModel['ModelState'];
              if (modelState.containsKey('ErrorMessage')) {
                showSnackBarColor(modelState['ErrorMessage'][0], context, true);
              }
            }
          }
        },
      );
    } on NoConnectivityException catch (_) {
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }
}
