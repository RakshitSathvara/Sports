class CoachAppointmentDetailResponseModel {
  final int? coachBookingId;
  final String? bookingNo;
  final String? transactionDate;
  final double? totalAmt;
  final int? subActivityId;
  final String? subActivityName;
  final String? activityName;
  final String? endUserFirstName;
  final String? endUserLastName;
  final List<CoachTrainingAddress>? coachTrainingAddress;
  final double? avarageRating;
  final List<CoachBookingSlotDates>? coachBookingSlotDates;
  final CoachBookingReviewsModel? coachBookingReviews;
  final String? endUserEmail;
  final String? endUserMobileNumber;
  final String? bookingType;
  final String? coachFirstName;
  final String? coachLastName;
  final String? setupName;
  final EndUserTrainingAddress? endUserTrainingAddress;
  List<PaymentTransaction>? paymentTransaction;
  final String? cancellationPolicyTime;
  String? coachMobileNumber;
  String? coachEmail;
  String? addressType;
  String? referralCouponText;

  CoachAppointmentDetailResponseModel(
      {this.coachBookingId,
      this.bookingNo,
      this.transactionDate,
      this.totalAmt,
      this.subActivityId,
      this.subActivityName,
      this.activityName,
      this.endUserFirstName,
      this.endUserLastName,
      this.coachTrainingAddress,
      this.avarageRating,
      this.coachBookingSlotDates,
      this.coachBookingReviews,
      this.endUserEmail,
      this.endUserMobileNumber,
      this.bookingType,
      this.coachFirstName,
      this.coachLastName,
      this.setupName,
      this.endUserTrainingAddress,
      this.paymentTransaction,
      this.cancellationPolicyTime,
      this.coachEmail,
      this.coachMobileNumber,
      this.addressType,
      this.referralCouponText});

  CoachAppointmentDetailResponseModel.fromJson(Map<String, dynamic> json)
      : coachBookingId = json['CoachBookingId'] as int?,
        bookingNo = json['BookingNo'] as String?,
        transactionDate = json['TransactionDate'] as String?,
        totalAmt = json['TotalAmt'] as double?,
        subActivityId = json['SubActivityId'] as int?,
        subActivityName = json['SubActivityName'] as String?,
        activityName = json['ActivityName'] as String?,
        endUserFirstName = json['EndUserFirstName'] as String?,
        endUserLastName = json['EndUserLastName'] as String?,
        endUserEmail = json['EndUserEmail'] as String?,
        endUserMobileNumber = json['EndUserMobileNumber'] as String?,
        bookingType = json['BookingType'] as String?,
        coachFirstName = json['CoachFirstName'] as String?,
        coachLastName = json['CoachLastName'] as String?,
        setupName = json['SetupName'] as String?,
        coachTrainingAddress = (json['CoachTrainingAddress'] as List?)?.map((dynamic e) => CoachTrainingAddress.fromJson(e as Map<String, dynamic>)).toList(),
        avarageRating = json['AvarageRating'] as double?,
        coachBookingSlotDates =
            (json['CoachBookingSlotDates'] as List?)?.map((dynamic e) => CoachBookingSlotDates.fromJson(e as Map<String, dynamic>)).toList(),
        coachBookingReviews = json['CoachBookingReview'] != null ? CoachBookingReviewsModel.fromJson(json['CoachBookingReview']) : null,
        paymentTransaction = (json['PaymentTransaction'] as List?)?.map((dynamic e) => PaymentTransaction.fromJson(e as Map<String, dynamic>)).toList(),
        endUserTrainingAddress = (json['EndUserTrainingAddress'] as Map<String, dynamic>?) != null
            ? EndUserTrainingAddress.fromJson(json['EndUserTrainingAddress'] as Map<String, dynamic>)
            : null,
        cancellationPolicyTime = json['CancellationPolicyTime'],
        coachEmail = json['CoachEmail'] ?? '',
        coachMobileNumber = json['CoachMobileNumber'] ?? '',
        addressType = json['AddressType'] ?? '',
        referralCouponText = json['ReferralCouponText'] ?? '';

  Map<String, dynamic> toJson() => {
        'CoachBookingId': coachBookingId,
        'BookingNo': bookingNo,
        'TransactionDate': transactionDate,
        'TotalAmt': totalAmt,
        'SubActivityId': subActivityId,
        'SubActivityName': subActivityName,
        'ActivityName': activityName,
        'EndUserFirstName': endUserFirstName,
        'EndUserLastName': endUserLastName,
        'setupName': setupName,
        'CoachTrainingAddress': coachTrainingAddress?.map((e) => e.toJson()).toList(),
        'CoachTrainingAddress': coachTrainingAddress?.map((e) => e.toJson()).toList(),
        'AvarageRating': avarageRating,
        'CoachBookingSlotDates': coachBookingSlotDates?.map((e) => e.toJson()).toList(),
        'CoachBookingReviews': coachBookingReviews,
        'PaymentTransaction': paymentTransaction!.map((v) => v.toJson()).toList(),
        'CoachBookingSlotDates': coachBookingSlotDates?.map((e) => e.toJson()).toList(),
        'CoachBookingReviews': coachBookingReviews,
        'CancellationPolicyTime': cancellationPolicyTime,
        'AddressType': addressType,
        'ReferralCouponText': referralCouponText
      };
}

class CoachBookingReviewsModel {
  final int? reviewId;
  final int? coachBookingId;
  final double? rating;
  final String? comment;

  CoachBookingReviewsModel({this.reviewId, this.coachBookingId, this.rating, this.comment});

  CoachBookingReviewsModel.fromJson(Map<String, dynamic> json)
      : reviewId = json['ReviewId'] as int?,
        coachBookingId = json['CoachBookingId'] as int?,
        rating = json['Rating'] ?? 0.0,
        comment = json['Comment'] as String?;

  Map<String, dynamic> toJson() => {'ReviewId': reviewId, 'CoachBookingId': coachBookingId, 'Rating': rating, 'Comment': comment};
}

class EndUserTrainingAddress {
  final String? address1;
  final String? address2;
  final String? addressName;
  final String? pincode;
  final String? cityName;
  final String? stateName;
  final String? countryName;

  EndUserTrainingAddress({this.address1, this.address2, this.addressName, this.pincode, this.cityName, this.stateName, this.countryName});

  EndUserTrainingAddress.fromJson(Map<String, dynamic> json)
      : address1 = json['Address1'] as String?,
        address2 = json['Address2'] as String?,
        addressName = json['AddressName'] as String?,
        pincode = json['PinCode'] as String?,
        cityName = json['CityName'] as String?,
        stateName = json['StateName'] as String?,
        countryName = json['CountryName'] as String?;
}

class CoachTrainingAddress {
  final int? coachTrainingAddressId;
  final int? coachId;
  final dynamic subActivityId;
  final String? addressName;
  final String? address1;
  final String? address2;
  final int? cityId;
  final String? pinCode;
  final bool? isActive;
  final int? createdBy;
  final String? createdAt;
  final dynamic coach;
  final dynamic subActivity;
  final City? city;

  CoachTrainingAddress({
    this.coachTrainingAddressId,
    this.coachId,
    this.subActivityId,
    this.addressName,
    this.address1,
    this.address2,
    this.cityId,
    this.pinCode,
    this.isActive,
    this.createdBy,
    this.createdAt,
    this.coach,
    this.subActivity,
    this.city,
  });

  CoachTrainingAddress.fromJson(Map<String, dynamic> json)
      : coachTrainingAddressId = json['CoachTrainingAddressId'] as int?,
        coachId = json['CoachId'] as int?,
        subActivityId = json['SubActivityId'],
        addressName = json['AddressName'] as String?,
        address1 = json['Address1'] as String?,
        address2 = json['Address2'] as String?,
        cityId = json['CityId'] as int?,
        pinCode = json['PinCode'] as String?,
        isActive = json['IsActive'] as bool?,
        createdBy = json['CreatedBy'] as int?,
        createdAt = json['CreatedAt'] as String?,
        coach = json['Coach'],
        subActivity = json['SubActivity'],
        city = (json['City'] as Map<String, dynamic>?) != null ? City.fromJson(json['City'] as Map<String, dynamic>) : null;

  Map<String, dynamic> toJson() => {
        'CoachTrainingAddressId': coachTrainingAddressId,
        'CoachId': coachId,
        'SubActivityId': subActivityId,
        'AddressName': addressName,
        'Address1': address1,
        'Address2': address2,
        'CityId': cityId,
        'PinCode': pinCode,
        'IsActive': isActive,
        'CreatedBy': createdBy,
        'CreatedAt': createdAt,
        'Coach': coach,
        'SubActivity': subActivity,
        'City': city?.toJson()
      };
}

class City {
  final int? cityId;
  final String? name;
  final int? stateId;
  final bool? isActive;
  final int? createdBy;
  final String? createdAt;
  final dynamic updatedBy;
  final dynamic updatedAt;
  final State? state;
  final List<dynamic>? endUserTrainingAddresses;

  City({
    this.cityId,
    this.name,
    this.stateId,
    this.isActive,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.state,
    this.endUserTrainingAddresses,
  });

  City.fromJson(Map<String, dynamic> json)
      : cityId = json['CityId'] as int?,
        name = json['Name'] as String?,
        stateId = json['StateId'] as int?,
        isActive = json['IsActive'] as bool?,
        createdBy = json['CreatedBy'] as int?,
        createdAt = json['CreatedAt'] as String?,
        updatedBy = json['UpdatedBy'],
        updatedAt = json['UpdatedAt'],
        state = (json['State'] as Map<String, dynamic>?) != null ? State.fromJson(json['State'] as Map<String, dynamic>) : null,
        endUserTrainingAddresses = json['EndUserTrainingAddresses'] as List?;

  Map<String, dynamic> toJson() => {
        'CityId': cityId,
        'Name': name,
        'StateId': stateId,
        'IsActive': isActive,
        'CreatedBy': createdBy,
        'CreatedAt': createdAt,
        'UpdatedBy': updatedBy,
        'UpdatedAt': updatedAt,
        'State': state?.toJson(),
        'EndUserTrainingAddresses': endUserTrainingAddresses
      };
}

class State {
  final int? stateId;
  final String? name;
  final int? countryId;
  final bool? isActive;
  final int? createdBy;
  final String? createdAt;
  final dynamic updatedBy;
  final dynamic updatedAt;
  final dynamic gSTStateCode;
  final Country? country;
  final List<dynamic>? cities;

  State({
    this.stateId,
    this.name,
    this.countryId,
    this.isActive,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.gSTStateCode,
    this.country,
    this.cities,
  });

  State.fromJson(Map<String, dynamic> json)
      : stateId = json['StateId'] as int?,
        name = json['Name'] as String?,
        countryId = json['CountryId'] as int?,
        isActive = json['IsActive'] as bool?,
        createdBy = json['CreatedBy'] as int?,
        createdAt = json['CreatedAt'] as String?,
        updatedBy = json['UpdatedBy'],
        updatedAt = json['UpdatedAt'],
        gSTStateCode = json['GSTStateCode'],
        country = (json['Country'] as Map<String, dynamic>?) != null ? Country.fromJson(json['Country'] as Map<String, dynamic>) : null,
        cities = json['Cities'] as List?;

  Map<String, dynamic> toJson() => {
        'StateId': stateId,
        'Name': name,
        'CountryId': countryId,
        'IsActive': isActive,
        'CreatedBy': createdBy,
        'CreatedAt': createdAt,
        'UpdatedBy': updatedBy,
        'UpdatedAt': updatedAt,
        'GSTStateCode': gSTStateCode,
        'Country': country?.toJson(),
        'Cities': cities
      };
}

class Country {
  final int? countryId;
  final String? name;
  final String? code;
  final int? isActive;
  final int? createdBy;
  final String? createdAt;
  final int? updatedBy;
  final String? updatedAt;
  final int? mobileNoLength;
  final List<dynamic>? states;

  Country({
    this.countryId,
    this.name,
    this.code,
    this.isActive,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.mobileNoLength,
    this.states,
  });

  Country.fromJson(Map<String, dynamic> json)
      : countryId = json['CountryId'] as int?,
        name = json['Name'] as String?,
        code = json['Code'] as String?,
        isActive = json['IsActive'] as int?,
        createdBy = json['CreatedBy'] as int?,
        createdAt = json['CreatedAt'] as String?,
        updatedBy = json['UpdatedBy'] as int?,
        updatedAt = json['UpdatedAt'] as String?,
        mobileNoLength = json['MobileNoLength'] as int?,
        states = json['States'] as List?;

  Map<String, dynamic> toJson() => {
        'CountryId': countryId,
        'Name': name,
        'Code': code,
        'IsActive': isActive,
        'CreatedBy': createdBy,
        'CreatedAt': createdAt,
        'UpdatedBy': updatedBy,
        'UpdatedAt': updatedAt,
        'MobileNoLength': mobileNoLength,
        'States': states
      };
}

class CoachBookingSlotDates {
  final String? bookingDate;
  final double? ratePerHour;
  final int? slotTimeMinute;
  final int? coachBatchSetupDaySlotMapId;
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

  CoachBookingSlotDates(
      {this.bookingDate,
      this.ratePerHour,
      this.slotTimeMinute,
      this.coachBatchSetupDaySlotMapId,
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

  CoachBookingSlotDates.fromJson(Map<String, dynamic> json)
      : bookingDate = json['BookingDate'] as String?,
        ratePerHour = json['RatePerHour'] as double?,
        slotTimeMinute = json['SlotTimeMinute'] as int?,
        coachBatchSetupDaySlotMapId = json['CoachBatchSetupDaySlotMapId'] as int?,
        startTimeInMinute = json['StartTimeInMinute'] as int?,
        endTimeInMinute = json['EndTimeInMinute'] as int?,
        startTime = json['StartTime'] as String?,
        endTime = json['EndTime'] as String?,
        isCancelled = json['IsCancelled'] as bool?,
        isSlotCancelled = json['IsCancelled'] as bool?,
        amount = json['Amount'] as double?,
        totalAmount = json['TotalAmount'] as double?,
        discountAmount = json['DiscountAmount'] ?? 0.0,
        bookingAmount = json['BookingAmount'] ?? 0.0,
        discountPer = json['DiscountPer'] ?? 0.0;

  Map<String, dynamic> toJson() => {
        'BookingDate': bookingDate,
        'RatePerHour': ratePerHour,
        'SlotTimeMinute': slotTimeMinute,
        'CoachBatchSetupDaySlotMapId': coachBatchSetupDaySlotMapId,
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
  int? coachBookingId;
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
    this.coachBookingId,
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
    coachBookingId = json['CoachBookingId'] as int?;
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
    json['CoachBookingId'] = coachBookingId;
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
