import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/screens/bazaar/chats/chat_repository.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();

  Future getChatDetails(Map<String, dynamic> request) async {
    try {
      var response = await _chatRepository.getChatDetails(request); // updated to use _chatRepository
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future getUserDetails(String userId) async {
    try {
      var response = await _chatRepository.getUserDetails(userId); // updated to use _chatRepository
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future getChatList(Map<String, dynamic> request) async {
    try {
      var response = await _chatRepository.getChatList(request); // updated to use _chatRepository
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future deleteChat(Map<String, dynamic> request) async {
    try {
      var response = await _chatRepository.deleteChat(request); // updated to use _chatRepository
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }
}
