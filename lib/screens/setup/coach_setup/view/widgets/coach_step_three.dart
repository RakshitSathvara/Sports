import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_button.dart';
import 'package:oqdo_mobile_app/screens/setup/coach_setup/view/coach_training_preview_page.dart';
import 'package:oqdo_mobile_app/screens/setup/coach_setup/viewmodel/create_coach_view_model.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/view/widgets/base_container.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/view/widgets/time_input_field.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_field.dart';
import 'package:provider/provider.dart';

class CoachStepThree extends StatelessWidget {
  const CoachStepThree({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMessageListener(),
          _buildTimeSlotView(context),
        ],
      ),
    );
  }

  Widget _buildMessageListener() {
    return Consumer<CreateCoachViewModel>(
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
          Navigator.of(context, rootNavigator: false).pop();
        }
        if (viewModel.setupState == CoachSetupState.success) {
          hideKeyboard();
          viewModel.setupState = CoachSetupState.ideal;
          Future.delayed(const Duration(milliseconds: 100)).then((_) {
            if (!context.mounted) return;
            Navigator.popAndPushNamed(context, CoachTrainingPreviewPage.routeName, result: true, arguments: viewModel.coachPreview);
          });
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTimeSlotView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5.0),
        Text(
          "Session Timetable",
          style: TextStyle(
            fontFamily: 'SFPro',
            color: ColorsUtils.primary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 15.0),
        BaseContainer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomButton(
                text: "Add Training Slot",
                leadingIcon: Icon(Icons.add, size: 18),
                textcolor: ColorsUtils.black,
                buttonColor: ColorsUtils.buttonColorGrey,
                borderColor: ColorsUtils.borderColor,
                textsize: 16,
                fontWeight: FontWeight.bold,
                buttonheight: 50,
                radius: 5,
                buttonwidth: double.infinity,
                onTap: () {
                  context.read<CreateCoachViewModel>().clearSelectionOfAddTimeBottomSheet();
                  _showAddSlotBottomSheet(context, context.read<CreateCoachViewModel>());
                },
              ),
              if (context.watch<CreateCoachViewModel>().addedTimeSlotList.isNotEmpty) const SizedBox(height: 10.0),
              if (context.watch<CreateCoachViewModel>().addedTimeSlotList.isNotEmpty)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: context.watch<CreateCoachViewModel>().addedTimeSlotList.length,
                  itemBuilder: (context, index) {
                    final slotDetails = context.read<CreateCoachViewModel>().addedTimeSlotList[index];
                    final numberOfSessions = int.tryParse(slotDetails.numberOfSlots.text) ?? 0;
                    return DottedBorder(
                      padding: EdgeInsets.zero,
                      borderType: BorderType.RRect,
                      strokeWidth: 1.5,
                      radius: const Radius.circular(5),
                      dashPattern: const [3, 3],
                      color: ColorsUtils.messageRight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: ColorsUtils.buttonColorGrey,
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
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: ColorsUtils.primary),
                                        child: Text(
                                          day.title,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: ColorsUtils.white,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                                GestureDetector(
                                  onTap: () => context.read<CreateCoachViewModel>().onRemoveAddedSlot(index),
                                  child: Container(
                                    height: 25,
                                    width: 25,
                                    padding: EdgeInsets.all(4.0),
                                    child: Image.asset(
                                      "assets/images/ic_cancel_appointment.png",
                                      color: ColorsUtils.black,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            _buildTitleDetailsRow(
                                title: "Time", details: slotDetails.getAccurateTimeRangeDisplay(context.read<CreateCoachViewModel>().getClassDurationInMinutes())),
                            _buildTitleDetailsRow(title: "Class", details: "$numberOfSessions ${numberOfSessions > 1 ? "Sessions" : "Session"}"),
                            _buildTitleDetailsRow(title: "Per Session Time", details: context.read<CreateCoachViewModel>().getFormattedClassDurationForDisplay()),
                            _buildTitleDetailsRow(
                                title: "Total Duration", details: context.read<CreateCoachViewModel>().getFormattedTotalClassDurationForDisplay(numberOfSessions)),
                            if (!context.watch<CreateCoachViewModel>().isSameRates)
                              _buildTitleDetailsRow(title: "Rate", details: "S\$ ${parseDoubleToRoundString(slotDetails.ratePerHour ?? 0)}/hour"),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 10.0);
                  },
                ),
              const SizedBox(height: 10.0),
              Text(
                "Add multiple time slots for different days and times. Overlapping times will be prevented.",
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
                color: ColorsUtils.black,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(width: 10),
            Text(
              details,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ColorsUtils.black,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showAddSlotBottomSheet(BuildContext context, CreateCoachViewModel viewModel) {
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
          child: ChangeNotifierProvider<CreateCoachViewModel>.value(
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
                        color: ColorsUtils.white,
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
                                'Add Training Slot',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: ColorsUtils.black,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
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
                                      'Select Training Days',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 12,
                                      children: context.watch<CreateCoachViewModel>().days.map((day) {
                                        final isSelected = context.watch<CreateCoachViewModel>().selectedDays.contains(day);
                                        return _buildDayItemWrap(
                                            day: day.title,
                                            isSelected: isSelected,
                                            onTap: () {
                                              context.read<CreateCoachViewModel>().toggleDay(day);
                                            });
                                      }).toList(),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Select multiple days when the same schedule applies',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: ColorsUtils.textGray,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    if (!(context.watch<CreateCoachViewModel>().isSameRates))
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 10),
                                          Text(
                                            'Rate per Hour (S\$)',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Montserrat',
                                              color: ColorsUtils.black,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          CommonTextField(
                                            maxLength: 6,
                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                            fillColor: ColorsUtils.white,
                                            isDouble: true,
                                            borderRadius: 6,
                                            hint: "Enter rate",
                                            textStyle: TextStyle(
                                              fontSize: 16,
                                              fontFamily: "Inter",
                                              color: ColorsUtils.black,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            validator: (value) {
                                              if (value?.isEmpty ?? true) {
                                                return "Please enter hourly rate";
                                              }
                                              return null;
                                            },
                                            controller: viewModel.hourlyRateController,
                                          ),
                                          const SizedBox(height: 10.0),
                                          Text(
                                            'Custom rate for this specific time slot',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: ColorsUtils.textGray,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
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
                                            Icon(Icons.access_time, size: 20, color: ColorsUtils.chipText),
                                            SizedBox(width: 8),
                                            Text(
                                              'Training Sessions (6 AM - 10 PM)',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w600,
                                                color: ColorsUtils.chipText,
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
                                            color: ColorsUtils.black,
                                          ),
                                          textcolor: ColorsUtils.black,
                                          buttonColor: ColorsUtils.selectedGridItemColor,
                                          borderColor: ColorsUtils.selectedGridItemColor,
                                          textsize: 16,
                                          fontWeight: FontWeight.bold,
                                          buttonheight: 35,
                                          buttonwidth: 35,
                                          radius: 6,
                                          onTap: () => viewModel.onTapAddTimeSlot(),
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
                                                    bgColor: ColorsUtils.white,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text(
                                                              'Session',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w600,
                                                                fontFamily: 'Montserrat',
                                                                color: ColorsUtils.black,
                                                              ),
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
                                                            color: ColorsUtils.chipText,
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
                                                                  color: ColorsUtils.selectedGridItemColor,
                                                                  borderRadius: BorderRadius.circular(6),
                                                                  border: Border.all(
                                                                    color: ColorsUtils.lightBlueBorderColor,
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  time,
                                                                  style: TextStyle(
                                                                    fontSize: 14,
                                                                    color: ColorsUtils.black,
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
                                                          'Popular training times. Click to select quickly.',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: ColorsUtils.textGray,
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
                                                                'Number of Classes',
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight: FontWeight.w500,
                                                                  fontFamily: 'Inter',
                                                                  color: ColorsUtils.chipText,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 15),
                                                              CommonTextField(
                                                                controller: editSlot.numberOfSlots,
                                                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                                                maxLength: 2,
                                                                fillColor: ColorsUtils.white,
                                                                isNumber: true,
                                                                borderRadius: 6,
                                                                hint: "Number of Classes",
                                                                labelText: "Number of Classes",
                                                                textStyle: TextStyle(
                                                                  fontSize: 16,
                                                                  fontFamily: "Inter",
                                                                  color: ColorsUtils.black,
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                                validator: (value) {
                                                                  if (value == null || value.isEmpty) {
                                                                    return "Please enter Number of Classes";
                                                                  }
                                                                  int numberOfSlots = int.tryParse(value) ?? 0;
                                                                  if (numberOfSlots <= 0) {
                                                                    return "Number of Classes must be greater than 0";
                                                                  }
                                                                  // Your validation logic here
                                                                  return validateSlotTiming(numberOfSlots, editSlot.startTime.text, "22:00",
                                                                      context.read<CreateCoachViewModel>().getClassDurationInMinutes());
                                                                },
                                                              ),
                                                              const SizedBox(height: 10),
                                                              Text(
                                                                'Consecutive classes without break',
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: ColorsUtils.textGray,
                                                                  fontFamily: 'Inter',
                                                                  fontWeight: FontWeight.w400,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        if (editSlot.numberOfSlots.text.isNotEmpty && (editSlot.formKey.currentState?.validate() ?? false))
                                                          Column(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              const SizedBox(height: 8),
                                                              DottedBorder(
                                                                padding: EdgeInsets.zero,
                                                                borderType: BorderType.RRect,
                                                                strokeWidth: 1.5,
                                                                radius: const Radius.circular(5),
                                                                dashPattern: const [3, 3],
                                                                color: ColorsUtils.messageRight,
                                                                child: Container(
                                                                  decoration: BoxDecoration(
                                                                    color: ColorsUtils.buttonColorGrey,
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
                                                                        title: "Start",
                                                                        details: editSlot.startTime.text,
                                                                        addTopPadding: false,
                                                                      ),
                                                                      _buildTitleDetailsRow(
                                                                          title: "End",
                                                                          details: editSlot.getAccurateEndTime(context.read<CreateCoachViewModel>().getClassDurationInMinutes())),
                                                                      _buildTitleDetailsRow(
                                                                        title: "Per Session Time",
                                                                        details: context.read<CreateCoachViewModel>().getFormattedClassDurationForDisplay(),
                                                                      ),
                                                                      _buildTitleDetailsRow(
                                                                        title: "Total Duration",
                                                                        details: context
                                                                            .read<CreateCoachViewModel>()
                                                                            .getFormattedTotalClassDurationForDisplay(editSlot.tempNumberOfSlots),
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
                                      'Add multiple sessions if you have breaks between training periods on the same day',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: ColorsUtils.textGray,
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
                                  textcolor: ColorsUtils.black,
                                  buttonColor: ColorsUtils.buttonBg,
                                  textsize: 16,
                                  fontWeight: FontWeight.bold,
                                  buttonheight: 50,
                                  radius: 10,
                                  buttonwidth: double.infinity,
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: CustomButton(
                                  text: "Add Time Slot",
                                  textcolor: ColorsUtils.white,
                                  buttonColor: ColorsUtils.primary,
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
                color: isSelected ? ColorsUtils.primary : ColorsUtils.greyBG,
                borderRadius: BorderRadius.circular(7),
              ),
              child: isSelected ? Icon(Icons.check, size: 18, color: ColorsUtils.white) : null,
            ),
            SizedBox(width: 8),
            Text(
              day,
              style: TextStyle(
                color: isSelected ? ColorsUtils.black : ColorsUtils.hintTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? validateSlotTiming(int numberOfSlots, String startTime, String endTime, int slotDurationMinutes) {
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
      final totalRequiredTimeInMinutes = numberOfSlots * slotDurationMinutes;

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
