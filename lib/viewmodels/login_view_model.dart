import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/repository/login_repository/login_repository_impl.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginRepositoryImpl _loginRepositoryImpl = LoginRepositoryImpl();

  Future login(String userName, String password, String notificationToken) async {
    try {
      var response = await _loginRepositoryImpl.loginRequest(userName, password, notificationToken);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future requestForgotPassword({required String email}) async {
    try {
      var response = await _loginRepositoryImpl.requestForgotPassword(email: email);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future verifyForgotPasswordOTP({required String email, required String otp}) async {
    try {
      var response = await _loginRepositoryImpl.verifyForgotPasswordOTP(email: email, otp: otp);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future createPassword({required Map request}) async {
    try {
      var response = await _loginRepositoryImpl.createPassword(request: request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }
}
