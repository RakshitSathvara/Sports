class EquipmentConditionResponseModel {
  final List<EquipmentCondition> data;
  final int totalCount;
  final int pageStart;
  final int resultPerPage;

  EquipmentConditionResponseModel({
    required this.data,
    required this.totalCount,
    required this.pageStart,
    required this.resultPerPage,
  });

  factory EquipmentConditionResponseModel.fromJson(Map<String, dynamic> json) {
    return EquipmentConditionResponseModel(
      data: (json['Data'] as List).map((e) => EquipmentCondition.fromJson(e)).toList(),
      totalCount: json['TotalCount'],
      pageStart: json['PageStart'],
      resultPerPage: json['ResultPerPage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Data': data.map((e) => e.toJson()).toList(),
      'TotalCount': totalCount,
      'PageStart': pageStart,
      'ResultPerPage': resultPerPage,
    };
  }
}

class EquipmentCondition {
  final int equipmentConditionId;
  final String name;
  final String code;
  final String description;
  final bool isActive;

  EquipmentCondition({
    required this.equipmentConditionId,
    required this.name,
    required this.code,
    required this.description,
    required this.isActive,
  });

  factory EquipmentCondition.fromJson(Map<String, dynamic> json) {
    return EquipmentCondition(
      equipmentConditionId: json['EquipmentConditionId'],
      name: json['Name'],
      code: json['Code'],
      description: json['Description'],
      isActive: json['IsActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'EquipmentConditionId': equipmentConditionId,
      'Name': name,
      'Code': code,
      'Description': description,
      'IsActive': isActive,
    };
  }
}
