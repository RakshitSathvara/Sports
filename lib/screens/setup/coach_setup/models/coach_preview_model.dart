import 'package:oqdo_mobile_app/screens/setup/facility_setup/models/add_time_slot_model.dart';

class CoachPreviewModel {
  String title;
  String activity;
  String subActivity;
  int slotDuration;
  int slotDurationInMinutes; // Duration in minutes for accurate calculations
  String slotDurationFormatted; // New field for formatted duration display
  double slotRate;
  String maxCapacityOrGroupSize;
  String minSessions;
  bool isOpenClass;
  int addressTypeId;
  List<AddTimeSlotModel> slotsList;

  CoachPreviewModel({
    required this.title,
    required this.activity,
    required this.subActivity,
    required this.slotDuration,
    required this.slotDurationInMinutes,
    required this.slotDurationFormatted,
    required this.slotRate,
    required this.addressTypeId,
    required this.maxCapacityOrGroupSize,
    required this.minSessions,
    required this.isOpenClass,
    required this.slotsList,
  });
}
