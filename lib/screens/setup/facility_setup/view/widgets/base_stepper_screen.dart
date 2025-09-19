import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_button.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/models/stepper_config_model.dart';
import 'package:oqdo_mobile_app/theme/custom_colors.dart';

class StepperBaseScreen extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<Widget> stepWidgets;
  final StepperConfig config;

  const StepperBaseScreen({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepWidgets,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, asd) {
        if (!didPop) {
          if (config.onBackPressed != null) {
            config.onBackPressed!();
          } else {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        backgroundColor: colorScheme.surface,
        appBar: _buildAppBar(context),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Indicator
            _buildProgressIndicator(context),

            // Step Content (Green highlighted area)
            Expanded(
              child: _buildStepContent(),
            ),

            // Bottom Buttons (Red highlighted area)
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: colorScheme.onSurface,
          size: 24,
        ),
        onPressed: config.onBackPressed ?? () => Navigator.of(context).pop(),
      ),
      title: Text(
        config.appBarTitle,
        style: TextStyle(
          color: customColors.chipText,
          fontFamily: 'Montserrat',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>()!;
    double progress = currentStep / totalSteps;
    int progressPercentage = (progress * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: customColors.containerBG,
          border: Border.all(color: customColors.borderColor, width: 1),
          borderRadius: BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step $currentStep of $totalSteps',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    fontFamily: 'Inter',
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: customColors.lightBlueBGColor,
                  ),
                  child: Text(
                    '$progressPercentage%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.primary,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: customColors.greyBG,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                minHeight: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    if (currentStep <= stepWidgets.length) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: stepWidgets[currentStep - 1],
      );
    }
    return const Center(
      child: Text('Invalid step'),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    bool isFirstStep = currentStep == 1;
    bool isLastStep = currentStep == totalSteps;

    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.all(16.0),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (isFirstStep) Expanded(child: SizedBox(height: 50)),
            // Previous Button
            if (!isFirstStep)
              Expanded(
                child: CustomButton(
                  text: config.previousButtonText,
                  textcolor: colorScheme.onSurface,
                  buttonColor: customColors.buttonBg,
                  textsize: 16,
                  fontWeight: FontWeight.bold,
                  buttonheight: 50,
                  radius: 10,
                  buttonwidth: double.infinity,
                  onTap: config.onPreviousPressed,
                ),
              ),

            const SizedBox(width: 10),

            // Next/Complete Button
            Expanded(
              child: CustomButton(
                text: isLastStep ? config.completeButtonText : config.nextButtonText,
                textcolor: colorScheme.onPrimary,
                buttonColor: colorScheme.primary,
                textsize: 16,
                fontWeight: FontWeight.bold,
                buttonheight: 50,
                radius: 10,
                buttonwidth: double.infinity,
                onTap: () {
                  if (isLastStep) {
                    config.onCompletePressed?.call();
                  } else {
                    config.onNextPressed?.call();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
