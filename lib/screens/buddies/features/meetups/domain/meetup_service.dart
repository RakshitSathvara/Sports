import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/data/remote/network/api_end_points.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/meetups/data/friend_list_repsonse_model.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/meetups/data/meetup_response_model.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:http/http.dart' as http;

class MeetupService {
  final networkInterceptor = NetworkConnectionInterceptor();

  Future<String> addMeetupCall(Map<String, dynamic> request) async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().addMeetup}';
    debugPrint('$urlTag $url');
    var uri = Uri.parse(url);
    var body = json.encode(request);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    debugPrint('$requestTag $body');
    if (await networkInterceptor.isConnected()) {
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag addMeetupCall -> ${response.body}');
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<MeetupResponseModel> getAllMeetup(String fromDate, String toDate) async {
    String url =
        '${Constants.BASE_URL}${ApiEndPoints().getAllMeetup}${OQDOApplication.instance.endUserID}&FromDate=$fromDate&ToDate=$toDate&DateWiseResponse=true';
    showLog('$urlTag $url');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        MeetupResponseModel meetupResponseModel = MeetupResponseModel.fromJson(jsonDecode(response.body));
        return meetupResponseModel;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<String> acceptRejectRequestCall(Map<String, dynamic> request) async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().acceptRejectMeetup}';
    debugPrint('$urlTag $url');
    var uri = Uri.parse(url);
    var body = json.encode(request);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    debugPrint('$requestTag $body');
    if (await networkInterceptor.isConnected()) {
      var response = await http.put(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag acceptRejectMeetup -> ${response.body}');
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<String> deleteMeetup(Map<String, dynamic> request) async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().deleteMeetup}';
    debugPrint('$urlTag $url');
    var uri = Uri.parse(url);
    var body = json.encode(request);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    debugPrint('$requestTag $body');
    if (await networkInterceptor.isConnected()) {
      var response = await http.delete(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag deleteMeetup -> ${response.body}');
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<FriendListResponseModel> getFriendList() async {
    String url = '${Constants.BASE_URL}${ApiEndPoints().getFriendList}${OQDOApplication.instance.endUserID}';
    showLog('$urlTag $url');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        FriendListResponseModel friendListResponseModel = FriendListResponseModel.fromJson(jsonDecode(response.body));
        return friendListResponseModel;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }
}
