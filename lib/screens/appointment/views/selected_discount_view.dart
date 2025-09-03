import 'package:flutter/material.dart';
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
    return Container(
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FBFF),
        border: Border.all(color: const Color(0xFF0099FA).withOpacity(0.5), width: 2),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0099FA),
                  ),
                  children: [
                    const TextSpan(text: 'You Saved '),
                    TextSpan(
                      text: percentage,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0099FA),
                      ),
                    ),
                    const TextSpan(text: ' with '),
                    TextSpan(
                      text: couponCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0099FA),
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
                foregroundColor: const Color(0xFFFF0000),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: CustomTextView(
                label: 'Remove',
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF0000),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
