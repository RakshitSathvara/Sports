// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/components/favorite_toggle_button.dart';
import 'package:oqdo_mobile_app/model/CoachDetailsResponseModel.dart';
import 'package:oqdo_mobile_app/model/EndUserAddressResponseModel.dart';
import 'package:oqdo_mobile_app/model/add_facility_slot_model.dart';
import 'package:oqdo_mobile_app/model/calendar_view_model.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/screens/common_widget/facility_coach_reviews_screen.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:oqdo_mobile_app/utils/textfields_widget.dart';
import 'package:oqdo_mobile_app/viewmodels/BookingViewModel.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import '../../components/my_button.dart';
import '../../utils/constants.dart';

// ignore: must_be_immutable
class CoachDetailsScreen extends StatefulWidget {
  CoachDetailsResponseModel? coachDetailsResponseModel;

  CoachDetailsScreen({Key? key, this.coachDetailsResponseModel}) : super(key: key);

  @override
  State<CoachDetailsScreen> createState() => _CoachDetailsScreenState();
}

class _CoachDetailsScreenState extends State<CoachDetailsScreen> {
  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;
  List<AddFacilitySlotModel>? addFacilitySlotList = [];
  late ProgressDialog progressDialog;
  List<EndUserAddressResponseModel> endUserAddressList = [];
  EndUserAddressResponseModel? selectedAddress;
  CoachBatchSetupAddressDtos? coachAddress;
  bool isAddressVisible = true;
  String? isLogin = '';
  final groupSizeController = TextEditingController();
  bool isAPICalledForFavorite = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setSlots();
      isLogin = OQDOApplication.instance.storage.getStringValue(AppStrings.isLogin);
      if (isLogin == '1') {
        if (OQDOApplication.instance.userType == Constants.endUserType) {
          isAddressVisible = true;
          debugPrint('isAddressVisible -> $isAddressVisible');
        } else {
          // if (OQDOApplication.instance.userType == Constants.facilityType) {
          //   isAddressVisible = false;
          // } else {
          isAddressVisible = false;
          debugPrint('isAddressVisible -> $isAddressVisible');
          // }
        }
      } else {
        isAddressVisible = false;
        debugPrint('isAddressVisible -> $isAddressVisible');
      }
    });
    debugPrint('isLogin -> $isLogin');
  }

  void setSlots() async {
    setState(() {
      groupSizeController.text = "${widget.coachDetailsResponseModel?.maxGroupSize ?? ""}";
      for (int i = 0; i < widget.coachDetailsResponseModel!.slots!.length; i++) {
        AddFacilitySlotModel addFacilitySlotModel = AddFacilitySlotModel();
        for (int j = 0; j < widget.coachDetailsResponseModel!.slots![i].dayNos!.length; j++) {
          if (widget.coachDetailsResponseModel!.slots![i].dayNos![j] == 0) {
            addFacilitySlotModel.sunday = true;
          } else if (widget.coachDetailsResponseModel!.slots![i].dayNos![j] == 1) {
            addFacilitySlotModel.monday = true;
          } else if (widget.coachDetailsResponseModel!.slots![i].dayNos![j] == 2) {
            addFacilitySlotModel.tuesday = true;
          } else if (widget.coachDetailsResponseModel!.slots![i].dayNos![j] == 3) {
            addFacilitySlotModel.wednesday = true;
          } else if (widget.coachDetailsResponseModel!.slots![i].dayNos![j] == 4) {
            addFacilitySlotModel.thursday = true;
          } else if (widget.coachDetailsResponseModel!.slots![i].dayNos![j] == 5) {
            addFacilitySlotModel.friday = true;
          } else if (widget.coachDetailsResponseModel!.slots![i].dayNos![j] == 6) {
            addFacilitySlotModel.saturday = true;
          }
        }
        addFacilitySlotModel.selectedSlotsDayList = widget.coachDetailsResponseModel!.slots![i].dayNos;
        SlotsModel slotsModel = SlotsModel(
            widget.coachDetailsResponseModel!.slots![i].startTimeFormatted,
            widget.coachDetailsResponseModel!.slots![i].endTimeFormatted,
            widget.coachDetailsResponseModel!.slots![i].startTimeInMinute,
            widget.coachDetailsResponseModel!.slots![i].endTimeInMinute,
            widget.coachDetailsResponseModel!.slots![i].noOfSlot);
        addFacilitySlotModel.slotsModelList!.add(slotsModel);
        addFacilitySlotModel.ratePerHour = widget.coachDetailsResponseModel!.slots![i].ratePerHour;
        addFacilitySlotList!.add(addFacilitySlotModel);
      }
    });

    if (OQDOApplication.instance.isLogin == '1') {
      if (widget.coachDetailsResponseModel!.addressRequired == 'E' || widget.coachDetailsResponseModel!.addressRequired == 'EC') {
        getEndUserAddress();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Timer.periodic(const Duration(seconds: 5), (timer) {
    //   setState(() {});
    // });
    return PopScope(
      canPop: false, // Prevent default back behavior
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        if (isAPICalledForFavorite) {
          Navigator.of(context).pop(true); // Return true to trigger refresh
        } else {
          Navigator.of(context).pop(false); // Return false to prevent refresh
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
            title: '',
            onBack: () {
              if (isAPICalledForFavorite) {
                Navigator.of(context).pop(true); // Return true to trigger refresh
              } else {
                Navigator.of(context).pop(false); // Return false to prevent refresh
              }
            }),
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            color: Theme.of(context).colorScheme.onBackground,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      topView(),
                      const SizedBox(
                        height: 20.0,
                      ),
                      imageView(),
                      const SizedBox(
                        height: 20.0,
                      ),
                      descriptionView(),
                      const SizedBox(
                        height: 20,
                      ),
                      availabilityView(),
                      const SizedBox(
                        height: 20,
                      ),
                      isAddressVisible && OQDOApplication.instance.userType == Constants.endUserType
                          ? widget.coachDetailsResponseModel!.addressRequired == 'EC'
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomTextView(
                                          label: 'Trainee Venue',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(fontSize: 18, fontWeight: FontWeight.w600, color: OQDOThemeData.greyColor),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).pushNamed(Constants.endUserTrainingAddress).then((value) {
                                              if (value != null) {
                                                bool data = value as bool;
                                                if (data) {
                                                  showSnackBarColor('Address added successfully', context, false);
                                                  getEndUserAddress();
                                                }
                                              }
                                            });
                                          },
                                          child: Image.asset(
                                            "assets/images/ic_add.png",
                                            fit: BoxFit.fitWidth,
                                            height: 50,
                                            width: 50,
                                          ),
                                        ),
                                      ],
                                    ),
                                    showEndUserAddress(),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        const Expanded(
                                          child: Divider(
                                            height: 1,
                                            thickness: 1,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        CustomTextView(
                                          label: 'Or',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: OQDOThemeData.greyColor),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        const Expanded(
                                          child: Divider(
                                            height: 1,
                                            thickness: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    CustomTextView(
                                      label: 'Training Venue',
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(fontSize: 18, fontWeight: FontWeight.w600, color: OQDOThemeData.greyColor),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    isAddressVisible && OQDOApplication.instance.userType == Constants.endUserType ? showCoachAddress() : Container(),
                                  ],
                                )
                              : widget.coachDetailsResponseModel!.addressRequired == 'E'
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomTextView(
                                          label: 'Trainee Venue',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(fontSize: 18, fontWeight: FontWeight.w600, color: OQDOThemeData.greyColor),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).pushNamed(Constants.endUserTrainingAddress).then((value) {
                                              if (value != null) {
                                                bool data = value as bool;
                                                if (data) {
                                                  getEndUserAddress();
                                                }
                                              }
                                            });
                                          },
                                          child: Image.asset(
                                            "assets/images/ic_add.png",
                                            fit: BoxFit.fitWidth,
                                            height: 50,
                                            width: 50,
                                          ),
                                        ),
                                      ],
                                    )
                                  : CustomTextView(
                                      label: 'Training Venue',
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(fontSize: 18, fontWeight: FontWeight.w600, color: OQDOThemeData.greyColor),
                                    )
                          : Container(),
                      const SizedBox(
                        height: 8,
                      ),
                      isAddressVisible
                          ? widget.coachDetailsResponseModel!.addressRequired == 'E'
                              ? showEndUserAddress()
                              : widget.coachDetailsResponseModel!.addressRequired == 'C'
                                  ? widget.coachDetailsResponseModel!.coachBatchSetupAddressDtos!.isNotEmpty
                                      ? isAddressVisible && OQDOApplication.instance.userType == Constants.endUserType
                                          ? showCoachAddress()
                                          : Container()
                                      : Container()
                                  : Container()
                          : Container(),
                      const SizedBox(
                        height: 20.0,
                      ),
                      isAddressVisible
                          ? selectedAddress != null
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CustomTextView(
                                      label: 'Address ',
                                      textStyle: const TextStyle(fontSize: 16.0, color: OQDOThemeData.blackColor, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: CustomTextView(
                                        maxLine: 8,
                                        textOverFlow: TextOverflow.ellipsis,
                                        label:
                                            '${selectedAddress!.address1},${selectedAddress!.address2},${selectedAddress!.cityName} - ${selectedAddress!.pinCode}',
                                        textStyle: const TextStyle(color: OQDOThemeData.greyColor, fontSize: 15.0),
                                      ),
                                    ),
                                  ],
                                )
                              : coachAddress != null
                                  ? Row(
                                      children: [
                                        CustomTextView(
                                          label: 'Address ',
                                          textStyle: const TextStyle(fontSize: 16.0, color: OQDOThemeData.blackColor, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: CustomTextView(
                                            maxLine: 8,
                                            textOverFlow: TextOverflow.ellipsis,
                                            label: '${coachAddress!.address1},${coachAddress!.address2} - ${coachAddress!.pinCode}',
                                            textStyle: const TextStyle(color: OQDOThemeData.greyColor, fontSize: 15.0),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container()
                          : Container(),
                      const SizedBox(
                        height: 15,
                      ),
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: CustomTextView(
                      //         label: 'Contact Number',
                      //         textStyle: const TextStyle(fontSize: 16.0, color: OQDOThemeData.blackColor, fontWeight: FontWeight.bold),
                      //       ),
                      //     ),
                      //     Expanded(
                      //       child: CustomTextView(
                      //         label: widget.coachDetailsResponseModel!.mobileNumber,
                      //         textStyle: const TextStyle(color: OQDOThemeData.greyColor, fontSize: 15.0),
                      //       ),
                      //     ),
                      //     Container()
                      //   ],
                      // ),
                      // const SizedBox(
                      //   height: 10,
                      // ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextView(
                              label: 'Minimum Slot',
                              textStyle: const TextStyle(fontSize: 16.0, color: OQDOThemeData.blackColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: CustomTextView(
                              label: '${widget.coachDetailsResponseModel!.minumumSlot}',
                              textStyle: const TextStyle(color: OQDOThemeData.greyColor, fontSize: 14.0),
                            ),
                          ),
                          Container()
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextView(
                              label: 'Experience',
                              textStyle: const TextStyle(fontSize: 16.0, color: OQDOThemeData.blackColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: CustomTextView(
                              label:
                                  '${widget.coachDetailsResponseModel!.experienceYear == null ? "0" : widget.coachDetailsResponseModel!.experienceYear.toString()} years',
                              textStyle: const TextStyle(color: OQDOThemeData.greyColor, fontSize: 14.0),
                            ),
                          ),
                          Container()
                        ],
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      isLogin == '1' && OQDOApplication.instance.userType == Constants.endUserType
                          ? MyButton(
                              text: 'Book Appointment',
                              textcolor: Theme.of(context).colorScheme.onBackground,
                              textsize: 16,
                              fontWeight: FontWeight.w600,
                              letterspacing: 0.7,
                              buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                              buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                              buttonheight: 50,
                              buttonwidth: width,
                              radius: 15,
                              onTap: () async {
                                debugPrint('In first button');
                                if (isLogin == '1') {
                                  if (widget.coachDetailsResponseModel!.addressRequired == 'E') {
                                    if (selectedAddress == null) {
                                      showSnackBar('Please select address', context);
                                    } else {
                                      debugPrint('Id-> ${selectedAddress!.endUserTrainingAddressId}');
                                      CalendarViewModel calendarViewModel = CalendarViewModel(
                                          type: 'C',
                                          getFacilityByIdModel: null,
                                          selectedAddressId: selectedAddress!.endUserTrainingAddressId.toString(),
                                          coachDetailsResponseModel: widget.coachDetailsResponseModel);
                                      Navigator.of(context).pushNamed(Constants.slotManagementCaledaerScreen, arguments: calendarViewModel);
                                    }
                                  } else if (widget.coachDetailsResponseModel!.addressRequired == 'C') {
                                    if (coachAddress == null) {
                                      showSnackBar('Please select address', context);
                                    } else {
                                      CalendarViewModel calendarViewModel = CalendarViewModel(
                                          type: 'C',
                                          getFacilityByIdModel: null,
                                          selectedAddressId: null,
                                          coachDetailsResponseModel: widget.coachDetailsResponseModel);
                                      Navigator.of(context).pushNamed(Constants.slotManagementCaledaerScreen, arguments: calendarViewModel);
                                    }
                                  } else if (widget.coachDetailsResponseModel!.addressRequired == 'EC') {
                                    if (selectedAddress == null && coachAddress == null) {
                                      showSnackBar('Please select address', context);
                                    } else {
                                      if (selectedAddress != null) {
                                        CalendarViewModel calendarViewModel = CalendarViewModel(
                                            type: 'C',
                                            getFacilityByIdModel: null,
                                            selectedAddressId: selectedAddress!.endUserTrainingAddressId.toString(),
                                            coachDetailsResponseModel: widget.coachDetailsResponseModel);
                                        Navigator.of(context).pushNamed(Constants.slotManagementCaledaerScreen, arguments: calendarViewModel);
                                      } else {
                                        CalendarViewModel calendarViewModel = CalendarViewModel(
                                            type: 'C',
                                            getFacilityByIdModel: null,
                                            selectedAddressId: null,
                                            coachDetailsResponseModel: widget.coachDetailsResponseModel);
                                        Navigator.of(context).pushNamed(Constants.slotManagementCaledaerScreen, arguments: calendarViewModel);
                                      }
                                    }
                                  }
                                } else {
                                  showSnackBarColor('Please login to book appointment', context, true);
                                  Timer(const Duration(microseconds: 500), () {
                                    Navigator.of(context).pushReplacementNamed(Constants.LOGIN);
                                  });
                                }
                              },
                            )
                          : isLogin == '' || isLogin == null || isLogin == '0'
                              ? MyButton(
                                  text: 'Book Appointment',
                                  textcolor: Theme.of(context).colorScheme.onBackground,
                                  textsize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterspacing: 0.7,
                                  buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                                  buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                                  buttonheight: 50,
                                  buttonwidth: width,
                                  radius: 15,
                                  onTap: () async {
                                    debugPrint('In second button');
                                    if (isLogin == '1') {
                                      if (widget.coachDetailsResponseModel!.addressRequired == 'E') {
                                        if (selectedAddress == null) {
                                          showSnackBar('Please select address', context);
                                        } else {
                                          debugPrint('Id-> ${selectedAddress!.endUserTrainingAddressId}');
                                          CalendarViewModel calendarViewModel = CalendarViewModel(
                                              type: 'C',
                                              getFacilityByIdModel: null,
                                              selectedAddressId: selectedAddress!.endUserTrainingAddressId.toString(),
                                              coachDetailsResponseModel: widget.coachDetailsResponseModel);
                                          Navigator.of(context).pushNamed(Constants.slotManagementCaledaerScreen, arguments: calendarViewModel);
                                        }
                                      } else if (widget.coachDetailsResponseModel!.addressRequired == 'C') {
                                        if (coachAddress == null) {
                                          showSnackBar('Please select address', context);
                                        } else {
                                          CalendarViewModel calendarViewModel = CalendarViewModel(
                                              type: 'C',
                                              getFacilityByIdModel: null,
                                              selectedAddressId: null,
                                              coachDetailsResponseModel: widget.coachDetailsResponseModel);
                                          Navigator.of(context).pushNamed(Constants.slotManagementCaledaerScreen, arguments: calendarViewModel);
                                        }
                                      } else if (widget.coachDetailsResponseModel!.addressRequired == 'EC') {
                                        if (selectedAddress == null && coachAddress == null) {
                                          showSnackBar('Please select address', context);
                                        } else {
                                          if (selectedAddress != null) {
                                            CalendarViewModel calendarViewModel = CalendarViewModel(
                                                type: 'C',
                                                getFacilityByIdModel: null,
                                                selectedAddressId: selectedAddress!.endUserTrainingAddressId.toString(),
                                                coachDetailsResponseModel: widget.coachDetailsResponseModel);
                                            Navigator.of(context).pushNamed(Constants.slotManagementCaledaerScreen, arguments: calendarViewModel);
                                          } else {
                                            CalendarViewModel calendarViewModel = CalendarViewModel(
                                                type: 'C',
                                                getFacilityByIdModel: null,
                                                selectedAddressId: null,
                                                coachDetailsResponseModel: widget.coachDetailsResponseModel);
                                            Navigator.of(context).pushNamed(Constants.slotManagementCaledaerScreen, arguments: calendarViewModel);
                                          }
                                        }
                                      }
                                    } else {
                                      showSnackBarColor('Please login to book appointment', context, true);
                                      Timer(const Duration(microseconds: 500), () {
                                        Navigator.of(context).pushReplacementNamed(Constants.LOGIN);
                                      });
                                    }
                                  },
                                )
                              : Container(),
                      const SizedBox(
                        height: 40.0,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget topView() {
    return Container(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: CustomTextView(
                  maxLine: 2,
                  textOverFlow: TextOverflow.ellipsis,
                  label: '${widget.coachDetailsResponseModel!.coachName!} - ${widget.coachDetailsResponseModel!.name!}',
                  textStyle: const TextStyle(fontSize: 18.0, color: OQDOThemeData.blackColor, fontWeight: FontWeight.bold),
                ),
              ),
              // CustomTextView(
              //   maxLine: 2,
              //   textOverFlow: TextOverflow.ellipsis,
              //   label: 'Registration id: ${widget.coachDetailsResponseModel!.coachRegistoryNumber}',
              //   textStyle:
              //       const TextStyle(fontSize: 12.0, color: OQDOThemeData.greyColor, fontWeight: FontWeight.normal),
              // ),
            ],
          ),
          const SizedBox(
            height: 8.0,
          ),
          CustomTextView(
            label: 'Activities: ${widget.coachDetailsResponseModel!.activities!.name} - ${widget.coachDetailsResponseModel!.subActivities!.name}',
            textStyle: const TextStyle(fontSize: 17.0, color: OQDOThemeData.greyColor),
          ),
          const SizedBox(
            height: 8.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextView(
                label: 'From S\$ ${widget.coachDetailsResponseModel?.ratePerHour?.toStringAsFixed(2) ?? 0.00} / hour',
                textStyle: const TextStyle(fontSize: 16.0, color: OQDOThemeData.greyColor),
              ),
              Row(
                children: [
                  RatingBar.builder(
                    initialRating: widget.coachDetailsResponseModel!.averageReview!.toDouble(),
                    minRating: 0,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    ignoreGestures: true,
                    itemSize: 15,
                    tapOnlyMode: true,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 15,
                    ),
                    onRatingUpdate: (rating) {
                      debugPrint(rating.toString());
                    },
                  ),
                  const SizedBox(
                    width: 6.0,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FacilityCoachReviewScreen(coachReviewList: widget.coachDetailsResponseModel!),
                          // settings: RouteSettings(
                          //   arguments: widget.coachDetailsResponseModel!,
                          // ),
                        ),
                      );
                    },
                    child: CustomTextView(
                      label: 'Reviews',
                      textStyle: const TextStyle(fontSize: 14.0, color: OQDOThemeData.greyColor, decoration: TextDecoration.underline),
                    ),
                  )
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget imageView() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: SizedBox(
        height: 300.0,
        child: CachedNetworkImage(
          imageUrl: widget.coachDetailsResponseModel!.profileImagePath!,
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Widget descriptionView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomTextView(
              label: 'Description',
              textStyle: const TextStyle(fontSize: 16.0, color: OQDOThemeData.blackColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              width: 10,
            ),
            isLogin == '1' && (OQDOApplication.instance.userType == Constants.endUserType)
                ? FavoriteToggleButton(
                    isFavorite: widget.coachDetailsResponseModel!.isFavourite ?? false,
                    size: 35,
                    onFavoriteChanged: () {
                      addRemoveFromFavorite(widget.coachDetailsResponseModel!);
                    },
                  )
                : isLogin == '1' && (OQDOApplication.instance.userType == Constants.facilityType || OQDOApplication.instance.userType == Constants.coachType)
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
        CustomTextView(
          label:
              widget.coachDetailsResponseModel!.otherDescription.toString().length > 2 ? widget.coachDetailsResponseModel!.otherDescription : 'No description',
          maxLine: 10,
          textOverFlow: TextOverflow.ellipsis,
          textStyle: const TextStyle(fontSize: 18.0, color: OQDOThemeData.greyColor),
        ),
        const SizedBox(
          height: 25.0,
        ),
        CustomTextView(
          label: 'Note',
          textStyle: const TextStyle(fontSize: 16.0, color: OQDOThemeData.blackColor, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10.0,
        ),
        CustomTextView(
          label: "If your preferred time slot is not available here, please feel free to reach out to the Service Provider directly.",
          maxLine: 3,
          textStyle: const TextStyle(
            fontSize: 16.0,
            color: OQDOThemeData.greyColor,
          ),
        ),
      ],
    );
  }

  Future<void> addRemoveFromFavorite(CoachDetailsResponseModel model) async {
    try {
      progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      progressDialog.style(message: "Please wait..");
      await progressDialog.show();

      Map<String, dynamic> request = {"SetupId": model.coachBatchSetupId.toString(), "Flag": 'C'};

      await Provider.of<BookingViewModel>(context, listen: false).addFavorite(request).then((value) async {
        Response res = value;
        await progressDialog.hide();
        if (!mounted) return;

        if (res.statusCode == 500 || res.statusCode == 404) {
          setState(() {
            model.isFavourite = model.isFavourite;
          });
          showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
        } else if (res.statusCode == 200) {
          String response = res.body;
          if (response.isNotEmpty) {
            isAPICalledForFavorite = true;
            if (model.isFavourite!) {
              model.isFavourite = false;
            } else {
              showSnackBar('Added to Favorite', context);
              model.isFavourite = true;
            }
          } else {
            model.isFavourite = model.isFavourite;
          }
          setState(() {});
        } else {
          setState(() {
            model.isFavourite = model.isFavourite;
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
      await progressDialog.hide();
      setState(() {
        model.isFavourite = model.isFavourite;
      });
      if (!mounted) return;
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      await progressDialog.hide();
      setState(() {
        model.isFavourite = model.isFavourite;
      });
      if (!mounted) return;
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      await progressDialog.hide();
      setState(() {
        model.isFavourite = model.isFavourite;
      });
      if (!mounted) return;
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      await progressDialog.hide();
      setState(() {
        model.isFavourite = model.isFavourite;
      });
      if (!mounted) return;
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  Widget availabilityView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 1,
              child: CustomTextView(
                label: 'Coach Available for',
                textStyle: const TextStyle(color: OQDOThemeData.greyColor, fontSize: 14.0),
              ),
            ),
            Flexible(
              flex: 1,
              child: Row(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: CustomTextView(
                      label: widget.coachDetailsResponseModel!.bookingType == 'I' ? 'Individual Booking' : 'Group Booking',
                      textStyle: const TextStyle(fontSize: 16.0, color: OQDOThemeData.greyColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      widget.coachDetailsResponseModel!.bookingType == "I" ? 'assets/images/ic_individual_booking.png' : 'assets/images/ic_group_booking.png',
                      fit: BoxFit.fill,
                      width: 20,
                      height: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 1,
              child: CustomTextView(
                label: 'Slot time',
                textStyle: const TextStyle(color: OQDOThemeData.greyColor, fontSize: 14.0),
              ),
            ),
            Flexible(
              flex: 1,
              child: Align(
                alignment: Alignment.topLeft,
                child: CustomTextView(
                  label: '${widget.coachDetailsResponseModel!.slotTimeHour} Hours',
                  textStyle: const TextStyle(fontSize: 16.0, color: OQDOThemeData.greyColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 1,
              child: CustomTextView(
                label: 'Capacity',
                textStyle: const TextStyle(color: OQDOThemeData.greyColor, fontSize: 14.0),
              ),
            ),
            Flexible(
              flex: 1,
              child: Align(
                alignment: Alignment.topLeft,
                child: CustomTextView(
                  label: widget.coachDetailsResponseModel!.batchCapacity.toString(),
                  textStyle: const TextStyle(fontSize: 16.0, color: OQDOThemeData.greyColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Visibility(
          visible: widget.coachDetailsResponseModel?.bookingType == 'G',
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextFormField(
                controller: groupSizeController,
                read: true,
                enabled: false,
                obscureText: false,
                maxlines: 1,
                maxlength: 3,
                labelText: 'Max size of the group',
                validator: (value) {
                  if (value?.isEmpty ?? false) {
                    return "Required field";
                  } else if (int.parse(value ?? "0") == 0) {
                    return "Value must be greater than zero";
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
        CustomTextView(
          label: 'Slots',
          textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: OQDOThemeData.greyColor, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        slotListView(),
      ],
    );
  }

  Widget slotListView() {
    return ListView.builder(
        itemCount: addFacilitySlotList!.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          AddFacilitySlotModel addFacilitySlotModel = addFacilitySlotList![index];
          return singleSlotView(addFacilitySlotModel);
        });
  }

  Widget singleSlotView(AddFacilitySlotModel addFacilitySlotModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 4.0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: addFacilitySlotModel.sunday! ? Theme.of(context).colorScheme.primary : ColorsUtils.greyCircle,
                              child: Text(
                                'S',
                                style: TextStyle(
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    color: addFacilitySlotModel.sunday! ? Theme.of(context).colorScheme.onBackground : Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: addFacilitySlotModel.monday! ? Theme.of(context).colorScheme.primary : ColorsUtils.greyCircle,
                              child: Text(
                                'M',
                                style: TextStyle(
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    color: addFacilitySlotModel.monday! ? Theme.of(context).colorScheme.onBackground : Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: addFacilitySlotModel.tuesday! ? Theme.of(context).colorScheme.primary : ColorsUtils.greyCircle,
                              child: Text(
                                'T',
                                style: TextStyle(
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    color: addFacilitySlotModel.tuesday! ? Theme.of(context).colorScheme.onBackground : Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: addFacilitySlotModel.wednesday! ? Theme.of(context).colorScheme.primary : ColorsUtils.greyCircle,
                              child: Text(
                                'W',
                                style: TextStyle(
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    color:
                                        addFacilitySlotModel.wednesday! ? Theme.of(context).colorScheme.onBackground : Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: addFacilitySlotModel.thursday! ? Theme.of(context).colorScheme.primary : ColorsUtils.greyCircle,
                              child: Text(
                                'T',
                                style: TextStyle(
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    color: addFacilitySlotModel.thursday! ? Theme.of(context).colorScheme.onBackground : Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: addFacilitySlotModel.friday! ? Theme.of(context).colorScheme.primary : ColorsUtils.greyCircle,
                              child: Text(
                                'F',
                                style: TextStyle(
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    color: addFacilitySlotModel.friday! ? Theme.of(context).colorScheme.onBackground : Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: addFacilitySlotModel.saturday! ? Theme.of(context).colorScheme.primary : ColorsUtils.greyCircle,
                              child: Text(
                                'S',
                                style: TextStyle(
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    color: addFacilitySlotModel.saturday! ? Theme.of(context).colorScheme.onBackground : Theme.of(context).colorScheme.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: CustomTextView(
                    label: "S\$ ${addFacilitySlotModel.ratePerHour?.toStringAsFixed(2) ?? 0}/hour",
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                        ),
                    maxLine: 4,
                    textOverFlow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22.0, 8, 18, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // const SizedBox(width: 10),
                    CustomTextView(
                      label: "Start Time",
                      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                          ),
                    ),
                    // const SizedBox(
                    //   width: 100,
                    // ),
                    Padding(
                      padding: const EdgeInsets.only(left: 0.0),
                      child: CustomTextView(
                        label: "End Time",
                        textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 14,
                            ),
                      ),
                    ),
                    const SizedBox(
                      width: 48,
                    ),
                    // CustomTextView(
                    //   label: "S\$ ${addFacilitySlotModel.ratePerHour?.toStringAsFixed(2) ?? 0}/hour",
                    //   textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    //         color: Theme.of(context).colorScheme.onSurface,
                    //         fontSize: 14,
                    //       ),
                    // ),
                  ],
                ),
              ),
              createTimeSlotList(addFacilitySlotModel.slotsModelList),
            ],
          ),
        ),
      ),
    );
  }

  createTimeSlotList(List<SlotsModel>? slotList) {
    return ListView.separated(
      key: UniqueKey(),
      shrinkWrap: true,
      primary: false,
      itemBuilder: (context, position) {
        SlotsModel slotModel = slotList![position];
        return createTimeSlotListItem(context, slotModel);
      },
      itemCount: slotList!.length,
      separatorBuilder: (context, position) {
        return const Divider(
          indent: 16, // empty space to the leading edge of divider.
          endIndent: 16,
        );
      },
    );
  }

  createTimeSlotListItem(BuildContext ctx, SlotsModel slotsModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 10),
                CustomTextView(
                    label: slotsModel.startTime.toString(),
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
                const SizedBox(
                  width: 50,
                ),
                SizedBox(
                  height: 15,
                  child: ImageIcon(
                    const AssetImage("assets/images/arrow_right.png"),
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(
                  width: 50,
                ),
                CustomTextView(
                    label: slotsModel.endTime.toString(),
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 8, 0),
            child: Text("${slotsModel.slots} Slots",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    )),
          ),
        ],
      ),
    );
  }

  Future<void> getEndUserAddress() async {
    try {
      progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      progressDialog.style(message: "Please wait..");
      await progressDialog.show();
      await Provider.of<BookingViewModel>(context, listen: false).getEndUserAddress(OQDOApplication.instance.endUserID!).then((value) async {
        Response res = value;
        await progressDialog.hide();
        if (res.statusCode == 500 || res.statusCode == 404) {
          showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
        } else if (res.statusCode == 200) {
          List body = jsonDecode(res.body);
          List<EndUserAddressResponseModel> list = [];
          for (int i = 0; i < body.length; i++) {
            EndUserAddressResponseModel endUserAddressResponseModel = EndUserAddressResponseModel.fromJson(body[i]);
            list.add(endUserAddressResponseModel);
          }
          if (list.isNotEmpty) {
            setState(() {
              endUserAddressList.clear();
              endUserAddressList = list;
              // selectedAddress = endUserAddressList.last;
            });
          }
        } else {
          Map<String, dynamic> errorModel = jsonDecode(res.body);
          if (errorModel.containsKey('error_description')) {
            showSnackBarColor(errorModel['error_description'], context, true);
          }
        }
      });
    } on NoConnectivityException catch (_) {
      await progressDialog.hide();
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      await progressDialog.hide();
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      await progressDialog.hide();
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      await progressDialog.hide();
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  Widget showEndUserAddress() {
    return endUserAddressList.isNotEmpty
        ? Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
              borderRadius: BorderRadius.circular(15),
              color: Theme.of(context).colorScheme.onBackground,
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: DropdownButton<dynamic>(
                  isExpanded: true,
                  underline: const SizedBox(),
                  borderRadius: BorderRadius.circular(15),
                  dropdownColor: Theme.of(context).colorScheme.onBackground,
                  hint: Text(
                    "Select One",
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.primaryContainer),
                  ),
                  value: selectedAddress,
                  items: endUserAddressList.map((address) {
                    return DropdownMenuItem(
                      value: address,
                      child: CustomTextView(label: address.addressName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedAddress = value;
                      coachAddress = null;
                      debugPrint(selectedAddress!.endUserTrainingAddressId.toString());
                    });
                  }),
            ),
          )
        : CustomTextView(
            label: 'Address not available',
            textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 16, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w400),
          );
  }

  Widget showCoachAddress() {
    return widget.coachDetailsResponseModel!.coachBatchSetupAddressDtos!.isNotEmpty
        ? Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
              borderRadius: BorderRadius.circular(15),
              color: Theme.of(context).colorScheme.onBackground,
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: DropdownButton<dynamic>(
                  isExpanded: true,
                  underline: const SizedBox(),
                  borderRadius: BorderRadius.circular(15),
                  dropdownColor: Theme.of(context).colorScheme.onBackground,
                  hint: Text(
                    "Select One",
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.primaryContainer),
                  ),
                  value: coachAddress,
                  items: widget.coachDetailsResponseModel!.coachBatchSetupAddressDtos!.map((address) {
                    return DropdownMenuItem(
                      value: address,
                      child: CustomTextView(label: address.addressName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      coachAddress = value;
                      selectedAddress = null;
                      debugPrint(coachAddress!.addressId.toString());
                    });
                  }),
            ),
          )
        : CustomTextView(
            label: 'Address not available',
            textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 16, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w400),
          );
  }
}
