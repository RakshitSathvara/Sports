import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/providers/theme_provider.dart';

class ColorsUtils {
  static bool get _isDark => ThemeProvider().isDarkMode;

  static Color get greyButton =>
      _isDark ? const Color(0xFF333333) : const Color(0xFFEFEFEF);
  static Color get greyCircle =>
      _isDark ? const Color(0xFF404040) : const Color(0xFFE2E2E8);
  static Color get redColor =>
      _isDark ? const Color(0xFFFF6B6B) : const Color(0xFFFF0000);
  static Color get redDeleteColor =>
      _isDark ? const Color(0xFFFF5252) : const Color(0xFFEE2B2F);
  static Color get vacationList =>
      _isDark ? const Color(0xFF4A90A4) : const Color(0xFF80b2c7);
  static Color get greyText =>
      _isDark ? const Color(0xFFB0B0B0) : const Color(0xFF818181);
  static Color get subTitle =>
      _isDark ? const Color(0xFFD0D0D0) : const Color(0xFF3A3A3A);
  static Color get chipBackground =>
      _isDark ? const Color(0xFF2A3540) : const Color(0xFFE1EDF2);
  static Color get chipText =>
      _isDark ? const Color(0xFFD0D0D0) : const Color(0xFF2B2B2B);
  static Color get edittextBackProfile =>
      _isDark ? const Color(0xFF404040) : const Color(0xFFD9D9D9);
  static Color get white =>
      _isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
  static Color get messageLeft =>
      _isDark ? const Color(0xFF2A4A57) : const Color(0xFFC7DDE7);
  static Color get messageRight =>
      _isDark ? const Color(0xFF404040) : const Color(0xFFC7C7C7);
  static Color get greyTab =>
      _isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F8F8);
  static Color get greyAmount =>
      _isDark ? const Color(0xFFB0B0B0) : const Color(0xFF656565);
  static Color get redAmount =>
      _isDark ? const Color(0xFFFF6B6B) : const Color(0xFFFF0000);
  static Color get greenAmount =>
      _isDark ? const Color(0xFF4CAF50) : const Color(0xFF008000);
  static Color get pendingAmount =>
      _isDark ? const Color(0xFFFFA726) : const Color(0xFFB59800);
  static Color get yellowStatus =>
      _isDark ? const Color(0xFFFFD54F) : const Color(0xFFE1B000);

  /// Background color for the refer and earn section
  static Color get referEarnColor =>
      _isDark ? const Color(0xFF4FC3F7) : const Color(0xFF006590);

  /// Background color for the close account button
  static Color get closeAccountColor =>
      _isDark ? const Color(0xFFFF5252) : const Color(0xFFFC5555);
}
