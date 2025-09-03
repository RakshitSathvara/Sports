class FreezeFacilityResponseModel {
  final int? facilityBookingFreezeId;
  final String? transactionDate;
  final int? endUserId;
  final int? facilitySetupDetailId;
  final dynamic expireAt;
  final bool? isActive;
  final bool? isSlotSelected;
  final double? totalAmount;
  final String? bookingDate;
  final int? facilitySetupDaySlotMapId;
  final bool? expireFreezeTime;
  final bool? isMeetupConflict;

  FreezeFacilityResponseModel(
      {this.facilityBookingFreezeId,
      this.transactionDate,
      this.endUserId,
      this.facilitySetupDetailId,
      this.expireAt,
      this.isActive,
      this.isSlotSelected,
      this.totalAmount,
      this.bookingDate,
      this.facilitySetupDaySlotMapId,
      this.expireFreezeTime,
      this.isMeetupConflict});

  FreezeFacilityResponseModel.fromJson(Map<String, dynamic> json)
      : facilityBookingFreezeId = json['FacilityBookingFreezeId'] as int?,
        transactionDate = json['TransactionDate'] as String?,
        endUserId = json['EndUserId'] as int?,
        facilitySetupDetailId = json['FacilitySetupDetailId'] as int?,
        expireAt = json['ExpireAt'],
        isActive = json['IsActive'] as bool?,
        isSlotSelected = json['IsSlotSelected'] as bool?,
        totalAmount = json['TotalAmount'] as double?,
        bookingDate = json['BookingDate'] as String?,
        facilitySetupDaySlotMapId = json['FacilitySetupDaySlotMapId'] as int?,
        expireFreezeTime = json['ExpireFreezeTime'] as bool?,
        isMeetupConflict = json['IsMeetupConflict'] ?? false;

  Map<String, dynamic> toJson() => {
        'FacilityBookingFreezeId': facilityBookingFreezeId,
        'TransactionDate': transactionDate,
        'EndUserId': endUserId,
        'FacilitySetupDetailId': facilitySetupDetailId,
        'ExpireAt': expireAt,
        'IsActive': isActive,
        'IsSlotSelected': isSlotSelected,
        'TotalAmount': totalAmount,
        'BookingDate': bookingDate,
        'FacilitySetupDaySlotMapId': facilitySetupDaySlotMapId,
        'ExpireFreezeTime': expireFreezeTime
      };
}
