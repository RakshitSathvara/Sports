import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';

class CustomButton extends StatelessWidget {
  final String? text;
  final Color textcolor;
  final double textsize;
  final FontWeight fontWeight;
  final double? buttonwidth;
  final double? buttonheight;
  final Color buttonColor;
  final Color? borderColor;
  final double radius;
  final VoidCallback? onTap;
  final Widget? leadingIcon;

  const CustomButton({
    super.key,
    this.text,
    required this.textcolor,
    required this.textsize,
    required this.fontWeight,
    this.buttonwidth,
    this.buttonheight,
    required this.buttonColor,
    this.borderColor,
    required this.radius,
    required this.onTap,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: buttonheight,
      width: buttonwidth,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          padding: EdgeInsets.zero,
          shadowColor: Colors.transparent,
          textStyle: TextStyle(color: textcolor),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: BorderSide(color: borderColor ?? buttonColor),
          ),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            (leadingIcon ?? const SizedBox.shrink()),
            if (leadingIcon != null && (text?.isNotEmpty ?? false)) const SizedBox(width: 2),
            if (text?.isNotEmpty ?? false)
              CustomTextView(
                label: text,
                textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                      decoration: TextDecoration.none,
                      fontSize: textsize,
                      fontWeight: fontWeight,
                      color: textcolor,
                      fontFamily: 'SFPro',
                    ),
              ),
          ],
        ),
      ),
    );
  }
}
