class CoachBatchFavoriteResponseModel {
  final List<CoachBatchData> data;
  final int totalCount;
  final int pageStart;
  final int resultPerPage;

  const CoachBatchFavoriteResponseModel({
    required this.data,
    required this.totalCount,
    required this.pageStart,
    required this.resultPerPage,
  });

  factory CoachBatchFavoriteResponseModel.fromJson(Map<String, dynamic> json) => CoachBatchFavoriteResponseModel(
        data: List<CoachBatchData>.from(
          (json['Data'] as List<dynamic>).map(
            (x) => CoachBatchData.fromJson(x as Map<String, dynamic>),
          ),
        ),
        totalCount: json['TotalCount'] as int? ?? 0,
        pageStart: json['PageStart'] as int? ?? 0,
        resultPerPage: json['ResultPerPage'] as int? ?? 10,
      );

  Map<String, dynamic> toJson() => {
        'Data': data.map((x) => x.toJson()).toList(),
        'TotalCount': totalCount,
        'PageStart': pageStart,
        'ResultPerPage': resultPerPage,
      };

  @override
  String toString() => 'CoachBatchResponse(data: $data, totalCount: $totalCount, pageStart: $pageStart, resultPerPage: $resultPerPage)';

  CoachBatchFavoriteResponseModel copyWith({
    List<CoachBatchData>? data,
    int? totalCount,
    int? pageStart,
    int? resultPerPage,
  }) {
    return CoachBatchFavoriteResponseModel(
      data: data ?? this.data,
      totalCount: totalCount ?? this.totalCount,
      pageStart: pageStart ?? this.pageStart,
      resultPerPage: resultPerPage ?? this.resultPerPage,
    );
  }
}

class CoachBatchData {
  final int coachBatchSetupId;
  final int coachBatchSetupDetailId;
  final String firstName;
  final String lastName;
  final String activityName;
  final String subActivityName;
  final String name;
  final int coachId;
  final String coachName;
  final double minimumHrRate;
  final String bookingType;
  final double? avrageRating;
  final int minStartTime;
  final int maxStartTime;
  final String startTime;
  final String endTime;
  final String profileImagePath;
  final String address;
  final double avgProviderRating;
  bool isFavorite;

  CoachBatchData({
    required this.coachBatchSetupId,
    required this.coachBatchSetupDetailId,
    required this.firstName,
    required this.lastName,
    required this.activityName,
    required this.subActivityName,
    required this.name,
    required this.coachId,
    required this.coachName,
    required this.minimumHrRate,
    required this.bookingType,
    this.avrageRating,
    required this.minStartTime,
    required this.maxStartTime,
    required this.startTime,
    required this.endTime,
    required this.profileImagePath,
    required this.address,
    required this.avgProviderRating,
    this.isFavorite = true,
  });

  factory CoachBatchData.fromJson(Map<String, dynamic> json) => CoachBatchData(
        coachBatchSetupId: json['CoachBatchSetupId'] as int? ?? 0,
        coachBatchSetupDetailId: json['CoachBatchSetupDetailId'] as int? ?? 0,
        firstName: json['FirstName'] as String? ?? '',
        lastName: json['LastName'] as String? ?? '',
        activityName: json['ActivityName'] as String? ?? '',
        subActivityName: json['SubActivityName'] as String? ?? '',
        name: json['Name'] as String? ?? '',
        coachId: json['CoachId'] as int? ?? 0,
        coachName: json['CoachName'] as String? ?? '',
        minimumHrRate: (json['MinimumHrRate'] as num?)?.toDouble() ?? 0.0,
        bookingType: json['BookingType'] as String? ?? '',
        avrageRating: (json['AvrageRating'] as num?)?.toDouble(),
        minStartTime: json['MinStartTime'] as int? ?? 0,
        maxStartTime: json['MaxStartTime'] as int? ?? 0,
        startTime: json['StartTime'] as String? ?? '',
        endTime: json['EndTime'] as String? ?? '',
        profileImagePath: json['ProfileImagePath'] as String? ?? '',
        address: json['Address'] as String? ?? '',
        avgProviderRating: (json['AvgProviderRating'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'CoachBatchSetupId': coachBatchSetupId,
        'CoachBatchSetupDetailId': coachBatchSetupDetailId,
        'FirstName': firstName,
        'LastName': lastName,
        'ActivityName': activityName,
        'SubActivityName': subActivityName,
        'Name': name,
        'CoachId': coachId,
        'CoachName': coachName,
        'MinimumHrRate': minimumHrRate,
        'BookingType': bookingType,
        'AvrageRating': avrageRating,
        'MinStartTime': minStartTime,
        'MaxStartTime': maxStartTime,
        'StartTime': startTime,
        'EndTime': endTime,
        'ProfileImagePath': profileImagePath,
        'Address': address,
        'AvgProviderRating': avgProviderRating,
      };

  @override
  String toString() => 'CoachBatchData(coachName: $coachName, activityName: $activityName, subActivityName: $subActivityName)';

  CoachBatchData copyWith({
    int? coachBatchSetupId,
    int? coachBatchSetupDetailId,
    String? firstName,
    String? lastName,
    String? activityName,
    String? subActivityName,
    String? name,
    int? coachId,
    String? coachName,
    double? minimumHrRate,
    String? bookingType,
    double? avrageRating,
    int? minStartTime,
    int? maxStartTime,
    String? startTime,
    String? endTime,
    String? profileImagePath,
    String? address,
    double? avgProviderRating,
  }) {
    return CoachBatchData(
      coachBatchSetupId: coachBatchSetupId ?? this.coachBatchSetupId,
      coachBatchSetupDetailId: coachBatchSetupDetailId ?? this.coachBatchSetupDetailId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      activityName: activityName ?? this.activityName,
      subActivityName: subActivityName ?? this.subActivityName,
      name: name ?? this.name,
      coachId: coachId ?? this.coachId,
      coachName: coachName ?? this.coachName,
      minimumHrRate: minimumHrRate ?? this.minimumHrRate,
      bookingType: bookingType ?? this.bookingType,
      avrageRating: avrageRating ?? this.avrageRating,
      minStartTime: minStartTime ?? this.minStartTime,
      maxStartTime: maxStartTime ?? this.maxStartTime,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      address: address ?? this.address,
      avgProviderRating: avgProviderRating ?? this.avgProviderRating,
    );
  }
}
