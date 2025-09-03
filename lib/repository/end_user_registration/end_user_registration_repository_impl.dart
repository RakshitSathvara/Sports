import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';

import '../../data/remote/network/api_end_points.dart';
import '../../utils/constants.dart';

class EndUserRegistrationRepositoryImpl {
  final networkInterceptor = NetworkConnectionInterceptor();

  Future getAllActivityAndSubActivity() async {
    try {
      var response = await http
          .get(Uri.parse('${Constants.BASE_URL}${ApiEndPoints().getAllActivity}PageStart=0&ResultPerPage=10000&SeachQuery'))
          .timeout(const Duration(seconds: 10));
      debugPrint(response.body.toString());
      return response;
    } on http.ClientException catch (_) {
      final isConnected = await networkInterceptor.isConnected();
      if (isConnected) {
        throw ServerException();
      } else {
        throw NoConnectivityException();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future getAllCity() async {
    try {
      var response = await http
          .get(
            Uri.parse('${Constants.BASE_URL}${ApiEndPoints().getAllCities}?PageStart=0&ResultPerPage=10000&SeachQuery'),
          )
          .timeout(const Duration(seconds: 10));
      debugPrint(response.body.toString());
      return response;
    } on http.ClientException catch (_) {
      final isConnected = await networkInterceptor.isConnected();
      if (isConnected) {
        throw ServerException();
      } else {
        throw NoConnectivityException();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future checkUsernameExist(String userName) async {
    try {
      var response = await http.get(Uri.parse(Constants.BASE_URL + ApiEndPoints().checkUserNameExists + userName)).timeout(const Duration(seconds: 10));
      return response;
    } on http.ClientException catch (_) {
      final isConnected = await networkInterceptor.isConnected();
      if (isConnected) {
        throw ServerException();
      } else {
        throw NoConnectivityException();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future checkEmailExist(String email) async {
    try {
      debugPrint('URL -> ${Constants.BASE_URL + ApiEndPoints().checkForMobileNumber + email}');
      var response = await http.get(Uri.parse(Constants.BASE_URL + ApiEndPoints().checkEmailExists + email)).timeout(const Duration(seconds: 10));
      debugPrint('response -> ${response.body}');
      return response;
    } on http.ClientException catch (_) {
      final isConnected = await networkInterceptor.isConnected();
      if (isConnected) {
        throw ServerException();
      } else {
        throw NoConnectivityException();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future checkForMobileNoExists(String mobileNo) async {
    try {
      debugPrint('URL -> ${Constants.BASE_URL + ApiEndPoints().checkForMobileNumber + mobileNo}');
      var response = await http.get(Uri.parse(Constants.BASE_URL + ApiEndPoints().checkForMobileNumber + mobileNo)).timeout(const Duration(seconds: 10));
      debugPrint('Response -> ${response.body}');
      return response;
    } on http.ClientException catch (_) {
      final isConnected = await networkInterceptor.isConnected();
      if (isConnected) {
        throw ServerException();
      } else {
        throw NoConnectivityException();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future tempEndUserRegistration(Map endUserRegistrationTempReqModel) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().tempRegistration;
      debugPrint(url);
      var uri = Uri.parse(url);
      var body = json.encode(endUserRegistrationTempReqModel);
      debugPrint(body);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      debugPrint('Response -> ${response.body}');
      return response;
    } on http.ClientException catch (_) {
      final isConnected = await networkInterceptor.isConnected();
      if (isConnected) {
        throw ServerException();
      } else {
        throw NoConnectivityException();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future sendEmailOtp(String number) async {
    try {
      debugPrint('URL - > ${Constants.BASE_URL + ApiEndPoints().sendEmailOTP + number}');
      var response = await http.get(Uri.parse(Constants.BASE_URL + ApiEndPoints().sendEmailOTP + number)).timeout(const Duration(seconds: 10));
      return response;
    } on http.ClientException catch (_) {
      final isConnected = await networkInterceptor.isConnected();
      if (isConnected) {
        throw ServerException();
      } else {
        throw NoConnectivityException();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future sendSMSOtp(String number) async {
    try {
      debugPrint('URL -> ${Constants.BASE_URL + ApiEndPoints().sendSMSOTP + number}');
      var response = await http.get(Uri.parse(Constants.BASE_URL + ApiEndPoints().sendSMSOTP + number)).timeout(const Duration(seconds: 10));
      return response;
    } on http.ClientException catch (_) {
      final isConnected = await networkInterceptor.isConnected();
      if (isConnected) {
        throw ServerException();
      } else {
        throw NoConnectivityException();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future verifyOtp(Map data) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().verifyOtp;
      debugPrint(url);
      var uri = Uri.parse(url);
      var body = json.encode(data);
      debugPrint(body);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      debugPrint(response.body);
      return response;
    } on http.ClientException catch (_) {
      final isConnected = await networkInterceptor.isConnected();
      if (isConnected) {
        throw ServerException();
      } else {
        throw NoConnectivityException();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future uploadImage(Map uploadImageData) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().uploadImage;
      debugPrint(url);
      var uri = Uri.parse(url);
      var body = json.encode(uploadImageData);
      debugPrint(body);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(minutes: 2));
      return response;
    } on http.ClientException catch (_) {
      final isConnected = await networkInterceptor.isConnected();
      if (isConnected) {
        throw ServerException();
      } else {
        throw NoConnectivityException();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future multipleUploadImage(List<Map<String, dynamic>> uploadImageData) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().multipleUploadImage;
      debugPrint(url);
      var uri = Uri.parse(url);
      var body = json.encode(uploadImageData);
      debugPrint(body);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(minutes: 5));
      return response;
    } on http.ClientException catch (_) {
      final isConnected = await networkInterceptor.isConnected();
      if (isConnected) {
        throw ServerException();
      } else {
        throw NoConnectivityException();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future endUserRegister(Map endUserRegisterRequest) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().endUserRegister;
      debugPrint(url);
      var uri = Uri.parse(url);
      var body = json.encode(endUserRegisterRequest);
      debugPrint(body);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      debugPrint('endUserRegister - response -> ${response.body}');
      return response;
    } on http.ClientException catch (_) {
      final isConnected = await networkInterceptor.isConnected();
      if (isConnected) {
        throw ServerException();
      } else {
        throw NoConnectivityException();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future facilityProviderRegister(Map facilityProviderRequest) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().facilityProviderRegister;
      debugPrint(url);
      var uri = Uri.parse(url);
      debugPrint(facilityProviderRequest.toString());
      var body = json.encode(facilityProviderRequest);
      debugPrint(body);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      debugPrint('facilityProviderRequest - response -> ${response.body}');
      return response;
    } on http.ClientException catch (_) {
      final isConnected = await networkInterceptor.isConnected();
      if (isConnected) {
        throw ServerException();
      } else {
        throw NoConnectivityException();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future coachProviderRegister(Map coachProviderRequest) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().coachProviderRegister;
      debugPrint(url);
      var uri = Uri.parse(url);
      var body = json.encode(coachProviderRequest);
      debugPrint(body);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      debugPrint('coachProviderRequest - response -> ${response.body}');
      return response;
    } on http.ClientException catch (_) {
      final isConnected = await networkInterceptor.isConnected();
      if (isConnected) {
        throw ServerException();
      } else {
        throw NoConnectivityException();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future validateReferralCode(String referralCode) async {
    try {
      var response = await http.get(Uri.parse('${Constants.BASE_URL}${ApiEndPoints().validateReferralCode}$referralCode')).timeout(const Duration(seconds: 10));
      debugPrint(response.body.toString());
      return response;
    } on http.ClientException catch (_) {
      final isConnected = await networkInterceptor.isConnected();
      if (isConnected) {
        throw ServerException();
      } else {
        throw NoConnectivityException();
      }
    } catch (e) {
      rethrow;
    }
  }
}
