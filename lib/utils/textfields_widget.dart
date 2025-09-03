import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';

class CustomTextFormField extends StatelessWidget {
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
  final Color fillColor;
  final Color borderColor;
  final double borderRadius;
  final double fontSize;
  final bool centerText;
  final List<String>? autofillHints;

  const CustomTextFormField({
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
    this.fillColor = Colors.white,
    this.borderColor = const Color(0xFF006590),
    this.borderRadius = 10,
    this.fontSize = 20.0,
    this.centerText = false,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius), borderSide: BorderSide(color: borderColor, width: 1)),
          filled: true,
          fillColor: fillColor,
          errorStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: Colors.red, fontSize: 14.0, fontWeight: FontWeight.w400),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: borderColor, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: borderColor, width: 1),
          ),
          prefixIcon: preffixIcon,
          suffixIcon: suffixIcon,
          // floatingLabelBehavior: FloatingLabelBehavior.always, // label is sticky
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: OQDOThemeData.filterDividerColor, width: 1),
          ),
          labelText: labelText,
          labelStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.w400),
          hintText: hintText,
          hintStyle:
              Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.shadow, fontWeight: FontWeight.w400, fontSize: fontSize),
          contentPadding: const EdgeInsets.all(15),
          counterText: ''),
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).brightness == Brightness.light
              ? ColorsUtils.greyText
              : const Color(0xFFAEAEAE),
          fontSize: fontSize,
          fontWeight: FontWeight.w400),
    );
  }
}

class CustomTextFormField1 extends StatelessWidget {
  final String? labelText;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Icon? suffixIcon;
  final Icon? preffixIcon;
  final VoidCallback? onPressedIcon;
  final String? Function(String?)? validator;
  final String Function(String?)? onchanged;
  final String Function(String?)? onSubmitted;
  final void Function()? oncomplete;
  final TextEditingController controller;
  final bool read;
  final int? maxlines;
  final int? maxlength;
  final List<TextInputFormatter>? inputformat;
  final Color fillColor;
  final Color borderColor;
  final double borderRadius;

  const CustomTextFormField1({
    super.key,
    required this.hintText,
    this.labelText,
    required this.obscureText,
    this.validator,
    this.onchanged,
    this.onSubmitted,
    required this.controller,
    this.suffixIcon,
    this.onPressedIcon,
    required this.read,
    this.preffixIcon,
    this.oncomplete,
    this.keyboardType,
    this.maxlines,
    this.maxlength,
    this.inputformat,
    this.fillColor = Colors.white,
    this.borderColor = const Color(0xFF006590),
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputformat,
      obscureText: obscureText,
      maxLength: maxlength,
      maxLines: maxlines,
      onChanged: onchanged,
      onEditingComplete: oncomplete,
      onFieldSubmitted: onSubmitted,
      readOnly: read,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius), borderSide: BorderSide(color: borderColor, width: 1)),
        filled: true,
        fillColor: fillColor,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        prefix: preffixIcon,
        suffix: suffixIcon,
        disabledBorder: InputBorder.none,
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.shadow, fontWeight: FontWeight.w400, fontSize: 25.0),
        contentPadding: const EdgeInsets.all(15.0),
      ),
      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w400, color: OQDOThemeData.lightColorScheme.onSecondary, fontSize: 20.0),
    );
  }
}

class CustomTextFormFieldWithUndline extends StatelessWidget {
  final String? labelText;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Icon? suffixIcon;
  final Icon? preffixIcon;
  final VoidCallback? onPressedIcon;
  final String? Function(String?)? validator;
  final String Function(String?)? onchanged;
  final void Function()? oncomplete;
  final TextEditingController controller;
  final bool read;
  final int? maxlines;
  final int? maxlength;
  final List<TextInputFormatter>? inputformat;
  final Color fillColor;
  final Color borderColor;
  final double borderRadius;

  const CustomTextFormFieldWithUndline({
    super.key,
    required this.hintText,
    this.labelText,
    required this.obscureText,
    this.validator,
    this.onchanged,
    required this.controller,
    this.suffixIcon,
    this.onPressedIcon,
    required this.read,
    this.preffixIcon,
    this.oncomplete,
    this.keyboardType,
    this.maxlines,
    this.maxlength,
    this.inputformat,
    this.fillColor = Colors.white,
    this.borderColor = const Color(0xFF006590),
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputformat,
      obscureText: obscureText,
      maxLength: maxlength,
      maxLines: maxlines,
      onChanged: onchanged,
      onEditingComplete: oncomplete,
      readOnly: read,
      decoration: InputDecoration(
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        filled: true,
        fillColor: fillColor,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        prefix: preffixIcon,
        suffix: suffixIcon,
        disabledBorder: InputBorder.none,
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.shadow, fontWeight: FontWeight.w400, fontSize: 25.0),
        contentPadding: const EdgeInsets.all(10),
      ),
      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: OQDOThemeData.lightColorScheme.onSecondary, fontSize: 20.0),
    );
  }
}
