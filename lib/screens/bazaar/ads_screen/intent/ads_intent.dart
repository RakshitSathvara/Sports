import 'package:oqdo_mobile_app/screens/bazaar/ads_screen/model/subactivyt_and_activity_response_model.dart';

class AdsIntent {
  int? selectedAdsType;
  String? selectedAdsTypeTitle;
  Map<String, List<SubActivity>> activityMap; // Fixing type declaration to List<Activity>

  AdsIntent({this.selectedAdsType, required this.activityMap, required this.selectedAdsTypeTitle});
}
