import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';
import 'package:oqdo_mobile_app/utils/core_text_style.dart';
import 'package:oqdo_mobile_app/utils/extentions.dart';

class CommonTextField extends StatelessWidget {
  final String hint;
  final String? insideHint;
  final bool? isRequired;
  final bool? showToolTip;
  final bool? viewOnly;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool? isNumber;
  final bool? isAddress;
  final bool? isName;
  final bool? isDouble;
  final bool? isPassword;
  final bool? showTitle;
  final int? maxLength;
  final int? minLines;
  final int? maxLines;
  final TextStyle? titleStyle;
  final TextStyle? textStyle;
  final Widget? prefix;
  final Color? fillColor;
  final Color? normalBorderColor;
  final int? decimalRange;
  final String? toolTipText;
  final bool enabled;
  final double? borderRadius;
  final FocusNode? focusNode;
  final Function(String)? onChanged;
  final AutovalidateMode? autovalidateMode;
  final Function()? onTap;
  final String? labelText;

  const CommonTextField({
    super.key,
    required this.hint,
    this.insideHint,
    this.isRequired,
    this.showToolTip,
    this.viewOnly,
    this.controller,
    this.validator,
    this.isNumber,
    this.isAddress,
    this.isPassword,
    this.maxLength,
    this.minLines,
    this.maxLines,
    this.titleStyle,
    this.textStyle,
    this.prefix,
    this.showTitle,
    this.fillColor,
    this.normalBorderColor,
    this.inputFormatters,
    this.isName,
    this.isDouble,
    this.decimalRange,
    this.toolTipText,
    this.borderRadius,
    this.enabled = true,
    this.focusNode,
    this.onChanged,
    this.autovalidateMode,
    this.onTap,
    this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    final borderFocused = OutlineInputBorder(
      borderSide: const BorderSide(width: 1, color: CoreTextStyle.focusedBorderColor),
      borderRadius: BorderRadius.circular(borderRadius ?? 6.0),
    );
    final errorBorder = OutlineInputBorder(
      borderSide: BorderSide(width: 1, color: ColorsUtils.redColor),
      borderRadius: BorderRadius.circular(borderRadius ?? 6.0),
    );

    final borderNormal = OutlineInputBorder(
      borderSide: BorderSide(width: 1, color: normalBorderColor ?? ColorsUtils.borderColor),
      borderRadius: BorderRadius.circular(borderRadius ?? 6.0),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(hint, style: titleStyle ?? CoreTextStyle.hintTextStyle),
                Text('*', style: titleStyle ?? CoreTextStyle.requiredFieldTextStyle).visible(isRequired == true),
                const SizedBox(width: 5).visible(showToolTip == true),
              ],
            ),
            const SizedBox(height: 5),
          ],
        ).visible(showTitle ?? false),
        TextFormField(
          onTap: onTap,
          focusNode: focusNode,
          autofocus: false,
          autovalidateMode: autovalidateMode,
          readOnly: viewOnly ?? false,
          enabled: enabled,
          controller: controller,
          textInputAction: ((minLines ?? 1) > 1) ? TextInputAction.newline : TextInputAction.done,
          obscureText: (isPassword == true) ? true : false,
          keyboardType: (isNumber == true || isDouble == true) ? TextInputType.number : null,
          onChanged: onChanged,
          inputFormatters: (isNumber == true)
              ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
              : (isDouble == true)
                  ? <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
                  : (isName ?? false)
                      ? <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s\-.'’]"))]
                      : (isAddress ?? false)
                          ? <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9\s\-',.#@%&/()]"))]
                          : inputFormatters,
          maxLength: maxLength,
          minLines: minLines,
          maxLines: maxLines ?? 1,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            labelText: labelText,
            counterText: '',
            fillColor: fillColor ?? CoreTextStyle.fieldFillColor,
            border: borderNormal,
            enabledBorder: borderNormal,
            focusedBorder: borderFocused,
            focusedErrorBorder: errorBorder,
            errorBorder: errorBorder,
            errorStyle: CoreTextStyle.errorTextStyle,
            prefixIcon: prefix,
            prefixIconConstraints: const BoxConstraints(maxWidth: 80),
            hintText: (showTitle ?? false) ? (insideHint ?? '') : hint,
            hintStyle: CoreTextStyle.insideHintTextStyleBold,
          ),
          style: textStyle ?? CoreTextStyle.inputTextStyle,
          validator: validator,
        ),
      ],
    );
  }
}
