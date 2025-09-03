// equipment_category_response_model.dart

class EquipmentCategoryResponseModel {
  final List<EquipmentCategory> data;
  final int totalCount;
  final int pageStart;
  final int resultPerPage;

  EquipmentCategoryResponseModel({
    required this.data,
    required this.totalCount,
    required this.pageStart,
    required this.resultPerPage,
  });

  factory EquipmentCategoryResponseModel.fromJson(Map<String, dynamic> json) {
    return EquipmentCategoryResponseModel(
      data: (json['Data'] as List).map((item) => EquipmentCategory.fromJson(item)).toList(),
      totalCount: json['TotalCount'] as int,
      pageStart: json['PageStart'] as int,
      resultPerPage: json['ResultPerPage'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Data': data.map((item) => item.toJson()).toList(),
      'TotalCount': totalCount,
      'PageStart': pageStart,
      'ResultPerPage': resultPerPage,
    };
  }

  @override
  String toString() {
    return 'EquipmentCategoryResponseModel(data: $data, totalCount: $totalCount, pageStart: $pageStart, resultPerPage: $resultPerPage)';
  }
}

class EquipmentCategory {
  final int equipmentCategoryId;
  final String name;
  final String code;
  final int imageId;
  final String filePath;
  final bool isActive;

  EquipmentCategory({
    required this.equipmentCategoryId,
    required this.name,
    required this.code,
    required this.imageId,
    required this.filePath,
    required this.isActive,
  });

  factory EquipmentCategory.fromJson(Map<String, dynamic> json) {
    return EquipmentCategory(
      equipmentCategoryId: json['EquipmentCategoryId'] as int,
      name: json['Name'] as String,
      code: json['Code'] as String,
      imageId: json['ImageId'] as int,
      filePath: json['FilePath'] as String,
      isActive: json['IsActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'EquipmentCategoryId': equipmentCategoryId,
      'Name': name,
      'Code': code,
      'ImageId': imageId,
      'FilePath': filePath,
      'IsActive': isActive,
    };
  }

  @override
  String toString() {
    return 'EquipmentCategory(equipmentCategoryId: $equipmentCategoryId, name: $name, code: $code, imageId: $imageId, filePath: $filePath, isActive: $isActive)';
  }

  EquipmentCategory copyWith({
    int? equipmentCategoryId,
    String? name,
    String? code,
    int? imageId,
    String? filePath,
    bool? isActive,
  }) {
    return EquipmentCategory(
      equipmentCategoryId: equipmentCategoryId ?? this.equipmentCategoryId,
      name: name ?? this.name,
      code: code ?? this.code,
      imageId: imageId ?? this.imageId,
      filePath: filePath ?? this.filePath,
      isActive: isActive ?? this.isActive,
    );
  }
}
