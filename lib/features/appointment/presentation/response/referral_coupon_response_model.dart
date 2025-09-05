import 'package:intl/intl.dart';

class ReferralCouponResponseModel {
  final List<ReferralActivityData> data;
  final int totalCount;
  final int pageStart;
  final int resultPerPage;

  ReferralCouponResponseModel({
    required this.data,
    required this.totalCount,
    required this.pageStart,
    required this.resultPerPage,
  });

  factory ReferralCouponResponseModel.fromJson(Map<String, dynamic> json) {
    return ReferralCouponResponseModel(
      data: (json['Data'] as List).map((item) => ReferralActivityData.fromJson(item)).toList(),
      totalCount: json['TotalCount'] as int,
      pageStart: json['PageStart'] as int,
      resultPerPage: json['ResultPerPage'] as int,
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

class ReferralActivityData {
  final int endUserReferralActivityId;
  final DateTime registerDate;
  final DateTime expiredAt;
  final double referralPercentage;
  final String referralCouponText;
  final bool isActive;
  final DateTime createdAt;

  ReferralActivityData({
    required this.endUserReferralActivityId,
    required this.registerDate,
    required this.expiredAt,
    required this.referralPercentage,
    required this.referralCouponText,
    required this.isActive,
    required this.createdAt,
  });

  factory ReferralActivityData.fromJson(Map<String, dynamic> json) {
    return ReferralActivityData(
      endUserReferralActivityId: json['EndUserReferralActivityId'] as int,
      registerDate: DateTime.parse(json['RegisterDate'] as String),
      expiredAt: DateTime.parse(json['ExpiredAt'] as String),
      referralPercentage: (json['ReferralPercentage'] as num).toDouble(),
      referralCouponText: json['ReferralCouponText'] as String,
      isActive: json['IsActive'] as bool,
      createdAt: DateTime.parse(json['CreatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'EndUserReferralActivityId': endUserReferralActivityId,
      'RegisterDate': registerDate.toIso8601String(),
      'ExpiredAt': expiredAt.toIso8601String(),
      'ReferralPercentage': referralPercentage,
      'ReferralCouponText': referralCouponText,
      'IsActive': isActive,
      'CreatedAt': createdAt.toIso8601String(),
    };
  }

  String get formattedExpiredDate => DateFormat('dd MMM yyyy').format(expiredAt);

  String get formattedExpiredDateDashed => DateFormat('dd-MM-yyyy').format(expiredAt);

  String get formattedExpiredDateSlashed => DateFormat('dd/MM/yyyy').format(expiredAt);

  String get formattedExpiredDateLong => DateFormat('MMMM dd, yyyy').format(expiredAt);

  String get formattedExpiredDateTime => DateFormat('dd MMM yyyy hh:mm a').format(expiredAt);

  String formatExpiredDate(String pattern) => DateFormat(pattern).format(expiredAt);
}
