import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/models/edit_view_equipment_intent_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/models/equipment_category_response_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/models/sell_equipment_response_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/sell_product_category_screen.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/viewmodel/sell_viewmodel.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/views/product_category.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:provider/provider.dart';

class ProductCategoryScreen extends StatefulWidget {
  final EditViewEquipmentIntentModel editViewEquipmentIntentModel;
  const ProductCategoryScreen({super.key, required this.editViewEquipmentIntentModel});

  @override
  State<ProductCategoryScreen> createState() => _ProductCategoryScreenState();
}

class _ProductCategoryScreenState extends State<ProductCategoryScreen> {
  List<EquipmentCategory> categories = [];
  bool isLoading = true;
  SellEquipmentResponseModel? equipmentDetails;
  int? selectedCategoryId;

  bool isCategorySelected(EquipmentCategory category) {
    if (selectedCategoryId != null) {
      return category.equipmentCategoryId == selectedCategoryId;
    }
    if (widget.editViewEquipmentIntentModel.isEdit && equipmentDetails != null) {
      return equipmentDetails!.sellEquipmentCategory.name == category.name;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getAllEquipmentCategories();
      if (widget.editViewEquipmentIntentModel.isEdit) {
        getSellEquipmentDetails();
      }
    });
  }

  void navigateToNextScreen(EquipmentCategory category) {
    final selectedCategory = SellEquipmentCategory(
      name: category.name,
      code: category.code,
    );

    if (!widget.editViewEquipmentIntentModel.isEdit) {
      // Handle new equipment case
      final intent = EditViewEquipmentIntentModel(
        equipmentId: 0,
        isEdit: false,
        sellEquipmentResponseModel: SellEquipmentResponseModel(
            equipmentId: 0,
            title: '',
            brand: '',
            description: '',
            postDate: DateTime.now(),
            price: 0,
            isActive: true,
            sysUserId: 0,
            equipmentCategoryId: category.equipmentCategoryId,
            isEquipmentOwner: true,
            fullName: '',
            mobileNumber: '',
            
            email: '',
            userType: '',
            isFavourite: false,
            sellEquipmentCategory: selectedCategory,
            equipmentStatusId: 0,
            equipmentStatus: EquipmentStatus(name: '', code: ''),
            equipmentSubActivities: [],
            equipmentImages: [],
            equipmentConditionId: 0,
            sellEquipmentCondition: SellEquipmentCondition(name: '', code: ''),
            equipmentChatId: null),
      );
      Navigator.pushNamed(
        context,
        SellProductCategoryScreen.routeName,
        arguments: intent,
      );
    } else if (equipmentDetails != null) {
      // Handle edit case
      final model = SellEquipmentResponseModel(
        equipmentId: equipmentDetails!.equipmentId,
        title: equipmentDetails!.title,
        brand: equipmentDetails!.brand,
        description: equipmentDetails!.description,
        postDate: equipmentDetails!.postDate,
        price: equipmentDetails!.price,
        isActive: equipmentDetails!.isActive,
        sysUserId: equipmentDetails!.sysUserId,
        equipmentCategoryId: category.equipmentCategoryId,
        isEquipmentOwner: equipmentDetails!.isEquipmentOwner,
        fullName: equipmentDetails!.fullName,
        mobileNumber: equipmentDetails!.mobileNumber,
        email: equipmentDetails!.email,
        userType: equipmentDetails!.userType,
        isFavourite: equipmentDetails!.isFavourite,
        sellEquipmentCategory: selectedCategory,
        equipmentStatusId: equipmentDetails!.equipmentStatusId,
        equipmentStatus: equipmentDetails!.equipmentStatus,
        equipmentSubActivities: equipmentDetails!.equipmentSubActivities,
        equipmentImages: equipmentDetails!.equipmentImages,
        equipmentConditionId: equipmentDetails!.equipmentConditionId,
        sellEquipmentCondition: equipmentDetails!.sellEquipmentCondition,
        equipmentChatId: equipmentDetails!.equipmentChatId,
      );

      final intent = EditViewEquipmentIntentModel(
        equipmentId: widget.editViewEquipmentIntentModel.equipmentId,
        isEdit: true,
        sellEquipmentResponseModel: model,
      );

      Navigator.pushNamed(
        context,
        SellProductCategoryScreen.routeName,
        arguments: intent,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: const Text(
          "Bazaar",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'SFPro',
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        backgroundColor: const Color(0xFF006590),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Product Category',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'SFPro',
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomScrollView(
                      slivers: [
                        SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.2,
                            mainAxisSpacing: 1,
                            crossAxisSpacing: 1,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final category = categories[index];
                              final isSelected = isCategorySelected(category);
                              return CategoryCard(
                                icon: category.filePath,
                                title: category.name,
                                isSelected: isSelected,
                                onTap: () {
                                  setState(() {
                                    selectedCategoryId = category.equipmentCategoryId;
                                  });
                                  navigateToNextScreen(category);
                                },
                              );
                            },
                            childCount: categories.length,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getAllEquipmentCategories() async {
    try {
      await Provider.of<SellViewmodel>(context, listen: false).getAllEquipmentCategories().then(
        (value) {
          Response res = value;
          debugPrint("Response: ${res.body}");

          if (res.statusCode == 500 || res.statusCode == 404) {
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            EquipmentCategoryResponseModel categoryResponse = EquipmentCategoryResponseModel.fromJson(jsonDecode(res.body));

            setState(() {
              categories = categoryResponse.data;
              isLoading = false;
            });
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
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getSellEquipmentDetails() async {
    try {
      final response = await Provider.of<SellViewmodel>(context, listen: false).getEquipmentById(widget.editViewEquipmentIntentModel.equipmentId.toString());

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          equipmentDetails = SellEquipmentResponseModel.fromJson(data);
          selectedCategoryId = equipmentDetails?.equipmentCategoryId;
        });
      } else if (response.statusCode == 500 || response.statusCode == 404) {
        showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
      } else {
        Map<String, dynamic> errorModel = json.decode(response.body);
        showSnackBarErrorColor(errorModel['ModelState']?['ErrorMessage']?[0] ?? 'An error occurred', context, true);
      }
    } on NoConnectivityException catch (_) {
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      showSnackBarErrorColor(exception.toString(), context, true);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
