class ResellerMaster {
  int ResellerId;
  int UserId;
  String FirmName;
  String GstNo;
  String PanNo;
  String MobileNo;
  String Address;
  String PinCode;
  int CityId;
  String Status;
  bool IsActive;
  int CreatedBy;
  String CreatedAt;
  Object UpdatedBy;
  Object UpdatedAt;

  ResellerMaster.fromJsonMap(Map<String, dynamic> map)
      : ResellerId = map["ResellerId"],
        UserId = map["UserId"],
        FirmName = map["FirmName"],
        GstNo = map["GstNo"],
        PanNo = map["PanNo"],
        MobileNo = map["MobileNo"],
        Address = map["Address"],
        PinCode = map["PinCode"],
        CityId = map["CityId"],
        Status = map["Status"],
        IsActive = map["IsActive"],
        CreatedBy = map["CreatedBy"],
        CreatedAt = map["CreatedAt"],
        UpdatedBy = map["UpdatedBy"],
        UpdatedAt = map["UpdatedAt"];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['ResellerId'] = ResellerId;
    data['UserId'] = UserId;
    data['FirmName'] = FirmName;
    data['GstNo'] = GstNo;
    data['PanNo'] = PanNo;
    data['MobileNo'] = MobileNo;
    data['Address'] = Address;
    data['PinCode'] = PinCode;
    data['CityId'] = CityId;
    data['Status'] = Status;
    data['IsActive'] = IsActive;
    data['CreatedBy'] = CreatedBy;
    data['CreatedAt'] = CreatedAt;
    data['UpdatedBy'] = UpdatedBy;
    data['UpdatedAt'] = UpdatedAt;
    return data;
  }
}
