import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/data/remote/network/api_end_points.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:http/http.dart' as http;

class ChatRepository {
  var networkInterceptor = NetworkConnectionInterceptor();

  Future getChatDetails(Map<String, dynamic> request) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().getChatDetails;
      var uri = Uri.parse(url);
      var body = json.encode(request);
      debugPrint(body);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}',
      };
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
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

  Future getUserDetails(String userId) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().getUserDetails + userId;
      var uri = Uri.parse(url);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}',
      };
      var response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
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

  Future getChatList(Map<String, dynamic> request) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().getChatList;
      var uri = Uri.parse(url);
      var body = json.encode(request);
      debugPrint(body);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}',
      };
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
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

  Future deleteChat(Map<String, dynamic> request) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().deleteChat;
      var uri = Uri.parse(url);
      var body = json.encode(request);
      debugPrint(body);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}',
      };
      var response = await http.delete(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
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
