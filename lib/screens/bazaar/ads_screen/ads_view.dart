import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/screens/bazaar/ads_screen/category_screen.dart';
import 'package:oqdo_mobile_app/screens/bazaar/ads_screen/intent/ads_intent.dart';
import 'package:oqdo_mobile_app/screens/bazaar/ads_screen/model/ads_list_request_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/ads_screen/model/advertisement_list_response_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/ads_screen/viewmodel/ads_view_model.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'model/subactivyt_and_activity_response_model.dart';

class SportsAdvertisementCarousel extends StatefulWidget {
  static const routeName = '/advertisement-carousel';
  final AdsIntent? intent;

  const SportsAdvertisementCarousel({super.key, required this.intent});

  @override
  State<SportsAdvertisementCarousel> createState() => _SportsAdvertisementCarouselState();
}

class _SportsAdvertisementCarouselState extends State<SportsAdvertisementCarousel> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();

  List<Advertisement> advertisementList = [];
  late AdsIntent currentIntent;

  int _currentPage = 1;
  int _resultPerPage = 10;
  int _pageStart = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    currentIntent = widget.intent!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      List<SubActivityParams> subActivityList = [];

      // Process each activity and its sub-activities from the map
      currentIntent.activityMap.forEach((activityName, subActivities) {
        // Add all sub-activities for this activity
        subActivityList.addAll(
          subActivities.map(
            (subActivity) => SubActivityParams(
              subActivityId: subActivity.subActivityId,
              name: subActivity.name,
            ),
          ),
        );
      });

      final request = AdsListRequestModel(
        advertisementTypeId: currentIntent.selectedAdsType ?? 0,
        pageStart: _pageStart,
        resultPerPage: _resultPerPage,
        subActivities: subActivityList,
      );

      setState(() {
        _isLoading = true;
      });

      getAdvertisementList(request.toJson());
    });
  }

  // Update the handle filter result method to use the new map structure
  void _handleFilterResult(Map<String, List<SubActivity>> result) {
    List<SubActivityParams> selectedSubActivities = [];

    // Convert the filter results to SubActivityParams
    result.forEach((activityName, subActivities) {
      selectedSubActivities.addAll(
        subActivities.map(
          (subActivity) => SubActivityParams(
            subActivityId: subActivity.subActivityId,
            name: subActivity.name,
          ),
        ),
      );
    });

    // Update currentIntent
    setState(() {
      currentIntent = AdsIntent(
        selectedAdsType: currentIntent.selectedAdsType,
        activityMap: result,
        selectedAdsTypeTitle: currentIntent.selectedAdsTypeTitle,
      );
    });

    // Create new request with updated selections
    final request = AdsListRequestModel(
      advertisementTypeId: currentIntent.selectedAdsType ?? 0,
      pageStart: 0,
      resultPerPage: _resultPerPage,
      subActivities: selectedSubActivities,
    );

    setState(() {
      _currentPage = 1;
      _pageStart = 0;
      _isLoading = true;
      advertisementList.clear();
    });

    getAdvertisementList(request.toJson());
  }

  // Update the filter button in build method
  Widget _buildFilterButton() {
    return IconButton(
      icon: Image.asset('assets/images/ic_ads_filter.png', width: 30.0, height: 30.0),
      onPressed: () async {
        final result = await Navigator.pushNamed(context, CategoryScreen.routeName, arguments: currentIntent);

        if (result != null && result is Map<String, List<SubActivity>>) {
          _handleFilterResult(result);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        backgroundColor: const Color(0xFF006590),
        title: widget.intent!.selectedAdsType == 1 ? 'Advertisement' : 'Events',
        isIconColorBlack: false,
        onBack: () => Navigator.pop(context),
        actions: [
          IconButton(
            icon: Image.asset('assets/images/ic_ads_filter.png', width: 30.0, height: 30.0),
            onPressed: () async {
              setState(() {
                _currentIndex = 0;
                // _carouselController.stopAutoPlay();
                // _carouselController.animateToPage(0);
              });

              final result = await Navigator.pushNamed(context, CategoryScreen.routeName, arguments: currentIntent);

              if (result != null && result is Map<String, List<SubActivity>>) {
                // Create list of SubActivityParams from the result map
                List<SubActivityParams> selectedSubActivities = [];

                result.forEach((activityName, subActivities) {
                  for (var subActivity in subActivities) {
                    selectedSubActivities.add(
                      SubActivityParams(
                        subActivityId: subActivity.subActivityId,
                        name: subActivity.name,
                      ),
                    );
                  }
                });

                setState(() {
                  _currentPage = 1;
                  _pageStart = 0;
                  _isLoading = true;
                  advertisementList.clear();
                  _currentIndex = 0;
                });

                // Update currentIntent with new selections
                setState(() {
                  currentIntent = AdsIntent(
                    selectedAdsType: currentIntent.selectedAdsType,
                    activityMap: result,
                    selectedAdsTypeTitle: currentIntent.selectedAdsTypeTitle,
                  );
                });

                // Create request with updated selections
                final request = AdsListRequestModel(
                  advertisementTypeId: currentIntent.selectedAdsType ?? 0,
                  pageStart: 0,
                  resultPerPage: _resultPerPage,
                  subActivities: selectedSubActivities,
                );

                getAdvertisementList(request.toJson());

                // Only animate after getting data and only if there are items
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            advertisementList.isNotEmpty
                ? Expanded(
                    child: Stack(
                      children: [
                        CarouselSlider.builder(
                          carouselController: _carouselController,
                          itemCount: advertisementList.length,
                          options: CarouselOptions(
                            height: double.infinity,
                            viewportFraction: 1.0,
                            enlargeCenterPage: false,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                            enableInfiniteScroll: advertisementList.length > 1,
                            autoPlay: advertisementList.length > 1,
                            autoPlayInterval: Duration(seconds: 3),
                            autoPlayAnimationDuration: Duration(milliseconds: 800),
                            autoPlayCurve: Curves.fastOutSlowIn,
                          ),
                          itemBuilder: (context, index, realIndex) {
                            return GestureDetector(
                              onTap: () {
                                _launchURL(advertisementList[index].webUrl, context);
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                ),
                                child: Image.network(
                                  advertisementList[index].filePath,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        Icons.error_outline,
                                        color: Colors.white,
                                        size: 48.0,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        advertisementList.isNotEmpty
                            ? Positioned(
                                bottom: 20.0,
                                left: 30.0,
                                child: Row(
                                  children: advertisementList.asMap().entries.map((entry) {
                                    return GestureDetector(
                                      onTap: () => _carouselController.animateToPage(entry.key),
                                      child: Container(
                                        width: 16.0,
                                        height: 16.0,
                                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _currentIndex == entry.key ? const Color(0xFF006590) : Colors.white,
                                          border: _currentIndex == entry.key
                                              ? Border.all(color: Colors.white, width: 2.0)
                                              : Border.all(color: Colors.grey[300]!, width: 1.0),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                  )
                : Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : const Center(
                            child: Text(
                              'No advertisements found',
                              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
                            ),
                          ),
                  ),
          ],
        ),
      ),
    );
  }

  // Future<void> _launchURL(String urlString, BuildContext context) async {
  //   final Uri url = Uri.parse(urlString);
  //   if (await canLaunchUrl(url)) {
  //     await launchUrl(url, mode: LaunchMode.externalApplication);
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Could not launch $urlString')),
  //     );
  //   }
  // }

  Future<void> _launchURL(String urlString, BuildContext context) async {
    // if (urlString.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('URL is empty')),
    //   );
    //   return;
    // }

    // final Uri url = Uri.parse(urlString);
    // final urlPattern =
    //     r'^(https?:\/\/)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6}(:[0-9]{1,5})?(\/.*)?$';
    final urlPattern = r'^(https?:\/\/)?([\w-]+(\.[\w-]+)+)(:\d{1,5})?(\/[^\s]*)?(\?[^\s]*)?$';
    final isValidUrl = RegExp(urlPattern).hasMatch(urlString);

    if (isValidUrl) {
      if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
        urlString = 'https://$urlString';
      }

      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $urlString')),
        );
      }
      // await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> getAdvertisementList(Map<String, dynamic> json) async {
    try {
      final value = await Provider.of<AdsViewModel>(context, listen: false).getAdvertisementList(json);
      Response res = value;

      if (res.statusCode == 200) {
        AdvertisementListResponseModel model = AdvertisementListResponseModel.fromJson(jsonDecode(res.body));
        setState(() {
          _isLoading = false;
          advertisementList = model.data;
        });
      } else if (res.statusCode == 500 || res.statusCode == 404) {
        setState(() => _isLoading = false);
        showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
      } else {
        setState(() => _isLoading = false);
        Map<String, dynamic> errorModel = jsonDecode(res.body);
        if (errorModel['ModelState']?['ErrorMessage'] != null) {
          showSnackBarColor(errorModel['ModelState']['ErrorMessage'][0], context, true);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (e is NoConnectivityException) {
        showSnackBarErrorColor(AppStrings.noInternet, context, true);
      } else if (e is TimeoutException) {
        showSnackBarErrorColor(AppStrings.timeout, context, true);
      } else if (e is ServerException) {
        showSnackBarErrorColor(AppStrings.serverError, context, true);
      } else {
        showSnackBarErrorColor(e.toString(), context, true);
      }
    }
  }
}
