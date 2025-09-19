// Configuration class for stepper customization
import 'package:flutter/material.dart';

class StepperConfig {
  final String appBarTitle;
  final bool showPreview;
  final String nextButtonText;
  final String previousButtonText;
  final String completeButtonText;
  final VoidCallback? onNextPressed;
  final VoidCallback? onPreviousPressed;
  final VoidCallback? onCompletePressed;
  final VoidCallback? onBackPressed;

  const StepperConfig({
    required this.appBarTitle,
    this.showPreview = false,
    this.nextButtonText = 'Next',
    this.previousButtonText = 'Previous',
    this.completeButtonText = 'Save and Preview',
    this.onNextPressed,
    this.onPreviousPressed,
    this.onCompletePressed,
    this.onBackPressed,
  });
}