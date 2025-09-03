import 'dart:convert';
import 'dart:io' show InternetAddress, Platform, SocketException;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oqdo_mobile_app/data/remote/network/api_end_points.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';

class LoginRepositoryImpl {
  final networkInterceptor = NetworkConnectionInterceptor();

  Future loginRequest(String userName, String password, String notificationToken) async {
    try {
      String os = Platform.operatingSystem;
      var response = await http
          .post(
            Uri.parse('${Constants.BASE_URL}/token'),
            headers: {
              "Content-Type": "application/x-www-form-urlencoded",
            },
            encoding: Encoding.getByName('utf-8'),
            body: {
              "grant_type": "password",
              "Client_id": os == 'android' ? 'AndroidApp' : 'IOSApp',
              "Client_Secret": Constants.androidSecret,
              "username": userName,
              "password": password,
              "NotificationToken": notificationToken,
            },
          )
          .timeout(const Duration(seconds: 10));
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

  Future requestForgotPassword({required String email}) async {
    try {
      String encodedEmail = Uri.encodeComponent(email);
      String url = "${Constants.BASE_URL}${ApiEndPoints().requestForgotPassword}?EmailId=$encodedEmail";
      debugPrint("URL: -$url");
      var response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
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

  Future verifyForgotPasswordOTP({required String email, required String otp}) async {
    try {
      String encodedEmail = Uri.encodeComponent(email);
      String url = "${Constants.BASE_URL}${ApiEndPoints().verifyForgotPasswordOTP}?EmailId=$encodedEmail&OtpText=$otp";
      debugPrint("URL: -$url");
      var response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
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

  Future createPassword({required Map request}) async {
    try {
      String url = "${Constants.BASE_URL}${ApiEndPoints().createPassword}";
      debugPrint("URL: -$url");
      var response = await http.post(Uri.parse(url), body: request).timeout(const Duration(seconds: 10));
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
