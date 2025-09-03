class FriendListResponseModel {
  final List<FrindListResponse>? data;
  final int? totalCount;
  final int? pageStart;
  final int? resultPerPage;

  FriendListResponseModel({
    this.data,
    this.totalCount,
    this.pageStart,
    this.resultPerPage,
  });

  FriendListResponseModel.fromJson(Map<String, dynamic> json)
      : data =
            (json['Data'] as List?)?.map((dynamic e) => FrindListResponse.fromJson(e as Map<String, dynamic>)).toList(),
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

class FrindListResponse {
  final int? friendId;
  final int? fromEndUserId;
  final int? toEndUserId;
  final String? status;
  final String? firstName;
  final String? lastName;
  final int? verifiedBy;
  final String? verifiedAt;
  final bool? isActive;
  final String? toEndUserFirstName;
  final String? toEndUserLastName;
  final String? displayFirstName;
  final String? displayLastName;
  bool? isSelected = false;

  FrindListResponse(
      {this.friendId,
      this.fromEndUserId,
      this.toEndUserId,
      this.status,
      this.firstName,
      this.lastName,
      this.verifiedBy,
      this.verifiedAt,
      this.isActive,
      this.toEndUserFirstName,
      this.toEndUserLastName,
      this.displayFirstName,
      this.displayLastName,
      this.isSelected});

  FrindListResponse.fromJson(Map<String, dynamic> json)
      : friendId = json['FriendId'] as int?,
        fromEndUserId = json['FromEndUserId'] as int?,
        toEndUserId = json['ToEndUserId'] as int?,
        status = json['Status'] as String?,
        firstName = json['FirstName'] as String?,
        lastName = json['LastName'] as String?,
        verifiedBy = json['VerifiedBy'] as int?,
        verifiedAt = json['VerifiedAt'] as String?,
        isActive = json['IsActive'] as bool?,
        toEndUserFirstName = json['ToEndUserFirstName'] as String?,
        toEndUserLastName = json['ToEndUserLastName'] as String?,
        displayFirstName = json['DisplayFirstName'] as String?,
        displayLastName = json['DisplayLastName'] as String?;

  Map<String, dynamic> toJson() => {
        'FriendId': friendId,
        'FromEndUserId': fromEndUserId,
        'ToEndUserId': toEndUserId,
        'Status': status,
        'FirstName': firstName,
        'LastName': lastName,
        'VerifiedBy': verifiedBy,
        'VerifiedAt': verifiedAt,
        'IsActive': isActive,
        'ToEndUserFirstName': toEndUserFirstName,
        'ToEndUserLastName': toEndUserLastName,
        'DisplayFirstName': displayFirstName,
        'DisplayLastName': displayLastName
      };
}
