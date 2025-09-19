class GetAllActivityAndSubActivityResponse {
  List<ActivityBean>? Data;
  int? TotalCount;
  int? PageStart;
  int? ResultPerPage;

  static GetAllActivityAndSubActivityResponse? fromMap(Map<String, dynamic> map) {
    GetAllActivityAndSubActivityResponse getAllActivityAndSubActivityResponseBean = GetAllActivityAndSubActivityResponse();
    getAllActivityAndSubActivityResponseBean.Data = [...(map['Data'] as List).map((o) => ActivityBean.fromMap(o)!)];
    getAllActivityAndSubActivityResponseBean.TotalCount = map['TotalCount'];
    getAllActivityAndSubActivityResponseBean.PageStart = map['PageStart'];
    getAllActivityAndSubActivityResponseBean.ResultPerPage = map['ResultPerPage'];
    return getAllActivityAndSubActivityResponseBean;
  }

  Map toJson() => {
        "Data": Data,
        "TotalCount": TotalCount,
        "PageStart": PageStart,
        "ResultPerPage": ResultPerPage,
      };
}

class ActivityBean {
  int? ActivityId;
  String? Name;
  bool? IsActive;
  bool? isSelected = false;
  String? localIconPath;
  List<SubActivitiesBean>? SubActivities;

  static ActivityBean? fromMap(Map<String, dynamic> map) {
    ActivityBean dataBean = ActivityBean();
    dataBean.ActivityId = map['ActivityId'];
    dataBean.Name = map['Name'];
    dataBean.IsActive = map['IsActive'];
    dataBean.localIconPath = "";
    dataBean.SubActivities = []..addAll((map['SubActivities'] as List).map((o) => SubActivitiesBean.fromMap(o)!));
    return dataBean;
  }

  Map toJson() => {
        "ActivityId": ActivityId,
        "Name": Name,
        "IsActive": IsActive,
        "SubActivities": SubActivities,
      };
}

class SubActivitiesBean {
  int? SubActivityId;
  String? Name;
  int? ActivityId;
  bool? selectedValue = false;
  bool? isSelected = false;
  String? imageUrl;

  static SubActivitiesBean? fromMap(Map<String, dynamic> map) {
    SubActivitiesBean subActivitiesBean = SubActivitiesBean();
    subActivitiesBean.SubActivityId = map['SubActivityId'];
    subActivitiesBean.Name = map['Name'];
    subActivitiesBean.ActivityId = map['ActivityId'];
    subActivitiesBean.imageUrl = map['FilePath'];
    return subActivitiesBean;
  }

  Map toJson() => {
        "SubActivityId": SubActivityId,
        "Name": Name,
        "ActivityId": ActivityId,
      };
}
