import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:oqdo_mobile_app/screens/bazaar/ads_screen/ads_view.dart';
import 'package:oqdo_mobile_app/screens/bazaar/ads_screen/intent/ads_intent.dart';
import 'package:oqdo_mobile_app/screens/bazaar/ads_screen/model/advertisement_type_response_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/ads_screen/model/subactivyt_and_activity_response_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/ads_screen/viewmodel/ads_view_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/ads_screen/widgets/category_view.dart';
import 'package:oqdo_mobile_app/screens/bazaar/ads_screen/widgets/segmented_view.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:provider/provider.dart';

class AdsScreen extends StatefulWidget {
  const AdsScreen({super.key});

  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  TabController? controller;
  List<AdvertisementTypeResponse> segments = [];
  AdvertisementTypeResponse? selectedSegment;
  List<Activity> categories = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getAdvertisementTypeList();
      getAllActivitys();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: categories.isNotEmpty
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 20, 10, 0),
                  child: SegmentedView(
                    segments: segments,
                    backgroundColor: Color(0xFFD4EEF9),
                    onSegmentSelected: (p0) {
                      selectedSegment = p0;
                      setState(() {});
                      debugPrint('Segment selected: ${selectedSegment!.name}');
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Column(
                      children: [
                        Expanded(
                          child: CustomScrollView(
                            slivers: [
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    final category = categories[index]; // categories from API
                                    return Column(
                                      children: [
                                        CategoryView(
                                          onPressed: () {
                                            // Create a map with the selected category and its sub-activities
                                            var activityMap = <String, List<SubActivity>>{categories[index].name: categories[index].subActivities};

                                            var intent = AdsIntent(
                                                activityMap: activityMap,
                                                selectedAdsType: selectedSegment!.advertisementTypeId,
                                                selectedAdsTypeTitle: selectedSegment!.name);

                                            Navigator.pushNamed(context, SportsAdvertisementCarousel.routeName, arguments: intent);
                                          },
                                          image: category.filePath,
                                          title: category.name,
                                        ),
                                        if (index != categories.length - 1) const SizedBox(height: 16),
                                      ],
                                    );
                                  },
                                  childCount: categories.length,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, Constants.addAdsScreen);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF006590),
                              foregroundColor: Color(0xFF006590),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            ),
                            child: Text(
                              'Add Your Advertisement',
                              style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w700, fontFamily: 'SFPro'),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> getAllActivitys() async {
    try {
      await Provider.of<AdsViewModel>(context, listen: false).getAllActivityAndSubActivity().then(
        (value) {
          Response res = value;
          if (res.statusCode == 500 || res.statusCode == 404) {
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            SubActivityAndActivityResponseModel subActivityAndActivityResponseModel = SubActivityAndActivityResponseModel.fromJson(jsonDecode(res.body));
            if (subActivityAndActivityResponseModel.data.isNotEmpty) {
              setState(() {
                categories = subActivityAndActivityResponseModel.data;
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

  Future<void> getAdvertisementTypeList() async {
    try {
      await Provider.of<AdsViewModel>(context, listen: false).getAdvertisementTypeList().then(
        (value) {
          Response res = value;
          if (res.statusCode == 500 || res.statusCode == 404) {
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            AdvertisementTypeResponseModel advertisementTypeResponseModel = AdvertisementTypeResponseModel.fromJson(jsonDecode(res.body));
            if (advertisementTypeResponseModel.data.isNotEmpty) {
              setState(() {
                // Sort segments by DisplayOrder
                segments = advertisementTypeResponseModel.data;
                segments.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
                selectedSegment = segments.first; // Now this will be the segment with lowest DisplayOrder
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
}
