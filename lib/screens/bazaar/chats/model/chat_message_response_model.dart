class ChatMessageResponseModel {
  int? equipmentId;
  int? equipmentChatId;
  bool? isBuyer;
  int? fromUserId;
  int? toUserId;
  String? name;
  String? status;
  String? messageType;
  String? message;
  num? price;
  bool? isactive;
  DateTime? createdDate;

  ChatMessageResponseModel({
    this.equipmentId,
    this.equipmentChatId,
    this.isBuyer,
    this.fromUserId,
    this.toUserId,
    this.name,
    this.status,
    this.messageType,
    this.message,
    this.price,
    this.isactive,
    this.createdDate,
  });

  factory ChatMessageResponseModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageResponseModel(
      equipmentId: json['EquipmentId'],
      equipmentChatId: json['EquipmentChatId'],
      isBuyer: json['IsBuyer'],
      fromUserId: json['FromUserId'],
      toUserId: json['ToUserId'],
      name: json['Name'],
      status: json['status'],
      messageType: json['messageType'],
      message: json['message'],
      price: json['price'],
      isactive: json['isactive'],
      createdDate: json['createdDate'] != null ? DateTime.parse(json['createdDate']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'EquipmentId': equipmentId,
      'EquipmentChatId': equipmentChatId,
      'IsBuyer': isBuyer,
      'FromUserId': fromUserId,
      'ToUserId': toUserId,
      'Name': name,
      'status': status,
      'messageType': messageType,
      'message': message,
      'price': price,
      'isactive': isactive,
    };
  }
}
