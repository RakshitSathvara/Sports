// equipment_chat_response_model.dart

class EquipmentChatResponseModel {
  final int equipmentId;
  final int equipmentChatId;
  final bool isBuyer;
  int buyerId;
  int sellerId;
  final String status;
  final bool isActive;
  final bool isRemovedByBuyer;
  final bool isRemovedBySeller;
  final bool isEquipmentOwner;
  final bool isActiveEquipment;
  final String title;
  final String brand;
  final String description;
  final double price;
  final DateTime expiryDate;
  final int sysUserId;
  final int equipmentCategoryId;
  final int equipmentStatusId;
  final String equipmentStatusName;
  final String equipmentStatusCode;
  final List<ChatEquipmentImage> equipmentImages;
  final ChatDetails chatDetails;

  EquipmentChatResponseModel({
    required this.equipmentId,
    required this.equipmentChatId,
    required this.isBuyer,
    required this.buyerId,
    required this.sellerId,
    required this.status,
    required this.isActive,
    required this.isRemovedByBuyer,
    required this.isRemovedBySeller,
    required this.isEquipmentOwner,
    required this.isActiveEquipment,
    required this.title,
    required this.brand,
    required this.description,
    required this.price,
    required this.expiryDate,
    required this.sysUserId,
    required this.equipmentCategoryId,
    required this.equipmentStatusId,
    required this.equipmentStatusName,
    required this.equipmentStatusCode,
    required this.equipmentImages,
    required this.chatDetails,
  });

  factory EquipmentChatResponseModel.fromJson(Map<String, dynamic> json) {
    return EquipmentChatResponseModel(
      equipmentId: json['EquipmentId'],
      equipmentChatId: json['EquipmentChatId'],
      isBuyer: json['IsBuyer'],
      buyerId: json['BuyerId'],
      sellerId: json['SellerId'],
      status: json['Status'] ?? '',
      isActive: json['IsActive'],
      isRemovedByBuyer: json['IsRemovedByBuyer'],
      isRemovedBySeller: json['IsRemovedBySeller'],
      isEquipmentOwner: json['IsEquipmentOwner'],
      isActiveEquipment: json['IsActiveEquipment'],
      title: json['Title'] ?? '',
      brand: json['Brand'] ?? '',
      description: json['Description'] ?? '',
      price: json['Price'] == null ? 0.0 : json['Price'].toDouble(),
      expiryDate: DateTime.parse(json['ExpiryDate'] ?? DateTime.now().toIso8601String()),
      sysUserId: json['SysUserId'],
      equipmentCategoryId: json['EquipmentCategoryId'],
      equipmentStatusId: json['EquipmentStatusId'],
      equipmentStatusName: json['EquipmentStatusName'] ?? '',
      equipmentStatusCode: json['EquipmentStatusCode'] ?? '',
      equipmentImages: (json['EquipmentImages'] as List).map((image) => ChatEquipmentImage.fromJson(image)).toList(),
      chatDetails: ChatDetails.fromJson(json['ChatDetails']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'EquipmentId': equipmentId,
      'EquipmentChatId': equipmentChatId,
      'IsBuyer': isBuyer,
      'BuyerId': buyerId,
      'SellerId': sellerId,
      'Status': status,
      'IsActive': isActive,
      'IsRemovedByBuyer': isRemovedByBuyer,
      'IsRemovedBySeller': isRemovedBySeller,
      'IsEquipmentOwner': isEquipmentOwner,
      'IsActiveEquipment': isActiveEquipment,
      'Title': title,
      'Brand': brand,
      'Description': description,
      'Price': price,
      'ExpiryDate': expiryDate.toIso8601String(),
      'SysUserId': sysUserId,
      'EquipmentCategoryId': equipmentCategoryId,
      'EquipmentStatusId': equipmentStatusId,
      'EquipmentStatusName': equipmentStatusName,
      'EquipmentStatusCode': equipmentStatusCode,
      'EquipmentImages': equipmentImages.map((image) => image.toJson()).toList(),
      'ChatDetails': chatDetails.toJson(),
    };
  }
}

class ChatEquipmentImage {
  final int fileStorageId;
  final String filePath;

  ChatEquipmentImage({
    required this.fileStorageId,
    required this.filePath,
  });

  factory ChatEquipmentImage.fromJson(Map<String, dynamic> json) {
    return ChatEquipmentImage(
      fileStorageId: json['FileStorageId'],
      filePath: json['FilePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'FileStorageId': fileStorageId,
      'FilePath': filePath,
    };
  }
}

class ChatDetails {
  final List<ChatMessage> data;
  final int totalCount;
  final int pageStart;
  final int resultPerPage;

  ChatDetails({
    required this.data,
    required this.totalCount,
    required this.pageStart,
    required this.resultPerPage,
  });

  factory ChatDetails.fromJson(Map<String, dynamic> json) {
    return ChatDetails(
      data: (json['Data'] as List).map((message) => ChatMessage.fromJson(message)).toList(),
      totalCount: json['TotalCount'],
      pageStart: json['PageStart'],
      resultPerPage: json['ResultPerPage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Data': data.map((message) => message.toJson()).toList(),
      'TotalCount': totalCount,
      'PageStart': pageStart,
      'ResultPerPage': resultPerPage,
    };
  }
}

class ChatMessage {
  final int? equipmentChatDetailId;
  final int? equipmentChatId;
  final int? fromUserId;
  final String? fromUserName;
  final int? toUserId;
  final String? toUserName;
  final String? messageType;
  final String? message;
  final double? price;
  final DateTime? createdAt;
  final int? equipmentId;
  final int? buyerId;
  final int? sellerId;
  final String? status;
  final bool? isActive;
  final bool? isRemovedByBuyer;
  final bool? isRemovedBySeller;
   String equipmentStatusName = '';
   String equipmentStatusCode = '';

  ChatMessage({
    required this.equipmentChatDetailId,
    required this.equipmentChatId,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.messageType,
    required this.message,
    required this.price,
    required this.createdAt,
    required this.equipmentId,
    required this.buyerId,
    required this.sellerId,
    required this.status,
    required this.isActive,
    required this.isRemovedByBuyer,
    required this.isRemovedBySeller,
    this.equipmentStatusName = '',
    this.equipmentStatusCode = '',
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      equipmentChatDetailId: json['EquipmentChatDetailId'],
      equipmentChatId: json['EquipmentChatId'],
      fromUserId: json['FromUserId'],
      fromUserName: json['FromUserName'],
      toUserId: json['ToUserId'],
      toUserName: json['ToUserName'],
      messageType: json['MessageType'],
      message: json['Message'],
      price: json['Price'].toDouble(),
      createdAt: json['CreatedAt'] != null ? DateTime.parse(json['CreatedAt']) : null,
      equipmentId: json['EquipmentId'],
      buyerId: json['BuyerId'],
      sellerId: json['SellerId'],
      status: json['Status'],
      isActive: json['IsActive'],
      isRemovedByBuyer: json['IsRemovedByBuyer'],
      isRemovedBySeller: json['IsRemovedBySeller'],
      equipmentStatusName: json['EquipmentStatusName'] ?? '',
      equipmentStatusCode: json['EquipmentStatusCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'EquipmentChatDetailId': equipmentChatDetailId,
      'EquipmentChatId': equipmentChatId,
      'FromUserId': fromUserId,
      'FromUserName': fromUserName,
      'ToUserId': toUserId,
      'ToUserName': toUserName,
      'MessageType': messageType,
      'Message': message,
      'Price': price,
      'CreatedAt': createdAt!.toIso8601String(),
      'EquipmentId': equipmentId,
      'BuyerId': buyerId,
      'SellerId': sellerId,
      'Status': status,
      'IsActive': isActive,
      'IsRemovedByBuyer': isRemovedByBuyer,
      'IsRemovedBySeller': isRemovedBySeller,
    };
  }
}
