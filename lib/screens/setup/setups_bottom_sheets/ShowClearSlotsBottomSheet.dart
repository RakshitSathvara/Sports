import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';

class ShowClearSlotsBottomSheet extends StatefulWidget {
  const ShowClearSlotsBottomSheet({super.key});

  @override
  State<ShowClearSlotsBottomSheet> createState() => _ShowClearSlotsBottomSheetState();
}

class _ShowClearSlotsBottomSheetState extends State<ShowClearSlotsBottomSheet> {
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
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Column(
        children: [
          CustomTextView(
            label: 'Slot Time',
            textStyle: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.bold, fontSize: 18, color: OQDOThemeData.greyColor),
          ),
          const SizedBox(
            height: 30,
          ),
          Expanded(
            child: CustomTextView(
              label: 'Slots will be removed on changing Slot Time. Are you sure you want to proceed?',
              maxLine: 6,
              textStyle: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: OQDOThemeData.blackColor),
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
                    textStyle: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontWeight: FontWeight.w400, fontSize: 18, color: OQDOThemeData.whiteColor),
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
                    textStyle: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontWeight: FontWeight.w400, fontSize: 18, color: OQDOThemeData.whiteColor),
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
