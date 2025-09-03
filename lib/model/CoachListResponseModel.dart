class CoachListResponseModel {
  final List<Data>? data;
  final int? totalCount;
  final int? pageStart;
  final int? resultPerPage;

  CoachListResponseModel({
    this.data,
    this.totalCount,
    this.pageStart,
    this.resultPerPage,
  });

  CoachListResponseModel.fromJson(Map<String, dynamic> json)
      : data = (json['Data'] as List?)?.map((dynamic e) => Data.fromJson(e as Map<String, dynamic>)).toList(),
        totalCount = json['TotalCount'] as int?,
        pageStart = json['PageStart'] as int?,
        resultPerPage = json['ResultPerPage'] as int?;

  Map<String, dynamic> toJson() =>
      {'Data': data?.map((e) => e.toJson()).toList(), 'TotalCount': totalCount, 'PageStart': pageStart, 'ResultPerPage': resultPerPage};
}

class Data {
  final String? firstName;
  final String? lastName;
  final int? coachBatchSetupId;
  final int? coachBatchSetupDetailId;
  final String? activityName;
  final String? subActivityName;
  final int? subActivityId;
  final int? activityId;
  final int? coachId;
  final String? coachName;
  final dynamic avrageRating;
  final String? bookingType;
  final double? minimumHrRate;
  final int? minStartTime;
  final int? maxStartTime;
  final String? startTime;
  final String? endTime;
  final String? profileImagePath;
  final String? address;
  final double? AvgProviderRating;
  bool? isFavourite = false;

  Data(
      {this.firstName,
      this.lastName,
      this.coachBatchSetupId,
      this.coachBatchSetupDetailId,
      this.activityName,
      this.subActivityName,
      this.subActivityId,
      this.activityId,
      this.coachId,
      this.coachName,
      this.avrageRating,
      this.bookingType,
      this.minimumHrRate,
      this.minStartTime,
      this.maxStartTime,
      this.startTime,
      this.endTime,
      this.profileImagePath,
      this.address,
      this.AvgProviderRating,
      this.isFavourite});

  Data.fromJson(Map<String, dynamic> json)
      : firstName = json['FirstName'] as String?,
        lastName = json['LastName'] as String?,
        coachBatchSetupId = json['CoachBatchSetupId'] as int?,
        coachBatchSetupDetailId = json['CoachBatchSetupDetailId'] as int?,
        activityName = json['ActivityName'] as String?,
        subActivityName = json['SubActivityName'] as String?,
        subActivityId = json['SubActivityId'] as int?,
        activityId = json['ActivityId'] as int?,
        coachId = json['CoachId'] as int?,
        coachName = json['CoachName'] as String?,
        avrageRating = json['AvrageRating'] ?? '',
        bookingType = json['BookingType'] as String?,
        minimumHrRate = json['MinimumHrRate'] as double? ?? 0.00,
        minStartTime = json['MinStartTime'] as int? ?? 0,
        maxStartTime = json['MaxStartTime'] as int? ?? 0,
        startTime = json['StartTime'] as String?,
        endTime = json['EndTime'] as String?,
        profileImagePath = json['ProfileImagePath'] as String?,
        address = json['Address'] as String?,
        AvgProviderRating = json['AvgProviderRating'] ?? 0.0,
        isFavourite = json['IsFavourite'] as bool?;

  Map<String, dynamic> toJson() => {
        'FirstName': firstName,
        'LastName': lastName,
        'CoachBatchSetupId': coachBatchSetupId,
        'CoachBatchSetupDetailId': coachBatchSetupDetailId,
        'ActivityName': activityName,
        'SubActivityName': subActivityName,
        'SubActivityId': subActivityId,
        'ActivityId': activityId,
        'CoachId': coachId,
        'CoachName': coachName,
        'AvrageRating': avrageRating,
        'BookingType': bookingType,
        'MinimumHrRate': minimumHrRate,
        'MinStartTime': minStartTime,
        'MaxStartTime': maxStartTime,
        'StartTime': startTime,
        'EndTime': endTime,
        'ProfileImagePath': profileImagePath,
        'Address': address,
        'rating': AvgProviderRating,
        'IsFavourite': isFavourite
      };
}
