import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:oqdo_mobile_app/screens/bazaar/ads_screen/model/subactivyt_and_activity_response_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/buy/buy_fav_screen.dart';
import 'package:oqdo_mobile_app/screens/bazaar/buy/buy_product_details_screen.dart';
import 'package:oqdo_mobile_app/screens/bazaar/buy/category_screen.dart';
import 'package:oqdo_mobile_app/screens/bazaar/buy/model/buy_equipment_response_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/buy/views/buy_equipment_card.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/viewmodel/sell_viewmodel.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/models/equipment_category_response_model.dart' as sell_models;

class BuyScreen extends StatefulWidget {
  const BuyScreen({super.key});

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
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

  Map<String, dynamic>? filterData;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
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
        children: [_buildSearchBar(), Expanded(child: _buildEquipmentGrid(equipments))],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Color(0xFF006590),
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: "Search Equipment's",
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF006590),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 15.0), // Space between text field and icon
          GestureDetector(
              onTap: () async {
                final result = await Navigator.pushNamed(context, BuyCategoryScreen.routeName, arguments: filterData);

                if (result != null && result is Map<String, dynamic>) {
                  // Store the filter data
                  filterData = result;

                  // Reset pagination and clear current data
                  setState(() {
                    pageCount = 0;
                    equipments.clear();
                    hasMoreData = true;
                  });

                  // Fetch new data with filters
                  await getSellEquipments(isInitial: true);
                }
              },
              child: Image.asset('assets/images/ic_bazaar_filter.png', width: 30.0, height: 30.0)),
          const SizedBox(width: 15.0), // Space between filter icon and fav icon
          GestureDetector(
            onTap: () async {
              var result = await Navigator.pushNamed(context, BuyFavScreen.routeName);
              if (result == true) {
                setState(() {
                  pageCount = 0;
                  equipments.clear();
                  hasMoreData = true;
                });
                await getSellEquipments(isInitial: true);
              }
            },
            child: Image.asset(
              'assets/images/ic_bazaar_fav.png',
              width: 30,
              height: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentGrid(List<EquipmentData> equipments) {
    if (isLoading && equipments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!isLoading && equipments.isEmpty) {
      return const Center(child: Text('No equipment found'));
    }
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(2.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.79,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
            ),
            // Add +1 to itemCount if loading more items to show loading indicator
            itemCount: equipments.length + (isLoading && hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == equipments.length && isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // Existing code for normal items
              return BuyEquipmentCard(
                equipment: equipments[index],
                onTap: () {
                  Navigator.pushNamed(context, BuyProductDetailsScreen.routeName, arguments: equipments[index].equipmentId.toString());
                },
                onFavouriteTap: () {
                  addRemoveFromFavorite(equipments[index]);
                },
                isFavorite: equipments[index].isFavourite,
              );
            },
          ),
        ),
        if (isLoading && hasMoreData && equipments.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Future<void> getSellEquipments({bool isInitial = false}) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    if (!mounted) return;

    try {
      // Create the base request
      Map<String, dynamic> request = {
        "IsBuyer": true,
        "pageStart": pageCount,
        "resultPerPage": resultPerPage,
        "seachquery": searchQuery,
      };

      // Add filter parameters if available
      if (filterData != null) {
        // Add subActivities if present
        if (filterData!.containsKey('subActivities')) {
          Map<String, List<SubActivity>> subActivitiesMap = filterData!['subActivities'];
          List<Map<String, dynamic>> subActivityFilters = [];

          subActivitiesMap.forEach((activityName, subActivities) {
            for (var subActivity in subActivities) {
              subActivityFilters.add({
                "subActivityId": subActivity.subActivityId,
              });
            }
          });

          if (subActivityFilters.isNotEmpty) {
            request["subActivities"] = subActivityFilters;
          }
        }

        // Add product categories if present
        if (filterData!.containsKey('productCategories')) {
          Map<String, List<sell_models.EquipmentCategory>> productCategoriesMap = filterData!['productCategories'];
          List<Map<String, dynamic>> productCategoryFilters = [];

          productCategoriesMap.forEach((activityName, productCategories) {
            for (var productCategory in productCategories) {
              productCategoryFilters.add({
                "EquipmentCategoryId": productCategory.equipmentCategoryId,
              });
            }
          });

          if (productCategoryFilters.isNotEmpty) {
            request["EquipmentCategories"] = productCategoryFilters;
          }

          // List<int> productCategories = filterData!['productCategories'];
          // if (productCategories.isNotEmpty) {
          //   request["productCategories"] = productCategories;
          // }
        }
      }

      debugPrint("Request: ${jsonEncode(request)}");

      await Provider.of<SellViewmodel>(context, listen: false).getEquipments(request).then(
        (value) {
          Response res = value;
          debugPrint("Response: ${res.body}");

          if (res.statusCode == 500 || res.statusCode == 404) {
            if (!mounted) return;
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            if (!mounted) return;
            BuyEquipmentResponseModel buyEquipmentResponseModel = BuyEquipmentResponseModel.fromJson(jsonDecode(res.body));

            setState(() {
              if (buyEquipmentResponseModel.data.isEmpty || equipments.length + buyEquipmentResponseModel.data.length >= buyEquipmentResponseModel.totalCount) {
                hasMoreData = false;
              } else {
                hasMoreData = true;
              }

              equipments.addAll(buyEquipmentResponseModel.data);
              pageCount++;
              isLoading = false;
            });
            // BuyEquipmentResponseModel buyEquipmentResponseModel = BuyEquipmentResponseModel.fromJson(jsonDecode(res.body));

            // setState(() {
            //   if (buyEquipmentResponseModel.data.isEmpty) {
            //     hasMoreData = false;
            //   } else {
            //     equipments.addAll(buyEquipmentResponseModel.data);
            //     pageCount++;
            //   }
            //   isLoading = false;
            // });
          } else {
            if (!mounted) return;
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
      if (!mounted) return;
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      if (!mounted) return;
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      if (!mounted) return;
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      if (!mounted) return;
      showSnackBarErrorColor(exception.toString(), context, true);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addRemoveFromFavorite(EquipmentData equipment) async {
    try {
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(message: "Please wait..");
      await _progressDialog.show();

      await Provider.of<SellViewmodel>(context, listen: false).addRemoveFromFavorite(equipment.equipmentId.toString()).then((value) async {
        Response res = value;
        if (!mounted) return;

        if (res.statusCode == 500 || res.statusCode == 404) {
          await _progressDialog.hide();
          setState(() {
            equipment.isFavourite = equipment.isFavourite;
          });
          showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
        } else if (res.statusCode == 200) {
          String response = res.body;
          if (response.isNotEmpty) {
            if (equipment.isFavourite) {
              equipment.isFavourite = false;
            } else {
              showSnackBar('Added to Favorite', context);
              equipment.isFavourite = true;
            }
          } else {
            equipment.isFavourite = equipment.isFavourite;
          }
          await _progressDialog.hide();
          setState(() {});
        } else {
          await _progressDialog.hide();
          setState(() {
            equipment.isFavourite = equipment.isFavourite;
          });
          Map<String, dynamic> errorModel = jsonDecode(res.body);
          if (errorModel.containsKey('ModelState')) {
            Map<String, dynamic> modelState = errorModel['ModelState'];
            if (modelState.containsKey('ErrorMessage')) {
              showSnackBarColor(modelState['ErrorMessage'][0], context, true);
            }
          }
        }
      });
    } on NoConnectivityException catch (_) {
      await _progressDialog.hide();
      setState(() {
        equipment.isFavourite = equipment.isFavourite;
      });
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      await _progressDialog.hide();
      setState(() {
        equipment.isFavourite = equipment.isFavourite;
      });
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      await _progressDialog.hide();
      setState(() {
        equipment.isFavourite = equipment.isFavourite;
      });
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      await _progressDialog.hide();
      setState(() {
        equipment.isFavourite = equipment.isFavourite;
      });
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }
}
