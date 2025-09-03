import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/repository/end_user_registration/end_user_registration_repository_impl.dart';
import '../model/otp_verification_response.dart';
import '../model/upload_file_response.dart';

class EndUserRegistrationViewModel extends ChangeNotifier {
  final EndUserRegistrationRepositoryImpl endUserRegistrationRepositoryImpl = EndUserRegistrationRepositoryImpl();

  Future getAllCities() async {
    try {
      var response = await endUserRegistrationRepositoryImpl.getAllCity();
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future getAllActivity() async {
    try {
      var response = await endUserRegistrationRepositoryImpl.getAllActivityAndSubActivity();
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future checkUserNameExists(String userName) async {
    try {
      var response = await endUserRegistrationRepositoryImpl.checkUsernameExist(userName);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future checkEmailExists(String email) async {
    try {
      var response = await endUserRegistrationRepositoryImpl.checkEmailExist(email);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future checkForMobileNoExists(String mobileNo) async {
    try {
      var response = await endUserRegistrationRepositoryImpl.checkForMobileNoExists(mobileNo);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future tempEnduserRegistration(Map endUserRegistrationTempReqModel) async {
    try {
      var response = await endUserRegistrationRepositoryImpl.tempEndUserRegistration(endUserRegistrationTempReqModel);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future sendSMSOtp(String number) async {
    try {
      var response = await endUserRegistrationRepositoryImpl.sendSMSOtp(number);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future sendEmailOtp(String number) async {
    try {
      var response = await endUserRegistrationRepositoryImpl.sendEmailOtp(number);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future otpVerification(Map data) async {
    try {
      var response = await endUserRegistrationRepositoryImpl.verifyOtp(data);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future uploadFile(Map uploadRequest) async {
    try {
      var response = await endUserRegistrationRepositoryImpl.uploadImage(uploadRequest);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future multipleUploadFile(List<Map<String, dynamic>> uploadRequest) async {
    try {
      var response = await endUserRegistrationRepositoryImpl.multipleUploadImage(uploadRequest);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future endUserRegister(Map request) async {
    try {
      var response = await endUserRegistrationRepositoryImpl.endUserRegister(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future facilityProviderRegister(Map request) async {
    try {
      var response = await endUserRegistrationRepositoryImpl.facilityProviderRegister(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future coachProviderRegister(Map request) async {
    try {
      var response = await endUserRegistrationRepositoryImpl.coachProviderRegister(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future validateReferralCode(String code) async {
    try {
      var response = await endUserRegistrationRepositoryImpl.validateReferralCode(code);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }
}
