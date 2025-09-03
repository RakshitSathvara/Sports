class SubActivityAndActivityResponseModel {
  List<Activity> data;
  int totalCount;
  int pageStart;
  int resultPerPage;

  SubActivityAndActivityResponseModel({
    required this.data,
    required this.totalCount,
    required this.pageStart,
    required this.resultPerPage,
  });

  factory SubActivityAndActivityResponseModel.fromJson(Map<String, dynamic> json) {
    return SubActivityAndActivityResponseModel(
      data: List<Activity>.from(json['Data'].map((x) => Activity.fromJson(x))),
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

class Activity {
  int activityId;
  String name;
  bool isActive;
  List<SubActivity> subActivities;
  bool isExpanded = false;
  String filePath;

  Activity({
    required this.activityId,
    required this.name,
    required this.isActive,
    required this.subActivities,
    required this.filePath,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      activityId: json['ActivityId'],
      name: json['Name'],
      isActive: json['IsActive'],
      subActivities: List<SubActivity>.from(
        json['SubActivities'].map((x) => SubActivity.fromJson(x)),
      ),
      filePath: json['FilePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ActivityId': activityId,
      'Name': name,
      'IsActive': isActive,
      'SubActivities': subActivities.map((x) => x.toJson()).toList(),
      'FilePath': filePath,
    };
  }
}

class SubActivity {
  int subActivityId;
  String name;
  int activityId;

  SubActivity({
    required this.subActivityId,
    required this.name,
    required this.activityId,
  });

  factory SubActivity.fromJson(Map<String, dynamic> json) {
    return SubActivity(
      subActivityId: json['SubActivityId'],
      name: json['Name'],
      activityId: json['ActivityId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'SubActivityId': subActivityId,
      'Name': name,
      'ActivityId': activityId,
    };
  }
}
