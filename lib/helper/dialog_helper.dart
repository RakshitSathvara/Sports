import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';

class LoadingDialog extends StatelessWidget
{
  String? message;

  LoadingDialog({this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      key: key,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 20),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(OQDOThemeData.dividerColor),
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          CustomTextView(
            label: message ?? 'Please wait..',
            textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: OQDOThemeData.dividerColor),
          )
        ],
      ),
    );
  }

}
