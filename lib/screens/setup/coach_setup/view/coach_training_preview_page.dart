import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_button.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/screens/setup/coach_setup/models/coach_preview_model.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/view/widgets/base_container.dart';
import 'package:oqdo_mobile_app/theme/custom_colors.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';

class CoachTrainingPreviewPage extends StatelessWidget {
  static const String routeName = '/coach_training_preview_page';

  const CoachTrainingPreviewPage({super.key, required this.coachDetails});

  final CoachPreviewModel coachDetails;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      backgroundColor: colorScheme.background,
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
          onPressed: () => Navigator.of(context).pop(true),
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
              _buildTrainingPreviewCard(context, customColors, colorScheme),
              const SizedBox(height: 20.0),
              _buildUserCard(context, customColors, colorScheme),
              const SizedBox(height: 20.0),
              _buildAvailableSessionsView(context, customColors, colorScheme),
              const SizedBox(height: 20.0),
              _buildTrainingVenueView(context, customColors, colorScheme),
              const SizedBox(height: 20.0),
              _buildAboutTrainingView(context, customColors, colorScheme),
              const SizedBox(height: 20.0),
              _buildGoToListViewButton(context, colorScheme),
              const SizedBox(height: 20.0),
              _buildBottomText(context, customColors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrainingPreviewCard(
    BuildContext context,
    CustomColors customColors,
    ColorScheme colorScheme,
  ) {
    return BaseContainer(
      borderColor: colorScheme.primary,
      bgColor: customColors.selectedGridItemColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            coachDetails.title,
            style: TextStyle(
              fontFamily: 'Inter',
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  "${coachDetails.activity} > ${coachDetails.subActivity}",
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
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: coachDetails.isOpenClass
                      ? customColors.green
                      : customColors.darkRed,
                ),
                child: Text(
                  coachDetails.isOpenClass ? 'Open Class' : 'Group Class',
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
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildTrainingInfoRow(
                context,
                icon: const Icon(Icons.access_time, size: 20),
                label: '${coachDetails.slotDurationFormatted} sessions',
                colorScheme: colorScheme,
                customColors: customColors,
              ),
              _buildTrainingInfoRow(
                context,
                icon: Image.asset(
                  "assets/images/ic_dollar_rounded.png",
                  height: 20,
                  width: 20,
                ),
                label: 'From ${parseDoubleToRoundString(coachDetails.slotRate)}/hr',
                colorScheme: colorScheme,
                customColors: customColors,
              ),
              if (coachDetails.isOpenClass)
                _buildTrainingInfoRow(
                  context,
                  icon: Image.asset(
                    "assets/images/ic_persons.png",
                    height: 20,
                    width: 20,
                  ),
                  label: '${coachDetails.maxCapacityOrGroupSize} max capacity',
                  colorScheme: colorScheme,
                  customColors: customColors,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingInfoRow(
    BuildContext context, {
    required Widget icon,
    required String label,
    required ColorScheme colorScheme,
    required CustomColors customColors,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconTheme(
          data: IconThemeData(color: customColors.chipText),
          child: icon,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            color: customColors.chipText,
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    CustomColors customColors,
    ColorScheme colorScheme,
  ) {
    return BaseContainer(
      borderColor: customColors.borderColor,
      bgColor: customColors.buttonBg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  imageUrl: OQDOApplication.instance.profileImage ?? "",
                  fit: BoxFit.fill,
                  height: 50,
                  width: 50,
                  placeholder: (context, _) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) {
                    return Image.asset(
                      "assets/images/profile_circle.png",
                      fit: BoxFit.fill,
                      width: 50,
                      height: 50,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Column(
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
              const SizedBox(height: 3),
              Text(
                "${OQDOApplication.instance.coachExperienceYears ?? 0} ${(OQDOApplication.instance.coachExperienceYears ?? 0) > 1 ? "years" : "year"}",
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: customColors.textGray,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableSessionsView(
    BuildContext context,
    CustomColors customColors,
    ColorScheme colorScheme,
  ) {
    return BaseContainer(
      borderColor: customColors.borderColor,
      bgColor: customColors.white,
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
                  "Available Sessions",
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
                  itemCount: coachDetails.slotsList.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final slotDetails = coachDetails.slotsList[index];
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
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10.0, vertical: 4.0),
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
                                  slotDetails.getAccurateTimeRangeDisplay(
                                      coachDetails.slotDurationInMinutes),
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
                            crossAxisAlignment: CrossAxisAlignment.center,
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

  Widget _buildTrainingVenueView(
    BuildContext context,
    CustomColors customColors,
    ColorScheme colorScheme,
  ) {
    return BaseContainer(
      borderColor: customColors.borderColor,
      bgColor: customColors.white,
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
                  "Training Venue",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Location Type",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: customColors.textGray,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if ((coachDetails.addressTypeId == 1) ||
                        (coachDetails.addressTypeId == 3))
                      _buildLocationType(
                        context,
                        customColors,
                        title: "Coach's Address",
                      ),
                    const SizedBox(width: 10.0),
                    if ((coachDetails.addressTypeId == 2) ||
                        (coachDetails.addressTypeId == 3))
                      _buildLocationType(
                        context,
                        customColors,
                        title: "Home Training",
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "Address",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: customColors.textGray,
                    fontWeight: FontWeight.w400,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTrainingView(
    BuildContext context,
    CustomColors customColors,
    ColorScheme colorScheme,
  ) {
    return BaseContainer(
      borderColor: customColors.borderColor,
      bgColor: customColors.white,
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
                  "About This Training",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Join our open training sessions where you'll learn alongside other students. Perfect for building skills in a supportive group environment with professional instruction.",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: customColors.textGray,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      coachDetails.isOpenClass
                          ? "Minimum Sessions"
                          : "Maximum Group Size",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: customColors.textGray,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      coachDetails.isOpenClass
                          ? coachDetails.minSessions
                          : coachDetails.maxCapacityOrGroupSize,
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

  Widget _buildGoToListViewButton(BuildContext context, ColorScheme colorScheme) {
    return CustomButton(
      text: "Go to List",
      textcolor: colorScheme.onPrimary,
      buttonColor: colorScheme.primary,
      textsize: 16,
      fontWeight: FontWeight.bold,
      buttonheight: 50,
      radius: 10,
      buttonwidth: double.infinity,
      onTap: () => Navigator.of(context).pop(true),
    );
  }

  Widget _buildBottomText(BuildContext context, CustomColors customColors) {
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

  Widget _buildLocationType(
    BuildContext context,
    CustomColors customColors, {
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: customColors.green.withOpacity(0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check,
            color: customColors.green,
            size: 16,
          ),
          const SizedBox(width: 3.0),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: customColors.green,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}
