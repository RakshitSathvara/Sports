import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_button.dart';
import 'package:oqdo_mobile_app/components/custom_toggle_switch.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/view/facility_training_preview_page.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/view/widgets/base_container.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/view/widgets/time_input_field.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/viewmodel/create_facility_view_model.dart';
import 'package:oqdo_mobile_app/theme/custom_colors.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_field.dart';
import 'package:provider/provider.dart';

class FacilityStepThree extends StatelessWidget {
  const FacilityStepThree({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMessageListener(),
          _buildConfigureFacilityDetailsView(context),
          _buildTimeSlotView(context),
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

        if (viewModel.bookingSlotSheetState == BookingSlotSheetState.hide) {
          viewModel.bookingSlotSheetState = BookingSlotSheetState.ideal;
          Navigator.of(context).pop();
        }
        if (viewModel.setupState == FacilitySetupState.success) {
          hideKeyboard();
          viewModel.setupState = FacilitySetupState.ideal;
          Future.delayed(const Duration(milliseconds: 100)).then((_) {
            if (!context.mounted) return;
            Navigator.popAndPushNamed(context, FacilityTrainingPreviewPage.routeName, result: true, arguments: viewModel.facilityPreview);
          });
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildConfigureFacilityDetailsView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5.0),
        Text(
          "Booking Schedule",
          style: TextStyle(
            fontFamily: 'SFPro',
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 15.0),
        BaseContainer(
          bgColor: Theme.of(context).extension<CustomColors>()!.containerBG,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Text(
                "Rate Settings",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Theme.of(context).extension<CustomColors>()!.chipText,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Same Rate for Slots",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Theme.of(context).extension<CustomColors>()!.chipText,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Apply one rate to all time slots",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Theme.of(context).extension<CustomColors>()!.hintTextColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  CustomToggleSwitch(
                    value: context.watch<CreateFacilityViewModel>().isSameRates,
                    onChanged: (value) {
                      if (context.read<CreateFacilityViewModel>().addedTimeSlotList.isNotEmpty) {
                        showDialog(
                          context: context,
                          builder: (mContext) => AlertDialog(
                            title: const Text('Slot Booking'),
                            content: const Text(
                                'Are you sure you want to change rates settings?\n\nIf you change now it\'ll remove all added slots.\n\nPlease note that this action can\'t be reversed.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context, rootNavigator: false).pop(),
                                child: const Text('No, Continue Setup'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  context.read<CreateFacilityViewModel>().onToggleSameRatesSwitch(value);
                                  Navigator.pop(context);
                                },
                                child: const Text('Yes, Change settings'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        context.read<CreateFacilityViewModel>().onToggleSameRatesSwitch(value);
                      }
                    },
                  ),
                ],
              ),
              if (context.watch<CreateFacilityViewModel>().isSameRates)
                Form(
                  key: context.read<CreateFacilityViewModel>().thirdStepFormKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Text(
                              "S\$",
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: "Inter",
                                color: Theme.of(context).extension<CustomColors>()!.darkGrey,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: CommonTextField(
                              maxLength: 6,
                              fillColor: Theme.of(context).extension<CustomColors>()!.containerBG,
                              isDouble: true,
                              borderRadius: 6,
                              hint: "Enter hourly rate",
                              labelText: "Hourly Rate",
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              controller: context.read<CreateFacilityViewModel>().hourlyRateController,
                              textStyle: TextStyle(
                                fontSize: 16,
                                fontFamily: "Inter",
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return "Please enter hourly rate";
                                }
                                final doubleValue = double.tryParse(value!);
                                if (doubleValue == null) {
                                  return 'Please enter a valid hourly rate';
                                }

                                if (doubleValue < 1) {
                                  return 'Hourly Rate must be greater than 0';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotView(BuildContext context) {
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
              CustomButton(
                text: "Add Time Slot",
                leadingIcon: Icon(Icons.add, size: 18),
                textcolor: Theme.of(context).colorScheme.onSurface,
                buttonColor: Theme.of(context).extension<CustomColors>()!.buttonColorGrey,
                borderColor: Theme.of(context).extension<CustomColors>()!.borderColor,
                textsize: 16,
                fontWeight: FontWeight.bold,
                buttonheight: 50,
                radius: 5,
                buttonwidth: double.infinity,
                onTap: () {
                  if (context.read<CreateFacilityViewModel>().isSameRates && (!(context.read<CreateFacilityViewModel>().thirdStepFormKey.currentState!.validate()))) {
                    return;
                  }
                  _showAddSlotBottomSheet(context, context.read<CreateFacilityViewModel>());
                },
              ),
              const SizedBox(height: 10.0),
              Text(
                "Add available rental time slots.",
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Theme.of(context).extension<CustomColors>()!.hintTextColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
              if (context.watch<CreateFacilityViewModel>().addedTimeSlotList.isNotEmpty) const SizedBox(height: 10.0),
              if (context.watch<CreateFacilityViewModel>().addedTimeSlotList.isNotEmpty)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: context.watch<CreateFacilityViewModel>().addedTimeSlotList.length,
                  itemBuilder: (context, index) {
                    final slotDetails = context.read<CreateFacilityViewModel>().addedTimeSlotList[index];
                    return DottedBorder(
                      padding: EdgeInsets.zero,
                      borderType: BorderType.RRect,
                      strokeWidth: 1.5,
                      radius: const Radius.circular(5),
                      dashPattern: const [3, 3],
                      color: Theme.of(context).extension<CustomColors>()!.messageRight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).extension<CustomColors>()!.buttonColorGrey,
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: slotDetails.sortedSelectedDays.map((day) {
                                      return Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: Theme.of(context).colorScheme.primary),
                                        child: Text(
                                          day.title,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Theme.of(context).extension<CustomColors>()!.onAccentText,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                                GestureDetector(
                                  onTap: () => context.read<CreateFacilityViewModel>().onRemoveAddedSlot(index),
                                  child: Container(
                                    height: 25,
                                    width: 25,
                                    padding: EdgeInsets.all(4.0),
                                    child: Image.asset(
                                      "assets/images/ic_cancel_appointment.png",
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            _buildTitleDetailsRow(
                                title: "Time",
                                details: context.read<CreateFacilityViewModel>().getAccurateTimeRangeForDisplay(slotDetails.startTime.text, slotDetails.tempNumberOfSlots)),
                            _buildTitleDetailsRow(title: "Slots", details: slotDetails.numberOfSlots.text),
                            _buildTitleDetailsRow(
                              title: "Per Slot Duration",
                              details: context.read<CreateFacilityViewModel>().getFormattedSlotDurationForDisplay(),
                            ),
                            _buildTitleDetailsRow(
                              title: "Total Duration",
                              details: context.read<CreateFacilityViewModel>().getFormattedTotalDurationForDisplay(slotDetails.tempNumberOfSlots),
                            ),
                            if (!context.watch<CreateFacilityViewModel>().isSameRates)
                              _buildTitleDetailsRow(
                                title: "Rate",
                                details: "S\$ ${parseDoubleToRoundString(slotDetails.ratePerHour ?? 0)}/hour",
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 10.0);
                  },
                )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitleDetailsRow({required String title, required String details, bool addTopPadding = true}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: addTopPadding ? 8 : 0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurface,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(width: 10),
            Text(
              details,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showAddSlotBottomSheet(BuildContext context, CreateFacilityViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: ChangeNotifierProvider<CreateFacilityViewModel>.value(
            value: viewModel,
            child: Builder(builder: (context) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height,
                    minHeight: 0, // Let content determine minimum height
                  ),
                  child: IntrinsicHeight(
                    child: Container(
                      // Remove fixed height - let content determine height
                      padding: EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).extension<CustomColors>()!.containerBG,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Important: use min size
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Add Booking Slot',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  viewModel.clearSelectionOfAddTimeBottomSheet();
                                },
                                child: Icon(Icons.close, size: 24),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Content
                          Flexible(
                            // Changed from Expanded to Flexible
                            child: SingleChildScrollView(
                              child: Form(
                                key: viewModel.slotFormKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Select Booking Days
                                    Text(
                                      'Select Booking Days',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 12,
                                      children: context.watch<CreateFacilityViewModel>().days.map((day) {
                                        final isSelected = context.watch<CreateFacilityViewModel>().selectedDays.contains(day);
                                        return _buildDayItemWrap(
                                          day: day.title,
                                          isSelected: isSelected,
                                          onTap: () {
                                            context.read<CreateFacilityViewModel>().toggleDay(day);
                                          },
                                        );
                                      }).toList(),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Select multiple days when the same availability applies',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).extension<CustomColors>()!.textGray,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    if (!(context.watch<CreateFacilityViewModel>().isSameRates))
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 15),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                'S\$',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontFamily: "Inter",
                                                  color: Theme.of(context).extension<CustomColors>()!.darkGrey,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: CommonTextField(
                                                  maxLength: 6,
                                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                                  fillColor: Theme.of(context).extension<CustomColors>()!.containerBG,
                                                  isDouble: true,
                                                  borderRadius: 6,
                                                  hint: "Enter hourly rate",
                                                  labelText: "Hourly Rate",
                                                  textStyle: TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: "Inter",
                                                    color: Theme.of(context).colorScheme.onSurface,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  validator: (value) {
                                                    if (value?.isEmpty ?? true) {
                                                      return "Please enter hourly rate";
                                                    }
                                                    final doubleValue = double.tryParse(value!);
                                                    if (doubleValue == null) {
                                                      return 'Please enter a valid hourly rate';
                                                    }

                                                    if (doubleValue < 1) {
                                                      return 'Hourly Rate must be greater than 0';
                                                    }
                                                    return null;
                                                  },
                                                  controller: viewModel.hourlyRateController,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    const SizedBox(height: 10),
                                    // Booking Slots section
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.access_time, size: 20, color: Theme.of(context).extension<CustomColors>()!.chipText),
                                            SizedBox(width: 8),
                                            Text(
                                              'Booking Slots (6 AM - 10 PM)',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context).extension<CustomColors>()!.chipText,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 10),
                                        CustomButton(
                                          text: "",
                                          leadingIcon: Icon(
                                            Icons.add,
                                            size: 20,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                          textcolor: Theme.of(context).colorScheme.onSurface,
                                          buttonColor: Theme.of(context).extension<CustomColors>()!.selectedGridItemColor,
                                          borderColor: Theme.of(context).extension<CustomColors>()!.selectedGridItemColor,
                                          textsize: 16,
                                          fontWeight: FontWeight.bold,
                                          buttonheight: 35,
                                          buttonwidth: 35,
                                          radius: 6,
                                          onTap: () => viewModel.onTapAddBookingSlot(),
                                        ),
                                      ],
                                    ),
                                    if (viewModel.editTimeSlotList.isNotEmpty) const SizedBox(height: 10),
                                    if (viewModel.editTimeSlotList.isNotEmpty)
                                      Column(
                                        children: [
                                          for (int index = 0; index < viewModel.editTimeSlotList.length; index++) ...[
                                            Builder(
                                              builder: (context) {
                                                final editSlot = viewModel.editTimeSlotList[index];
                                                return Form(
                                                  key: editSlot.formKey,
                                                  child: BaseContainer(
                                                    bgColor: Theme.of(context).extension<CustomColors>()!.containerBG,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text(
                                                              'Session',
                                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Montserrat', color: Theme.of(context).colorScheme.onSurface),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                viewModel.onClearSession(index);
                                                              },
                                                              child: Icon(Icons.close, size: 24),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 10.0),
                                                        // Start Time
                                                        Text(
                                                          'Start Time',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w500,
                                                            fontFamily: 'Inter',
                                                            color: Theme.of(context).extension<CustomColors>()!.chipText,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 8),
                                                        TimeInputField(
                                                          key: editSlot.startTimeControllerKey,
                                                          controller: editSlot.startTime,
                                                          hintText: '--:--',
                                                          startTime: "06:00",
                                                          endTime: "22:00",
                                                          slotDuration: editSlot.perSlotDuration,
                                                          onTimeChanged: (String selectedTime) {
                                                            debugPrint('onTimeChanged: $selectedTime');
                                                            viewModel.clearNumberOfSlots(editSlot);
                                                          },
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Wrap(
                                                          spacing: 6,
                                                          runSpacing: 6,
                                                          children: viewModel.popularTimes.map((time) {
                                                            return GestureDetector(
                                                              onTap: () => viewModel.setStartTime(time, index),
                                                              child: Container(
                                                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                                                decoration: BoxDecoration(
                                                                  color: Theme.of(context).extension<CustomColors>()!.selectedGridItemColor,
                                                                  borderRadius: BorderRadius.circular(6),
                                                                  border: Border.all(
                                                                    color: Theme.of(context).extension<CustomColors>()!.lightBlueBorderColor,
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  time,
                                                                  style: TextStyle(
                                                                    fontSize: 14,
                                                                    color: Theme.of(context).colorScheme.onSurface,
                                                                    fontFamily: 'Inter',
                                                                    fontWeight: FontWeight.w400,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }).toList(),
                                                        ),
                                                        const SizedBox(height: 10),
                                                        Text(
                                                          'Popular booking times. Click to select quickly.',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Theme.of(context).extension<CustomColors>()!.textGray,
                                                            fontFamily: 'Inter',
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                        if (editSlot.startTime.text.isNotEmpty && (!(editSlot.startTimeControllerKey.currentState?.hasError ?? true)))
                                                          Column(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              const SizedBox(height: 10),
                                                              Text(
                                                                'Number of Slots',
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight: FontWeight.w500,
                                                                  fontFamily: 'Inter',
                                                                  color: Theme.of(context).extension<CustomColors>()!.chipText,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 15),
                                                              CommonTextField(
                                                                controller: editSlot.numberOfSlots,
                                                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                                                maxLength: 2,
                                                                fillColor: Theme.of(context).extension<CustomColors>()!.containerBG,
                                                                isNumber: true,
                                                                borderRadius: 6,
                                                                hint: "Number of Slots",
                                                                labelText: "Number of Slots",
                                                                textStyle: TextStyle(
                                                                  fontSize: 16,
                                                                  fontFamily: "Inter",
                                                                  color: Theme.of(context).colorScheme.onSurface,
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                                validator: (value) {
                                                                  if (value == null || value.isEmpty) {
                                                                    return "Please enter number of slots";
                                                                  }
                                                                  int numberOfSlots = int.tryParse(value) ?? 0;
                                                                  if (numberOfSlots <= 0) {
                                                                    return "Number of Slots must be greater than 0";
                                                                  }
                                                                  // Your validation logic here
                                                                  return validateSlotTiming(numberOfSlots, editSlot.startTime.text, "22:00", editSlot.perSlotDuration);
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        if (editSlot.numberOfSlots.text.isNotEmpty && (editSlot.formKey.currentState?.validate() ?? false))
                                                          Column(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              SizedBox(height: 8),
                                                              Text(
                                                                'Consecutive hours for venue booking',
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Theme.of(context).extension<CustomColors>()!.textGray,
                                                                  fontFamily: 'Inter',
                                                                  fontWeight: FontWeight.w400,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 8),
                                                              DottedBorder(
                                                                padding: EdgeInsets.zero,
                                                                borderType: BorderType.RRect,
                                                                strokeWidth: 1.5,
                                                                radius: const Radius.circular(5),
                                                                dashPattern: const [3, 3],
                                                                color: Theme.of(context).extension<CustomColors>()!.messageRight,
                                                                child: Container(
                                                                  decoration: BoxDecoration(
                                                                    color: Theme.of(context).extension<CustomColors>()!.buttonColorGrey,
                                                                    borderRadius: BorderRadius.all(
                                                                      Radius.circular(5),
                                                                    ),
                                                                  ),
                                                                  padding: const EdgeInsets.all(10.0),
                                                                  child: Column(
                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      _buildTitleDetailsRow(
                                                                        title: "Start Time",
                                                                        details: editSlot.startTime.text,
                                                                        addTopPadding: false,
                                                                      ),
                                                                      _buildTitleDetailsRow(
                                                                          title: "End Time",
                                                                          details: viewModel.getAccurateEndTimeForDisplay(editSlot.startTime.text, editSlot.tempNumberOfSlots)),
                                                                      _buildTitleDetailsRow(
                                                                        title: "Per Slot Duration",
                                                                        details: viewModel.getFormattedSlotDurationForDisplay(),
                                                                      ),
                                                                      _buildTitleDetailsRow(
                                                                        title: "Total Duration",
                                                                        details: viewModel.getFormattedTotalDurationForDisplay(editSlot.tempNumberOfSlots),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            if (index < viewModel.editTimeSlotList.length - 1) const SizedBox(height: 10.0),
                                          ],
                                        ],
                                      ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Add multiple slots if you have separate booking periods on the same day',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).extension<CustomColors>()!.textGray,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Bottom buttons
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  text: "Cancel",
                                  textcolor: Theme.of(context).colorScheme.onSurface,
                                  buttonColor: Theme.of(context).extension<CustomColors>()!.buttonBg,
                                  textsize: 16,
                                  fontWeight: FontWeight.bold,
                                  buttonheight: 50,
                                  radius: 10,
                                  buttonwidth: double.infinity,
                                  onTap: () {
                                    Navigator.pop(context);
                                    viewModel.clearSelectionOfAddTimeBottomSheet();
                                  },
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: CustomButton(
                                  text: "Add Time Slot",
                                  textcolor: Theme.of(context).colorScheme.onPrimary,
                                  buttonColor: Theme.of(context).colorScheme.primary,
                                  textsize: 16,
                                  fontWeight: FontWeight.bold,
                                  buttonheight: 50,
                                  radius: 10,
                                  buttonwidth: double.infinity,
                                  onTap: () => viewModel.onClickOfAddTimeSlot(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildDayItemWrap({required String day, required Function()? onTap, required bool isSelected}) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 130,
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).extension<CustomColors>()!.greyBG,
                borderRadius: BorderRadius.circular(7),
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 18, color: Theme.of(context).extension<CustomColors>()!.onAccentText)
                  : null,
            ),
            SizedBox(width: 8),
            Text(
              day,
              style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).extension<CustomColors>()!.hintTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter'),
            ),
          ],
        ),
      ),
    );
  }

  String? validateSlotTiming(int numberOfSlots, String startTime, String endTime, int slotDurationHours) {
    try {
      // Parse start and end times
      final startHour = int.parse(startTime.split(':')[0]);
      final startMinute = int.parse(startTime.split(':')[1]);
      final endHour = int.parse(endTime.split(':')[0]);
      final endMinute = int.parse(endTime.split(':')[1]);

      // Calculate total available time in minutes
      final startTimeInMinutes = (startHour * 60) + startMinute;
      final endTimeInMinutes = (endHour * 60) + endMinute;
      final availableTimeInMinutes = endTimeInMinutes - startTimeInMinutes;

      // Calculate required time for all slots in minutes
      final slotDurationInMinutes = slotDurationHours * 60;
      final totalRequiredTimeInMinutes = numberOfSlots * slotDurationInMinutes;

      // Check if total required time exceeds available time
      if (totalRequiredTimeInMinutes > availableTimeInMinutes) {
        return "Every slot must end on or before $endTime";
      }

      return null; // No validation error
    } catch (e) {
      return "Invalid time format";
    }
  }
}
