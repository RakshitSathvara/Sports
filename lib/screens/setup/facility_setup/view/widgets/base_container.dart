import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';

class BaseContainer extends StatelessWidget {
  const BaseContainer({super.key, required this.child, this.bgColor, this.width, this.borderColor});

  final Widget child;
  final Color? bgColor;
  final Color? borderColor;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: bgColor ?? ColorsUtils.containerBG,
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: borderColor ?? ColorsUtils.borderColor, width: 1),
      ),
      child: child,
    );
  }
}
