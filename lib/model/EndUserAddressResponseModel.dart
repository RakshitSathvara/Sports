class EndUserAddressResponseModel {
  int? endUserTrainingAddressId;
  int? endUserId;
  String? addressName;
  String? address1;
  String? address2;
  String? cityName;
  String? subActivitiesName;
  String? pinCode;
  int? subActivityId;
  int? activityId;

  EndUserAddressResponseModel({
    this.endUserTrainingAddressId,
    this.endUserId,
    this.addressName,
    this.address1,
    this.address2,
    this.cityName,
    this.subActivitiesName,
    this.pinCode,
    this.subActivityId,
    this.activityId,
  });

  EndUserAddressResponseModel.fromJson(Map<String, dynamic> json) {
    endUserTrainingAddressId = json['EndUserTrainingAddressId'] as int?;
    endUserId = json['EndUserId'] as int?;
    addressName = json['AddressName'] as String?;
    address1 = json['Address1'] as String?;
    address2 = json['Address2'] as String?;
    cityName = json['CityName'] as String?;
    subActivitiesName = json['SubActivitiesName'] as String?;
    pinCode = json['PinCode'] as String?;
    subActivityId = json['SubActivityId'] as int?;
    activityId = json['ActivityId'] as int?;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = <String, dynamic>{};
    json['EndUserTrainingAddressId'] = endUserTrainingAddressId;
    json['EndUserId'] = endUserId;
    json['AddressName'] = addressName;
    json['Address1'] = address1;
    json['Address2'] = address2;
    json['CityName'] = cityName;
    json['SubActivitiesName'] = subActivitiesName;
    json['PinCode'] = pinCode;
    json['SubActivityId'] = subActivityId;
    json['ActivityId'] = activityId;
    return json;
  }
}
