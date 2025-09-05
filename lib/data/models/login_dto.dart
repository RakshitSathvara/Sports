import 'dart:convert';
import '../../domain/entities/login_entity.dart';

class LoginDto {
  final String? accessToken;
  final String? tokenType;
  final int? expiresIn;
  final String? refreshToken;
  final String? clientId;
  final String? userId;
  final String? facilityId;
  final String? coachId;
  final String? endUserId;
  final String? fcm;
  final String? userType;
  final String? issued;
  final String? expires;

  const LoginDto({
    this.accessToken,
    this.tokenType,
    this.expiresIn,
    this.refreshToken,
    this.clientId,
    this.userId,
    this.facilityId,
    this.coachId,
    this.endUserId,
    this.fcm,
    this.userType,
    this.issued,
    this.expires,
  });

  factory LoginDto.fromMap(Map<String, dynamic> map) {
    return LoginDto(
      accessToken: map['access_token'] as String?,
      tokenType: map['token_type'] as String?,
      expiresIn: map['expires_in'] as int?,
      refreshToken: map['refresh_token'] as String?,
      clientId: map['as:client_id'] as String?,
      userId: map['UserId'] as String?,
      facilityId: map['FacilityId'] as String?,
      coachId: map['CoachId'] as String?,
      endUserId: map['EndUserId'] as String?,
      fcm: map['Fcm'] as String?,
      userType: map['UserType'] as String?,
      issued: map['.issued'] as String?,
      expires: map['.expires'] as String?,
    );
  }

  factory LoginDto.fromJson(String source) => LoginDto.fromMap(json.decode(source));

  Map<String, dynamic> toMap() => {
        'access_token': accessToken,
        'token_type': tokenType,
        'expires_in': expiresIn,
        'refresh_token': refreshToken,
        'as:client_id': clientId,
        'UserId': userId,
        'FacilityId': facilityId,
        'CoachId': coachId,
        'EndUserId': endUserId,
        'Fcm': fcm,
        'UserType': userType,
        '.issued': issued,
        '.expires': expires,
      };

  String toJson() => json.encode(toMap());

  LoginEntity toEntity() => LoginEntity(
        accessToken: accessToken,
        tokenType: tokenType,
        expiresIn: expiresIn,
        refreshToken: refreshToken,
        userId: userId,
      );
}
