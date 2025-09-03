class HomeResponseModel {
  final List<Data>? data;
  final int? totalCount;
  final int? pageStart;
  final int? resultPerPage;

  HomeResponseModel({
    this.data,
    this.totalCount,
    this.pageStart,
    this.resultPerPage,
  });

  HomeResponseModel.fromJson(Map<String, dynamic> json)
      : data = (json['Data'] as List?)?.map((dynamic e) => Data.fromJson(e as Map<String, dynamic>)).toList(),
        totalCount = json['TotalCount'] as int?,
        pageStart = json['PageStart'] as int?,
        resultPerPage = json['ResultPerPage'] as int?;

  Map<String, dynamic> toJson() => {
        'Data': data?.map((e) => e.toJson()).toList(),
        'TotalCount': totalCount,
        'PageStart': pageStart,
        'ResultPerPage': resultPerPage
      };
}

class Data {
  final int? activityId;
  final String? name;
  final bool? isActive;
  final List<SubActivities>? subActivities;

  Data({
    this.activityId,
    this.name,
    this.isActive,
    this.subActivities,
  });

  Data.fromJson(Map<String, dynamic> json)
      : activityId = json['ActivityId'] as int?,
        name = json['Name'] as String?,
        isActive = json['IsActive'] as bool?,
        subActivities = (json['SubActivities'] as List?)
            ?.map((dynamic e) => SubActivities.fromJson(e as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() => {
        'ActivityId': activityId,
        'Name': name,
        'IsActive': isActive,
        'SubActivities': subActivities?.map((e) => e.toJson()).toList()
      };
}

class SubActivities {
  final int? coachBatchSetupsCount;
  final int? facilitySetupsCount;
  int? subActivityId;
  String? name;
  final int? activityId;
  final String? filePath;
  final int? thumbnail;
  final String? fileName;

  SubActivities({
    this.coachBatchSetupsCount,
    this.facilitySetupsCount,
    this.subActivityId,
    this.name,
    this.activityId,
    this.filePath,
    this.thumbnail,
    this.fileName,
  });

  SubActivities.fromJson(Map<String, dynamic> json)
      : coachBatchSetupsCount = json['CoachBatchSetupsCount'] as int?,
        facilitySetupsCount = json['FacilitySetupsCount'] as int?,
        subActivityId = json['SubActivityId'] as int?,
        name = json['Name'] as String?,
        activityId = json['ActivityId'] as int?,
        filePath = json['FilePath'] as String?,
        thumbnail = json['Thumbnail'] as int?,
        fileName = json['FileName'] as String?;

  Map<String, dynamic> toJson() => {
        'CoachBatchSetupsCount': coachBatchSetupsCount,
        'FacilitySetupsCount': facilitySetupsCount,
        'SubActivityId': subActivityId,
        'Name': name,
        'ActivityId': activityId,
        'FilePath': filePath,
        'Thumbnail': thumbnail,
        'FileName': fileName
      };
}
