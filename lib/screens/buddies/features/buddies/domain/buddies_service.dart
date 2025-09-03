import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oqdo_mobile_app/data/remote/network/api_end_points.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/create_group_response.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/friend_chat_response.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/get_all_buddies_response_model.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/get_conversation_list_response.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/group_chat_response.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/group_list_response.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';

class BuddiesService {
  final networkInterceptor = NetworkConnectionInterceptor();

  Future<GetAllBuddiesResponseModel> getAllBuddiesList(String endUrl) async {
    String url = '${Constants.BASE_URL}${ApiEndPoints().getAllBuddiesList}$endUrl';
    showLog('$urlTag $url');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var uri = Uri.parse(url);
      var response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      showLog('$responseTag ${response.body}');
      if (response.statusCode == 200) {
        GetAllBuddiesResponseModel getAllBuddiesResponseModel = GetAllBuddiesResponseModel.fromJson(jsonDecode(response.body));
        return getAllBuddiesResponseModel;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<GroupListResponse?> getAllGroups(String endUrl) async {
    String url = '${Constants.BASE_URL}${ApiEndPoints().getAllGroups}$endUrl';
    showLog('$urlTag $url');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        GroupListResponse groupListResponse = GroupListResponse.fromJson(jsonDecode(response.body));
        return groupListResponse;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<GetAllBuddiesResponseModel> getAllFriendsList(String endUrl) async {
    String url = '${Constants.BASE_URL}${ApiEndPoints().getAllFriendsList}$endUrl';
    showLog('$urlTag $url');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      showLog('$responseTag ${response.body}');
      if (response.statusCode == 200) {
        GetAllBuddiesResponseModel getAllFriendsResponse = GetAllBuddiesResponseModel.fromJson(jsonDecode(response.body));
        return getAllFriendsResponse;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<GetConversationListResponse?> getConversationList(String endUrl) async {
    String url = '${Constants.BASE_URL}${ApiEndPoints().getConversationList}$endUrl';
    showLog('$urlTag $url');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        GetConversationListResponse getConversationListResponse = GetConversationListResponse.fromJson(jsonDecode(response.body));
        return getConversationListResponse;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<FriendChatResponse?> getFriendChatList(String endUrl) async {
    String url = '${Constants.BASE_URL}${ApiEndPoints().getFriendChatList}$endUrl';
    showLog('$urlTag $url');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        FriendChatResponse friendChatResponse = FriendChatResponse.fromJson(jsonDecode(response.body));
        return friendChatResponse;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<dynamic> getFriendOnline(String endUrl) async {
    String url = '${Constants.BASE_URL}${ApiEndPoints().getFriendOnline}$endUrl';
    showLog('$urlTag $url');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<GroupChatResponse?> getGroupChatList(String endUrl) async {
    String url = '${Constants.BASE_URL}${ApiEndPoints().getGroupChatList}$endUrl';
    showLog('$urlTag $url');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        GroupChatResponse groupChatResponse = GroupChatResponse.fromJson(jsonDecode(response.body));
        return groupChatResponse;
      }
    } else {
      throw NoConnectivityException();
    }
    return null;
  }

  Future<GetAllBuddiesResponseModel> getAllPendingFriendsList(String endUrl) async {
    String url = '${Constants.BASE_URL}${ApiEndPoints().getAllPendingFriendsList}$endUrl';
    showLog('$urlTag $url');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      showLog('$responseTag ${response.body}');
      if (response.statusCode == 200) {
        GetAllBuddiesResponseModel getAllFriendsResponse = GetAllBuddiesResponseModel.fromJson(jsonDecode(response.body));
        return getAllFriendsResponse;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<CreateGroupResponse?> createGroup(Map data) async {
    String url = '${Constants.BASE_URL}${ApiEndPoints().createGroup}';
    showLog('$urlTag $url');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        CreateGroupResponse createGroupResponse = CreateGroupResponse.fromJson(jsonDecode(response.body));
        return createGroupResponse;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<bool?> editGroup(Map data) async {
    String url = '${Constants.BASE_URL}${ApiEndPoints().createGroup}';
    showLog('$urlTag $url');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http
          .put(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return true;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<int> sendFriendRequest(Map<String, dynamic> request) async {
    String url = '${Constants.BASE_URL}${ApiEndPoints().sendFriendRequest}';
    showLog('$urlTag $url');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(request),
          )
          .timeout(const Duration(seconds: 10));
      showLog('$responseTag ${response.body}');
      if (response.statusCode == 200) {
        return int.parse(response.body);
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<String> acceptRejectRequestCall(Map<String, dynamic> request) async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().acceptRejectFriendRequest}';
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
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }
}
