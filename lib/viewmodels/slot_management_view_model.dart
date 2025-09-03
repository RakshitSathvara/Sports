import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/model/available_slots_by_date_response_model.dart';
import 'package:oqdo_mobile_app/model/coach_available_slots_by_date_response_model.dart';
import 'package:oqdo_mobile_app/model/coach_booking_list_response_model.dart';
import 'package:oqdo_mobile_app/model/coach_booking_response.dart';
import 'package:oqdo_mobile_app/model/coach_get_21_days_slot_response_model.dart';
import 'package:oqdo_mobile_app/model/facility_booking_list_response_model.dart';
import 'package:oqdo_mobile_app/model/facility_booking_response.dart';
import 'package:oqdo_mobile_app/model/freeze_coach_response_model.dart';
import 'package:oqdo_mobile_app/model/freeze_facility_response_model.dart';
import 'package:oqdo_mobile_app/model/get_21_days_slot_response_model.dart';
import 'package:oqdo_mobile_app/repository/slot_management_repository.dart';
import 'package:oqdo_mobile_app/screens/appointment/response/referral_coupon_response_model.dart';

class SlotManagementViewModel extends ChangeNotifier {
  final SlotManagementRepository _slotManagementRepository = SlotManagementRepository();

  Future<List<Get21DaysSlotResponseModel>> get21DaysFacilitySlots(int facilityId, String selectedDate, String passingLastDate) async {
    try {
      var response = await _slotManagementRepository.get21DaysFacilitySlots(facilityId, selectedDate, passingLastDate);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<List<AvailableSlotsByDateResponseModel>> getFacilityAvailableSlotsByDate(int facilityId, String selectedDate) async {
    try {
      var response = await _slotManagementRepository.getFacilityAvailableSlotsByDate(facilityId, selectedDate);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<List<CoachGet21DaysSlotResponseModel>> getCoach21DaysFacilitySlots(int facilityId, String selectedDate, String passingLastDate) async {
    try {
      var response = await _slotManagementRepository.getCoach21DaysFacilitySlots(facilityId, selectedDate, passingLastDate);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<List<CoachAvailableSlotsByDateResponseModel>> getCoachAvailableSlotsByDate(int facilityId, String selectedDate) async {
    try {
      var response = await _slotManagementRepository.getCoachAvailableSlotsByDate(facilityId, selectedDate);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<FreezeFacilityResponseModel> freezeFacilityBooking(Map<String, dynamic> request) async {
    try {
      var response = await _slotManagementRepository.freezeFacilityBooking(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<FreezeCoachResponseModel> freezeCoachBooking(Map<String, dynamic> request) async {
    try {
      var response = await _slotManagementRepository.freezeCoachBooking(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<FreezeFacilityResponseModel> unFreezeFacilityBooking(Map<String, dynamic> request) async {
    try {
      var response = await _slotManagementRepository.unFreezeFacilityBooking(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> unFreezeFacilityBookingList(List<Map<String, dynamic>> request) async {
    try {
      var response = await _slotManagementRepository.unFreezeFacilityBookingList(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<FreezeCoachResponseModel> unFreezeCoachBooking(Map<String, dynamic> request) async {
    try {
      var response = await _slotManagementRepository.unFreezeCoachBooking(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<FacilityBookingListModelResponse> getFreezeBooking(String orderId) async {
    try {
      var response = await _slotManagementRepository.getFreezeBooking(orderId);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> unFreezeCoachBookingBulk(List<Map<String, dynamic>> request) async {
    try {
      var response = await _slotManagementRepository.unFreezeCoachBookingBulk(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<CoachBookingListModelResponse> getCoachFreezeBooking(String orderId) async {
    try {
      var response = await _slotManagementRepository.getFreezeCoachBooking(orderId);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<FacilityBookingResponse> facilitySlotBooking(Map<String, dynamic> request) async {
    try {
      var response = await _slotManagementRepository.facilitySlotBooking(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<CoachBookingResponse> coachSlotBooking(Map<String, dynamic> request) async {
    try {
      var response = await _slotManagementRepository.coachSlotBooking(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> successCoachBooking(Map<String, dynamic> request) async {
    try {
      var response = await _slotManagementRepository.successCoachBooking(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> failedCoachBooking(Map<String, dynamic> request) async {
    try {
      var response = await _slotManagementRepository.failedCoachBooking(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> successFacilityBooking(Map<String, dynamic> request) async {
    try {
      var response = await _slotManagementRepository.successFacilityBooking(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> failedFacilityBooking(Map<String, dynamic> request) async {
    try {
      var response = await _slotManagementRepository.failedFacilityBooking(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<List<ReferralActivityData>> getReferralCoupons() async {
    try {
      var response = await _slotManagementRepository.getReferralCoupons();
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> validateFacilityPaymentActivity(Map<String, dynamic> request) async {
    try {
      var response = await _slotManagementRepository.validateFacilityPaymentActivity(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> validateCoachPaymentActivity(Map<String, dynamic> request) async {
    try {
      var response = await _slotManagementRepository.validateCoachPaymentActivity(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }
}
