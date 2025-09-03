import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/screens/appointment/intent/selected_coupon_intent.dart';
import 'package:oqdo_mobile_app/screens/appointment/response/referral_coupon_response_model.dart';
import 'package:oqdo_mobile_app/screens/appointment/views/discount_coupon.dart';
import 'package:oqdo_mobile_app/theme/app_colors.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/viewmodels/slot_management_view_model.dart';
import 'package:provider/provider.dart';

class CopounScreen extends StatefulWidget {
  const CopounScreen({Key? key}) : super(key: key);

  @override
  State<CopounScreen> createState() => _CopounScreenState();
}

class _CopounScreenState extends State<CopounScreen> {
  List<ReferralActivityData> referralCoupons = [];
  bool isLoading = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      getAllReferralCoupons();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: CustomAppBar(
          title: 'Book Appointment',
          onBack: () {
            Navigator.pop(context);
          }),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 20),
            child: CustomTextView(
              label: 'Select Coupon',
              textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontSize: 19,
                    color: AppColors.chipText,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          referralCoupons.isNotEmpty
              ? Expanded(
                  child: ListView.separated(
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemCount: referralCoupons.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final coupon = referralCoupons[index];
                      return GestureDetector(
                        onTap: () {
                          final selectedCouponIntent = SelectedCouponIntent(
                              couponName: coupon.referralCouponText,
                              discount: coupon.referralPercentage,
                              couponId: coupon.endUserReferralActivityId,
                              discountAmount: coupon.referralPercentage);
                          Navigator.pop(context, selectedCouponIntent);
                        },
                        child: DiscountCoupon(
                          couponCode: coupon.referralCouponText,
                          discountAmount: '${coupon.referralPercentage}%',
                          expiryDate: coupon.formattedExpiredDateSlashed,
                        ),
                      );
                    },
                  ),
                )
              : Expanded(
                  child: Center(
                  child: isLoading
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.dividerColor),
                        )
                      : CustomTextView(
                          label: 'No Coupons Available',
                          textStyle: const TextStyle(
                            color: AppColors.chipText,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                )),
        ],
      ),
    );
  }

  Future<void> getAllReferralCoupons() async {
    try {
      setState(() {
        isLoading = true;
      });
      final response = await Provider.of<SlotManagementViewModel>(context, listen: false).getReferralCoupons();
      if (response.isNotEmpty) {
        setState(() {
          referralCoupons.addAll(response);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } on CommonException catch (error) {
      setState(() {
        isLoading = false;
      });
      debugPrint(error.toString());
      if (error.code == 400) {
        Map<String, dynamic> errorModel = jsonDecode(error.message);
        if (errorModel.containsKey('ModelState')) {
          Map<String, dynamic> modelState = errorModel['ModelState'];
          if (modelState.containsKey('ErrorMessage')) {
            showSnackBarColor(modelState['ErrorMessage'][0], context, true);
          } else {
            showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
          }
        } else {
          showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
        }
      } else {
        showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
    } on NoConnectivityException catch (_) {
      setState(() {
        isLoading = false;
      });
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      debugPrint(error.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }
}
