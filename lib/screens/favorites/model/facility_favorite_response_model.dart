// Model for the root response
class FacilityFavoriteResponseModel {
  final List<FacilityData> data;
  final int totalCount;
  final int pageStart;
  final int resultPerPage;

  const FacilityFavoriteResponseModel({
    required this.data,
    required this.totalCount,
    required this.pageStart,
    required this.resultPerPage,
  });

  factory FacilityFavoriteResponseModel.fromJson(Map<String, dynamic> json) => FacilityFavoriteResponseModel(
        data: List<FacilityData>.from(
          (json['Data'] as List<dynamic>).map(
            (x) => FacilityData.fromJson(x as Map<String, dynamic>),
          ),
        ),
        totalCount: json['TotalCount'] as int? ?? 0,
        pageStart: json['PageStart'] as int? ?? 0,
        resultPerPage: json['ResultPerPage'] as int? ?? 10,
      );

  Map<String, dynamic> toJson() => {
        'Data': data.map((x) => x.toJson()).toList(),
        'TotalCount': totalCount,
        'PageStart': pageStart,
        'ResultPerPage': resultPerPage,
      };

  @override
  String toString() {
    return 'FacilityResponse(data: $data, totalCount: $totalCount, pageStart: $pageStart, resultPerPage: $resultPerPage)';
  }

  FacilityFavoriteResponseModel copyWith({
    List<FacilityData>? data,
    int? totalCount,
    int? pageStart,
    int? resultPerPage,
  }) {
    return FacilityFavoriteResponseModel(
      data: data ?? this.data,
      totalCount: totalCount ?? this.totalCount,
      pageStart: pageStart ?? this.pageStart,
      resultPerPage: resultPerPage ?? this.resultPerPage,
    );
  }
}

// Model for individual facility data
class FacilityData {
  final int facilitySetupId;
  final String facilityName;
  final String title;
  final String subTitle;
  final String bookingType;
  final double minimumHrRate;
  final List<dynamic> facilitySetupPrvReview;
  final String listingPageImage;
  final String description;
  final double avrageRating;
  final dynamic facilitySetupDays;
  bool isFavorite = true;

  FacilityData({
    required this.facilitySetupId,
    required this.facilityName,
    required this.title,
    required this.subTitle,
    required this.bookingType,
    required this.minimumHrRate,
    this.facilitySetupPrvReview = const [],
    required this.listingPageImage,
    required this.description,
    this.avrageRating = 0.0,
    this.facilitySetupDays,
    this.isFavorite = true,
  });

  factory FacilityData.fromJson(Map<String, dynamic> json) => FacilityData(
        facilitySetupId: json['FacilitySetupId'] as int? ?? 0,
        facilityName: json['FacilityName'] as String? ?? '',
        title: json['Title'] as String? ?? '',
        subTitle: json['SubTitle'] as String? ?? '',
        bookingType: json['BookingType'] as String? ?? '',
        minimumHrRate: (json['MinimumHrRate'] as num?)?.toDouble() ?? 0.0,
        facilitySetupPrvReview: List<dynamic>.from(json['FacilitySetupPrvReview'] ?? []),
        listingPageImage: json['ListingPageImage'] as String? ?? '',
        description: json['Description'] as String? ?? '',
        avrageRating: (json['AvrageRating'] as num?)?.toDouble() ?? 0.0,
        facilitySetupDays: json['FacilitySetupDays'],
        isFavorite: true,
      );

  Map<String, dynamic> toJson() => {
        'FacilitySetupId': facilitySetupId,
        'FacilityName': facilityName,
        'Title': title,
        'SubTitle': subTitle,
        'BookingType': bookingType,
        'MinimumHrRate': minimumHrRate,
        'FacilitySetupPrvReview': facilitySetupPrvReview,
        'ListingPageImage': listingPageImage,
        'Description': description,
        'AvrageRating': avrageRating,
        'FacilitySetupDays': facilitySetupDays,
      };

  @override
  String toString() {
    return 'FacilityData(facilitySetupId: $facilitySetupId, facilityName: $facilityName, title: $title)';
  }

  FacilityData copyWith({
    int? facilitySetupId,
    String? facilityName,
    String? title,
    String? subTitle,
    String? bookingType,
    double? minimumHrRate,
    List<dynamic>? facilitySetupPrvReview,
    String? listingPageImage,
    String? description,
    double? avrageRating,
    dynamic facilitySetupDays,
  }) {
    return FacilityData(
      facilitySetupId: facilitySetupId ?? this.facilitySetupId,
      facilityName: facilityName ?? this.facilityName,
      title: title ?? this.title,
      subTitle: subTitle ?? this.subTitle,
      bookingType: bookingType ?? this.bookingType,
      minimumHrRate: minimumHrRate ?? this.minimumHrRate,
      facilitySetupPrvReview: facilitySetupPrvReview ?? this.facilitySetupPrvReview,
      listingPageImage: listingPageImage ?? this.listingPageImage,
      description: description ?? this.description,
      avrageRating: avrageRating ?? this.avrageRating,
      facilitySetupDays: facilitySetupDays ?? this.facilitySetupDays,
      isFavorite: true,
    );
  }
}
