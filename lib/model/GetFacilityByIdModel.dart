class GetFacilityByIdModel {
  GetFacilityByIdModel({
    this.facilitySetupDetailId,
    this.facilitySetupId,
    this.facilityProviderId,
    this.title,
    this.subTitle,
    this.description,
    this.effectiveDate,
    this.facilitySetupIsActive,
    this.subActivityId,
    this.subActivityName,
    this.activityId,
    this.activityName,
    this.listingPageImageId,
    this.listingPageImage,
    this.facilitySetupImages,
    this.averageReview,
    this.bookingType,
    this.slotTimeMinute,
    this.slotTimeHour,
    this.ratePerHour,
    this.maxGroupSize,
    this.facilityCapacity,
    this.isActive,
    this.slots,
    this.address,
    this.mobileNumber,
    this.isSameSlotRate,
    this.facilityBookingReviewList,
    this.isFavourite,
  });

  GetFacilityByIdModel.fromJson(dynamic json) {
    facilitySetupDetailId = json['FacilitySetupDetailId'];
    facilitySetupId = json['FacilitySetupId'];
    facilityProviderId = json['FacilityProviderId'];
    title = json['Title'];
    subTitle = json['SubTitle'];
    description = json['Description'];
    effectiveDate = json['EffectiveDate'];
    facilitySetupIsActive = json['FacilitySetupIsActive'];
    subActivityId = json['SubActivityId'];
    subActivityName = json['SubActivityName'];
    activityId = json['ActivityId'];
    activityName = json['ActivityName'];
    listingPageImageId = json['ListingPageImageId'];
    listingPageImage = json['ListingPageImage'];
    if (json['FacilitySetupImages'] != null) {
      facilitySetupImages = [];
      json['FacilitySetupImages'].forEach((v) {
        facilitySetupImages?.add(FacilitySetupImages.fromJson(v));
      });
    }
    averageReview = json['AverageReview'];
    bookingType = json['BookingType'];
    slotTimeMinute = json['SlotTimeMinute'];
    slotTimeHour = json['SlotTimeHour'];
    ratePerHour = json['RatePerHour'];
    maxGroupSize = json['MaxGroupSize'];
    facilityCapacity = json['FacilityCapacity'];
    isActive = json['IsActive'];
    if (json['Slots'] != null) {
      slots = [];
      json['Slots'].forEach((v) {
        slots?.add(Slots.fromJson(v));
      });
    }
    address = json['Address'];
    mobileNumber = json['MobileNumber'];
    isSameSlotRate = json['IsSameSlotRate'];
    isFavourite = json['IsFavourite'];

    if (json['FacilityBookingReviews'] != null) {
      facilityBookingReviewList = [];
      json['FacilityBookingReviews'].forEach((v) {
        facilityBookingReviewList?.add(FacilityBookingReviews.fromJson(v));
      });
    }
  }

  int? facilitySetupDetailId;
  int? facilitySetupId;
  int? facilityProviderId;
  String? title;
  String? subTitle;
  String? description;
  String? effectiveDate;
  bool? facilitySetupIsActive;
  int? subActivityId;
  String? subActivityName;
  int? activityId;
  String? activityName;
  int? listingPageImageId;
  String? listingPageImage;
  List<FacilitySetupImages>? facilitySetupImages;
  double? averageReview;
  String? bookingType;
  int? slotTimeMinute;
  String? slotTimeHour;
  double? ratePerHour;
  int? maxGroupSize;
  int? facilityCapacity;
  bool? isActive;
  List<Slots>? slots;
  String? address;
  String? mobileNumber;
  bool? isSameSlotRate;
  List<FacilityBookingReviews>? facilityBookingReviewList;
  bool? isFavourite = false;

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['FacilitySetupDetailId'] = facilitySetupDetailId;
    map['FacilitySetupId'] = facilitySetupId;
    map['FacilityProviderId'] = facilityProviderId;
    map['Title'] = title;
    map['SubTitle'] = subTitle;
    map['Description'] = description;
    map['EffectiveDate'] = effectiveDate;
    map['FacilitySetupIsActive'] = facilitySetupIsActive;
    map['SubActivityId'] = subActivityId;
    map['SubActivityName'] = subActivityName;
    map['ActivityId'] = activityId;
    map['ActivityName'] = activityName;
    map['ListingPageImageId'] = listingPageImageId;
    map['ListingPageImage'] = listingPageImage;
    if (facilitySetupImages != null) {
      map['FacilitySetupImages'] = facilitySetupImages?.map((v) => v.toJson()).toList();
    }
    map['AverageReview'] = averageReview;
    map['BookingType'] = bookingType;
    map['SlotTimeMinute'] = slotTimeMinute;
    map['SlotTimeHour'] = slotTimeHour;
    map['RatePerHour'] = ratePerHour;
    map['RatePerHour'] = ratePerHour;
    map['MaxGroupSize'] = maxGroupSize;
    map['IsActive'] = isActive;
    map['Address'] = address;
    map['MobileNumber'] = mobileNumber;
    map['IsSameSlotRate'] = isSameSlotRate;
    if (slots != null) {
      map['Slots'] = slots?.map((v) => v.toJson()).toList();
    }
    map['IsFavourite'] = isFavourite;
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

class FacilitySetupImages {
  FacilitySetupImages({
    this.setupImageId,
    this.facilitySetupId,
    this.fileStorageId,
    this.fileName,
    this.fileExtension,
    this.filePath,
  });

  FacilitySetupImages.fromJson(dynamic json) {
    setupImageId = json['SetupImageId'];
    facilitySetupId = json['FacilitySetupId'];
    fileStorageId = json['FileStorageId'];
    fileName = json['FileName'];
    fileExtension = json['FileExtension'];
    filePath = json['FilePath'];
  }

  int? setupImageId;
  int? facilitySetupId;
  int? fileStorageId;
  String? fileName;
  String? fileExtension;
  String? filePath;

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['SetupImageId'] = setupImageId;
    map['FacilitySetupId'] = facilitySetupId;
    map['FileStorageId'] = fileStorageId;
    map['FileName'] = fileName;
    map['FileExtension'] = fileExtension;
    map['FilePath'] = filePath;
    return map;
  }
}

class FacilityBookingReviews {
  final int? reviewId;
  final int? facilityBookingId;
  final double? rating;
  final String? comment;
  final String? createdAt;
  final String? createdBy;
  final String? createdUserName;

  FacilityBookingReviews({this.reviewId, this.facilityBookingId, this.rating, this.comment, this.createdAt, this.createdBy, this.createdUserName});

  FacilityBookingReviews.fromJson(Map<String, dynamic> json)
      : reviewId = json['ReviewId'] as int?,
        facilityBookingId = json['FacilityBookingId'] as int?,
        rating = json['Rating'] ?? 0.0,
        comment = json['Comment'] as String?,
        createdAt = json['CreatedAt'] as String?,
        createdBy = json['CreatedBy'] as String?,
        createdUserName = json['CreatedUserName'] as String?;
}
