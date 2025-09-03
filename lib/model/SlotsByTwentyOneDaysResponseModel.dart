class SlotsByTwentyOneDaysResponseModel {
  final String? date;
  final String? day;
  final List<SlotList>? slotList;

  SlotsByTwentyOneDaysResponseModel({
    this.date,
    this.day,
    this.slotList,
  });

  SlotsByTwentyOneDaysResponseModel.fromJson(Map<String, dynamic> json)
      : date = json['Date'] as String?,
        day = json['Day'] as String?,
        slotList =
            (json['SlotList'] as List?)?.map((dynamic e) => SlotList.fromJson(e as Map<String, dynamic>)).toList();

  Map<String, dynamic> toJson() => {'Date': date, 'Day': day, 'SlotList': slotList?.map((e) => e.toJson()).toList()};
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
