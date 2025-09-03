class AdsListRequestModel {
  final int advertisementTypeId;
  final List<SubActivityParams> subActivities;
  final int pageStart;
  final int resultPerPage;

  AdsListRequestModel({
    required this.advertisementTypeId,
    required this.subActivities,
    required this.pageStart,
    required this.resultPerPage,
  });

  Map<String, dynamic> toJson() {
    return {
      'AdvertisementTypeId': advertisementTypeId,
      'SubActivities': subActivities.map((activity) => activity.toJson()).toList(),
      'PageStart': pageStart,
      'ResultPerPage': resultPerPage,
    };
  }

  factory AdsListRequestModel.fromJson(Map<String, dynamic> json) {
    return AdsListRequestModel(
      advertisementTypeId: json['AdvertisementTypeId'] as int,
      subActivities: (json['SubActivities'] as List).map((activity) => SubActivityParams.fromJson(activity as Map<String, dynamic>)).toList(),
      pageStart: json['PageStart'] as int,
      resultPerPage: json['ResultPerPage'] as int,
    );
  }
}

class SubActivityParams {
  final int subActivityId;
  final String name;

  SubActivityParams({required this.subActivityId, this.name = ''});

  Map<String, dynamic> toJson() {
    return {
      'SubActivityId': subActivityId,
    };
  }

  factory SubActivityParams.fromJson(Map<String, dynamic> json) {
    return SubActivityParams(
      subActivityId: json['SubActivityId'] as int,
      name: json['Name'] as String,
    );
  }
}
