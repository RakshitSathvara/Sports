import 'package:flutter/material.dart';

class AppColors {
  static const Color blackColor = Colors.black;
  static const Color whiteColor = Colors.white;
  static const Color backgroundColor = Colors.white;
  static const Color greyColor = Color(0xFF2B2B2B);
  static const Color dividerColor = Color(0xFF006590);
  static const Color otherTextColor = Color(0xFF818181);
  static const Color filterDividerColor = Color(0xFFE3E3E3);
  static const Color dialogActionColor = Color(0xFF007AFF);
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;
  static const Color offlineColor = Color(0xFFFF5F1F);
  static const Color onlineColor = Color(0xFF00A36C);
  static const Color chipColor = Color.fromRGBO(118, 115, 115, 1);
  static const Color buttonColor = Color(0xFF3C80A8);
  static const Color hobbiesListing = Color(0xFFEBF3F6);
  static const Color wellnessListing = Color(0xFFF7ECEC);
  static const Color sportsListing = Color(0xFFEBF4ED);
  static Color greyButton = parseColor("#EFEFEF");
  static Color greyCircle = parseColor("#E2E2E8");
  static Color redColor = parseColor("#FF0000");
  static Color redDeleteColor = parseColor("#EE2B2F");
  static Color vacationList = parseColor("#80b2c7");
  static Color greyText = parseColor("#818181");
  static Color subTitle = parseColor("#3A3A3A");
  static Color chipBackground = parseColor("#e1edf2");
  static Color chipText = parseColor("#2B2B2B");
  static Color edittextBackProfile = parseColor("#D9D9D9");
  static Color white = parseColor("#FFFFFF");
  static Color messageLeft = parseColor("#C7DDE7");
  static Color messageRight = parseColor("#C7C7C7");
  static Color greyTab = parseColor("#F8F8F8");
  static Color greyAmount = parseColor("#656565");
  static Color redAmount = parseColor("#FF0000");
  static Color greenAmount = parseColor("#008000");
  static Color pendingAmount = parseColor("#B59800");
  static Color yellowStatus = parseColor("#E1B000");

  static Color parseColor(String color) {
    String hex = color.replaceAll("#", "");
    if (hex.isEmpty) hex = "ffffff";
    if (hex.length == 3) {
      hex =
      '${hex.substring(0, 1)}${hex.substring(0, 1)}${hex.substring(1, 2)}${hex.substring(1, 2)}${hex.substring(2, 3)}${hex.substring(2, 3)}';
    }
    Color col = Color(int.parse(hex, radix: 16)).withOpacity(1.0);
    return col;
  }
}
