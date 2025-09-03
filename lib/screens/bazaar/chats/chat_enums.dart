enum EquipmentChatStatus {
  chatInitiate('CI'),
  accepted('AC'),
  closeDeal('CD');

  final String value;
  const EquipmentChatStatus(this.value);

  factory EquipmentChatStatus.fromString(String value) {
    return EquipmentChatStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => throw Exception('Invalid EquipmentChatStatus value: $value'),
    );
  }

  @override
  String toString() => value;
}

enum EquipmentChatMessageType {
  regular('RG'),
  offer('OF'),
  offerAccepted('OA');

  final String value;
  const EquipmentChatMessageType(this.value);

  factory EquipmentChatMessageType.fromString(String value) {
    return EquipmentChatMessageType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw Exception('Invalid EquipmentChatMessageType value: $value'),
    );
  }

  @override
  String toString() => value;
}

enum EquipmentStatusCode {
  active('AC'),
  inactive('IN'),
  pending('PE'),
  sold('SO'),
  expired('EX'),
  removed('RE');

  final String code;
  const EquipmentStatusCode(this.code);

  factory EquipmentStatusCode.fromString(String code) {
    return EquipmentStatusCode.values.firstWhere(
      (status) => status.code == code,
      orElse: () => throw Exception('Invalid EquipmentStatus code: $code'),
    );
  }

  @override
  String toString() => code;
}
