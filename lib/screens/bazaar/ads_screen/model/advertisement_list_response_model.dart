class AdvertisementListResponseModel {
  final List<Advertisement> data;
  final int totalCount;
  final int pageStart;
  final int resultPerPage;

  AdvertisementListResponseModel({
    required this.data,
    required this.totalCount,
    required this.pageStart,
    required this.resultPerPage,
  });

  factory AdvertisementListResponseModel.fromJson(Map<String, dynamic> json) {
    return AdvertisementListResponseModel(
      data: (json['Data'] as List).map((item) => Advertisement.fromJson(item)).toList(),
      totalCount: json['TotalCount'],
      pageStart: json['PageStart'],
      resultPerPage: json['ResultPerPage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Data': data.map((item) => item.toJson()).toList(),
      'TotalCount': totalCount,
      'PageStart': pageStart,
      'ResultPerPage': resultPerPage,
    };
  }
}

class Advertisement {
  final int advertisementId;
  final String displayAdvertisementNo;
  final String webUrl;
  final String filePath;

  Advertisement({
    required this.advertisementId,
    required this.displayAdvertisementNo,
    required this.webUrl,
    required this.filePath,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      advertisementId: json['AdvertisementId'],
      displayAdvertisementNo: json['DisplayAdvertisementNo'],
      webUrl: json['WebUrl'],
      filePath: json['FilePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AdvertisementId': advertisementId,
      'DisplayAdvertisementNo': displayAdvertisementNo,
      'WebUrl': webUrl,
      'FilePath': filePath,
    };
  }
}
