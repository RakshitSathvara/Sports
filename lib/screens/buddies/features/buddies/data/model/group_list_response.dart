class GroupListResponse {
  List<AllGroups>? data;
  int? totalCount;
  int? pageStart;
  int? resultPerPage;

  GroupListResponse({this.data, this.totalCount, this.pageStart, this.resultPerPage});

  GroupListResponse.fromJson(Map<String, dynamic> json) {
    if (json['Data'] != null) {
      data = <AllGroups>[];
      json['Data'].forEach((v) {
        data!.add(new AllGroups.fromJson(v));
      });
    }
    totalCount = json['TotalCount'];
    pageStart = json['PageStart'];
    resultPerPage = json['ResultPerPage'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['Data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['TotalCount'] = this.totalCount;
    data['PageStart'] = this.pageStart;
    data['ResultPerPage'] = this.resultPerPage;
    return data;
  }
}

class AllGroups {
  int? groupId;
  String? groupName;
  int? endUserId;
  String? firstName;
  String? lastName;
  bool? isActive;
  List<GroupFriends>? groupFriends;

  AllGroups({this.groupId, this.groupName, this.endUserId, this.firstName, this.lastName, this.isActive, this.groupFriends});

  AllGroups.fromJson(Map<String, dynamic> json) {
    groupId = json['GroupId'];
    groupName = json['GroupName'];
    endUserId = json['EndUserId'];
    firstName = json['FirstName'];
    lastName = json['LastName'];
    isActive = json['IsActive'];
    if (json['GroupFriends'] != null) {
      groupFriends = <GroupFriends>[];
      json['GroupFriends'].forEach((v) {
        groupFriends!.add(new GroupFriends.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['GroupId'] = this.groupId;
    data['GroupName'] = this.groupName;
    data['EndUserId'] = this.endUserId;
    data['FirstName'] = this.firstName;
    data['LastName'] = this.lastName;
    data['IsActive'] = this.isActive;
    if (this.groupFriends != null) {
      data['GroupFriends'] = this.groupFriends!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GroupFriends {
  int? againsEndUserId;
  int? groupFriendId;
  int? groupId;
  int? friendId;
  String? friendStatus;
  int? fromEndUserId;
  int? toEndUserId;
  String? fromEndUserFirstName;
  String? fromEndUserLastName;
  String? toEndUserFirstName;
  String? toEndUserLastName;
  String? displayFirstName;
  String? displayLastName;
  String? status;
  String? profileImage;
  bool? isAdmin;
  bool? isRemove = true;

  GroupFriends(
      {this.againsEndUserId,
      this.groupFriendId,
      this.groupId,
      this.friendId,
      this.friendStatus,
      this.fromEndUserId,
      this.toEndUserId,
      this.fromEndUserFirstName,
      this.fromEndUserLastName,
      this.toEndUserFirstName,
      this.toEndUserLastName,
      this.displayFirstName,
      this.displayLastName,
      this.status,
      this.profileImage,
      this.isAdmin,
      this.isRemove});

  GroupFriends.fromJson(Map<String, dynamic> json) {
    againsEndUserId = json['AgainsEndUserId'];
    groupFriendId = json['GroupFriendId'];
    groupId = json['GroupId'];
    friendId = json['FriendId'];
    friendStatus = json['FriendStatus'];
    fromEndUserId = json['FromEndUserId'];
    toEndUserId = json['ToEndUserId'];
    fromEndUserFirstName = json['FromEndUserFirstName'];
    fromEndUserLastName = json['FromEndUserLastName'];
    toEndUserFirstName = json['ToEndUserFirstName'];
    toEndUserLastName = json['ToEndUserLastName'];
    displayFirstName = json['DisplayFirstName'];
    displayLastName = json['DisplayLastName'];
    status = json['Status'];
    profileImage = json['ProfileImage'];
    isAdmin = json['IsAdmin'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['AgainsEndUserId'] = this.againsEndUserId;
    data['GroupFriendId'] = this.groupFriendId;
    data['GroupId'] = this.groupId;
    data['FriendId'] = this.friendId;
    data['FriendStatus'] = this.friendStatus;
    data['FromEndUserId'] = this.fromEndUserId;
    data['ToEndUserId'] = this.toEndUserId;
    data['FromEndUserFirstName'] = this.fromEndUserFirstName;
    data['FromEndUserLastName'] = this.fromEndUserLastName;
    data['ToEndUserFirstName'] = this.toEndUserFirstName;
    data['ToEndUserLastName'] = this.toEndUserLastName;
    data['DisplayFirstName'] = this.displayFirstName;
    data['DisplayLastName'] = this.displayLastName;
    data['Status'] = this.status;
    data['ProfileImage'] = this.profileImage;
    data['isRemove'] = this.isRemove;
    data['IsAdmin'] = this.isAdmin;
    return data;
  }
}
