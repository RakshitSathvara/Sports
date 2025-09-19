import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_button.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/models/facility_preview_model.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/view/widgets/base_container.dart';
import 'package:oqdo_mobile_app/theme/custom_colors.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';

class FacilityTrainingPreviewPage extends StatelessWidget {
  static const String routeName = '/facility_training_preview_page';

  const FacilityTrainingPreviewPage({super.key, required this.facilityDetails});

  final FacilityPreviewModel facilityDetails;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Training Preview",
          style: TextStyle(
            color: customColors.chipText,
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTrainingPreviewCard(context),
              const SizedBox(height: 20.0),
              _buildAddressAndContactInfo(context),
              const SizedBox(height: 20.0),
              _buildAvailableBookingSlotsView(context),
              const SizedBox(height: 20.0),
              _buildFacilityDescription(context),
              const SizedBox(height: 20.0),
              _buildGoToListViewButton(context),
              const SizedBox(height: 20.0),
              _buildBottomText(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrainingPreviewCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return BaseContainer(
      borderColor: colorScheme.primary,
      bgColor: customColors.selectedGridItemColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            facilityDetails.title,
            style: TextStyle(
              fontFamily: 'Inter',
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            facilityDetails.subTitle,
            style: TextStyle(
              fontFamily: 'Inter',
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  "${facilityDetails.activity} > ${facilityDetails.subActivity}",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: customColors.chipText,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: facilityDetails.isPrivateRental ? customColors.green : customColors.darkRed,
                ),
                child: Text(
                  facilityDetails.isPrivateRental ? 'Shared Rental' : 'Private Rental',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: customColors.onAccentText,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.access_time, size: 20, color: customColors.chipText),
                    SizedBox(width: 5),
                    Text(
                      '${facilityDetails.slotDuration} slots',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        color: customColors.chipText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 15.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/ic_dollar_rounded.png",
                      height: 20,
                      width: 20,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'From ${parseDoubleToRoundString(facilityDetails.slotRate)}/hr',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        color: customColors.chipText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 15.0),
                if (facilityDetails.isPrivateRental)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/ic_persons.png",
                        height: 20,
                        width: 20,
                      ),
                      SizedBox(width: 5),
                      Text(
                        '${facilityDetails.maxCapacityOrGroupSize} max capacity',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          color: customColors.chipText,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressAndContactInfo(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return BaseContainer(
      borderColor: customColors.borderColor,
      bgColor: customColors.buttonBg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  OQDOApplication.instance.userName ?? "",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Address",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Venue address will be provided after booking",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Contact Number",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  OQDOApplication.instance.phone ?? "",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableBookingSlotsView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return BaseContainer(
      borderColor: customColors.borderColor,
      bgColor: customColors.containerBG,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Available Booking Slots",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  itemCount: facilityDetails.slotsList.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final slotDetails = facilityDetails.slotsList[index];
                    return BaseContainer(
                      bgColor: customColors.buttonBg,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: slotDetails.sortedSelectedDays.map((day) {
                                          return Container(
                                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20.0),
                                              color: customColors.containerBG,
                                            ),
                                            child: Text(
                                              day.title,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: colorScheme.onSurface,
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  // slotDetails.getAccurateTimeRange(facilityDetails.rentalDurationInMinutes),
                                  "${slotDetails.startTimeFormatted} → ${slotDetails.endTimeFormatted}",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "S\$ ${parseDoubleToRoundString(slotDetails.ratePerHour ?? 0)}/hr",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "${slotDetails.tempNumberOfSlots} ${((slotDetails.tempNumberOfSlots) > 1) ? "Slots" : "Slot"}",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: customColors.textGray,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(height: 10.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityDescription(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return BaseContainer(
      borderColor: customColors.borderColor,
      bgColor: customColors.containerBG,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Facility Description",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  facilityDetails.description,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: customColors.textGray,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                if (!facilityDetails.isPrivateRental)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        "Maximum Group Size",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: customColors.textGray,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        facilityDetails.maxCapacityOrGroupSize,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoToListViewButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CustomButton(
      text: "Go to List",
      textcolor: colorScheme.onPrimary,
      buttonColor: colorScheme.primary,
      textsize: 16,
      fontWeight: FontWeight.bold,
      buttonheight: 50,
      radius: 10,
      buttonwidth: double.infinity,
      onTap: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildBottomText(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Text(
      "Need a different time slot? Contact the instructor directly for custom scheduling.",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Inter',
        color: customColors.textGray,
        fontWeight: FontWeight.w400,
        fontSize: 12,
      ),
    );
  }
}
