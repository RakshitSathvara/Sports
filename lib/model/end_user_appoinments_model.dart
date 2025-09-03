class EndUserAppointmentsResponseModel {
  final String? date;
  final int? dayNo;
  String? day = '';
  final List<AppointmentListingSlotDtos>? appointmentListingSlotDtos;

  EndUserAppointmentsResponseModel({
    this.date,
    this.dayNo,
    this.day,
    this.appointmentListingSlotDtos,
  });

  EndUserAppointmentsResponseModel.fromJson(Map<String, dynamic> json)
      : date = json['Date'] as String?,
        dayNo = json['DayNo'] as int?,
        appointmentListingSlotDtos = (json['AppointmentListingSlotDtos'] as List?)
            ?.map((dynamic e) => AppointmentListingSlotDtos.fromJson(e as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() => {
        'Date': date,
        'DayNo': dayNo,
        'AppointmentListingSlotDtos': appointmentListingSlotDtos?.map((e) => e.toJson()).toList()
      };
}

class AppointmentListingSlotDtos {
  bool? isCancel = false;
  bool? isPastSlot = false;
  final int? bookingId;
  final int? setupDaySlotMapId;
  final String? startTime;
  final String? endTime;
  final bool? isFacility;
  final String? setupName;
  final double? amount;
  final double? ratePerHour;
  final double? totalAmount;
  final int? endUserId;
  final String? endUserName;
  bool? isDirectSlotCancel = false;
  bool? isNotDirectSlotCancel = false;

  AppointmentListingSlotDtos(
      {this.isCancel,
      this.bookingId,
      this.setupDaySlotMapId,
      this.startTime,
      this.endTime,
      this.isFacility,
      this.setupName,
      this.amount,
      this.ratePerHour,
      this.totalAmount,
      this.endUserId,
      this.endUserName,
      this.isDirectSlotCancel,
      this.isNotDirectSlotCancel,});

  AppointmentListingSlotDtos.fromJson(Map<String, dynamic> json)
      : isCancel = json['IsCancel'] as bool?,
        bookingId = json['BookingId'] as int?,
        setupDaySlotMapId = json['SetupDaySlotMapId'] as int?,
        startTime = json['StartTime'] as String?,
        endTime = json['EndTime'] as String?,
        isFacility = json['IsFacility'] as bool?,
        setupName = json['SetupName'] as String?,
        amount = json['Amount'] as double?,
        ratePerHour = json['RatePerHour'] as double?,
        totalAmount = json['TotalAmount'] as double?,
        endUserId = json['EndUserId'] as int?,
        endUserName = json['EndUserName'] as String?;

  Map<String, dynamic> toJson() => {
        'IsCancel': isCancel,
        'BookingId': bookingId,
        'SetupDaySlotMapId': setupDaySlotMapId,
        'StartTime': startTime,
        'EndTime': endTime,
        'IsFacility': isFacility,
        'SetupName': setupName,
        'Amount': amount,
        'RatePerHour': ratePerHour,
        'TotalAmount': totalAmount,
        'EndUserId': endUserId,
        'EndUserName': endUserName
      };
}
