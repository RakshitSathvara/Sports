/// access_token : "HN78AbeWSdZiFFsnQqPTIOj3WLs6AppAYT2uYsG-XQ8hG6MQ4GSc-_hubX4Cx_edD3X48PnnyRaXTKJs_dowBaa6PeIXkEpd5q6wet5HaYuivlDQCMLlpi4qxKL7Wob_lNzancMd7XDR8x4iCbFqryphK11ovlr1d1LuNnAwSdUvvHpkhXhpZAtAkqx-Q8h_YjAXdn70vwPRZo9vxMvy2T1Q9NJx2V6yOr-etJ7IcEk04aJeTnA6dLCbGTexaRo1rp2z97diNohApX7-_JDdZwh7OwWoIuqFH2VMjBT075teHDc2JlQplhdNe-Vb9rBjSQai8Je4PE8NUgtEpUSnNnc43-1G8jgrSRpPYcvrhYgP3RFHesTej8V3mV_DMwiaTheQgf2IxeyZJ6E136MwR_9x0CSgT5rIa6SUL7PzW1A"
/// token_type : "bearer"
/// expires_in : 86399
/// refresh_token : "f85f6f4b89e84be5bebdb9a6a1fb2e62"
/// as:client_id : "AndroidApp"
/// UserId : "2577"
/// FacilityId : "0"
/// CoachId : "0"
/// EndUserId : "1"
/// Fcm : "hkj67878656lfghghdfh"
/// UserType : "E"
/// .issued : "Tue, 26 Jul 2022 09:32:53 GMT"
/// .expires : "Wed, 27 Jul 2022 09:32:53 GMT"

class LoginResponseModel {
  String? accessToken;
  String? tokenType;
  int? expiresIn;
  String? refreshToken;
  String? clientId;
  String? UserId;
  String? FacilityId;
  String? CoachId;
  String? EndUserId;
  String? Fcm;
  String? UserType;

  String? issued;

  String? expires;

  static LoginResponseModel? fromMap(Map<String, dynamic> map) {
    LoginResponseModel loginResponseModelBean = LoginResponseModel();
    loginResponseModelBean.accessToken = map['access_token'];
    loginResponseModelBean.tokenType = map['token_type'];
    loginResponseModelBean.expiresIn = map['expires_in'];
    loginResponseModelBean.refreshToken = map['refresh_token'];
    loginResponseModelBean.clientId = map['as:client_id'];
    loginResponseModelBean.UserId = map['UserId'];
    loginResponseModelBean.FacilityId = map['FacilityId'];
    loginResponseModelBean.CoachId = map['CoachId'];
    loginResponseModelBean.EndUserId = map['EndUserId'];
    loginResponseModelBean.Fcm = map['Fcm'];
    loginResponseModelBean.UserType = map['UserType'];
    loginResponseModelBean.issued = map['.issued'];
    loginResponseModelBean.expires = map['.expires'];
    return loginResponseModelBean;
  }

  Map toJson() => {
        "access_token": accessToken,
        "token_type": tokenType,
        "expires_in": expiresIn,
        "refresh_token": refreshToken,
        "as:client_id": clientId,
        "UserId": UserId,
        "FacilityId": FacilityId,
        "CoachId": CoachId,
        "EndUserId": EndUserId,
        "Fcm": Fcm,
        "UserType": UserType,
        ".issued": issued,
        "expires": expires
      };
}
