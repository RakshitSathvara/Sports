class FacilityAppointmentDetailModel {
  final int? facilityBookingId;
  final String? bookingNo;
  final String? transactionDate;
  final double? totalAmt;
  final int? subActivityId;
  final String? subActivityName;
  final String? activityName;
  final String? endUserFirstName;
  final String? endUserLastName;
  final String? endUserMobileNumber;
  final String? endUserEmail;
  final String? bookingType;
  final String? facilitySetupTitle;
  final String? facilitySetupSubTitle;
  final String? facilityName;
  final String? facilityMobileNumber;
  final String? facilityEmail;
  final double? avarageRating;
  final String? referralCouponText;
  final List<FacilityBookingSlotDates>? facilityBookingSlotDates;
  final FacilityBookingReviewModel? facilityBookingReviews;
  List<PaymentTransaction>? paymentTransaction;
  final String? cancellationPolicyTime;
  String? address;

  FacilityAppointmentDetailModel(
      {this.facilityBookingId,
      this.bookingNo,
      this.transactionDate,
      this.totalAmt,
      this.subActivityId,
      this.subActivityName,
      this.activityName,
      this.endUserFirstName,
      this.endUserLastName,
      this.endUserMobileNumber,
      this.endUserEmail,
      this.bookingType,
      this.facilitySetupTitle,
      this.facilitySetupSubTitle,
      this.facilityName,
      this.facilityMobileNumber,
      this.facilityEmail,
      this.avarageRating,
      this.facilityBookingSlotDates,
      this.facilityBookingReviews,
      this.paymentTransaction,
      this.cancellationPolicyTime,
      this.address,
      this.referralCouponText});

  // FacilityAppointmentDetailModel(
  //     {this.facilityBookingId,
  //     this.bookingNo,
  //     this.transactionDate,
  //     this.totalAmt,
  //     this.subActivityId,
  //     this.subActivityName,
  //     this.activityName,
  //     this.endUserFirstName,
  //     this.endUserLastName,
  //     this.endUserMobileNumber,
  //     this.endUserEmail,
  //     this.bookingType,
  //     this.facilitySetupTitle,
  //     this.facilitySetupSubTitle,
  //     this.facilityName,
  //     this.facilityMobileNumber,
  //     this.facilityEmail,
  //     this.avarageRating,
  //     this.facilityBookingSlotDates,
  //     this.facilityBookingReviews,
  //     this.cancellationPolicyTime});

  FacilityAppointmentDetailModel.fromJson(Map<String, dynamic> json)
      : facilityBookingId = json['FacilityBookingId'] as int?,
        bookingNo = json['BookingNo'] as String?,
        transactionDate = json['TransactionDate'] as String?,
        totalAmt = json['TotalAmt'] as double?,
        subActivityId = json['SubActivityId'] as int?,
        subActivityName = json['SubActivityName'] as String?,
        activityName = json['ActivityName'] as String?,
        endUserFirstName = json['EndUserFirstName'] as String?,
        endUserLastName = json['EndUserLastName'] as String?,
        endUserMobileNumber = json['EndUserMobileNumber'] as String?,
        endUserEmail = json['EndUserEmail'] as String?,
        bookingType = json['BookingType'] as String?,
        facilitySetupTitle = json['FacilitySetupTitle'] as String?,
        facilitySetupSubTitle = json['FacilitySetupSubTitle'] as String?,
        facilityName = json['FacilityName'] as String?,
        facilityMobileNumber = json['FacilityMobileNumber'] as String?,
        facilityEmail = json['FacilityEmail'] as String?,
        avarageRating = json['AvarageRating'] as double?,
        facilityBookingSlotDates =
            (json['FacilityBookingSlotDates'] as List?)?.map((dynamic e) => FacilityBookingSlotDates.fromJson(e as Map<String, dynamic>)).toList(),
        facilityBookingReviews = json['FacilityBookingReview'] != null ? FacilityBookingReviewModel.fromJson(json['FacilityBookingReview']) : null,
        paymentTransaction = (json['PaymentTransaction'] as List?)?.map((dynamic e) => PaymentTransaction.fromJson(e as Map<String, dynamic>)).toList(),
        cancellationPolicyTime = json['CancellationPolicyTime'],
        address = json['Address'] ?? '',
        referralCouponText = json['ReferralCouponText'];

  Map<String, dynamic> toJson() => {
        'FacilityBookingId': facilityBookingId,
        'BookingNo': bookingNo,
        'TransactionDate': transactionDate,
        'TotalAmt': totalAmt,
        'SubActivityId': subActivityId,
        'SubActivityName': subActivityName,
        'ActivityName': activityName,
        'EndUserFirstName': endUserFirstName,
        'EndUserLastName': endUserLastName,
        'EndUserMobileNumber': endUserMobileNumber,
        'EndUserEmail': endUserEmail,
        'BookingType': bookingType,
        'FacilitySetupTitle': facilitySetupTitle,
        'FacilitySetupSubTitle': facilitySetupSubTitle,
        'FacilityName': facilityName,
        'FacilityMobileNumber': facilityMobileNumber,
        'FacilityEmail': facilityEmail,
        'AvarageRating': avarageRating,
        'FacilityBookingSlotDates': facilityBookingSlotDates?.map((e) => e.toJson()).toList(),
        'FacilityBookingReviews': facilityBookingReviews,
        'PaymentTransaction': paymentTransaction?.map((e) => e.toJson()).toList(),
        'CancellationPolicyTime': cancellationPolicyTime,
        'Address': address
      };
}

class FacilityBookingReviewModel {
  final int? reviewId;
  final int? facilityBookingId;
  final double? rating;
  final String? comment;
  FacilityBookingReviewModel({this.reviewId, this.facilityBookingId, this.rating, this.comment});

  FacilityBookingReviewModel.fromJson(Map<String, dynamic> json)
      : reviewId = json['ReviewId'] as int?,
        facilityBookingId = json['FacilityBookingId'] as int?,
        rating = json['Rating'] ?? 0.0,
        comment = json['Comment'] as String?;

  Map<String, dynamic> toJson() => {'ReviewId': reviewId, 'FacilityBookingId': facilityBookingId, 'Rating': rating, 'Comment': comment};
}

class FacilityBookingSlotDates {
  final String? bookingDate;
  final double? ratePerHour;
  final int? slotTimeMinute;
  final int? facilitySetupDaySlotMapId;
  final int? startTimeInMinute;
  final int? endTimeInMinute;
  final String? startTime;
  final String? endTime;
  final double? amount;
  final double? totalAmount;
  bool? isSlotSelected = true;
  bool? isCancelled;
  bool? isSlotCancelled = false;
  double? refundedAmount = 0.0;
  double? discountAmount = 0.0;
  double? bookingAmount = 0.0;
  double? discountPer = 0.0;

  FacilityBookingSlotDates(
      {this.bookingDate,
      this.ratePerHour,
      this.slotTimeMinute,
      this.facilitySetupDaySlotMapId,
      this.startTimeInMinute,
      this.endTimeInMinute,
      this.startTime,
      this.endTime,
      this.amount,
      this.totalAmount,
      this.isSlotSelected,
      this.isCancelled,
      this.refundedAmount,
      this.isSlotCancelled,
      this.discountAmount,
      this.bookingAmount,
      this.discountPer});

  FacilityBookingSlotDates.fromJson(Map<String, dynamic> json)
      : bookingDate = json['BookingDate'] as String?,
        ratePerHour = json['RatePerHour'] as double?,
        slotTimeMinute = json['SlotTimeMinute'] as int?,
        facilitySetupDaySlotMapId = json['FacilitySetupDaySlotMapId'] as int?,
        startTimeInMinute = json['StartTimeInMinute'] as int?,
        endTimeInMinute = json['EndTimeInMinute'] as int?,
        startTime = json['StartTime'] as String?,
        endTime = json['EndTime'] as String?,
        isCancelled = json['IsCancelled'] as bool?,
        isSlotCancelled = json['IsCancelled'] as bool?,
        amount = json['Amount'] as double?,
        totalAmount = json['TotalAmount'] as double?,
        discountAmount = json['DiscountAmount'] as double?,
        bookingAmount = json['BookingAmount'] ?? 0.0,
        discountPer = json['DiscountPer'] ?? 0.0;

  Map<String, dynamic> toJson() => {
        'BookingDate': bookingDate,
        'RatePerHour': ratePerHour,
        'SlotTimeMinute': slotTimeMinute,
        'FacilitySetupDaySlotMapId': facilitySetupDaySlotMapId,
        'StartTimeInMinute': startTimeInMinute,
        'EndTimeInMinute': endTimeInMinute,
        'StartTime': startTime,
        'EndTime': endTime,
        'Amount': amount,
        'TotalAmount': totalAmount,
        'IsCancelled': isCancelled,
        'DiscountAmount': discountAmount,
        'BookingAmount': bookingAmount
      };
}

class PaymentTransaction {
  int? facilityBookingId;
  String? status;
  double? amount;
  double? ratePerHour;
  double? totalAmount;
  bool? isRefund;
  String? bookingNo;
  int? trasactionId;
  String? createdAt;
  int? startTimeInMinute;
  int? endTimeInMinute;
  String? bookingDate;
  String? startTime;
  String? endTime;
  String? setupName;
  String? cancelreason;
  String? otherReason;
  String? entryFrom;
  String? cancelledBy;
  double? transactionDiscountAmount;

  PaymentTransaction({
    this.facilityBookingId,
    this.status,
    this.amount,
    this.ratePerHour,
    this.totalAmount,
    this.isRefund,
    this.bookingNo,
    this.trasactionId,
    this.createdAt,
    this.startTimeInMinute,
    this.endTimeInMinute,
    this.bookingDate,
    this.startTime,
    this.endTime,
    this.setupName,
    this.cancelreason,
    this.otherReason,
    this.entryFrom,
    this.cancelledBy,
    this.transactionDiscountAmount,
  });

  PaymentTransaction.fromJson(Map<String, dynamic> json) {
    facilityBookingId = json['FacilityBookingId'] as int?;
    status = json['Status'] as String?;
    amount = json['Amount'] as double?;
    ratePerHour = json['RatePerHour'] as double?;
    totalAmount = json['TotalAmount'] as double?;
    isRefund = json['IsRefund'] ?? false;
    bookingNo = json['BookingNo'] as String?;
    trasactionId = json['TrasactionId'] as int?;
    createdAt = json['CreatedAt'] as String?;
    startTimeInMinute = json['StartTimeInMinute'] as int?;
    endTimeInMinute = json['EndTimeInMinute'] as int?;
    bookingDate = json['BookingDate'] as String?;
    startTime = json['StartTime'] as String?;
    endTime = json['EndTime'] as String?;
    setupName = json['SetupName'] as String?;
    cancelreason = json['Cancelreason'] as String?;
    otherReason = json['OtherReason'] as String?;
    entryFrom = json['EntryFrom'] as String?;
    cancelledBy = json['CancelledBy'] as String?;
    transactionDiscountAmount = json['DiscountAmount'] as double?;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = <String, dynamic>{};
    json['FacilityBookingId'] = facilityBookingId;
    json['Status'] = status;
    json['Amount'] = amount;
    json['RatePerHour'] = ratePerHour;
    json['TotalAmount'] = totalAmount;
    json['IsRefund'] = isRefund;
    json['BookingNo'] = bookingNo;
    json['TrasactionId'] = trasactionId;
    json['CreatedAt'] = createdAt;
    json['StartTimeInMinute'] = startTimeInMinute;
    json['EndTimeInMinute'] = endTimeInMinute;
    json['BookingDate'] = bookingDate;
    json['StartTime'] = startTime;
    json['EndTime'] = endTime;
    json['SetupName'] = setupName;
    json['Cancelreason'] = cancelreason;
    json['OtherReason'] = otherReason;
    json['EntryFrom'] = entryFrom;
    json['CancelledBy'] = cancelledBy;
    json['DiscountAmount'] = transactionDiscountAmount;
    return json;
  }
}
