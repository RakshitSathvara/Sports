import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/repository/profile_repository/profile_repository_impl.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepositoryImpl _profileRepositoryImpl = ProfileRepositoryImpl();

  String? userName;

  void setUserName(String name) {
    userName = name;
    notifyListeners();
  }

  Future getEndUserProfile(String endUserId) async {
    try {
      var response = await _profileRepositoryImpl.getEndUserProfile(endUserId);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future getFacilityUserProfile(String facilityUserId) async {
    try {
      var response = await _profileRepositoryImpl.getFacilityUserProfile(facilityUserId);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future getCoachUserProfile(String coachUserId) async {
    try {
      var response = await _profileRepositoryImpl.getCoachUserProfile(coachUserId);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future uploadFile(Map uploadRequest) async {
    try {
      var response = await _profileRepositoryImpl.uploadImage(uploadRequest);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future getAllActivity() async {
    try {
      var response = await _profileRepositoryImpl.getAllActivityAndSubActivity();
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future coachProviderRegister(Map request) async {
    try {
      var response = await _profileRepositoryImpl.coachProviderRegister(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future facilityProfileUpdate(Map request) async {
    try {
      var response = await _profileRepositoryImpl.facilityProfileUpdate(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future getEndUserAddress(String userId) async {
    try {
      var response = await _profileRepositoryImpl.getEndUserAddress(userId);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future deleteEndUserAddress(Map<String, dynamic> request) async {
    try {
      var response = await _profileRepositoryImpl.deleteEndUserAddress(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future deleteCoachAddress(Map<String, dynamic> request) async {
    try {
      var response = await _profileRepositoryImpl.deleteCoachAddress(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future getCoachTrainingAddress(String coachID) async {
    try {
      var response = await _profileRepositoryImpl.getCoachTrainingCenter(coachID);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future endUserProfileUpdate(Map request) async {
    try {
      var response = await _profileRepositoryImpl.endUserProfileUpdate(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future changePassword(Map request) async {
    try {
      var response = await _profileRepositoryImpl.changePassword(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future getNotification(String endUrl) async {
    try {
      var list = await _profileRepositoryImpl.getNotification(endUrl);
      notifyListeners();
      return Future.value(list);
    } catch (error) {
      rethrow;
    }
  }

  Future getTransactionList(String endUrl) async {
    try {
      var response = await _profileRepositoryImpl.getTransactionList(endUrl);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future getRefundList(String endUrl) async {
    try {
      var response = await _profileRepositoryImpl.getRefundList(endUrl);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future logout(String userID) async {
    try {
      var response = await _profileRepositoryImpl.logout(userID);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future endUserAccountClose(Map<String, dynamic> request) async {
    try {
      var response = await _profileRepositoryImpl.endUserAccountClose(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future facilityUserAccountClose(Map<String, dynamic> request) async {
    try {
      var response = await _profileRepositoryImpl.facilityUserAccountClose(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future coachUserAccountClose(Map<String, dynamic> request) async {
    try {
      var response = await _profileRepositoryImpl.coachUserAccountClose(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future multipleUploadFile(List<Map<String, dynamic>> uploadRequest) async {
    try {
      var response = await _profileRepositoryImpl.multipleUploadImage(uploadRequest);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future deleteSingleNotification(String notificationID) async {
    try {
      var response = await _profileRepositoryImpl.deleteSingleNotification(notificationID);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future deleteAllNotifications(String userId) async {
    try {
      var response = await _profileRepositoryImpl.deleteAllNotifications(userId);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }
}
