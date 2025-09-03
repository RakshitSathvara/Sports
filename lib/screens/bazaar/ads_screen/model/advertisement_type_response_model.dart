import 'dart:ui';

class AdvertisementTypeResponseModel {
  List<AdvertisementTypeResponse> data;
  int totalCount;
  int pageStart;
  int resultPerPage;

  AdvertisementTypeResponseModel({
    required this.data,
    required this.totalCount,
    required this.pageStart,
    required this.resultPerPage,
  });

  factory AdvertisementTypeResponseModel.fromJson(Map<String, dynamic> json) {
    return AdvertisementTypeResponseModel(
      data: List<AdvertisementTypeResponse>.from(json['Data'].map((x) => AdvertisementTypeResponse.fromJson(x))),
      totalCount: json['TotalCount'],
      pageStart: json['PageStart'],
      resultPerPage: json['ResultPerPage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Data': data.map((x) => x.toJson()).toList(),
      'TotalCount': totalCount,
      'PageStart': pageStart,
      'ResultPerPage': resultPerPage,
    };
  }
}

class AdvertisementTypeResponse {
  int advertisementTypeId;
  String name;
  String code;
  bool isActive;
  int displayOrder;
  final VoidCallback? onPressed;

  AdvertisementTypeResponse({
    required this.advertisementTypeId,
    required this.name,
    required this.code,
    required this.isActive,
    required this.displayOrder,
    this.onPressed,
  });

  factory AdvertisementTypeResponse.fromJson(Map<String, dynamic> json) {
    return AdvertisementTypeResponse(
      advertisementTypeId: json['AdvertisementTypeId'],
      name: json['Name'],
      code: json['Code'],
      isActive: json['IsActive'],
      displayOrder: json['DisplayOrder'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AdvertisementTypeId': advertisementTypeId,
      'Name': name,
      'Code': code,
      'IsActive': isActive,
      'DisplayOrder': displayOrder,
    };
  }
}
