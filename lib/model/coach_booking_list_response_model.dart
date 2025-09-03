class CoachBookingListModelResponse {
  final int? coachBookingFreezeId;
  final String? lastName;
  final String? email;
  final String? mobCountryCode;
  final String? mobileNumber;
  final String? transactionDate;
  final String? expireAt;
  final int? endUserId;
  final EndUser? endUser;
  final SubActivities? subActivities;
  final double? amount;
  final double? totalAmount;
  final bool? isActive;
  final double? ratePerHour;
  final List<CoachBookingFreezeSlots>? coachBookingFreezeSlots;
  final String? cancellationPolicyTime;

  CoachBookingListModelResponse({
    this.coachBookingFreezeId,
    this.lastName,
    this.email,
    this.mobCountryCode,
    this.mobileNumber,
    this.transactionDate,
    this.expireAt,
    this.endUserId,
    this.endUser,
    this.subActivities,
    this.amount,
    this.totalAmount,
    this.isActive,
    this.ratePerHour,
    this.coachBookingFreezeSlots,
    this.cancellationPolicyTime,
  });

  CoachBookingListModelResponse.fromJson(Map<String, dynamic> json)
      : coachBookingFreezeId = json['CoachBookingFreezeId'] as int?,
        lastName = json['LastName'] as String?,
        email = json['Email'] as String?,
        mobCountryCode = json['MobCountryCode'] as String?,
        mobileNumber = json['MobileNumber'] as String?,
        transactionDate = json['TransactionDate'] as String?,
        expireAt = json['ExpireAt'] as String?,
        endUserId = json['EndUserId'] as int?,
        endUser = (json['EndUser'] as Map<String, dynamic>?) != null ? EndUser.fromJson(json['EndUser'] as Map<String, dynamic>) : null,
        subActivities = (json['SubActivities'] as Map<String, dynamic>?) != null ? SubActivities.fromJson(json['SubActivities'] as Map<String, dynamic>) : null,
        amount = json['Amount'] as double?,
        totalAmount = json['TotalAmount'] as double?,
        isActive = json['IsActive'] as bool?,
        ratePerHour = json['RatePerHour'] as double?,
        coachBookingFreezeSlots =
            (json['CoachBookingFreezeSlots'] as List?)?.map((dynamic e) => CoachBookingFreezeSlots.fromJson(e as Map<String, dynamic>)).toList(),
        cancellationPolicyTime = json['CancellationPolicyTime'] as String?;

  Map<String, dynamic> toJson() => {
        'CoachBookingFreezeId': coachBookingFreezeId,
        'LastName': lastName,
        'Email': email,
        'MobCountryCode': mobCountryCode,
        'MobileNumber': mobileNumber,
        'TransactionDate': transactionDate,
        'ExpireAt': expireAt,
        'EndUserId': endUserId,
        'EndUser': endUser?.toJson(),
        'SubActivities': subActivities?.toJson(),
        'Amount': amount,
        'TotalAmount': totalAmount,
        'IsActive': isActive,
        'RatePerHour': ratePerHour,
        'CoachBookingFreezeSlots': coachBookingFreezeSlots?.map((e) => e.toJson()).toList(),
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

class CoachBookingFreezeSlots {
  final String? bookingDate;
  final int? coachBatchSetupDaySlotMapId;
  final int? startTimeInMinute;
  final int? endTimeInMinute;
  final String? startTime;
  final String? endTime;
  final double? amount;
  final double? ratePerHour;
  final double? totalAmount;
  bool? isSlotSelected = true;
  double? discountAmount = 0.0;

  CoachBookingFreezeSlots(
      {this.bookingDate,
      this.coachBatchSetupDaySlotMapId,
      this.startTimeInMinute,
      this.endTimeInMinute,
      this.startTime,
      this.endTime,
      this.amount,
      this.totalAmount,
      this.ratePerHour,
      this.isSlotSelected,
      this.discountAmount});

  CoachBookingFreezeSlots.fromJson(Map<String, dynamic> json)
      : bookingDate = json['BookingDate'] as String?,
        coachBatchSetupDaySlotMapId = json['CoachBatchSetupDaySlotMapId'] as int?,
        startTimeInMinute = json['StartTimeInMinute'] as int?,
        endTimeInMinute = json['EndTimeInMinute'] as int?,
        startTime = json['StartTime'] as String?,
        endTime = json['EndTime'] as String?,
        amount = json['Amount'] as double?,
        ratePerHour = json['RatePerHour'] as double?,
        totalAmount = json['TotalAmount'] as double?;

  Map<String, dynamic> toJson() => {
        'BookingDate': bookingDate,
        'CoachBatchSetupDaySlotMapId': coachBatchSetupDaySlotMapId,
        'StartTimeInMinute': startTimeInMinute,
        'EndTimeInMinute': endTimeInMinute,
        'StartTime': startTime,
        'EndTime': endTime,
        'Amount': amount,
        'TotalAmount': totalAmount,
        'RatePerHour': ratePerHour,
      };
}
