import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/repository/booking_repository/BookingRepository.dart';

class BookingViewModel extends ChangeNotifier {
  final BookingRepository bookingRepository = BookingRepository();

  Future getAllFacilities(String value) async {
    try {
      var response = await bookingRepository.getAllFacilities(value);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future getFacilityById(int facilitySetupId) async {
    try {
      var response = await bookingRepository.getFacilityById(facilitySetupId);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future getCoaches(String value) async {
    try {
      var response = await bookingRepository.getCoaches(value);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future getCoachDetailsById(int coachSetupId) async {
    try {
      var response = await bookingRepository.getCoachDetailsById(coachSetupId.toString());
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future getAllActivity() async {
    try {
      var response = await bookingRepository.getAllActivityAndSubActivity();
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future getEndUserAddress(String userId) async {
    try {
      var response = await bookingRepository.getEndUserAddress(userId);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future addFavorite(Map<String, dynamic> request) async {
    try {
      var response = await bookingRepository.addFavorite(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future getFavoriteFacilities(String request) async {
    try {
      var response = await bookingRepository.getFavoriteFacilities(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future getFavoriteCoach(String request) async {
    try {
      var response = await bookingRepository.getFavoriteCoach(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }
}
