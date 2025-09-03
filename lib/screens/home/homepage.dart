import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/helper/helpers.dart';
import 'package:oqdo_mobile_app/model/PopularSportsResponseModel.dart';
import 'package:oqdo_mobile_app/model/coach_profile_response.dart';
import 'package:oqdo_mobile_app/model/end_user_profile_response.dart';
import 'package:oqdo_mobile_app/model/facility_profile_response.dart';
import 'package:oqdo_mobile_app/model/selecte_home_model.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/ConnectivityService.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:oqdo_mobile_app/utils/update_popup.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:oqdo_mobile_app/viewmodels/DashboardViewModel.dart';
import 'package:oqdo_mobile_app/viewmodels/ProfileViewModel.dart';
import 'package:oqdo_mobile_app/viewmodels/notification_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/home_response_model.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with WidgetsBindingObserver {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  late Helper hp;

  List<PopularSportsResponseModel> popularActivityList = [];
  List<PopularSportsResponseModel> sportsList = [];
  List<PopularSportsResponseModel> wellnessList = [];
  List<PopularSportsResponseModel> hobbiesList = [];
  String? isLogin = '';
  String? selectedCountry = '';
  late CoachProfileResponseModel coachProfileResponseModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getPrefData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void getPrefData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      isLogin = OQDOApplication.instance.storage.getStringValue(AppStrings.isLogin);
      selectedCountry = OQDOApplication.instance.storage.getStringValue(AppStrings.selectedCountryName);

      if (Constants.categoryList == null) {
        if (await hasNetwork()) {
          getPopularActivity();
        } else {
          // ignore: use_build_context_synchronously
          dialogOpen(context);
        }
      } else {
        if (await hasNetwork()) {
          setCategoryData(Constants.categoryList!);
        } else {
          // ignore: use_build_context_synchronously
          dialogOpen(context);
        }
      }

      OQDOApplication.instance.isLogin = isLogin;
      // if (OQDOApplication.instance.isLogin == '1') {
      if (await hasNetwork()) {
        getConfigCall();
      } else {
        // ignore: use_build_context_synchronously
        dialogOpen(context);
      }
      // }
    });
  }

  Future<void> dialogOpen(BuildContext mContext) {
    return showDialog(
      context: mContext,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.network_check_rounded,
                color: Colors.red,
                size: 100.0,
              ),
              const SizedBox(height: 10.0),
              CustomTextView(
                maxLine: 4,
                textOverFlow: TextOverflow.ellipsis,
                label: "Slow or No Internet.",
                textStyle: Theme.of(mContext).textTheme.bodyMedium!.copyWith(
                      color: OQDOThemeData.blackColor,
                      fontSize: 20,
                    ),
              ),
              const SizedBox(height: 10.0),
              Text(
                "Please check your internet settings",
                textAlign: TextAlign.center,
                maxLines: 4,
                style: Theme.of(mContext).textTheme.bodyMedium!.copyWith(
                      color: OQDOThemeData.blackColor,
                      fontSize: 16,
                    ),
              ),
              const SizedBox(height: 20.0),
              MyButton(
                text: 'Retry',
                textcolor: Theme.of(mContext).colorScheme.onBackground,
                textsize: 14,
                fontWeight: FontWeight.w500,
                letterspacing: 0.7,
                buttoncolor: Theme.of(mContext).colorScheme.secondaryContainer,
                buttonbordercolor: Theme.of(mContext).colorScheme.secondaryContainer,
                buttonheight: 40.0,
                buttonwidth: 100,
                radius: 15,
                onTap: () async {
                  Navigator.pop(mContext);
                  checkInternetConnectivity(mContext);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> checkInternetConnectivity(mContext) async {
    bool isConnected = await ConnectivityService.isInternetConnected();
    debugPrint("connected $isConnected");
    if (isConnected) {
      debugPrint("connected 1$isConnected");
      await Navigator.pushNamedAndRemoveUntil(mContext, Constants.APPPAGES, Helper.of(mContext).predicate, arguments: 0);
    } else {
      showDialog(
        context: mContext,
        barrierDismissible: false,
        builder: (_) => WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.network_check_rounded,
                  color: Colors.red,
                  size: 100.0,
                ),
                const SizedBox(height: 10.0),
                CustomTextView(
                  maxLine: 4,
                  textOverFlow: TextOverflow.ellipsis,
                  label: "Slow or No Internet.",
                  textStyle: Theme.of(mContext).textTheme.bodyMedium!.copyWith(
                        color: OQDOThemeData.blackColor,
                        fontSize: 20,
                      ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  "Please check your internet settings",
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  style: Theme.of(mContext).textTheme.bodyMedium!.copyWith(
                        color: OQDOThemeData.blackColor,
                        fontSize: 16,
                      ),
                ),
                const SizedBox(height: 20.0),
                MyButton(
                  text: 'Retry',
                  textcolor: Theme.of(mContext).colorScheme.onBackground,
                  textsize: 14,
                  fontWeight: FontWeight.w500,
                  letterspacing: 0.7,
                  buttoncolor: Theme.of(mContext).colorScheme.secondaryContainer,
                  buttonbordercolor: Theme.of(mContext).colorScheme.secondaryContainer,
                  buttonheight: 40.0,
                  buttonwidth: 100,
                  radius: 15,
                  onTap: () async {
                    debugPrint("Click ->");
                    Navigator.pop(mContext);
                    await checkInternetConnectivity(mContext);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: Container(
          width: width,
          height: height,
          color: OQDOThemeData.whiteColor,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: width,
                  height: 40,
                  color: OQDOThemeData.whiteColor,
                  padding: const EdgeInsets.only(left: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 25,
                        color: Theme.of(context).colorScheme.shadow,
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      CustomTextView(
                        label: 'Location: ${selectedCountry!}',
                        type: styleSubTitle,
                        textStyle:
                            Theme.of(context).textTheme.titleSmall!.copyWith(color: const Color(0xFF878787), fontSize: 16.0, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(Constants.homeScreenActivitySelectionScreen, arguments: HomeScreenSelection.Sports.name);
                          },
                          child: Image.asset("assets/images/sports_home.png"),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(Constants.homeScreenActivitySelectionScreen, arguments: HomeScreenSelection.Hobbies.name);
                          },
                          child: Image.asset("assets/images/hobby_home.png"),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(Constants.homeScreenActivitySelectionScreen, arguments: HomeScreenSelection.Wellness.name);
                          },
                          child: Image.asset("assets/images/lifestyle_home.png"),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomTextView(
                    label: 'Book',
                    type: styleSubTitle,
                    textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 24.0,
                          fontFamily: 'Ultra',
                          letterSpacing: 0.5,
                          color: OQDOThemeData.greyColor,
                        ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    circlecontainer('assets/images/ic_facility.png', 'Facilities', () async {
                      // if (OQDOApplication.instance.isLogin == '1') {
                      // if (OQDOApplication.instance.userType == Constants.endUserType) {
                      SelectedHomeModel selectedHomeModel = SelectedHomeModel();
                      await Navigator.pushNamed(context, Constants.FACILITIESLISTPAGE, arguments: selectedHomeModel);
                      // }
                      // } else {
                      // SelectedHomeModel selectedHomeModel = SelectedHomeModel();
                      // await Navigator.pushNamed(context, Constants.FACILITIESLISTPAGE, arguments: selectedHomeModel);
                      // }
                    }),
                    circlecontainer('assets/images/ic_appointment.png', 'Appointments', () async {
                      if (OQDOApplication.instance.isLogin == '1') {
                        if (OQDOApplication.instance.userType == Constants.endUserType) {
                          await Navigator.pushNamed(context, Constants.endUserAppointmentScreen, arguments: DateTime.now());
                        } else {
                          if (OQDOApplication.instance.userType == Constants.facilityType) {
                            await Navigator.pushNamed(context, Constants.facilityAppointmentScreen, arguments: DateTime.now());
                          } else {
                            await Navigator.pushNamed(context, Constants.coachAppointmentScreen, arguments: DateTime.now());
                          }
                        }
                      } else {
                        showSnackBarColor('Please login', context, true);
                        Timer(const Duration(microseconds: 500), () {
                          Navigator.of(context).pushNamed(Constants.LOGIN);
                        });
                      }
                    }),
                    circlecontainer('assets/images/ic_coaches.png', 'Coaches', () async {
                      // if (OQDOApplication.instance.isLogin == '1') {
                      //   if (OQDOApplication.instance.userType == Constants.endUserType) {
                      SelectedHomeModel selectedHomeModel = SelectedHomeModel();
                      await Navigator.pushNamed(context, Constants.COACHLISTPAGE, arguments: selectedHomeModel);
                      //   }
                      // } else {
                      //   SelectedHomeModel selectedHomeModel = SelectedHomeModel();
                      //   await Navigator.pushNamed(context, Constants.COACHLISTPAGE, arguments: selectedHomeModel);
                      // }
                    }),
                  ],
                ),

                const SizedBox(
                  height: 24.0,
                ),
                OQDOApplication.instance.isLogin == "1"
                    ? OQDOApplication.instance.userType == Constants.endUserType
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: CustomTextView(
                                  label: 'Buddies',
                                  type: styleSubTitle,
                                  textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 24.0,
                                        fontFamily: 'Ultra',
                                        letterSpacing: 0.5,
                                        color: OQDOThemeData.greyColor,
                                      ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  circlecontainer('assets/images/ic_friend.png', 'Friends', () {
                                    Navigator.of(context).pushNamed(Constants.searchBuddiesScreen);
                                  }),
                                  circlecontainer('assets/images/ic_group.png', 'Groups', () async {
                                    Navigator.of(context).pushNamed(Constants.groupListScreen);
                                  }),
                                  circlecontainer('assets/images/ic_meetup.png', 'Meetup', () {
                                    Navigator.of(context).pushNamed(Constants.listMeetup, arguments: DateTime.now());
                                  }),
                                ],
                              ),
                              const SizedBox(
                                height: 24,
                              ),
                            ],
                          )
                        : Container()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: CustomTextView(
                              label: 'Buddies',
                              type: styleSubTitle,
                              textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24.0,
                                    fontFamily: 'Ultra',
                                    letterSpacing: 0.5,
                                    color: OQDOThemeData.greyColor,
                                  ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              circlecontainer('assets/images/ic_friend.png', 'Friends', () {
                                showSnackBarColor('Please login', context, true);
                                Timer(const Duration(microseconds: 500), () {
                                  Navigator.of(context).pushNamed(Constants.LOGIN);
                                });
                              }),
                              circlecontainer('assets/images/ic_group.png', 'Groups', () {
                                showSnackBarColor('Please login', context, true);
                                Timer(const Duration(microseconds: 500), () {
                                  Navigator.of(context).pushNamed(Constants.LOGIN);
                                });
                              }),
                              circlecontainer('assets/images/ic_meetup.png', 'Meetup', () {
                                showSnackBarColor('Please login', context, true);
                                Timer(const Duration(microseconds: 500), () {
                                  Navigator.of(context).pushNamed(Constants.LOGIN);
                                });
                              }),
                            ],
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                        ],
                      ),

                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 20),
                //   child: CustomTextView(
                //     label: 'Bazaar',
                //     type: styleSubTitle,
                //     textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                //           fontWeight: FontWeight.w700,
                //           fontSize: 24.0,
                //           fontFamily: 'Ultra',
                //           letterSpacing: 0.5,
                //           color: OQDOThemeData.greyColor,
                //         ),
                //   ),
                // ),
                // const SizedBox(
                //   height: 10,
                // ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                //   children: [
                //     circlecontainer('assets/images/ic_ticket.png', 'Tickets', () async {
                //       await Navigator.pushNamed(context, Constants.comingSoonScreen);
                //     }),
                //     circlecontainer('assets/images/ic_equipment.png', 'Equipment', () async {
                //       await Navigator.pushNamed(context, Constants.comingSoonScreen);
                //     }),
                //     circlecontainer('assets/images/ic_apparel.png', 'Apparel', () async {
                //       await Navigator.pushNamed(context, Constants.comingSoonScreen);
                //     }),
                //   ],
                // ),
                const SizedBox(
                  height: 24.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomTextView(
                    label: 'Popular Sports',
                    type: styleSubTitle,
                    textStyle: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(letterSpacing: 0.5, color: OQDOThemeData.greyColor, fontSize: 20.0, fontFamily: 'Ultra', fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                sportsList.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          removeBottom: true,
                          child: GridView.builder(
                              shrinkWrap: true,
                              itemCount: sportsList.length,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(mainAxisSpacing: 15.0, crossAxisSpacing: 10.0, crossAxisCount: 3),
                              itemBuilder: (context, index) {
                                return singlePopularSportsView(index, sportsList, "Sports");
                              }),
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
                const SizedBox(
                  height: 24.0,
                ),

                // popular wellness
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomTextView(
                    label: 'Popular Wellness',
                    type: styleSubTitle,
                    textStyle: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: OQDOThemeData.blackColor, fontSize: 20.0, fontFamily: 'Ultra', fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                wellnessList.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          removeBottom: true,
                          child: GridView.builder(
                              shrinkWrap: true,
                              itemCount: wellnessList.length,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(mainAxisSpacing: 15.0, crossAxisSpacing: 10.0, crossAxisCount: 3),
                              itemBuilder: (context, index) {
                                return singlePopularSportsView(index, wellnessList, "Wellness");
                              }),
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
                const SizedBox(
                  height: 24.0,
                ),

                // popular hobbies
                // popular wellness
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomTextView(
                    label: 'Popular Hobbies',
                    type: styleSubTitle,
                    textStyle: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: OQDOThemeData.blackColor, fontSize: 20.0, fontFamily: 'Ultra', fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                hobbiesList.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          removeBottom: true,
                          child: GridView.builder(
                              shrinkWrap: true,
                              itemCount: hobbiesList.length,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(mainAxisSpacing: 15.0, crossAxisSpacing: 10.0, crossAxisCount: 3),
                              itemBuilder: (context, index) {
                                return singlePopularSportsView(index, hobbiesList, "Hobbies");
                              }),
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
                const SizedBox(
                  height: 24.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget singlePopularSportsView(int index, List<PopularSportsResponseModel> list, String selected) {
    return GestureDetector(
      onTap: () {
        // print(selected);
        SelectedHomeModel selectedHomeModel = SelectedHomeModel();
        selectedHomeModel.selectedActivity = selected;
        SubActivities subActivities = SubActivities();
        subActivities.name = list[index].subActivityName;
        subActivities.subActivityId = list[index].subActivityId;
        selectedHomeModel.subActivities = subActivities;
        Navigator.of(context).pushNamed(Constants.selectedActivityHomeScreen, arguments: selectedHomeModel);
      },
      child: SizedBox(
        height: 140.0,
        child: Card(
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
                  list[index].thumbnailUrl!,
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.error, // or Icons.error
                      color: Colors.red, // You can customize the color
                      size: 40.0, // You can adjust the size
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: CustomTextView(
                    label: list[index].subActivityName!,
                    color: OQDOThemeData.blackColor,
                    textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: OQDOThemeData.blackColor,
                          fontSize: 14,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w400,
                        ),
                    textOverFlow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(
                height: 5.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tabcontainer(String text, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
            height: 50,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: color),
            child: Center(
              child: CustomTextView(
                label: text,
                type: styleSubTitle,
                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.w600),
              ),
            )),
      ),
    );
  }

  Widget circlecontainer(String img, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              img,
              width: 110,
              height: 90,
            ),
          ),
          CustomTextView(
            label: text,
            type: styleSubTitle,
            maxLine: 2,
            textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: OQDOThemeData.greyColor, fontSize: 16.0, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Future<void> getPopularActivity() async {
    try {
      var response = await Provider.of<DashboardViewModel>(context, listen: false).getPopularSports();
      if (response.isNotEmpty) {
        popularActivityList.clear();
        popularActivityList = response;
        Constants.categoryList = popularActivityList;
        setCategoryData(popularActivityList);
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
      }
    } on NoConnectivityException catch (_) {
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      debugPrint(error.toString());
      // showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  Future<void> getConfigCall() async {
    try {
      var response = await Provider.of<DashboardViewModel>(context, listen: false).getConfig();
      if (response.cancelApplicableMinAfterEndTime >= 0) {
        isLogin = OQDOApplication.instance.storage.getStringValue(AppStrings.isLogin);
        debugPrint("isLogin Home-> $isLogin");
        if (isLogin == '1') {
          checkForUser();
        }
        setState(() {
          OQDOApplication.instance.configResponseModel = response;
          debugPrint("Config Response -> ${OQDOApplication.instance.configResponseModel!.androidVersion}");
          debugPrint("Config Response -> ${OQDOApplication.instance.configResponseModel!.equipmentDefualtExpiryDays}");
          debugPrint("Config Response -> ${OQDOApplication.instance.configResponseModel!.defaultRefCode}");
          OQDOApplication.instance.defualtRefCode = OQDOApplication.instance.configResponseModel!.defaultRefCode;
          if (Platform.isAndroid) {
            if (Constants.androidAppVersion < double.parse(OQDOApplication.instance.configResponseModel!.androidVersion)) {
              openForceUpdateDialog();
            }
          }

          if (Platform.isIOS) {
            if (Constants.iosAppVersion < double.parse(OQDOApplication.instance.configResponseModel!.iosVersion)) {
              openForceUpdateDialog();
            }
          }

          // if (Platform.isAndroid) {
          //   if (OQDOApplication.instance.configResponseModel!.androidVersion! < Constants.androidAppVersion) {
          //     openForceUpdateDialog();
          //   }
          // } else if (Platform.isIOS) {
          //   if (OQDOApplication.instance.configResponseModel!.iosVersion! != Constants.iosAppVersion) {
          //     openForceUpdateDialog();
          //   }
          // }

          debugPrint(response.toString());
        });
      }
    } on CommonException catch (error) {
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
      }
    } on NoConnectivityException catch (_) {
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } on TimeoutException catch (_) {
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    } catch (error) {
      debugPrint(error.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  void checkForUser() async {
    if (await hasNetwork()) {
      if (OQDOApplication.instance.userType == Constants.endUserType) {
        await getEndUserData();
      } else if (OQDOApplication.instance.userType == Constants.facilityType) {
        await getFacilityUserData();
      } else {
        await getCoachUserData();
      }
    } else {
      dialogOpen(context);
    }
  }

  Future<void> getEndUserData() async {
    try {
      await Provider.of<ProfileViewModel>(context, listen: false).getEndUserProfile(OQDOApplication.instance.endUserID!).then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500) {
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 401) {
            Provider.of<NotificationProvider>(context, listen: false).updateStatus(false);
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.token, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.tokenType, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.expiresIn, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.refreshToken, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.userId, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.facilityId, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.coachId, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.endUserId, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.fcmToken, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.userType, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.isLogin, value: "0");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.selectedCountryName, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.selectedCountryID, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.selectedCountryCode, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.mobileNoLength, value: "");
            Navigator.pushNamedAndRemoveUntil(context, Constants.LOCATIONCHOOSEPAGE, (route) => false);
            showSnackBarColor('Un-Authorized access. Please try to login again', context, true);
          } else if (res.statusCode == 200) {
            EndUserProfileResponseModel endUserProfileResponseModel = EndUserProfileResponseModel.fromJson(jsonDecode(res.body));
            if (endUserProfileResponseModel.firstName != null) {
              setState(() {});
            }
          } else {
            Map<String, dynamic> errorModel = jsonDecode(res.body);
            if (errorModel.containsKey('error_description')) {
              showSnackBarColor(errorModel['error_description'], context, true);
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
      debugPrint(exception.toString());
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  Future<void> getFacilityUserData() async {
    try {
      await Provider.of<ProfileViewModel>(context, listen: false).getFacilityUserProfile(OQDOApplication.instance.facilityID!).then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 401) {
            Provider.of<NotificationProvider>(context, listen: false).updateStatus(false);
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.token, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.tokenType, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.expiresIn, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.refreshToken, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.userId, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.facilityId, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.coachId, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.endUserId, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.fcmToken, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.userType, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.isLogin, value: "0");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.selectedCountryName, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.selectedCountryID, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.selectedCountryCode, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.mobileNoLength, value: "");
            Navigator.pushNamedAndRemoveUntil(context, Constants.LOCATIONCHOOSEPAGE, (route) => false);
            showSnackBarColor('Un-Authorized access. Please try to login again', context, true);
          } else if (res.statusCode == 200) {
            FacilityProfileResponse facilityProfileResponseModel = FacilityProfileResponse.fromJson(jsonDecode(res.body));
            if (facilityProfileResponseModel.facilityName != null) {
              setState(() {});
            }
          } else {
            Map<String, dynamic> errorModel = jsonDecode(res.body);
            if (errorModel.containsKey('error_description')) {
              showSnackBarColor(errorModel['error_description'], context, true);
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

  Future<void> getCoachUserData() async {
    try {
      await Provider.of<ProfileViewModel>(context, listen: false).getCoachUserProfile(OQDOApplication.instance.coachID!).then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 401) {
            Provider.of<NotificationProvider>(context, listen: false).updateStatus(false);
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.token, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.tokenType, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.expiresIn, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.refreshToken, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.userId, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.facilityId, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.coachId, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.endUserId, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.fcmToken, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.userType, value: "");
            await OQDOApplication.instance.storage.setStringValue(key: AppStrings.isLogin, value: "0");
            // await OQDOApplication.instance.storage.deleteAll();
            Navigator.pushNamedAndRemoveUntil(context, Constants.LOCATIONCHOOSEPAGE, (route) => false);
            showSnackBarColor('Un-Authorized access. Please try to login again', context, true);
          } else if (res.statusCode == 200) {
            coachProfileResponseModel = CoachProfileResponseModel.fromJson(jsonDecode(res.body));
            if (coachProfileResponseModel.firstName != null) {
              setState(() {});
            }
            debugPrint(coachProfileResponseModel.firstName);
          } else {
            Map<String, dynamic> errorModel = jsonDecode(res.body);
            if (errorModel.containsKey('error_description')) {
              showSnackBarColor(errorModel['error_description'], context, true);
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

  openForceUpdateDialog() async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => UpdatePopup(
        no: () async {
          exit(0);
        },
        yes: () async {
          if (Platform.isAndroid) {
            launchUrl(Uri.parse("https://play.google.com/store/apps/details?id=com.oqdo.oqdo_mobile_app"));
          } else if (Platform.isIOS) {
            launchUrl(Uri.parse("https://apps.apple.com/in/app/OQDO/id1641886517"));
          }
        },
      ),
    );
  }

  void setCategoryData(List<PopularSportsResponseModel> popularActivityList) {
    setState(() {
      sportsList.clear();
      wellnessList.clear();
      hobbiesList.clear();

      sportsList = popularActivityList.where((i) => i.activityName == "Sports").toList();
      wellnessList = popularActivityList.where((i) => i.activityName == "Wellness").toList();
      hobbiesList = popularActivityList.where((i) => i.activityName == "Hobbies").toList();
    });
  }

  // Use this method to handle back button press directly
  Future<bool> _onBackPressed() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to exit an App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  exit(0); // Force exit the app
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
