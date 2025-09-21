import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_button.dart';
import 'package:oqdo_mobile_app/components/custom_toggle_switch.dart';
import 'package:oqdo_mobile_app/model/coach_training_address.dart';
import 'package:oqdo_mobile_app/screens/setup/coach_setup/viewmodel/create_coach_view_model.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/view/widgets/base_container.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/view/widgets/duration_input_field.dart';
import 'package:oqdo_mobile_app/screens/setup/setups_bottom_sheets/ShowClearSlotsBottomSheet.dart';
import 'package:oqdo_mobile_app/theme/custom_colors.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_field.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:provider/provider.dart';

class CoachStepTwo extends StatelessWidget {
  const CoachStepTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: context.read<CreateCoachViewModel>().secondStepFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMessageListener(),
            _buildClassSettingsView(context),
            _buildTrainingVenueView(context),
            _buildRateSettingsView(context),
          ],
        ),
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
        if (viewModel.addressBottomSheetState == AddressBottomSheetState.show) {
          viewModel.addressBottomSheetState = AddressBottomSheetState.ideal;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showAddAddressBottomSheet(context, context.read<CreateCoachViewModel>());
          });
        }

        // Check if we should show the clear slots dialog
        if (viewModel.shouldShowClearSlotsDialog) {
          viewModel.clearShouldShowClearSlotsDialogFlag();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showClearSlotsDialog(context, viewModel);
          });
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showClearSlotsDialog(BuildContext context, CreateCoachViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (BuildContext context) => const ShowClearSlotsBottomSheet(
        height: 230,
        fieldName: "Class Duration",
      ),
    ).then((value) {
      if (value != null) {
        bool data = value as bool;
        if (data) {
          if (!context.mounted) return;
          viewModel.onAcceptSlotTimeChangeRequest();
        } else {
          // User cancelled, revert the duration change
          if (!context.mounted) return;
          viewModel.revertClassDurationChange();
          FocusManager.instance.primaryFocus?.unfocus();
        }
      }
    });
  }

  Widget _buildClassSettingsView(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5.0),
        Text(
          "Class Configuration",
          style: TextStyle(
            fontFamily: 'SFPro',
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 15.0),
        BaseContainer(
          bgColor: customColors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Text(
                "Class Settings",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: customColors.chipText,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 15),
              CommonTextField(
                maxLength: context.read<CreateCoachViewModel>().selectedTrainingType?.id == 2 ? 3 : 4,
                fillColor: customColors.white,
                isNumber: true,
                borderRadius: 6,
                hint: context.read<CreateCoachViewModel>().selectedTrainingType?.id == 2 ? "Maximum Group Size" : "Class Capacity",
                labelText: context.read<CreateCoachViewModel>().selectedTrainingType?.id == 2 ? "Maximum Group Size" : "Class Capacity",
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: context.read<CreateCoachViewModel>().classCapacityController,
                textStyle: TextStyle(
                  fontSize: 16,
                  fontFamily: "Inter",
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter ${context.read<CreateCoachViewModel>().selectedTrainingType?.id == 2 ? "Maximum Group Size" : "Class Capacity"}';
                  }
                  final intValue = int.tryParse(value!);
                  if (intValue == null) {
                    return 'Please enter a valid ${context.read<CreateCoachViewModel>().selectedTrainingType?.id == 2 ? "Maximum Group Size" : "Class Capacity"}';
                  }
                  if (intValue < 1) {
                    return '${context.read<CreateCoachViewModel>().selectedTrainingType?.id == 2 ? "Maximum Group Size" : "Class Capacity"} must be greater than 0';
                  }
                  return null;
                },
                onChanged: (val) => context.read<CreateCoachViewModel>().onChangeClassCapacity(val),
              ),
              const SizedBox(height: 10),
              Text(
                "Maximum participants per class",
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: customColors.hintTextColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (!context.read<CreateCoachViewModel>().isSlotTimeChangeRequestAccepted &&
                            (context.read<CreateCoachViewModel>().addedTimeSlotList.isNotEmpty)) {
                          showModalBottomSheet(
                            context: context,
                            isDismissible: false,
                            enableDrag: false,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            builder: (BuildContext context) => const ShowClearSlotsBottomSheet(
                              height: 230,
                              fieldName: "Class Duration",
                            ),
                          ).then((value) {
                            if (value != null) {
                              bool data = value as bool;
                              if (data) {
                                if (!context.mounted) return;
                                context.read<CreateCoachViewModel>().onAcceptSlotTimeChangeRequest();
                              } else {
                                FocusManager.instance.primaryFocus?.unfocus();
                              }
                            }
                          });
                        }
                      },
                      child: DurationInputField(
                        controller: context.read<CreateCoachViewModel>().classDurationController,
                        labelText: "Class Duration",
                        hintText: "--:--",
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return "Please enter Class Duration";
                          }

                          // Check if it's a complete duration format
                          if (value!.length != 5 || !value.contains(':')) {
                            return 'Please enter duration in HH:MM format';
                          }

                          // Parse the duration to check validity
                          final parts = value.split(':');
                          if (parts.length != 2) {
                            return 'Invalid duration format';
                          }

                          try {
                            int hours = int.parse(parts[0]);
                            int minutes = int.parse(parts[1]);

                            if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59) {
                              return 'Invalid time format';
                            }

                            // Check duration range (1-12 hours)
                            final totalMinutes = hours * 60 + minutes;
                            if (totalMinutes < 60 || totalMinutes > 720) {
                              return 'Class Duration must be between 1 hour and 12 hours';
                            }
                          } catch (e) {
                            return 'Invalid duration format';
                          }

                          return null;
                        },
                        // readOnly: !context.watch<CreateCoachViewModel>().isSlotTimeChangeRequestAccepted,
                        onDurationChangeStarted: () {
                          // Store the current duration before changes
                          context.read<CreateCoachViewModel>().storePreviousClassDuration();
                        },
                        onDurationChanged: (duration) {
                          // Check if there are existing time slots and show confirmation
                          if (context.read<CreateCoachViewModel>().addedTimeSlotList.isNotEmpty) {
                            showModalBottomSheet(
                              context: context,
                              isDismissible: false,
                              enableDrag: false,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              builder: (BuildContext context) => const ShowClearSlotsBottomSheet(
                                height: 230,
                                fieldName: "Class Duration",
                              ),
                            ).then((value) {
                              if (value != null) {
                                bool data = value as bool;
                                if (data) {
                                  if (!context.mounted) return;
                                  context.read<CreateCoachViewModel>().onAcceptSlotTimeChangeRequest();
                                } else {
                                  // User cancelled, revert the duration change
                                  if (!context.mounted) return;
                                  context.read<CreateCoachViewModel>().revertClassDurationChange();
                                  FocusManager.instance.primaryFocus?.unfocus();
                                }
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Text(
                      "hours",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: "Inter",
                        color: customColors.hintTextColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "Minimum 1 hour - coaches can choose longer durations for their classes",
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: customColors.hintTextColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: context.read<CreateCoachViewModel>().popularDurations.map((duration) {
                  return GestureDetector(
                    onTap: () {
                      // Use the setClassDuration method to handle duration change with proper callbacks
                      context.read<CreateCoachViewModel>().setClassDuration(duration);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: customColors.selectedGridItemColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: customColors.lightBlueBorderColor,
                        ),
                      ),
                      child: Text(
                        duration,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface,
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
                'Popular Duration. Click to select quickly.',
                style: TextStyle(
                  fontSize: 12,
                  color: customColors.textGray,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
              // if (context.watch<CreateCoachViewModel>().selectedTrainingType?.id == 1)
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CommonTextField(
                            maxLength: 2,
                            fillColor: customColors.white,
                            isNumber: true,
                            borderRadius: 6,
                            hint: "Min Sessions to Book for Coaching",
                            labelText: "Min Sessions to Book for Coaching",
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            controller: context.read<CreateCoachViewModel>().minSessionController,
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontFamily: "Inter",
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter Min Sessions to Book for Coaching';
                              }

                              final intValue = int.tryParse(value!);
                              if (intValue == null) {
                                return 'Please enter a valid number of Session';
                              }

                              // if (intValue < 1 || intValue > 9) {
                              //   return 'Number of Sessions must be between 1 and 9';
                              // }

                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                      child: Text(
                        "sessions",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "Inter",
                          color: customColors.hintTextColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Minimum number of sessions students must book to get coaching",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: customColors.hintTextColor,
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

  Widget _buildTrainingVenueView(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (context.watch<CreateCoachViewModel>().classCapacityController.text.trim().isNotEmpty)
          Column(
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
                    Text(
                      "Training Venue",
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: customColors.chipText,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    (context.watch<CreateCoachViewModel>().selectedTrainingType?.id == 2)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Training Location",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: customColors.chipText,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              _buildTrainingLocationCheckBoxTitleRow(
                                context,
                                title: "At Coach's Address",
                                isSelected: (context.watch<CreateCoachViewModel>().trainingLocationCheckBoxValue == 1),
                                onTap: () => context.read<CreateCoachViewModel>().onChangeTrainingLocationCheckBoxValue(1),
                              ),
                              _buildTrainingLocationCheckBoxTitleRow(
                                context,
                                title: "Home Training",
                                isSelected: (context.watch<CreateCoachViewModel>().trainingLocationCheckBoxValue == 2),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Alert'),
                                      content: const Text(
                                          'While creating coaching slots ensure sufficient time gap between two slots for your rest and travel time (particularly if training at trainee place)!'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Ok'),
                                        ),
                                      ],
                                    ),
                                  );
                                  context.read<CreateCoachViewModel>().onChangeTrainingLocationCheckBoxValue(2);
                                },
                              ),
                              _buildTrainingLocationCheckBoxTitleRow(
                                context,
                                title: "Both Options Available",
                                isSelected: (context.watch<CreateCoachViewModel>().trainingLocationCheckBoxValue == 3),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Alert'),
                                      content: const Text(
                                          'While creating coaching slots ensure sufficient time gap between two slots for your rest and travel time (particularly if training at trainee place)!'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Ok'),
                                        ),
                                      ],
                                    ),
                                  );
                                  context.read<CreateCoachViewModel>().onChangeTrainingLocationCheckBoxValue(3);
                                },
                              ),
                              const SizedBox(height: 10.0),
                              Text(
                                "Select the training location options you offer",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: customColors.textGray,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                              if (context.watch<CreateCoachViewModel>().trainingLocationCheckBoxValue == 1 ||
                                  context.watch<CreateCoachViewModel>().trainingLocationCheckBoxValue == 3)
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 10.0),
                                    if (context.watch<CreateCoachViewModel>().coachTrainingAddressList?.isNotEmpty ?? false)
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(color: customColors.borderColor),
                                              borderRadius: BorderRadius.circular(6),
                                              color: colorScheme.surface,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 10, right: 10),
                                              child: DropdownButton<CoachTrainingAddress>(
                                                  isExpanded: true,
                                                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: colorScheme.onSurface),
                                                  dropdownColor: customColors.white,
                                                  underline: const SizedBox(),
                                                  borderRadius: BorderRadius.circular(6),
                                                  hint: CustomTextView(
                                                    label: "Select Training Venue",
                                                    textStyle: TextStyle(
                                                      color: customColors.hintTextColor,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                      fontFamily: 'Inter',
                                                    ),
                                                  ),
                                                  value: context.watch<CreateCoachViewModel>().selectedAddress,
                                                  items: context.watch<CreateCoachViewModel>().coachTrainingAddressList?.map((address) {
                                                    return DropdownMenuItem<CoachTrainingAddress>(
                                                      value: address,
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            address.addressName ?? "",
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                              color: colorScheme.onSurface,
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.bold,
                                                              fontFamily: 'Inter',
                                                            ),
                                                          ),
                                                          const SizedBox(height: 5.0),
                                                          Text(
                                                            "${address.address1 ?? ""}${(address.address1 ?? "").isNotEmpty ? ", " : ""}${address.address2 ?? ""}${(address.address2 ?? "").isNotEmpty ? ", " : ""}${address.pinCode ?? ""}",
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                              fontFamily: 'Inter',
                                                              color: customColors.hintTextColor,
                                                              fontWeight: FontWeight.w400,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }).toList(),
                                                  onChanged: (value) => context.read<CreateCoachViewModel>().onSelectTrainingVenue(value)),
                                            ),
                                          ),
                                          const SizedBox(height: 10.0),
                                        ],
                                      ),
                                    CustomButton(
                                      text: "Add New Address",
                                      leadingIcon: Icon(Icons.add, size: 18),
                                      textcolor: colorScheme.onSurface,
                                      buttonColor: customColors.buttonColorGrey,
                                      borderColor: customColors.borderColor,
                                      textsize: 16,
                                      fontWeight: FontWeight.bold,
                                      buttonheight: 50,
                                      radius: 5,
                                      buttonwidth: double.infinity,
                                      onTap: () {
                                        context.read<CreateCoachViewModel>().clearAddressSheetData();
                                        _showAddAddressBottomSheet(context, context.read<CreateCoachViewModel>());
                                      },
                                    ),
                                    const SizedBox(height: 10.0),
                                    Text(
                                      "Select from available venues or add a new custom address",
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: customColors.textGray,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (context.watch<CreateCoachViewModel>().selectedAddress != null)
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 10.0),
                                          BaseContainer(
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
                                                        context.read<CreateCoachViewModel>().selectedAddress?.addressName ?? "",
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                          color: colorScheme.onSurface,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.bold,
                                                          fontFamily: 'Inter',
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5.0),
                                                      Text(
                                                        "${context.read<CreateCoachViewModel>().selectedAddress?.address1 ?? ""}${(context.read<CreateCoachViewModel>().selectedAddress?.address1 ?? "").isNotEmpty ? ", " : ""}${context.read<CreateCoachViewModel>().selectedAddress?.address2 ?? ""}${(context.read<CreateCoachViewModel>().selectedAddress?.address2 ?? "").isNotEmpty ? ", " : ""}${context.read<CreateCoachViewModel>().selectedAddress?.pinCode ?? ""}",
                                                        style: TextStyle(
                                                          fontFamily: 'Inter',
                                                          color: customColors.hintTextColor,
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Training Location",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: customColors.chipText,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              if (context.watch<CreateCoachViewModel>().classCapacity > 0)
                                _buildTrainingLocationCheckBoxTitleRow(
                                  context,
                                  title: "At Coach's Address",
                                  isSelected: (context.watch<CreateCoachViewModel>().trainingLocationCheckBoxValue == 1),
                                  onTap: () => context.read<CreateCoachViewModel>().onChangeTrainingLocationCheckBoxValue(1),
                                ),
                              if (context.watch<CreateCoachViewModel>().classCapacity == 1)
                                _buildTrainingLocationCheckBoxTitleRow(
                                  context,
                                  title: "Home Training",
                                  isSelected: (context.watch<CreateCoachViewModel>().trainingLocationCheckBoxValue == 2),
                                  onTap: () => context.read<CreateCoachViewModel>().onChangeTrainingLocationCheckBoxValue(2),
                                ),
                              if (context.watch<CreateCoachViewModel>().classCapacity == 1)
                                _buildTrainingLocationCheckBoxTitleRow(
                                  context,
                                  title: "Both Options Available",
                                  isSelected: (context.watch<CreateCoachViewModel>().trainingLocationCheckBoxValue == 3),
                                  onTap: () => context.read<CreateCoachViewModel>().onChangeTrainingLocationCheckBoxValue(3),
                                ),
                              const SizedBox(height: 10.0),
                              Text(
                                "Select the training location options you offer",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: customColors.textGray,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                              if (context.watch<CreateCoachViewModel>().trainingLocationCheckBoxValue == 1 ||
                                  context.watch<CreateCoachViewModel>().trainingLocationCheckBoxValue == 3)
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 10.0),
                                    if (context.watch<CreateCoachViewModel>().coachTrainingAddressList?.isNotEmpty ?? false)
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(color: customColors.borderColor),
                                              borderRadius: BorderRadius.circular(6),
                                              color: colorScheme.surface,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 10, right: 10),
                                              child: DropdownButton<CoachTrainingAddress>(
                                                  isExpanded: true,
                                                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: colorScheme.onSurface),
                                                  dropdownColor: customColors.white,
                                                  underline: const SizedBox(),
                                                  borderRadius: BorderRadius.circular(6),
                                                  hint: CustomTextView(
                                                    label: "Select Training Venue",
                                                    textStyle: TextStyle(
                                                      color: customColors.hintTextColor,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                      fontFamily: 'Inter',
                                                    ),
                                                  ),
                                                  value: context.watch<CreateCoachViewModel>().selectedAddress,
                                                  items: context.watch<CreateCoachViewModel>().coachTrainingAddressList?.map((address) {
                                                    return DropdownMenuItem<CoachTrainingAddress>(
                                                      value: address,
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            address.addressName ?? "",
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                              color: colorScheme.onSurface,
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.bold,
                                                              fontFamily: 'Inter',
                                                            ),
                                                          ),
                                                          const SizedBox(height: 5.0),
                                                          Text(
                                                            "${address.address1 ?? ""}${(address.address1 ?? "").isNotEmpty ? ", " : ""}${address.address2 ?? ""}${(address.address2 ?? "").isNotEmpty ? ", " : ""}${address.pinCode ?? ""}",
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                              fontFamily: 'Inter',
                                                              color: customColors.hintTextColor,
                                                              fontWeight: FontWeight.w400,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }).toList(),
                                                  onChanged: (value) => context.read<CreateCoachViewModel>().onSelectTrainingVenue(value)),
                                            ),
                                          ),
                                          const SizedBox(height: 10.0),
                                        ],
                                      ),
                                    CustomButton(
                                      text: "Add New Address",
                                      leadingIcon: Icon(Icons.add, size: 18),
                                      textcolor: colorScheme.onSurface,
                                      buttonColor: customColors.buttonColorGrey,
                                      borderColor: customColors.borderColor,
                                      textsize: 16,
                                      fontWeight: FontWeight.bold,
                                      buttonheight: 50,
                                      radius: 5,
                                      buttonwidth: double.infinity,
                                      onTap: () =>
                                          _showAddAddressBottomSheet(context, context.read<CreateCoachViewModel>()),
                                    ),
                                    const SizedBox(height: 10.0),
                                    Text(
                                      "Select from available venues or add a new custom address",
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: customColors.textGray,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (context.watch<CreateCoachViewModel>().selectedAddress != null)
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 10.0),
                                          BaseContainer(
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
                                                        context.read<CreateCoachViewModel>().selectedAddress?.addressName ?? "",
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                          color: colorScheme.onSurface,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.bold,
                                                          fontFamily: 'Inter',
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5.0),
                                                      Text(
                                                        "${context.read<CreateCoachViewModel>().selectedAddress?.address1 ?? ""}${(context.read<CreateCoachViewModel>().selectedAddress?.address1 ?? "").isNotEmpty ? ", " : ""}${context.read<CreateCoachViewModel>().selectedAddress?.address2 ?? ""}${(context.read<CreateCoachViewModel>().selectedAddress?.address2 ?? "").isNotEmpty ? ", " : ""}${context.read<CreateCoachViewModel>().selectedAddress?.pinCode ?? ""}",
                                                        style: TextStyle(
                                                          fontFamily: 'Inter',
                                                          color: customColors.hintTextColor,
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                            ],
                          ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  void _showAddAddressBottomSheet(BuildContext aContext, CreateCoachViewModel viewModel) {
    final customColors = Theme.of(aContext).extension<CustomColors>()!;
    final colorScheme = Theme.of(aContext).colorScheme;
    showModalBottomSheet(
      context: aContext,
      isScrollControlled: true,
      enableDrag: false,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (mContext) {
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
                      color: customColors.white,
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
                              'Add Training Address',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context, rootNavigator: false).pop();
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
                                key: viewModel.addAddressFormKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Name of Address*',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
                                    ),
                                    const SizedBox(height: 7),
                                    CommonTextField(
                                      maxLength: 50,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      fillColor: customColors.white,
                                      isAddress: true,
                                      borderRadius: 6,
                                      hint: "e.g Main Training Center",
                                      controller: viewModel.nameOfAddressController,
                                      textStyle: TextStyle(
                                        fontSize: 16,
                                        fontFamily: "Inter",
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      validator: (value) {
                                        if (value?.isEmpty ?? true) {
                                          return "Please enter Name of Address";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Address Line 1*',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
                                    ),
                                    const SizedBox(height: 7),
                                    CommonTextField(
                                      maxLength: 100,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      fillColor: customColors.white,
                                      isAddress: true,
                                      borderRadius: 6,
                                      hint: "Street address, building name",
                                      controller: viewModel.addressLineOneController,
                                      textStyle: TextStyle(
                                        fontSize: 16,
                                        fontFamily: "Inter",
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      validator: (value) {
                                        if (value?.isEmpty ?? true) {
                                          return "Please enter Address Line 1";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Address Line 2*',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
                                    ),
                                    const SizedBox(height: 7),
                                    CommonTextField(
                                      maxLength: 100,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      fillColor: customColors.white,
                                      isAddress: true,
                                      borderRadius: 6,
                                      hint: "Apartment, suite, unit, etc.",
                                      controller: viewModel.addressLineTwoController,
                                      textStyle: TextStyle(
                                        fontSize: 16,
                                        fontFamily: "Inter",
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      validator: (value) {
                                        if (value?.isEmpty ?? true) {
                                          return "Please enter Address Line 2";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Pincode*',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
                                    ),
                                    const SizedBox(height: 7),
                                    CommonTextField(
                                      maxLength: 6,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      fillColor: customColors.white,
                                      isNumber: true,
                                      borderRadius: 6,
                                      hint: "Pincode",
                                      controller: viewModel.pincodeController,
                                      textStyle: TextStyle(
                                        fontSize: 16,
                                        fontFamily: "Inter",
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      validator: (value) {
                                        if (value?.isEmpty ?? true) {
                                          return "Please enter Pincode";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 10),
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
                                  textcolor: colorScheme.onSurface,
                                  buttonColor: customColors.buttonBg,
                                  textsize: 16,
                                  fontWeight: FontWeight.bold,
                                  buttonheight: 50,
                                  radius: 10,
                                  buttonwidth: double.infinity,
                                  onTap: () {
                                    Navigator.of(context, rootNavigator: false).pop();
                                  },
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: CustomButton(
                                  text: "Save Address",
                                  textcolor: colorScheme.onPrimary,
                                  buttonColor: colorScheme.primary,
                                  textsize: 16,
                                  fontWeight: FontWeight.bold,
                                  buttonheight: 50,
                                  radius: 10,
                                  buttonwidth: double.infinity,
                                  onTap: () {
                                    if (viewModel.addAddressFormKey.currentState!.validate()) {
                                      Navigator.of(context, rootNavigator: false).pop();
                                      viewModel.onClickOfSaveAddress();
                                    }
                                  },
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

  Widget _buildRateSettingsView(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        BaseContainer(
          bgColor: customColors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Text(
                "Rate Settings",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: customColors.chipText,
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
                        "Same Rate for All Sessions",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: customColors.chipText,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Apply one rate to all time slots",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: customColors.hintTextColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  CustomToggleSwitch(
                    value: context.watch<CreateCoachViewModel>().isSameRates,
                    onChanged: (value) {
                      if (context.read<CreateCoachViewModel>().addedTimeSlotList.isNotEmpty) {
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
                                  context.read<CreateCoachViewModel>().onToggleSameRatesSwitch(value);
                                  Navigator.pop(context);
                                },
                                child: const Text('Yes, Change settings'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        context.read<CreateCoachViewModel>().onToggleSameRatesSwitch(value);
                      }
                    },
                  ),
                ],
              ),
              if (context.watch<CreateCoachViewModel>().isSameRates)
                Column(
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
                          "S \$",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Inter",
                            color: customColors.hintTextColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                        const SizedBox(width: 10.0),
                        Expanded(
                        child: CommonTextField(
                          maxLength: 6,
                          fillColor: customColors.white,
                          controller: context.read<CreateCoachViewModel>().hourlyRateController,
                          isDouble: true,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          normalBorderColor: customColors.borderColor,
                          borderRadius: 6,
                          hint: "Enter hourly rate",
                          labelText: "Hourly Rate",
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontFamily: "Inter",
                            color: colorScheme.onSurface,
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrainingLocationCheckBoxTitleRow(BuildContext context,
      {required String title, required bool isSelected, required Function()? onTap}) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.primary : customColors.greyBG,
                borderRadius: BorderRadius.circular(7),
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 18, color: customColors.onAccentText)
                  : null,
            ),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? colorScheme.onSurface : customColors.hintTextColor,
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
}
