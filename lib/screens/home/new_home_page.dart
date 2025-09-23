import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/helper/helpers.dart';
import 'package:oqdo_mobile_app/model/coach_profile_response.dart';
import 'package:oqdo_mobile_app/model/end_user_profile_response.dart';
import 'package:oqdo_mobile_app/model/facility_profile_response.dart';
import 'package:oqdo_mobile_app/model/selecte_home_model.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/screens/home/tools_card_view.dart';
import 'package:oqdo_mobile_app/screens/home/widget/community_view.dart';
import 'package:oqdo_mobile_app/screens/profile/learner_profile.dart';
import 'package:oqdo_mobile_app/theme/custom_colors.dart';
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

class NewHomePage extends StatefulWidget {
  const NewHomePage({super.key});

  @override
  State<NewHomePage> createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage> with WidgetsBindingObserver {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).extension<CustomColors>()!.appBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _firstSection(context),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: _secondSection(),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: OQDOApplication.instance.isLogin == '1'
                  ? OQDOApplication.instance.userType == Constants.endUserType
                      ? _getTools(context)
                      : _getToolsServiceProvider(context)
                  : _getTools(context),
            ),
            const SizedBox(height: 10),
            _pastedImageView(context),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: const Text(
                'Community',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: OQDOApplication.instance.isLogin == '1'
                  ? OQDOApplication.instance.userType == Constants.endUserType
                      ? _communityEndUserSection()
                      : _communityServiceProviderSection()
                  : _communityEndUserSection(),
            ),
            const SizedBox(height: 30),
            OQDOApplication.instance.isLogin == '1'
                ? OQDOApplication.instance.userType == Constants.coachType
                    ? Column(
                        children: [
                          _promoteBusinessSection(),
                          const SizedBox(height: 40),
                        ],
                      )
                    : OQDOApplication.instance.userType == Constants.facilityType
                        ? Column(
                            children: [
                              _promoteBusinessSection(),
                              const SizedBox(height: 40),
                            ],
                          )
                        : const SizedBox.shrink()
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _promoteBusinessSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).extension<CustomColors>()!.homeScreenRewardBgColor.withAlpha(10),
        border: Border.all(color: Theme.of(context).extension<CustomColors>()!.promoteBusinessBorderColor, width: 1),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/ic_promote.png',
            height: 36,
            width: 36,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Promote Your Business',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  color: Theme.of(context).extension<CustomColors>()!.blackAndWhiteColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Get your message in front of thousands of potential customers.',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Inter',
                  color: Theme.of(context).extension<CustomColors>()!.blackAndWhiteColor,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _firstSection(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/images/new_home_page.jpg'), // Replace with your image
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.6),
            ],
          ),
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your world of Sports, Hobbies\nand Wellness!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Book a coach or a venue, organise sporting activities & hobbies',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.3,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () async {
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
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'My Bookings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _secondSection() {
    return SizedBox(
      height: 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(Constants.homeScreenActivitySelectionScreen, arguments: HomeScreenSelection.Sports.name);
              },
              child: Image.asset(
                'assets/images/new_home_sport.png',
                height: 80,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(Constants.homeScreenActivitySelectionScreen, arguments: HomeScreenSelection.Hobbies.name);
            },
            child: Image.asset(
              'assets/images/new_home_hobbies.png',
              height: 80,
            ),
          ),
          Expanded(
              child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(Constants.homeScreenActivitySelectionScreen, arguments: HomeScreenSelection.Wellness.name);
            },
            child: Image.asset('assets/images/new_home_wellness.png', height: 80),
          )),
        ],
      ),
    );
  }

  Widget _getTools(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Get Moving',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
            color: Theme.of(context).extension<CustomColors>()!.getMovingTextColor,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ToolsCard(
                title: 'Book a Coach',
                subtitle: 'Expert guidance',
                imagePath: 'assets/images/ic_book_coach.png',
                backgroundColor: Theme.of(context).extension<CustomColors>()!.coachToolsBg,
                textColor: Theme.of(context).extension<CustomColors>()!.blackAndWhiteColor,
                subtitleColor: Theme.of(context).extension<CustomColors>()!.greyText,
                onTap: () => handleBookCoach(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolsCard(
                title: 'Book a Venue',
                subtitle: "Find your space",
                imagePath: 'assets/images/ic_book_facility.png',
                backgroundColor: Theme.of(context).extension<CustomColors>()!.coachToolsBg,
                textColor: Theme.of(context).extension<CustomColors>()!.blackAndWhiteColor,
                subtitleColor: Theme.of(context).extension<CustomColors>()!.greyText,
                onTap: () => handleBookVenue(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _getToolsServiceProvider(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Get Moving',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
            color: Theme.of(context).extension<CustomColors>()!.getMovingTextColor,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ToolsCard(
                title: OQDOApplication.instance.userType == Constants.coachType ? 'Create Batch' : 'Setup Facility',
                subtitle: OQDOApplication.instance.userType == Constants.coachType ? 'Coaching schedule' : 'Configure venues',
                imagePath: OQDOApplication.instance.userType == Constants.coachType ? 'assets/images/ic_batch.png' : 'assets/images/ic_facility.png',
                backgroundColor: Theme.of(context).extension<CustomColors>()!.coachToolsBg,
                textColor: Theme.of(context).extension<CustomColors>()!.blackAndWhiteColor,
                subtitleColor: Theme.of(context).extension<CustomColors>()!.greyText,
                onTap: () => handleBookCoach(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolsCard(
                title: OQDOApplication.instance.userType == Constants.coachType ? 'Appointments' : 'Bookings',
                subtitle: OQDOApplication.instance.userType == Constants.coachType ? "Today's sessions" : 'Manage reservations',
                imagePath: OQDOApplication.instance.userType == Constants.coachType ? 'assets/images/ic_appointment.png' : 'assets/images/ic_bookings.png',
                backgroundColor: Theme.of(context).extension<CustomColors>()!.coachToolsBg,
                textColor: Theme.of(context).extension<CustomColors>()!.blackAndWhiteColor,
                subtitleColor: Theme.of(context).extension<CustomColors>()!.greyText,
                onTap: () => handleBookVenue(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ToolsCard(
                title: OQDOApplication.instance.userType == Constants.coachType ? 'Set Vacation' : 'Maintenance',
                subtitle: OQDOApplication.instance.userType == Constants.coachType ? 'Block time off' : 'Schedule downtime',
                imagePath: OQDOApplication.instance.userType == Constants.coachType ? 'assets/images/ic_vacation.png' : 'assets/images/ic_maintenance.png',
                backgroundColor: Theme.of(context).extension<CustomColors>()!.coachToolsBg,
                textColor: Theme.of(context).extension<CustomColors>()!.blackAndWhiteColor,
                subtitleColor: Theme.of(context).extension<CustomColors>()!.greyText,
                onTap: () => handleBookCoach(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolsCard(
                title: 'Cancellations',
                subtitle: OQDOApplication.instance.userType == Constants.coachType ? "Review requests" : 'Handle requests',
                imagePath: 'assets/images/ic_cancellation.png',
                backgroundColor: Theme.of(context).extension<CustomColors>()!.coachToolsBg,
                textColor: Theme.of(context).extension<CustomColors>()!.blackAndWhiteColor,
                subtitleColor: Theme.of(context).extension<CustomColors>()!.greyText,
                onTap: () => handleBookVenue(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void handleBookCoach(BuildContext context) {
    SelectedHomeModel selectedHomeModel = SelectedHomeModel();
    Navigator.pushNamed(context, Constants.COACHLISTPAGE, arguments: selectedHomeModel);
  }

  void handleBookVenue(BuildContext context) {
    SelectedHomeModel selectedHomeModel = SelectedHomeModel();
    Navigator.pushNamed(context, Constants.FACILITIESLISTPAGE, arguments: selectedHomeModel);
  }

  Widget _pastedImageView(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Container(
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0),
        color: customColors.homeScreenRewardBgColor.withAlpha(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset('assets/images/reward.png', height: 24, width: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Unlock Exclusive Rewards!',
                    style: TextStyle(
                      color: customColors.homeScreenRewardTextColor,
                      fontSize: 18,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Invite friends to join our community and start earning',
                style: TextStyle(
                  color: customColors.blackAndWhiteColor,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                if (OQDOApplication.instance.isLogin == '1') {
                  await Navigator.pushNamedAndRemoveUntil(context, Constants.APPPAGES, Helper.of(context).predicate, arguments: 4);
                } else {
                  showSnackBarColor('Please login', context, true);
                  Timer(const Duration(microseconds: 500), () {
                    Navigator.of(context).pushNamed(Constants.LOGIN);
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: customColors.homeScreenRewardButtonColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Refer Now',
                  style: TextStyle(
                    color: customColors.homeScreenRewardButtonTextColor,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _communityEndUserSection() {
    return SizedBox(
      height: 450,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: CommunityCard(
                    icon: 'assets/images/ic_find_friend.png',
                    title: "Find Friends",
                    subtitle: "Connect with like-minded people",
                    onTap: () async {
                      if (OQDOApplication.instance.isLogin == '1') {
                        Navigator.of(context).pushNamed(Constants.searchBuddiesScreen);
                      } else {
                        showSnackBarColor('Please login', context, true);
                        Timer(const Duration(microseconds: 500), () {
                          Navigator.of(context).pushNamed(Constants.LOGIN);
                        });
                      }
                    },
                    backgroundColor: Theme.of(context).extension<CustomColors>()!.coachToolsBg,
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: CommunityCard(
                    icon: 'assets/images/ic_your_group.png',
                    title: "Your Groups",
                    subtitle: "See your sports and hobby groups",
                    onTap: () async {
                      if (OQDOApplication.instance.isLogin == '1') {
                        Navigator.of(context).pushNamed(Constants.groupListScreen);
                      } else {
                        showSnackBarColor('Please login', context, true);
                        Timer(const Duration(microseconds: 500), () {
                          Navigator.of(context).pushNamed(Constants.LOGIN);
                        });
                      }
                    },
                    backgroundColor: Theme.of(context).extension<CustomColors>()!.coachToolsBg,
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: CommunityCard(
                    icon: 'assets/images/ic_join_meetup.png',
                    title: "Join Meetup",
                    subtitle: "See your meetup events",
                    onTap: () async {
                      if (OQDOApplication.instance.isLogin == '1') {
                        Navigator.of(context).pushNamed(Constants.listMeetup, arguments: DateTime.now());
                      } else {
                        showSnackBarColor('Please login', context, true);
                        Timer(const Duration(microseconds: 500), () {
                          Navigator.of(context).pushNamed(Constants.LOGIN);
                        });
                      }
                    },
                    backgroundColor: Theme.of(context).extension<CustomColors>()!.coachToolsBg,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: CommunityCard(
                    icon: 'assets/images/ic_bazaar_sell.png',
                    title: "Bazaar Sell",
                    subtitle: "Sell your equipment",
                    onTap: () {
                      if (OQDOApplication.instance.isLogin == '1') {
                        Navigator.of(context).pushNamed(Constants.bazaarHomeScreen, arguments: 1);
                      } else {
                        showSnackBarColor('Please login', context, true);
                        Timer(const Duration(microseconds: 500), () {
                          Navigator.of(context).pushNamed(Constants.LOGIN);
                        });
                      }
                    },
                    backgroundColor: Theme.of(context).extension<CustomColors>()!.coachToolsBg,
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: CommunityCard(
                    icon: 'assets/images/ic_bazaar_buy.png',
                    title: "Bazaar Buy",
                    subtitle: "Purchase equipment",
                    onTap: () {
                      if (OQDOApplication.instance.isLogin == '1') {
                        Navigator.of(context).pushNamed(Constants.bazaarHomeScreen, arguments: 2);
                      } else {
                        showSnackBarColor('Please login', context, true);
                        Timer(const Duration(microseconds: 500), () {
                          Navigator.of(context).pushNamed(Constants.LOGIN);
                        });
                      }
                    },
                    backgroundColor: Theme.of(context).extension<CustomColors>()!.coachToolsBg,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _communityServiceProviderSection() {
    return SizedBox(
      height: 350,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: CommunityCard(
                    icon: 'assets/images/ic_bazaar_sell.png',
                    title: "Bazaar Sell",
                    subtitle: "Sell your equipment",
                    onTap: () {
                      if (OQDOApplication.instance.isLogin == '1') {
                        Navigator.of(context).pushNamed(Constants.bazaarHomeScreen, arguments: 1);
                      } else {
                        showSnackBarColor('Please login', context, true);
                        Timer(const Duration(microseconds: 500), () {
                          Navigator.of(context).pushNamed(Constants.LOGIN);
                        });
                      }
                    },
                    backgroundColor: Theme.of(context).extension<CustomColors>()!.coachToolsBg,
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: CommunityCard(
                    icon: 'assets/images/ic_local_venues.png',
                    title: " Local Venues",
                    subtitle: "See what various facilities\nare offering in your area.",
                    onTap: () async {
                      SelectedHomeModel selectedHomeModel = SelectedHomeModel();
                      await Navigator.pushNamed(context, Constants.FACILITIESLISTPAGE, arguments: selectedHomeModel);
                    },
                    backgroundColor: Theme.of(context).extension<CustomColors>()!.coachToolsBg,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: CommunityCard(
                    icon: 'assets/images/ic_bazaar_buy.png',
                    title: "Bazaar Buy",
                    subtitle: "Purchase equipment",
                    onTap: () {
                      if (OQDOApplication.instance.isLogin == '1') {
                        Navigator.of(context).pushNamed(Constants.bazaarHomeScreen, arguments: 2);
                      } else {
                        showSnackBarColor('Please login', context, true);
                        Timer(const Duration(microseconds: 500), () {
                          Navigator.of(context).pushNamed(Constants.LOGIN);
                        });
                      }
                    },
                    backgroundColor: Theme.of(context).extension<CustomColors>()!.coachToolsBg,
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: CommunityCard(
                    icon: 'assets/images/ic_browse_coach.png',
                    title: "Browse Coaches",
                    subtitle: "See how coaches are\nbuilding their practice.",
                    onTap: () async {
                      SelectedHomeModel selectedHomeModel = SelectedHomeModel();
                      await Navigator.pushNamed(context, Constants.COACHLISTPAGE, arguments: selectedHomeModel);
                    },
                    backgroundColor: Theme.of(context).extension<CustomColors>()!.coachToolsBg,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void getPrefData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      isLogin = OQDOApplication.instance.storage.getStringValue(AppStrings.isLogin);
      selectedCountry = OQDOApplication.instance.storage.getStringValue(AppStrings.selectedCountryName);

      OQDOApplication.instance.isLogin = isLogin;
      if (await hasNetwork()) {
        getConfigCall();
      } else {
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
              Icon(
                Icons.network_check_rounded,
                color: Theme.of(mContext).colorScheme.error,
                size: 100.0,
              ),
              const SizedBox(height: 10.0),
              CustomTextView(
                maxLine: 4,
                textOverFlow: TextOverflow.ellipsis,
                label: "Slow or No Internet.",
                textStyle: Theme.of(mContext).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(mContext).colorScheme.onSurface,
                      fontSize: 20,
                    ),
              ),
              const SizedBox(height: 10.0),
              Text(
                "Please check your internet settings",
                textAlign: TextAlign.center,
                maxLines: 4,
                style: Theme.of(mContext).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(mContext).colorScheme.onSurface,
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
                Icon(
                  Icons.network_check_rounded,
                  color: Theme.of(mContext).colorScheme.error,
                  size: 100.0,
                ),
                const SizedBox(height: 10.0),
                CustomTextView(
                  maxLine: 4,
                  textOverFlow: TextOverflow.ellipsis,
                  label: "Slow or No Internet.",
                  textStyle: Theme.of(mContext).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(mContext).colorScheme.onSurface,
                        fontSize: 20,
                      ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  "Please check your internet settings",
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  style: Theme.of(mContext).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(mContext).colorScheme.onSurface,
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
}
