import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/components/favorite_toggle_button.dart';
import 'package:oqdo_mobile_app/model/GetFacilityByIdModel.dart';
import 'package:oqdo_mobile_app/model/common_passing_args.dart';
import 'package:oqdo_mobile_app/model/get_all_activity_and_sub_activity_response.dart';
import 'package:oqdo_mobile_app/model/selecte_home_model.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/screens/favorites/model/facility_favorite_response_model.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:oqdo_mobile_app/viewmodels/BookingViewModel.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import '../../theme/oqdo_theme_data.dart';

class FacilitiesFavoritesListPage extends StatefulWidget {
  SelectedHomeModel? selectedHomeModel;

  FacilitiesFavoritesListPage({Key? key, this.selectedHomeModel}) : super(key: key);

  @override
  FacilitiesFavoritesListPageState createState() => FacilitiesFavoritesListPageState();
}

class FacilitiesFavoritesListPageState extends State<FacilitiesFavoritesListPage> {
  List<FacilityData> facilitiesList = [];
  late ProgressDialog progressDialog;
  String? isLogin;
  String? userType;
  int? pageCount = 0;
  int? resultPerPage = 10;
  int? totalCount;
  bool isLoading = false;
  String request = '';
  ScrollController mScrollController = ScrollController();
  List<ActivityBean> activityListModel = [];
  List<String>? filterList = ['Facilities', 'Coaches'];
  String? selectedTypeValue;
  CommonPassingArgs commonPassingArgs = CommonPassingArgs();

  String selectedValue = '';
  List<SubActivitiesBean> selectedValuesFromKey = [];
  Map<String, List<SelectedFilterValues>> selectedValues = {};
  List<String> selectedSubValue = [];
  Map<int, bool> itemsSelectedValue = {};
  List<int> selectedSubActivityId = [];
  bool isIndividualBookingSelected = true;
  bool isGroupBookingSelected = false;
  Map<String, List<SelectedFilterValues>>? selectedFilterData = {};
  bool isCircularProgressLoading = true;
  final ScrollController _scrollController = ScrollController();
  bool isAPICalled = false;

  @override
  void initState() {
    super.initState();
    getPrefData();
    isCircularProgressLoading = true;
    selectedTypeValue = 'Facilities';
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      mScrollController.addListener(() {
        double threshold = 0.5 * mScrollController.position.maxScrollExtent;
        if (mScrollController.position.pixels > threshold && !isLoading) {
          if (totalCount != facilitiesList.length) {
            getAllFacilities();
          }
        }
        debugPrint('list size -> ${facilitiesList.length} -> totaoCount -> $totalCount');
      });
    });
  }

  void getPrefData() async {
    isLogin = OQDOApplication.instance.storage.getStringValue(AppStrings.isLogin);

    getAllFacilities();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
        } // Return true to trigger refresh
      },
      child: Scaffold(
        appBar: CustomAppBar(
            title: 'My Favorites',
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
                const SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DropdownButton<dynamic>(
                            isExpanded: false,
                            underline: const SizedBox(),
                            dropdownColor: Theme.of(context).colorScheme.onBackground,
                            hint: CustomTextView(
                              label: filterList![0],
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(color: OQDOThemeData.greyColor, fontSize: 20.0, fontWeight: FontWeight.w300),
                            ),
                            value: selectedTypeValue,
                            items: filterList!.map((interest) {
                              return DropdownMenuItem(
                                value: interest,
                                child: CustomTextView(
                                  label: interest.toString(),
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(color: OQDOThemeData.greyColor, fontSize: 20.0, fontWeight: FontWeight.w300),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              // setState(() {
                              selectedTypeValue = value as String;
                              SelectedHomeModel selectedHomeModel = SelectedHomeModel();
                              if (selectedTypeValue == 'Coaches') {
                                Navigator.pushNamed(context, Constants.coachFavoritesList, arguments: selectedHomeModel);
                              }
                              // if (selectedTypeValue == 'Facilities') {
                              //   Navigator.pushNamed(context, Constants.facilityFavoritesList, arguments: selectedHomeModel);
                              // } else {
                              //   Navigator.pushNamed(context, Constants.coachFavoritesList, arguments: selectedHomeModel);
                              // }
                              // });
                            },
                          ),
                          selectionTypeWithFilterView(),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                facilitiesList.isNotEmpty
                    ? Expanded(
                        child: Stack(children: [
                          ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: facilitiesList.length,
                              controller: mScrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, index) {
                                return singleFacilityView(facilitiesList[index]);
                              }),
                          isLoading
                              ? const Padding(
                                  padding: EdgeInsets.only(bottom: 10.0),
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : const SizedBox(
                                  height: 0,
                                  width: 0,
                                ),
                        ]),
                      )
                    : Expanded(
                        child: Center(
                          child: isCircularProgressLoading
                              ? const CircularProgressIndicator()
                              : CustomTextView(
                                  label: 'Facilities not found',
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(fontWeight: FontWeight.w600, color: OQDOThemeData.blackColor, fontSize: 16.0),
                                ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget singleFacilityView(FacilityData model) {
    return GestureDetector(
      onTap: () {
        callGetSetupById(model.facilitySetupId!);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 170,
              child: Stack(
                children: [
                  Card(
                    elevation: 4,
                    child: ClipPath(
                      clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                      child: Opacity(
                        opacity: 0.7,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Theme.of(context).colorScheme.onBackground),
                          child: CachedNetworkImage(
                            imageUrl: model.listingPageImage!,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: CustomTextView(
                    label: model.facilityName,
                    maxLine: 2,
                    textOverFlow: TextOverflow.ellipsis,
                    type: styleSubTitle,
                    textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18.0,
                          color: OQDOThemeData.greyColor,
                        ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                FavoriteToggleButton(
                  isFavorite: model.isFavorite,
                  size: 35,
                  onFavoriteChanged: () {
                    addRemoveFromFavorite(model);
                  },
                )
              ],
            ),
            CustomTextView(
              label: '${model.title!} - ${model.subTitle!}',
              maxLine: 2,
              textOverFlow: TextOverflow.ellipsis,
              type: styleSubTitle,
              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: OQDOThemeData.greyColor, fontWeight: FontWeight.w400, fontSize: 16),
            ),
            const SizedBox(
              height: 6,
            ),
            Row(
              children: [
                Image.asset(
                  model.bookingType == "I" ? 'assets/images/ic_individual_booking.png' : 'assets/images/ic_group_booking.png',
                  height: 20,
                  width: 20,
                  fit: BoxFit.fill,
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: CustomTextView(
                    label: 'From S\$ ${model.minimumHrRate?.toStringAsFixed(2) ?? 0.00} / hour',
                    type: styleSubTitle,
                    textOverFlow: TextOverflow.ellipsis,
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: OQDOThemeData.greyColor, fontWeight: FontWeight.w400, fontSize: 14.0),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFE1E1E1),
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(8))),
                  child: Row(
                    children: [
                      CustomTextView(
                        label: model.avrageRating.toStringAsFixed(1),
                        textOverFlow: TextOverflow.ellipsis,
                        textStyle:
                            Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 14.0, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      Image.asset(
                        'assets/images/ic_star.png',
                        height: 15,
                        width: 15,
                        fit: BoxFit.fill,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget selectionTypeWithFilterView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomTextView(
          label: '',
          textStyle: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(fontWeight: FontWeight.bold, fontSize: 20.0, color: OQDOThemeData.greyColor, fontStyle: FontStyle.normal),
        ),
      ],
    );
  }

  Future<void> getAllFacilities() async {
    try {
      setState(() {
        isLoading = true;
      });

      String requestStr = 'pageStart=${pageCount!}&resultPerPage=$resultPerPage&Flag=F';

      await Provider.of<BookingViewModel>(context, listen: false).getFavoriteFacilities(requestStr).then(
        (value) async {
          Response res = value;
          if (!mounted) return;
          if (res.statusCode == 500 || res.statusCode == 404) {
            setState(() {
              isCircularProgressLoading = false;
            });
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            FacilityFavoriteResponseModel facilityFavoriteResponseModel = FacilityFavoriteResponseModel.fromJson(jsonDecode(res.body));
            if (facilityFavoriteResponseModel.data.isNotEmpty) {
              setState(() {
                facilitiesList.addAll(facilityFavoriteResponseModel.data);
                totalCount = facilityFavoriteResponseModel.totalCount;
                pageCount = pageCount! + 1;
                isLoading = false;
                isCircularProgressLoading = false;
              });
              debugPrint('after API facilitiesList -> ${facilitiesList.length}');
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
      if (!mounted) return;
      setState(() {
        isCircularProgressLoading = false;
      });
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      if (!mounted) return;
      setState(() {
        isCircularProgressLoading = false;
      });
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      if (!mounted) return;
      setState(() {
        isCircularProgressLoading = false;
      });
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      if (!mounted) return;
      setState(() {
        isCircularProgressLoading = false;
      });
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  Future<void> callGetSetupById(int facilitySetupId) async {
    try {
      progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      progressDialog.style(message: "Please wait..");
      await progressDialog.show();
      await Provider.of<BookingViewModel>(context, listen: false).getFacilityById(facilitySetupId).then((value) async {
        Response res = value;
        if (!mounted) return;
        await progressDialog.hide();
        if (res.statusCode == 500 || res.statusCode == 404) {
          showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
        } else if (res.statusCode == 200) {
          GetFacilityByIdModel getFacilityByIdModel = GetFacilityByIdModel.fromJson(jsonDecode(res.body));
          debugPrint(getFacilityByIdModel.title);
          final result = await Navigator.of(context).pushNamed(Constants.facilityDetailsScreen, arguments: getFacilityByIdModel);
          if (result == true) {
            setState(() {
              isAPICalled = true;
              pageCount = 0;
              facilitiesList.clear();
              isCircularProgressLoading = true;
            });
            await getAllFacilities();
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
      });
    } on NoConnectivityException catch (_) {
      await progressDialog.hide();
      if (!mounted) return;
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      await progressDialog.hide();
      if (!mounted) return;
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      await progressDialog.hide();
      if (!mounted) return;
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      await progressDialog.hide();
      if (!mounted) return;
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  Future<void> addRemoveFromFavorite(FacilityData model) async {
    try {
      progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      progressDialog.style(message: "Please wait..");
      await progressDialog.show();

      Map<String, dynamic> request = {"SetupId": model.facilitySetupId.toString(), "Flag": 'F'};
      await Provider.of<BookingViewModel>(context, listen: false).addFavorite(request).then(
        (value) async {
          Response res = value;
          if (!mounted) return;
          if (res.statusCode == 500 || res.statusCode == 404) {
            await progressDialog.hide();
            setState(() {
              model.isFavorite = model.isFavorite;
            });
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            String response = res.body;
            if (response.isNotEmpty) {
              isAPICalled = true;
              facilitiesList.remove(model);
            } else {
              model.isFavorite = model.isFavorite;
            }
            await progressDialog.hide();
            setState(() {});
          } else {
            await progressDialog.hide();
            setState(() {
              model.isFavorite = model.isFavorite;
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
      await progressDialog.hide();
      setState(() {
        model.isFavorite = model.isFavorite;
      });
      if (!mounted) return;
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      await progressDialog.hide();
      setState(() {
        model.isFavorite = model.isFavorite;
      });
      if (!mounted) return;
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      await progressDialog.hide();
      setState(() {
        model.isFavorite = model.isFavorite;
      });
      if (!mounted) return;
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      await progressDialog.hide();
      setState(() {
        model.isFavorite = model.isFavorite;
      });
      if (!mounted) return;
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }
}
