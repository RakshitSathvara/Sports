import 'package:oqdo_mobile_app/utils/enums.dart';

class FacilityProfileResponse {
  String? facilityName;
  int? facilityProviderId;
  int? cityId;
  String? cityName;
  String? pinCode;
  String? email;
  String? mobCountryCode;
  String? mobileNumber;
  String? address;
  String? uENRegistrationNo;
  int? establishmentYear;
  String? otherDescription;
  int? regServiceProviderId;
  int? userId;
  int? profileImageId;
  String? profileImage;
  bool? isActive;
  String? regEmail;
  PayoutMethodTypeEnum? payoutMethod;
  String? payNowId;
  String? mobileNum;
  String? beneficiaryName;
  String? bankName;
  String? bankAccountNumber;
  String? ifscSwiftCode;
  List<FacilityProviderContacts>? facilityProviderContacts;
  List<FacilityProviderSubActivities>? facilityProviderSubActivities;
  List<dynamic>? facilityProviderPrvReviews;
  List<FacilityProviderCertifications>? facilityProviderCertifications;
  FacilityProviderCancelPolicy? facilityProviderCancelPolicy;
  String? userName;
  String? accountClosureStatus;
  String? referralCode;

  FacilityProfileResponse(
      {this.facilityName,
      this.facilityProviderId,
      this.cityId,
      this.cityName,
      this.pinCode,
      this.email,
      this.mobCountryCode,
      this.mobileNumber,
      this.address,
      this.uENRegistrationNo,
      this.establishmentYear,
      this.otherDescription,
      this.regServiceProviderId,
      this.userId,
      this.profileImageId,
      this.profileImage,
      this.isActive,
      this.regEmail,
      this.payoutMethod,
      this.payNowId,
      this.mobileNum,
      this.beneficiaryName,
      this.bankName,
      this.bankAccountNumber,
      this.ifscSwiftCode,
      this.facilityProviderContacts,
      this.facilityProviderSubActivities,
      this.facilityProviderPrvReviews,
      this.facilityProviderCertifications,
      this.facilityProviderCancelPolicy,
      this.userName,
      this.accountClosureStatus,
      this.referralCode});

  FacilityProfileResponse.fromJson(Map<String, dynamic> json) {
    facilityName = json['FacilityName'];
    facilityProviderId = json['FacilityProviderId'];
    cityId = json['CityId'];
    cityName = json['CityName'];
    pinCode = json['PinCode'];
    email = json['Email'];
    mobCountryCode = json['MobCountryCode'];
    mobileNumber = json['MobileNumber'];
    address = json['Address'];
    uENRegistrationNo = json['UENRegistrationNo'];
    establishmentYear = json['EstablishmentYear'];
    otherDescription = json['OtherDescription'];
    regServiceProviderId = json['RegServiceProviderId'];
    userId = json['UserId'];
    profileImageId = json['ProfileImageId'];
    profileImage = json['ProfileImage'];
    isActive = json['IsActive'];
    regEmail = json['RegEmail'];
    payoutMethod = PayoutMethodTypeEnum.getEnumFromString(json['PayoutMethod'] ?? "");
    payNowId = json['PayNowId'];
    mobileNum = json['MobileNum'];
    beneficiaryName = json['BeneficiaryName'];
    bankName = json['BankName'];
    bankAccountNumber = json['BankAccountNumber'];
    ifscSwiftCode = json['IFSCSwiftCode'];
    if (json['FacilityProviderContacts'] != null) {
      facilityProviderContacts = <FacilityProviderContacts>[];
      json['FacilityProviderContacts'].forEach((v) {
        facilityProviderContacts!.add(FacilityProviderContacts.fromJson(v));
      });
    }
    if (json['FacilityProviderSubActivities'] != null) {
      facilityProviderSubActivities = <FacilityProviderSubActivities>[];
      json['FacilityProviderSubActivities'].forEach((v) {
        facilityProviderSubActivities!.add(FacilityProviderSubActivities.fromJson(v));
      });
    }
    if (json['FacilityProviderCertifications'] != null) {
      facilityProviderCertifications = <FacilityProviderCertifications>[];
      json['FacilityProviderCertifications'].forEach((v) {
        facilityProviderCertifications!.add(FacilityProviderCertifications.fromJson(v));
      });
    }
    facilityProviderCancelPolicy = FacilityProviderCancelPolicy.fromJson(json['FacilityProviderCancelPolicy']);
    userName = json['UserName'];
    accountClosureStatus = json['AccountClosureStatus'];
    referralCode = json['ReferralCode'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data['FacilityName'] = facilityName;
    data['FacilityProviderId'] = facilityProviderId;
    data['CityName'] = cityName;
    data['CityId'] = cityId;
    data['PinCode'] = pinCode;
    data['Email'] = email;
    data['MobCountryCode'] = mobCountryCode;
    data['MobileNumber'] = mobileNumber;
    data['Address'] = address;
    data['UENRegistrationNo'] = uENRegistrationNo;
    data['EstablishmentYear'] = establishmentYear;
    data['OtherDescription'] = otherDescription;
    data['RegServiceProviderId'] = regServiceProviderId;
    data['UserId'] = userId;
    data['ProfileImageId'] = profileImageId;
    data['ProfileImage'] = profileImage;
    data['IsActive'] = isActive;
    data['RegEmail'] = regEmail;
    data['PayoutMethod'] = payoutMethod?.value;
    data['PayNowId'] = payNowId;
    data['MobileNum'] = mobileNum;
    data['BeneficiaryName'] = beneficiaryName;
    data['BankName'] = bankName;
    data['BankAccountNumber'] = bankAccountNumber;
    data['IFSCSwiftCode'] = ifscSwiftCode;
    if (facilityProviderContacts != null) {
      data['FacilityProviderContacts'] = facilityProviderContacts!.map((v) => v.toJson()).toList();
    }
    if (facilityProviderSubActivities != null) {
      data['FacilityProviderSubActivities'] = facilityProviderSubActivities!.map((v) => v.toJson()).toList();
    }
    if (facilityProviderPrvReviews != null) {
      data['FacilityProviderPrvReviews'] = facilityProviderPrvReviews!.map((v) => v.toJson()).toList();
    }
    if (facilityProviderCertifications != null) {
      data['FacilityProviderCertifications'] = facilityProviderCertifications!.map((v) => v.toJson()).toList();
    }
    data['FacilityProviderCancelPolicy'] = facilityProviderCancelPolicy;
    data['UserName'] = userName;
    data['AccountClosureStatus'] = accountClosureStatus;
    data['ReferralCode'] = referralCode;
    return data;
  }
}

class FacilityProviderCancelPolicy {
  int? FacilityProviderCancelPolicyId;
  int? FacilityProviderId;
  String? EffectiveDate;
  int? CancelMinute;

  FacilityProviderCancelPolicy({this.FacilityProviderCancelPolicyId, this.FacilityProviderId, this.EffectiveDate, this.CancelMinute});

  FacilityProviderCancelPolicy.fromJson(Map<String, dynamic> json) {
    FacilityProviderCancelPolicyId = json['FacilityProviderCancelPolicyId'];
    FacilityProviderId = json['FacilityProviderId'];
    EffectiveDate = json['EffectiveDate'];
    CancelMinute = json['CancelMinute'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data['FacilityProviderCancelPolicyId'] = FacilityProviderCancelPolicyId;
    data['FacilityProviderId'] = FacilityProviderId;
    data['EffectiveDate'] = EffectiveDate;
    data['CancelMinute'] = CancelMinute;
    return data;
  }
}

class FacilityProviderContacts {
  int? facilityProviderContactId;
  int? facilityProviderId;
  String? name;
  String? mobCountryCode;
  String? mobileNumber;
  bool? isActive;

  FacilityProviderContacts({this.facilityProviderContactId, this.facilityProviderId, this.name, this.mobCountryCode, this.mobileNumber, this.isActive});

  FacilityProviderContacts.fromJson(Map<String, dynamic> json) {
    facilityProviderContactId = json['FacilityProviderContactId'];
    facilityProviderId = json['FacilityProviderId'];
    name = json['Name'];
    mobCountryCode = json['MobCountryCode'];
    mobileNumber = json['MobileNumber'];
    isActive = json['IsActive'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data['FacilityProviderContactId'] = facilityProviderContactId;
    data['FacilityProviderId'] = facilityProviderId;
    data['Name'] = name;
    data['MobCountryCode'] = mobCountryCode;
    data['MobileNumber'] = mobileNumber;
    data['IsActive'] = isActive;
    return data;
  }
}

class FacilityProviderSubActivities {
  int? facilityProviderSubActivityId;
  int? facilityProviderId;
  int? subActivityId;
  String? subActivityName;
  int? activityId;
  String? activityName;
  bool? isActive;

  FacilityProviderSubActivities(
      {this.facilityProviderSubActivityId,
      this.facilityProviderId,
      this.subActivityId,
      this.subActivityName,
      this.activityId,
      this.activityName,
      this.isActive});

  FacilityProviderSubActivities.fromJson(Map<String, dynamic> json) {
    facilityProviderSubActivityId = json['FacilityProviderSubActivityId'];
    facilityProviderId = json['FacilityProviderId'];
    subActivityId = json['SubActivityId'];
    subActivityName = json['SubActivityName'];
    activityId = json['ActivityId'];
    activityName = json['ActivityName'];
    isActive = json['IsActive'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data['FacilityProviderSubActivityId'] = facilityProviderSubActivityId;
    data['FacilityProviderId'] = facilityProviderId;
    data['SubActivityId'] = subActivityId;
    data['SubActivityName'] = subActivityName;
    data['ActivityId'] = activityId;
    data['ActivityName'] = activityName;
    data['IsActive'] = isActive;
    return data;
  }
}

class FacilityProviderCertifications {
  int? facilityProviderCertificationId;
  int? facilityProviderId;
  int? fileStorageId;
  String? fileName;
  String? fileExtension;
  String? filePath;
  bool? isActive;

  FacilityProviderCertifications({
    this.facilityProviderCertificationId,
    this.facilityProviderId,
    this.fileStorageId,
    this.fileName,
    this.fileExtension,
    this.filePath,
    this.isActive,
  });

  FacilityProviderCertifications.fromJson(Map<String, dynamic> json) {
    facilityProviderCertificationId = json['FacilityProviderCertificationId'] as int?;
    facilityProviderId = json['FacilityProviderId'] as int?;
    fileStorageId = json['FileStorageId'] as int?;
    fileName = json['FileName'] as String?;
    fileExtension = json['FileExtension'] as String?;
    filePath = json['FilePath'] as String?;
    isActive = json['IsActive'] as bool?;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = <String, dynamic>{};
    json['FacilityProviderCertificationId'] = facilityProviderCertificationId;
    json['FacilityProviderId'] = facilityProviderId;
    json['FileStorageId'] = fileStorageId;
    json['FileName'] = fileName;
    json['FileExtension'] = fileExtension;
    json['FilePath'] = filePath;
    json['IsActive'] = isActive;
    return json;
  }
}
