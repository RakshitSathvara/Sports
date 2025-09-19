import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';

class CoreTextStyle {
  static const fieldFillColor = Color(0xFFFCFCFC);
  static const normalBorderColor = Color(0xFFDBDFE9);
  static const focusedBorderColor = ColorsUtils.primary;

  static var activeIconColor = ColorsUtils.black;
  static var disabledIconColor = ColorsUtils.gray400;
  static var separatorColor = ColorsUtils.greyBG;
  static var dialogBackgroundColor = ColorsUtils.white;

  static var hintTextStyle = _textStyle14Grey400;
  static var insideHintTextStyle = _textStyle13GrayLight400;
  static var insideHintTextStyleBold = _textStyle13GrayLight600;
  static var requiredFieldTextStyle = _textStyle14Black400;

  static var inputTextStyle = _textStyle14Black400;
  static var errorTextStyle = _errorTextStyle;

  static final _textStyle14Grey400 = TextStyle(color: ColorsUtils.hintTextColor, fontSize: 14, fontWeight: FontWeight.w400, fontFamily: 'Inter');

  static final _textStyle14Black400 = TextStyle(color: ColorsUtils.black, fontSize: 14, fontWeight: FontWeight.w400, fontFamily: 'Inter');

  static final _textStyle13GrayLight400 = TextStyle(
    color: ColorsUtils.hintTextColor,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: 'Inter',
  );

  static final _textStyle13GrayLight600 = TextStyle(
    color: ColorsUtils.hintTextColor,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
  );

  static final _errorTextStyle = TextStyle(
    color: ColorsUtils.redColor,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontFamily: 'Inter',
  );
}
