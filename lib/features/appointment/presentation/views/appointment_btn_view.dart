import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';

class AppointmentButton extends StatelessWidget {
  final double amount;
  final VoidCallback onPressed;

  const AppointmentButton({
    Key? key,
    required this.amount,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF006990),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: EdgeInsets.zero,
        elevation: 0,
      ),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextView(
                  label: 'S\$ ${amount.toStringAsFixed(2)}',
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'SFPro',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                CustomTextView(
                  label: 'To Pay',
                  textStyle: const TextStyle(
                    fontFamily: 'SFPro',
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                CustomTextView(
                  label: 'Book Appointments',
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'SFPro',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 15.0,
                  width: 15.0,
                  child: Image.asset('assets/images/ic_btn.png', fit: BoxFit.contain),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
