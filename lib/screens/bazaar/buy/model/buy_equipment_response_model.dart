class BuyEquipmentResponseModel {
  final List<EquipmentData> data;
  final int totalCount;
  final int pageStart;
  final int resultPerPage;

  BuyEquipmentResponseModel({
    required this.data,
    required this.totalCount,
    required this.pageStart,
    required this.resultPerPage,
  });

  factory BuyEquipmentResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('Invalid JSON');
    }
    return BuyEquipmentResponseModel(
      data: (json['Data'] as List<dynamic>? ?? []).map((item) => EquipmentData.fromJson(item as Map<String, dynamic>?)).toList(),
      totalCount: json['TotalCount'] ?? 0,
      pageStart: json['PageStart'] ?? 0,
      resultPerPage: json['ResultPerPage'] ?? 0,
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
}

class EquipmentData {
  final int equipmentId;
  final String title;
  final String brand;
  final String description;
  final DateTime? expiryDate;
  final DateTime? postDate;
  final double price;
  final bool isActive;
  final int sysUserId;
  final String userName;
   bool isFavourite = false;
  final int equipmentCategoryId;
  final EquipmentCategory? equipmentCategory;
  final int equipmentStatusId;
  final EquipmentStatus? equipmentStatus;
  final List<EquipmentImage> equipmentImages;

  EquipmentData({
    required this.equipmentId,
    required this.title,
    required this.brand,
    required this.description,
    required this.expiryDate,
    required this.postDate,
    required this.price,
    required this.isActive,
    required this.sysUserId,
    required this.userName,
    required this.isFavourite,
    required this.equipmentCategoryId,
    required this.equipmentCategory,
    required this.equipmentStatusId,
    required this.equipmentStatus,
    required this.equipmentImages,
  });

  factory EquipmentData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('Invalid JSON');
    }
    return EquipmentData(
      equipmentId: json['EquipmentId'] ?? 0,
      title: json['Title'] ?? '',
      brand: json['Brand'] ?? '',
      description: json['Description'] ?? '',
      expiryDate: json['ExpiryDate'] != null ? DateTime.tryParse(json['ExpiryDate']) : null,
      postDate: json['PostDate'] != null ? DateTime.tryParse(json['PostDate']) : null,
      price: (json['Price'] ?? 0).toDouble(),
      isActive: json['IsActive'] ?? false,
      sysUserId: json['SysUserId'] ?? 0,
      userName: json['UserName'] ?? '',
      isFavourite: json['IsFavourite'] ?? false,
      equipmentCategoryId: json['EquipmentCategoryId'] ?? 0,
      equipmentCategory: json['EquipmentCategory'] != null ? EquipmentCategory.fromJson(json['EquipmentCategory'] as Map<String, dynamic>?) : null,
      equipmentStatusId: json['EquipmentStatusId'] ?? 0,
      equipmentStatus: json['EquipmentStatus'] != null ? EquipmentStatus.fromJson(json['EquipmentStatus'] as Map<String, dynamic>?) : null,
      equipmentImages: (json['EquipmentImages'] as List<dynamic>? ?? []).map((item) => EquipmentImage.fromJson(item as Map<String, dynamic>?)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'EquipmentId': equipmentId,
      'Title': title,
      'Brand': brand,
      'Description': description,
      'ExpiryDate': expiryDate?.toIso8601String(),
      'PostDate': postDate?.toIso8601String(),
      'Price': price,
      'IsActive': isActive,
      'SysUserId': sysUserId,
      'UserName': userName,
      'IsFavourite': isFavourite,
      'EquipmentCategoryId': equipmentCategoryId,
      'EquipmentCategory': equipmentCategory?.toJson(),
      'EquipmentStatusId': equipmentStatusId,
      'EquipmentStatus': equipmentStatus?.toJson(),
      'EquipmentImages': equipmentImages.map((item) => item.toJson()).toList(),
    };
  }
}

class EquipmentCategory {
  final String name;
  final String code;

  EquipmentCategory({
    required this.name,
    required this.code,
  });

  factory EquipmentCategory.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return EquipmentCategory(name: '', code: '');
    }
    return EquipmentCategory(
      name: json['Name'] ?? '',
      code: json['Code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Code': code,
    };
  }
}

class EquipmentStatus {
  final String name;
  final String code;

  EquipmentStatus({
    required this.name,
    required this.code,
  });

  factory EquipmentStatus.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return EquipmentStatus(name: '', code: '');
    }
    return EquipmentStatus(
      name: json['Name'] ?? '',
      code: json['Code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Code': code,
    };
  }
}

class EquipmentImage {
  final int equipmentImageId;
  final int fileStorageId;
  final String filePath;
  final String fileName;

  EquipmentImage({
    required this.equipmentImageId,
    required this.fileStorageId,
    required this.filePath,
    required this.fileName,
  });

  factory EquipmentImage.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return EquipmentImage(equipmentImageId: 0, fileStorageId: 0, filePath: '', fileName: '');
    }
    return EquipmentImage(
      equipmentImageId: json['EquipmentImageId'] ?? 0,
      fileStorageId: json['FileStorageId'] ?? 0,
      filePath: json['FilePath'] ?? '',
      fileName: json['FileName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'EquipmentImageId': equipmentImageId,
      'FileStorageId': fileStorageId,
      'FilePath': filePath,
      'FileName': fileName,
    };
  }
}
