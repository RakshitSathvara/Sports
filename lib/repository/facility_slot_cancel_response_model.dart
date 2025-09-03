class FacilitySlotCancelResponseModel {
  final int? facilitySetupId;
  final int? facilitySetupDaySlotMapId;
  final int? facilitySetupDaySlotId;

  FacilitySlotCancelResponseModel({
    this.facilitySetupId,
    this.facilitySetupDaySlotMapId,
    this.facilitySetupDaySlotId,
  });

  FacilitySlotCancelResponseModel.fromJson(Map<String, dynamic> json)
      : facilitySetupId = json['FacilitySetupId'] as int?,
        facilitySetupDaySlotMapId = json['FacilitySetupDaySlotMapId'] as int?,
        facilitySetupDaySlotId = json['FacilitySetupDaySlotId'] as int?;

  Map<String, dynamic> toJson() => {
        'FacilitySetupId': facilitySetupId,
        'FacilitySetupDaySlotMapId': facilitySetupDaySlotMapId,
        'FacilitySetupDaySlotId': facilitySetupDaySlotId
      };
}
