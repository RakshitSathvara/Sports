class FacilityCancelAppointmentVerificationResponseModel {
  final List<FacilityCancelAppointmentSlotDtos>? facilityCancelAppointmentSlotDtos;
  final int? subActivityId;
  final int? userId;
  final int? cancelReasonId;
  final String? otherReason;

  FacilityCancelAppointmentVerificationResponseModel({
    this.facilityCancelAppointmentSlotDtos,
    this.subActivityId,
    this.userId,
    this.cancelReasonId,
    this.otherReason,
  });

  FacilityCancelAppointmentVerificationResponseModel.fromJson(Map<String, dynamic> json)
      : facilityCancelAppointmentSlotDtos = (json['FacilityCancelAppointmentSlotDtos'] as List?)
            ?.map((dynamic e) => FacilityCancelAppointmentSlotDtos.fromJson(e as Map<String, dynamic>))
            .toList(),
        subActivityId = json['SubActivityId'] as int?,
        userId = json['UserId'] as int?,
        cancelReasonId = json['CancelReasonId'] as int? ,
        otherReason = json['OtherReason'] as String?;

  Map<String, dynamic> toJson() => {
        'FacilityCancelAppointmentSlotDtos': facilityCancelAppointmentSlotDtos?.map((e) => e.toJson()).toList(),
        'SubActivityId': subActivityId,
        'UserId': userId,
        'CancelReasonId': cancelReasonId,
        'OtherReason': otherReason
      };
}

class FacilityCancelAppointmentSlotDtos {
  final int? slotMapId;
  final String? bookingDate;
  final bool? isVerificationRequired;
  final double? refundedAmount;

  FacilityCancelAppointmentSlotDtos({
    this.slotMapId,
    this.bookingDate,
    this.isVerificationRequired,
    this.refundedAmount,
  });

  FacilityCancelAppointmentSlotDtos.fromJson(Map<String, dynamic> json)
      : slotMapId = json['SlotMapId'] as int?,
        bookingDate = json['BookingDate'] as String?,
        isVerificationRequired = json['IsVerificationRequired'] as bool?,
        refundedAmount = json['RefundedAmount'] as double?;

  Map<String, dynamic> toJson() => {
        'SlotMapId': slotMapId,
        'BookingDate': bookingDate,
        'IsVerificationRequired': isVerificationRequired,
        'RefundedAmount': refundedAmount
      };
}
