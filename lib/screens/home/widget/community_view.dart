import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/theme/custom_colors.dart';

class CommunityCard extends StatelessWidget {
  const CommunityCard({super.key, required this.icon, required this.title, required this.subtitle, required this.onTap, required this.backgroundColor});

  final String? icon;
  final String? title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(icon ?? '', width: 60, height: 60),
              SizedBox(height: 10),
              Text(title ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).extension<CustomColors>()!.blackAndWhiteColor,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                  textAlign: TextAlign.center),
              SizedBox(height: 4),
              Text(
                subtitle ?? '',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).extension<CustomColors>()!.blackAndWhiteColor,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Inter',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
