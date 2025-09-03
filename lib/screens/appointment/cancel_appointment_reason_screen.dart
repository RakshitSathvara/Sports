import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';

import '../../components/my_button.dart';
import '../../helper/helpers.dart';
import '../../theme/oqdo_theme_data.dart';
import '../../utils/constants.dart';
import '../../utils/custom_text_view.dart';
import '../../utils/textfields_widget.dart';

class CancelAppointmentReasonScreen extends StatefulWidget {
  const CancelAppointmentReasonScreen({Key? key}) : super(key: key);

  @override
  State<CancelAppointmentReasonScreen> createState() => _CancelAppointmentReasonScreenState();
}

class _CancelAppointmentReasonScreenState extends State<CancelAppointmentReasonScreen> {
  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  final List<String> _cancelReasons = ['Medical Reason', 'Travel Emergency', 'Personal Reason', 'Service Provider Didn' '\t Show Up', 'Other'];
  var _selectedReason = '';
  final TextEditingController _otherReason = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarView(),
      body: SafeArea(
        child: Container(
          color: Theme.of(context).colorScheme.onBackground,
          width: width,
          height: height,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: CustomTextView(
                    label: 'Indoor Basketball Court',
                    textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: CustomTextView(
                    label: 'Details',
                    textStyle: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(color: OQDOThemeData.otherTextColor, fontWeight: FontWeight.w600, decoration: TextDecoration.underline, fontSize: 12.0),
                  ),
                ),
                const SizedBox(
                  height: 40.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                  child: CustomTextView(
                    label: 'Select Reason For Cancelling Appointment',
                    textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 18.0, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w400),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _cancelReasons.length,
                  itemBuilder: (BuildContext context, int index) {
                    return reasonListView(index);
                  },
                ),
                const SizedBox(
                  height: 40.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: CustomTextFormField(
                    read: false,
                    obscureText: false,
                    labelText: 'If Other, Type Here',
                    keyboardType: TextInputType.text,
                    maxlines: 4,
                    controller: _otherReason,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: MyButton(
                    text: "Submit",
                    textcolor: Theme.of(context).colorScheme.onBackground,
                    textsize: 20,
                    fontWeight: FontWeight.w600,
                    letterspacing: 1.2,
                    buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                    buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                    buttonheight: 55,
                    buttonwidth: width,
                    radius: 15,
                    onTap: () async {
                      _showAlertDialog(context);
                    },
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget reasonListView(int index) {
    return RadioListTile(
        visualDensity: const VisualDensity(horizontal: VisualDensity.minimumDensity, vertical: VisualDensity.minimumDensity),
        contentPadding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0),
        title: CustomTextView(
          label: _cancelReasons[index],
          textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
        ),
        value: _cancelReasons[index],
        groupValue: _selectedReason,
        activeColor: Theme.of(context).colorScheme.primary,
        onChanged: (value) {
          setState(() {
            _selectedReason = value.toString();
          });
        });
  }

  PreferredSizeWidget appbarView() {
    return CustomAppBar(
        title: 'Cancel Appointments',
        onBack: () {
          Navigator.pop(context);
        });
  }

  void _showAlertDialog(BuildContext dialogContext) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: CustomTextView(
          label: '',
          textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w400, fontSize: 18.0, color: OQDOThemeData.greyColor),
        ),
        content: Center(
          child: CustomTextView(
            label: 'Are You Sure You Want To Cancel Appointment?',
            maxLine: 2,
            textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 16.0, fontWeight: FontWeight.w600, color: OQDOThemeData.greyColor),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: CustomTextView(
              label: 'No',
              textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: OQDOThemeData.dialogActionColor),
            ),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              await Navigator.pushNamedAndRemoveUntil(context, Constants.APPPAGES, Helper.of(context).predicate, arguments: 0);
            },
            child: CustomTextView(
              label: 'Yes',
              textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: OQDOThemeData.dialogActionColor),
            ),
          )
        ],
      ),
    );
  }
}
