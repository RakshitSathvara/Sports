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
import 'package:oqdo_mobile_app/screens/favorites/model/coach_batch_favorite_response_model.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:oqdo_mobile_app/viewmodels/BookingViewModel.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import '../../model/CoachListResponseModel.dart';

class CoachFavoritesListPage extends StatefulWidget {
  SelectedHomeModel? selectedHomeModel;

  CoachFavoritesListPage({Key? key, this.selectedHomeModel}) : super(key: key);

  @override
  _CoachFavoritesListPageState createState() => _CoachFavoritesListPageState();
}

class _CoachFavoritesListPageState extends State<CoachFavoritesListPage> {
  String? isLogin;
  String? userType;
  int? pageCount = 0;
  int? resultPerPage = 10;
  int? totalCount;
  bool isLoading = false;
  String request = '';
  late ProgressDialog _progressDialog;
  List<CoachBatchData> coachesList = [];
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
  final ScrollController _scrollController2 = ScrollController();
  bool isAPICalled = false;

  @override
  void initState() {
    super.initState();
    getSharedPref();
    isCircularProgressLoading = true;
    selectedTypeValue = 'Coaches';
  }

  void getSharedPref() async {
    isLogin = OQDOApplication.instance.storage.getStringValue(AppStrings.isLogin);
    getCoaches();
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
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // selectionTypeWithFilterView(),
                        DropdownButton<dynamic>(
                          isExpanded: false,
                          underline: const SizedBox(),
                          dropdownColor: Theme.of(context).colorScheme.onBackground,
                          hint: CustomTextView(
                            label: filterList![0],
                            textStyle:
                                Theme.of(context).textTheme.titleMedium!.copyWith(color: OQDOThemeData.greyColor, fontSize: 20.0, fontWeight: FontWeight.w300),
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
                            selectedTypeValue = value as String;
                            SelectedHomeModel selectedHomeModel = SelectedHomeModel();
                            if (selectedTypeValue == 'Facilities') {
                              Navigator.pushNamed(context, Constants.facilityFavoritesList, arguments: selectedHomeModel);
                            }
                            //  else {
                            //   Navigator.pushNamed(context, Constants.coachFavoritesList, arguments: selectedHomeModel);
                            // }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  coachesList.isNotEmpty
                      ? Expanded(
                          child: Stack(
                            children: [
                              NotificationListener<ScrollNotification>(
                                onNotification: (ScrollNotification scrollNotification) {
                                  if (scrollNotification is ScrollEndNotification && scrollNotification.metrics.extentAfter < 100 && !isLoading) {
                                    if (totalCount != coachesList.length) {
                                      getCoaches();
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
                                    }),
                              ),
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
                                    label: 'Coaches not found',
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

  Widget singleCoachView(CoachBatchData coachesModel) {
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
                          FavoriteToggleButton(
                            isFavorite: coachesModel.isFavorite,
                            size: 35,
                            onFavoriteChanged: () {
                              addRemoveFromFavorite(coachesModel);
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
                                  label: coachesModel.avgProviderRating.toStringAsFixed(1),
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

  Future<void> getCoaches() async {
    try {
      setState(() {
        isLoading = true;
      });

      String requestStr = 'pageStart=${pageCount!}&resultPerPage=$resultPerPage&Flag=C';
      await Provider.of<BookingViewModel>(context, listen: false).getFavoriteCoach(requestStr).then(
        (value) {
          Response res = value;
          if (!mounted) return;
          if (res.statusCode == 500 || res.statusCode == 404) {
            setState(() {
              isCircularProgressLoading = false;
            });
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            CoachBatchFavoriteResponseModel coachBatchFavoriteResponseModel = CoachBatchFavoriteResponseModel.fromJson(jsonDecode(res.body));
            if (coachBatchFavoriteResponseModel.data.isNotEmpty) {
              coachesList.addAll(coachBatchFavoriteResponseModel.data);
              totalCount = coachBatchFavoriteResponseModel.totalCount;
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
                isAPICalled = true;
                pageCount = 0;
                coachesList.clear();
                isCircularProgressLoading = true;
              });
              await getCoaches();
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

  Future<void> addRemoveFromFavorite(CoachBatchData coachesModel) async {
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
            coachesModel.isFavorite = coachesModel.isFavorite;
          });
          showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
        } else if (res.statusCode == 200) {
          String response = res.body;
          if (response.isNotEmpty) {
            isAPICalled = true;
            coachesList.remove(coachesModel);
          } else {
            coachesModel.isFavorite = coachesModel.isFavorite;
          }
          await _progressDialog.hide();
          setState(() {});
        } else {
          await _progressDialog.hide();
          setState(() {
            coachesModel.isFavorite = coachesModel.isFavorite;
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
        coachesModel.isFavorite = coachesModel.isFavorite;
      });
      if (!mounted) return;
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      await _progressDialog.hide();
      setState(() {
        coachesModel.isFavorite = coachesModel.isFavorite;
      });
      if (!mounted) return;
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      await _progressDialog.hide();
      setState(() {
        coachesModel.isFavorite = coachesModel.isFavorite;
      });
      if (!mounted) return;
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      await _progressDialog.hide();
      setState(() {
        coachesModel.isFavorite = coachesModel.isFavorite;
      });
      if (!mounted) return;
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }
}
