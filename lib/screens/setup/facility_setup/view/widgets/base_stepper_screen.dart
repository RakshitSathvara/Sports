import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_button.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/models/stepper_config_model.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';

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
        backgroundColor: ColorsUtils.white,
        appBar: _buildAppBar(context),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Indicator
            _buildProgressIndicator(),

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
    return AppBar(
      backgroundColor: ColorsUtils.white,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: ColorsUtils.black,
          size: 24,
        ),
        onPressed: config.onBackPressed ?? () => Navigator.of(context).pop(),
      ),
      title: Text(
        config.appBarTitle,
        style: TextStyle(
          color: ColorsUtils.chipText,
          fontFamily: 'Montserrat',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    double progress = currentStep / totalSteps;
    int progressPercentage = (progress * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: ColorsUtils.white,
          border: Border.all(color: ColorsUtils.borderColor, width: 1),
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
                    color: ColorsUtils.black,
                    fontFamily: 'Inter',
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: ColorsUtils.lightBlueBGColor),
                  child: Text(
                    '$progressPercentage%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: ColorsUtils.primary,
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
                backgroundColor: ColorsUtils.greyBG,
                valueColor: const AlwaysStoppedAnimation<Color>(ColorsUtils.primary),
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

    return Container(
      color: Colors.white,
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
                  textcolor: ColorsUtils.black,
                  buttonColor: ColorsUtils.buttonBg,
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
                textcolor: ColorsUtils.white,
                buttonColor: ColorsUtils.primary,
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
