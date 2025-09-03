class CreateGroupResponse {
  int? groupId;
  String? name;

  CreateGroupResponse({this.groupId, this.name});

  CreateGroupResponse.fromJson(Map<String, dynamic> json) {
    groupId = json['GroupId'];
    name = json['Name'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['GroupId'] = this.groupId;
    data['Name'] = this.name;
    return data;
  }
}
