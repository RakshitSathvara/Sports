class GetAllBuddiesResponseModel {
  final List<AllBuddiesModel>? data;
  final int? totalCount;
  final int? pageStart;
  final int? resultPerPage;

  GetAllBuddiesResponseModel({
    this.data,
    this.totalCount,
    this.pageStart,
    this.resultPerPage,
  });

  GetAllBuddiesResponseModel.fromJson(Map<String, dynamic> json)
      : data = (json['Data'] as List?)?.map((dynamic e) => AllBuddiesModel.fromJson(e as Map<String, dynamic>)).toList(),
        totalCount = json['TotalCount'] as int?,
        pageStart = json['PageStart'] as int?,
        resultPerPage = json['ResultPerPage'] as int?;

  Map<String, dynamic> toJson() => {'Data': data?.map((e) => e.toJson()).toList(), 'TotalCount': totalCount, 'PageStart': pageStart, 'ResultPerPage': resultPerPage};
}

class AllBuddiesModel {
  int? againsEndUserId;
  int? fromEndUserId;
  int? toEndUserId;
  int? endUserId;
  final int? toFriendId;
  int? groupFriendId;
  String? firstName;
  String? lastName;
  String? profileImage;
  final bool? isActive;
  final String? aboutYourSelf;
  final bool? isProfilePrivate;
  final List<EndUserSubActivities>? endUserSubActivities;
  final List<dynamic>? fromFriends;
  final List<ToFriends>? toFriends;
  String? status;
  int? friendId;
  bool isSelected = false;
  bool? isRemove = true;
  bool? isAdmin = false;

  AllBuddiesModel({
    this.fromEndUserId,
    this.toEndUserId,
    this.endUserId,
    this.toFriendId,
    this.firstName,
    this.lastName,
    this.profileImage = '',
    this.isActive,
    this.aboutYourSelf,
    this.isProfilePrivate,
    this.endUserSubActivities,
    this.fromFriends,
    this.toFriends,
    this.status,
    this.friendId,
  });

  AllBuddiesModel.fromJson(Map<String, dynamic> json)
      : fromEndUserId = json['FromEndUserId'] as int?,
        toEndUserId = json['ToEndUserId'] as int?,
        endUserId = json['EndUserId'] as int?,
        toFriendId = json['ToFriendId'] as int?,
        firstName = json['FirstName'] as String?,
        lastName = json['LastName'] as String?,
        profileImage = json['ProfileImage'] as String?,
        isActive = json['IsActive'] as bool?,
        aboutYourSelf = json['AboutYourSelf'] as String?,
        isProfilePrivate = json['IsProfilePrivate'] as bool?,
        endUserSubActivities = (json['EndUserSubActivities'] as List?)?.map((dynamic e) => EndUserSubActivities.fromJson(e as Map<String, dynamic>)).toList(),
        fromFriends = json['FromFriends'] as List?,
        toFriends = (json['ToFriends'] as List?)?.map((dynamic e) => ToFriends.fromJson(e as Map<String, dynamic>)).toList(),
        status = json['Status'] as String?,
        friendId = json['FriendId'] as int?;

  Map<String, dynamic> toJson() => {
        'FromEndUserId': fromEndUserId,
        'ToEndUserId': toEndUserId,
        'EndUserId': endUserId,
        'ToFriendId': toFriendId,
        'FirstName': firstName,
        'LastName': lastName,
        'ProfileImage': profileImage,
        'IsActive': isActive,
        'AboutYourSelf': aboutYourSelf,
        'IsProfilePrivate': isProfilePrivate,
        'EndUserSubActivities': endUserSubActivities?.map((e) => e.toJson()).toList(),
        'FromFriends': fromFriends,
        'ToFriends': toFriends?.map((e) => e.toJson()).toList(),
        'Status': status,
        'FriendId': friendId,
        'IsRemove': isRemove,
      };
}

class EndUserSubActivities {
  final int? endUserSubActivityId;
  final int? endUserId;
  final int? activitiesId;
  final String? activitiesName;
  final String? subActivitiesName;
  final int? subActivitiesId;

  EndUserSubActivities({
    this.endUserSubActivityId,
    this.endUserId,
    this.activitiesId,
    this.activitiesName,
    this.subActivitiesName,
    this.subActivitiesId,
  });

  EndUserSubActivities.fromJson(Map<String, dynamic> json)
      : endUserSubActivityId = json['EndUserSubActivityId'] as int?,
        endUserId = json['EndUserId'] as int?,
        activitiesId = json['ActivitiesId'] as int?,
        activitiesName = json['ActivitiesName'] as String?,
        subActivitiesName = json['SubActivitiesName'] as String?,
        subActivitiesId = json['SubActivitiesId'] as int?;

  Map<String, dynamic> toJson() => {
        'EndUserSubActivityId': endUserSubActivityId,
        'EndUserId': endUserId,
        'ActivitiesId': activitiesId,
        'ActivitiesName': activitiesName,
        'SubActivitiesName': subActivitiesName,
        'SubActivitiesId': subActivitiesId
      };
}

class ToFriends {
  final int? friendId;
  final String? status;

  ToFriends({
    this.friendId,
    this.status,
  });

  ToFriends.fromJson(Map<String, dynamic> json)
      : friendId = json['FriendId'] as int?,
        status = json['Status'] as String?;

  Map<String, dynamic> toJson() => {'FriendId': friendId, 'Status': status};
}
