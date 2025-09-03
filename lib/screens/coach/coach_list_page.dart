import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/components/favorite_toggle_button.dart';
import 'package:oqdo_mobile_app/model/CoachDetailsResponseModel.dart';
import 'package:oqdo_mobile_app/model/common_passing_args.dart';
import 'package:oqdo_mobile_app/model/get_all_activity_and_sub_activity_response.dart';
import 'package:oqdo_mobile_app/model/selecte_home_model.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:oqdo_mobile_app/viewmodels/BookingViewModel.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import '../../model/CoachListResponseModel.dart';

class CoachListPage extends StatefulWidget {
  SelectedHomeModel? selectedHomeModel;

  CoachListPage({Key? key, this.selectedHomeModel}) : super(key: key);

  @override
  _CoachListPageState createState() => _CoachListPageState();
}

class _CoachListPageState extends State<CoachListPage> {
  String? isLogin;
  String? userType;
  int? pageCount = 0;
  int? resultPerPage = 10;
  int? totalCount;
  bool isLoading = false;
  String request = '';
  late ProgressDialog _progressDialog;
  List<Data> coachesList = [];
  List<ActivityBean> activityListModel = [];

  String requestData = "";
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
  final ScrollController _scrollController2 = ScrollController();
  Timer? _searchDebounce;
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;
  bool isSearchLoading = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    getSharedPref();
    getAllActivity();
    isCircularProgressLoading = true;
    selectedTypeValue = 'Coaches';
  }

  void getSharedPref() async {
    isLogin = OQDOApplication.instance.storage.getStringValue(AppStrings.isLogin);
    getCoaches('pageStart=${pageCount!}&resultPerPage=$resultPerPage');
  }

  @override
  void dispose() {
    _scrollController2.dispose();
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Book',
        onBack: () {
          Navigator.of(context).pop();
        },
        actions: [
          isLogin == '1' && (OQDOApplication.instance.userType == Constants.facilityType || OQDOApplication.instance.userType == Constants.coachType)
              ? const SizedBox()
              : Padding(
                  padding: const EdgeInsetsDirectional.only(end: 20),
                  child: GestureDetector(
                      onTap: () async {
                        if (isLogin == '1') {
                          SelectedHomeModel selectedHomeModel = SelectedHomeModel();
                          var result = await Navigator.pushNamed(context, Constants.coachFavoritesList, arguments: selectedHomeModel);
                          if (result == true) {
                            setState(() {
                              pageCount = 0;
                              coachesList.clear();
                              isCircularProgressLoading = true;
                            });
                            await getCoaches(requestData);
                          }
                        } else {
                          showSnackBarColor('Please login', context, true);
                          Timer(const Duration(microseconds: 500), () {
                            Navigator.of(context).pushNamed(Constants.LOGIN);
                          });
                        }
                      },
                      child: Image.asset(
                        "assets/images/ic_fav.png",
                        height: 30,
                        width: 30,
                      )),
                ),
        ],
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Theme.of(context).colorScheme.onBackground,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Dropdown and filter section (only show when not searching from home)
              if (widget.selectedHomeModel!.selectedActivity == null)
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
                            onChanged: (value) async {
                              if (value == null) return;
                              setState(() {
                                selectedTypeValue = value as String;
                              });

                              if (selectedTypeValue == 'Facilities') {
                                SelectedHomeModel selectedHomeModel = SelectedHomeModel();
                                await Navigator.pushNamed(context, Constants.FACILITIESLISTPAGE, arguments: selectedHomeModel);

                                // When coming back to this page, reset the dropdown to its default value
                                if (mounted) {
                                  setState(() {
                                    selectedTypeValue = 'Coaches';
                                  });
                                }
                              }
                            },
                          ),
                          selectionTypeWithFilterView(),
                        ],
                      )
                    ],
                  ),
                ),

              const SizedBox(height: 10),

              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Color(0xFFB5B5B5)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(color: Color(0xFF2B2B2B), fontSize: 18.0, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
                      icon: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Image.asset(
                          'assets/images/ic_search.png',
                          height: 25,
                          width: 25,
                          fit: BoxFit.fill,
                        ),
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      // Cancel the previous timer
                      _searchDebounce?.cancel();

                      // Update UI to show/hide clear button
                      setState(() {
                        isSearching = value.isNotEmpty;
                      });

                      // Start a new timer
                      _searchDebounce = Timer(const Duration(milliseconds: 500), () {
                        setState(() {
                          searchQuery = value.isNotEmpty ? '&SeachQuery=$value' : '';
                          pageCount = 0;
                          isSearchLoading = true; // Show search loader
                          // Clear coaches list when starting a new search
                          coachesList.clear();
                        });
                        getCoaches(requestData);
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Main content area - Show centered loading when searching, list when available, or not found message
              Expanded(
                child: isCircularProgressLoading
                    ? const Center(child: CircularProgressIndicator())
                    : isSearchLoading && coachesList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: OQDOThemeData.lightColorScheme.primary),
                              ],
                            ),
                          )
                        : coachesList.isNotEmpty
                            ? Stack(
                                children: [
                                  NotificationListener<ScrollNotification>(
                                    onNotification: (ScrollNotification scrollNotification) {
                                      if (scrollNotification is ScrollEndNotification &&
                                          scrollNotification.metrics.extentAfter < 100 &&
                                          !isLoading &&
                                          !isSearchLoading) {
                                        if (totalCount != coachesList.length) {
                                          getCoaches(requestData);
                                        }
                                      }
                                      return true;
                                    },
                                    child: ListView.builder(
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      itemCount: coachesList.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return singleCoachView(coachesList[index]);
                                      },
                                    ),
                                  ),
                                  // Show bottom loading indicator for pagination (not search)
                                  if (isLoading && !isSearchLoading)
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 10.0),
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                ],
                              )
                            : Center(
                                child: CustomTextView(
                                  label: 'Coaches not found',
                                  textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: OQDOThemeData.blackColor,
                                        fontSize: 16.0,
                                      ),
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget singleCoachView(Data coachesModel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: InkWell(
        onTap: () {
          getCoachDetailsById(coachesModel.coachBatchSetupId!);
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 180,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          color: Theme.of(context).colorScheme.onBackground,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                child: ClipPath(
                  clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Theme.of(context).colorScheme.onBackground),
                    child: Image.network(
                      coachesModel.profileImagePath!,
                      fit: BoxFit.fill,
                      width: 140,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: CustomTextView(
                              label: '${coachesModel.firstName!} ${coachesModel.lastName!}',
                              type: styleSubTitle,
                              maxLine: 1,
                              textOverFlow: TextOverflow.ellipsis,
                              textStyle:
                                  Theme.of(context).textTheme.titleSmall!.copyWith(color: OQDOThemeData.greyColor, fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          isLogin == '1' && (OQDOApplication.instance.userType == Constants.endUserType)
                              ? FavoriteToggleButton(
                                  onFavoriteChanged: () {
                                    addRemoveFromFavorite(coachesModel);
                                  },
                                  isFavorite: coachesModel.isFavourite ?? false,
                                  size: 35,
                                )
                              : isLogin == '1' &&
                                      (OQDOApplication.instance.userType == Constants.facilityType || OQDOApplication.instance.userType == Constants.coachType)
                                  ? const SizedBox()
                                  : FavoriteToggleButton(
                                      isFavorite: false,
                                      size: 35,
                                      onFavoriteChanged: () {
                                        showSnackBarColor('Please login', context, true);
                                        Timer(const Duration(microseconds: 500), () {
                                          Navigator.of(context).pushNamed(Constants.LOGIN);
                                        });
                                      },
                                    )
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextView(
                              label: '${coachesModel.activityName} - ${coachesModel.subActivityName}',
                              maxLine: 2,
                              textOverFlow: TextOverflow.ellipsis,
                              textStyle:
                                  Theme.of(context).textTheme.bodyMedium!.copyWith(color: OQDOThemeData.greyColor, fontWeight: FontWeight.w400, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          CustomTextView(
                            label: 'From S\$ ${coachesModel.minimumHrRate?.toStringAsFixed(2) ?? 0.00} / hour',
                            type: styleSubTitle,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w300, fontSize: 13),
                          ),
                          Image.asset(
                            coachesModel.bookingType == "I" ? 'assets/images/ic_individual_booking.png' : 'assets/images/ic_group_booking.png',
                            height: 20,
                            width: 20,
                            fit: BoxFit.fill,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          CustomTextView(
                            label: 'Availability: ',
                            textStyle:
                                Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 13, fontWeight: FontWeight.w400, color: const Color(0xFF8A8A8A)),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          CustomTextView(
                            label: '${coachesModel.startTime} : ${coachesModel.endTime}',
                            textStyle:
                                Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 16, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextView(
                              // label: coachesModel.address,
                              label: 'Singapore',
                              maxLine: 3,
                              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: OQDOThemeData.greyColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 10,
                                  ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
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
                                  label: coachesModel.AvgProviderRating!.toStringAsFixed(1),
                                  textOverFlow: TextOverflow.ellipsis,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(fontSize: 14.0, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
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
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getCoaches(String request) async {
    try {
      setState(() {
        isLoading = true;
      });

      String requestStr = "";

      // Check if we have filtered subactivities (from filter view) or from selectedHomeModel
      bool hasFilteredSubactivities = requestData.contains('&subactivities=');
      bool hasSelectedHomeModel = widget.selectedHomeModel!.selectedActivity != null && widget.selectedHomeModel!.subActivities != null;

      String finalRequestData = requestData;

      // If we have selectedHomeModel but no filtered subactivities, include selectedHomeModel subactivity
      if (hasSelectedHomeModel && !hasFilteredSubactivities) {
        String selectedHomeSubactivity = widget.selectedHomeModel!.subActivities!.subActivityId.toString();
        if (finalRequestData.isEmpty) {
          finalRequestData = '&subactivities=$selectedHomeSubactivity';
        } else if (!finalRequestData.contains('subactivities=$selectedHomeSubactivity')) {
          finalRequestData = '$finalRequestData&subactivities=$selectedHomeSubactivity';
        }
      }
      // If we have both filtered subactivities and selectedHomeModel, check for duplicates and merge if needed
      else if (hasFilteredSubactivities && hasSelectedHomeModel) {
        String selectedHomeSubactivity = widget.selectedHomeModel!.subActivities!.subActivityId.toString();
        if (!finalRequestData.contains('subactivities=$selectedHomeSubactivity')) {
          finalRequestData = '$finalRequestData&subactivities=$selectedHomeSubactivity';
        }
      }

      // Add search query if available
      if (searchQuery.isNotEmpty) {
        finalRequestData = '$finalRequestData$searchQuery';
      }

      if (isLogin == '1') {
        if (OQDOApplication().userType == Constants.endUserType || !hasSelectedHomeModel) {
          requestStr = 'pageStart=${pageCount!}&resultPerPage=$resultPerPage$finalRequestData';
        } else {
          requestStr = 'pageStart=${pageCount!}&resultPerPage=$resultPerPage$finalRequestData';
        }
      } else {
        requestStr = 'pageStart=${pageCount!}&resultPerPage=$resultPerPage$finalRequestData';
      }

      await Provider.of<BookingViewModel>(context, listen: false).getCoaches(requestStr).then((value) async {
        Response res = value;
        if (!mounted) return;

        setState(() {
          isCircularProgressLoading = false;
          isSearchLoading = false; // Hide search loader
        });

        if (res.statusCode == 500 || res.statusCode == 404) {
          showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
        } else if (res.statusCode == 200) {
          if (!mounted) return;
          CoachListResponseModel coachListResponseModel = CoachListResponseModel.fromJson(jsonDecode(res.body));
          if (coachListResponseModel.data!.isNotEmpty) {
            // If pageCount is 0, it's a new search/filter so replace data
            // If pageCount > 0, it's pagination so append data
            if (pageCount == 0) {
              coachesList = coachListResponseModel.data!;
            } else {
              coachesList.addAll(coachListResponseModel.data!);
            }
            totalCount = coachListResponseModel.totalCount;
            pageCount = pageCount! + 1;
            isLoading = false;
            isCircularProgressLoading = false;
            setState(() {});
          } else {
            setState(() {
              isCircularProgressLoading = false;
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
      });
    } on NoConnectivityException catch (_) {
      setState(() {
        isCircularProgressLoading = false;
        isSearchLoading = false; // Hide search loader on error
      });
      if (!mounted) return;
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      setState(() {
        isCircularProgressLoading = false;
        isSearchLoading = false; // Hide search loader on error
      });
      if (!mounted) return;
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      setState(() {
        isCircularProgressLoading = false;
        isSearchLoading = false; // Hide search loader on error
      });
      if (!mounted) return;
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      setState(() {
        isCircularProgressLoading = false;
        isSearchLoading = false; // Hide search loader on error
      });
      if (!mounted) return;
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  Future<void> addRemoveFromFavorite(Data coachesModel) async {
    try {
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(message: "Please wait..");
      await _progressDialog.show();

      Map<String, dynamic> request = {"SetupId": coachesModel.coachBatchSetupId.toString(), "Flag": 'C'};
      await Provider.of<BookingViewModel>(context, listen: false).addFavorite(request).then((value) async {
        Response res = value;
        if (!mounted) return;

        if (res.statusCode == 500 || res.statusCode == 404) {
          await _progressDialog.hide();
          setState(() {
            coachesModel.isFavourite = coachesModel.isFavourite;
          });
          showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
        } else if (res.statusCode == 200) {
          String response = res.body;
          if (response.isNotEmpty) {
            if (coachesModel.isFavourite!) {
              coachesModel.isFavourite = false;
            } else {
              showSnackBar('Added to Favorite', context);
              coachesModel.isFavourite = true;
            }
          } else {
            coachesModel.isFavourite = coachesModel.isFavourite;
          }
          await _progressDialog.hide();
          setState(() {});
        } else {
          await _progressDialog.hide();
          setState(() {
            coachesModel.isFavourite = coachesModel.isFavourite;
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
        coachesModel.isFavourite = coachesModel.isFavourite;
      });
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      await _progressDialog.hide();
      setState(() {
        coachesModel.isFavourite = coachesModel.isFavourite;
      });
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      await _progressDialog.hide();
      setState(() {
        coachesModel.isFavourite = coachesModel.isFavourite;
      });
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      await _progressDialog.hide();
      setState(() {
        coachesModel.isFavourite = coachesModel.isFavourite;
      });
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  Future<void> getCoachDetailsById(int coachBatchId) async {
    try {
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(message: "Please wait..");
      await _progressDialog.show();
      await Provider.of<BookingViewModel>(context, listen: false).getCoachDetailsById(coachBatchId).then((value) async {
        Response res = value;
        await _progressDialog.hide();

        if (res.statusCode == 500 || res.statusCode == 404) {
          showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
        } else if (res.statusCode == 200) {
          CoachDetailsResponseModel coachDetailsResponseModel = CoachDetailsResponseModel.fromJson(jsonDecode(res.body));
          if (coachDetailsResponseModel.coachName!.isNotEmpty) {
            final result = await Navigator.pushNamed(context, Constants.coachDetailScreen, arguments: coachDetailsResponseModel);

            if (result == true) {
              setState(() {
                pageCount = 0;
                coachesList.clear();
                isCircularProgressLoading = true;
              });
              await getCoaches(requestData);
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
      });
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

  Future<void> getAllActivity() async {
    try {
      await Provider.of<BookingViewModel>(context, listen: false).getAllActivity().then((value) async {
        Response res = value;
        if (!mounted) return;

        if (res.statusCode == 500 || res.statusCode == 404) {
          showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
        } else if (res.statusCode == 200) {
          GetAllActivityAndSubActivityResponse? getAllActivityAndSubActivityResponse = GetAllActivityAndSubActivityResponse.fromMap(jsonDecode(res.body));
          if (getAllActivityAndSubActivityResponse!.Data!.isNotEmpty) {
            setState(() {
              activityListModel = getAllActivityAndSubActivityResponse.Data!;
              debugPrint(activityListModel.length.toString());
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
      });
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
    }
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
        InkWell(
          onTap: () async {
            debugPrint('filter -> ${activityListModel.length}');
            Map<String, List<SubActivitiesBean>> interestValue = {};
            for (int i = 0; i < activityListModel.length; i++) {
              interestValue[activityListModel[i].Name!] = activityListModel[i].SubActivities!;
            }
            commonPassingArgs.endUserActivitySelection = interestValue;
            showModalBottomSheet(
                context: context,
                enableDrag: false,
                isDismissible: false,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                    return filterScreenView(setState);
                  });
                }).then((value) {
              if (value != null) {
                selectedFilterData = value as Map<String, List<SelectedFilterValues>>?;
                debugPrint(selectedFilterData.toString());
                if (selectedFilterData!.isEmpty) {
                  showSnackBar('Please select sub-activity', context);
                } else {
                  List<String> data = [];
                  for (int i = 0; i < selectedFilterData!.keys.length; i++) {
                    String key = selectedFilterData!.keys.elementAt(i);
                    List<SelectedFilterValues> value = selectedFilterData![key]!;
                    // print("length -> ${value.length}");
                    for (var element in value) {
                      data.add(element.subActivityId.toString());
                    }
                  }
                  // print(data.length);

                  List<String> subActivityMapList = [];
                  String requestString = '';
                  for (int i = 0; i < data.length; i++) {
                    subActivityMapList.add(data[i]);
                    requestString = "$requestString&subactivities=${data[i]}";
                  }
                  requestData = requestString;

                  setState(() {
                    searchQuery = '';
                    _searchController.clear();
                    pageCount = 0;
                    coachesList.clear();
                  });

                  if (isGroupBookingSelected) {
                    requestData = "$requestData&bookingType=G";
                    getCoaches(requestData);
                  } else if (isIndividualBookingSelected) {
                    requestData = "$requestData&bookingType=I";
                    getCoaches(requestData);
                  } else {
                    getCoaches(requestData);
                  }
                  // getCoaches(requestData);
                }
              }
            });
          },
          child: SizedBox(
            height: 25.0,
            width: 25.0,
            child: Image.asset(
              'assets/images/ic_filter.png',
            ),
          ),
        ),
      ],
    );
  }

  Widget filterScreenView(StateSetter setState) {
    return WillPopScope(
      onWillPop: () async {
        isIndividualBookingSelected = true;
        isGroupBookingSelected = false;
        for (int i = 0; i < commonPassingArgs.endUserActivitySelection!.length; i++) {
          String key = commonPassingArgs.endUserActivitySelection!.keys.elementAt(i);
          List<SubActivitiesBean> values = commonPassingArgs.endUserActivitySelection![key];
          for (int j = 0; j < values.length; j++) {
            if (values[j].selectedValue!) {
              selectedValuesFromKey[j].selectedValue = false;
            }
          }
        }
        for (int j = 0; j < selectedValuesFromKey.length; j++) {
          if (selectedValuesFromKey[j].selectedValue!) {
            selectedValuesFromKey[j].selectedValue = false;
          }
        }
        selectedValue = "";
        Navigator.of(context).pop();
        return false;
      },
      child: Container(
        color: Theme.of(context).colorScheme.onBackground,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20.0,
            ),
            topView(setState),
            const SizedBox(
              height: 20.0,
            ),
            selectionView(setState),
            const SizedBox(
              height: 30.0,
            ),
            Expanded(child: filterView(setState)),
            bottomBtnView(setState),
          ],
        ),
      ),
    );
  }

  Widget bottomBtnView(StateSetter setState) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 70.0,
            child: ElevatedButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(const Color(0xFFCECECE)),
                  backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFCECECE)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                      side: BorderSide(
                        color: Color(0xFFCECECE),
                      ),
                    ),
                  ),
                ),
                onPressed: () {
                  isIndividualBookingSelected = true;
                  isGroupBookingSelected = false;
                  for (int i = 0; i < commonPassingArgs.endUserActivitySelection!.length; i++) {
                    String key = commonPassingArgs.endUserActivitySelection!.keys.elementAt(i);
                    List<SubActivitiesBean> values = commonPassingArgs.endUserActivitySelection![key];
                    for (int j = 0; j < values.length; j++) {
                      if (values[j].selectedValue!) {
                        selectedValuesFromKey[j].selectedValue = false;
                      }
                    }
                  }
                  for (int j = 0; j < selectedValuesFromKey.length; j++) {
                    if (selectedValuesFromKey[j].selectedValue!) {
                      selectedValuesFromKey[j].selectedValue = false;
                    }
                  }
                  selectedValue = "";
                  Navigator.of(context).pop();
                },
                child: CustomTextView(
                  label: 'Cancel',
                  textStyle: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.w400, fontSize: 16.0, decoration: TextDecoration.underline, color: OQDOThemeData.blackColor),
                )),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 70.0,
            child: ElevatedButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(const Color(0xFF006590)),
                  backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF006590)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                      side: BorderSide(
                        color: Color(0xFF006590),
                      ),
                    ),
                  ),
                ),
                onPressed: () {
                  for (int i = 0; i < commonPassingArgs.endUserActivitySelection!.length; i++) {
                    String key = commonPassingArgs.endUserActivitySelection!.keys.elementAt(i);
                    List<SubActivitiesBean> values = commonPassingArgs.endUserActivitySelection![key];
                    List<SelectedFilterValues> data = [];
                    for (int j = 0; j < values.length; j++) {
                      if (values[j].selectedValue!) {
                        SelectedFilterValues selectedFilterValues = SelectedFilterValues();
                        selectedFilterValues.activityName = values[j].Name;
                        selectedFilterValues.subActivityId = values[j].SubActivityId;
                        data.add(selectedFilterValues);
                        selectedValues[key] = data;
                      }
                    }
                  }
                  // print(selectedValues);
                  if (selectedValues.isEmpty) {
                    showSnackBar('Please select sub-activity for filter', context);
                  } else {
                    Navigator.of(context).pop(selectedValues);
                  }
                },
                child: CustomTextView(
                  label: 'Apply',
                  textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600, fontSize: 16.0, color: OQDOThemeData.whiteColor),
                )),
          ),
        )
      ],
    );
  }

  Widget topView(StateSetter setState) {
    return Container(
      padding: const EdgeInsets.only(left: 20.0, top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextView(
            label: 'Filter By',
            textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600, fontSize: 18.0, color: OQDOThemeData.greyColor),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isIndividualBookingSelected = false;
                    isGroupBookingSelected = false;
                    for (int i = 0; i < commonPassingArgs.endUserActivitySelection!.length; i++) {
                      String key = commonPassingArgs.endUserActivitySelection!.keys.elementAt(i);
                      List<SubActivitiesBean> values = commonPassingArgs.endUserActivitySelection![key];
                      for (int j = 0; j < values.length; j++) {
                        if (values[j].selectedValue!) {
                          selectedValuesFromKey[j].selectedValue = false;
                        }
                      }
                    }
                  });
                },
                child: CustomTextView(
                  label: 'Clear All',
                  textStyle: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(fontSize: 14.0, fontWeight: FontWeight.w400, decoration: TextDecoration.underline, color: OQDOThemeData.otherTextColor),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isIndividualBookingSelected = false;
                    isGroupBookingSelected = false;
                  });
                  for (int i = 0; i < commonPassingArgs.endUserActivitySelection!.length; i++) {
                    String key = commonPassingArgs.endUserActivitySelection!.keys.elementAt(i);
                    List<SubActivitiesBean> values = commonPassingArgs.endUserActivitySelection![key];
                    List<SelectedFilterValues> data = [];
                    for (int j = 0; j < values.length; j++) {
                      if (values[j].selectedValue!) {
                        selectedValuesFromKey[j].selectedValue = false;
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(shape: const CircleBorder(), backgroundColor: OQDOThemeData.backgroundColor),
                child: Image.asset(
                  'assets/images/ic_filter.png',
                  height: 20.0,
                  width: 20.0,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget selectionView(StateSetter setState) {
    return Container(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          isGroupBookingSelected
              ? Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      border: Border.all(width: 5.0, color: OQDOThemeData.backgroundColor),
                    ),
                    child: SizedBox(
                      height: 100.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isGroupBookingSelected ? OQDOThemeData.dividerColor : OQDOThemeData.backgroundColor,
                          shape: BoxShape.rectangle,
                          borderRadius: const BorderRadius.all(Radius.circular(2.0)),
                        ),
                        child: Center(
                          child: CustomTextView(
                            label: 'Group Booking',
                            textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 15.0,
                                color: isGroupBookingSelected ? OQDOThemeData.whiteColor : OQDOThemeData.blackColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isGroupBookingSelected = true;
                        isIndividualBookingSelected = false;
                      });
                    },
                    child: Container(
                      height: 100.0,
                      decoration: BoxDecoration(
                        color: OQDOThemeData.whiteColor,
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Center(
                        child: CustomTextView(
                          label: 'Group Booking',
                          textStyle:
                              Theme.of(context).textTheme.titleSmall!.copyWith(color: OQDOThemeData.greyColor, fontSize: 15.0, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ),
          const SizedBox(
            width: 20.0,
          ),
          isIndividualBookingSelected
              ? Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      border: Border.all(width: 5.0, color: OQDOThemeData.backgroundColor),
                    ),
                    child: SizedBox(
                      height: 100.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isIndividualBookingSelected ? OQDOThemeData.dividerColor : OQDOThemeData.backgroundColor,
                          shape: BoxShape.rectangle,
                          borderRadius: const BorderRadius.all(Radius.circular(2.0)),
                        ),
                        child: Center(
                          child: CustomTextView(
                            label: 'Individual Booking',
                            textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 15.0,
                                color: isIndividualBookingSelected ? OQDOThemeData.whiteColor : OQDOThemeData.blackColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isGroupBookingSelected = false;
                        isIndividualBookingSelected = true;
                      });
                    },
                    child: Container(
                      height: 100.0,
                      decoration: BoxDecoration(
                        color: OQDOThemeData.whiteColor,
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Center(
                        child: CustomTextView(
                          label: 'Individual Booking',
                          textStyle:
                              Theme.of(context).textTheme.titleSmall!.copyWith(color: OQDOThemeData.greyColor, fontSize: 15.0, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget filterView(StateSetter setState) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: commonPassingArgs.endUserActivitySelection!.length,
              itemBuilder: (context, index) {
                String key = commonPassingArgs.endUserActivitySelection!.keys.elementAt(index);
                bool? isSelected = itemsSelectedValue[index] ?? false;
                return firstFilter(key, index, isSelected, setState);
              },
              separatorBuilder: (BuildContext context, int index) {
                return Container();
              },
            ),
          ),
          Container(
            color: const Color.fromRGBO(227, 227, 227, 1.0),
            width: 1,
            height: double.infinity,
          ),
          selectedValue != ""
              ? Flexible(
                  flex: 3,
                  fit: FlexFit.tight,
                  child: ListView.separated(
                    shrinkWrap: false,
                    controller: _scrollController2,
                    itemCount: selectedValuesFromKey.length,
                    itemBuilder: (context, index) {
                      return reviewAppointmentSingleView(index, setState);
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Container();
                    },
                  ),
                )
              : Flexible(
                  flex: 3,
                  fit: FlexFit.tight,
                  child: Container(),
                ),
        ],
      ),
    );
  }

  Widget reviewAppointmentSingleView(int index, StateSetter setState) {
    return Container(
      padding: const EdgeInsets.only(left: 10.0, right: 20.0, top: 20.0),
      child: Row(
        children: [
          Transform.scale(
            scale: 1.3,
            child: Checkbox(
                fillColor: MaterialStateProperty.resolveWith(Utils.getColor),
                checkColor: Theme.of(context).colorScheme.primaryContainer,
                value: selectedValuesFromKey[index].selectedValue,
                onChanged: (value) {
                  setState(() {
                    selectedValuesFromKey[index].selectedValue = value;
                  });
                }),
          ),
          const SizedBox(
            width: 15.0,
          ),
          Expanded(
            child: CustomTextView(
              maxLine: 3,
              textOverFlow: TextOverflow.ellipsis,
              label: selectedValuesFromKey[index].Name,
              textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 16.0, fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor),
            ),
          )
        ],
      ),
    );
  }

  Widget firstFilter(String key, int index, bool isSelected, StateSetter setState) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              selectedValue = key;
              if (index == index) {
                itemsSelectedValue[index] = !isSelected;
              }
              debugPrint("OnClick : $index + ${itemsSelectedValue[index]}");
              List<SubActivitiesBean> selectedValueList = commonPassingArgs.endUserActivitySelection![key];
              selectedValuesFromKey = selectedValueList;
              if (_scrollController2.positions.isNotEmpty) {
                _scrollController2.jumpTo(0);
              }
            });
          },
          child: Container(
            height: 80.0,
            color: selectedValue == key ? OQDOThemeData.filterDividerColor : OQDOThemeData.whiteColor,
            child: Center(
              child: CustomTextView(
                label: key,
                textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 14.0, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 1.0,
          child: Container(
            color: OQDOThemeData.filterDividerColor,
          ),
        ),
      ],
    );
  }

  Future<void> _onRefresh() async {
    setState(() {
      pageCount = 0;
      coachesList.clear();
      requestData = '';
      searchQuery = ''; // Clear search query
      isSearching = false;
      isSearchLoading = false; // Hide search loader
      isCircularProgressLoading = true;
    });
    _searchController.clear();
    await getCoaches('pageStart=${pageCount!}&resultPerPage=$resultPerPage');
  }
}
