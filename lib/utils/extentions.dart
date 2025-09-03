import 'package:flutter/material.dart';

extension VisibilityExtension on Widget {
  Widget visible(bool isVisible) {
    return isVisible ? this : const SizedBox.shrink();
  }
}
