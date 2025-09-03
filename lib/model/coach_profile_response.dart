import 'package:oqdo_mobile_app/utils/enums.dart';

class CoachProfileResponseModel {
  int? coachId;
  String? firstName;
  String? lastName;
  int? cityId;
  String? cityName;
  String? pinCode;
  String? emailId;
  String? mobCountryCode;
  String? mobileNumber;
  String? address;
  String? iCNumber;
  String? coachRegistoryNumber;
  int? experienceYear;
  String? otherDescription;
  int? userId;
  String? loginId;
  String? coachTitle;
  String? coachSubTitle;
  int? coachFileStorageId;
  int? profileImageId;
  String? profileImage;
  int? RegServiceProviderId;
  bool? isActive;
  String? coachFileBase64;
  PayoutMethodTypeEnum? payoutMethod;
  String? payNowId;
  String? mobileNum;
  String? beneficiaryName;
  String? bankName;
  String? bankAccountNumber;
  String? ifscSwiftCode;
  List<CoachSubActivityDtos>? coachSubActivityDtos;
  List<CoachCertificationDtos>? coachCertificationDtos;
  List<dynamic>? coachPrvReviewDtos;
  List<CoachTrainingAddressDtos>? coachTrainingAddressDtos;
  CoachCancelPolicyDto? coachCancelPolicyDto;
  String? userName;
  String? accountClosureStatus;
  String? UENRegistrationNo;
  String? referrerCode;

  CoachProfileResponseModel(
      {this.coachId,
      this.firstName,
      this.lastName,
      this.cityId,
      this.cityName,
      this.pinCode,
      this.emailId,
      this.mobCountryCode,
      this.mobileNumber,
      this.address,
      this.iCNumber,
      this.coachRegistoryNumber,
      this.experienceYear,
      this.otherDescription,
      this.userId,
      this.loginId,
      this.coachTitle,
      this.coachSubTitle,
      this.coachFileStorageId,
      this.profileImageId,
      this.profileImage,
      this.isActive,
      this.coachFileBase64,
      this.payoutMethod,
      this.payNowId,
      this.mobileNum,
      this.beneficiaryName,
      this.bankName,
      this.bankAccountNumber,
      this.ifscSwiftCode,
      this.coachSubActivityDtos,
      this.coachCertificationDtos,
      this.coachPrvReviewDtos,
      this.coachTrainingAddressDtos,
      this.coachCancelPolicyDto,
      this.RegServiceProviderId,
      this.userName,
      this.accountClosureStatus,
      this.UENRegistrationNo,
      this.referrerCode});

  CoachProfileResponseModel.fromJson(Map<String, dynamic> json) {
    coachId = json['CoachId'];
    firstName = json['FirstName'];
    lastName = json['LastName'];
    cityId = json['CityId'];
    cityName = json['CityName'];
    pinCode = json['PinCode'];
    emailId = json['EmailId'];
    mobCountryCode = json['MobCountryCode'];
    mobileNumber = json['MobileNumber'];
    address = json['Address'];
    iCNumber = json['ICNumber'];
    coachRegistoryNumber = json['CoachRegistoryNumber'];
    experienceYear = json['ExperienceYear'];
    otherDescription = json['OtherDescription'];
    userId = json['UserId'];
    loginId = json['LoginId'];
    coachTitle = json['CoachTitle'];
    coachSubTitle = json['CoachSubTitle'];
    coachFileStorageId = json['CoachFileStorageId'] ?? 0;
    profileImageId = json['ProfileImageId'];
    profileImage = json['ProfileImage'];
    isActive = json['IsActive'];
    userName = json['UserName'];
    RegServiceProviderId = json['RegServiceProviderId'];
    coachFileBase64 = json['CoachFileBase64'];
    payoutMethod = PayoutMethodTypeEnum.getEnumFromString(json['PayoutMethod'] ?? "");
    payNowId = json['PayNowId'];
    mobileNum = json['MobileNum'];
    beneficiaryName = json['BeneficiaryName'];
    bankName = json['BankName'];
    bankAccountNumber = json['BankAccountNumber'];
    ifscSwiftCode = json['IFSCSwiftCode'];
    if (json['CoachSubActivityDtos'] != null) {
      coachSubActivityDtos = <CoachSubActivityDtos>[];
      json['CoachSubActivityDtos'].forEach((v) {
        coachSubActivityDtos!.add(CoachSubActivityDtos.fromJson(v));
      });
    }
    if (json['CoachCertificationDtos'] != null) {
      coachCertificationDtos = <CoachCertificationDtos>[];
      json['CoachCertificationDtos'].forEach((v) {
        coachCertificationDtos!.add(CoachCertificationDtos.fromJson(v));
      });
    }
    // if (json['CoachPrvReviewDtos'] != null) {
    //   coachPrvReviewDtos = <Null>[];
    //   json['CoachPrvReviewDtos'].forEach((v) {
    //     coachPrvReviewDtos!.add(new Null.fromJson(v));
    //   });
    // }
    if (json['CoachTrainingAddressDtos'] != null) {
      coachTrainingAddressDtos = <CoachTrainingAddressDtos>[];
      json['CoachTrainingAddressDtos'].forEach((v) {
        coachTrainingAddressDtos!.add(CoachTrainingAddressDtos.fromJson(v));
      });
    }

    coachCancelPolicyDto = CoachCancelPolicyDto.fromJson(json['CoachCancelPolicyDto']);
    accountClosureStatus = json['AccountClosureStatus'];
    UENRegistrationNo = json['UENRegistrationNo'] ?? '';
    referrerCode = json['ReferralCode'] ?? '';
    // json['CoachCancelPolicyDto'].forEach((v) {

    // });
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data['CoachId'] = coachId;
    data['FirstName'] = firstName;
    data['LastName'] = lastName;
    data['CityId'] = cityId;
    data['CityName'] = cityName;
    data['PinCode'] = pinCode;
    data['EmailId'] = emailId;
    data['MobCountryCode'] = mobCountryCode;
    data['MobileNumber'] = mobileNumber;
    data['Address'] = address;
    data['ICNumber'] = iCNumber;
    data['CoachRegistoryNumber'] = coachRegistoryNumber;
    data['ExperienceYear'] = experienceYear;
    data['OtherDescription'] = otherDescription;
    data['UserId'] = userId;
    data['LoginId'] = loginId;
    data['CoachTitle'] = coachTitle;
    data['CoachSubTitle'] = coachSubTitle;
    data['CoachFileStorageId'] = coachFileStorageId;
    data['ProfileImageId'] = profileImageId;
    data['ProfileImage'] = profileImage;
    data['IsActive'] = isActive;
    data['RegServiceProviderId'] = RegServiceProviderId;
    data['CoachFileBase64'] = coachFileBase64;
    data['PayoutMethod'] = payoutMethod?.value;
    data['PayNowId'] = payNowId;
    data['MobileNum'] = mobileNum;
    data['BeneficiaryName'] = beneficiaryName;
    data['BankName'] = bankName;
    data['BankAccountNumber'] = bankAccountNumber;
    data['IFSCSwiftCode'] = ifscSwiftCode;
    data['UserName'] = userName;
    if (coachSubActivityDtos != null) {
      data['CoachSubActivityDtos'] = coachSubActivityDtos!.map((v) => v.toJson()).toList();
    }
    if (coachCertificationDtos != null) {
      data['CoachCertificationDtos'] = coachCertificationDtos!.map((v) => v.toJson()).toList();
    }
    if (coachPrvReviewDtos != null) {
      data['CoachPrvReviewDtos'] = coachPrvReviewDtos!.map((v) => v.toJson()).toList();
    }
    if (coachTrainingAddressDtos != null) {
      data['CoachTrainingAddressDtos'] = coachTrainingAddressDtos!.map((v) => v.toJson()).toList();
    }

    data['CoachCancelPolicyDto'] = coachCancelPolicyDto;
    data['AccountClosureStatus'] = accountClosureStatus;

    return data;
  }
}

class CoachCancelPolicyDto {
  int? coachCancelPolicyId;
  int? coachId;
  String? effectiveDate;
  int? cancelMinute;

  CoachCancelPolicyDto({
    this.coachCancelPolicyId,
    this.coachId,
    this.effectiveDate,
    this.cancelMinute,
  });

  CoachCancelPolicyDto.fromJson(Map<String, dynamic> json) {
    coachCancelPolicyId = json['CoachCancelPolicyId'] as int?;
    coachId = json['CoachId'] as int?;
    effectiveDate = json['EffectiveDate'] as String?;
    cancelMinute = json['CancelMinute'] as int?;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = <String, dynamic>{};
    json['CoachCancelPolicyId'] = coachCancelPolicyId;
    json['CoachId'] = coachId;
    json['EffectiveDate'] = effectiveDate;
    json['CancelMinute'] = cancelMinute;
    return json;
  }
}

class CoachSubActivityDtos {
  int? coachSubActivityId;
  int? coachId;
  int? subActivityId;
  String? subActivityName;
  int? activityId;
  String? activityName;
  bool? isActive;

  CoachSubActivityDtos({this.coachSubActivityId, this.coachId, this.subActivityId, this.subActivityName, this.activityId, this.activityName, this.isActive});

  CoachSubActivityDtos.fromJson(Map<String, dynamic> json) {
    coachSubActivityId = json['CoachSubActivityId'];
    coachId = json['CoachId'];
    subActivityId = json['SubActivityId'];
    subActivityName = json['SubActivityName'];
    activityId = json['ActivityId'];
    activityName = json['ActivityName'];
    isActive = json['IsActive'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data['CoachSubActivityId'] = coachSubActivityId;
    data['CoachId'] = coachId;
    data['SubActivityId'] = subActivityId;
    data['SubActivityName'] = subActivityName;
    data['ActivityId'] = activityId;
    data['ActivityName'] = activityName;
    data['IsActive'] = isActive;
    return data;
  }
}

class CoachTrainingAddressDtos {
  int? coachTrainingAddressId;
  int? coachId;

  // Null? subActivityId;
  // Null? subActivityName;
  // Null? activityId;
  // Null? activityName;
  String? addressName;
  String? address1;
  String? address2;
  int? cityId;
  String? cityName;
  String? pinCode;
  bool? isActive;

  CoachTrainingAddressDtos(
      {this.coachTrainingAddressId,
      this.coachId,
      // this.subActivityId,
      // this.subActivityName,
      // this.activityId,
      // this.activityName,
      this.addressName,
      this.address1,
      this.address2,
      this.cityId,
      this.cityName,
      this.pinCode,
      this.isActive});

  CoachTrainingAddressDtos.fromJson(Map<String, dynamic> json) {
    coachTrainingAddressId = json['CoachTrainingAddressId'];
    coachId = json['CoachId'];
    // subActivityId = json['SubActivityId'];
    // subActivityName = json['SubActivityName'];
    // activityId = json['ActivityId'];
    // activityName = json['ActivityName'];
    addressName = json['AddressName'];
    address1 = json['Address1'];
    address2 = json['Address2'];
    cityId = json['CityId'];
    cityName = json['CityName'];
    pinCode = json['PinCode'];
    isActive = json['IsActive'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data['CoachTrainingAddressId'] = coachTrainingAddressId;
    data['CoachId'] = coachId;
    // data['SubActivityId'] = this.subActivityId;
    // data['SubActivityName'] = this.subActivityName;
    // data['ActivityId'] = this.activityId;
    // data['ActivityName'] = this.activityName;
    data['AddressName'] = addressName;
    data['Address1'] = address1;
    data['Address2'] = address2;
    data['CityId'] = cityId;
    data['CityName'] = cityName;
    data['PinCode'] = pinCode;
    data['IsActive'] = isActive;
    return data;
  }
}

class CoachCertificationDtos {
  int? coachCertificationId;
  int? coachId;
  int? coachCertificationFileStorageId;
  String? coachCertificationFileBase64;
  String? fileName;
  bool? isActive;

  CoachCertificationDtos({
    this.coachCertificationId,
    this.coachId,
    this.coachCertificationFileStorageId,
    this.coachCertificationFileBase64,
    this.fileName,
    this.isActive,
  });

  CoachCertificationDtos.fromJson(Map<String, dynamic> json) {
    coachCertificationId = json['CoachCertificationId'] as int?;
    coachId = json['CoachId'] as int?;
    coachCertificationFileStorageId = json['CoachCertificationFileStorageId'] as int?;
    coachCertificationFileBase64 = json['CoachCertificationFileBase64'] as String?;
    fileName = json['FileName'] as String?;
    isActive = json['IsActive'] as bool?;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = <String, dynamic>{};
    json['CoachCertificationId'] = coachCertificationId;
    json['CoachId'] = coachId;
    json['CoachCertificationFileStorageId'] = coachCertificationFileStorageId;
    json['CoachCertificationFileBase64'] = coachCertificationFileBase64;
    json['FileName'] = fileName;
    json['IsActive'] = isActive;
    return json;
  }
}
