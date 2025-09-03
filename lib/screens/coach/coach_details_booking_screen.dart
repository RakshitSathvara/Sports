import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';

import '../../components/my_button.dart';
import '../../theme/oqdo_theme_data.dart';
import '../../utils/custom_text_view.dart';

class CoachDetailsBookingScreen extends StatefulWidget {
  const CoachDetailsBookingScreen({Key? key}) : super(key: key);

  @override
  State<CoachDetailsBookingScreen> createState() => _CoachDetailsBookingScreenState();
}

class _CoachDetailsBookingScreenState extends State<CoachDetailsBookingScreen> {
  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  List<String> sports = ['India', 'Singapore'];
  String? selectedSports;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: '',
          onBack: () {
            Navigator.pop(context);
          }),
      body: SafeArea(
        child: Container(
          color: Theme.of(context).colorScheme.onBackground,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    topView(),
                    const SizedBox(
                      height: 40.0,
                    ),
                    const Divider(
                      height: 20,
                      thickness: 2,
                      endIndent: 0,
                      color: OQDOThemeData.dividerColor,
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    bookAppointmentView(),
                    const SizedBox(
                      height: 40.0,
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                      child: MyButton(
                        text: 'Next',
                        textcolor: Theme.of(context).colorScheme.onBackground,
                        textsize: 16,
                        fontWeight: FontWeight.w600,
                        letterspacing: 0.7,
                        buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                        buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                        buttonheight: 50,
                        buttonwidth: width,
                        radius: 15,
                        onTap: () async {
                          // if (hp.formKey.currentState!.validate()) {
                          // await Navigator.pushNamed(
                          //     context, Constants.coach_detail_booking_screen);
                          // }
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget topView() {
    return Container(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextView(
                label: "Elizabeth",
                textStyle: const TextStyle(fontSize: 18.0, color: OQDOThemeData.blackColor, fontWeight: FontWeight.bold),
              ),
              CustomTextView(
                label: 'Registration id: 123456',
                textStyle: const TextStyle(fontSize: 12.0, color: OQDOThemeData.greyColor, fontWeight: FontWeight.normal),
              ),
            ],
          ),
          const SizedBox(
            height: 8.0,
          ),
          CustomTextView(
            label: 'Activities: Yoga,Zumba,Aerobics',
            textStyle: const TextStyle(fontSize: 17.0, color: OQDOThemeData.greyColor),
          ),
          const SizedBox(
            height: 8.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextView(
                label: '\$ 15/ hour',
                textStyle: const TextStyle(fontSize: 16.0, color: OQDOThemeData.greyColor),
              ),
              Row(
                children: [
                  RatingBar.builder(
                    initialRating: 3,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 15,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 15,
                    ),
                    onRatingUpdate: (rating) {
                      // print(rating);
                    },
                  ),
                  const SizedBox(
                    width: 6.0,
                  ),
                  CustomTextView(
                    label: 'Reviews',
                    textStyle: const TextStyle(fontSize: 14.0, color: OQDOThemeData.greyColor, decoration: TextDecoration.underline),
                  )
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget bookAppointmentView() {
    return Container(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextView(
            label: 'Book an appointment',
            textStyle: const TextStyle(fontSize: 18.0, color: OQDOThemeData.blackColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 30.0,
          ),
          CustomTextView(
            label: 'Select Sports',
            textStyle: const TextStyle(color: OQDOThemeData.greyColor, fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
              borderRadius: BorderRadius.circular(15),
              color: Theme.of(context).colorScheme.onBackground,
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: DropdownButton<dynamic>(
                  isExpanded: true,
                  underline: const SizedBox(),
                  borderRadius: BorderRadius.circular(15),
                  dropdownColor: Theme.of(context).colorScheme.onBackground,
                  hint: Text(
                    "Selected Sports",
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.primaryContainer),
                  ),
                  value: selectedSports,
                  items: sports.map((country) {
                    return DropdownMenuItem(
                      child: Text(country.toString()),
                      value: country,
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSports = value as String;
                    });
                    // print(selectedSports);
                  }),
            ),
          ),
          const SizedBox(
            height: 15.0,
          ),
          CustomTextView(
            label: 'Select type of Booking',
            textStyle: const TextStyle(color: OQDOThemeData.greyColor, fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
              borderRadius: BorderRadius.circular(15),
              color: Theme.of(context).colorScheme.onBackground,
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: DropdownButton<dynamic>(
                  isExpanded: true,
                  underline: const SizedBox(),
                  borderRadius: BorderRadius.circular(15),
                  dropdownColor: Theme.of(context).colorScheme.onBackground,
                  hint: Text(
                    "Select type of Booking",
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.primaryContainer),
                  ),
                  value: selectedSports,
                  items: sports.map((country) {
                    return DropdownMenuItem(
                      child: Text(country.toString()),
                      value: country,
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSports = value as String;
                    });
                    // print(selectedSports);
                  }),
            ),
          ),
          const SizedBox(
            height: 15.0,
          ),
          CustomTextView(
            label: 'Select Training Address',
            textStyle: const TextStyle(color: OQDOThemeData.greyColor, fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
              borderRadius: BorderRadius.circular(15),
              color: Theme.of(context).colorScheme.onBackground,
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: DropdownButton<dynamic>(
                  isExpanded: true,
                  underline: const SizedBox(),
                  borderRadius: BorderRadius.circular(15),
                  dropdownColor: Theme.of(context).colorScheme.onBackground,
                  hint: Text(
                    "Select Training Address",
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.primaryContainer),
                  ),
                  value: selectedSports,
                  items: sports.map((country) {
                    return DropdownMenuItem(
                      child: Text(country.toString()),
                      value: country,
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSports = value as String;
                    });
                    // print(selectedSports);
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
