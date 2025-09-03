import 'package:custom_timer/custom_timer.dart';

class CancellationRequestsListModel {
  List<CancellationRequest>? data;
  int? totalCount;
  int? pageStart;
  int? resultPerPage;

  CancellationRequestsListModel({
    this.data,
    this.totalCount,
    this.pageStart,
    this.resultPerPage,
  });

  CancellationRequestsListModel.fromJson(Map<String, dynamic> json) {
    data = (json['Data'] as List?)?.map((dynamic e) => CancellationRequest.fromJson(e as Map<String, dynamic>)).toList();
    totalCount = json['TotalCount'] as int?;
    pageStart = json['PageStart'] as int?;
    resultPerPage = json['ResultPerPage'] as int?;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = <String, dynamic>{};
    json['Data'] = data?.map((e) => e.toJson()).toList();
    json['TotalCount'] = totalCount;
    json['PageStart'] = pageStart;
    json['ResultPerPage'] = resultPerPage;
    return json;
  }
}

class CancellationRequest {
  String? bookingDate;
  int? startTimeInMinute;
  int? endTimeInMinute;
  int? coachBookingId;
  String? expiredAt;
  String? firstName;
  String? lastName;
  String? createdAt;
  String? bookingNo;
  String? facilityName;
  String? status;
  String? startTime;
  String? endTime;
  int? bookingRefundVerificationId;
  double? ratePerHour;
  double? amount;
  double? totalAmount;
  CustomTimerController? expireTimeController;
  Duration? expireTime;

  CancellationRequest({
    this.bookingDate,
    this.startTimeInMinute,
    this.endTimeInMinute,
    this.coachBookingId,
    this.expiredAt,
    this.firstName,
    this.lastName,
    this.createdAt,
    this.bookingNo,
    this.facilityName,
    this.status,
    this.startTime,
    this.endTime,
    this.bookingRefundVerificationId,
    this.ratePerHour,
    this.amount,
    this.totalAmount,
    this.expireTimeController,
    this.expireTime = const Duration(),
  });

  CancellationRequest.fromJson(Map<String, dynamic> json) {
    bookingDate = json['BookingDate'] as String?;
    startTimeInMinute = json['StartTimeInMinute'] as int?;
    endTimeInMinute = json['EndTimeInMinute'] as int?;
    coachBookingId = json['CoachBookingId'] as int?;
    expiredAt = json['ExpiredAt'] as String?;
    firstName = json['FirstName'] as String?;
    lastName = json['LastName'] as String?;
    createdAt = json['CreatedAt'] as String?;
    bookingNo = json['BookingNo'] as String?;
    facilityName = json['FacilityName'] as String?;
    status = json['Status'] as String?;
    startTime = json['StartTime'] as String?;
    endTime = json['EndTime'] as String?;
    bookingRefundVerificationId = json['BookingRefundVerificationId'] as int?;
    ratePerHour = json['RatePerHour'] as double?;
    amount = json['Amount'] as double?;
    totalAmount = json['TotalAmount'] as double?;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = <String, dynamic>{};
    json['BookingDate'] = bookingDate;
    json['StartTimeInMinute'] = startTimeInMinute;
    json['EndTimeInMinute'] = endTimeInMinute;
    json['CoachBookingId'] = coachBookingId;
    json['ExpiredAt'] = expiredAt;
    json['FirstName'] = firstName;
    json['LastName'] = lastName;
    json['CreatedAt'] = createdAt;
    json['BookingNo'] = bookingNo;
    json['FacilityName'] = facilityName;
    json['Status'] = status;
    json['BookingRefundVerificationId'] = bookingRefundVerificationId;
    json['RatePerHour'] = ratePerHour;
    json['Amount'] = amount;
    json['TotalAmount'] = totalAmount;
    return json;
  }
}
