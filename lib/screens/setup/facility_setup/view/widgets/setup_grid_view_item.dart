import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/theme/custom_colors.dart';

class SetupGridViewItem extends StatelessWidget {
  const SetupGridViewItem({
    super.key,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
    required this.imagePath,
    required this.title,
    this.unSelectedColor,
    this.useLocalImage = true,
  });

  final String imagePath;
  final bool useLocalImage;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? unSelectedColor;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final double borderOpacity = isEnabled ? 1 : 0.25;
    final double backgroundOpacity = isEnabled ? 1 : 0.5;
    final Color resolvedUnselectedColor = unSelectedColor ?? customColors.containerBG;
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(
              color: (isSelected ? colorScheme.primary : customColors.borderColor).withOpacity(borderOpacity),
              width: 1),
          borderRadius: BorderRadius.circular(5.0),
          color: isSelected
              ? customColors.selectedGridItemColor.withOpacity(backgroundOpacity)
              : resolvedUnselectedColor.withOpacity(backgroundOpacity),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            useLocalImage
                ? Image.asset(
                    imagePath,
                    width: 35,
                    height: 35,
                  )
                : CachedNetworkImage(
                    imageUrl: imagePath,
                    fit: BoxFit.fill,
                    height: 45,
                    width: 45,
                    placeholder: (context, _) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) {
                      return Icon(
                        Icons.error_outline,
                        size: 35,
                      );
                    },
                  ),
            const SizedBox(height: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
