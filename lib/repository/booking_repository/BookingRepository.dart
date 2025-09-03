import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:oqdo_mobile_app/data/remote/network/api_end_points.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';

class BookingRepository {
  final networkInterceptor = NetworkConnectionInterceptor();

  Future getAllFacilities(String value) async {
    try {
      final url = Uri.parse(Constants.BASE_URL + ApiEndPoints().getAllFacilities + value);
      debugPrint('URL -> $url');

      // Prepare headers
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      // Set authorization header if user is logged in
      if (OQDOApplication.instance.isLogin == '1') {
        headers["Authorization"] = '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}';
      }

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

  Future getFacilityById(int facilitySetupId) async {
    try {
      final url = Uri.parse(Constants.BASE_URL + ApiEndPoints().getFacilityById + facilitySetupId.toString());
      debugPrint('URL -> $url');

      // Prepare headers
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      // Set authorization header if user is logged in
      if (OQDOApplication.instance.isLogin == '1') {
        headers["Authorization"] = '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}';
      }

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

  Future getCoaches(String value) async {
    try {
      final url = Uri.parse(Constants.BASE_URL + ApiEndPoints().getCoaches + value);
      debugPrint('URL -> $url');

      // Prepare headers
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      // Set authorization header if user is logged in
      if (OQDOApplication.instance.isLogin == '1') {
        headers["Authorization"] = '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}';
      }

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

  Future getCoachDetailsById(String coachSetupId) async {
    try {
      final url = Uri.parse(Constants.BASE_URL + ApiEndPoints().coachDetailsById + coachSetupId);
      debugPrint('URL -> $url');

      // Prepare headers
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      // Set authorization header if user is logged in
      if (OQDOApplication.instance.isLogin == '1') {
        headers["Authorization"] = '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}';
      }

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

  Future getEndUserAddress(String userId) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().getEndUserAddress + userId;
      debugPrint('URL -> $url');
      var uri = Uri.parse(url);
      var response = await http.get(uri).timeout(const Duration(seconds: 10));
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

  Future addFavorite(Map<String, dynamic> request) async {
    try {
      final url = Uri.parse(Constants.BASE_URL + ApiEndPoints().addFavorite);
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
            body: json.encode(request),
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

  Future getFavoriteFacilities(String request) async {
    try {
      final url = Uri.parse(Constants.BASE_URL + ApiEndPoints().getFavoriteList + request);
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

  Future getFavoriteCoach(String request) async {
    try {
      final url = Uri.parse(Constants.BASE_URL + ApiEndPoints().getFavoriteList + request);
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
}
