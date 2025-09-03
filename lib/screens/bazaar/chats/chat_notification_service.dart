import 'package:flutter/foundation.dart';

// A simple service to manage chat notifications across tabs
class ChatNotificationService extends ChangeNotifier {
  // Singleton instance
  static final ChatNotificationService _instance = ChatNotificationService._internal();

  factory ChatNotificationService() {
    return _instance;
  }

  ChatNotificationService._internal();

  // Map to store notification status by chat ID
  final Map<int, bool> _unreadChats = {};

  // Set a chat as having a new message
  void setUnread(int chatId, bool isUnread) {
    _unreadChats[chatId] = isUnread;
    debugPrint('Chat $chatId marked as ${isUnread ? "unread" : "read"}');
    notifyListeners();
  }

  // Check if a chat has unread messages
  bool isUnread(int chatId) {
    return _unreadChats[chatId] ?? false;
  }

  // Mark all chats as read
  void markAllAsRead() {
    _unreadChats.clear();
    notifyListeners();
  }

  // Mark specific chats as read
  void markAsRead(List<int> chatIds) {
    for (var chatId in chatIds) {
      _unreadChats.remove(chatId);
    }
    notifyListeners();
  }

  // Get all unread chat IDs
  List<int> getAllUnreadChats() {
    return _unreadChats.entries.where((entry) => entry.value).map((entry) => entry.key).toList();
  }
}
