// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/components/favorite_toggle_button.dart';
import 'package:oqdo_mobile_app/model/GetFacilityByIdModel.dart';
import 'package:oqdo_mobile_app/model/add_facility_slot_model.dart';
import 'package:oqdo_mobile_app/model/calendar_view_model.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/screens/common_widget/facility_review_screen.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:oqdo_mobile_app/utils/textfields_widget.dart';
import 'package:oqdo_mobile_app/viewmodels/BookingViewModel.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';

import '../../components/my_button.dart';
import '../../theme/oqdo_theme_data.dart';
import '../../utils/custom_text_view.dart';

class FacilityDetailsScreen extends StatefulWidget {
  GetFacilityByIdModel? getFacilityByIdModel;

  FacilityDetailsScreen({Key? key, this.getFacilityByIdModel}) : super(key: key);

  @override
  State<FacilityDetailsScreen> createState() => _FacilityDetailsScreenState();
}

class _FacilityDetailsScreenState extends State<FacilityDetailsScreen> {
  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;
  List<AddFacilitySlotModel>? addFacilitySlotList = [];
  int _currentIndex = 0;
  final CarouselSliderController _controller = CarouselSliderController();
  final groupSizeController = TextEditingController();

  GetFacilityByIdModel? getFacilityByIdModel;
  String? isLogin = '';

  late ProgressDialog progressDialog;
  bool isAPICalledForFavorite = false;

  @override
  void initState() {
    super.initState();

    getFacilityByIdModel = widget.getFacilityByIdModel;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setSlots();
    });
  }

  void setSlots() async {
    groupSizeController.text = "${widget.getFacilityByIdModel?.maxGroupSize ?? ""}";
    for (int i = 0; i < widget.getFacilityByIdModel!.slots!.length; i++) {
      AddFacilitySlotModel addFacilitySlotModel = AddFacilitySlotModel();
      for (int j = 0; j < widget.getFacilityByIdModel!.slots![i].dayNos!.length; j++) {
        if (widget.getFacilityByIdModel!.slots![i].dayNos![j] == 0) {
          addFacilitySlotModel.sunday = true;
        } else if (widget.getFacilityByIdModel!.slots![i].dayNos![j] == 1) {
          addFacilitySlotModel.monday = true;
        } else if (widget.getFacilityByIdModel!.slots![i].dayNos![j] == 2) {
          addFacilitySlotModel.tuesday = true;
        } else if (widget.getFacilityByIdModel!.slots![i].dayNos![j] == 3) {
          addFacilitySlotModel.wednesday = true;
        } else if (widget.getFacilityByIdModel!.slots![i].dayNos![j] == 4) {
          addFacilitySlotModel.thursday = true;
        } else if (widget.getFacilityByIdModel!.slots![i].dayNos![j] == 5) {
          addFacilitySlotModel.friday = true;
        } else if (widget.getFacilityByIdModel!.slots![i].dayNos![j] == 6) {
          addFacilitySlotModel.saturday = true;
        }
      }
      addFacilitySlotModel.selectedSlotsDayList = widget.getFacilityByIdModel!.slots![i].dayNos;
      SlotsModel slotsModel = SlotsModel(
        widget.getFacilityByIdModel!.slots![i].startTimeFormatted,
        widget.getFacilityByIdModel!.slots![i].endTimeFormatted,
        widget.getFacilityByIdModel!.slots![i].startTimeInMinute,
        widget.getFacilityByIdModel!.slots![i].endTimeInMinute,
        widget.getFacilityByIdModel!.slots![i].noOfSlot,
      );
      addFacilitySlotModel.slotsModelList!.add(slotsModel);
      addFacilitySlotModel.ratePerHour = widget.getFacilityByIdModel!.slots![i].ratePerHour;
      addFacilitySlotList!.add(addFacilitySlotModel);
    }
    isLogin = OQDOApplication.instance.storage.getStringValue(AppStrings.isLogin);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
            child: SingleChildScrollView(
              child: Column(
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
                    height: 40.0,
                  ),
                  isLogin == '1'
                      ? OQDOApplication.instance.userType == Constants.endUserType
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              child: MyButton(
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
                                  if (isLogin == '1') {
                                    CalendarViewModel calendarViewModel =
                                        CalendarViewModel(type: 'F', getFacilityByIdModel: widget.getFacilityByIdModel, coachDetailsResponseModel: null);
                                    Navigator.of(context).pushNamed(Constants.slotManagementCaledaerScreen, arguments: calendarViewModel);
                                  } else {
                                    showSnackBarColor('Please login to book appointment', context, true);
                                    Timer(const Duration(microseconds: 500), () {
                                      Navigator.of(context).pushReplacementNamed(Constants.LOGIN);
                                    });
                                  }
                                },
                              ),
                            )
                          : Container()
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: MyButton(
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
                              if (isLogin == '1') {
                                CalendarViewModel calendarViewModel =
                                    CalendarViewModel(type: 'F', getFacilityByIdModel: widget.getFacilityByIdModel, coachDetailsResponseModel: null);
                                Navigator.of(context).pushNamed(Constants.slotManagementCaledaerScreen, arguments: calendarViewModel);
                              } else {
                                showSnackBarColor('Please login to book appointment', context, true);
                                Timer(const Duration(microseconds: 500), () {
                                  Navigator.of(context).pushReplacementNamed(Constants.LOGIN);
                                });
                              }
                            },
                          ),
                        )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget topView() {
    debugPrint(widget.getFacilityByIdModel?.title);
    return Container(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextView(
            label: widget.getFacilityByIdModel!.title,
            maxLine: 2,
            textOverFlow: TextOverflow.ellipsis,
            textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 18.0, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w800),
          ),
          const SizedBox(
            height: 8.0,
          ),
          CustomTextView(
            label: '${widget.getFacilityByIdModel!.subTitle}',
            maxLine: 3,
            textOverFlow: TextOverflow.ellipsis,
            textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w400, fontSize: 18.0, color: OQDOThemeData.greyColor),
          ),
          const SizedBox(
            height: 8.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextView(
                label: 'From S\$ ${widget.getFacilityByIdModel?.ratePerHour?.toStringAsFixed(2) ?? 0.00} / hour',
                textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 14.0, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
              ),
              Row(
                children: [
                  RatingBar.builder(
                    initialRating: widget.getFacilityByIdModel!.averageReview!,
                    minRating: 1,
                    ignoreGestures: true,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 15,
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
                          builder: (context) => FacilityReviewScreen(getFacilityByIdModel: widget.getFacilityByIdModel!),
                        ),
                      );
                    },
                    child: CustomTextView(
                      label: 'Reviews',
                      textStyle: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(fontSize: 12.0, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor, decoration: TextDecoration.underline),
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
    List<Widget> images = widget.getFacilityByIdModel!.facilitySetupImages!
        .map(
          (image) => Container(
            margin: const EdgeInsets.all(5),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(5.0),
              ),
              child: CachedNetworkImage(
                imageUrl: image.filePath!,
                fit: BoxFit.fill,
              ),
            ),
          ),
        )
        .toList();
    debugPrint(images.length.toString());
    return SizedBox(
      height: 350,
      child: Column(
        children: [
          Expanded(
            child: CarouselSlider(
              items: images,
              options: CarouselOptions(
                  autoPlay: false,
                  reverse: false,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  }),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: images.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => _controller.animateToPage(entry.key),
                child: Container(
                  width: 12.0,
                  height: 12.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(_currentIndex == entry.key ? 0.9 : 0.4)),
                ),
              );
            }).toList(),
          ),
        ],
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
                    isFavorite: widget.getFacilityByIdModel!.isFavourite ?? false,
                    size: 35,
                    onFavoriteChanged: () {
                      addRemoveFromFavorite(widget.getFacilityByIdModel!);
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
          label: widget.getFacilityByIdModel!.description,
          maxLine: 10,
          textOverFlow: TextOverflow.ellipsis,
          textStyle: const TextStyle(fontSize: 16.0, color: OQDOThemeData.greyColor),
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
        const SizedBox(
          height: 25.0,
        ),
        CustomTextView(
          label: 'Availability',
          textStyle: const TextStyle(fontSize: 16.0, color: OQDOThemeData.greyColor, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 20.0,
        ),
        availabilityView(),
      ],
    );
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
                label: 'Facility Available for',
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
                      label: widget.getFacilityByIdModel!.bookingType == 'I' ? 'Individual Booking' : 'Group Booking',
                      textStyle: const TextStyle(fontSize: 16.0, color: OQDOThemeData.greyColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      widget.getFacilityByIdModel!.bookingType == "I" ? 'assets/images/ic_individual_booking.png' : 'assets/images/ic_group_booking.png',
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
                  label: '${widget.getFacilityByIdModel!.slotTimeHour} Hours',
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
                  label: widget.getFacilityByIdModel!.facilityCapacity.toString(),
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
          visible: widget.getFacilityByIdModel?.bookingType == 'G',
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
        const SizedBox(
          height: 20.0,
        ),
        Row(
          children: [
            Expanded(
              child: CustomTextView(
                label: 'Address',
                textStyle: const TextStyle(fontSize: 16.0, color: OQDOThemeData.blackColor, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: CustomTextView(
                label: widget.getFacilityByIdModel!.address,
                maxLine: 8,
                textOverFlow: TextOverflow.ellipsis,
                textStyle: const TextStyle(color: OQDOThemeData.greyColor, fontSize: 16.0),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        Row(
          children: [
            Expanded(
              child: CustomTextView(
                label: 'Contact Number',
                textStyle: const TextStyle(fontSize: 16.0, color: OQDOThemeData.blackColor, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: CustomTextView(
                label: widget.getFacilityByIdModel!.mobileNumber,
                textStyle: const TextStyle(color: OQDOThemeData.greyColor, fontSize: 16.0),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
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
                padding: const EdgeInsets.fromLTRB(20.0, 8, 18, 8),
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
                    //   label: "S\$ ${addFacilitySlotModel.ratePerHour?.toStringAsFixed(2) ?? 0.00}/hour",
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

  Future<void> addRemoveFromFavorite(GetFacilityByIdModel model) async {
    try {
      progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      progressDialog.style(message: "Please wait..");
      await progressDialog.show();

      Map<String, dynamic> request = {"SetupId": model.facilitySetupId.toString(), "Flag": 'F'};
      await Provider.of<BookingViewModel>(context, listen: false).addFavorite(request).then((value) async {
        Response res = value;
        if (!mounted) return;

        if (res.statusCode == 500 || res.statusCode == 404) {
          await progressDialog.hide();
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
          await progressDialog.hide();
          setState(() {});
        } else {
          await progressDialog.hide();
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
}
