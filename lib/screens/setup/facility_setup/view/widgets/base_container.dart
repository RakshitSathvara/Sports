import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/theme/custom_colors.dart';

class BaseContainer extends StatelessWidget {
  const BaseContainer({super.key, required this.child, this.bgColor, this.width, this.borderColor});

  final Widget child;
  final Color? bgColor;
  final Color? borderColor;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Container(
      width: width,
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: bgColor ?? customColors.containerBG,
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: borderColor ?? customColors.borderColor, width: 1),
      ),
      child: child,
    );
  }
}
