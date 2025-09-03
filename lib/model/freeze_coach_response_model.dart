class FreezeCoachResponseModel {
  final int? coachBookingFreezeId;
  final String? transactionDate;
  final int? endUserId;
  final int? coachBatchSetupDetailId;
  final dynamic expireAt;
  final bool? isActive;
  final bool? isSlotSelected;
  final double? totalAmount;
  final String? bookingDate;
  final int? coachBatchSetupDaySlotMapId;
  final bool? expireFreezeTime;
  final bool? isMeetupConflict;

  FreezeCoachResponseModel(
      {this.coachBookingFreezeId,
      this.transactionDate,
      this.endUserId,
      this.coachBatchSetupDetailId,
      this.expireAt,
      this.isActive,
      this.isSlotSelected,
      this.totalAmount,
      this.bookingDate,
      this.coachBatchSetupDaySlotMapId,
      this.expireFreezeTime,
      this.isMeetupConflict});

  FreezeCoachResponseModel.fromJson(Map<String, dynamic> json)
      : coachBookingFreezeId = json['CoachBookingFreezeId'] as int?,
        transactionDate = json['TransactionDate'] as String?,
        endUserId = json['EndUserId'] as int?,
        coachBatchSetupDetailId = json['CoachBatchSetupDetailId'] as int?,
        expireAt = json['ExpireAt'],
        isActive = json['IsActive'] as bool?,
        isSlotSelected = json['IsSlotSelected'] as bool?,
        totalAmount = json['TotalAmount'] as double?,
        bookingDate = json['BookingDate'] as String?,
        coachBatchSetupDaySlotMapId = json['CoachBatchSetupDaySlotMapId'] as int?,
        expireFreezeTime = json['ExpireFreezeTime'] as bool?,
        isMeetupConflict = json['IsMeetupConflict'] ?? false;

  Map<String, dynamic> toJson() => {
        'CoachBookingFreezeId': coachBookingFreezeId,
        'TransactionDate': transactionDate,
        'EndUserId': endUserId,
        'CoachBatchSetupDetailId': coachBatchSetupDetailId,
        'ExpireAt': expireAt,
        'IsActive': isActive,
        'IsSlotSelected': isSlotSelected,
        'TotalAmount': totalAmount,
        'BookingDate': bookingDate,
        'CoachBatchSetupDaySlotMapId': coachBatchSetupDaySlotMapId,
        'ExpireFreezeTime': expireFreezeTime
      };
}
