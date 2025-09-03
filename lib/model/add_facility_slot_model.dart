class AddFacilitySlotModel {
  bool? sunday = false;
  bool? monday = false;
  bool? tuesday = false;
  bool? wednesday = false;
  bool? thursday = false;
  bool? friday = false;
  bool? saturday = false;
  double? ratePerHour = 0;
  List<SlotsModel>? slotsModelList = [];
  List<int>? selectedSlotsDayList = [];
}

class SlotsModel {
  String? startTime = '00:00';
  String? endTime = '00:00';
  int? startTimeInMinutes;
  int? endTimeInMinutes;
  int? slots = 0;


  SlotsModel(this.startTime, this.endTime, this.startTimeInMinutes,
      this.endTimeInMinutes, this.slots);
}
