import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/screens/bazaar/chats/chat_enums.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/models/edit_view_equipment_intent_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/models/sell_equipment_response_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/viewmodel/sell_viewmodel.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class EditSellProductDetailScreen extends StatefulWidget {
  static const routeName = '/edit-sell-equipment-detail';
  final String equipmentId;

  const EditSellProductDetailScreen({super.key, required this.equipmentId});

  @override
  State<EditSellProductDetailScreen> createState() => _SellProductDetailScreenState();
}

class _SellProductDetailScreenState extends State<EditSellProductDetailScreen> {
  final Set<String> selectedActivities = {};
  late ProgressDialog _progressDialog;
  List<String>? certificateUploadId = [];
  SellEquipmentResponseModel? equipmentDetails;
  bool isLoading = true;
  String? errorMessage;
  bool isAPICalled = false;

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
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        if (isAPICalled) {
          Navigator.of(context).pop(true);
        } else {
          Navigator.of(context).pop(false);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF006989),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (isAPICalled) {
                Navigator.of(context).pop(true);
              } else {
                Navigator.of(context).pop(false);
              }
            },
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
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage!,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Montserrat',
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });
                getSellEquipmentDetails();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006989),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (equipmentDetails == null) {
      return const Center(
        child: Text(
          'No data found',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Montserrat',
            color: Colors.grey,
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Review your Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'SFPro',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Image carousel
                  if (equipmentDetails!.equipmentImages.isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: PageView.builder(
                        itemCount: equipmentDetails!.equipmentImages.length,
                        controller: PageController(viewportFraction: 0.93),
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                equipmentDetails!.equipmentImages[index].filePath,
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
                  const SizedBox(height: 16),

                  // Product title
                  Text(
                    equipmentDetails!.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Product price
                  Row(
                    children: [
                      Text(
                        'S\$ ${equipmentDetails!.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006590),
                        ),
                      ),
                      Spacer(),
                      Text(
                        equipmentDetails!.equipmentStatus.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: _getStatusColor(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Category information
                  _buildInfoSection('Category', equipmentDetails!.sellEquipmentCategory.name),

                  // Used For section with activities
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Used For',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2B2B2B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: equipmentDetails!.equipmentSubActivities.map((activity) {
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
                      )
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Product details sections
                  _buildInfoSection('Description', equipmentDetails!.description),
                  const SizedBox(height: 8),
                  _buildInfoSection('Brand', equipmentDetails!.brand),
                  const SizedBox(height: 8),
                  _buildInfoSection('Condition', equipmentDetails!.sellEquipmentCondition.name),

                  if (equipmentDetails!.expiryDate != null)
                    Text(
                      'Post expiry date: ${DateFormat('dd/MM/yyyy').format(equipmentDetails!.expiryDate!)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Montserrat',
                        color: Color(0xFF808080),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),

        // Bottom button
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if ((equipmentDetails!.equipmentStatus.code == EquipmentStatusCode.sold.toString()) ||
                          (equipmentDetails!.equipmentStatus.code == EquipmentStatusCode.expired.toString())) {
                        republishEquipment();
                      } else {
                        final intent = EditViewEquipmentIntentModel(equipmentId: int.parse(widget.equipmentId), isEdit: true);
                        Navigator.pushNamed(context, Constants.sellProductListScreen, arguments: intent);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006989),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      ((equipmentDetails!.equipmentStatus.code == EquipmentStatusCode.sold.toString()) ||
                              (equipmentDetails!.equipmentStatus.code == EquipmentStatusCode.expired.toString()))
                          ? 'Republish'
                          : 'Edit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      showDeleteConfirmationDialog(context, int.parse(widget.equipmentId));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Remove',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Color(0xFF2B2B2B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            color: Color(0xFF2B2B2B),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> getSellEquipmentDetails() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      await _progressDialog.show();
      final response = await Provider.of<SellViewmodel>(context, listen: false).getEquipmentById(widget.equipmentId);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          equipmentDetails = SellEquipmentResponseModel.fromJson(data);
          selectedActivities.addAll(equipmentDetails!.equipmentSubActivities.map((e) => e.name));
          isLoading = false;
        });
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

  Color _getStatusColor() {
    switch (equipmentDetails!.equipmentStatus.name.toLowerCase()) {
      case 'active':
        return const Color(0xFF1AB805);
      case 'pending':
        return const Color(0xFFEDBE00);
      case 'expired':
        return const Color(0xFFA80000);
      case 'sold':
        return const Color(0xFF3C3C3C);
      default:
        return Colors.black;
    }
  }

  Future<void> showDeleteConfirmationDialog(BuildContext context, int equipmentId) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Are you sure?',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Montserrat',
                        color: Color(0xFF2B2B2B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'You want to remove the product. The action can not be reversed ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2B2B2B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(
                height: 2,
                color: Colors.black,
              ),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Color(0xFF006590),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          deleteEquipment(equipmentId);
                        },
                        child: const Text('Yes'),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black87,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('No'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> deleteEquipment(int equipmentId) async {
    try {
      _progressDialog.show();
      await Provider.of<SellViewmodel>(context, listen: false)
          .deleteEquipment({"EquipmentId": equipmentId, "InActiveReason": "Removed by owner", "IsRemoveMobile": true}).then(
        (value) {
          Response res = value;
          debugPrint("Response: ${res.body}");

          if (res.statusCode == 500 || res.statusCode == 404) {
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            _progressDialog.hide();
            showSnackBarColor("Equipment deleted successfully", context, false);
            setState(() {
              isAPICalled = true;
            });
            Navigator.of(context).pop(true);
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
      _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      _progressDialog.hide();
      debugPrint(exception.toString());
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  Future<void> republishEquipment() async {
    try {
      await _progressDialog.show();
      await Provider.of<SellViewmodel>(context, listen: false)
          .updateEquipmentStatus({"EquipmentId": int.parse(widget.equipmentId), "IsMoveToCurrent": true}).then(
        (value) async {
          Response res = value;
          debugPrint("Response: ${res.body}");

          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            await _progressDialog.hide();
            setState(() {
              isAPICalled = true;
            });
            showAlertDialog("Your post has been republished. It is currently in the Pending state, and you may edit it if needed.", context);
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
      debugPrint(exception.toString());
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  void showAlertDialog(String message, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Post Republished'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop(true);
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}
