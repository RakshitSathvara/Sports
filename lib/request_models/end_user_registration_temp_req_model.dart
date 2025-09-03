class EndUserRegistrationTempReqModel {
  dynamic regServiceProviderId;
  String? registrationType;
  String? firstName;
  String? lastName;
  int? cityId;
  dynamic pinCode;
  String? userName;
  String? email;
  String? password;
  String? confirmPassword;
  String? mobileNumber;
  dynamic uenRegistrationNo;
  dynamic establishmentYear;
  dynamic otherDescription;

  static EndUserRegistrationTempReqModel? fromMap(Map<String, dynamic> map) {
    EndUserRegistrationTempReqModel endUserRegistrationTempReqModelBean = EndUserRegistrationTempReqModel();
    endUserRegistrationTempReqModelBean.regServiceProviderId = map['regServiceProviderId'];
    endUserRegistrationTempReqModelBean.registrationType = map['registrationType'];
    endUserRegistrationTempReqModelBean.firstName = map['firstName'];
    endUserRegistrationTempReqModelBean.lastName = map['lastName'];
    endUserRegistrationTempReqModelBean.cityId = map['cityId'];
    endUserRegistrationTempReqModelBean.pinCode = map['pinCode'];
    endUserRegistrationTempReqModelBean.userName = map['userName'];
    endUserRegistrationTempReqModelBean.email = map['email'];
    endUserRegistrationTempReqModelBean.password = map['password'];
    endUserRegistrationTempReqModelBean.confirmPassword = map['confirmPassword'];
    endUserRegistrationTempReqModelBean.mobileNumber = map['mobileNumber'];
    endUserRegistrationTempReqModelBean.uenRegistrationNo = map['uenRegistrationNo'];
    endUserRegistrationTempReqModelBean.establishmentYear = map['establishmentYear'];
    endUserRegistrationTempReqModelBean.otherDescription = map['otherDescription'];
    return endUserRegistrationTempReqModelBean;
  }

  Map toJson() => {
        "regServiceProviderId": regServiceProviderId,
        "registrationType": registrationType,
        "firstName": firstName,
        "lastName": lastName,
        "cityId": cityId,
        "pinCode": pinCode,
        "userName": userName,
        "email": email,
        "password": password,
        "confirmPassword": confirmPassword,
        "mobileNumber": mobileNumber,
        "uenRegistrationNo": uenRegistrationNo,
        "establishmentYear": establishmentYear,
        "otherDescription": otherDescription,
      };
}
