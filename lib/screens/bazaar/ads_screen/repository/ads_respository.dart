import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oqdo_mobile_app/data/remote/network/api_end_points.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';

abstract class AdsRepository {
  Future createLead(Map<String, dynamic> data);
  Future getAllActivityAndSubActivity();
  Future getAdvertisementTypeList();
  Future getAdvertisementList(Map<String, dynamic> data);
}

class AdsRepositoryImpl implements AdsRepository {
  final networkInterceptor = NetworkConnectionInterceptor();

  @override
  Future createLead(Map<String, dynamic> data) async {
    String url = Constants.BASE_URL + ApiEndPoints().createLead;
    debugPrint(url);
    var uri = Uri.parse(url);
    var body = json.encode(data);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    debugPrint(body);
    try {
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
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

  @override
  Future getAllActivityAndSubActivity() async {
    try {
      var response = await http
          .get(Uri.parse('${Constants.BASE_URL}${ApiEndPoints().getAllActivityAndSubActivity}PageStart=0&ResultPerPage=10000&SeachQuery'))
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

  @override
  Future getAdvertisementTypeList() async {
    try {
      var response = await http
          .get(Uri.parse('${Constants.BASE_URL}${ApiEndPoints().getAdvertisementTypeList}PageStart=0&ResultPerPage=10000&SeachQuery'))
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

  // Get Advertisement List
  @override
  Future getAdvertisementList(Map<String, dynamic> data) async {
    String url = Constants.BASE_URL + ApiEndPoints().getAdvertisements;
    debugPrint(url);
    var uri = Uri.parse(url);
    var body = json.encode(data);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    debugPrint(body);
    try {
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
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

  Future getAllSubActivity() async {
    try {
      var response = await http
          .get(Uri.parse('${Constants.BASE_URL}${ApiEndPoints().getAllActivityAndSubActivity}PageStart=0&ResultPerPage=10000&SeachQuery'))
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
}
