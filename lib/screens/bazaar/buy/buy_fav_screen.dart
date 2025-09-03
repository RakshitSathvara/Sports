import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/screens/bazaar/buy/buy_product_details_screen.dart';
import 'package:oqdo_mobile_app/screens/bazaar/buy/model/buy_fav_response_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/buy/views/buy_favorite_equipment_card.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/viewmodel/sell_viewmodel.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class BuyFavScreen extends StatefulWidget {
  static const String routeName = '/buyFavScreen';

  const BuyFavScreen({super.key});

  @override
  _BuyFavScreenState createState() => _BuyFavScreenState();
}

class _BuyFavScreenState extends State<BuyFavScreen> {
  int? pageCount = 0;
  int? resultPerPage = 10;
  int? totalCount;
  bool isLoading = false;
  String request = '';
  late ProgressDialog _progressDialog;
  List<BuyFavoriteEquipment> equipments = [];
  bool isCircularProgressLoading = true;
  final ScrollController _scrollController2 = ScrollController();
  bool isAPICalled = false;

  @override
  void initState() {
    super.initState();
    getSharedPref();
    isCircularProgressLoading = true;
  }

  void getSharedPref() async {
    getAllEquipmentFavorites();
  }

  @override
  void dispose() {
    _scrollController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent default back behavior
      onPopInvoked: (bool didPop) {
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
        appBar: CustomAppBar(
            backgroundColor: Color(0xFF006590),
            title: 'My Favorites',
            isIconColorBlack: false,
            onBack: () {
              if (isAPICalled) {
                Navigator.of(context).pop(true);
              } else {
                Navigator.of(context).pop(false);
              }
            }),
        body: SafeArea(
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Theme.of(context).colorScheme.onBackground,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  equipments.isNotEmpty
                      ? Expanded(
                          child: Stack(
                            children: [
                              NotificationListener<ScrollNotification>(
                                  onNotification: (ScrollNotification scrollNotification) {
                                    if (scrollNotification is ScrollEndNotification && scrollNotification.metrics.extentAfter < 100 && !isLoading) {
                                      if (totalCount != equipments.length) {
                                        getAllEquipmentFavorites();
                                      }
                                    }
                                    return true;
                                  },
                                  child: _buildEquipmentGrid(equipments)),
                              if (isLoading)
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 10.0),
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : Expanded(
                          child: Center(
                            child: isCircularProgressLoading
                                ? const CircularProgressIndicator()
                                : CustomTextView(
                                    label: 'Favorites not found',
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(fontWeight: FontWeight.w600, color: OQDOThemeData.blackColor, fontSize: 16.0),
                                  ),
                          ),
                        ),
                ],
              )),
        ),
      ),
    );
  }

  Widget _buildEquipmentGrid(List<BuyFavoriteEquipment> equipments) {
    return GridView.builder(
      padding: const EdgeInsets.all(2.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.79,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: equipments.length,
      itemBuilder: (context, index) {
        return BuyFavoriteEquipmentCard(
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
    );
  }

  Future<void> getAllEquipmentFavorites() async {
    try {
      setState(() {
        isLoading = true;
      });

      String requestStr = 'pageStart=${pageCount!}&resultPerPage=$resultPerPage';
      await Provider.of<SellViewmodel>(context, listen: false).getEquipmentFavorite(requestStr).then(
        (value) {
          Response res = value;
          if (!mounted) return;
          if (res.statusCode == 500 || res.statusCode == 404) {
            setState(() {
              isCircularProgressLoading = false;
            });
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            BuyFavoriteEquipmentResponseModel buyEquipmentResponseModel = BuyFavoriteEquipmentResponseModel.fromJson(jsonDecode(res.body));
            if (buyEquipmentResponseModel.data.isNotEmpty) {
              equipments.addAll(buyEquipmentResponseModel.data);
              totalCount = buyEquipmentResponseModel.totalCount;
              pageCount = pageCount! + 1;
              isLoading = false;
              isCircularProgressLoading = false;
              setState(() {});
            } else {
              setState(() {
                isLoading = false;
                isCircularProgressLoading = false;
              });
            }
          } else {
            setState(() {
              isCircularProgressLoading = false;
            });
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
      setState(() {
        isCircularProgressLoading = false;
      });
      if (!mounted) return;
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      setState(() {
        isCircularProgressLoading = false;
      });
      if (!mounted) return;
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      setState(() {
        isCircularProgressLoading = false;
      });
      if (!mounted) return;
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      setState(() {
        isCircularProgressLoading = false;
      });
      if (!mounted) return;
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  Future<void> addRemoveFromFavorite(BuyFavoriteEquipment equipment) async {
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
            isAPICalled = true;
            equipments.remove(equipment);
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
      if (!mounted) return;
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      await _progressDialog.hide();
      setState(() {
        equipment.isFavourite = equipment.isFavourite;
      });
      if (!mounted) return;
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      await _progressDialog.hide();
      setState(() {
        equipment.isFavourite = equipment.isFavourite;
      });
      if (!mounted) return;
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      await _progressDialog.hide();
      setState(() {
        equipment.isFavourite = equipment.isFavourite;
      });
      if (!mounted) return;
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }
}
