class CoachSlotCancelResponseModel {
  final int? coachBatchSetupDaySlotMapId;
  final int? coachBatchSetupDaySlotId;
  final int? coachBatchSetupId;

  CoachSlotCancelResponseModel({
    this.coachBatchSetupDaySlotMapId,
    this.coachBatchSetupDaySlotId,
    this.coachBatchSetupId,
  });

  CoachSlotCancelResponseModel.fromJson(Map<String, dynamic> json)
      : coachBatchSetupDaySlotMapId =
            json['CoachBatchSetupDaySlotMapId'] as int?,
        coachBatchSetupDaySlotId = json['CoachBatchSetupDaySlotId'] as int?,
        coachBatchSetupId = json['CoachBatchSetupId'] as int?;

  Map<String, dynamic> toJson() => {
        'CoachBatchSetupDaySlotMapId': coachBatchSetupDaySlotMapId,
        'CoachBatchSetupDaySlotId': coachBatchSetupDaySlotId,
        'CoachBatchSetupId': coachBatchSetupId
      };
}
