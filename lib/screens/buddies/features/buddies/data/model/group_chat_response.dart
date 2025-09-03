class GroupChatResponse {
  List<GroupMessage>? data;
  int? totalCount;
  int? pageStart;
  int? resultPerPage;

  GroupChatResponse({this.data, this.totalCount, this.pageStart, this.resultPerPage});

  GroupChatResponse.fromJson(Map<String, dynamic> json) {
    if (json['Data'] != null) {
      data = <GroupMessage>[];
      json['Data'].forEach((v) {
        data!.add(GroupMessage.fromJson(v));
      });
    }
    totalCount = json['TotalCount'];
    pageStart = json['PageStart'];
    resultPerPage = json['ResultPerPage'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['Data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['TotalCount'] = totalCount;
    data['PageStart'] = pageStart;
    data['ResultPerPage'] = resultPerPage;
    return data;
  }
}

class GroupMessage {
  int? groupFriendChatId;
  int? groupId;
  String? groupName;
  int? fromEndUserId;
  String? firstName;
  String? lastName;
  int? groupAdminEndUserId;
  String? message;
  String? seenAt;
  String? sentAt;
  bool? isActive;
  bool? isSentFromMe;

  GroupMessage(
      {this.groupFriendChatId,
      this.groupId,
      this.groupName,
      this.fromEndUserId,
      this.firstName,
      this.lastName,
      this.groupAdminEndUserId,
      this.message,
      this.seenAt,
      this.sentAt,
      this.isActive,
      this.isSentFromMe});

  GroupMessage.fromJson(Map<String, dynamic> json) {
    groupFriendChatId = json['GroupFriendChatId'];
    groupId = json['GroupId'];
    groupName = json['GroupName'];
    fromEndUserId = json['FromEndUserId'];
    firstName = json['FirstName'];
    lastName = json['LastName'];
    groupAdminEndUserId = json['GroupAdminEndUserId'];
    message = json['Message'];
    seenAt = json['SeenAt'];
    sentAt = json['SentAt'];
    isActive = json['IsActive'];
    isSentFromMe = json['IsSentFromMe'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data['GroupFriendChatId'] = groupFriendChatId;
    data['GroupId'] = groupId;
    data['GroupName'] = groupName;
    data['FromEndUserId'] = fromEndUserId;
    data['FirstName'] = firstName;
    data['LastName'] = lastName;
    data['GroupAdminEndUserId'] = groupAdminEndUserId;
    data['Message'] = message;
    data['SeenAt'] = seenAt;
    data['SentAt'] = sentAt;
    data['IsActive'] = isActive;
    data['IsSentFromMe'] = isSentFromMe;
    return data;
  }
}
