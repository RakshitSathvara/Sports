import 'package:collection/collection.dart';

class Datum {
  String? firstName;
  String? lastName;
  dynamic coachBatchSetupDetails;
  List<dynamic>? coachprvreview;
  String? activityName;
  String? subActivityName;
  int? subActivityId;
  int? activityId;
  int? coachId;
  String? name;
  int? coachBatchSetupId;
  String? coachName;
  double? minimumHrRate;
  double? avrageRating;
  bool? isSelected = false;

  Datum(
      {this.firstName,
      this.lastName,
      this.coachBatchSetupDetails,
      this.coachprvreview,
      this.activityName,
      this.subActivityName,
      this.subActivityId,
      this.activityId,
      this.coachId,
      this.name,
      this.coachBatchSetupId,
      this.coachName,
      this.minimumHrRate,
      this.avrageRating,
      this.isSelected});

  factory Datum.fromMap(Map<String, dynamic> json) {
    return Datum(
      firstName: json['FirstName'] as String?,
      lastName: json['LastName'] as String?,
      coachBatchSetupDetails: json['CoachBatchSetupDetails'] as dynamic,
      coachprvreview: json['coachprvreview'] as List<dynamic>?,
      activityName: json['ActivityName'] as String?,
      subActivityName: json['SubActivityName'] as String?,
      subActivityId: json['SubActivityId'] as int?,
      activityId: json['ActivityId'] as int?,
      coachId: json['CoachId'] as int?,
      name: json['Name'] as String?,
      coachBatchSetupId: json['CoachBatchSetupId'] as int?,
      coachName: json['CoachName'] as String?,
      minimumHrRate: json['MinimumHrRate'] as double?,
      avrageRating: json['AvrageRating'] as double?,
    );
  }

  Map<String, dynamic> tpJson() {
    return {
      'FirstName': firstName,
      'LastName': lastName,
      'CoachBatchSetupDetails': coachBatchSetupDetails,
      'coachprvreview': coachprvreview,
      'ActivityName': activityName,
      'SubActivityName': subActivityName,
      'SubActivityId': subActivityId,
      'ActivityId': activityId,
      'CoachId': coachId,
      'Name': name,
      'CoachBatchSetupId': coachBatchSetupId,
      'CoachName': coachName,
      'MinimumHrRate': minimumHrRate,
      'AvrageRating': avrageRating,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! Datum) return false;
    var mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.tpJson(), tpJson());
  }

  @override
  int get hashCode =>
      firstName.hashCode ^
      lastName.hashCode ^
      coachBatchSetupDetails.hashCode ^
      coachprvreview.hashCode ^
      activityName.hashCode ^
      subActivityName.hashCode ^
      subActivityId.hashCode ^
      activityId.hashCode ^
      coachId.hashCode ^
      name.hashCode ^
      coachBatchSetupId.hashCode ^
      coachName.hashCode ^
      minimumHrRate.hashCode ^
      avrageRating.hashCode;
}
