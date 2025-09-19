import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/model/get_all_activity_and_sub_activity_response.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/view/widgets/base_container.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/view/widgets/setup_grid_view_item.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/viewmodel/create_facility_view_model.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_field.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:provider/provider.dart';

class FacilityStepOne extends StatelessWidget {
  const FacilityStepOne({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMessageListener(),
          _buildTitleAndFacilityTitleView(context),
          _buildChooseYourActivityView(context),
          _buildChooseBookingTypeView(context),
        ],
      ),
    );
  }

  Widget _buildMessageListener() {
    return Consumer<CreateFacilityViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.getError.isNotEmpty) {
          final message = viewModel.getError;
          viewModel.setError();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showSnackBar(message, context);
          });
        }
        if (viewModel.getInfo.isNotEmpty) {
          final message = viewModel.getInfo;
          viewModel.setInfo();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showSnackBar(message, context);
          });
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTitleAndFacilityTitleView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5.0),
        Text(
          "Activity & Type Setup",
          style: TextStyle(
            fontFamily: 'SFPro',
            color: ColorsUtils.primary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 15.0),
        BaseContainer(
          child: Form(
            key: context.read<CreateFacilityViewModel>().firstStepFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Facility Title",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: ColorsUtils.chipText,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 15.0),
                CommonTextField(
                  maxLength: 50,
                  fillColor: ColorsUtils.white,
                  borderRadius: 6,
                  hint: "Facility Title",
                  labelText: "Facility Title",
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: context.read<CreateFacilityViewModel>().titleController,
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontFamily: "Inter",
                    color: ColorsUtils.black,
                    fontWeight: FontWeight.w500,
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return "Please enter Facility Title";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 5.0),
                Text(
                  "Give your facility a catchy name.",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: ColorsUtils.hintTextColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 15.0),
                CommonTextField(
                  maxLength: 50,
                  fillColor: ColorsUtils.white,
                  borderRadius: 6,
                  hint: "Subtitle",
                  labelText: "Subtitle",
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: context.read<CreateFacilityViewModel>().subTitleController,
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontFamily: "Inter",
                    color: ColorsUtils.black,
                    fontWeight: FontWeight.w500,
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return "Please enter Facility Subtitle";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 5.0),
                Text(
                  "A brief tagline describing your facility.",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: ColorsUtils.hintTextColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildChooseYourActivityView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        BaseContainer(
          bgColor: ColorsUtils.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Text(
                "${context.read<CreateFacilityViewModel>().isEdit ? "" : "Choose "}Your Activity",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: ColorsUtils.chipText,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 15),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: context.read<CreateFacilityViewModel>().activityList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(mainAxisSpacing: 15.0, crossAxisSpacing: 15.0, crossAxisCount: 3, childAspectRatio: 1.5),
                itemBuilder: (context, index) {
                  final item = context.watch<CreateFacilityViewModel>().activityList[index];
                  final isSelected = (context.watch<CreateFacilityViewModel>().selectedActivity?.ActivityId == item.ActivityId);
                  return SetupGridViewItem(
                    title: item.Name ?? "",
                    imagePath: item.localIconPath ?? "assets/images/ic_group_booking.png",
                    isSelected: isSelected,
                    isEnabled: !context.read<CreateFacilityViewModel>().isEdit,
                    onTap: () => context.read<CreateFacilityViewModel>().onSelectActivity(item),
                  );
                },
              ),
              const SizedBox(height: 10.0),
              Text(
                "${context.read<CreateFacilityViewModel>().isEdit ? "The" : "Choose the"} main category your facility belongs to.",
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: ColorsUtils.hintTextColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
              if (context.watch<CreateFacilityViewModel>().selectedActivity != null)
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10.0),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: ColorsUtils.borderColor),
                        borderRadius: BorderRadius.circular(15),
                        color: OQDOThemeData.backgroundColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: DropdownButton<dynamic>(
                            isExpanded: true,
                            icon: Icon(Icons.keyboard_arrow_down_rounded,
                                color: context.watch<CreateFacilityViewModel>().isEdit
                                    ? Colors.grey.shade400 // Disabled icon color
                                    : OQDOThemeData.blackColor),
                            dropdownColor: ColorsUtils.white,
                            underline: const SizedBox(),
                            borderRadius: BorderRadius.circular(15),
                            hint: CustomTextView(
                              label: context.watch<CreateFacilityViewModel>().subActivityHint,
                              textStyle: TextStyle(
                                color: ColorsUtils.hintTextColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Inter',
                              ),
                            ),
                            value: context.watch<CreateFacilityViewModel>().selectedSubActivity,
                            items: context.watch<CreateFacilityViewModel>().subActivityList.map((subActivity) {
                              return DropdownMenuItem<SubActivitiesBean>(
                                value: subActivity,
                                child: CustomTextView(
                                  label: subActivity.Name ?? "",
                                  textStyle: TextStyle(
                                    color: ColorsUtils.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: context.watch<CreateFacilityViewModel>().isEdit ? null : (value) => context.read<CreateFacilityViewModel>().onSelectSubActivity(value)),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      "${context.read<CreateFacilityViewModel>().isEdit ? "The" : "Select the"} specific activity your facility specializes in.",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: ColorsUtils.hintTextColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChooseBookingTypeView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        BaseContainer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Choose Booking Type",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: ColorsUtils.chipText,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Text(
                "Choose how users can book your facility.",
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: ColorsUtils.hintTextColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: context.read<CreateFacilityViewModel>().bookingTypes.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(mainAxisSpacing: 15.0, crossAxisSpacing: 15.0, crossAxisCount: 2, childAspectRatio: 2.25),
                itemBuilder: (context, index) {
                  final item = context.watch<CreateFacilityViewModel>().bookingTypes[index];
                  final isSelected = (context.watch<CreateFacilityViewModel>().selectedBookingType?.id == item.id);
                  return SetupGridViewItem(
                    title: item.title,
                    unSelectedColor: ColorsUtils.white,
                    imagePath: item.imagePath,
                    isSelected: isSelected,
                    isEnabled: true,
                    onTap: () => context.read<CreateFacilityViewModel>().onSelectBookingType(item),
                  );
                },
              ),
              const SizedBox(height: 10.0),
              Text(
                (context.watch<CreateFacilityViewModel>().selectedBookingType?.id == 2) ? "Shared access with other users" : "Exclusive access to the facility",
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: ColorsUtils.hintTextColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
