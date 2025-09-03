import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oqdo_mobile_app/main.dart';
import 'package:oqdo_mobile_app/model/upload_file_response.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/models/edit_view_equipment_intent_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/models/equipment_condition_response_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/models/sell_equipment_response_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/product/sell_product_detail_screen.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/viewmodel/sell_viewmodel.dart';
import 'package:oqdo_mobile_app/screens/common_widget/view_image_screen.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'dart:io';
import 'package:oqdo_mobile_app/utils/textfields_widget.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key, required this.editViewEquipmentIntentModel});

  final EditViewEquipmentIntentModel editViewEquipmentIntentModel;

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  // Lists to store selected options and images
  final Set<String> selectedActivities = {};

  // Form control flags
  bool? termsAccepted = false;
  EquipmentCondition selectedCondition = EquipmentCondition(equipmentConditionId: 0, name: '', code: '', description: '', isActive: true);

  // Text controllers for form inputs
  final TextEditingController titleController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  // Image handling variables
  final picker = ImagePicker();
  File? listingImage;
  List<XFile>? imagesList = [];

  List<String> certificateList = [];
  List<String>? certificateUploadId = [];
  File? profilepic;
  File? profileImageFile;
  CroppedFile? croppedFile;
  String uploadedImagePath = '';
  int? profileImageId;

  // Page controller for image carousel
  final controller = PageController(viewportFraction: 0.8, keepPage: true);

  // Progress dialog for loading states
  late ProgressDialog _progressDialog;

  List<EquipmentCondition> equipmentConditionList = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(message: "Please wait..");
      getAllEquipmentConditionList();

      if (widget.editViewEquipmentIntentModel.isEdit) {
        titleController.text = widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.title;
        brandController.text = widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.brand;
        descriptionController.text = widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.description;
        priceController.text = widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.price.toString();

        if (widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.equipmentImages.isNotEmpty) {
          for (int i = 0; i < widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.equipmentImages.length; i++) {
            certificateList.add(widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.equipmentImages[i].filePath);
            certificateUploadId!.add(widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.equipmentImages[i].fileStorageId.toString());
          }
        }

        termsAccepted = true;
      }
    });
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a price';
    }
    if (double.parse(priceController.text) < 0.1) {
      return 'Price must be equal or greater than to 0.1';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF006590),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'Used For',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20.0),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2B2B2B),
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.sellEquipmentCategory.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF2B2B2B),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Used For',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                    color: Color(0xFF2B2B2B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                // Updated Activity Selection Section with FilterChips
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.equipmentSubActivities.map((activity) {
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9), // Light blue-grey background
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Text(
                            activity.name,
                            style: const TextStyle(
                              color: Color(0xFF475569), // Dark blue-grey text
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                // Rest of the form fields...
                _buildProductDetailsSection(),
                const SizedBox(height: 24),
                _buildImageUploadSection(),
                const SizedBox(height: 16),
                _buildTermsAndConditions(),
                const SizedBox(height: 24),
                _buildNextButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Details',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontFamily: 'SFPro',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          labelText: 'Title',
          obscureText: false,
          maxlength: 50,
          controller: titleController,
          keyboardType: TextInputType.text,
          inputformat: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
          ],
          read: false,
          validator: (value) => validateRequired(value, 'Title'),
          hintText: 'Enter Title',
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          labelText: 'Brand',
          obscureText: false,
          maxlength: 50,
          keyboardType: TextInputType.text,
          inputformat: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
          ],
          controller: brandController,
          read: false,
          validator: (value) => validateRequired(value, 'Brand'),
          hintText: 'Enter Brand Name',
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          labelText: 'Description',
          obscureText: false,
          controller: descriptionController,
          keyboardType: TextInputType.text,
          read: false,
          maxlines: 5,
          maxlength: 500,
          hintText: 'Enter Description',
          validator: (value) => validateRequired(value, 'Description'),
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          labelText: 'Price',
          obscureText: false,
          inputformat: [
            TextInputFormatter.withFunction((oldValue, newValue) {
              // Don't allow just a decimal point
              if (newValue.text == '.') {
                return oldValue;
              }

              // Pattern to validate: max 8 digits total with optional decimal point and up to 2 decimal places
              final regExp = RegExp(r'^\d{0,8}$|^\d{0,5}\.\d{0,2}$');

              if (regExp.hasMatch(newValue.text)) {
                // Valid input
                return newValue;
              }

              // If not valid, return old value
              return oldValue;
            }),
          ],
          keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
          controller: priceController,
          read: false,
          oncomplete: () {
            FocusScope.of(context).unfocus();
            hideKeyboard();
          },
          hintText: 'Enter Price',
          validator: (value) => validatePrice(value),
        ),
        const SizedBox(height: 25),
        _buildDropdownField(selectedCondition),
      ],
    );
  }

  Widget _buildTermsAndConditions() {
    return Row(
      children: [
        Transform.scale(
          scale: 1.3,
          child: Checkbox(
            fillColor: WidgetStateProperty.resolveWith(getColor),
            checkColor: Theme.of(context).colorScheme.primaryContainer,
            value: termsAccepted,
            onChanged: (value) {
              setState(() {
                termsAccepted = value;
              });
            },
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              if (await NetworkConnectionInterceptor().isConnected()) {
                Map<String, dynamic> model = {};
                model['url'] = 'https://oqdo.com/terms-of-service/';
                model['title'] = 'Terms of Service';
                Navigator.pushNamed(context, Constants.webViewScreens, arguments: model);
              } else {
                showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
              }
            },
            child: CustomTextView(
              maxLine: 2,
              textOverFlow: TextOverflow.ellipsis,
              isStrikeThrough: true,
              label: 'I have read and accept the terms & conditions',
              textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontFamily: 'Montserrat',
                    color: Color(0xFF006590),
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _validateAndProceed();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF006590),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text(
          'Next',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'SFPro',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _validateAndProceed() {
    // First validate all required fields

    final validations = {
      'Please select condition': selectedCondition.equipmentConditionId == 0,
      'Please upload at least one image': certificateList.isEmpty,
      'Please accept terms and conditions': !termsAccepted!,
    };

    for (var entry in validations.entries) {
      if (entry.value) {
        // showSnackBarColor(entry.key, context, true);
        var snackBar = SnackBar(
            content: CustomTextView(
                label: entry.key,
                maxLine: 5,
                textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(color: OQDOThemeData.whiteColor, fontSize: 16.0, fontWeight: FontWeight.w500)),
            backgroundColor: OQDOThemeData.blackColor,
            behavior: SnackBarBehavior.floating);

        rootScaffoldMessangerKey.currentState?.removeCurrentSnackBar();
        rootScaffoldMessangerKey.currentState?.showSnackBar(snackBar);
        return;
      }
    }

    // Create the equipment model
    final equipmentModel = SellEquipmentResponseModel(
      equipmentId: widget.editViewEquipmentIntentModel.isEdit ? widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.equipmentId : 0,
      title: titleController.text.trim(),
      brand: brandController.text.trim(),
      description: descriptionController.text.trim(),
      expiryDate: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.expiryDate, // Set expiry to 60 days from now
      postDate: DateTime.now(),
      price: double.parse(priceController.text),
      isActive: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.isActive,
      sysUserId: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.sysUserId,
      equipmentCategoryId: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.equipmentCategoryId,
      isEquipmentOwner: true,
      fullName: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.fullName,
      mobileNumber: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.mobileNumber,
      email: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.email,
      userType: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.userType,
      isFavourite: false,
      sellEquipmentCategory: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.sellEquipmentCategory,
      equipmentConditionId: selectedCondition.equipmentConditionId,
      sellEquipmentCondition: SellEquipmentCondition(
        name: selectedCondition.name,
        code: selectedCondition.code,
      ),
      equipmentStatusId: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.equipmentStatusId,
      equipmentStatus: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.equipmentStatus,
      equipmentSubActivities: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.equipmentSubActivities,
      equipmentChatId: widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.equipmentChatId,
      equipmentImages: certificateUploadId!.asMap().entries.map((entry) {
        return EquipmentImage(
          equipmentImageId: 0, // New image
          fileStorageId: int.parse(entry.value),
          filePath: certificateList[entry.key],
          fileName: certificateList[entry.key].split('/').last,
        );
      }).toList(),
    );

    // Create intent model with the new equipment data
    final intent = EditViewEquipmentIntentModel(
      isEdit: widget.editViewEquipmentIntentModel.isEdit,
      equipmentId: widget.editViewEquipmentIntentModel.equipmentId,
      sellEquipmentResponseModel: equipmentModel,
    );

    // Navigate to the detail screen with the created model
    Navigator.pushNamed(
      context,
      SellProductDetailScreen.routeName,
      arguments: intent,
    );
  }

  /// Builds custom dropdown field with label and hint
  /// [label] - Label text to display above field
  /// [hint] - Placeholder text when no value selected
  Widget _buildDropdownField(EquipmentCondition condition) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Condition',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              _showConditionBottomSheet();
              // The selected value will automatically update through setState in _buildConditionOption
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFF006590)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedCondition.name.isNotEmpty ? selectedCondition.name : 'Select Condition',
                    style: TextStyle(
                      color: selectedCondition.name.isEmpty ? Colors.grey[600] : Colors.black,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Color(0xFF006590)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows bottom sheet for condition selection
  /// Displays list of condition options with descriptions
  void _showConditionBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          // Added StatefulBuilder to update bottom sheet
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Condition',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: equipmentConditionList.length,
                    itemBuilder: (context, index) {
                      final condition = equipmentConditionList[index];
                      return _buildConditionOption(condition);
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }

  /// Builds individual condition option for bottom sheet
  /// [title] - Condition name
  /// [description] - Detailed description of condition
  /// Returns ListTile with radio button
  Widget _buildConditionOption(EquipmentCondition condition) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedCondition = condition;
        });
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        condition.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        condition.description,
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'Montserrat',
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 1.2,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selectedCondition.name == condition.name
                            ? const Color(0xFF006590) // Blue border when selected
                            : const Color(0xFFB7B7B7), // Light gray border when unselected
                        width: 1.5,
                      ),
                    ),
                    child: selectedCondition.name == condition.name
                        ? Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF006590),
                              ),
                              child: Center(
                                child: Container(
                                  width: 0,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : null, // No inner circles when unselected
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Divider(
              height: 3,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: CustomTextView(
            label: 'Upload Image(s)',
            type: styleSubTitle,
            textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: const Color(0xFF818181)),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                if (certificateList.length >= 10) {
                  showSnackBar('Maximum 10 certificates allowed', context);
                } else {
                  bottomSheetImage(true);
                }
              },
              child: const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage("assets/images/camera.png"),
              ),
            ),
            const SizedBox(width: 10.0),
            certificateList.isNotEmpty
                ? Expanded(
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: certificateList.length,
                      itemBuilder: (context, index) {
                        final bool isMainImage = index == 0;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewImageScreen(
                                  url: certificateList[index],
                                ),
                              ),
                            );
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Image
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: isMainImage ? Border.all(color: const Color(0xFF006590), width: 2) : null,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(isMainImage ? 6 : 8),
                                  child: Image.network(
                                    certificateList[index],
                                    fit: BoxFit.cover,
                                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      }
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, trace) {
                                      return const Center(
                                        child: Icon(Icons.image_not_supported_outlined, size: 40),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              // Main image badge in the top left (for main image only)
                              if (isMainImage)
                                Positioned(
                                  top: 4,
                                  left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF006590),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: const Text(
                                      'MAIN',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                              // Make Main button (only for non-main images)
                              if (!isMainImage)
                                Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        // Swap with main image
                                        String tempImagePath = certificateList[index];
                                        String tempImageId = certificateUploadId![index];

                                        // Move current image to first position
                                        certificateList.removeAt(index);
                                        certificateUploadId!.removeAt(index);

                                        // Insert at beginning
                                        certificateList.insert(0, tempImagePath);
                                        certificateUploadId!.insert(0, tempImageId);
                                      });
                                    },
                                    child: SizedBox(),
                                  ),
                                ),

                              // Delete button
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (certificateList.length > 1 && index == 0) {
                                        // If deleting main image, remove it
                                        certificateList.removeAt(0);
                                        certificateUploadId!.removeAt(0);
                                      } else if (certificateList.length == 1) {
                                        // Just clear if it's the only image
                                        certificateList.clear();
                                        certificateUploadId!.clear();
                                      } else {
                                        // Delete the selected image
                                        certificateList.removeAt(index);
                                        certificateUploadId!.removeAt(index);
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, size: 14, color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ],
    );
  }

  /// Builds image upload section with preview carousel
  /// - Shows camera icon for picking images
  /// - Displays selected images in carousel
  /// - Shows page indicator for multiple images
  // Widget _buildImageUploadSection() {
  //   return Column(
  //     children: [
  //       Align(
  //         alignment: Alignment.topLeft,
  //         child: CustomTextView(
  //           label: 'Upload Image(s)',
  //           type: styleSubTitle,
  //           textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: const Color(0xFF818181)),
  //         ),
  //       ),
  //       Row(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           GestureDetector(
  //             onTap: () {
  //               if (certificateList.length >= 4) {
  //                 showSnackBar('Maximum 4 images allowed', context);
  //               } else {
  //                 bottomSheetImage(true);
  //               }
  //             },
  //             child: const CircleAvatar(
  //               radius: 50,
  //               backgroundColor: Colors.transparent,
  //               backgroundImage: AssetImage("assets/images/camera.png"),
  //             ),
  //           ),
  //           const SizedBox(
  //             width: 10.0,
  //           ),
  //           certificateList.isNotEmpty
  //               ? Expanded(
  //                   child: GridView.builder(
  //                       shrinkWrap: true,
  //                       physics: const NeverScrollableScrollPhysics(),
  //                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //                         crossAxisCount: 2,
  //                         childAspectRatio: 1,
  //                         crossAxisSpacing: 0,
  //                         mainAxisSpacing: 0,
  //                       ),
  //                       itemCount: certificateList.length,
  //                       itemBuilder: (context, index) {
  //                         return GestureDetector(
  //                           onTap: () {
  //                             Navigator.push(
  //                               context,
  //                               MaterialPageRoute(
  //                                 builder: (context) => ViewImageScreen(
  //                                   url: certificateList[index],
  //                                 ),
  //                               ),
  //                             );
  //                           },
  //                           child: Row(
  //                             children: [
  //                               IconButton(
  //                                 icon: const Icon(Icons.close),
  //                                 onPressed: () {
  //                                   certificateList.removeAt(index);
  //                                   certificateUploadId!.removeAt(index);
  //                                   profilepic = null;
  //                                   setState(() {});
  //                                 },
  //                               ),
  //                               Expanded(
  //                                 child: Image.network(
  //                                   certificateList[index],
  //                                   fit: BoxFit.cover,
  //                                   loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
  //                                     if (loadingProgress == null) {
  //                                       return child;
  //                                     }
  //                                     return Center(
  //                                       child: CircularProgressIndicator(
  //                                         value: loadingProgress.expectedTotalBytes != null
  //                                             ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
  //                                             : null,
  //                                       ),
  //                                     );
  //                                   },
  //                                   errorBuilder: (context, error, trace) {
  //                                     return ClipRRect(
  //                                       borderRadius: BorderRadius.circular(10.0),
  //                                       child: const SizedBox(
  //                                         height: 70,
  //                                         width: 70,
  //                                         child: Icon(Icons.image_not_supported_outlined, size: 70),
  //                                       ),
  //                                     );
  //                                   },
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         );
  //                       }),
  //                 )
  //               : const SizedBox(),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Future<void> getAllEquipmentConditionList() async {
    try {
      await Provider.of<SellViewmodel>(context, listen: false).getEquipmentCondition().then(
        (value) {
          Response res = value;
          if (res.statusCode == 500 || res.statusCode == 404) {
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            EquipmentConditionResponseModel model = EquipmentConditionResponseModel.fromJson(jsonDecode(res.body));
            if (model.data.isNotEmpty) {
              setState(() {
                equipmentConditionList.clear();
                equipmentConditionList.addAll(model.data);
              });
            }

            if (widget.editViewEquipmentIntentModel.isEdit) {
              for (int i = 0; i < equipmentConditionList.length; i++) {
                if (equipmentConditionList[i].equipmentConditionId == widget.editViewEquipmentIntentModel.sellEquipmentResponseModel!.equipmentConditionId) {
                  selectedCondition = equipmentConditionList[i];
                  break;
                }
              }
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

  bottomSheetImage(bool forCertificate) async {
    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text(
                      'Photo Library',
                      style: TextStyle(
                          // fontFamily: 'Fingbanger',
                          ),
                    ),
                    onTap: () async {
                      if (Constants.androidVersion >= 13) {
                        if (forCertificate) {
                          getMultiplePicFromGallery();
                        } else {
                          getPicFromGallery(forCertificate);
                        }
                      } else {
                        var status = await Permission.storage.request();
                        if (status == PermissionStatus.granted) {
                          if (forCertificate) {
                            getMultiplePicFromGallery();
                          } else {
                            getPicFromGallery(forCertificate);
                          }
                        } else if (status == PermissionStatus.denied) {
                          showSnackBar('Permission denied.Please Allow Permission.', context);
                        } else if (status == PermissionStatus.permanentlyDenied) {
                          await openAppSettings();
                        }
                      }
                    }),
                ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text(
                      'Camera',
                      style: TextStyle(
                          // fontFamily: 'Fingbanger',
                          ),
                    ),
                    onTap: () async {
                      var status = await Permission.camera.request();
                      if (status == PermissionStatus.granted) {
                        getPicFromCam(forCertificate);
                      } else if (status == PermissionStatus.denied) {
                        if (status == PermissionStatus.granted) {
                          getPicFromCam(forCertificate);
                        } else {
                          showSnackBar('Permission denied.Please Allow Permission.', context);
                        }
                      } else if (status == PermissionStatus.permanentlyDenied) {
                        await openAppSettings();
                      }
                    } //getPicFromCam
                    ),
              ],
            ),
          );
        });
    hideKeyboard();
  }

  Future getPicFromCam(bool forCertificate) async {
    Navigator.pop(context);
    await _progressDialog.show();
    setState(() {});
    var pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 60);

    if (pickedFile != null) {
      if (forCertificate) {
        var finalSize = certificateList.length + 1;
        if (finalSize > 4) {
          await _progressDialog.hide();
          setState(() {});
          showSnackBar('Maximum 4 images allowed', context);
        } else {
          var byte = await File(pickedFile.path).length();
          var kb = byte / 1024;
          var mb = kb / 1024;
          debugPrint("File size -> ${mb.toString()}");
          if (mb < 10.0) {
            await _progressDialog.hide();
            profileImageFile = File(pickedFile.path);
            setState(() {});
            var bytes = File(profileImageFile!.path).readAsBytesSync();
            String convertedBytes = base64Encode(bytes);
            uploadFile(convertedBytes, forCertificate);
          } else {
            await _progressDialog.hide();
            setState(() {});
            showSnackBarErrorColor("Please select image below 10 MB", context, true);
          }
        }
      } else {
        _cropImage(pickedFile, forCertificate);
      }
    } else {
      await _progressDialog.hide();
      setState(() {});
    }
    hideKeyboard();
  }

  Future getPicFromGallery(bool forCertificate) async {
    Navigator.pop(context);
    await _progressDialog.show();
    setState(() {});
    var pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);

    if (pickedFile != null) {
      _cropImage(pickedFile, forCertificate);
    } else {
      await _progressDialog.hide();
      setState(() {});
    }
  }

  Future<void> _cropImage(XFile pickedFile, bool forCertificate) async {
    var mCroppedFile = await ImageCropper().cropImage(sourcePath: pickedFile.path, compressFormat: ImageCompressFormat.jpg, compressQuality: 100, uiSettings: [
      AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: OQDOThemeData.buttonColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false),
      IOSUiSettings(
        title: 'Cropper',
      ),
    ]);

    if (mCroppedFile != null) {
      // setState(() async{
      var byte = await File(mCroppedFile.path).length();
      var kb = byte / 1024;
      var mb = kb / 1024;
      debugPrint("File size -> ${mb.toString()}");
      if (mb < 10.0) {
        await _progressDialog.hide();
        croppedFile = mCroppedFile;
        setState(() {});
        var bytes = File(mCroppedFile.path).readAsBytesSync();
        String convertedBytes = base64Encode(bytes);
        uploadFile(convertedBytes, forCertificate);
      } else {
        await _progressDialog.hide();
        setState(() {});
        showSnackBarErrorColor("Please select image below 10 MB", context, true);
      }
      // });
    } else {
      await _progressDialog.hide();
      setState(() {});
    }
  }

  Future getMultiplePicFromGallery() async {
    Navigator.pop(context);
    await _progressDialog.show();
    setState(() {});
    var pickedFile = await picker.pickMultiImage(imageQuality: 60);

    if (pickedFile.isNotEmpty) {
      if (pickedFile.length > 4) {
        await _progressDialog.hide();
        setState(() {});
        showSnackBar('Maximum 4 images allowed', context);
        return;
      } else {
        var finalSize = certificateList.length + pickedFile.length;
        if (finalSize > 4) {
          await _progressDialog.hide();
          setState(() {});
          showSnackBar('Maximum 4 images allowed', context);
        } else {
          double maxMb = 0.00;
          for (int i = 0; i < pickedFile.length; i++) {
            var byte = await File(pickedFile[i].path).length();
            var kb = byte / 1024;
            var mb = kb / 1024;
            if (mb > 10.0) {
              await _progressDialog.hide();
              maxMb = 0.0;
              setState(() {});
              showSnackBarErrorColor("Please select image below 10 MB", context, true);
              return;
            } else {
              maxMb = maxMb + mb;
            }
          }
          await _progressDialog.hide();
          setState(() {});
          if (maxMb < 40) {
            uploadMultipleImgFiles(pickedFile);
          } else {
            showSnackBarErrorColor("Please select image below 40 MB", context, true);
          }
        }
      }
    } else {
      await _progressDialog.hide();
      setState(() {});
    }
  }

  // The uploadFile method remains largely the same, but we'll ensure the images are added
// to the lists in the correct order
  Future<void> uploadFile(String base64File, bool forCertificate) async {
    await _progressDialog.show();
    Map uploadFileRequest = {};
    uploadFileRequest['FileStorageId'] = null;
    uploadFileRequest['FileName'] = forCertificate ? profileImageFile!.path.split('/').last : croppedFile!.path.split('/').last;
    uploadFileRequest['FileExtension'] =
        forCertificate ? profileImageFile!.path.split('/').last.split('.')[1] : croppedFile!.path.split('/').last.split('.')[1];
    uploadFileRequest['FilePath'] = base64File;

    try {
      await Provider.of<SellViewmodel>(context, listen: false).uploadFile(uploadFileRequest).then(
        (value) async {
          Response res = value;
          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            await _progressDialog.hide();
            hideKeyboard();
            UploadFileResponse? uploadFileResponse = UploadFileResponse.fromMap(jsonDecode(res.body));
            debugPrint('Upload File Response -> ${uploadFileResponse!.FileStorageId}');
            if (forCertificate) {
              // For single file, we just add it to the end which maintains order
              certificateUploadId!.add(uploadFileResponse.FileStorageId.toString());
              if (uploadFileResponse.FilePath != null && uploadFileResponse.FilePath!.isNotEmpty) {
                setState(() {
                  certificateList.add(uploadFileResponse.FilePath!);
                });
              } else {
                showSnackBarColor("Image not uploaded", context, true);
              }
              profileImageFile = null;
              croppedFile = null;
            } else {
              setState(() {
                uploadedImagePath = uploadFileResponse.FilePath!;
                profileImageId = uploadFileResponse.FileStorageId;
              });
            }
          } else {
            await _progressDialog.hide();
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
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      await _progressDialog.hide();
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

// Completely revised uploadMultipleImgFiles method to upload sequentially
  Future<void> uploadMultipleImgFiles(List<XFile> pickedFiles) async {
    try {
      await _progressDialog.show();

      // Process files one at a time to guarantee order
      for (int i = 0; i < pickedFiles.length; i++) {
        XFile file = pickedFiles[i];

        // Create request for this single file
        Map<String, dynamic> uploadFileRequest = {};
        uploadFileRequest['FileStorageId'] = null;
        uploadFileRequest['FileName'] = file.path.split('/').last;
        uploadFileRequest['FileExtension'] = file.path.split('/').last.split('.')[1];
        var bytes = await File(file.path).readAsBytes();
        String convertedBytes = base64Encode(bytes);
        uploadFileRequest['FilePath'] = convertedBytes;

        // Upload single file and handle response immediately to maintain order
        Response res = await Provider.of<SellViewmodel>(context, listen: false).uploadFile(uploadFileRequest);

        if (res.statusCode == 200) {
          UploadFileResponse? uploadFileResponse = UploadFileResponse.fromMap(jsonDecode(res.body));
          debugPrint('Upload File Response -> ${uploadFileResponse!.FileStorageId}');

          // Add to lists in order of upload
          certificateUploadId!.add(uploadFileResponse.FileStorageId.toString());
          if (uploadFileResponse.FilePath != null && uploadFileResponse.FilePath!.isNotEmpty) {
            setState(() {
              certificateList.add(uploadFileResponse.FilePath!);
            });
          } else {
            showSnackBarColor("Image ${i + 1} not uploaded", context, true);
          }
        } else if (res.statusCode == 500 || res.statusCode == 404) {
          showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          break; // Stop on server error
        } else {
          Map<String, dynamic> errorModel = jsonDecode(res.body);
          if (errorModel.containsKey('ModelState')) {
            Map<String, dynamic> modelState = errorModel['ModelState'];
            if (modelState.containsKey('ErrorMessage')) {
              showSnackBarColor(modelState['ErrorMessage'][0], context, true);
            }
          }
          break; // Stop on other errors
        }

        // Optional: Update progress dialog to show current upload progress
        _progressDialog.update(message: "Uploading image ${i + 1}/${pickedFiles.length}...");
      }

      await _progressDialog.hide();
      hideKeyboard();
    } on NoConnectivityException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      await _progressDialog.hide();
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  // Future<void> uploadFile(String base64File, bool forCertificate) async {
  //   await _progressDialog.show();
  //   Map uploadFileRequest = {};
  //   uploadFileRequest['FileStorageId'] = null;
  //   uploadFileRequest['FileName'] = forCertificate ? profileImageFile!.path.split('/').last : croppedFile!.path.split('/').last;
  //   uploadFileRequest['FileExtension'] =
  //       forCertificate ? profileImageFile!.path.split('/').last.split('.')[1] : croppedFile!.path.split('/').last.split('.')[1];
  //   uploadFileRequest['FilePath'] = base64File;

  //   try {
  //     await Provider.of<SellViewmodel>(context, listen: false).uploadFile(uploadFileRequest).then(
  //       (value) async {
  //         Response res = value;
  //         if (res.statusCode == 500 || res.statusCode == 404) {
  //           await _progressDialog.hide();
  //           showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
  //         } else if (res.statusCode == 200) {
  //           await _progressDialog.hide();
  //           UploadFileResponse? uploadFileResponse = UploadFileResponse.fromMap(jsonDecode(res.body));
  //           debugPrint('Upload File Response -> ${uploadFileResponse!.FileStorageId}');
  //           if (forCertificate) {
  //             certificateUploadId!.add(uploadFileResponse.FileStorageId.toString());
  //             if (uploadFileResponse.FilePath != null && uploadFileResponse.FilePath!.isNotEmpty) {
  //               setState(() {
  //                 certificateList.add(uploadFileResponse.FilePath!);
  //               });
  //             } else {
  //               showSnackBarColor("Image not uploaded", context, true);
  //             }
  //             profileImageFile = null;
  //             croppedFile = null;
  //           } else {
  //             setState(() {
  //               uploadedImagePath = uploadFileResponse.FilePath!;
  //               profileImageId = uploadFileResponse.FileStorageId;
  //             });
  //             // Provider.of<ChatProvider>(context, listen: false).setProfileImagePath(uploadFileResponse.FilePath!);
  //           }
  //         } else {
  //           await _progressDialog.hide();
  //           Map<String, dynamic> errorModel = jsonDecode(res.body);
  //           if (errorModel.containsKey('ModelState')) {
  //             Map<String, dynamic> modelState = errorModel['ModelState'];
  //             if (modelState.containsKey('ErrorMessage')) {
  //               showSnackBarColor(modelState['ErrorMessage'][0], context, true);
  //             }
  //           }
  //         }
  //       },
  //     );
  //   } on NoConnectivityException catch (_) {
  //     await _progressDialog.hide();
  //     showSnackBarErrorColor(AppStrings.noInternet, context, true);
  //   } on TimeoutException catch (_) {
  //     await _progressDialog.hide();
  //     showSnackBarErrorColor(AppStrings.timeout, context, true);
  //   } on ServerException catch (_) {
  //     await _progressDialog.hide();
  //     showSnackBarErrorColor(AppStrings.serverError, context, true);
  //   } catch (exception) {
  //     await _progressDialog.hide();
  //     showSnackBarErrorColor(exception.toString(), context, true);
  //   }
  // }

  // Future<void> uploadMultipleImgFiles(List<XFile> pickedFile) async {
  //   try {
  //     await _progressDialog.show();
  //     List<Map<String, dynamic>> requestList = [];

  //     for (int i = 0; i < pickedFile.length; i++) {
  //       Map<String, dynamic> uploadFileRequest = {};
  //       uploadFileRequest['FileStorageId'] = null;
  //       uploadFileRequest['FileName'] = pickedFile[i].path.split('/').last;
  //       uploadFileRequest['FileExtension'] = pickedFile[i].path.split('/').last.split('.')[1];
  //       var bytes = File(pickedFile[i].path).readAsBytesSync();
  //       String convertedBytes = base64Encode(bytes);
  //       uploadFileRequest['FilePath'] = convertedBytes;
  //       requestList.add(uploadFileRequest);
  //     }
  //     await Provider.of<SellViewmodel>(context, listen: false).multipleUploadFile(requestList).then(
  //       (value) async {
  //         Response res = value;
  //         if (res.statusCode == 500 || res.statusCode == 404) {
  //           await _progressDialog.hide();
  //           showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
  //         } else if (res.statusCode == 200) {
  //           await _progressDialog.hide();
  //           List<dynamic> bodyList = jsonDecode(res.body);
  //           List<UploadFileResponse?> uploadFileResponse = bodyList.map((e) => UploadFileResponse.fromMap(e)).toList();
  //           debugPrint('Upload File Response -> ${uploadFileResponse[0]!.FileStorageId}');

  //           for (var i = 0; i < uploadFileResponse.length; i++) {
  //             certificateUploadId!.add(uploadFileResponse[i]!.FileStorageId.toString());
  //             if (uploadFileResponse[i]!.FilePath != null && uploadFileResponse[i]!.FilePath!.isNotEmpty) {
  //               setState(() {
  //                 certificateList.add(uploadFileResponse[i]!.FilePath!);
  //               });
  //             } else {
  //               showSnackBarColor("Image not uploaded", context, true);
  //             }
  //           }
  //         } else {
  //           await _progressDialog.hide();
  //           Map<String, dynamic> errorModel = jsonDecode(res.body);
  //           if (errorModel.containsKey('ModelState')) {
  //             Map<String, dynamic> modelState = errorModel['ModelState'];
  //             if (modelState.containsKey('ErrorMessage')) {
  //               showSnackBarColor(modelState['ErrorMessage'][0], context, true);
  //             }
  //           }
  //         }
  //       },
  //     );
  //   } on NoConnectivityException catch (_) {
  //     await _progressDialog.hide();
  //     showSnackBarErrorColor(AppStrings.noInternet, context, true);
  //   } on TimeoutException catch (_) {
  //     await _progressDialog.hide();
  //     showSnackBarErrorColor(AppStrings.timeout, context, true);
  //   } on ServerException catch (_) {
  //     await _progressDialog.hide();
  //     showSnackBarErrorColor(AppStrings.serverError, context, true);
  //   } catch (exception) {
  //     await _progressDialog.hide();
  //     showSnackBarErrorColor(exception.toString(), context, true);
  //   }
  // }

  // Widget to display the main image (first in the list) with title overlay
  Widget _buildMainImage() {
    return Stack(
      children: [
        // Main image container
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewImageScreen(
                  url: certificateList[0],
                ),
              ),
            );
          },
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF006590), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Main image
                  Image.network(
                    certificateList[0],
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Center(
                        child: CircularProgressIndicator(
                          value:
                              loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, trace) {
                      return const Center(
                        child: Icon(Icons.image_not_supported_outlined, size: 70),
                      );
                    },
                  ),

                  // Semi-transparent overlay at the bottom for text
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      color: Colors.black.withOpacity(0.5),
                      child: Text(
                        titleController.text.isEmpty ? 'Main Image' : titleController.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  // "Main Image" badge in the top left
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006590),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'MAIN IMAGE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Delete button in the top right
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () {
                        if (certificateList.length > 1) {
                          // Move second image to first position if deleting the main image
                          certificateList.removeAt(0);
                          certificateUploadId!.removeAt(0);
                        } else {
                          // Just clear if it's the only image
                          certificateList.clear();
                          certificateUploadId!.clear();
                        }
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 20, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

// Widget to display additional images in a grid
  Widget _buildAdditionalImages() {
    // Skip the first image (main image) and show the rest
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: certificateList.length - 1, // Exclude the main image
      itemBuilder: (context, index) {
        // Adjust index because we're skipping the first image
        final actualIndex = index + 1;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewImageScreen(
                  url: certificateList[actualIndex],
                ),
              ),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  certificateList[actualIndex],
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, trace) {
                    return const Center(
                      child: Icon(Icons.image_not_supported_outlined, size: 40),
                    );
                  },
                ),
              ),

              // Make Main button - to promote this image to main
              Positioned(
                bottom: 5,
                right: 5,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      // Swap with main image
                      String tempImagePath = certificateList[actualIndex];
                      String tempImageId = certificateUploadId![actualIndex];

                      // Move current image to first position
                      certificateList.removeAt(actualIndex);
                      certificateUploadId!.removeAt(actualIndex);

                      // Insert at beginning
                      certificateList.insert(0, tempImagePath);
                      certificateUploadId!.insert(0, tempImageId);
                    });
                  },
                  // child: Container(
                  //   padding: const EdgeInsets.all(4),
                  //   decoration: BoxDecoration(
                  //     color: const Color(0xFF006590).withOpacity(0.8),
                  //     borderRadius: BorderRadius.circular(4),
                  //   ),
                  //   child: const Text(
                  //     'MAIN',
                  //     style: TextStyle(
                  //       color: Colors.white,
                  //       fontSize: 8,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ),
                ),
              ),

              // Delete button
              Positioned(
                top: 5,
                right: 5,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      certificateList.removeAt(actualIndex);
                      certificateUploadId!.removeAt(actualIndex);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 16, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void hideKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
