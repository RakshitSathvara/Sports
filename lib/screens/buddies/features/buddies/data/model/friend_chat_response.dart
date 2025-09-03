class FriendChatResponse {
  List<FriendMessage>? data;
  int? totalCount;
  int? pageStart;
  int? resultPerPage;

  FriendChatResponse({this.data, this.totalCount, this.pageStart, this.resultPerPage});

  FriendChatResponse.fromJson(Map<String, dynamic> json) {
    if (json['Data'] != null) {
      data = <FriendMessage>[];
      json['Data'].forEach((v) {
        data!.add(FriendMessage.fromJson(v));
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

class FriendMessage {
  int? friendChatId;
  int? fromEndUserId;
  String? firstName;
  String? lastName;
  int? toEndUserId;
  String? sentAt;
  String? message;
  String? seenAt;
  bool? isActive;
  bool? isSentFromMe;
  bool? isBold = false;

  FriendMessage({
    this.friendChatId,
    this.fromEndUserId,
    this.firstName,
    this.lastName,
    this.toEndUserId,
    this.sentAt,
    this.message,
    this.seenAt,
    this.isActive,
    this.isSentFromMe,
  });

  FriendMessage.fromJson(Map<String, dynamic> json) {
    friendChatId = json['FriendChatId'];
    fromEndUserId = json['FromEndUserId'];
    firstName = json['FirstName'];
    lastName = json['LastName'];
    toEndUserId = json['ToEndUserId'];
    sentAt = json['SentAt'];
    message = json['Message'];
    seenAt = json['SeenAt'];
    isActive = json['IsActive'];
    isSentFromMe = json['IsSentFromMe'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data['FriendChatId'] = friendChatId;
    data['FromEndUserId'] = fromEndUserId;
    data['FirstName'] = firstName;
    data['LastName'] = lastName;
    data['ToEndUserId'] = toEndUserId;
    data['SentAt'] = sentAt;
    data['Message'] = message;
    data['SeenAt'] = seenAt;
    data['IsActive'] = isActive;
    data['IsSentFromMe'] = isSentFromMe;
    return data;
  }
}
