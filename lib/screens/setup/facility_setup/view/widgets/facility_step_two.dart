import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/models/selected_image_model.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/view/widgets/base_container.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/view/widgets/duration_input_field.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/viewmodel/create_facility_view_model.dart';
import 'package:oqdo_mobile_app/screens/setup/setups_bottom_sheets/ShowClearSlotsBottomSheet.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_field.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class FacilityStepTwo extends StatelessWidget {
  const FacilityStepTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMessageListener(),
          _buildImageAndDescriptionView(context),
          Form(
            key: context.read<CreateFacilityViewModel>().secondStepFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAboutFacilityFeatureView(context),
                _buildConfigureFacilityDetailsView(context),
              ],
            ),
          ),
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

  void _showClearSlotsDialog(BuildContext context, CreateFacilityViewModel viewModel) {
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
      backgroundColor: OQDOThemeData.whiteColor,
      builder: (BuildContext context) => const ShowClearSlotsBottomSheet(
        height: 230,
        fieldName: "Rental Duration",
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
          viewModel.revertRentalDurationChange();
          FocusManager.instance.primaryFocus?.unfocus();
        }
      }
    });
  }

  Widget _buildImageAndDescriptionView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5.0),
        Text(
          "Images & Description",
          style: TextStyle(
            fontFamily: 'SFPro',
            color: ColorsUtils.primary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 15.0),
        BaseContainer(
          bgColor: ColorsUtils.white,
          width: double.infinity,
          child: _buildGalleryImageSelectionView(context),
        ),
        const SizedBox(height: 20.0),
        BaseContainer(
          bgColor: ColorsUtils.white,
          width: double.infinity,
          child: _buildCoverImageSelectionView(context),
        ),
        const SizedBox(height: 20.0),
        Text(
          "Add a cover image and up to 3 gallery photos showcasing your facility.",
          style: TextStyle(
            fontFamily: 'Inter',
            color: ColorsUtils.hintTextColor,
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryImageSelectionView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Gallery",
          style: TextStyle(
            fontFamily: 'Montserrat',
            color: ColorsUtils.chipText,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 15.0),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            // Gallery selection icon (always first)
            _buildGallerySelectionTile(context, true),

            // Selected images
            ...context.watch<CreateFacilityViewModel>().galleryImages.map(
                  (image) => _buildSelectedImageTile(context, image, true),
                ),
          ],
        ),
      ],
    );
  }

  Widget _buildGallerySelectionTile(BuildContext context, bool forGallery) {
    return GestureDetector(
      onTap: () async {
        if (forGallery) {
          if (context.read<CreateFacilityViewModel>().galleryImages.length > 2) {
            showSnackBar('Maximum 3 images allowed', context);
          } else {
            context.read<CreateFacilityViewModel>().getMultiplePicFromGallery();
          }
        } else {
          if (context.read<CreateFacilityViewModel>().selectedCoverImage != null) {
            showSnackBar('Maximum 1 image allowed', context);
            return;
          }
          bottomSheetImage(context);
        }
      },
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: ColorsUtils.lightBlueBGColor,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: ColorsUtils.primary, width: 1),
        ),
        child: Center(
          child: SizedBox(
            height: 30,
            width: 35,
            child: Image.asset("assets/images/ic_camera_blue.png"),
          ),
        ),
      ),
    );
  }

  void bottomSheetImage(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (mContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text(
                  'Photo Library',
                  style: TextStyle(),
                ),
                onTap: () async {
                  if (Constants.androidVersion >= 13) {
                    Navigator.of(context, rootNavigator: false).pop();
                    context.read<CreateFacilityViewModel>().getSinglePhotoFromGallery();
                  } else {
                    var status = await Permission.storage.request();
                    if (status == PermissionStatus.granted) {
                      if (!context.mounted) return;
                      Navigator.of(context, rootNavigator: false).pop();
                      context.read<CreateFacilityViewModel>().getSinglePhotoFromGallery();
                    } else if (status == PermissionStatus.denied) {
                      if (!context.mounted) return;
                      showSnackBar('Permission denied.Please Allow Permission.', context);
                    } else if (status == PermissionStatus.permanentlyDenied) {
                      await openAppSettings();
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text(
                  'Camera',
                  style: TextStyle(),
                ),
                onTap: () async {
                  var status = await Permission.camera.request();
                  if (status == PermissionStatus.granted) {
                    if (!context.mounted) return;
                    Navigator.of(context, rootNavigator: false).pop();
                    context.read<CreateFacilityViewModel>().getPhotoFromCamera();
                  } else if (status == PermissionStatus.denied) {
                    if (status == PermissionStatus.granted) {
                      if (!context.mounted) return;
                      Navigator.of(context, rootNavigator: false).pop();
                      context.read<CreateFacilityViewModel>().getPhotoFromCamera();
                    } else {
                      if (!context.mounted) return;
                      showSnackBar('Permission denied.Please Allow Permission.', context);
                    }
                  } else if (status == PermissionStatus.permanentlyDenied) {
                    await openAppSettings();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedImageTile(BuildContext context, SelectedImageModel image, bool forGallery) {
    return Stack(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: (image.image?.path != null)
                ? Image.file(
                    File(image.image!.path),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.error,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  )
                : CachedNetworkImage(
                    imageUrl: image.editTimeImageUrl ?? "",
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.error_outline,
                      size: 40,
                    ),
                  ),
          ),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: GestureDetector(
            onTap: () {
              if (forGallery) {
                context.read<CreateFacilityViewModel>().removeGalleryImage(image);
              } else {
                context.read<CreateFacilityViewModel>().removeCoverImage();
              }
            },
            child: SizedBox(
              height: 14,
              width: 14,
              child: Image.asset("assets/images/ic_cross_with_black_bg.png"),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoverImageSelectionView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Cover Image",
          style: TextStyle(
            fontFamily: 'Montserrat',
            color: ColorsUtils.chipText,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 15.0),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            // Cover selection icon (always first)
            _buildGallerySelectionTile(context, false),

            // Selected image
            if (context.watch<CreateFacilityViewModel>().selectedCoverImage != null)
              _buildSelectedImageTile(context, context.watch<CreateFacilityViewModel>().selectedCoverImage!, false),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutFacilityFeatureView(BuildContext context) {
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
                    "Tell users about your facility's features",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: ColorsUtils.chipText,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15.0),
              CommonTextField(
                maxLength: 250,
                fillColor: ColorsUtils.white,
                borderRadius: 6,
                maxLines: 4,
                hint: "Facility Description",
                labelText: "Facility Description",
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: context.read<CreateFacilityViewModel>().descriptionController,
                textStyle: TextStyle(
                  fontSize: 16,
                  fontFamily: "Inter",
                  color: ColorsUtils.black,
                  fontWeight: FontWeight.w500,
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return "Please enter Facility Description";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10.0),
              Text(
                "Describe your facility's features and amenities.",
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

  Widget _buildConfigureFacilityDetailsView(BuildContext context) {
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
                "Configure your facility details",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: ColorsUtils.chipText,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (!context.read<CreateFacilityViewModel>().isSlotTimeChangeRequestAccepted &&
                            (context.read<CreateFacilityViewModel>().addedTimeSlotList.isNotEmpty)) {
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
                            backgroundColor: OQDOThemeData.whiteColor,
                            builder: (BuildContext context) => const ShowClearSlotsBottomSheet(
                              height: 230,
                              fieldName: "Rental Duration",
                            ),
                          ).then((value) {
                            if (value != null) {
                              bool data = value as bool;
                              if (data) {
                                if (!context.mounted) return;
                                context.read<CreateFacilityViewModel>().onAcceptSlotTimeChangeRequest();
                              } else {
                                FocusManager.instance.primaryFocus?.unfocus();
                              }
                            }
                          });
                        }
                      },
                      child: DurationInputField(
                        controller: context.read<CreateFacilityViewModel>().rentalDurationController,
                        labelText: "Rental Duration",
                        hintText: "--:--",
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return "Please enter Rental Duration";
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
                              return 'Rental Duration must be between 1 hour and 12 hours';
                            }
                          } catch (e) {
                            return 'Invalid duration format';
                          }

                          return null;
                        },
                        // readOnly: !context.watch<CreateFacilityViewModel>().isSlotTimeChangeRequestAccepted,
                        onDurationChangeStarted: () {
                          // Store the current duration before changes
                          context.read<CreateFacilityViewModel>().storePreviousRentalDuration();
                        },
                        onDurationChanged: (duration) {
                          // Check if there are existing time slots and show confirmation
                          if (context.read<CreateFacilityViewModel>().addedTimeSlotList.isNotEmpty) {
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
                              backgroundColor: OQDOThemeData.whiteColor,
                              builder: (BuildContext context) => const ShowClearSlotsBottomSheet(
                                height: 230,
                                fieldName: "Rental Duration",
                              ),
                            ).then((value) {
                              if (value != null) {
                                bool data = value as bool;
                                if (data) {
                                  if (!context.mounted) return;
                                  context.read<CreateFacilityViewModel>().onAcceptSlotTimeChangeRequest();
                                } else {
                                  // User cancelled, revert the duration change
                                  if (!context.mounted) return;
                                  context.read<CreateFacilityViewModel>().revertRentalDurationChange();
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
                        color: ColorsUtils.hintTextColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "Minimum 1 hour -  booking duration for users",
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: ColorsUtils.hintTextColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: context.read<CreateFacilityViewModel>().popularDurations.map((duration) {
                  return GestureDetector(
                    onTap: () {
                      // Use the setRentalDuration method to handle duration change with proper callbacks
                      context.read<CreateFacilityViewModel>().setRentalDuration(duration);
                    },
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
                        duration,
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
                'Popular Duration. Click to select quickly.',
                style: TextStyle(
                  fontSize: 12,
                  color: ColorsUtils.textGray,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 15),
              CommonTextField(
                maxLength: 3,
                fillColor: ColorsUtils.white,
                isNumber: true,
                borderRadius: 6,
                hint: (context.watch<CreateFacilityViewModel>().selectedBookingType?.id == 1)
                    ? "Facility Capacity"
                    : "Maximum Group Size",
                labelText: (context.watch<CreateFacilityViewModel>().selectedBookingType?.id == 1)
                    ? "Facility Capacity"
                    : "Maximum Group Size",
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: context.read<CreateFacilityViewModel>().capacityController,
                textStyle: TextStyle(
                  fontSize: 16,
                  fontFamily: "Inter",
                  color: ColorsUtils.black,
                  fontWeight: FontWeight.w500,
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return (context.watch<CreateFacilityViewModel>().selectedBookingType?.id == 1)
                        ? "Please enter Facility Capacity"
                        : "Please enter Maximum Group Size";
                  }

                  final intValue = int.tryParse(value!);
                  if (intValue == null) {
                    return (context.watch<CreateFacilityViewModel>().selectedBookingType?.id == 1)
                        ? 'Please enter a valid Facility Capacity'
                        : 'Please enter a valid Maximum Group Size';
                  }

                  if (intValue < 1) {
                    return (context.watch<CreateFacilityViewModel>().selectedBookingType?.id == 1)
                        ? 'Facility Capacity must be greater than 0'
                        : 'Maximum Group Size must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Text(
                "Maximum number of people allowed to book the facility",
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
