import 'package:collection/collection.dart';

import 'datum.dart';

class GetCoachBatchModel {
  List<Datum>? data;
  int? totalCount;
  int? pageStart;
  int? resultPerPage;

  GetCoachBatchModel({
    this.data,
    this.totalCount,
    this.pageStart,
    this.resultPerPage,
  });

  factory GetCoachBatchModel.fromMap(Map<String, dynamic> json) {
    return GetCoachBatchModel(
      data: (json['Data'] as List<dynamic>?)?.map((e) => Datum.fromMap(e as Map<String, dynamic>)).toList(),
      totalCount: json['TotalCount'] as int?,
      pageStart: json['PageStart'] as int?,
      resultPerPage: json['ResultPerPage'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Data': data?.map((e) => e.tpJson()).toList(),
      'TotalCount': totalCount,
      'PageStart': pageStart,
      'ResultPerPage': resultPerPage,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! GetCoachBatchModel) return false;
    var mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toJson(), toJson());
  }

  @override
  int get hashCode => data.hashCode ^ totalCount.hashCode ^ pageStart.hashCode ^ resultPerPage.hashCode;
}
