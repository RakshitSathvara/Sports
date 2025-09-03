import 'package:oqdo_mobile_app/model/forgot_password_response_model.dart';

import '../../model/login_response_model.dart';

abstract class LoginRepository {
  Future<LoginResponseModel> loginRequest(String userName, String password, String notificationToken);

  Future<ForgotPasswordResponseModel> requestForgotPassword({required String email});

  Future<ForgotPasswordResponseModel> verifyForgotPasswordOTP({required String email, required String otp});

  Future<String> createPassword({required Map request});
}
