import 'package:flutter/material.dart';

class DisabledAdNotification extends StatelessWidget {
  final VoidCallback onDelete;
  
  const DisabledAdNotification({
    super.key,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary, // Blue background color
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              
              child:  Text(
                'This ad has been disabled by the seller',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.background,
                  fontSize: 16,
                  fontFamily: 'SFPro',
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(width: 16.0),
          TextButton(
            onPressed: onDelete,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
            ),
            child:  Text(
              'Delete',
              style: TextStyle(
                color: Theme.of(context).colorScheme.background,
                fontSize: 16,
                fontFamily: 'SFPro',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}