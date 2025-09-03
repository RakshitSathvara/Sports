class AvailableSlotsByDateResponseModel {
  final int? facilitySetupDaySlotMapId;
  final int? totalSeat;
  final int? bookedSeat;
  final int? availableSeat;
  final bool? isSlotCancelled;

  AvailableSlotsByDateResponseModel({this.facilitySetupDaySlotMapId, this.totalSeat, this.bookedSeat, this.availableSeat, this.isSlotCancelled});

  AvailableSlotsByDateResponseModel.fromJson(Map<String, dynamic> json)
      : facilitySetupDaySlotMapId = json['FacilitySetupDaySlotMapId'] as int?,
        totalSeat = json['TotalSeat'] as int?,
        bookedSeat = json['BookedSeat'] ?? 0,
        isSlotCancelled = json['IsSlotCancelled'] ?? false,
        availableSeat = json['AvailableSeat'] ?? 0;

  Map<String, dynamic> toJson() => {
        'FacilitySetupDaySlotMapId': facilitySetupDaySlotMapId,
        'TotalSeat': totalSeat,
        'BookedSeat': bookedSeat,
        'AvailableSeat': availableSeat,
        'IsSlotCancelled': isSlotCancelled
      };
}
