import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';

class Show24HrsAlearBottomSheet extends StatefulWidget {
  const Show24HrsAlearBottomSheet({Key? key}) : super(key: key);

  @override
  State<Show24HrsAlearBottomSheet> createState() =>
      _Show24HrsAlearBottomSheetState();
}

class _Show24HrsAlearBottomSheetState extends State<Show24HrsAlearBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      padding: const EdgeInsets.only(top: 20, left: 40, right: 40),
      child: Column(
        children: [
          const SizedBox(
            height: 30,
          ),
          Expanded(
            child: CustomTextView(
              label:
                  'The saved setup will be reviewed by admin before it gets published. Review may take upto 24 hours. Are you sure you want to proceed?',
              maxLine: 6,
              textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: 18.0,
                  overflow: TextOverflow.clip,
                  fontWeight: FontWeight.w400,
                  color: OQDOThemeData.blackColor),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CupertinoButton(
                  color: Theme.of(context).colorScheme.primary,
                  child: CustomTextView(
                    label: 'Yes',
                    textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                        color: OQDOThemeData.whiteColor),
                  ),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                ),
                CupertinoButton(
                  color: OQDOThemeData.errorColor,
                  disabledColor: OQDOThemeData.errorColor,
                  child: CustomTextView(
                    label: 'No',
                    textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                        color: OQDOThemeData.whiteColor),
                  ),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
