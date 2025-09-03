import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/data/remote/network/api_end_points.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:http/http.dart' as http;

class SellRepository {
  var networkInterceptor = NetworkConnectionInterceptor();

  Future getEquipments(Map<String, dynamic> request) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().getEquipmentsList;
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

  Future getAllEquipmentCategories() async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().getAllEquipmentCategories;
      var uri = Uri.parse(url);
      Map<String, String> headers = {
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

  Future getEquipmentFavorite(String request) async {
    try {
      final url = Uri.parse(Constants.BASE_URL + ApiEndPoints().getAllEquipmentFavorites + request);
      debugPrint('URL -> $url');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
      };

      final response = await http
          .get(
            url,
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

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

  Future getAllEquipmentConditionList() async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().getAllEquipmentConditionList;
      var uri = Uri.parse(url);
      Map<String, String> headers = {
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

  Future postProduct(Map<String, dynamic> request) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().postProduct;
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

  Future getEquipmentDetail(String request) async {
    try {
      final url = Uri.parse(Constants.BASE_URL + ApiEndPoints().getEquipmentById + request);
      debugPrint('URL -> $url');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
      };

      final response = await http
          .get(
            url,
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

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

  Future editPostProduct(Map<String, dynamic> request) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().updateProduct;
      var uri = Uri.parse(url);
      var body = json.encode(request);
      debugPrint(body);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}',
      };
      var response = await http.put(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
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

  Future deleteEquipment(Map<String, dynamic> request) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().postProduct;
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

  Future addRemoveFromFavorite(String request) async {
    try {
      final url = Uri.parse(Constants.BASE_URL + ApiEndPoints().equipmentAddRemoveFavorite + request);
      debugPrint('URL -> $url');

      // Prepare headers
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
      };

      final response = await http
          .post(
            url,
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('addFavorite - response -> ${response.body}');
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

  Future updateEquipmentStatus(Map<String, dynamic> request) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().updateEquipmentStatus;
      var uri = Uri.parse(url);
      var body = json.encode(request);
      debugPrint(body);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}',
      };
      var response = await http.put(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
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
