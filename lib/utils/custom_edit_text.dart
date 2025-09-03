import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';

abstract class OnChangeReturn {
  void onChangeValue(String tag, String value);
}

abstract class OnChangeState {
  onChangeState(String tag);
}

InputDecoration getTextFieldDecoration({BuildContext? context, String? text, Color? color}) {
  return InputDecoration(
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: color!)),
      disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: color)),
      labelText: text,
      labelStyle: Theme.of(context!).textTheme.bodyLarge!.copyWith(color: color, fontSize: 14.0),
      fillColor: OQDOThemeData.lightColorScheme.primary,
      counterText: "",
      border: OutlineInputBorder(borderSide: BorderSide(color: color)));
}

// ignore: must_be_immutable
class CustomEditText extends StatefulWidget {
  BuildContext? context;
  TextEditingController? controller;
  TextInputType? textInputType;
  FocusNode? currentFocus;
  FocusNode? nextFocus;
  bool? isDigitOnly;
  String? hintText;
  List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  OnChangeReturn? onChange;
  String? tag;
  bool? isChangeReturn = false;
  Color? color;
  IconData? icon;
  int? maxLength = 500;
  TextAlign? textAlign;
  InputDecoration? decoration;
  bool autoFocus = false;
  bool obscureText = false;
  bool? isReadOnly = false;

  CustomEditText(
      {Key? key,
      this.context,
      this.tag,
      this.controller,
      this.textInputType,
      this.currentFocus,
      this.nextFocus,
      this.isDigitOnly,
      this.hintText,
      this.inputFormatters,
      this.validator,
      this.onChange,
      this.isChangeReturn,
      this.color,
      this.textAlign = TextAlign.start,
      this.decoration,
      this.icon,
      this.maxLength,
      this.autoFocus = false,
      this.obscureText = false,
      this.isReadOnly})
      : super(key: key);

  @override
  State<CustomEditText> createState() => _CustomEditTextState();
}

class _CustomEditTextState extends State<CustomEditText> {
  @override
  void initState() {
    try {
      if (widget.isChangeReturn!) {
        widget.controller?.addListener(onChange);
      }
    } catch (e) {
      // print(e);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextFormField(
        maxLines: 1,
        autocorrect: false,
        enableSuggestions: false,
        obscureText: widget.obscureText,
        cursorColor: OQDOThemeData.lightColorScheme.primary,
        maxLength: widget.maxLength,
        validator: widget.validator,
        controller: widget.controller,
        autofillHints: null,
        keyboardType: widget.textInputType,
        textAlign: widget.textAlign!,
        autofocus: widget.autoFocus,
        inputFormatters: widget.inputFormatters,
        readOnly: widget.isReadOnly!,
        textInputAction: widget.nextFocus == null ? TextInputAction.done : TextInputAction.next,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color.fromRGBO(105, 105, 105, 1), fontSize: 16.0, fontWeight: FontWeight.w400),
        focusNode: widget.currentFocus,
        onFieldSubmitted: (value) {
          widget.currentFocus?.unfocus();
        },
        // decoration: widget.decoration != null
        //     ? getTextFieldDecorationWithIcon()
        //     : getTextFieldDecorationWithoutIcon(),
        decoration: widget.decoration ?? getTextFieldDecorationWithoutIcon(),
      ),
    );
  }

  InputDecoration getTextFieldDecorationWithIcon() {
    return InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Icon(
            widget.icon,
            color: Colors.grey,
            size: 15,
          ), // icon is 48px widget.
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9), borderSide: BorderSide(color: widget.color ?? OQDOThemeData.lightColorScheme.primary, width: 1)),
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9), borderSide: BorderSide(color: widget.color ?? OQDOThemeData.lightColorScheme.primary, width: 1)),
        labelText: widget.hintText,
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: OQDOThemeData.lightColorScheme.onSecondary, fontSize: 14.0),
        fillColor: OQDOThemeData.lightColorScheme.onSecondary,
        counterText: "",
        hintStyle: Theme.of(context).textTheme.titleMedium,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9), borderSide: BorderSide(color: widget.color ?? OQDOThemeData.lightColorScheme.primary, width: 1)));
  }

  InputDecoration getTextFieldDecorationWithoutIcon() {
    return InputDecoration(
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9), borderSide: BorderSide(color: widget.color ?? OQDOThemeData.lightColorScheme.primary, width: 1)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9), borderSide: BorderSide(color: widget.color ?? OQDOThemeData.lightColorScheme.primary, width: 1)),
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9), borderSide: BorderSide(color: widget.color ?? OQDOThemeData.lightColorScheme.primary, width: 1)),
        labelText: widget.hintText,
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: OQDOThemeData.lightColorScheme.onSecondary, fontSize: 14.0),
        fillColor: OQDOThemeData.lightColorScheme.onSecondary,
        counterText: "",
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9), borderSide: BorderSide(color: widget.color ?? OQDOThemeData.lightColorScheme.primary, width: 1)));
  }

  void onChange() {
    try {
      String text = widget.controller!.text;
      widget.onChange?.onChangeValue(widget.tag!, text);
    } catch (e) {
      // print(e);
    }
  }
}
