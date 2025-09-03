import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oqdo_mobile_app/data/remote/network/api_end_points.dart';

import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';

class ProfileRepositoryImpl {
  var networkInterceptor = NetworkConnectionInterceptor();

  Future getCoachUserProfile(String coachId) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().coachUserProfileCall + coachId;
      print(url);
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

  Future getEndUserProfile(String endUserId) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().endUserProfileCall + endUserId;
      // print(url);
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

  Future getFacilityUserProfile(String facilityId) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().facilityUserProfileCall + facilityId;
      // print(url);
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

  Future getAllActivityAndSubActivity() async {
    try {
      String url = "${Constants.BASE_URL}${ApiEndPoints().getAllActivity}PageStart=0&ResultPerPage=10000&SeachQuery";
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

  Future coachProviderRegister(Map coachProviderRequest) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().coachProviderRegister;
      // print(url);
      var uri = Uri.parse(url);
      var body = json.encode(coachProviderRequest);
      // print(body);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        // 'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}',
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

  Future facilityProfileUpdate(Map request) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().facilityProviderRegister;
      debugPrint(url);
      var uri = Uri.parse(url);
      var body = json.encode(request);
      debugPrint(body);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}',
      };
      var response = await http.put(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
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

  Future deleteEndUserAddress(Map<String, dynamic> request) async {
    try {
      var url = Constants.BASE_URL + ApiEndPoints().addEditDelteEndUserAddress;
      debugPrint('URL -> $url');
      var uri = Uri.parse(url);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      var body = json.encode(request);
      debugPrint(body);
      var response = await http.delete(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
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

  Future getCoachTrainingCenter(String coachId) async {
    try {
      var url = Constants.BASE_URL + ApiEndPoints().getCoachTrainingAddress + coachId;
      debugPrint("getCoachTrainingCenter -> URL$url");
      var uri = Uri.parse(url);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}',
      };
      var response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      debugPrint("getCoachTrainingCenter -> response${response.body}");
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

  Future deleteCoachAddress(Map<String, dynamic> request) async {
    try {
      var url = Constants.BASE_URL + ApiEndPoints().addCoachTrainingAddress;
      debugPrint('URL -> $url');
      var uri = Uri.parse(url);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      var body = json.encode(request);
      debugPrint(body);
      var response = await http.put(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
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

  Future endUserProfileUpdate(Map request) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().endUserRegister;
      debugPrint(url);
      var uri = Uri.parse(url);
      var body = json.encode(request);
      debugPrint(body);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}',
      };
      var response = await http.put(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
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

  Future changePassword(Map request) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().changePassword;
      debugPrint(url);
      var uri = Uri.parse(url);
      var body = json.encode(request);
      debugPrint(body);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}',
      };
      var response = await http.put(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
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

  Future getNotification(String endUrl) async {
    try {
      String url = '${Constants.BASE_URL}${ApiEndPoints().getNotification}$endUrl';
      debugPrint(url);
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

  Future getTransactionList(String endUrl) async {
    try {
      String url = '${Constants.BASE_URL}${ApiEndPoints().getTransactionList}$endUrl';
      debugPrint(url);
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

  Future getRefundList(String endUrl) async {
    try {
      String url = '${Constants.BASE_URL}${ApiEndPoints().geRefundList}$endUrl';
      debugPrint(url);
      var uri = Uri.parse(url);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}',
      };
      var response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 180));
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

  Future logout(String userId) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().logout + userId;
      debugPrint(url);
      var uri = Uri.parse(url);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}',
      };
      var response = await http.delete(uri, headers: headers).timeout(const Duration(seconds: 10));
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

  Future endUserAccountClose(Map requets) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().endUserAccountClose;
      debugPrint(url);
      var uri = Uri.parse(url);
      var body = json.encode(requets);
      debugPrint(body);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
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

  Future facilityUserAccountClose(Map requets) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().facilityUserAccountClose;
      debugPrint(url);
      var uri = Uri.parse(url);
      var body = json.encode(requets);
      debugPrint(body);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
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

  Future coachUserAccountClose(Map requets) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().coachUserAccountClose;
      debugPrint(url);
      var uri = Uri.parse(url);
      var body = json.encode(requets);
      debugPrint(body);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
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

  Future multipleUploadImage(List<Map<String, dynamic>> uploadImageData) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().multipleUploadImage;
      // print(url);
      var uri = Uri.parse(url);
      var body = json.encode(uploadImageData);
      // print(body);
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

  Future deleteSingleNotification(String notificationId) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().deleteSingleNotification + notificationId;
      var uri = Uri.parse(url);
      debugPrint('URL - > $url');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
      };
      var response = await http.delete(uri, headers: headers).timeout(const Duration(seconds: 10));
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

  Future deleteAllNotifications(String userId) async {
    try {
      String url = Constants.BASE_URL + ApiEndPoints().deleteAllNotification + userId;
      var uri = Uri.parse(url);
      debugPrint('URL - > $url');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
      };
      var response = await http.delete(uri, headers: headers).timeout(const Duration(seconds: 10));
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
