class BuyFavoriteEquipmentResponseModel {
  final List<BuyFavoriteEquipment> data;
  final int totalCount;
  final int pageStart;
  final int resultPerPage;

  BuyFavoriteEquipmentResponseModel({
    required this.data,
    required this.totalCount,
    required this.pageStart,
    required this.resultPerPage,
  });

  factory BuyFavoriteEquipmentResponseModel.fromJson(Map<String, dynamic> json) {
    return BuyFavoriteEquipmentResponseModel(
      data: (json['Data'] as List).map((e) => BuyFavoriteEquipment.fromJson(e)).toList(),
      totalCount: json['TotalCount'] as int,
      pageStart: json['PageStart'] as int,
      resultPerPage: json['ResultPerPage'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'Data': data.map((e) => e.toJson()).toList(),
        'TotalCount': totalCount,
        'PageStart': pageStart,
        'ResultPerPage': resultPerPage,
      };
}

class BuyFavoriteEquipment {
  final int equipmentId;
  final String title;
  final String brand;
  final String description;
  final DateTime expiryDate;
  final DateTime postDate;
  final double price;
  final bool isActive;
  final int sysUserId;
  final String userName;
  final int equipmentCategoryId;
  final BuyFavoriteEquipmentCategory equipmentCategory;
  final int equipmentStatusId;
  final BuyFavoriteEquipmentStatus equipmentStatus;
  final List<BuyFavoriteEquipmentImage> equipmentImages;
  bool isFavourite = true;

  BuyFavoriteEquipment({
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
    required this.equipmentCategoryId,
    required this.equipmentCategory,
    required this.equipmentStatusId,
    required this.equipmentStatus,
    required this.equipmentImages,
  });

  factory BuyFavoriteEquipment.fromJson(Map<String, dynamic> json) {
    return BuyFavoriteEquipment(
      equipmentId: json['EquipmentId'] as int,
      title: json['Title'] as String,
      brand: json['Brand'] as String,
      description: json['Description'] as String,
      expiryDate: DateTime.parse(json['ExpiryDate'] as String),
      postDate: DateTime.parse(json['PostDate'] as String),
      price: (json['Price'] as num).toDouble(),
      isActive: json['IsActive'] as bool,
      sysUserId: json['SysUserId'] as int,
      userName: json['UserName'] as String,
      equipmentCategoryId: json['EquipmentCategoryId'] as int,
      equipmentCategory: BuyFavoriteEquipmentCategory.fromJson(json['EquipmentCategory'] as Map<String, dynamic>),
      equipmentStatusId: json['EquipmentStatusId'] as int,
      equipmentStatus: BuyFavoriteEquipmentStatus.fromJson(json['EquipmentStatus'] as Map<String, dynamic>),
      equipmentImages: (json['EquipmentImages'] as List)
          .map((e) => BuyFavoriteEquipmentImage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'EquipmentId': equipmentId,
        'Title': title,
        'Brand': brand,
        'Description': description,
        'ExpiryDate': expiryDate.toIso8601String(),
        'PostDate': postDate.toIso8601String(),
        'Price': price,
        'IsActive': isActive,
        'SysUserId': sysUserId,
        'UserName': userName,
        'EquipmentCategoryId': equipmentCategoryId,
        'EquipmentCategory': equipmentCategory.toJson(),
        'EquipmentStatusId': equipmentStatusId,
        'EquipmentStatus': equipmentStatus.toJson(),
        'EquipmentImages': equipmentImages.map((e) => e.toJson()).toList(),
      };
}

class BuyFavoriteEquipmentCategory {
  final String name;
  final String code;

  BuyFavoriteEquipmentCategory({
    required this.name,
    required this.code,
  });

  factory BuyFavoriteEquipmentCategory.fromJson(Map<String, dynamic> json) {
    return BuyFavoriteEquipmentCategory(
      name: json['Name'] as String,
      code: json['Code'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'Name': name,
        'Code': code,
      };
}

class BuyFavoriteEquipmentStatus {
  final String name;
  final String code;

  BuyFavoriteEquipmentStatus({
    required this.name,
    required this.code,
  });

  factory BuyFavoriteEquipmentStatus.fromJson(Map<String, dynamic> json) {
    return BuyFavoriteEquipmentStatus(
      name: json['Name'] as String,
      code: json['Code'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'Name': name,
        'Code': code,
      };
}

class BuyFavoriteEquipmentImage {
  final int equipmentImageId;
  final int fileStorageId;
  final String filePath;
  final String fileName;

  BuyFavoriteEquipmentImage({
    required this.equipmentImageId,
    required this.fileStorageId,
    required this.filePath,
    required this.fileName,
  });

  factory BuyFavoriteEquipmentImage.fromJson(Map<String, dynamic> json) {
    return BuyFavoriteEquipmentImage(
      equipmentImageId: json['EquipmentImageId'] as int,
      fileStorageId: json['FileStorageId'] as int,
      filePath: json['FilePath'] as String,
      fileName: json['FileName'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'EquipmentImageId': equipmentImageId,
        'FileStorageId': fileStorageId,
        'FilePath': filePath,
        'FileName': fileName,
      };
}