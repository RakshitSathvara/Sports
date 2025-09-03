class GetCoachBySetupIdModel {
  GetCoachBySetupIdModel(
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
      this.averageReview,
      this.isActive,
      this.slots,
      this.reviews,
      this.isSameSlotRate,
      this.coachBatchSetupAddressDtos,
      this.minimumSlot});

  GetCoachBySetupIdModel.fromJson(dynamic json) {
    coachBatchSetupId = json['CoachBatchSetupId'];
    coachId = json['CoachId'];
    activityId = json['ActivityId'];
    subActivityId = json['SubActivityId'];
    activities = json['Activities'] != null ? Activities.fromJson(json['Activities']) : null;
    subActivities = json['SubActivities'] != null ? SubActivities.fromJson(json['SubActivities']) : null;
    coachName = json['CoachName'];
    coachRegistoryNumber = json['CoachRegistoryNumber'];
    experienceYear = json['ExperienceYear'];
    otherDescription = json['OtherDescription'];
    coachBatchSetupDetailId = json['CoachBatchSetupDetailId'];
    effectiveDate = json['EffectiveDate'];
    bookingType = json['BookingType'];
    name = json['Name'];
    slotTimeMinute = json['SlotTimeMinute'];
    slotTimeHour = json['SlotTimeHour'];
    ratePerHour = json['RatePerHour'];
    maxGroupSize = json['MaxGroupSize'];
    batchCapacity = json['BatchCapacity'];
    isTraineeAddress = json['IsTraineeAddress'];
    isTrainingAddress = json['IsTrainingAddress'];
    averageReview = json['AverageReview'];
    isActive = json['IsActive'];
    minimumSlot = json['MinimumSlot'];
    if (json['Slots'] != null) {
      slots = [];
      json['Slots'].forEach((v) {
        slots?.add(Slots.fromJson(v));
      });
    }
    reviews = json['Reviews'] != null ? json['Reviews'].cast<int>() : [];
    isSameSlotRate = json['IsSameSlotRate'] ?? false;
    if (json['coachBatchSetupAddressDtos'] != null) {
      coachBatchSetupAddressDtos = [];
      json['coachBatchSetupAddressDtos'].forEach((v) {
        coachBatchSetupAddressDtos?.add(AddressId.fromJson(v));
      });
    }
  }

  int? coachBatchSetupId;
  int? coachId;
  int? activityId;
  int? subActivityId;
  Activities? activities;
  SubActivities? subActivities;
  String? coachName;
  dynamic coachRegistoryNumber;
  int? experienceYear;
  dynamic otherDescription;
  int? coachBatchSetupDetailId;
  String? effectiveDate;
  String? bookingType;
  String? name;
  int? slotTimeMinute;
  String? slotTimeHour;
  double? ratePerHour;
  int? maxGroupSize;
  int? batchCapacity;
  bool? isTraineeAddress;
  bool? isTrainingAddress;
  double? averageReview;
  bool? isActive;
  List<Slots>? slots;
  List<int>? reviews;
  List<AddressId>? coachBatchSetupAddressDtos;
  bool? isSameSlotRate;
  int? minimumSlot;

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['CoachBatchSetupId'] = coachBatchSetupId;
    map['CoachId'] = coachId;
    map['ActivityId'] = activityId;
    map['SubActivityId'] = subActivityId;
    if (activities != null) {
      map['Activities'] = activities?.toJson();
    }
    if (subActivities != null) {
      map['SubActivities'] = subActivities?.toJson();
    }
    map['CoachName'] = coachName;
    map['CoachRegistoryNumber'] = coachRegistoryNumber;
    map['ExperienceYear'] = experienceYear;
    map['OtherDescription'] = otherDescription;
    map['CoachBatchSetupDetailId'] = coachBatchSetupDetailId;
    map['EffectiveDate'] = effectiveDate;
    map['BookingType'] = bookingType;
    map['Name'] = name;
    map['SlotTimeMinute'] = slotTimeMinute;
    map['SlotTimeHour'] = slotTimeHour;
    map['RatePerHour'] = ratePerHour;
    map['MaxGroupSize'] = maxGroupSize;
    map['BatchCapacity'] = batchCapacity;
    map['IsTraineeAddress'] = isTraineeAddress;
    map['IsTrainingAddress'] = isTrainingAddress;
    map['AverageReview'] = averageReview;
    map['IsActive'] = isActive;
    if (slots != null) {
      map['Slots'] = slots?.map((v) => v.toJson()).toList();
    }
    map['Reviews'] = reviews;
    map['IsSameSlotRate'] = isSameSlotRate;
    map['MinimumSlot'] = minimumSlot;
    return map;
  }
}

class Slots {
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

  Slots.fromJson(dynamic json) {
    dayNos = json['DayNos'] != null ? json['DayNos'].cast<int>() : [];
    noOfSlot = json['NoOfSlot'];
    startTimeInMinute = json['StartTimeInMinute'];
    slotTimeMinute = json['SlotTimeMinute'];
    endTimeInMinute = json['EndTimeInMinute'];
    startTimeFormatted = json['StartTimeFormatted'];
    endTimeFormatted = json['EndTimeFormatted'];
    ratePerHour = json['RatePerHour'];
  }

  List<int>? dayNos;
  int? noOfSlot;
  int? startTimeInMinute;
  int? slotTimeMinute;
  int? endTimeInMinute;
  String? startTimeFormatted;
  String? endTimeFormatted;
  double? ratePerHour;

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['DayNos'] = dayNos;
    map['NoOfSlot'] = noOfSlot;
    map['StartTimeInMinute'] = startTimeInMinute;
    map['SlotTimeMinute'] = slotTimeMinute;
    map['EndTimeInMinute'] = endTimeInMinute;
    map['StartTimeFormatted'] = startTimeFormatted;
    map['EndTimeFormatted'] = endTimeFormatted;
    map['RatePerHour'] = ratePerHour;
    return map;
  }
}

class SubActivities {
  SubActivities({
    this.subActivityId,
    this.activityId,
    this.name,
    this.isActive,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.createdUser,
    this.updatedUser,
    this.activities,
    this.coachBatchSetups,
    this.facilitySetups,
  });

  SubActivities.fromJson(dynamic json) {
    subActivityId = json['SubActivityId'];
    activityId = json['ActivityId'];
    name = json['Name'];
    isActive = json['IsActive'];
    createdBy = json['CreatedBy'];
    createdAt = json['CreatedAt'];
    updatedBy = json['UpdatedBy'];
    updatedAt = json['UpdatedAt'];
    createdUser = json['CreatedUser'];
    updatedUser = json['UpdatedUser'];
    activities = json['Activities'];
    coachBatchSetups = json['CoachBatchSetups'];
    facilitySetups = json['FacilitySetups'];
  }

  int? subActivityId;
  int? activityId;
  String? name;
  bool? isActive;
  int? createdBy;
  String? createdAt;
  dynamic updatedBy;
  dynamic updatedAt;
  dynamic createdUser;
  dynamic updatedUser;
  dynamic activities;
  List<dynamic>? coachBatchSetups;
  List<dynamic>? facilitySetups;

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['SubActivityId'] = subActivityId;
    map['ActivityId'] = activityId;
    map['Name'] = name;
    map['IsActive'] = isActive;
    map['CreatedBy'] = createdBy;
    map['CreatedAt'] = createdAt;
    map['UpdatedBy'] = updatedBy;
    map['UpdatedAt'] = updatedAt;
    map['CreatedUser'] = createdUser;
    map['UpdatedUser'] = updatedUser;
    map['Activities'] = activities;
    if (coachBatchSetups != null) {
      map['CoachBatchSetups'] = coachBatchSetups?.map((v) => v.toJson()).toList();
    }
    if (facilitySetups != null) {
      map['FacilitySetups'] = facilitySetups?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class AddressId {
  int? addressId;

  AddressId({this.addressId});

  AddressId.fromJson(dynamic json) {
    addressId = json['AddressId'];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['AddressId'] = addressId;
    return map;
  }
}

class Activities {
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

  Activities.fromJson(dynamic json) {
    activityId = json['ActivityId'];
    name = json['Name'];
    isActive = json['IsActive'];
    createdBy = json['CreatedBy'];
    createdAt = json['CreatedAt'];
    updatedBy = json['UpdatedBy'];
    updatedAt = json['UpdatedAt'];
    createdUser = json['CreatedUser'];
    updatedUser = json['UpdatedUser'];
    subActivities = json['SubActivities'];
  }

  int? activityId;
  String? name;
  bool? isActive;
  int? createdBy;
  String? createdAt;
  dynamic updatedBy;
  dynamic updatedAt;
  dynamic createdUser;
  dynamic updatedUser;
  List<dynamic>? subActivities;

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['ActivityId'] = activityId;
    map['Name'] = name;
    map['IsActive'] = isActive;
    map['CreatedBy'] = createdBy;
    map['CreatedAt'] = createdAt;
    map['UpdatedBy'] = updatedBy;
    map['UpdatedAt'] = updatedAt;
    map['CreatedUser'] = createdUser;
    map['UpdatedUser'] = updatedUser;
    if (subActivities != null) {
      map['SubActivities'] = subActivities?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
