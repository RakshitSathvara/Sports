class ResellerShippingAddresses {
  int ResellerAddressId;
  int ResellerId;
  String AddressName;
  String Address;
  int CityId;
  String PinCode;
  bool IsActive;
  int CreatedBy;
  String CreatedAt;
  Object UpdatedBy;
  Object UpdatedAt;

  ResellerShippingAddresses.fromJsonMap(Map<String, dynamic> map)
      : ResellerAddressId = map["ResellerAddressId"],
        ResellerId = map["ResellerId"],
        AddressName = map["AddressName"],
        Address = map["Address"],
        CityId = map["CityId"],
        PinCode = map["PinCode"],
        IsActive = map["IsActive"],
        CreatedBy = map["CreatedBy"],
        CreatedAt = map["CreatedAt"],
        UpdatedBy = map["UpdatedBy"],
        UpdatedAt = map["UpdatedAt"];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['ResellerAddressId'] = ResellerAddressId;
    data['ResellerId'] = ResellerId;
    data['AddressName'] = AddressName;
    data['Address'] = Address;
    data['CityId'] = CityId;
    data['PinCode'] = PinCode;
    data['IsActive'] = IsActive;
    data['CreatedBy'] = CreatedBy;
    data['CreatedAt'] = CreatedAt;
    data['UpdatedBy'] = UpdatedBy;
    data['UpdatedAt'] = UpdatedAt;
    return data;
  }
}
