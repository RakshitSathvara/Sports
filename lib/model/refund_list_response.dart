class RefundListResponse {
  List<RefundTransaction>? data;
  int? totalCount;
  int? pageStart;
  int? resultPerPage;

  RefundListResponse({this.data, this.totalCount, this.pageStart, this.resultPerPage});

  RefundListResponse.fromJson(Map<String, dynamic> json) {
    if (json['Data'] != null) {
      data = <RefundTransaction>[];
      json['Data'].forEach((v) {
        data!.add(new RefundTransaction.fromJson(v));
      });
    }
    totalCount = json['TotalCount'];
    pageStart = json['PageStart'];
    resultPerPage = json['ResultPerPage'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['Data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['TotalCount'] = this.totalCount;
    data['PageStart'] = this.pageStart;
    data['ResultPerPage'] = this.resultPerPage;
    return data;
  }
}

class RefundTransaction {
  int? id;
  bool? isCoachBooking;
  int? bookingId;
  String? bookingNo;
  int? endUserId;
  double? refundAmount;
  String? bookingDate;
  String? firstName;
  String? lastName;
  String? setupName;
  String? paymentStatus;
  int? startTimeInMinute;
  int? endTimeInMinute;
  int? bookingSlotId;
  String? refundCreatedAt;
  String? startTime;
  String? endTime;
  String? cancelReason;
  String? otherReason;

  RefundTransaction(
      {this.id,
      this.isCoachBooking,
      this.bookingId,
      this.bookingNo,
      this.endUserId,
      this.refundAmount,
      this.bookingDate,
      this.firstName,
      this.lastName,
      this.setupName,
      this.paymentStatus,
      this.startTimeInMinute,
      this.endTimeInMinute,
      this.bookingSlotId,
      this.refundCreatedAt,
      this.startTime,
      this.cancelReason,
      this.otherReason,
      this.endTime});

  RefundTransaction.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    isCoachBooking = json['IsCoachBooking'];
    bookingId = json['BookingId'];
    bookingNo = json['BookingNo'];
    endUserId = json['EndUserId'];
    refundAmount = json['RefundAmount'];
    bookingDate = json['BookingDate'];
    firstName = json['FirstName'];
    lastName = json['LastName'];
    setupName = json['SetupName'];
    paymentStatus = json['PaymentStatus'];
    startTimeInMinute = json['StartTimeInMinute'];
    endTimeInMinute = json['EndTimeInMinute'];
    bookingSlotId = json['BookingSlotId'];
    refundCreatedAt = json['RefundCreatedAt'];
    startTime = json['StartTime'];
    endTime = json['EndTime'];
    cancelReason = json['CancelReason'];
    otherReason = json['OtherReason'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['IsCoachBooking'] = this.isCoachBooking;
    data['BookingId'] = this.bookingId;
    data['BookingNo'] = this.bookingNo;
    data['EndUserId'] = this.endUserId;
    data['RefundAmount'] = this.refundAmount;
    data['BookingDate'] = this.bookingDate;
    data['FirstName'] = this.firstName;
    data['LastName'] = this.lastName;
    data['SetupName'] = this.setupName;
    data['PaymentStatus'] = this.paymentStatus;
    data['StartTimeInMinute'] = this.startTimeInMinute;
    data['EndTimeInMinute'] = this.endTimeInMinute;
    data['BookingSlotId'] = this.bookingSlotId;
    data['RefundCreatedAt'] = this.refundCreatedAt;
    data['StartTime'] = this.startTime;
    data['EndTime'] = this.endTime;
    data['CancelReason'] = this.cancelReason;
    data['OtherReason'] = this.otherReason;
    return data;
  }
}
