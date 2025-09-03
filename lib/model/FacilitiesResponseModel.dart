class FacilitiesResponseModel {
  List<Data>? data;
  int? totalCount;
  int? pageStart;
  int? resultPerPage;

  FacilitiesResponseModel({
    this.data,
    this.totalCount,
    this.pageStart,
    this.resultPerPage,
  });

  FacilitiesResponseModel.fromJson(Map<String, dynamic> json) {
    data = (json['Data'] as List?)?.map((dynamic e) => Data.fromJson(e as Map<String, dynamic>)).toList();
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

class Data {
  String? title;
  String? subTitle;
  dynamic facilitySetupDetails;
  List<dynamic>? facilitySetupPrvReview;
  String? listingPageImage;
  int? listingPageImageId;
  String? activityName;
  String? subActivityName;
  int? subActivityId;
  int? activityId;
  int? facilitySetupId;
  String? description;
  String? facilityName;
  double? minimumHrRate;
  double? avrageRating;
  int? facilityProviderId;
  String? bookingType;
  String? address;
  double? avgProviderRating;
  bool? isFavourite = false;

  Data(
      {this.title,
      this.subTitle,
      this.facilitySetupDetails,
      this.facilitySetupPrvReview,
      this.listingPageImage,
      this.listingPageImageId,
      this.activityName,
      this.subActivityName,
      this.subActivityId,
      this.activityId,
      this.facilitySetupId,
      this.description,
      this.facilityName,
      this.minimumHrRate,
      this.avrageRating,
      this.facilityProviderId,
      this.bookingType,
      this.address,
      this.avgProviderRating,
      this.isFavourite});

  Data.fromJson(Map<String, dynamic> json) {
    title = json['Title'] as String?;
    subTitle = json['SubTitle'] as String?;
    facilitySetupDetails = json['FacilitySetupDetails'] ?? '';
    facilitySetupPrvReview = json['FacilitySetupPrvReview'] as List?;
    listingPageImage = json['ListingPageImage'] as String?;
    listingPageImageId = json['ListingPageImageId'] as int?;
    activityName = json['ActivityName'] as String?;
    subActivityName = json['SubActivityName'] as String?;
    subActivityId = json['SubactivityId'] as int?;
    activityId = json['ActivityId'] as int?;
    facilitySetupId = json['FacilitySetupId'] as int?;
    description = json['Description'] as String?;
    facilityName = json['FacilityName'] as String?;
    minimumHrRate = json['MinimumHrRate'] as double?;
    avrageRating = json['AvrageRating'] as double?;
    facilityProviderId = json['FacilityProviderId'] as int?;
    bookingType = json['BookingType'] as String?;
    address = json['Address'] as String?;
    avgProviderRating = json['AvgProviderRating'] ?? 0.0;
    isFavourite = json['IsFavourite'] ?? false;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = <String, dynamic>{};
    json['Title'] = title;
    json['SubTitle'] = subTitle;
    json['FacilitySetupDetails'] = facilitySetupDetails;
    json['FacilitySetupPrvReview'] = facilitySetupPrvReview;
    json['ListingPageImage'] = listingPageImage;
    json['ListingPageImageId'] = listingPageImageId;
    json['ActivityName'] = activityName;
    json['SubActivityName'] = subActivityName;
    json['SubactivityId'] = subActivityId;
    json['ActivityId'] = activityId;
    json['FacilitySetupId'] = facilitySetupId;
    json['Description'] = description;
    json['FacilityName'] = facilityName;
    json['MinimumHrRate'] = minimumHrRate;
    json['AvrageRating'] = avrageRating;
    json['FacilityProviderId'] = facilityProviderId;
    json['BookingType'] = bookingType;
    json['Address'] = address;
    json['AvgProviderRating'] = avgProviderRating;
    json['IsFavourite'] = isFavourite;
    return json;
  }
}
