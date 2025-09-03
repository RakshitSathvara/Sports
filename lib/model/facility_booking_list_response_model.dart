class FacilityBookingListModelResponse {
  final int? facilityBookingFreezeId;
  final String? facilityName;
  final String? email;
  final String? mobCountryCode;
  final String? mobileNumber;
  final String? transactionDate;
  final String? expireAt;
  final EndUser? endUser;
  final SubActivities? subActivities;
  final bool? isActive;
  final double? ratePerHour;
  final double? amount;
  final double? totalAmount;
  final List<FacilityBookingFreezeSlots>? facilityBookingFreezeSlots;
  final String? cancellationPolicyTime;

  FacilityBookingListModelResponse(
      {this.facilityBookingFreezeId,
      this.facilityName,
      this.email,
      this.mobCountryCode,
      this.mobileNumber,
      this.transactionDate,
      this.expireAt,
      this.endUser,
      this.subActivities,
      this.isActive,
      this.ratePerHour,
      this.amount,
      this.totalAmount,
      this.facilityBookingFreezeSlots,
      this.cancellationPolicyTime});

  FacilityBookingListModelResponse.fromJson(Map<String, dynamic> json)
      : facilityBookingFreezeId = json['FacilityBookingFreezeId'] as int?,
        facilityName = json['FacilityName'] as String?,
        email = json['Email'] as String?,
        mobCountryCode = json['MobCountryCode'] as String?,
        mobileNumber = json['MobileNumber'] as String?,
        transactionDate = json['TransactionDate'] as String?,
        expireAt = json['ExpireAt'] as String?,
        endUser = (json['EndUser'] as Map<String, dynamic>?) != null ? EndUser.fromJson(json['EndUser'] as Map<String, dynamic>) : null,
        subActivities = (json['SubActivities'] as Map<String, dynamic>?) != null ? SubActivities.fromJson(json['SubActivities'] as Map<String, dynamic>) : null,
        isActive = json['IsActive'] as bool?,
        ratePerHour = json['RatePerHour'] as double?,
        amount = json['Amount'] as double?,
        totalAmount = json['TotalAmount'] as double?,
        facilityBookingFreezeSlots =
            (json['FacilityBookingFreezeSlots'] as List?)?.map((dynamic e) => FacilityBookingFreezeSlots.fromJson(e as Map<String, dynamic>)).toList(),
        cancellationPolicyTime = json['CancellationPolicyTime'] as String?;

  Map<String, dynamic> toJson() => {
        'FacilityBookingFreezeId': facilityBookingFreezeId,
        'FacilityName': facilityName,
        'Email': email,
        'MobCountryCode': mobCountryCode,
        'MobileNumber': mobileNumber,
        'TransactionDate': transactionDate,
        'ExpireAt': expireAt,
        'EndUser': endUser?.toJson(),
        'SubActivities': subActivities?.toJson(),
        'IsActive': isActive,
        'RatePerHour': ratePerHour,
        'Amount': amount,
        'TotalAmount': totalAmount,
        'FacilityBookingFreezeSlots': facilityBookingFreezeSlots?.map((e) => e.toJson()).toList(),
        'CancellationPolicyTime': cancellationPolicyTime
      };
}

class EndUser {
  final String? firstName;
  final String? lastName;

  EndUser({
    this.firstName,
    this.lastName,
  });

  EndUser.fromJson(Map<String, dynamic> json)
      : firstName = json['FirstName'] as String?,
        lastName = json['LastName'] as String?;

  Map<String, dynamic> toJson() => {'FirstName': firstName, 'LastName': lastName};
}

class SubActivities {
  final String? name;
  final Activities? activities;

  SubActivities({
    this.name,
    this.activities,
  });

  SubActivities.fromJson(Map<String, dynamic> json)
      : name = json['Name'] as String?,
        activities = (json['Activities'] as Map<String, dynamic>?) != null ? Activities.fromJson(json['Activities'] as Map<String, dynamic>) : null;

  Map<String, dynamic> toJson() => {'Name': name, 'Activities': activities?.toJson()};
}

class Activities {
  final String? name;

  Activities({
    this.name,
  });

  Activities.fromJson(Map<String, dynamic> json) : name = json['Name'] as String?;

  Map<String, dynamic> toJson() => {'Name': name};
}

class FacilityBookingFreezeSlots {
  final String? bookingDate;
  final int? facilitySetupDaySlotMapId;
  final String? startTime;
  final String? endTime;
  final int? startTimeInMinute;
  final int? endTimeInMinute;
  final double? amount;
  final double? totalAmount;
  final double? ratePerHour;
  bool? isSlotSelected = true;
  double? discountAmount = 0.0;

  FacilityBookingFreezeSlots(
      {this.bookingDate,
      this.facilitySetupDaySlotMapId,
      this.startTime,
      this.endTime,
      this.startTimeInMinute,
      this.endTimeInMinute,
      this.amount,
      this.totalAmount,
      this.ratePerHour,
      this.isSlotSelected,
      this.discountAmount = 0.0});

  FacilityBookingFreezeSlots.fromJson(Map<String, dynamic> json)
      : bookingDate = json['BookingDate'] as String?,
        facilitySetupDaySlotMapId = json['FacilitySetupDaySlotMapId'] as int?,
        startTime = json['StartTime'] as String?,
        endTime = json['EndTime'] as String?,
        startTimeInMinute = json['StartTimeInMinute'] as int?,
        endTimeInMinute = json['EndTimeInMinute'] as int?,
        amount = json['Amount'] as double?,
        totalAmount = json['TotalAmount'] as double?,
        ratePerHour = json['RatePerHour'] as double?;

  Map<String, dynamic> toJson() => {
        'BookingDate': bookingDate,
        'FacilitySetupDaySlotMapId': facilitySetupDaySlotMapId,
        'StartTime': startTime,
        'EndTime': endTime,
        'StartTimeInMinute': startTimeInMinute,
        'EndTimeInMinute': endTimeInMinute,
        'Amount': amount,
        'TotalAmount': totalAmount,
        'RatePerHour': ratePerHour,
      };
}
