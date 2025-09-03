class OrderStatus {
  int OrderStatusId;
  String Name;
  String Code;
  bool IsActive;
  int CreatedBy;
  String CreatedAt;
  Object UpdatedBy;
  Object UpdatedAt;

  OrderStatus.fromJsonMap(Map<String, dynamic> map)
      : OrderStatusId = map["OrderStatusId"],
        Name = map["Name"],
        Code = map["Code"],
        IsActive = map["IsActive"],
        CreatedBy = map["CreatedBy"],
        CreatedAt = map["CreatedAt"],
        UpdatedBy = map["UpdatedBy"],
        UpdatedAt = map["UpdatedAt"];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['OrderStatusId'] = OrderStatusId;
    data['Name'] = Name;
    data['Code'] = Code;
    data['IsActive'] = IsActive;
    data['CreatedBy'] = CreatedBy;
    data['CreatedAt'] = CreatedAt;
    data['UpdatedBy'] = UpdatedBy;
    data['UpdatedAt'] = UpdatedAt;
    return data;
  }
}
