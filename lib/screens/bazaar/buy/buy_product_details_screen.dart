import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/models/sell_equipment_response_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/viewmodel/sell_viewmodel.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

/// A screen that displays product details for selling items
/// Shows product images, details, and a post button
class BuyProductDetailsScreen extends StatefulWidget {
  static const String routeName = '/buy_product_details';
  final String equipmentId;

  const BuyProductDetailsScreen({super.key, required this.equipmentId});

  @override
  State<BuyProductDetailsScreen> createState() => _BuyProductDetailsScreenState();
}

class _BuyProductDetailsScreenState extends State<BuyProductDetailsScreen> {
  final Set<String> selectedActivities = {};
  late ProgressDialog _progressDialog;
  List<String>? certificateUploadId = [];
  SellEquipmentResponseModel? equipmentDetails;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(message: "Please wait..");
      getSellEquipmentDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF006989),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Product List',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20.0,
              ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF006590),
        onPressed: () async {
          final value = await Navigator.pushNamed(context, Constants.buyingChatScreen, arguments: equipmentDetails);
          if (value != null && value is bool && value) {
            equipmentDetails = null;
            getSellEquipmentDetails();
          }
        },
        child: Image.asset(
          'assets/images/ic_bazaar_msg.png',
          color: Colors.white,
          height: 25,
          width: 25,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: equipmentDetails == null
                      ? Container()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header text
                            Text(
                              'Review your Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'SFPro',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 16),

                            /// Product Image Carousel
                            if (equipmentDetails?.equipmentImages.isNotEmpty == true)
                              SizedBox(
                                height: 200,
                                child: PageView.builder(
                                  itemCount: equipmentDetails?.equipmentImages.length,
                                  controller: PageController(viewportFraction: 0.93),
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          equipmentDetails?.equipmentImages[index].filePath ?? '',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[300],
                                              child: const Icon(Icons.error),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            SizedBox(height: 16),

                            // Product title
                            Text(
                              equipmentDetails?.title ?? 'No title available',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8),

                            // Product price
                            Text(
                              'S\$ ${equipmentDetails?.price.toStringAsFixed(2) ?? '0.00'}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF006590),
                              ),
                            ),
                            SizedBox(height: 16),

                            // Category information
                            _buildInfoSection('Category', equipmentDetails?.sellEquipmentCategory.name ?? 'N/A'),

                            // Used For section with chips
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
                                  children: equipmentDetails?.equipmentSubActivities.map((activity) {
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
                                      }).toList() ??
                                      [Container()],
                                )
                              ],
                            ),
                            SizedBox(height: 16),

                            // Product details sections
                            _buildInfoSection('Description', equipmentDetails?.description ?? 'No description available'),
                            _buildInfoSection('Brand', equipmentDetails?.brand ?? 'N/A'),
                            _buildInfoSection('Condition', equipmentDetails?.sellEquipmentCondition.name ?? 'N/A'),

                            if (equipmentDetails?.expiryDate != null)
                              Text(
                                'Post expiry date: ${DateFormat('dd/MM/yyyy').format(equipmentDetails?.expiryDate ?? DateTime.now())}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Montserrat',
                                  color: Color(0xFF808080),
                                ),
                              ),
                            SizedBox(height: 16),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a standardized information section with a title and content
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

  /// Creates a chip widget for displaying categories or tags
  // Widget _buildChip(String label) {
  //   return Chip(
  //     label: Text(
  //       label,
  //       style: TextStyle(
  //         fontSize: 15,
  //         fontWeight: FontWeight.w500,
  //         fontFamily: 'Montserrat',
  //         color: Color(0xFF2B2B2B),
  //       ),
  //     ),
  //     backgroundColor: Color(0xFFE1EDF2),
  //     padding: EdgeInsets.symmetric(horizontal: 8),
  //   );
  // }

  Future<void> getSellEquipmentDetails() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      await _progressDialog.show();
      final response = await Provider.of<SellViewmodel>(context, listen: false).getEquipmentById(widget.equipmentId);

      if (response.statusCode == 200) {
        await _progressDialog.hide();
        final Map<String, dynamic> data = json.decode(response.body);

        equipmentDetails = SellEquipmentResponseModel.fromJson(data);
        selectedActivities.addAll(equipmentDetails!.equipmentSubActivities.map((e) => e.name));
        isLoading = false;
        setState(() {});
      } else if (response.statusCode == 500 || response.statusCode == 404) {
        setState(() {
          errorMessage = AppStrings.internalServerErrorMessage;
          isLoading = false;
        });
      } else {
        Map<String, dynamic> errorModel = json.decode(response.body);
        setState(() {
          errorMessage = errorModel['ModelState']?['ErrorMessage']?[0] ?? 'An error occurred';
          isLoading = false;
        });
      }
    } on NoConnectivityException catch (_) {
      setState(() {
        errorMessage = AppStrings.noInternet;
        isLoading = false;
      });
    } on TimeoutException catch (_) {
      setState(() {
        errorMessage = AppStrings.timeout;
        isLoading = false;
      });
    } on ServerException catch (_) {
      setState(() {
        errorMessage = AppStrings.serverError;
        isLoading = false;
      });
    } catch (exception) {
      setState(() {
        errorMessage = exception.toString();
        isLoading = false;
      });
    } finally {
      await _progressDialog.hide();
    }
  }
}
