class ChatListResponseModel {
  final List<ChatItem> data;
  final int totalCount;
  final int pageStart;
  final int resultPerPage;

  ChatListResponseModel({
    required this.data,
    required this.totalCount,
    required this.pageStart,
    required this.resultPerPage,
  });

  factory ChatListResponseModel.fromJson(Map<String, dynamic> json) {
    return ChatListResponseModel(
      data: (json['Data'] as List).map((item) => ChatItem.fromJson(item)).toList(),
      totalCount: json['TotalCount'],
      pageStart: json['PageStart'],
      resultPerPage: json['ResultPerPage'],
    );
  }
}

class ChatItem {
  final int equipmentChatId;
  final int buyerId;
  final String buyerUserName;
  final int sellerId;
  final String sellerUserName;
  final String status;
  final bool isRemovedByBuyer;
  final bool isRemovedBySeller;
  final bool isActive;
  final int equipmentId;
  final String title;
  final String brand;
  final String description;
  final double price;
  final String expiryDate;
  final int equipmentStatusId;
  final EquipmentStatus equipmentStatus;
  final List<EquipmentImage> equipmentImages;
  bool? isNewMsg = false;

  ChatItem({
    required this.equipmentChatId,
    required this.buyerId,
    required this.buyerUserName,
    required this.sellerId,
    required this.sellerUserName,
    required this.status,
    required this.isRemovedByBuyer,
    required this.isRemovedBySeller,
    required this.isActive,
    required this.equipmentId,
    required this.title,
    required this.brand,
    required this.description,
    required this.price,
    required this.expiryDate,
    required this.equipmentStatusId,
    required this.equipmentStatus,
    required this.equipmentImages,
  });

  factory ChatItem.fromJson(Map<String, dynamic> json) {
    return ChatItem(
      equipmentChatId: json['EquipmentChatId'],
      buyerId: json['BuyerId'],
      buyerUserName: json['BuyerUserName'],
      sellerId: json['SellerId'],
      sellerUserName: json['SellerUserName'],
      status: json['Status'],
      isRemovedByBuyer: json['IsRemovedByBuyer'],
      isRemovedBySeller: json['IsRemovedBySeller'],
      isActive: json['IsActive'],
      equipmentId: json['EquipmentId'],
      title: json['Title'],
      brand: json['Brand'],
      description: json['Description'],
      price: json['Price'].toDouble(),
      expiryDate: json['ExpiryDate'],
      equipmentStatusId: json['EquipmentStatusId'],
      equipmentStatus: EquipmentStatus.fromJson(json['EquipmentStatus']),
      equipmentImages: (json['EquipmentImages'] as List).map((image) => EquipmentImage.fromJson(image)).toList(),
    )..isNewMsg = json['IsNewMsg'] ?? false;
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
      name: json['Name'],
      code: json['Code'],
    );
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
      equipmentImageId: json['EquipmentImageId'],
      fileStorageId: json['FileStorageId'],
      filePath: json['FilePath'],
      fileName: json['FileName'],
    );
  }
}
