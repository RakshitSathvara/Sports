class Category {
  int CategoryId;
  String Name;
  String WefDate;
  Object FilestorageId;
  bool IsPublish;
  bool IsActive;
  int CreatedBy;
  String CreatedAt;
  int UpdatedBy;
  String UpdatedAt;
  Object FileStorage;

  Category.fromJsonMap(Map<String, dynamic> map)
      : CategoryId = map["CategoryId"],
        Name = map["Name"],
        WefDate = map["WefDate"],
        FilestorageId = map["FilestorageId"],
        IsPublish = map["IsPublish"],
        IsActive = map["IsActive"],
        CreatedBy = map["CreatedBy"],
        CreatedAt = map["CreatedAt"],
        UpdatedBy = map["UpdatedBy"],
        UpdatedAt = map["UpdatedAt"],
        FileStorage = map["FileStorage"];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['CategoryId'] = CategoryId;
    data['Name'] = Name;
    data['WefDate'] = WefDate;
    data['FilestorageId'] = FilestorageId;
    data['IsPublish'] = IsPublish;
    data['IsActive'] = IsActive;
    data['CreatedBy'] = CreatedBy;
    data['CreatedAt'] = CreatedAt;
    data['UpdatedBy'] = UpdatedBy;
    data['UpdatedAt'] = UpdatedAt;
    data['FileStorage'] = FileStorage;
    return data;
  }
}
