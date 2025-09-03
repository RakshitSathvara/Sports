import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/model/PopularSportsResponseModel.dart';
import 'package:oqdo_mobile_app/model/selecte_home_model.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:oqdo_mobile_app/viewmodels/DashboardViewModel.dart';
import 'package:provider/provider.dart';

class SelectedActivityHomeScreen extends StatefulWidget {
  SelectedHomeModel? selectedHomeModel;

  SelectedActivityHomeScreen({Key? key, this.selectedHomeModel}) : super(key: key);

  @override
  State<SelectedActivityHomeScreen> createState() => _SelectedActivityHomeScreenState();
}

class _SelectedActivityHomeScreenState extends State<SelectedActivityHomeScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<PopularSportsResponseModel> popularActivityList = [];
  String? isLogin = '';
  String? selectedSports = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // getPopularActivity();
      getPrefData();
    });
  }

  void getPrefData() async {
    isLogin = OQDOApplication.instance.storage.getStringValue(AppStrings.isLogin);
    OQDOApplication.instance.isLogin = isLogin;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: CustomAppBar(
        title: selectedSports!.isNotEmpty ? selectedSports : '${widget.selectedHomeModel!.selectedActivity} - ${widget.selectedHomeModel!.subActivities!.name}',
        onBack: () async {
          selectedSports = ' ';
          Navigator.of(context).pop();
        },
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: OQDOThemeData.whiteColor,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomTextView(
                    label: 'Book',
                    type: styleSubTitle,
                    textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 20.0,
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
                      if (OQDOApplication.instance.isLogin == '1') {
                        if (OQDOApplication.instance.userType == Constants.endUserType) {
                          await Navigator.pushNamed(context, Constants.FACILITIESLISTPAGE, arguments: widget.selectedHomeModel);
                        }
                      } else {
                        await Navigator.pushNamed(context, Constants.FACILITIESLISTPAGE, arguments: widget.selectedHomeModel);
                      }
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
                      if (OQDOApplication.instance.isLogin == '1') {
                        if (OQDOApplication.instance.userType == Constants.endUserType) {
                          await Navigator.pushNamed(context, Constants.COACHLISTPAGE, arguments: widget.selectedHomeModel);
                        }
                      } else {
                        await Navigator.pushNamed(context, Constants.COACHLISTPAGE, arguments: widget.selectedHomeModel);
                      }
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
                                        fontSize: 20.0,
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
                                    fontSize: 20.0,
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
                        ],
                      ),
                const SizedBox(
                  height: 10,
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 20),
                //   child: CustomTextView(
                //     label: 'Bazaar',
                //     type: styleSubTitle,
                //     textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                //           fontWeight: FontWeight.w700,
                //           fontSize: 20.0,
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
                  height: 24,
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 20),
                //   child: CustomTextView(
                //     label: 'Popular Sports',
                //     type: styleSubTitle,
                //     textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                //         color: OQDOThemeData.blackColor,
                //         fontSize: 20.0,
                //         fontFamily: 'Ultra',
                //         fontWeight: FontWeight.bold),
                //   ),
                // ),
                // const SizedBox(
                //   height: 10.0,
                // ),
                // popularActivityList.isNotEmpty
                //     ? Container(
                //         padding: const EdgeInsets.symmetric(horizontal: 20),
                //         child: MediaQuery.removePadding(
                //           context: context,
                //           removeTop: true,
                //           removeBottom: true,
                //           child: GridView.builder(
                //               shrinkWrap: true,
                //               itemCount: popularActivityList.length,
                //               physics: const NeverScrollableScrollPhysics(),
                //               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                //                   mainAxisSpacing: 15.0, crossAxisSpacing: 10.0, crossAxisCount: 3),
                //               itemBuilder: (context, index) {
                //                 return singlePopularSportsView(index);
                //               }),
                //         ),
                //       )
                //     : const Center(
                //         child: CircularProgressIndicator(),
                //       ),
                // const SizedBox(
                //   height: 30.0,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget singlePopularSportsView(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSports = 'Sports - ${popularActivityList[index].subActivityName}';
          widget.selectedHomeModel!.selectedActivity = 'sports';
          widget.selectedHomeModel!.subActivities!.name = popularActivityList[index].subActivityName;
          widget.selectedHomeModel!.subActivities!.subActivityId = popularActivityList[index].subActivityId;
          debugPrint('Selected id -> ${widget.selectedHomeModel!.subActivities!.subActivityId}');
        });
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
                  popularActivityList[index].thumbnailUrl!,
                  fit: BoxFit.fill,
                ),
              ),
              CustomTextView(
                label: popularActivityList[index].subActivityName!,
                type: styleSubTitle,
                textOverFlow: TextOverflow.ellipsis,
                maxLine: 1,
                textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: OQDOThemeData.blackColor, fontSize: 14, fontWeight: FontWeight.w400),
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
            width: 110,
            height: 90,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Image.asset(img),
          ),
          CustomTextView(
            label: text,
            type: styleSubTitle,
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
        setState(() {
          popularActivityList.clear();
          popularActivityList = response;
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
    } catch (error) {
      debugPrint(error.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }
}
