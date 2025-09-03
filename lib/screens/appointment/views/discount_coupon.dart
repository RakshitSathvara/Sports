import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';

class DiscountCoupon extends StatelessWidget {
  final String couponCode;
  final String discountAmount;
  final String expiryDate;

  const DiscountCoupon({
    super.key,
    required this.couponCode,
    required this.discountAmount,
    required this.expiryDate,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: CustomPaint(
        painter: TicketShapePainter(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                couponCode,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              CustomTextView(
                label: 'Save $discountAmount',
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                ),
              ),
              CustomTextView(
                label: 'Expire Date: $expiryDate',
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TicketShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Main ticket shape paint
    final Paint paint = Paint()
      ..color = const Color(0xFF006994) // Deep blue color
      ..style = PaintingStyle.fill;

    const double circleRadius = 20;
    const double cornerRadius = 15;
    final Path path = Path();

    // Top left corner
    path.moveTo(cornerRadius, 0);
    path.lineTo(size.width - cornerRadius, 0);

    // Top right corner
    path.arcToPoint(
      Offset(size.width, cornerRadius),
      radius: const Radius.circular(cornerRadius),
      clockwise: true,
    );

    // Right side notch
    path.lineTo(size.width, (size.height / 2) - circleRadius);
    path.arcToPoint(
      Offset(size.width, (size.height / 2) + circleRadius),
      radius: const Radius.circular(circleRadius),
      clockwise: false,
    );

    // Bottom right corner
    path.lineTo(size.width, size.height - cornerRadius);
    path.arcToPoint(
      Offset(size.width - cornerRadius, size.height),
      radius: const Radius.circular(cornerRadius),
      clockwise: true,
    );

    // Bottom left corner
    path.lineTo(cornerRadius, size.height);
    path.arcToPoint(
      Offset(0, size.height - cornerRadius),
      radius: const Radius.circular(cornerRadius),
      clockwise: true,
    );

    // Left side notch
    path.lineTo(0, (size.height / 2) + circleRadius);
    path.arcToPoint(
      Offset(0, (size.height / 2) - circleRadius),
      radius: const Radius.circular(circleRadius),
      clockwise: false,
    );

    // Back to top left
    path.lineTo(0, cornerRadius);
    path.arcToPoint(
      const Offset(cornerRadius, 0),
      radius: const Radius.circular(cornerRadius),
      clockwise: true,
    );

    canvas.drawPath(path, paint);

    // Grid pattern paint
    final Paint gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw vertical grid lines
    double gridSpacing = 20;
    for (double x = 0; x <= size.width; x += gridSpacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    // Draw horizontal grid lines
    for (double y = 0; y <= size.height; y += gridSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
