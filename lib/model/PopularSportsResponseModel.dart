class PopularSportsResponseModel {
  String? activityName;
  int? countSetups;
  int? subActivityId;
  String? subActivityName;
  String? thumbnailUrl;

  PopularSportsResponseModel({this.activityName, this.countSetups, this.subActivityId, this.subActivityName, this.thumbnailUrl});

  PopularSportsResponseModel.fromJson(Map<String, dynamic> json) {
    activityName = json['ActivityName'];
    countSetups = json['CountSetups'];
    subActivityId = json['SubActivityId'];
    subActivityName = json['SubActivityName'];
    thumbnailUrl = json['ThumbnailUrl'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['ActivityName'] = this.activityName;
    data['CountSetups'] = this.countSetups;
    data['SubActivityId'] = this.subActivityId;
    data['SubActivityName'] = this.subActivityName;
    data['ThumbnailUrl'] = this.thumbnailUrl;
    return data;
  }
}
