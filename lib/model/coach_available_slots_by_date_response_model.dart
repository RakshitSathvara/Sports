class CoachAvailableSlotsByDateResponseModel {
  final int? coachBatchSetupDaySlotMapId;
  final int? totalSeat;
  final int? bookedSeat;
  final int? availableSeat;
  final bool? isSlotCancelled;

  CoachAvailableSlotsByDateResponseModel({this.coachBatchSetupDaySlotMapId, this.totalSeat, this.bookedSeat, this.availableSeat, this.isSlotCancelled});

  CoachAvailableSlotsByDateResponseModel.fromJson(Map<String, dynamic> json)
      : coachBatchSetupDaySlotMapId = json['CoachBatchSetupDaySlotMapId'] as int?,
        totalSeat = json['TotalSeat'] as int?,
        bookedSeat = json['BookedSeat'] ?? 0,
        availableSeat = json['AvailableSeat'] ?? 0,
        isSlotCancelled = json['IsSlotCancelled'] ?? false;

  Map<String, dynamic> toJson() => {
        'CoachBatchSetupDaySlotMapId': coachBatchSetupDaySlotMapId,
        'TotalSeat': totalSeat,
        'BookedSeat': bookedSeat,
        'AvailableSeat': availableSeat,
        'IsSlotCancelled': isSlotCancelled
      };
}
