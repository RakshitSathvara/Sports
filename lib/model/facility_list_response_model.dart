class FacilityListResponseModel {
  List<Data>? data;
  int? pageStart;
  int? resultPerPage;
  int? totalCount;

  FacilityListResponseModel({this.data, this.pageStart, this.resultPerPage, this.totalCount});

  factory FacilityListResponseModel.fromJson(Map<String, dynamic> json) {
    return FacilityListResponseModel(
      data: json['Data'] != null ? (json['Data'] as List).map((i) => Data.fromJson(i)).toList() : null,
      pageStart: json['PageStart'],
      resultPerPage: json['ResultPerPage'],
      totalCount: json['TotalCount'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['PageStart'] = this.pageStart;
    data['ResultPerPage'] = this.resultPerPage;
    data['TotalCount'] = this.totalCount;
    if (this.data != null) {
      data['Data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? activityId;
  String? activityName;
  double? avrageRating;
  String? description;
  String? facilityName;
  int? facilityProviderId;
  Object? facilitySetupDetails;
  int? facilitySetupId;
  List<FacilitySetupPrvReview>? facilitySetupPrvReview;
  String? listingPageImage;
  int? listingPageImageId;
  double? minimumHrRate;
  String? subActivityName;
  String? subTitle;
  int? subactivityId;
  String? title;
  bool? isFacilitySelected = false;

  Data(
      {this.activityId,
      this.activityName,
      this.avrageRating,
      this.description,
      this.facilityName,
      this.facilityProviderId,
      this.facilitySetupDetails,
      this.facilitySetupId,
      this.facilitySetupPrvReview,
      this.listingPageImage,
      this.listingPageImageId,
      this.minimumHrRate,
      this.subActivityName,
      this.subTitle,
      this.subactivityId,
      this.title,
      this.isFacilitySelected});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      activityId: json['ActivityId'],
      activityName: json['ActivityName'],
      avrageRating: json['AvrageRating'],
      description: json['Description'],
      facilityName: json['FacilityName'],
      facilityProviderId: json['FacilityProviderId'],
      facilitySetupDetails: null,
      facilitySetupId: json['FacilitySetupId'],
      facilitySetupPrvReview:
          json['FacilitySetupPrvReview'] != null ? (json['FacilitySetupPrvReview'] as List).map((i) => FacilitySetupPrvReview.fromJson(i)).toList() : null,
      listingPageImage: json['ListingPageImage'],
      listingPageImageId: json['ListingPageImageId'],
      minimumHrRate: json['MinimumHrRate'],
      subActivityName: json['SubActivityName'],
      subTitle: json['SubTitle'],
      subactivityId: json['SubactivityId'],
      title: json['Title'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['ActivityId'] = this.activityId;
    data['ActivityName'] = this.activityName;
    data['AvrageRating'] = this.avrageRating;
    data['Description'] = this.description;
    data['FacilityName'] = this.facilityName;
    data['FacilityProviderId'] = this.facilityProviderId;
    data['FacilitySetupId'] = this.facilitySetupId;
    data['ListingPageImage'] = this.listingPageImage;
    data['ListingPageImageId'] = this.listingPageImageId;
    data['MinimumHrRate'] = this.minimumHrRate;
    data['SubActivityName'] = this.subActivityName;
    data['SubTitle'] = this.subTitle;
    data['SubactivityId'] = this.subactivityId;
    data['Title'] = this.title;
    if (this.facilitySetupDetails != null) {
      data['facilitySetupDetails'] = null;
    }
    if (this.facilitySetupPrvReview != null) {
      data['FacilitySetupPrvReview'] = this.facilitySetupPrvReview!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FacilitySetupPrvReview {
  Object? facilitySetup;
  int? facilitySetupId;
  int? facilitySetupPrvReviewId;
  bool? isActive;
  String? reviewerComment;
  String? reviewerName;
  int? reviewerRating;

  FacilitySetupPrvReview(
      {this.facilitySetup, this.facilitySetupId, this.facilitySetupPrvReviewId, this.isActive, this.reviewerComment, this.reviewerName, this.reviewerRating});

  factory FacilitySetupPrvReview.fromJson(Map<String, dynamic> json) {
    return FacilitySetupPrvReview(
      facilitySetup: null,
      facilitySetupId: json['FacilitySetupId'],
      facilitySetupPrvReviewId: json['FacilitySetupPrvReviewId'],
      isActive: json['IsActive'],
      reviewerComment: json['ReviewerComment'],
      reviewerName: json['ReviewerName'],
      reviewerRating: json['ReviewerRating'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['FacilitySetupId'] = this.facilitySetupId;
    data['FacilitySetupPrvReviewId'] = this.facilitySetupPrvReviewId;
    data['IsActive'] = this.isActive;
    data['ReviewerComment'] = this.reviewerComment;
    data['ReviewerName'] = this.reviewerName;
    data['ReviewerRating'] = this.reviewerRating;
    if (this.facilitySetup != null) {
      data['facilitySetup'] = null;
    }
    return data;
  }
}
