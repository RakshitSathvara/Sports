import 'package:flutter/material.dart';

class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.greyButton,
    required this.greyCircle,
    required this.redColor,
    required this.redDeleteColor,
    required this.vacationList,
    required this.greyText,
    required this.subTitle,
    required this.chipBackground,
    required this.chipText,
    required this.edittextBackProfile,
    required this.white,
    required this.messageLeft,
    required this.messageRight,
    required this.greyTab,
    required this.greyAmount,
    required this.redAmount,
    required this.greenAmount,
    required this.pendingAmount,
    required this.yellowStatus,
    required this.filterDivider,
    required this.referEarnColor,
    required this.closeAccountColor,
    required this.chatPrimary,
    required this.accentBlue,
    required this.profileBlue,
    required this.buddiesBackground,
    required this.buddiesCard,
    required this.buddiesBorder,
  });

  final Color greyButton;
  final Color greyCircle;
  final Color redColor;
  final Color redDeleteColor;
  final Color vacationList;
  final Color greyText;
  final Color subTitle;
  final Color chipBackground;
  final Color chipText;
  final Color edittextBackProfile;
  final Color white;
  final Color messageLeft;
  final Color messageRight;
  final Color greyTab;
  final Color greyAmount;
  final Color redAmount;
  final Color greenAmount;
  final Color pendingAmount;
  final Color yellowStatus;
  final Color filterDivider;
  final Color referEarnColor;
  final Color closeAccountColor;
  final Color chatPrimary;
  final Color accentBlue;
  final Color profileBlue;
  final Color buddiesBackground;
  final Color buddiesCard;
  final Color buddiesBorder;

  static const CustomColors light = CustomColors(
    greyButton: Color(0xFFEFEFEF),
    greyCircle: Color(0xFFE2E2E8),
    redColor: Color(0xFFFF0000),
    redDeleteColor: Color(0xFFEE2B2F),
    vacationList: Color(0xFF80B2C7),
    greyText: Color(0xFF818181),
    subTitle: Color(0xFF3A3A3A),
    chipBackground: Color(0xFFE1EDF2),
    chipText: Color(0xFF2B2B2B),
    edittextBackProfile: Color(0xFFD9D9D9),
    white: Color(0xFFFFFFFF),
    messageLeft: Color(0xFFC7DDE7),
    messageRight: Color(0xFFC7C7C7),
    greyTab: Color(0xFFF8F8F8),
    greyAmount: Color(0xFF656565),
    redAmount: Color(0xFFFF0000),
    greenAmount: Color(0xFF008000),
    pendingAmount: Color(0xFFB59800),
    yellowStatus: Color(0xFFE1B000),
    filterDivider: Color(0xFFE3E3E3),
    referEarnColor: Color(0xFF006590),
    closeAccountColor: Color(0xFFFC5555),
    chatPrimary: Color(0xFF2B5278),
    accentBlue: Color(0xFF006590),
    profileBlue: Color(0xFF3C80A8),
    buddiesBackground: Color(0xFFF5F5F5),
    buddiesCard: Color(0xFFF1F1F1),
    buddiesBorder: Color(0xFFCFCFCF),
  );

  static const CustomColors dark = CustomColors(
    greyButton: Color(0xFF333333),
    greyCircle: Color(0xFF404040),
    redColor: Color(0xFFFF6B6B),
    redDeleteColor: Color(0xFFFF5252),
    vacationList: Color(0xFF4A90A4),
    greyText: Color(0xFFB0B0B0),
    subTitle: Color(0xFFD0D0D0),
    chipBackground: Color(0xFF2A3540),
    chipText: Color(0xFFD0D0D0),
    edittextBackProfile: Color(0xFF404040),
    white: Color(0xFF1E1E1E),
    messageLeft: Color(0xFF2A4A57),
    messageRight: Color(0xFF404040),
    greyTab: Color(0xFF2A2A2A),
    greyAmount: Color(0xFFB0B0B0),
    redAmount: Color(0xFFFF6B6B),
    greenAmount: Color(0xFF4CAF50),
    pendingAmount: Color(0xFFFFA726),
    yellowStatus: Color(0xFFFFD54F),
    filterDivider: Color(0xFF404040),
    referEarnColor: Color(0xFF4FC3F7),
    closeAccountColor: Color(0xFFFF5252),
    chatPrimary: Color(0xFF2B5278),
    accentBlue: Color(0xFF4FC3F7),
    profileBlue: Color(0xFF4FC3F7),
    buddiesBackground: Color(0xFF2A2A2A),
    buddiesCard: Color(0xFF333333),
    buddiesBorder: Color(0xFF404040),
  );

  @override
  CustomColors copyWith({
    Color? greyButton,
    Color? greyCircle,
    Color? redColor,
    Color? redDeleteColor,
    Color? vacationList,
    Color? greyText,
    Color? subTitle,
    Color? chipBackground,
    Color? chipText,
    Color? edittextBackProfile,
    Color? white,
    Color? messageLeft,
    Color? messageRight,
    Color? greyTab,
    Color? greyAmount,
    Color? redAmount,
    Color? greenAmount,
    Color? pendingAmount,
    Color? yellowStatus,
    Color? filterDivider,
    Color? referEarnColor,
    Color? closeAccountColor,
    Color? chatPrimary,
    Color? accentBlue,
    Color? profileBlue,
    Color? buddiesBackground,
    Color? buddiesCard,
    Color? buddiesBorder,
  }) {
    return CustomColors(
      greyButton: greyButton ?? this.greyButton,
      greyCircle: greyCircle ?? this.greyCircle,
      redColor: redColor ?? this.redColor,
      redDeleteColor: redDeleteColor ?? this.redDeleteColor,
      vacationList: vacationList ?? this.vacationList,
      greyText: greyText ?? this.greyText,
      subTitle: subTitle ?? this.subTitle,
      chipBackground: chipBackground ?? this.chipBackground,
      chipText: chipText ?? this.chipText,
      edittextBackProfile: edittextBackProfile ?? this.edittextBackProfile,
      white: white ?? this.white,
      messageLeft: messageLeft ?? this.messageLeft,
      messageRight: messageRight ?? this.messageRight,
      greyTab: greyTab ?? this.greyTab,
      greyAmount: greyAmount ?? this.greyAmount,
      redAmount: redAmount ?? this.redAmount,
      greenAmount: greenAmount ?? this.greenAmount,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      yellowStatus: yellowStatus ?? this.yellowStatus,
      filterDivider: filterDivider ?? this.filterDivider,
      referEarnColor: referEarnColor ?? this.referEarnColor,
      closeAccountColor: closeAccountColor ?? this.closeAccountColor,
      chatPrimary: chatPrimary ?? this.chatPrimary,
      accentBlue: accentBlue ?? this.accentBlue,
      profileBlue: profileBlue ?? this.profileBlue,
      buddiesBackground: buddiesBackground ?? this.buddiesBackground,
      buddiesCard: buddiesCard ?? this.buddiesCard,
      buddiesBorder: buddiesBorder ?? this.buddiesBorder,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      greyButton: Color.lerp(greyButton, other.greyButton, t)!,
      greyCircle: Color.lerp(greyCircle, other.greyCircle, t)!,
      redColor: Color.lerp(redColor, other.redColor, t)!,
      redDeleteColor: Color.lerp(redDeleteColor, other.redDeleteColor, t)!,
      vacationList: Color.lerp(vacationList, other.vacationList, t)!,
      greyText: Color.lerp(greyText, other.greyText, t)!,
      subTitle: Color.lerp(subTitle, other.subTitle, t)!,
      chipBackground: Color.lerp(chipBackground, other.chipBackground, t)!,
      chipText: Color.lerp(chipText, other.chipText, t)!,
      edittextBackProfile: Color.lerp(edittextBackProfile, other.edittextBackProfile, t)!,
      white: Color.lerp(white, other.white, t)!,
      messageLeft: Color.lerp(messageLeft, other.messageLeft, t)!,
      messageRight: Color.lerp(messageRight, other.messageRight, t)!,
      greyTab: Color.lerp(greyTab, other.greyTab, t)!,
      greyAmount: Color.lerp(greyAmount, other.greyAmount, t)!,
      redAmount: Color.lerp(redAmount, other.redAmount, t)!,
      greenAmount: Color.lerp(greenAmount, other.greenAmount, t)!,
      pendingAmount: Color.lerp(pendingAmount, other.pendingAmount, t)!,
      yellowStatus: Color.lerp(yellowStatus, other.yellowStatus, t)!,
      filterDivider: Color.lerp(filterDivider, other.filterDivider, t)!,
      referEarnColor: Color.lerp(referEarnColor, other.referEarnColor, t)!,
      closeAccountColor: Color.lerp(closeAccountColor, other.closeAccountColor, t)!,
      chatPrimary: Color.lerp(chatPrimary, other.chatPrimary, t)!,
      accentBlue: Color.lerp(accentBlue, other.accentBlue, t)!,
      profileBlue: Color.lerp(profileBlue, other.profileBlue, t)!,
      buddiesBackground: Color.lerp(buddiesBackground, other.buddiesBackground, t)!,
      buddiesCard: Color.lerp(buddiesCard, other.buddiesCard, t)!,
      buddiesBorder: Color.lerp(buddiesBorder, other.buddiesBorder, t)!,
    );
  }
}

