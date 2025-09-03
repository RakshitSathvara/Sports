class MeetupResponseModel {
  final List<MeetupResponse>? data;
  final int? totalCount;
  final int? pageStart;
  final int? resultPerPage;

  MeetupResponseModel({
    this.data,
    this.totalCount,
    this.pageStart,
    this.resultPerPage,
  });

  MeetupResponseModel.fromJson(Map<String, dynamic> json)
      : data = (json['Data'] as List?)?.map((dynamic e) => MeetupResponse.fromJson(e as Map<String, dynamic>)).toList(),
        totalCount = json['TotalCount'] as int?,
        pageStart = json['PageStart'] as int?,
        resultPerPage = json['ResultPerPage'] as int?;

  Map<String, dynamic> toJson() => {
        'Data': data?.map((e) => e.toJson()).toList(),
        'TotalCount': totalCount,
        'PageStart': pageStart,
        'ResultPerPage': resultPerPage
      };
}

class MeetupResponse {
  final String? date;
  final List<MeetUps>? meetUps;
  String? day = '';

  MeetupResponse({this.date, this.meetUps, this.day});

  MeetupResponse.fromJson(Map<String, dynamic> json)
      : date = json['Date'] as String?,
        meetUps = (json['MeetUps'] as List?)?.map((dynamic e) => MeetUps.fromJson(e as Map<String, dynamic>)).toList();

  Map<String, dynamic> toJson() => {'Date': date, 'MeetUps': meetUps?.map((e) => e.toJson()).toList()};
}

class MeetUps {
  final int? meetUpId;
  final String? name;
  final String? description;
  final String? date;
  final dynamic remarks;
  final int? endUserId;
  final String? firstName;
  final String? lastName;
  final bool? isActive;
  final int? statTimeMinutes;
  final int? endTimeMinutes;
  final String? startFrom;
  final String? endAt;
  final List<MeetUpFriends>? meetUpFriends;
  final int? meetUpFriendId;
  final String? status;
  final bool? isCreator;

  MeetUps({
    this.meetUpId,
    this.name,
    this.description,
    this.date,
    this.remarks,
    this.endUserId,
    this.firstName,
    this.lastName,
    this.isActive,
    this.statTimeMinutes,
    this.endTimeMinutes,
    this.startFrom,
    this.endAt,
    this.meetUpFriends,
    this.meetUpFriendId,
    this.status,
    this.isCreator,
  });

  MeetUps.fromJson(Map<String, dynamic> json)
      : meetUpId = json['MeetUpId'] as int?,
        name = json['Name'] as String?,
        description = json['Description'] as String?,
        date = json['Date'] as String?,
        remarks = json['Remarks'],
        endUserId = json['EndUserId'] as int?,
        firstName = json['FirstName'] as String?,
        lastName = json['LastName'] as String?,
        isActive = json['IsActive'] as bool?,
        statTimeMinutes = json['StatTimeMinutes'] as int?,
        endTimeMinutes = json['EndTimeMinutes'] as int?,
        startFrom = json['StartFrom'] as String?,
        endAt = json['EndAt'] as String?,
        meetUpFriends = (json['MeetUpFriends'] as List?)
            ?.map((dynamic e) => MeetUpFriends.fromJson(e as Map<String, dynamic>))
            .toList(),
        meetUpFriendId = json['MeetUpFriendId'] as int?,
        status = json['Status'] as String?,
        isCreator = json['IsCreator'] as bool?;

  Map<String, dynamic> toJson() => {
        'MeetUpId': meetUpId,
        'Name': name,
        'Description': description,
        'Date': date,
        'Remarks': remarks,
        'EndUserId': endUserId,
        'FirstName': firstName,
        'LastName': lastName,
        'IsActive': isActive,
        'StatTimeMinutes': statTimeMinutes,
        'EndTimeMinutes': endTimeMinutes,
        'StartFrom': startFrom,
        'EndAt': endAt,
        'MeetUpFriends': meetUpFriends?.map((e) => e.toJson()).toList(),
        'MeetUpFriendId': meetUpFriendId,
        'Status': status,
        'IsCreator': isCreator
      };
}

class MeetUpFriends {
  final int? meetUpFriendId;
  final int? meetUpId;
  final int? friendId;
  final String? status;
  final int? fromEndUserId;
  final String? fromEndUserFirstName;
  final String? fromEndUserLastName;
  final int? toEndUserId;
  final String? toEndUserFirstName;
  final String? toEndUserLastName;
  final String? displayFirstName;
  final String? displayLastName;

  MeetUpFriends({
    this.meetUpFriendId,
    this.meetUpId,
    this.friendId,
    this.status,
    this.fromEndUserId,
    this.fromEndUserFirstName,
    this.fromEndUserLastName,
    this.toEndUserId,
    this.toEndUserFirstName,
    this.toEndUserLastName,
    this.displayFirstName,
    this.displayLastName,
  });

  MeetUpFriends.fromJson(Map<String, dynamic> json)
      : meetUpFriendId = json['MeetUpFriendId'] as int?,
        meetUpId = json['MeetUpId'] as int?,
        friendId = json['FriendId'] as int?,
        status = json['Status'] as String?,
        fromEndUserId = json['FromEndUserId'] as int?,
        fromEndUserFirstName = json['FromEndUserFirstName'] as String?,
        fromEndUserLastName = json['FromEndUserLastName'] as String?,
        toEndUserId = json['ToEndUserId'] as int?,
        toEndUserFirstName = json['ToEndUserFirstName'] as String?,
        toEndUserLastName = json['ToEndUserLastName'] as String?,
        displayFirstName = json['DisplayFirstName'] as String?,
        displayLastName = json['DisplayLastName'] as String?;

  Map<String, dynamic> toJson() => {
        'MeetUpFriendId': meetUpFriendId,
        'MeetUpId': meetUpId,
        'FriendId': friendId,
        'Status': status,
        'FromEndUserId': fromEndUserId,
        'FromEndUserFirstName': fromEndUserFirstName,
        'FromEndUserLastName': fromEndUserLastName,
        'ToEndUserId': toEndUserId,
        'ToEndUserFirstName': toEndUserFirstName,
        'ToEndUserLastName': toEndUserLastName,
        'DisplayFirstName': displayFirstName,
        'DisplayLastName': displayLastName
      };
}
