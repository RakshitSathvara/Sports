class CoachDetailsResponseModel {
  final int? coachBatchSetupId;
  final int? coachId;
  final int? activityId;
  final int? subActivityId;
  final Activities? activities;
  final SubActivities? subActivities;
  final String? coachName;
  final String? coachRegistoryNumber;
  final int? experienceYear;
  final dynamic otherDescription;
  final int? coachBatchSetupDetailId;
  final String? effectiveDate;
  final String? bookingType;
  final String? name;
  final int? slotTimeMinute;
  final String? slotTimeHour;
  final double? ratePerHour;
  final int? maxGroupSize;
  final int? batchCapacity;
  final bool? isTraineeAddress;
  final bool? isTrainingAddress;
  final List<CoachBatchSetupAddressDtos>? coachBatchSetupAddressDtos;
  final double? averageReview;
  final bool? isActive;
  final String? addressRequired;
  final List<Slots>? slots;
  final List<int>? reviews;
  final String? profileImagePath;
  String? mobileNumber;
  bool? isSameSlotRate;
  int? minumumSlot;
  final List<CoachBookingReviews>? coachBookingReviews;
  bool? isFavourite = false;

  CoachDetailsResponseModel(
      {this.coachBatchSetupId,
      this.coachId,
      this.activityId,
      this.subActivityId,
      this.activities,
      this.subActivities,
      this.coachName,
      this.coachRegistoryNumber,
      this.experienceYear,
      this.otherDescription,
      this.coachBatchSetupDetailId,
      this.effectiveDate,
      this.bookingType,
      this.name,
      this.slotTimeMinute,
      this.slotTimeHour,
      this.ratePerHour,
      this.maxGroupSize,
      this.batchCapacity,
      this.isTraineeAddress,
      this.isTrainingAddress,
      this.coachBatchSetupAddressDtos,
      this.averageReview,
      this.isActive,
      this.addressRequired,
      this.slots,
      this.reviews,
      this.profileImagePath,
      this.mobileNumber,
      this.isSameSlotRate,
      this.coachBookingReviews,
      this.minumumSlot,
      this.isFavourite});

  CoachDetailsResponseModel.fromJson(Map<String, dynamic> json)
      : coachBatchSetupId = json['CoachBatchSetupId'] as int?,
        coachId = json['CoachId'] as int?,
        activityId = json['ActivityId'] as int?,
        subActivityId = json['SubActivityId'] as int?,
        activities = (json['Activities'] as Map<String, dynamic>?) != null ? Activities.fromJson(json['Activities'] as Map<String, dynamic>) : null,
        subActivities = (json['SubActivities'] as Map<String, dynamic>?) != null ? SubActivities.fromJson(json['SubActivities'] as Map<String, dynamic>) : null,
        coachName = json['CoachName'] as String?,
        coachRegistoryNumber = json['CoachRegistoryNumber'] as String?,
        experienceYear = json['ExperienceYear'] as int?,
        otherDescription = json['OtherDescription'] ?? '',
        coachBatchSetupDetailId = json['CoachBatchSetupDetailId'] as int?,
        effectiveDate = json['EffectiveDate'] as String?,
        bookingType = json['BookingType'] as String?,
        name = json['Name'] as String?,
        slotTimeMinute = json['SlotTimeMinute'] as int?,
        slotTimeHour = json['SlotTimeHour'] as String?,
        ratePerHour = json['RatePerHour'] as double?,
        maxGroupSize = json['MaxGroupSize'] as int?,
        batchCapacity = json['BatchCapacity'] as int?,
        isTraineeAddress = json['IsTraineeAddress'] as bool?,
        isTrainingAddress = json['IsTrainingAddress'] as bool?,
        coachBatchSetupAddressDtos =
            (json['coachBatchSetupAddressDtos'] as List?)?.map((dynamic e) => CoachBatchSetupAddressDtos.fromJson(e as Map<String, dynamic>)).toList(),
        averageReview = json['AverageReview'] as double?,
        isActive = json['IsActive'] as bool?,
        addressRequired = json['AddressRequired'] as String?,
        slots = (json['Slots'] as List?)?.map((dynamic e) => Slots.fromJson(e as Map<String, dynamic>)).toList(),
        reviews = (json['Reviews'] as List?)?.map((dynamic e) => e as int).toList(),
        profileImagePath = json['ProfileImagePath'] as String?,
        mobileNumber = json['MobileNumber'] ?? '',
        isSameSlotRate = json['IsSameSlotRate'],
        minumumSlot = json['MinimumSlot'] ?? 0,
        coachBookingReviews = (json['CoachBookingReviews'] as List?)?.map((dynamic e) => CoachBookingReviews.fromJson(e as Map<String, dynamic>)).toList(),
        isFavourite = json['IsFavourite'] as bool?;

  Map<String, dynamic> toJson() => {
        'CoachBatchSetupId': coachBatchSetupId,
        'CoachId': coachId,
        'ActivityId': activityId,
        'SubActivityId': subActivityId,
        'Activities': activities?.toJson(),
        'SubActivities': subActivities?.toJson(),
        'CoachName': coachName,
        'CoachRegistoryNumber': coachRegistoryNumber,
        'ExperienceYear': experienceYear,
        'OtherDescription': otherDescription,
        'CoachBatchSetupDetailId': coachBatchSetupDetailId,
        'EffectiveDate': effectiveDate,
        'BookingType': bookingType,
        'Name': name,
        'SlotTimeMinute': slotTimeMinute,
        'SlotTimeHour': slotTimeHour,
        'RatePerHour': ratePerHour,
        'MaxGroupSize': maxGroupSize,
        'BatchCapacity': batchCapacity,
        'IsTraineeAddress': isTraineeAddress,
        'IsTrainingAddress': isTrainingAddress,
        'coachBatchSetupAddressDtos': coachBatchSetupAddressDtos?.map((e) => e.toJson()).toList(),
        'AverageReview': averageReview,
        'IsActive': isActive,
        'AddressRequired': addressRequired,
        'Slots': slots?.map((e) => e.toJson()).toList(),
        'Reviews': reviews,
        'ProfileImagePath': profileImagePath,
        'MobileNumber': mobileNumber,
        'IsSameSlotRate': isSameSlotRate,
        'IsFavourite': isFavourite,
      };
}

class Activities {
  final int? activityId;
  final String? name;
  final bool? isActive;
  final int? createdBy;
  final String? createdAt;
  final dynamic updatedBy;
  final dynamic updatedAt;
  final dynamic createdUser;
  final dynamic updatedUser;
  final List<dynamic>? subActivities;

  Activities({
    this.activityId,
    this.name,
    this.isActive,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.createdUser,
    this.updatedUser,
    this.subActivities,
  });

  Activities.fromJson(Map<String, dynamic> json)
      : activityId = json['ActivityId'] as int?,
        name = json['Name'] as String?,
        isActive = json['IsActive'] as bool?,
        createdBy = json['CreatedBy'] as int?,
        createdAt = json['CreatedAt'] as String?,
        updatedBy = json['UpdatedBy'],
        updatedAt = json['UpdatedAt'],
        createdUser = json['CreatedUser'],
        updatedUser = json['UpdatedUser'],
        subActivities = json['SubActivities'] as List?;

  Map<String, dynamic> toJson() => {
        'ActivityId': activityId,
        'Name': name,
        'IsActive': isActive,
        'CreatedBy': createdBy,
        'CreatedAt': createdAt,
        'UpdatedBy': updatedBy,
        'UpdatedAt': updatedAt,
        'CreatedUser': createdUser,
        'UpdatedUser': updatedUser,
        'SubActivities': subActivities
      };
}

class SubActivities {
  final int? subActivityId;
  final int? activityId;
  final String? name;
  final bool? isActive;
  final int? createdBy;
  final String? createdAt;
  final dynamic updatedBy;
  final dynamic updatedAt;
  final int? thumbnail;
  final dynamic createdUser;
  final dynamic updatedUser;
  final dynamic thumbnailFileStorage;
  final dynamic activities;
  final List<dynamic>? coachBatchSetups;
  final List<dynamic>? facilitySetups;
  final List<dynamic>? facilityBookings;
  final List<dynamic>? coachBookings;

  SubActivities({
    this.subActivityId,
    this.activityId,
    this.name,
    this.isActive,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.thumbnail,
    this.createdUser,
    this.updatedUser,
    this.thumbnailFileStorage,
    this.activities,
    this.coachBatchSetups,
    this.facilitySetups,
    this.facilityBookings,
    this.coachBookings,
  });

  SubActivities.fromJson(Map<String, dynamic> json)
      : subActivityId = json['SubActivityId'] as int?,
        activityId = json['ActivityId'] as int?,
        name = json['Name'] as String?,
        isActive = json['IsActive'] as bool?,
        createdBy = json['CreatedBy'] as int?,
        createdAt = json['CreatedAt'] as String?,
        updatedBy = json['UpdatedBy'],
        updatedAt = json['UpdatedAt'],
        thumbnail = json['Thumbnail'] as int?,
        createdUser = json['CreatedUser'],
        updatedUser = json['UpdatedUser'],
        thumbnailFileStorage = json['ThumbnailFileStorage'],
        activities = json['Activities'],
        coachBatchSetups = json['CoachBatchSetups'] as List?,
        facilitySetups = json['FacilitySetups'] as List?,
        facilityBookings = json['FacilityBookings'] as List?,
        coachBookings = json['CoachBookings'] as List?;

  Map<String, dynamic> toJson() => {
        'SubActivityId': subActivityId,
        'ActivityId': activityId,
        'Name': name,
        'IsActive': isActive,
        'CreatedBy': createdBy,
        'CreatedAt': createdAt,
        'UpdatedBy': updatedBy,
        'UpdatedAt': updatedAt,
        'Thumbnail': thumbnail,
        'CreatedUser': createdUser,
        'UpdatedUser': updatedUser,
        'ThumbnailFileStorage': thumbnailFileStorage,
        'Activities': activities,
        'CoachBatchSetups': coachBatchSetups,
        'FacilitySetups': facilitySetups,
        'FacilityBookings': facilityBookings,
        'CoachBookings': coachBookings
      };
}

class CoachBatchSetupAddressDtos {
  final int? addressId;
  final String? address1;
  final String? address2;
  final String? addressName;
  final String? pinCode;

  CoachBatchSetupAddressDtos({
    this.addressId,
    this.address1,
    this.address2,
    this.addressName,
    this.pinCode,
  });

  CoachBatchSetupAddressDtos.fromJson(Map<String, dynamic> json)
      : addressId = json['AddressId'] as int?,
        address1 = json['Address1'] as String?,
        address2 = json['Address2'] as String?,
        addressName = json['AddressName'] as String?,
        pinCode = json['PinCode'] as String?;

  Map<String, dynamic> toJson() => {'AddressId': addressId, 'Address1': address1, 'Address2': address2, 'AddressName': addressName, 'PinCode': pinCode};
}

class Slots {
  final List<int>? dayNos;
  final int? noOfSlot;
  final int? startTimeInMinute;
  final int? slotTimeMinute;
  final int? endTimeInMinute;
  final String? startTimeFormatted;
  final String? endTimeFormatted;
  final double? ratePerHour;

  Slots({
    this.dayNos,
    this.noOfSlot,
    this.startTimeInMinute,
    this.slotTimeMinute,
    this.endTimeInMinute,
    this.startTimeFormatted,
    this.endTimeFormatted,
    this.ratePerHour,
  });

  Slots.fromJson(Map<String, dynamic> json)
      : dayNos = (json['DayNos'] as List?)?.map((dynamic e) => e as int).toList(),
        noOfSlot = json['NoOfSlot'] as int?,
        startTimeInMinute = json['StartTimeInMinute'] as int?,
        slotTimeMinute = json['SlotTimeMinute'] as int?,
        endTimeInMinute = json['EndTimeInMinute'] as int?,
        startTimeFormatted = json['StartTimeFormatted'] as String?,
        endTimeFormatted = json['EndTimeFormatted'] as String?,
        ratePerHour = json['RatePerHour'] as double?;

  Map<String, dynamic> toJson() => {
        'DayNos': dayNos,
        'NoOfSlot': noOfSlot,
        'StartTimeInMinute': startTimeInMinute,
        'SlotTimeMinute': slotTimeMinute,
        'EndTimeInMinute': endTimeInMinute,
        'StartTimeFormatted': startTimeFormatted,
        'EndTimeFormatted': endTimeFormatted,
        'RatePerHour': ratePerHour,
      };
}

class CoachBookingReviews {
  final int? reviewId;
  final int? coachBookingId;
  final double? rating;
  final String? comment;
  final String? createdAt;
  final String? createdBy;
  final String? createdUserName;

  CoachBookingReviews({this.reviewId, this.coachBookingId, this.rating, this.comment, this.createdAt, this.createdBy, this.createdUserName});

  CoachBookingReviews.fromJson(Map<String, dynamic> json)
      : reviewId = json['ReviewId'] as int?,
        coachBookingId = json['CoachBookingId'] as int?,
        rating = json['Rating'] ?? 0.0,
        comment = json['Comment'] as String?,
        createdAt = json['CreatedAt'] as String?,
        createdBy = json['CreatedBy'] as String?,
        createdUserName = json['CreatedUserName'] as String?;
}
