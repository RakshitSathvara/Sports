class Get21DaysSlotResponseModel {
  final String? date;
  final String? day;
  final List<SlotList>? slotList;
  bool? isSlotBooked = false;

  Get21DaysSlotResponseModel({this.date, this.day, this.slotList, this.isSlotBooked});

  Get21DaysSlotResponseModel.fromJson(Map<String, dynamic> json)
      : date = convertToString(json['Date']),
        day = json['Day'] as String?,
        slotList = json['SlotList'] == null
            ? []
            : (json['SlotList'] as List?)?.map((dynamic e) => SlotList.fromJson(e as Map<String, dynamic>)).toList();

  Map<String, dynamic> toJson() => {'Date': date, 'Day': day, 'SlotList': slotList?.map((e) => e.toJson()).toList()};
}

String convertToString(String date) {
  return date.split('T')[0];
}

class SlotList {
  final int? facilitySetupDetailId;
  final int? facilitySetupDaySlotMapId;
  final String? startTime;
  final String? endTime;

  SlotList({
    this.facilitySetupDetailId,
    this.facilitySetupDaySlotMapId,
    this.startTime,
    this.endTime,
  });

  SlotList.fromJson(Map<String, dynamic> json)
      : facilitySetupDetailId = json['FacilitySetupDetailId'] as int?,
        facilitySetupDaySlotMapId = json['FacilitySetupDaySlotMapId'] as int?,
        startTime = json['StartTime'] as String?,
        endTime = json['EndTime'] as String?;

  Map<String, dynamic> toJson() => {
        'FacilitySetupDetailId': facilitySetupDetailId,
        'FacilitySetupDaySlotMapId': facilitySetupDaySlotMapId,
        'StartTime': startTime,
        'EndTime': endTime
      };
}
