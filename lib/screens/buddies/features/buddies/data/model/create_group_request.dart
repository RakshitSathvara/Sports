class CreateGroupRequest {
  String? name;
  String? endUserId;
  bool? isActive;
  List<GroupFriendDtos>? groupFriendDtos;

  CreateGroupRequest({this.name, this.endUserId, this.isActive, this.groupFriendDtos});

  CreateGroupRequest.fromJson(Map<String, dynamic> json) {
    name = json['Name'];
    endUserId = json['EndUserId'];
    isActive = json['IsActive'];
    if (json['GroupFriendDtos'] != null) {
      groupFriendDtos = <GroupFriendDtos>[];
      json['GroupFriendDtos'].forEach((v) {
        groupFriendDtos!.add(GroupFriendDtos.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data['Name'] = name;
    data['EndUserId'] = endUserId;
    data['IsActive'] = isActive;
    if (groupFriendDtos != null) {
      data['GroupFriendDtos'] = groupFriendDtos!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GroupFriendDtos {
  int? friendId;
  String? status;
  bool? isActive;

  GroupFriendDtos({this.friendId, this.status, this.isActive});

  GroupFriendDtos.fromJson(Map<String, dynamic> json) {
    friendId = json['FriendId'];
    status = json['Status'];
    isActive = json['IsActive'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data['FriendId'] = friendId;
    data['Status'] = status;
    data['IsActive'] = isActive;
    return data;
  }
}
