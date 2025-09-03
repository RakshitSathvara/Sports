class ConfigResponseModel {
  final String? didntShowReasonId;
  final String timeZoneId;
  final int cancelApplicableMinAfterEndTime;
  final int providerCancellationAllowedMin;
  final int slotFreezeExpireMin;
  final int facilityBookingPer;
  final int coachBookingPer;
  final int maxCancellationPolicyMin;
  final int facilityCommissionPer;
  final int coachCommissionPer;
  final bool storeModeVerification;
  final String storeModeOtpText;
  final String androidVersion;
  final String iosVersion;
  final String webVersion;
  final int notificationDays;
  final int blockStartTimeInMinute;
  final int blockEndTimeInMinute;
  final int perDayBookingMaxTimeInMinute;
  final String sourceControlVersion;
  final String equipmentDefualtExpiryDays;
  final String defaultRefCode;

  ConfigResponseModel({
    this.didntShowReasonId,
    required this.timeZoneId,
    required this.cancelApplicableMinAfterEndTime,
    required this.providerCancellationAllowedMin,
    required this.slotFreezeExpireMin,
    required this.facilityBookingPer,
    required this.coachBookingPer,
    required this.maxCancellationPolicyMin,
    required this.facilityCommissionPer,
    required this.coachCommissionPer,
    required this.storeModeVerification,
    required this.storeModeOtpText,
    required this.androidVersion,
    required this.iosVersion,
    required this.webVersion,
    required this.notificationDays,
    required this.blockStartTimeInMinute,
    required this.blockEndTimeInMinute,
    required this.perDayBookingMaxTimeInMinute,
    required this.sourceControlVersion,
    required this.equipmentDefualtExpiryDays,
    required this.defaultRefCode,
  });

  ConfigResponseModel.fromJson(Map<String, dynamic> json)
      : didntShowReasonId = json['DidntShowReasonId'] as String?,
        timeZoneId = json['TimeZoneId'] ?? '',
        cancelApplicableMinAfterEndTime = json['CancelApplicableMinAfterEndTime'] != null ? int.parse(json['CancelApplicableMinAfterEndTime']) : 0,
        providerCancellationAllowedMin = json['ProviderCancellationAllowedMin'] != null ? int.parse(json['ProviderCancellationAllowedMin']) : 0,
        slotFreezeExpireMin = json['SlotFreezeExpireMin'] != null ? int.parse(json['SlotFreezeExpireMin']) : 0,
        facilityBookingPer = json['FacilityBookingPer'] != null ? int.parse(json['FacilityBookingPer']) : 0,
        coachBookingPer = json['CoachBookingPer'] != null ? int.parse(json['CoachBookingPer']) : 0,
        maxCancellationPolicyMin = json['MaxCancellationPolicyMin'] != null ? int.parse(json['MaxCancellationPolicyMin']) : 0,
        facilityCommissionPer = json['FacilityCommissionPer'] != null ? int.parse(json['FacilityCommissionPer']) : 0,
        coachCommissionPer = json['CoachCommissionPer'] != null ? int.parse(json['CoachCommissionPer']) : 0,
        storeModeVerification = json['StoreModeVerification'] == 'true',
        storeModeOtpText = json['StoreModeOtpText'] ?? '',
        androidVersion = json['android_version'] ?? '',
        iosVersion = json['ios_version'] ?? '',
        webVersion = json['web_version'] ?? '',
        notificationDays = json['NotificationDays'] != null ? int.parse(json['NotificationDays']) : 0,
        blockStartTimeInMinute = json['BlockStartTimeInMinute'] != null ? int.parse(json['BlockStartTimeInMinute']) : 0,
        blockEndTimeInMinute = json['BlockEndTimeInMinute'] != null ? int.parse(json['BlockEndTimeInMinute']) : 0,
        perDayBookingMaxTimeInMinute = json['PerDayBookingMaxTimeInMinute'] != null ? int.parse(json['PerDayBookingMaxTimeInMinute']) : 0,
        sourceControlVersion = json['SourceControlVersion'] ?? '',
        equipmentDefualtExpiryDays = json['EquipmentDefaultExpiryDays'] ?? '',
        defaultRefCode = json['DefaultRefCode'] ?? '';

  Map<String, dynamic> toJson() => {
        'DidntShowReasonId': didntShowReasonId,
        'TimeZoneId': timeZoneId,
        'CancelApplicableMinAfterEndTime': cancelApplicableMinAfterEndTime,
        'ProviderCancellationAllowedMin': providerCancellationAllowedMin,
        'SlotFreezeExpireMin': slotFreezeExpireMin,
        'FacilityBookingPer': facilityBookingPer,
        'CoachBookingPer': coachBookingPer,
        'MaxCancellationPolicyMin': maxCancellationPolicyMin,
        'FacilityCommissionPer': facilityCommissionPer,
        'CoachCommissionPer': coachCommissionPer,
        'StoreModeVerification': storeModeVerification.toString(),
        'StoreModeOtpText': storeModeOtpText,
        'android_version': androidVersion,
        'ios_version': iosVersion,
        'web_version': webVersion,
        'NotificationDays': notificationDays,
        'BlockStartTimeInMinute': blockStartTimeInMinute,
        'BlockEndTimeInMinute': blockEndTimeInMinute,
        'PerDayBookingMaxTimeInMinute': perDayBookingMaxTimeInMinute,
        'SourceControlVersion': sourceControlVersion,
        'EquipmentDefaultExpiryDays': equipmentDefualtExpiryDays,
        'DefaultRefCode': defaultRefCode,
      };
}
