class GetConversationListResponse {
  List<Conversation>? data;
  int? totalCount;
  int? pageStart;
  int? resultPerPage;

  GetConversationListResponse({this.data, this.totalCount, this.pageStart, this.resultPerPage});

  GetConversationListResponse.fromJson(Map<String, dynamic> json) {
    if (json['Data'] != null) {
      data = <Conversation>[];
      json['Data'].forEach((v) {
        data!.add(Conversation.fromJson(v));
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

class Conversation {
  int? friendId;
  int? fromEndUserId;
  String? firstName;
  String? lastName;
  int? toEndUserId;
  String? status;
  bool? isActive;
  String? profileImage;
  String? groupName;
  int? groupId;
  String? chatType;
  String? lastMessage;
  String? lastMsgSeenAt;
  String? lastMsgSentAt;
  bool? isBold = false;
  bool? isDoubleBack = false;

  Conversation(
      {this.friendId,
      this.fromEndUserId,
      this.firstName,
      this.lastName,
      this.toEndUserId,
      this.status,
      this.isActive,
      this.profileImage,
      this.groupName,
      this.groupId,
      this.chatType,
      this.lastMessage,
      this.lastMsgSeenAt,
      this.lastMsgSentAt});

  Conversation.fromJson(Map<String, dynamic> json) {
    friendId = json['FriendId'];
    fromEndUserId = json['FromEndUserId'];
    firstName = json['FirstName'];
    lastName = json['LastName'];
    toEndUserId = json['ToEndUserId'];
    status = json['Status'];
    isActive = json['IsActive'];
    profileImage = json['ProfileImage'];
    groupName = json['GroupName'];
    groupId = json['GroupId'];
    chatType = json['ChatType'];
    lastMessage = json['LastMessage'];
    lastMsgSeenAt = json['LastMsgSeenAt'];
    lastMsgSentAt = json['LastMsgSentAt'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data['FriendId'] = friendId;
    data['FromEndUserId'] = fromEndUserId;
    data['FirstName'] = firstName;
    data['LastName'] = lastName;
    data['ToEndUserId'] = toEndUserId;
    data['Status'] = status;
    data['IsActive'] = isActive;
    data['ProfileImage'] = profileImage;
    data['GroupName'] = groupName;
    data['GroupId'] = groupId;
    data['ChatType'] = chatType;
    data['LastMessage'] = lastMessage;
    data['LastMsgSeenAt'] = lastMsgSeenAt;
    data['LastMsgSentAt'] = lastMsgSentAt;
    return data;
  }
}
