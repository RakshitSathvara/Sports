import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  String? hintText = "";
  int? maxLines = 1;
  bool? isEndIconVisible = false;
  IconData? endIcon;

  CustomTextField(
      {Key? key,
      @required this.hintText,
      this.maxLines,
      @required this.isEndIconVisible,
      this.endIcon})
      : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Theme.of(context).primaryColor,
      decoration: InputDecoration(
        labelText: widget.hintText,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF6200EE),
        ),
        suffixIcon: widget.isEndIconVisible!
            ? Icon(
                widget.endIcon,
              )
            : const SizedBox(
                width: 10.0,
                height: 10.0,
              ),
      ),
    );
  }
}
