import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';

class ShowSaveDiscardBottomSheet extends StatefulWidget {
  const ShowSaveDiscardBottomSheet({Key? key}) : super(key: key);

  @override
  State<ShowSaveDiscardBottomSheet> createState() => _ShowSaveDiscardBottomSheetState();
}

class _ShowSaveDiscardBottomSheetState extends State<ShowSaveDiscardBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: CustomTextView(label: ''),
      content: CustomTextView(
        label: 'The changes are not saved.',
        maxLine: 6,
        textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 18.0, fontWeight: FontWeight.w400, color: OQDOThemeData.blackColor),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: const Text('Discard'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: const Text('Save'),
        ),
      ],
    );
    // return Container(
    //   height: 300,
    //   decoration: const BoxDecoration(
    //     borderRadius: BorderRadius.only(
    //       topLeft: Radius.circular(10),
    //       topRight: Radius.circular(10),
    //     ),
    //   ),
    //   padding: const EdgeInsets.only(top: 20, left: 40, right: 40),
    //   child: Column(
    //     children: [
    //       const SizedBox(
    //         height: 30,
    //       ),
    //       Expanded(
    //         child: CustomTextView(
    //           label: 'The changes are not saved.',
    //           maxLine: 6,
    //           textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 18.0, fontWeight: FontWeight.w400, color: OQDOThemeData.blackColor),
    //         ),
    //       ),
    //       const SizedBox(
    //         height: 20,
    //       ),
    //       Padding(
    //         padding: const EdgeInsets.only(bottom: 20.0),
    //         child: Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //           children: [
    //             Expanded(
    //               child: CupertinoButton(
    //                 color: Theme.of(context).colorScheme.primary,
    //                 child: CustomTextView(
    //                   label: 'Save',
    //                   textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w400, fontSize: 20, color: OQDOThemeData.whiteColor),
    //                 ),
    //                 onPressed: () {
    //                   Navigator.pop(context, true);
    //                 },
    //               ),
    //             ),
    //             const SizedBox(
    //               width: 10,
    //             ),
    //             Expanded(
    //               child: CupertinoButton(
    //                 color: OQDOThemeData.errorColor,
    //                 disabledColor: OQDOThemeData.errorColor,
    //                 child: CustomTextView(
    //                   label: 'Discard',
    //                   textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w400, fontSize: 18, color: OQDOThemeData.whiteColor),
    //                 ),
    //                 onPressed: () {
    //                   Navigator.pop(context, false);
    //                 },
    //               ),
    //             ),
    //           ],
    //         ),
    //       )
    //     ],
    //   ),
    // );
  }
}
