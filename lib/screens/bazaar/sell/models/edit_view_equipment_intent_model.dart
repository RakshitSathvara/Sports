import 'package:oqdo_mobile_app/screens/bazaar/sell/models/sell_equipment_response_model.dart';

class EditViewEquipmentIntentModel {
  final bool isEdit;
  final int? equipmentId;
  final SellEquipmentResponseModel? sellEquipmentResponseModel;

  const EditViewEquipmentIntentModel({
    this.isEdit = false,
    this.equipmentId,
    this.sellEquipmentResponseModel,
  });

  // Copyable
  EditViewEquipmentIntentModel copyWith({
    bool? isEdit,
    int? equipmentId,
    SellEquipmentResponseModel? sellEquipmentResponseModel,
  }) {
    return EditViewEquipmentIntentModel(
      isEdit: isEdit ?? this.isEdit,
      equipmentId: equipmentId ?? this.equipmentId,
      sellEquipmentResponseModel: sellEquipmentResponseModel ?? this.sellEquipmentResponseModel,
    );
  }

  // Equatable
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EditViewEquipmentIntentModel &&
        other.isEdit == isEdit &&
        other.equipmentId == equipmentId &&
        other.sellEquipmentResponseModel == sellEquipmentResponseModel;
  }

  @override
  int get hashCode => Object.hash(isEdit, equipmentId, sellEquipmentResponseModel);

  // For debugging and logging
  @override
  String toString() {
    return 'EditViewEquipmentIntentModel(isEdit: $isEdit, equipmentId: $equipmentId, sellEquipmentResponseModel: $sellEquipmentResponseModel)';
  }
}
