class SellEquipmentResponseModel {
  final int equipmentId;
  final String title;
  final String brand;
  final String description;
  final DateTime? expiryDate;
  final DateTime postDate;
  final double price;
  final bool isActive;
  final int sysUserId;
  final int equipmentCategoryId;
  final bool isEquipmentOwner;
  final String fullName;
  final String mobileNumber;
  final String email;
  final String userType;
  final bool isFavourite;
  final SellEquipmentCategory sellEquipmentCategory;
  final int equipmentConditionId;
  final SellEquipmentCondition sellEquipmentCondition;
  final int equipmentStatusId;
  final EquipmentStatus equipmentStatus;
  final List<EquipmentSubActivity> equipmentSubActivities;
  final List<EquipmentImage> equipmentImages;
  final int? equipmentChatId;
  final String? userName;

  SellEquipmentResponseModel({
    required this.equipmentId,
    required this.title,
    required this.brand,
    required this.description,
    this.expiryDate,
    required this.postDate,
    required this.price,
    required this.isActive,
    required this.sysUserId,
    required this.equipmentCategoryId,
    required this.isEquipmentOwner,
    required this.fullName,
    required this.mobileNumber,
    required this.email,
    required this.userType,
    required this.isFavourite,
    required this.sellEquipmentCategory,
    required this.equipmentConditionId,
    required this.sellEquipmentCondition,
    required this.equipmentStatusId,
    required this.equipmentStatus,
    required this.equipmentSubActivities,
    required this.equipmentImages,
    required this.equipmentChatId,
    this.userName,
  });

  factory SellEquipmentResponseModel.fromJson(Map<String, dynamic> json) {
    return SellEquipmentResponseModel(
      equipmentId: json['EquipmentId'] as int,
      title: json['Title'] as String,
      brand: json['Brand'] as String,
      description: json['Description'] as String,
      expiryDate: json['ExpiryDate'] != null ? DateTime.parse(json['ExpiryDate']) : null,
      postDate: DateTime.parse(json['PostDate']),
      price: (json['Price'] as num).toDouble(),
      isActive: json['IsActive'] as bool,
      sysUserId: json['SysUserId'] as int,
      equipmentCategoryId: json['EquipmentCategoryId'] as int,
      isEquipmentOwner: json['IsEquipmentOwner'] as bool,
      fullName: json['FullName'] as String,
      mobileNumber: json['MobileNumber'] as String,
      email: json['Email'] as String,
      userType: json['UserType'] as String,
      isFavourite: json['IsFavourite'] as bool,
      sellEquipmentCategory: SellEquipmentCategory.fromJson(json['EquipmentCategory']),
      equipmentConditionId: json['EquipmentConditionId'] as int,
      sellEquipmentCondition: SellEquipmentCondition.fromJson(json['EquipmentCondition']),
      equipmentStatusId: json['EquipmentStatusId'] as int,
      equipmentStatus: EquipmentStatus.fromJson(json['EquipmentStatus']),
      equipmentSubActivities: (json['EquipmentSubActivities'] as List).map((e) => EquipmentSubActivity.fromJson(e)).toList(),
      equipmentImages: (json['EquipmentImages'] as List).map((e) => EquipmentImage.fromJson(e)).toList(),
      equipmentChatId: json['EquipmentChatId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'EquipmentId': equipmentId,
      'Title': title,
      'Brand': brand,
      'Description': description,
      'ExpiryDate': expiryDate?.toIso8601String(),
      'PostDate': postDate.toIso8601String(),
      'Price': price,
      'IsActive': isActive,
      'SysUserId': sysUserId,
      'EquipmentCategoryId': equipmentCategoryId,
      'IsEquipmentOwner': isEquipmentOwner,
      'FullName': fullName,
      'MobileNumber': mobileNumber,
      'Email': email,
      'UserType': userType,
      'IsFavourite': isFavourite,
      'EquipmentCategory': sellEquipmentCategory.toJson(),
      'EquipmentConditionId': equipmentConditionId,
      'EquipmentCondition': sellEquipmentCondition.toJson(),
      'EquipmentStatusId': equipmentStatusId,
      'EquipmentStatus': equipmentStatus.toJson(),
      'EquipmentSubActivities': equipmentSubActivities.map((e) => e.toJson()).toList(),
      'EquipmentImages': equipmentImages.map((e) => e.toJson()).toList(),
    };
  }
}

class SellEquipmentCategory {
  final String name;
  final String code;

  SellEquipmentCategory({
    required this.name,
    required this.code,
  });

  factory SellEquipmentCategory.fromJson(Map<String, dynamic> json) {
    return SellEquipmentCategory(
      name: json['Name'] as String,
      code: json['Code'] as String,
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

  factory EquipmentStatus.fromJson(Map<String, dynamic> json) {
    return EquipmentStatus(
      name: json['Name'] as String,
      code: json['Code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Code': code,
    };
  }
}

class SellEquipmentCondition {
  final String name;
  final String code;

  SellEquipmentCondition({
    required this.name,
    required this.code,
  });

  factory SellEquipmentCondition.fromJson(Map<String, dynamic> json) {
    return SellEquipmentCondition(
      name: json['Name'] as String,
      code: json['Code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Code': code,
    };
  }
}

class EquipmentSubActivity {
  final int equipmentSubActivityId;
  final int subActivityId;
  final String name;

  EquipmentSubActivity({
    required this.equipmentSubActivityId,
    required this.subActivityId,
    required this.name,
  });

  factory EquipmentSubActivity.fromJson(Map<String, dynamic> json) {
    return EquipmentSubActivity(
      equipmentSubActivityId: json['EquipmentSubActivityId'] as int,
      subActivityId: json['SubActivityId'] as int,
      name: json['Name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'EquipmentSubActivityId': equipmentSubActivityId,
      'SubActivityId': subActivityId,
      'Name': name,
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

  factory EquipmentImage.fromJson(Map<String, dynamic> json) {
    return EquipmentImage(
      equipmentImageId: json['EquipmentImageId'] as int,
      fileStorageId: json['FileStorageId'] as int,
      filePath: json['FilePath'] as String,
      fileName: json['FileName'] as String,
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
