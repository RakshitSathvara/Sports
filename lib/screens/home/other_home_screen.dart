import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/model/home_response_model.dart';
import 'package:oqdo_mobile_app/model/selecte_home_model.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:oqdo_mobile_app/viewmodels/DashboardViewModel.dart';
import 'package:provider/provider.dart';

class ActivityHomeScreen extends StatefulWidget {
  String? homeScreenSelection;

  ActivityHomeScreen({Key? key, this.homeScreenSelection}) : super(key: key);

  @override
  State<ActivityHomeScreen> createState() => _ActivityHomeScreenState();
}

class _ActivityHomeScreenState extends State<ActivityHomeScreen> {
  List<Data> selectedHomeActivityResponseList = [];
  List<SubActivities> _searchedHomeActivityResponseList = [];
  final TextEditingController _searchActivityController = TextEditingController();
  bool isSearch = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getHomeActivities();
      _searchActivityController.addListener(() {
        if (_searchActivityController.text.isNotEmpty) {
          debugPrint('Search -> ${_searchActivityController.text}');
          setState(() {
            isSearch = true;
            _searchedHomeActivityResponseList = selectedHomeActivityResponseList[0]
                .subActivities!
                .where((element) => element.name!.toLowerCase().contains(_searchActivityController.text))
                .toList();
          });
          debugPrint('Search List main-> ${selectedHomeActivityResponseList.length}');
          debugPrint('Search List -> ${_searchedHomeActivityResponseList.length}');
        } else {
          setState(() {
            isSearch = false;
            _searchedHomeActivityResponseList.clear();
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: OQDOThemeData.whiteColor,
        leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Image.asset(
              widget.homeScreenSelection! == HomeScreenSelection.Sports.name
                  ? 'assets/images/ic_sports.png'
                  : widget.homeScreenSelection == HomeScreenSelection.Hobbies.name
                      ? 'assets/images/ic_hobbies.png'
                      : 'assets/images/ic_wellness.png',
              height: 50,
              width: 50,
            ),
          ),
        ),
        title: CustomTextView(
          label: widget.homeScreenSelection! == HomeScreenSelection.Sports.name
              ? 'Sports'
              : widget.homeScreenSelection == HomeScreenSelection.Hobbies.name
                  ? 'Hobbies'
                  : 'Wellness',
          textStyle:
              Theme.of(context).textTheme.bodyMedium!.copyWith(fontFamily: 'Ultra', fontSize: 16, color: OQDOThemeData.blackColor, fontWeight: FontWeight.w400),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: OQDOThemeData.whiteColor,
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromRGBO(212, 212, 212, 0.8),
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(10))),
                    child: SizedBox(
                      height: 40,
                      child: TextFormField(
                        autocorrect: false,
                        autofocus: false,
                        cursorColor: OQDOThemeData.greyColor,
                        minLines: 1,
                        controller: _searchActivityController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          icon: Image.asset(
                            'assets/images/ic_search_home.png',
                            height: 20,
                            width: 20,
                            fit: BoxFit.fill,
                          ),
                          hintText: widget.homeScreenSelection! == HomeScreenSelection.Sports.name
                              ? 'Search Sports'
                              : widget.homeScreenSelection == HomeScreenSelection.Hobbies.name
                                  ? 'Search Hobbies'
                                  : 'Search Wellness',
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                !isSearch
                    ? selectedHomeActivityResponseList.isNotEmpty
                        ? Expanded(
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10.0, right: 10),
                                child: GridView.builder(
                                    shrinkWrap: true,
                                    itemCount: selectedHomeActivityResponseList[0].subActivities!.length,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(mainAxisSpacing: 15.0, crossAxisSpacing: 10.0, crossAxisCount: 3),
                                    itemBuilder: (context, index) {
                                      var model = selectedHomeActivityResponseList[0].subActivities![index];
                                      return singlePopularSportsView(model);
                                    }),
                              ),
                            ),
                          )
                        : const Expanded(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                    : _searchedHomeActivityResponseList.isNotEmpty
                        ? Expanded(
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10.0, right: 10),
                                child: GridView.builder(
                                    shrinkWrap: true,
                                    itemCount: _searchedHomeActivityResponseList.length,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(mainAxisSpacing: 15.0, crossAxisSpacing: 10.0, crossAxisCount: 3),
                                    itemBuilder: (context, index) {
                                      var model = _searchedHomeActivityResponseList[index];
                                      return singlePopularSportsView(model);
                                    }),
                              ),
                            ),
                          )
                        : Container()
              ],
            )),
      ),
    );
  }

  Widget singlePopularSportsView(SubActivities model) {
    return GestureDetector(
      onTap: () {
        SelectedHomeModel selectedHomeModel = SelectedHomeModel();
        selectedHomeModel.selectedActivity = widget.homeScreenSelection;
        selectedHomeModel.subActivities = model;
        debugPrint('Name P -> ${selectedHomeModel.subActivities!.name}');
        Navigator.of(context).pushNamed(Constants.selectedActivityHomeScreen, arguments: selectedHomeModel);
      },
      child: SizedBox(
        height: 140.0,
        child: Card(
          color: widget.homeScreenSelection! == HomeScreenSelection.Sports.name
              ? OQDOThemeData.sportsListing
              : widget.homeScreenSelection == HomeScreenSelection.Hobbies.name
                  ? OQDOThemeData.hobbiesListing
                  : OQDOThemeData.wellnessListing,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 4.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                width: 80.0,
                height: 80.0,
                child: Image.network(
                  model.filePath!,
                  fit: BoxFit.fill,
                ),
              ),
              Align(
                  alignment: Alignment.center,
                  child: Text(
                    model.name.toString(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: OQDOThemeData.blackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          overflow: TextOverflow.ellipsis,
                        ),
                  )),
              const SizedBox(
                height: 5.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getHomeActivities() async {
    try {
      String selectedActivityName;
      if (widget.homeScreenSelection == HomeScreenSelection.Sports.name) {
        selectedActivityName = 'Sports';
      } else if (widget.homeScreenSelection == HomeScreenSelection.Hobbies.name) {
        selectedActivityName = 'Hobbies';
      } else {
        selectedActivityName = 'Wellness';
      }
      HomeResponseModel homeResponseModel = await Provider.of<DashboardViewModel>(context, listen: false).getHomeActivity(selectedActivityName);
      if (!mounted) return;
      if (homeResponseModel.data!.isNotEmpty) {
        setState(() {
          selectedHomeActivityResponseList = homeResponseModel.data!;
        });
        debugPrint('length ${selectedHomeActivityResponseList.length}');
      }
    } on CommonException catch (error) {
      debugPrint(error.toString());
      if (error.code == 400) {
        Map<String, dynamic> errorModel = jsonDecode(error.message);
        if (errorModel.containsKey('ModelState')) {
          Map<String, dynamic> modelState = errorModel['ModelState'];
          if (modelState.containsKey('ErrorMessage')) {
            showSnackBarColor(modelState['ErrorMessage'][0], context, true);
          } else {
            showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
          }
        } else {
          showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
        }
      } else {
        showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
    } on NoConnectivityException catch (_) {
      if (!mounted) return;
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      if (!mounted) return;
      debugPrint(error.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  void showLoading() {
    setState(() {
      isLoading = true;
    });
  }

  void cancelLoading() {
    setState(() {
      isLoading = false;
    });
  }
}
