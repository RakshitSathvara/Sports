import 'package:oqdo_mobile_app/screens/setup/facility_setup/models/add_time_slot_model.dart';

class FacilityPreviewModel {
  String title;
  String subTitle;
  String activity;
  String subActivity;
  String description;
  String slotDuration;
  int rentalDurationInMinutes;
  double slotRate;
  String maxCapacityOrGroupSize;
  bool isPrivateRental;
  List<AddTimeSlotModel> slotsList;

  FacilityPreviewModel({
    required this.title,
    required this.subTitle,
    required this.activity,
    required this.subActivity,
    required this.description,
    required this.slotDuration,
    required this.rentalDurationInMinutes,
    required this.slotRate,
    required this.maxCapacityOrGroupSize,
    required this.isPrivateRental,
    required this.slotsList,
  });
}
