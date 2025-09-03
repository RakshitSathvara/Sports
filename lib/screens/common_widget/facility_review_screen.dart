import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/model/GetFacilityByIdModel.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';

class FacilityReviewScreen extends StatefulWidget {
  FacilityReviewScreen({Key? key, required this.getFacilityByIdModel}) : super(key: key);
  GetFacilityByIdModel? getFacilityByIdModel;

  @override
  State<FacilityReviewScreen> createState() => _FacilityReviewScreenState();
}

class _FacilityReviewScreenState extends State<FacilityReviewScreen> {
  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final args = ModalRoute.of(context)!.settings.arguments as FacilityCoachReviewArgumentsModel;
    return Scaffold(
      appBar: CustomAppBar(
          title: 'Reviews',
          onBack: () {
            Navigator.pop(context);
          }),
      body: SafeArea(
        child: Container(
          width: width,
          height: height,
          color: Theme.of(context).colorScheme.onBackground,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: CustomTextView(
                    maxLine: 2,
                    label: '${widget.getFacilityByIdModel!.title} \nReviews',
                    textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w400),
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                widget.getFacilityByIdModel!.facilityBookingReviewList!.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.getFacilityByIdModel!.facilityBookingReviewList!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              reviewSingleView(index),
                              const Divider(
                                height: 1.0,
                                color: OQDOThemeData.greyColor,
                              )
                            ],
                          );
                        },
                      )
                    : const Center(
                        child: Text(
                          'Reviews not available',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontStyle: FontStyle.normal),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget reviewSingleView(int index) {
    return Container(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextView(
                    label: widget.getFacilityByIdModel!.facilityBookingReviewList![index].createdBy,
                    textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w500, fontSize: 16.0, color: OQDOThemeData.blackColor),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  CustomTextView(
                    label: widget.getFacilityByIdModel!.facilityBookingReviewList![index].createdUserName,
                    textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w500, fontSize: 12.0, color: OQDOThemeData.greyColor),
                  ),
                ],
              ),
              RatingBar.builder(
                initialRating: widget.getFacilityByIdModel!.facilityBookingReviewList![index].rating!.toDouble(),
                minRating: 1,
                ignoreGestures: true,
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
            ],
          ),
          const SizedBox(
            height: 20.0,
          ),
          CustomTextView(
            label: widget.getFacilityByIdModel!.facilityBookingReviewList![index].comment,
            textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: OQDOThemeData.greyColor),
          ),
        ],
      ),
    );
  }
}
