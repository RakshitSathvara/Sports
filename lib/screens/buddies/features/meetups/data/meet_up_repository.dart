import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/meetups/data/friend_list_repsonse_model.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/meetups/data/meetup_response_model.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/meetups/domain/meetup_service.dart';


class MeetupRepository extends ChangeNotifier {
  final MeetupService _meetupService = MeetupService();

  Future<MeetupResponseModel> getAllMeetupList(String fromDate, String toDate) async {
    try {
      var response = await _meetupService.getAllMeetup(fromDate, toDate);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future<String> acceptRejectRequest(Map<String, dynamic> request) async {
    try {
      var response = await _meetupService.acceptRejectRequestCall(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future<String> deleteMeetup(Map<String, dynamic> request) async {
    try {
      var response = await _meetupService.deleteMeetup(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future<FriendListResponseModel> getFriendList() async {
    try {
      var response = await _meetupService.getFriendList();
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future<String> addMeetup(Map<String, dynamic> request) async {
    try {
      var response = await _meetupService.addMeetupCall(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }
}
