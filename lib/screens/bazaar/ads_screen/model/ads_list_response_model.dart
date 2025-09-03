import 'package:flutter/material.dart';

class AdvertisementResponse {
  final List<AdvertisementType> data;
  final int totalCount;
  final int pageStart;
  final int resultPerPage;

  AdvertisementResponse({
    required this.data,
    required this.totalCount,
    required this.pageStart,
    required this.resultPerPage,
  });

  /// A factory constructor that creates an [AdvertisementResponse]
  /// object from a JSON map.
  factory AdvertisementResponse.fromJson(Map<String, dynamic> json) {
    return AdvertisementResponse(
      data: (json['Data'] as List<dynamic>).map((item) => AdvertisementType.fromJson(item as Map<String, dynamic>)).toList(),
      totalCount: json['TotalCount'] as int,
      pageStart: json['PageStart'] as int,
      resultPerPage: json['ResultPerPage'] as int,
    );
  }

  /// Converts the current [AdvertisementResponse] object to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'Data': data.map((e) => e.toJson()).toList(),
      'TotalCount': totalCount,
      'PageStart': pageStart,
      'ResultPerPage': resultPerPage,
    };
  }
}

class AdvertisementType {
  final int advertisementTypeId;
  final String name;
  final String code;
  final bool isActive;
  final VoidCallback? onPressed;

  AdvertisementType({
    required this.advertisementTypeId,
    required this.name,
    required this.code,
    required this.isActive,
    this.onPressed,
  });

  factory AdvertisementType.fromJson(Map<String, dynamic> json) {
    return AdvertisementType(
      advertisementTypeId: json['AdvertisementTypeId'] as int,
      name: json['Name'] as String,
      code: json['Code'] as String,
      isActive: json['IsActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AdvertisementTypeId': advertisementTypeId,
      'Name': name,
      'Code': code,
      'IsActive': isActive,
    };
  }
}
