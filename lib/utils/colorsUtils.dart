import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/theme/app_colors.dart';

class ColorsUtils {

  static Color redColor = AppColors.redColor;
  static Color redDeleteColor = AppColors.redDeleteColor;
  static Color redAmount = AppColors.redAmount;
  static Color greenAmount = AppColors.greenAmount;
  static Color pendingAmount = AppColors.pendingAmount;


  static Color greyButtonTheme(BuildContext context) => AppColors.greyButton;
  static Color greyCircleTheme(BuildContext context) => AppColors.greyCircle;
  static Color vacationListTheme(BuildContext context) => AppColors.vacationList;
  static Color greyTextTheme(BuildContext context) => AppColors.greyText;
  static Color subTitleTheme(BuildContext context) => AppColors.subTitle;
  static Color chipBackgroundTheme(BuildContext context) => AppColors.chipBackground;
  static Color chipTextTheme(BuildContext context) => AppColors.chipText;
  static Color edittextBackProfileTheme(BuildContext context) => AppColors.edittextBackProfile;
  static Color whiteTheme(BuildContext context) => AppColors.white;
  static Color messageLeftTheme(BuildContext context) => AppColors.messageLeft;
  static Color messageRightTheme(BuildContext context) => AppColors.messageRight;
  static Color greyTabTheme(BuildContext context) => AppColors.greyTab;
  static Color greyAmountTheme(BuildContext context) => AppColors.greyAmount;
  static Color yellowStatusTheme(BuildContext context) => AppColors.yellowStatus;

  static Color getThemeColor(BuildContext context, Color lightColor, Color darkColor) {
    return Theme.of(context).brightness == Brightness.dark ? darkColor : lightColor;
  }

  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.background;
  }
}


