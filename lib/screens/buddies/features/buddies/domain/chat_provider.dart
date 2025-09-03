import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/friend_chat_response.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/group_chat_response.dart';

class ChatProvider extends ChangeNotifier {
  FriendMessage? receivedFriendMessage; // trigger from list , listern in chat
  GroupMessage? receivedGroupMessage; // trigger from list , listern in chat
  Object? sendMessage; // trigger from chant, listen in list

  List<Object>? sendFrndMessageArgs;
  List<Object>? sendGroupMessageArgs;
  bool isSending = false;

  String? userName = '';
  String? _profileImagePathStr = '';
  String? get profileImagePathStr => _profileImagePathStr;

  void setUserName(String name) {
    userName = name;
    notifyListeners();
  }

  void setProfileImagePath(String path) {
    _profileImagePathStr = path;
    notifyListeners();
  }

  // friend
  void receivedNewMsgFromFriend(FriendMessage newMsg) {
    receivedFriendMessage = newMsg;
    notifyListeners();
  }

  void sendNewMsgToFriend(msg) {
    isSending = true;
    sendFrndMessageArgs = msg;
    notifyListeners();
  }

  // group
  void receivedNewMsgFromGroup(GroupMessage newMsg) {
    receivedGroupMessage = newMsg;
    notifyListeners();
  }

  void sendNewMsgToGroup(msg) {
    isSending = true;
    sendGroupMessageArgs = msg;
    notifyListeners();
  }

  void resetNewMessage() {
    receivedFriendMessage = null;
    receivedGroupMessage = null;
  }

  void notifyChanges() {
    notifyListeners();
  }
}
