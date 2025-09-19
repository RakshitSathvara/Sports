import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/models/stepper_config_model.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/view/widgets/base_stepper_screen.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/view/widgets/facility_step_one.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/view/widgets/facility_step_three.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/view/widgets/facility_step_two.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/viewmodel/create_facility_view_model.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/viewmodel/stepper_mixin.dart';
import 'package:oqdo_mobile_app/screens/setup/setups_bottom_sheets/Show24HrsAleartBottomSheet.dart';
import 'package:oqdo_mobile_app/screens/setup/setups_bottom_sheets/ShowEditFacilityCoachChangesBottomSheet.dart';
import 'package:oqdo_mobile_app/screens/setup/setups_bottom_sheets/ShowSaveDiscardBottomSheet.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class CreateFacilitySetupPage extends StatelessWidget {
  static const String routeName = '/create_facility_setup_page';

  const CreateFacilitySetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateFacilityViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.progressDialog == null) {
          viewModel.progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
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
            FacilityStepOne(),
            FacilityStepTwo(),
            FacilityStepThree(),
          ],
          config: StepperConfig(
            appBarTitle: viewModel.isEdit ? 'Edit Facility Setup' : 'Create Facility Setup',
            showPreview: true,
            onBackPressed: () => viewModel.onBackPressed(context),
            onNextPressed: viewModel.nextStep,
            onPreviousPressed: viewModel.previousStep,
            onCompletePressed: () => _handleFacilitySetupSaveAndPreview(context, viewModel),
          ),
        );
      },
    );
  }

  void _handleFacilitySetupSaveAndPreview(BuildContext context, CreateFacilityViewModel viewModel) {
    hideKeyboard();
    if (viewModel.isSameRates && (!(viewModel.thirdStepFormKey.currentState!.validate()))) {
      return;
    } else if (viewModel.addedTimeSlotList.isEmpty) {
      showSnackBar("Please add at least one time slot", context);
      return;
    }
    if (viewModel.isEdit) {
      handleEditSetupApiCall(viewModel, context);
    } else {
      handleSaveAndPreviewApiCall(viewModel, context);
    }
  }

  Future<void> handleSaveAndPreviewApiCall(CreateFacilityViewModel viewModel, BuildContext context) async {
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
      builder: (ctx) => const Show24HrsAlearBottomSheet(),
    ).then((value) {
      if (value != null) {
        bool data = value as bool;
        if (data) {
          hideKeyboard();
          viewModel.setupApiCall();
        }
      }
    });
  }

  Future<void> handleEditSetupApiCall(CreateFacilityViewModel viewModel, BuildContext context) async {
    await viewModel.checkForChanges();
    if (viewModel.isPriceChanged ||
        viewModel.isCapacityChanged ||
        viewModel.isBookingTypeChanged ||
        viewModel.isSlotsChanged ||
        viewModel.isSlotDurationChanged) {
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        builder: (ctx) => ShowEditFacilityCoachChangesBottomSheet(
          type: 'F',
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
              backgroundColor: Theme.of(context).colorScheme.surface,
              builder: (ctx) => const Show24HrsAlearBottomSheet(),
            ).then((value) {
              if (value != null) {
                bool data = value as bool;
                if (data) {
                  viewModel.setupApiCall();
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
                        viewModel.setupApiCall();
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
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    builder: (ctx) => const Show24HrsAlearBottomSheet(),
                  ).then((value) {
                    if (value != null) {
                      bool data = value as bool;
                      if (data) {
                        viewModel.setupApiCall();
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
                              viewModel.setupApiCall();
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
        backgroundColor: Theme.of(context).colorScheme.surface,
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
    }
  }
}
