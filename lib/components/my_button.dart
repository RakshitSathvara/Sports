import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/extentions.dart';

class MyButton extends StatelessWidget {
  final String text;
  final Color textcolor;
  final double textsize;
  final FontWeight fontWeight;
  final double letterspacing;
  final double buttonwidth;
  double buttonheight = 55;
  final Color buttoncolor;
  final Color buttonbordercolor;
  final double radius;
  final VoidCallback onTap;
  String? imagePath;
  bool? hideImage;
  double? elevation;

  MyButton({
    required this.text,
    required this.textcolor,
    required this.textsize,
    required this.fontWeight,
    required this.letterspacing,
    required this.buttonwidth,
    required this.buttonheight,
    required this.buttoncolor,
    required this.buttonbordercolor,
    required this.radius,
    required this.onTap,
    this.imagePath,
    this.hideImage,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: buttonheight,
      child: ElevatedButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomTextView(
              label: text,
              textStyle: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(decoration: TextDecoration.none, fontSize: textsize, fontWeight: fontWeight, letterSpacing: letterspacing, color: textcolor),
            ),
            SizedBox(
              height: 25.0,
              width: 25.0,
              child: imagePath != null ? Image.asset(imagePath!, fit: BoxFit.contain) : Image.asset('assets/images/ic_btn.png', fit: BoxFit.contain),
            ).visible(!(hideImage ?? false)),
          ],
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttoncolor,
          textStyle: TextStyle(color: textcolor),
          elevation: elevation ?? 6.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: BorderSide(color: buttonbordercolor),
          ),
        ),
        onPressed: onTap,
      ),
    );
  }
}

class MyButtonWithoutBackground extends StatelessWidget {
  final String text;
  final Color textcolor;
  final double textsize;
  final FontWeight fontWeight;
  final double letterspacing;
  final double buttonwidth;
  double buttonheight = 55;
  final Color buttoncolor;
  final Color buttonbordercolor;
  final double radius;
  final VoidCallback onTap;

  MyButtonWithoutBackground(
      {required this.text,
      required this.textcolor,
      required this.textsize,
      required this.fontWeight,
      required this.letterspacing,
      required this.buttonwidth,
      required this.buttonheight,
      required this.buttoncolor,
      required this.buttonbordercolor,
      required this.radius,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: buttonheight,
      child: ElevatedButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomTextView(
              label: text,
              textStyle: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(decoration: TextDecoration.none, fontSize: textsize, fontWeight: fontWeight, letterSpacing: letterspacing, color: textcolor),
            ),
            SizedBox(
              height: 25.0,
              width: 25.0,
              child: Image.asset('assets/images/ic_btn_arrow.png', fit: BoxFit.contain),
            ),
          ],
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttoncolor,
          textStyle: TextStyle(color: textcolor),
          elevation: 6.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: BorderSide(color: buttonbordercolor),
          ),
        ),
        onPressed: onTap,
      ),
    );
  }
}

class SimpleButton extends StatelessWidget {
  final String text;
  final Color textcolor;
  final double textsize;
  final FontWeight fontWeight;
  final double letterspacing;
  final double buttonwidth;
  double buttonheight = 55;
  final Color buttoncolor;
  final Color buttonbordercolor;
  final double radius;
  final VoidCallback onTap;

  SimpleButton(
      {required this.text,
      required this.textcolor,
      required this.textsize,
      required this.fontWeight,
      required this.letterspacing,
      required this.buttonwidth,
      required this.buttonheight,
      required this.buttoncolor,
      required this.buttonbordercolor,
      required this.radius,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: buttonheight,
      width: buttonwidth,
      child: ElevatedButton(
        child: CustomTextView(
          label: text,
          textAlign: TextAlign.center,
          textStyle: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(decoration: TextDecoration.none, fontSize: textsize, fontWeight: fontWeight, letterSpacing: letterspacing, color: textcolor),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttoncolor,
          textStyle: TextStyle(color: textcolor),
          elevation: 6.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: BorderSide(color: buttonbordercolor),
          ),
        ),
        onPressed: onTap,
      ),
    );
  }
}
