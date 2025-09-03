class EndUserProfileResponseModel {
  EndUserProfileResponseModel(
      {this.endUserId,
      this.regServiceProviderId,
      this.firstName,
      this.lastName,
      this.regEmail,
      this.cityName,
      this.countryName,
      this.pinCode,
      this.mobileNumber,
      this.status,
      this.userId,
      this.icNo,
      this.aboutYourSelf,
      this.profileImageId,
      this.isProfilePrivate,
      this.profileImage,
      this.isActive,
      this.endUserSubActivityDto,
      this.userName,
      this.accountClosureStatus,
      this.referralCode});

  EndUserProfileResponseModel.fromJson(dynamic json) {
    endUserId = json['EndUserId'];
    regServiceProviderId = json['RegServiceProviderId'];
    firstName = json['FirstName'];
    lastName = json['LastName'];
    regEmail = json['RegEmail'];
    cityName = json['CityName'];
    countryName = json['CountryName'];
    pinCode = json['PinCode'] ?? '';
    mobileNumber = json['MobileNumber'];
    status = json['Status'];
    userId = json['UserId'];
    icNo = json['IcNo'];
    aboutYourSelf = json['AboutYourSelf'];
    profileImageId = json['ProfileImageId'];
    isProfilePrivate = json['IsProfilePrivate'];
    profileImage = json['ProfileImage'];
    isActive = json['IsActive'];
    if (json['EndUserSubActivityDto'] != null) {
      endUserSubActivityDto = [];
      json['EndUserSubActivityDto'].forEach((v) {
        endUserSubActivityDto?.add(EndUserSubActivityDto.fromJson(v));
      });
    }
    userName = json['UserName'];
    accountClosureStatus = json['AccountClosureStatus'];
    referralCode = json['ReferralCode'];
  }

  int? endUserId;
  int? regServiceProviderId;
  String? firstName;
  String? lastName;
  String? regEmail;
  String? cityName;
  String? countryName;
  String? pinCode;
  String? mobileNumber;
  String? status;
  int? userId;
  String? icNo;
  String? aboutYourSelf;
  int? profileImageId;
  bool? isProfilePrivate;
  String? profileImage;
  bool? isActive;
  List<EndUserSubActivityDto>? endUserSubActivityDto;
  String? userName;
  String? accountClosureStatus;
  String? referralCode;

  EndUserProfileResponseModel copyWith(
          {int? endUserId,
          int? regServiceProviderId,
          String? firstName,
          String? lastName,
          String? regEmail,
          String? cityName,
          String? countryName,
          dynamic pinCode,
          String? mobileNumber,
          String? status,
          int? userId,
          String? icNo,
          String? aboutYourSelf,
          int? profileImageId,
          bool? isProfilePrivate,
          String? profileImage,
          bool? isActive,
          List<EndUserSubActivityDto>? endUserSubActivityDto,
          String? userName,
          String? accountClosureStatus,
          String? referralCode}) =>
      EndUserProfileResponseModel(
          endUserId: endUserId ?? this.endUserId,
          regServiceProviderId: regServiceProviderId ?? this.regServiceProviderId,
          firstName: firstName ?? this.firstName,
          lastName: lastName ?? this.lastName,
          regEmail: regEmail ?? this.regEmail,
          cityName: cityName ?? this.cityName,
          countryName: cityName ?? this.countryName,
          pinCode: pinCode ?? this.pinCode,
          mobileNumber: mobileNumber ?? this.mobileNumber,
          status: status ?? this.status,
          userId: userId ?? this.userId,
          icNo: icNo ?? this.icNo,
          aboutYourSelf: aboutYourSelf ?? this.aboutYourSelf,
          profileImageId: profileImageId ?? this.profileImageId,
          isProfilePrivate: isProfilePrivate ?? this.isProfilePrivate,
          profileImage: profileImage ?? this.profileImage,
          isActive: isActive ?? this.isActive,
          endUserSubActivityDto: endUserSubActivityDto ?? this.endUserSubActivityDto,
          userName: this.userName,
          accountClosureStatus: this.accountClosureStatus,
          referralCode: this.referralCode);

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['EndUserId'] = endUserId;
    map['RegServiceProviderId'] = regServiceProviderId;
    map['FirstName'] = firstName;
    map['LastName'] = lastName;
    map['RegEmail'] = regEmail;
    map['CityName'] = cityName;
    map['CountryName'] = countryName;
    map['PinCode'] = pinCode;
    map['MobileNumber'] = mobileNumber;
    map['Status'] = status;
    map['UserId'] = userId;
    map['IcNo'] = icNo;
    map['AboutYourSelf'] = aboutYourSelf;
    map['ProfileImageId'] = profileImageId;
    map['IsProfilePrivate'] = isProfilePrivate;
    map['ProfileImage'] = profileImage;
    map['IsActive'] = isActive;
    if (endUserSubActivityDto != null) {
      map['EndUserSubActivityDto'] = endUserSubActivityDto?.map((v) => v.toJson()).toList();
    }
    map['UserName'] = userName;
    map['AccountClosureStatus'] = accountClosureStatus;
    map['ReferralCode'] = referralCode;
    return map;
  }
}

/// EndUserSubActivityId : 2
/// EndUserId : 2
/// SubActivityId : 2
/// SubActivityName : "Football"
/// ActivityId : 3
/// ActivityName : "Sports"

class EndUserSubActivityDto {
  EndUserSubActivityDto({
    this.endUserSubActivityId,
    this.endUserId,
    this.subActivityId,
    this.subActivityName,
    this.activityId,
    this.activityName,
  });

  EndUserSubActivityDto.fromJson(dynamic json) {
    endUserSubActivityId = json['EndUserSubActivityId'];
    endUserId = json['EndUserId'];
    subActivityId = json['SubActivityId'];
    subActivityName = json['SubActivityName'];
    activityId = json['ActivityId'];
    activityName = json['ActivityName'];
  }

  int? endUserSubActivityId;
  int? endUserId;
  int? subActivityId;
  String? subActivityName;
  int? activityId;
  String? activityName;

  EndUserSubActivityDto copyWith({
    int? endUserSubActivityId,
    int? endUserId,
    int? subActivityId,
    String? subActivityName,
    int? activityId,
    String? activityName,
  }) =>
      EndUserSubActivityDto(
        endUserSubActivityId: endUserSubActivityId ?? this.endUserSubActivityId,
        endUserId: endUserId ?? this.endUserId,
        subActivityId: subActivityId ?? this.subActivityId,
        subActivityName: subActivityName ?? this.subActivityName,
        activityId: activityId ?? this.activityId,
        activityName: activityName ?? this.activityName,
      );

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['EndUserSubActivityId'] = endUserSubActivityId;
    map['EndUserId'] = endUserId;
    map['SubActivityId'] = subActivityId;
    map['SubActivityName'] = subActivityName;
    map['ActivityId'] = activityId;
    map['ActivityName'] = activityName;
    return map;
  }
}
