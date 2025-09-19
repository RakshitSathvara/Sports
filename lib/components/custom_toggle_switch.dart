import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';

class CustomToggleSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;

  const CustomToggleSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
  });

  @override
  State<CustomToggleSwitch> createState() => _CustomToggleSwitchState();
}

class _CustomToggleSwitchState extends State<CustomToggleSwitch> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(useMaterial3: true),
      child: Switch(
        value: widget.value,
        onChanged: widget.onChanged,
        activeColor: widget.thumbColor ?? Colors.white,
        activeTrackColor: widget.activeColor ?? ColorsUtils.primary,
        inactiveThumbColor: widget.thumbColor ?? Colors.white,
        inactiveTrackColor: widget.inactiveColor ?? ColorsUtils.greyBG,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}