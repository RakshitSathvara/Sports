import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';

class OfferPriceBottomSheetView extends StatefulWidget {
  const OfferPriceBottomSheetView({super.key, required this.title, required this.offerPriceController, required this.onSendOffer});

  final TextEditingController offerPriceController;
  final VoidCallback onSendOffer;
  final String title;

  @override
  State<OfferPriceBottomSheetView> createState() => _OfferPriceBottomSheetViewState();
}

class _OfferPriceBottomSheetViewState extends State<OfferPriceBottomSheetView> {
  @override
  void initState() {
    widget.offerPriceController.addListener(controllerListner);
    super.initState();
  }

  void controllerListner() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.offerPriceController.removeListener(controllerListner);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: CustomTextView(
              label: widget.title,
              textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: 18, color: OQDOThemeData.greyColor),
            ),
          ),
          const SizedBox(height: 15),
          Divider(
            thickness: 2,
            color: Color(0xFFD0D0D0),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomTextView(
                      label: 'S\$',
                      textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontSize: 30.0,
                            fontWeight: FontWeight.w400,
                            color: OQDOThemeData.blackColor,
                          ),
                    ),
                    const SizedBox(width: 3),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width / 2),
                      child: IntrinsicWidth(
                        child: TextField(
                          controller: widget.offerPriceController,
                          inputFormatters: [
                            DecimalTextInputFormatter(decimalRange: 2),
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                          ],
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          maxLength: 8,
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: widget.offerPriceController.text.isEmpty ? 'Offer Price' : null,
                            hintStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.w400,
                                  color: OQDOThemeData.filterDividerColor,
                                ),
                          ),
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                fontSize: 30.0,
                                fontWeight: FontWeight.w400,
                                color: OQDOThemeData.blackColor,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
                CupertinoButton(
                  color: Theme.of(context).colorScheme.primary,
                  child: CustomTextView(
                    label: 'Send',
                    textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: 18, color: OQDOThemeData.whiteColor),
                  ),
                  onPressed: () {
                    if (widget.offerPriceController.text.isEmpty || double.parse(widget.offerPriceController.text) <= 0) {
                      hideKeyboard();
                      showSnackBar('Please enter a valid offer price', context);
                      return;
                    }
                    Navigator.pop(context, true);
                    widget.onSendOffer();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
