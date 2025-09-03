class CoachVacationResponseModel {
  final String? fromDate;
  final String? toDate;
  final String? cancelreason;
  final int? vacationId;
  final String? batchName;

  CoachVacationResponseModel({this.fromDate, this.toDate, this.cancelreason, this.vacationId, this.batchName});

  CoachVacationResponseModel.fromJson(Map<String, dynamic> json)
      : fromDate = json['FromDate'] as String?,
        toDate = json['ToDate'] as String?,
        cancelreason = json['Cancelreason'] as String?,
        vacationId = json['VacationId'] as int?,
        batchName = json['BatchName'] as String?;

  Map<String, dynamic> toJson() => {
        'FromDate': fromDate,
        'ToDate': toDate,
        'Cancelreason': cancelreason,
        'VacationId': vacationId,
        'BatchName': batchName
      };
}
