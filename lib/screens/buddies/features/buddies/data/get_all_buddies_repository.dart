import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/create_group_response.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/friend_chat_response.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/get_all_buddies_response_model.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/get_conversation_list_response.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/group_chat_response.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/group_list_response.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/domain/buddies_service.dart';

class GetAllBuddiesReposotory extends ChangeNotifier {
  final BuddiesService _buddiesService = BuddiesService();

  Future<GetAllBuddiesResponseModel> getAllBuddiesList(String endUrl) async {
    try {
      var response = await _buddiesService.getAllBuddiesList(endUrl);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<GroupListResponse> getAllGroupList(String endUrl) async {
    try {
      var response = await _buddiesService.getAllGroups(endUrl);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<GetAllBuddiesResponseModel> getAllFriendsList(String endUrl) async {
    try {
      var response = await _buddiesService.getAllFriendsList(endUrl);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<GetAllBuddiesResponseModel> getAllPendingFriendsList(
      String endUrl) async {
    try {
      var response = await _buddiesService.getAllPendingFriendsList(endUrl);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<CreateGroupResponse?> createGroup(Map data) async {
    try {
      var response = await _buddiesService.createGroup(data);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<bool?> editGroup(Map data) async {
    try {
      var response = await _buddiesService.editGroup(data);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<int> sendFriendRequest(Map<String, dynamic> request) async {
    try {
      var response = await _buddiesService.sendFriendRequest(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<String> acceptRejectRequest(Map<String, dynamic> request) async {
    try {
      var response = await _buddiesService.acceptRejectRequestCall(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<GetConversationListResponse> getConversationList(String endUrl) async {
    try {
      var response = await _buddiesService.getConversationList(endUrl);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<FriendChatResponse> getFriendChatList(String endUrl) async {
    try {
      var response = await _buddiesService.getFriendChatList(endUrl);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<GroupChatResponse> getGroupChatList(String endUrl) async {
    try {
      var response = await _buddiesService.getGroupChatList(endUrl);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> getFriendOnline(String endUrl) async {
    try {
      var response = await _buddiesService.getFriendOnline(endUrl);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }


}
