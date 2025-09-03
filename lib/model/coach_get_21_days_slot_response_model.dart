class CoachGet21DaysSlotResponseModel {
  final String? date;
  final String? day;
  final List<SlotList>? slotList;

  CoachGet21DaysSlotResponseModel({
    this.date,
    this.day,
    this.slotList,
  });

  CoachGet21DaysSlotResponseModel.fromJson(Map<String, dynamic> json)
      : date = convertToString(json['Date']),
        day = json['Day'] as String?,
        slotList =
            (json['SlotList'] as List?)?.map((dynamic e) => SlotList.fromJson(e as Map<String, dynamic>)).toList();

  Map<String, dynamic> toJson() => {'Date': date, 'Day': day, 'SlotList': slotList?.map((e) => e.toJson()).toList()};
}

String convertToString(String date) {
  return date.split('T')[0];
}

class SlotList {
  final int? coachBatchSetupDetailId;
  final int? coachBatchSetupDaySlotMapId;
  final String? startTime;
  final String? endTime;

  SlotList({
    this.coachBatchSetupDetailId,
    this.coachBatchSetupDaySlotMapId,
    this.startTime,
    this.endTime,
  });

  SlotList.fromJson(Map<String, dynamic> json)
      : coachBatchSetupDetailId = json['CoachBatchSetupDetailId'] as int?,
        coachBatchSetupDaySlotMapId = json['CoachBatchSetupDaySlotMapId'] as int?,
        startTime = json['StartTime'] as String?,
        endTime = json['EndTime'] as String?;

  Map<String, dynamic> toJson() => {
        'CoachBatchSetupDetailId': coachBatchSetupDetailId,
        'CoachBatchSetupDaySlotMapId': coachBatchSetupDaySlotMapId,
        'StartTime': startTime,
        'EndTime': endTime
      };
}
