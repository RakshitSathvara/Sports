import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:oqdo_mobile_app/screens/bazaar/buy/model/buy_equipment_response_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/chats/chat_enums.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/models/edit_view_equipment_intent_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/product/edit_sell_product_detail_screen.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/viewmodel/sell_viewmodel.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/views/equipment_card.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  List<EquipmentData> equipments = [];
  int pageCount = 0;
  final int resultPerPage = 10;
  String searchQuery = '';
  bool isLoading = false;
  bool hasMoreData = true;
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;
  final TextEditingController _searchController = TextEditingController();
  late ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(message: "Please wait..");
      getSellEquipments(isInitial: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!isLoading && hasMoreData) {
        getSellEquipments();
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = query;
        pageCount = 0;
        equipments.clear();
        hasMoreData = true;
      });
      getSellEquipments(isInitial: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _searchbar(),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF006590),
        onPressed: () {
          var intentModel = EditViewEquipmentIntentModel(isEdit: false, equipmentId: 0, sellEquipmentResponseModel: null);
          Navigator.pushNamed(context, Constants.sellProductListScreen, arguments: intentModel);
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading && equipments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!isLoading && equipments.isEmpty) {
      return const Center(child: Text('No equipment found'));
    }

    return _equipmentGridView(equipments);
  }

  Widget _searchbar() {
    return Container(
      color: const Color(0xFF006590),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 16),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: "Search Equipment's",
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF006590),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _equipmentGridView(List<EquipmentData> equipments) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(2.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 0.1,
        mainAxisSpacing: 0.1,
      ),
      itemCount: equipments.length,
      itemBuilder: (context, index) {
        return EquipmentCard(
          equipment: equipments[index],
          onTap: () async {
            var result = await Navigator.pushNamed(
              context,
              EditSellProductDetailScreen.routeName,
              arguments: equipments[index].equipmentId.toString(),
            );
            if (result == true || result == null) {
              setState(() {
                pageCount = 0;
                equipments.clear();
                hasMoreData = true;
              });
              getSellEquipments(isInitial: true);
            }
          },
          onView: (p0) async {
            var result = await Navigator.pushNamed(
              context,
              EditSellProductDetailScreen.routeName,
              arguments: p0.equipmentId.toString(),
            );
            if (result == true || result == null) {
              setState(() {
                pageCount = 0;
                equipments.clear();
                hasMoreData = true;
              });
              getSellEquipments(isInitial: true);
            }
          },
          onEdit: (p0) {
            Navigator.pushNamed(
              context,
              Constants.sellProductListScreen,
              arguments: EditViewEquipmentIntentModel(equipmentId: p0.equipmentId, isEdit: true),
            );
          },
          onDelete: (p0) {
            showDeleteConfirmationDialog(context, p0.equipmentId);
          },
        );
      },
    );
  }

  Future<void> getSellEquipments({bool isInitial = false}) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      Map<String, dynamic> request = {
        "IsBuyer": false,
        "pageStart": pageCount,
        "resultPerPage": resultPerPage,
        "seachquery": searchQuery,
      };

      await Provider.of<SellViewmodel>(context, listen: false).getEquipments(request).then(
        (value) {
          Response res = value;
          debugPrint("Response: ${res.body}");

          if (res.statusCode == 500 || res.statusCode == 404) {
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            BuyEquipmentResponseModel buyEquipmentResponseModel = BuyEquipmentResponseModel.fromJson(jsonDecode(res.body));

            setState(() {
              if (buyEquipmentResponseModel.data.isEmpty) {
                hasMoreData = false;
              } else {
                for (var i = 0; i < buyEquipmentResponseModel.data.length; i++) {
                  var data = buyEquipmentResponseModel.data[i];
                  if (data.equipmentStatus!.code != EquipmentStatusCode.removed.toString() ||
                      data.equipmentStatus!.code != EquipmentStatusCode.inactive.toString()) {
                    equipments.add(data);
                  }
                }
                pageCount++;
              }
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
              pageCount = 0;
              equipments.clear();
              hasMoreData = true;
            });

            // Fetch fresh data
            getSellEquipments(isInitial: true);
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
}
