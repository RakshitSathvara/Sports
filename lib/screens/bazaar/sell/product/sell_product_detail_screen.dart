import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/theme/custom_colors.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/helper/helpers.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/models/edit_view_equipment_intent_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/viewmodel/sell_viewmodel.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class SellProductDetailScreen extends StatefulWidget {
  static const routeName = '/sell-product-detail';
  final EditViewEquipmentIntentModel editViewEquipmentIntentModel;
  const SellProductDetailScreen({super.key, required this.editViewEquipmentIntentModel});

  @override
  State<SellProductDetailScreen> createState() => _SellProductDetailScreenState();
}

class _SellProductDetailScreenState extends State<SellProductDetailScreen> {
  final Set<String> selectedActivities = {};
  late ProgressDialog _progressDialog;
  List<String>? certificateUploadId = [];
  String postExpiryDate = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(
              message: "Please wait..",
              backgroundColor: Theme.of(context).extension<CustomColors>()!.progressDialogBackgroundColor,
              messageTextStyle: TextStyle(color: Theme.of(context).extension<CustomColors>()!.blackAndWhiteColor, fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 18));
      if (!widget.editViewEquipmentIntentModel.isEdit) {
        int expiryDays = int.parse(OQDOApplication.instance.configResponseModel!.equipmentDefualtExpiryDays);
        postExpiryDate = DateTime.now().add(Duration(days: expiryDays)).toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon:  Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.background),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Product List',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.background,
                fontWeight: FontWeight.w600,
                fontSize: 20.0,
              ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      'Review your Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'SFPro',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Image carousel
                    if (product.equipmentImages.isNotEmpty) ...[
                      SizedBox(
                        height: 200,
                        child: PageView.builder(
                          itemCount: product.equipmentImages.length,
                          controller: PageController(viewportFraction: 0.93),
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  product.equipmentImages[index].filePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error)),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                    ],

                    // Product title
                    Text(
                      product.title,
                      style: TextStyle(fontSize: 25, fontFamily: 'Montserrat', fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onBackground),
                    ),
                    SizedBox(height: 8),

                    // Product price
                    Text(
                      'S\$ ${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Category information
                    _buildInfoSection('Category', product.sellEquipmentCategory.name),

                    // Used For section with activities
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          'Used For',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2B2B2B),
                          ),
                        ),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: product.equipmentSubActivities.map((activity) {
                            return FilterChip(
                              selected: selectedActivities.contains(activity.name),
                              label: Text(
                                activity.name,
                                style: TextStyle(
                                  color: selectedActivities.contains(activity.name) ? Theme.of(context).colorScheme.background : Theme.of(context).extension<CustomColors>()!.chipText,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              backgroundColor: Theme.of(context).extension<CustomColors>()!.chipBackground,
                              selectedColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: selectedActivities.contains(activity.name) ? Theme.of(context).primaryColor : Theme.of(context).extension<CustomColors>()!.chipBackground,
                                ),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              showCheckmark: false,
                              onSelected: (bool selected) {
                                setState(() {
                                  if (selected) {
                                    selectedActivities.add(activity.name);
                                  } else {
                                    selectedActivities.remove(activity.name);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Product details
                    _buildInfoSection('Description', product.description),
                    _buildInfoSection('Brand', product.brand),
                    _buildInfoSection('Condition', product.sellEquipmentCondition.name),

                    // Expiry date if available
                    // if (product.expiryDate != null) ...[
                    Text(
                      postExpiryDate.isEmpty
                          ? 'Post expiry date: ${DateFormat('dd/MM/yyyy').format(product.expiryDate!)}'
                          : 'Post expiry date: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(postExpiryDate))}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Montserrat',
                        color: Color(0xFF808080),
                      ),
                    ),
                    SizedBox(height: 16),
                    // ],
                  ],
                ),
              ),
            ),
          ),

          // Post button
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => postProduct(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:  Text(
                    'Post Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.background,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            color: Color(0xFF2B2B2B),
          ),
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Future<void> postProduct() async {
    try {
      await _progressDialog.show();
      final product = widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!;

      Map<String, dynamic> request = {};

      if (widget.editViewEquipmentIntentModel.isEdit) {
        request = {
          'EquipmentId': widget.editViewEquipmentIntentModel.equipmentId,
          'Title': product.title,
          'Brand': product.brand,
          'Price': product.price,
          'EquipmentStatusId': widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.equipmentStatusId,
          'SysUserId': OQDOApplication.instance.userID,
          'EquipmentCategoryId': product.equipmentCategoryId,
          // 'ExpiryDate': product.expiryDate,
          'EquipmentConditionId': product.equipmentConditionId,
          'Description': product.description,
          'EquipmentSubActivityDtos': product.equipmentSubActivities.map((activity) => {'SubActivityId': activity.subActivityId}).toList(),
          'EquipmentImageDtos': product.equipmentImages.map((image) => {'FileStorageId': image.fileStorageId}).toList(),
        };
      } else {
        debugPrint('postExpiryDate: ${DateTime.parse(postExpiryDate).toIso8601String()}');
        request = {
          'Title': product.title,
          'Brand': product.brand,
          'Price': product.price,
          'SysUserId': OQDOApplication.instance.userID,
          'EquipmentCategoryId': product.equipmentCategoryId,
          'EquipmentConditionId': product.equipmentConditionId,
          'Description': product.description,
          'ExpiryDate': DateTime.parse(postExpiryDate).toIso8601String(),
          'EquipmentSubActivityDtos': product.equipmentSubActivities.map((activity) => {'SubActivityId': activity.subActivityId}).toList(),
          'EquipmentImageDtos': product.equipmentImages.map((image) => {'FileStorageId': image.fileStorageId}).toList(),
        };
      }

      final sellViewmodel = Provider.of<SellViewmodel>(context, listen: false);
      Response response;
      if (widget.editViewEquipmentIntentModel.isEdit) {
        response = await sellViewmodel.editPostProduct(request);
      } else {
        response = await sellViewmodel.postProduct(request);
      }
      if (!mounted) return;

      await _progressDialog.hide();

      if (response.statusCode == 500 || response.statusCode == 404) {
        showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, false);
      } else if (response.statusCode == 200) {
        if (widget.editViewEquipmentIntentModel.isEdit) {
          showSnackBarColor("Product updated successfully", context, false);
        } else {
          showSnackBarColor("Product posted successfully", context, false);
        }

        Navigator.pushNamedAndRemoveUntil(context, Constants.bazaarHomeScreen, arguments: 1, Helper.of(context).predicate);
      } else {
        await _progressDialog.hide();
        Map<String, dynamic> errorModel = jsonDecode(response.body);
        if (errorModel.containsKey('ModelState')) {
          Map<String, dynamic> modelState = errorModel['ModelState'];
          if (modelState.containsKey('ErrorMessage')) {
            showSnackBarColor(modelState['ErrorMessage'][0], context, true);
          }
        }
      }
    } on NoConnectivityException catch (_) {
      await _progressDialog.hide();
      if (mounted) {
        showSnackBarErrorColor(AppStrings.noInternet, context, true);
      }
    } on TimeoutException catch (_) {
      await _progressDialog.hide();
      if (mounted) {
        showSnackBarErrorColor(AppStrings.timeout, context, true);
      }
    } on ServerException catch (_) {
      await _progressDialog.hide();
      if (mounted) {
        showSnackBarErrorColor(AppStrings.serverError, context, true);
      }
    } catch (exception) {
      await _progressDialog.hide();
      if (mounted) {
        showSnackBarErrorColor(exception.toString(), context, true);
      }
    }
  }
}
