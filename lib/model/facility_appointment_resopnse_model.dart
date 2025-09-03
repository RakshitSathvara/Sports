class FacilityAppointmentsResponseModel {
  final String? date;
  final int? dayNo;
  String? day = '';
  final List<FacilityAppointmentListingSlotDtos>? appointmentListingSlotDtos;

  FacilityAppointmentsResponseModel({
    this.date,
    this.dayNo,
    this.day,
    this.appointmentListingSlotDtos,
  });

  FacilityAppointmentsResponseModel.fromJson(Map<String, dynamic> json)
      : date = json['Date'] as String?,
        dayNo = json['DayNo'] as int?,
        appointmentListingSlotDtos = (json['AppointmentListingSlotDtos']
                as List?)
            ?.map((dynamic e) => FacilityAppointmentListingSlotDtos.fromJson(
                e as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() => {
        'Date': date,
        'DayNo': dayNo,
        'AppointmentListingSlotDtos':
            appointmentListingSlotDtos?.map((e) => e.toJson()).toList()
      };
}

class FacilityAppointmentListingSlotDtos {
  final bool? isCancel;
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

  FacilityAppointmentListingSlotDtos({
    this.isCancel,
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
  });

  FacilityAppointmentListingSlotDtos.fromJson(Map<String, dynamic> json)
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
