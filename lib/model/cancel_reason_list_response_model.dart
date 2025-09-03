class CancelReasonListResponseModel {
  final int? cancelReasonId;
  final String? cancelreason;
  final String? reasonFor;
  bool? isSelected = false;

  CancelReasonListResponseModel({this.cancelReasonId, this.cancelreason, this.isSelected, this.reasonFor});

  CancelReasonListResponseModel.fromJson(Map<String, dynamic> json)
      : cancelReasonId = json['CancelReasonId'] as int?,
        cancelreason = json['Cancelreason'] as String?,
        reasonFor = json['ReasonFor'] ?? '';

  Map<String, dynamic> toJson() => {'CancelReasonId': cancelReasonId, 'Cancelreason': cancelreason, 'ReasonFor': reasonFor};
}
