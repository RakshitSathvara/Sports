/// IsSuccess : false
/// Message : "Invalid OTP Or Expired."
/// ServiceProviderId : 3
/// MobileNumber : null
/// EmailAddress : null
/// OtpText : "311382"

class OtpVerificationResponse {
  bool? IsSuccess;
  String? Message;
  int? ServiceProviderId;
  dynamic MobileNumber;
  dynamic EmailAddress;
  String? OtpText;

  static OtpVerificationResponse? fromMap(Map<String, dynamic> map) {
    OtpVerificationResponse otpVerificationResponseBean = OtpVerificationResponse();
    otpVerificationResponseBean.IsSuccess = map['IsSuccess'];
    otpVerificationResponseBean.Message = map['Message'];
    otpVerificationResponseBean.ServiceProviderId = map['ServiceProviderId'];
    otpVerificationResponseBean.MobileNumber = map['MobileNumber'];
    otpVerificationResponseBean.EmailAddress = map['EmailAddress'];
    otpVerificationResponseBean.OtpText = map['OtpText'];
    return otpVerificationResponseBean;
  }

  Map toJson() => {
        "IsSuccess": IsSuccess,
        "Message": Message,
        "ServiceProviderId": ServiceProviderId,
        "MobileNumber": MobileNumber,
        "EmailAddress": EmailAddress,
        "OtpText": OtpText,
      };
}
