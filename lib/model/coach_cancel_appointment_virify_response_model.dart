class CoachCancelAppointmentVerificationResponseModel {
  final List<CoachCancelAppointmentSlotDtos>? coachCancelAppointmentSlotDtos;
  final int? userId;
  final int? cancelReasonId;
  final String? otherReason;

  CoachCancelAppointmentVerificationResponseModel({
    this.coachCancelAppointmentSlotDtos,
    this.userId,
    this.cancelReasonId,
    this.otherReason,
  });

  CoachCancelAppointmentVerificationResponseModel.fromJson(Map<String, dynamic> json)
      : coachCancelAppointmentSlotDtos = (json['CoachCancelAppointmentSlotDtos'] as List?)?.map((dynamic e) => CoachCancelAppointmentSlotDtos.fromJson(e as Map<String,dynamic>)).toList(),
        userId = json['UserId'] as int?,
        cancelReasonId = json['CancelReasonId'] as int?,
        otherReason = json['OtherReason'] as String?;

  Map<String, dynamic> toJson() => {
    'CoachCancelAppointmentSlotDtos' : coachCancelAppointmentSlotDtos?.map((e) => e.toJson()).toList(),
    'UserId' : userId,
    'CancelReasonId' : cancelReasonId,
    'OtherReason' : otherReason
  };
}

class CoachCancelAppointmentSlotDtos {
  final int? slotMapId;
  final String? bookingDate;
  final bool? isVerificationRequired;
  final double? refundedAmount;

  CoachCancelAppointmentSlotDtos({
    this.slotMapId,
    this.bookingDate,
    this.isVerificationRequired,
    this.refundedAmount,
  });

  CoachCancelAppointmentSlotDtos.fromJson(Map<String, dynamic> json)
      : slotMapId = json['SlotMapId'] as int?,
        bookingDate = json['BookingDate'] as String?,
        isVerificationRequired = json['IsVerificationRequired'] as bool?,
        refundedAmount = json['RefundedAmount'] as double?;

  Map<String, dynamic> toJson() => {
    'SlotMapId' : slotMapId,
    'BookingDate' : bookingDate,
    'IsVerificationRequired' : isVerificationRequired,
    'RefundedAmount' : refundedAmount
  };
}