import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/screens/setup/coach_setup/view/widgets/coach_step_one.dart';
import 'package:oqdo_mobile_app/screens/setup/coach_setup/view/widgets/coach_step_three.dart';
import 'package:oqdo_mobile_app/screens/setup/coach_setup/view/widgets/coach_step_two.dart';
import 'package:oqdo_mobile_app/screens/setup/coach_setup/viewmodel/create_coach_view_model.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/models/stepper_config_model.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/view/widgets/base_stepper_screen.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/viewmodel/stepper_mixin.dart';
import 'package:oqdo_mobile_app/screens/setup/setups_bottom_sheets/Show24HrsAleartBottomSheet.dart';
import 'package:oqdo_mobile_app/screens/setup/setups_bottom_sheets/ShowEditFacilityCoachChangesBottomSheet.dart';
import 'package:oqdo_mobile_app/screens/setup/setups_bottom_sheets/ShowSaveDiscardBottomSheet.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class CreateCoachSetupPage extends StatelessWidget {
  static const String routeName = '/create_coach_setup_page';

  const CreateCoachSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateCoachViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.progressDialog == null) {
          viewModel.progressDialog = ProgressDialog(context,
              type: ProgressDialogType.normal, isDismissible: false);
          viewModel.progressDialog?.style(message: "Please wait..");
        }
        if (viewModel.getLoaderState == LoaderState.showLoader) {
          viewModel.setLoaderState();
          viewModel.progressDialog?.show();
        }
        if (viewModel.getLoaderState == LoaderState.hideLoader) {
          viewModel.setLoaderState();
          viewModel.progressDialog?.hide();
        }
        return StepperBaseScreen(
          currentStep: viewModel.currentStep,
          totalSteps: viewModel.totalSteps,
          stepWidgets: const [
            CoachStepOne(),
            CoachStepTwo(),
            CoachStepThree(),
          ],
          config: StepperConfig(
            appBarTitle: viewModel.isEdit ? 'Edit Batch Setup' : 'Create Batch Setup',
            showPreview: true,
            onBackPressed: () => viewModel.onBackPressed(context),
            onNextPressed: viewModel.nextStep,
            onPreviousPressed: viewModel.previousStep,
            onCompletePressed: () =>
                _handleCoachSetupSaveAndPreview(context, viewModel),
          ),
        );
      },
    );
  }

  void _handleCoachSetupSaveAndPreview(
      BuildContext context, CreateCoachViewModel viewModel) {
    hideKeyboard();
    if (viewModel.addedTimeSlotList.isEmpty) {
      showSnackBar("Please add at least one Training Slot", context);
      return;
    }
    if (viewModel.isEdit) {
      handleEditSetupApiCall(viewModel, context);
    } else {
      handleSaveAndPreviewApiCall(viewModel, context);
    }
  }

  void handleSaveAndPreviewApiCall(
      CreateCoachViewModel viewModel, BuildContext context) async {
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
      builder: (ctx) => const Show24HrsAlearBottomSheet(),
    ).then((value) {
      if (value != null) {
        bool data = value as bool;
        if (data) {
          hideKeyboard();
          viewModel.addBatchSetupCall();
        }
      }
    });
  }

  void handleEditSetupApiCall(
      CreateCoachViewModel viewModel, BuildContext context) async {
    await viewModel.checkForChanges();
    
    // Check if only name has changed
    bool onlyNameChanged = viewModel.isNameChanged &&
        !viewModel.isPriceChanged &&
        !viewModel.isCapacityChanged &&
        !viewModel.isTrainingLocationChanged &&
        !viewModel.isClassDurationChanged &&
        !viewModel.isMinSessionChanged &&
        !viewModel.isSlotsChanged;
    
    // Check if anything other than name has changed
    bool otherChanges = viewModel.isPriceChanged ||
        viewModel.isCapacityChanged ||
        viewModel.isTrainingLocationChanged ||
        viewModel.isClassDurationChanged ||
        viewModel.isMinSessionChanged ||
        viewModel.isSlotsChanged;
    
    if (onlyNameChanged) {
      // If only name changed, call updateBasicInfo
      if (!context.mounted) return;
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
        builder: (ctx) => const Show24HrsAlearBottomSheet(),
      ).then((value) {
        if (value != null) {
          bool data = value as bool;
          if (data) {
            viewModel.updateBasicInfo();
          } else {
            if (!context.mounted) return;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => const ShowSaveDiscardBottomSheet(),
            ).then((value) {
              if (value != null) {
                bool data = value as bool;
                if (data) {
                  viewModel.updateBasicInfo();
                } else {
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                }
              }
            });
          }
        }
      });
    } else if (otherChanges) {
      if (!context.mounted) return;
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
        builder: (ctx) => ShowEditFacilityCoachChangesBottomSheet(
          type: 'C',
        ),
      ).then((value) {
        if (value != null) {
          bool data = value as bool;
          if (data) {
            if (!context.mounted) return;
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
              builder: (ctx) => const Show24HrsAlearBottomSheet(),
            ).then((value) {
              if (value != null) {
                bool data = value as bool;
                if (data) {
                  viewModel.addBatchSetupCall();
                } else {
                  if (!context.mounted) return;
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => const ShowSaveDiscardBottomSheet(),
                  ).then((value) {
                    if (value != null) {
                      bool data = value as bool;
                      if (data) {
                        viewModel.addBatchSetupCall();
                      } else {
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                      }
                    }
                  });
                }
              }
            });
          } else {
            if (!context.mounted) return;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => const ShowSaveDiscardBottomSheet(),
            ).then((value) {
              if (value != null) {
                bool data = value as bool;
                if (data) {
                  if (!context.mounted) return;
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
                    builder: (ctx) => const Show24HrsAlearBottomSheet(),
                  ).then((value) {
                    if (value != null) {
                      bool data = value as bool;
                      if (data) {
                        viewModel.addBatchSetupCall();
                      } else {
                        if (!context.mounted) return;
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) => const ShowSaveDiscardBottomSheet(),
                        ).then((value) {
                          if (value != null) {
                            bool data = value as bool;
                            if (data) {
                              viewModel.addBatchSetupCall();
                            } else {
                              if (!context.mounted) return;
                              Navigator.of(context).pop();
                            }
                          }
                        });
                      }
                    }
                  });
                } else {
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                }
              }
            });
          }
        }
      });
    } else {
      // No changes detected - just go back
      if (!context.mounted) return;
      Navigator.of(context).pop();
    }
  }
}
