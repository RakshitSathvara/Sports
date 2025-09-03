class CoachTrainingAddress {
  int? coachTrainingAddressId;
  int? coachId;
  String? addressName;
  String? address1;
  String? address2;
  int? cityId;
  int? subActivityId;
  int? activityId;
  String? cityName;
  String? pinCode;
  bool? isActive;
  bool? isSelected = false;

  CoachTrainingAddress(
      {this.coachTrainingAddressId,
      this.coachId,
      this.addressName,
      this.address1,
      this.address2,
      this.cityId,
      this.subActivityId,
      this.activityId,
      this.cityName,
      this.pinCode,
      this.isActive,
      this.isSelected});

  factory CoachTrainingAddress.fromJson(Map<String, dynamic> json) {
    return CoachTrainingAddress(
      coachTrainingAddressId: json['CoachTrainingAddressId'] as int?,
      coachId: json['CoachId'] as int?,
      addressName: json['AddressName'] as String?,
      address1: json['Address1'] as String?,
      address2: json['Address2'] as String?,
      cityId: json['CityId'] as int?,
      subActivityId: json['SubActivityId'] as int?,
      activityId: json['ActivityId'] as int?,
      cityName: json['CityName'] as String?,
      pinCode: json['PinCode'] as String?,
      isActive: json['IsActive'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'CoachTrainingAddressId': coachTrainingAddressId,
        'CoachId': coachId,
        'AddressName': addressName,
        'Address1': address1,
        'Address2': address2,
        'CityId': cityId,
        'SubActivityId': subActivityId,
        'ActivityId': activityId,
        'CityName': cityName,
        'PinCode': pinCode,
        'IsActive': isActive,
      };
}
