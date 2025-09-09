import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/theme/custom_colors.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';

class SelectedDiscountView extends StatelessWidget {
  final String percentage;
  final String couponCode;
  final VoidCallback onRemove;

  const SelectedDiscountView({
    super.key,
    required this.percentage,
    required this.couponCode,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Container(
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.05),
        border: Border.all(color: colorScheme.primary.withOpacity(0.5), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Image.asset('assets/images/ic_coupon_selected.png', height: 24, width: 24),
            const SizedBox(width: 12),

            Expanded(
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                  children: [
                    const TextSpan(text: 'You Saved '),
                    TextSpan(
                      text: percentage,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const TextSpan(text: ' with '),
                    TextSpan(
                      text: couponCode,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Remove button
            TextButton(
              onPressed: onRemove,
              style: TextButton.styleFrom(
                foregroundColor: customColors.redColor,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: CustomTextView(
                label: 'Remove',
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: customColors.redColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
