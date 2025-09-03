import 'package:flutter/foundation.dart';

class NotificationProvider extends ChangeNotifier {
  bool isNewNotification = false;

  void updateStatus(bool newStatus) {
    isNewNotification = newStatus;
    notifyListeners();
  }

  bool getNotification() {
    return isNewNotification;
  }
}
