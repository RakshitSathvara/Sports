class FacilityVacationResponseModel {
  final String? fromDate;
  final String? toDate;
  final String? cancelreason;
  final int? vacationId;
  final String? batchName;

  FacilityVacationResponseModel({this.fromDate, this.toDate, this.cancelreason, this.vacationId, this.batchName});

  FacilityVacationResponseModel.fromJson(Map<String, dynamic> json)
      : fromDate = json['FromDate'] as String?,
        toDate = json['ToDate'] as String?,
        cancelreason = json['Cancelreason'] as String?,
        batchName = json['BatchName'] as String?,
        vacationId = json['VacationId'] as int?;

  Map<String, dynamic> toJson() => {
        'FromDate': fromDate,
        'ToDate': toDate,
        'Cancelreason': cancelreason,
        'VacationId': vacationId,
        'BatchName': batchName
      };
}
