class NotificationResponse {
  List<NotificationItem>? data;
  int? totalCount;
  int? pageStart;
  int? resultPerPage;

  NotificationResponse({this.data, this.totalCount, this.pageStart, this.resultPerPage});

  NotificationResponse.fromJson(Map<String, dynamic> json) {
    if (json['Data'] != null) {
      data = <NotificationItem>[];
      json['Data'].forEach((v) {
        data!.add(NotificationItem.fromJson(v));
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

class NotificationItem {
  int? userId;
  int? notificationHistoryId;
  String? notificationTemplateType;
  String? content;
  String? sentAT;
  String? validTill;
  int? deepLinkType;

  NotificationItem({this.userId, this.notificationHistoryId, this.notificationTemplateType, this.content, this.sentAT, this.validTill, this.deepLinkType});

  NotificationItem.fromJson(Map<String, dynamic> json) {
    userId = json['UserId'];
    notificationHistoryId = json['NotificationHistoryId'];
    notificationTemplateType = json['NotificationTemplateType'];
    content = json['Content'];
    sentAT = json['SentAT'];
    validTill = json['ValidTill'];
    deepLinkType = json['DeepLinkType'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data['UserId'] = userId;
    data['NotificationHistoryId'] = notificationHistoryId;
    data['NotificationTemplateType'] = notificationTemplateType;
    data['Content'] = content;
    data['SentAT'] = sentAT;
    data['ValidTill'] = validTill;
    data['DeepLinkType'] = deepLinkType;
    return data;
  }
}
