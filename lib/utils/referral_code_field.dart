import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';

class ReferralTextField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final Icon? preffixIcon;
  final VoidCallback? onPressedIcon;
  final String? Function(String?)? validator;
  final String Function(String)? onchanged;
  final String Function(String?)? onSubmitted;
  final void Function()? oncomplete;
  final TextEditingController controller;
  final bool read;
  final bool? enabled;
  final int? maxlines;
  final int? maxlength;
  final List<TextInputFormatter>? inputformat;
  final Color? fillColor;
  final Color? borderColor;
  final double borderRadius;
  final double fontSize;
  final bool centerText;
  final List<String>? autofillHints;
  final FocusNode? focusNode;

  const ReferralTextField({
    super.key,
    this.hintText,
    required this.labelText,
    required this.obscureText,
    this.validator,
    this.onchanged,
    this.onSubmitted,
    required this.controller,
    this.suffixIcon,
    this.onPressedIcon,
    required this.read,
    this.enabled,
    this.preffixIcon,
    this.oncomplete,
    this.keyboardType,
    this.maxlines,
    this.maxlength,
    this.inputformat,
    this.fillColor,
    this.borderColor,
    this.borderRadius = 10,
    this.fontSize = 20.0,
    this.centerText = false,
    this.autofillHints,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveFillColor =
        fillColor ?? Theme.of(context).colorScheme.background;
    final Color effectiveBorderColor =
        borderColor ?? Theme.of(context).colorScheme.primaryContainer;

    return TextFormField(
      focusNode: focusNode,
      autofillHints: autofillHints,
      validator: validator,
      enableSuggestions: false,
      autocorrect: false,
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputformat,
      obscureText: obscureText,
      maxLength: maxlength,
      autofocus: false,
      maxLines: maxlines,
      onChanged: onchanged,
      onEditingComplete: oncomplete,
      onFieldSubmitted: onSubmitted,
      readOnly: read,
      enabled: enabled,
      textAlign: centerText ? TextAlign.center : TextAlign.start,
      decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: effectiveBorderColor, width: 1)),
          filled: true,
          fillColor: effectiveFillColor,
          errorStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: Colors.red, fontSize: 14.0, fontWeight: FontWeight.w400),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: effectiveBorderColor, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: effectiveBorderColor, width: 1),
          ),
          prefixIcon: preffixIcon,
          suffixIcon: suffixIcon,
          // floatingLabelBehavior: FloatingLabelBehavior.always, // label is sticky
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: OQDOThemeData.filterDividerColor, width: 1),
          ),
          labelText: labelText,
          labelStyle: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(color: Theme.of(context).colorScheme.onBackground, fontSize: 20.0, fontWeight: FontWeight.w400),
          hintText: hintText,
          hintStyle:
              Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.shadow, fontWeight: FontWeight.w400, fontSize: fontSize),
          contentPadding: const EdgeInsets.all(15),
          counterText: ''),
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.onBackground,
          fontSize: fontSize,
          fontWeight: FontWeight.w400),
    );
  }
}
