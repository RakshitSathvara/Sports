import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/model/cancel_reason_list_response_model.dart';
import 'package:oqdo_mobile_app/model/coach_appointment_details_response_model.dart';
import 'package:oqdo_mobile_app/model/coach_appointments_response_model.dart';
import 'package:oqdo_mobile_app/model/coach_cancel_appointment_virify_response_model.dart';
import 'package:oqdo_mobile_app/model/coach_cancel_slot_response_model.dart';
import 'package:oqdo_mobile_app/model/end_user_appoinments_model.dart';
import 'package:oqdo_mobile_app/model/facility_appointment_details_model.dart';
import 'package:oqdo_mobile_app/model/facility_appointment_resopnse_model.dart';
import 'package:oqdo_mobile_app/model/facility_cancel_appointment_verify_response_model.dart';
import 'package:oqdo_mobile_app/repository/appointment_repository.dart';
import 'package:oqdo_mobile_app/repository/facility_slot_cancel_response_model.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/meetups/data/meetup_response_model.dart';

class AppointmentViewModel extends ChangeNotifier {
  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  Future<List<EndUserAppointmentsResponseModel>> getEndUserAppointments(String endUserId, String date, String endDate) async {
    try {
      var response = await _appointmentRepository.getEndUserAppointments(endUserId, date, endDate);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<List<FacilityAppointmentsResponseModel>> getFacilityProviderAppointments(String facilityId, String date, String lastDate) async {
    try {
      var response = await _appointmentRepository.getFacilityProviderAppointments(facilityId, date, lastDate);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<List<CoachAppointmentsResponseModel>> getCoachProviderAppointments(String coachId, String date, String lastDate) async {
    try {
      var response = await _appointmentRepository.getCoachProviderAppointments(coachId, date, lastDate);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<FacilityAppointmentDetailModel> getFacilityAppointmentDetail(String bookingId) async {
    try {
      var response = await _appointmentRepository.getFacilityAppointmentDetails(bookingId);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<CoachAppointmentDetailResponseModel> getCoachAppointmentDetail(String bookingId) async {
    try {
      var response = await _appointmentRepository.getCoachAppointmentDetails(bookingId);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<List<CancelReasonListResponseModel>> getCancelReasonList() async {
    try {
      var response = await _appointmentRepository.getCancelReasonList();
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<List<FacilitySlotCancelResponseModel>> facilitySlotCancelRequest(Map<String, dynamic> request) async {
    try {
      var response = await _appointmentRepository.facilityCancelApiCall(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<List<CoachSlotCancelResponseModel>> coachSlotCancelRequest(Map<String, dynamic> request) async {
    try {
      var response = await _appointmentRepository.coachCancelApiCall(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<String> coachAddReviewRequest(Map<String, dynamic> request) async {
    try {
      var response = await _appointmentRepository.addCoachReview(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<String> coachEditReviewRequest(Map<String, dynamic> request) async {
    try {
      var response = await _appointmentRepository.editCoachReview(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<String> facilityAddReviewRequest(Map<String, dynamic> request) async {
    try {
      var response = await _appointmentRepository.addFacilityReview(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<String> facilityEditReviewRequest(Map<String, dynamic> request) async {
    try {
      var response = await _appointmentRepository.editFacilityReview(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<String> facilityCancelAppointmentRequest(Map<String, dynamic> request) async {
    try {
      var response = await _appointmentRepository.facilityAppointmentCancel(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<String> coachCancelAppointmentRequest(Map<String, dynamic> request) async {
    try {
      var response = await _appointmentRepository.coachAppointmentCancel(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<FacilityCancelAppointmentVerificationResponseModel> verifyFacilityCancelAppointmentCancel(Map<String, dynamic> request) async {
    try {
      var response = await _appointmentRepository.verifyFacilityCancelAppointmentCancel(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<CoachCancelAppointmentVerificationResponseModel> verifyCoachCancelAppointmentCancel(Map<String, dynamic> request) async {
    try {
      var response = await _appointmentRepository.verifyCoachCancelAppointmentCancel(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<MeetupResponseModel> getAllMeetupList(String fromDate, String toDate) async {
    try {
      var response = await _appointmentRepository.getAllMeetup(fromDate, toDate);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }
}
