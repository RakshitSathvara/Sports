import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oqdo_mobile_app/data/remote/network/api_end_points.dart';
import 'package:oqdo_mobile_app/model/cancel_reason_list_response_model.dart';
import 'package:oqdo_mobile_app/model/coach_appointment_details_response_model.dart';
import 'package:oqdo_mobile_app/model/coach_appointments_response_model.dart';
import 'package:oqdo_mobile_app/model/coach_cancel_appointment_virify_response_model.dart';
import 'package:oqdo_mobile_app/model/coach_cancel_slot_response_model.dart';
import 'package:oqdo_mobile_app/model/end_user_appoinments_model.dart';
import 'package:oqdo_mobile_app/model/facility_appointment_details_model.dart';
import 'package:oqdo_mobile_app/model/facility_appointment_resopnse_model.dart';
import 'package:oqdo_mobile_app/model/facility_cancel_appointment_verify_response_model.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/repository/facility_slot_cancel_response_model.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/meetups/data/meetup_response_model.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';

class AppointmentRepository {
  final networkInterceptor = NetworkConnectionInterceptor();

  Future<List<EndUserAppointmentsResponseModel>> getEndUserAppointments(String endUserId, String date, String endDate) async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().getEndUserBookedAppointment}endUserId=$endUserId&selectedDate=$date&endDate=$endDate';
    debugPrint('$urlTag $url');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag ${response.body}');
      if (response.statusCode == 200) {
        List body = jsonDecode(response.body);
        List<EndUserAppointmentsResponseModel> list = [];
        for (int i = 0; i < body.length; i++) {
          EndUserAppointmentsResponseModel endUserAppointmentsResponseModel = EndUserAppointmentsResponseModel.fromJson(body[i]);
          list.add(endUserAppointmentsResponseModel);
        }
        return list;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<List<FacilityAppointmentsResponseModel>> getFacilityProviderAppointments(String facilityId, String date, String endDate) async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().getFacilityBookedAppointment}facilityId=$facilityId&selectedDate=$date&endDate=$endDate';
    debugPrint('$urlTag $url');
    var headers = {'Content-Type': 'application/json', 'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'};
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag $response');
      if (response.statusCode == 200) {
        List body = jsonDecode(response.body);
        List<FacilityAppointmentsResponseModel> list = [];
        for (int i = 0; i < body.length; i++) {
          FacilityAppointmentsResponseModel facilityAppointmentsResponseModel = FacilityAppointmentsResponseModel.fromJson(body[i]);
          list.add(facilityAppointmentsResponseModel);
        }
        return list;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<List<CoachAppointmentsResponseModel>> getCoachProviderAppointments(String coachId, String date, String lastDate) async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().getCoachBookedAppointment}coachId=$coachId&selectedDate=$date&endDate=$lastDate';
    debugPrint('$urlTag $url');
    var headers = {'Content-Type': 'application/json', 'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'};
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag $response');
      if (response.statusCode == 200) {
        List body = jsonDecode(response.body);
        List<CoachAppointmentsResponseModel> list = [];
        for (int i = 0; i < body.length; i++) {
          CoachAppointmentsResponseModel coachAppointmentsResponseModel = CoachAppointmentsResponseModel.fromJson(body[i]);
          list.add(coachAppointmentsResponseModel);
        }
        return list;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<FacilityAppointmentDetailModel> getFacilityAppointmentDetails(String bookingId) async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().getFacilityAppointmentDetails}$bookingId';
    debugPrint('$urlTag $url');
    var headers = {'Content-Type': 'application/json', 'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'};
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag $response');
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        FacilityAppointmentDetailModel facilityAppointmentDetailModel = FacilityAppointmentDetailModel.fromJson(body);
        return facilityAppointmentDetailModel;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<CoachAppointmentDetailResponseModel> getCoachAppointmentDetails(String bookingId) async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().getCoachAppointmentDetails}$bookingId';
    debugPrint('$urlTag $url');
    var headers = {'Content-Type': 'application/json', 'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'};
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag $response');
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        CoachAppointmentDetailResponseModel coachAppointmentDetailModel = CoachAppointmentDetailResponseModel.fromJson(body);
        return coachAppointmentDetailModel;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<List<CancelReasonListResponseModel>> getCancelReasonList() async {
    String url = Constants.BASE_URL + ApiEndPoints().getCancelReasonList;
    debugPrint('URL -> $url');
    var headers = {'Content-Type': 'application/json', 'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'};
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      debugPrint(response.body);
      if (response.statusCode == 200) {
        List body = jsonDecode(response.body);
        debugPrint('debugprint -> $body');
        List<CancelReasonListResponseModel> list = [];
        for (int i = 0; i < body.length; i++) {
          CancelReasonListResponseModel availableSlotsByDateResponseModel = CancelReasonListResponseModel.fromJson(body[i]);
          list.add(availableSlotsByDateResponseModel);
        }
        return list;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<List<FacilitySlotCancelResponseModel>> facilityCancelApiCall(Map<String, dynamic> request) async {
    String url = Constants.BASE_URL + ApiEndPoints().facilityCancelApiCall;
    debugPrint(url);
    var uri = Uri.parse(url);
    var body = json.encode(request);
    debugPrint(body);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        List body = jsonDecode(response.body);
        List<FacilitySlotCancelResponseModel> list = [];
        for (int i = 0; i < body.length; i++) {
          FacilitySlotCancelResponseModel facilitySlotCancelResponseModel = FacilitySlotCancelResponseModel.fromJson(body[i]);
          list.add(facilitySlotCancelResponseModel);
        }
        return list;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<List<CoachSlotCancelResponseModel>> coachCancelApiCall(Map<String, dynamic> request) async {
    String url = Constants.BASE_URL + ApiEndPoints().coachCancelApiCall;
    debugPrint(url);
    var uri = Uri.parse(url);
    var body = json.encode(request);
    debugPrint(body);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        List body = jsonDecode(response.body);
        List<CoachSlotCancelResponseModel> list = [];
        for (int i = 0; i < body.length; i++) {
          CoachSlotCancelResponseModel coachSlotCancelResponseModel = CoachSlotCancelResponseModel.fromJson(body[i]);
          list.add(coachSlotCancelResponseModel);
        }
        return list;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<String> addCoachReview(Map<String, dynamic> request) async {
    String url = Constants.BASE_URL + ApiEndPoints().coachAddReview;
    debugPrint(url);
    var uri = Uri.parse(url);
    var body = json.encode(request);
    debugPrint(body);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag -> $response');
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<String> editCoachReview(Map<String, dynamic> request) async {
    String url = Constants.BASE_URL + ApiEndPoints().coachAddReview;
    debugPrint(url);
    var uri = Uri.parse(url);
    var body = json.encode(request);
    debugPrint(body);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.put(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag -> $response');
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<String> addFacilityReview(Map<String, dynamic> request) async {
    String url = Constants.BASE_URL + ApiEndPoints().facilityAddReview;
    debugPrint(url);
    var uri = Uri.parse(url);
    var body = json.encode(request);
    debugPrint(body);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag -> $response');
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<String> editFacilityReview(Map<String, dynamic> request) async {
    String url = Constants.BASE_URL + ApiEndPoints().facilityAddReview;
    debugPrint(url);
    var uri = Uri.parse(url);
    var body = json.encode(request);
    debugPrint(body);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.put(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag -> $response');
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<String> facilityAppointmentCancel(Map<String, dynamic> request) async {
    String url = Constants.BASE_URL + ApiEndPoints().facilityEndUserCancelAppointment;
    debugPrint(url);
    var uri = Uri.parse(url);
    var body = json.encode(request);
    debugPrint(body);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.delete(uri, headers: headers, body: body).timeout(const Duration(seconds: 60));
      debugPrint('$responseTag -> $response');
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<String> coachAppointmentCancel(Map<String, dynamic> request) async {
    String url = Constants.BASE_URL + ApiEndPoints().coachEndUserCancelAppointment;
    debugPrint(url);
    var uri = Uri.parse(url);
    var body = json.encode(request);
    debugPrint(body);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.delete(uri, headers: headers, body: body).timeout(const Duration(seconds: 60));
      debugPrint('$responseTag -> $response');
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<FacilityCancelAppointmentVerificationResponseModel> verifyFacilityCancelAppointmentCancel(Map<String, dynamic> requestMap) async {
    String url = Constants.BASE_URL + ApiEndPoints().verifyFacilityCancelAppointment;
    showLog(url);
    var headers = {
      'Content-Type': 'application/json',
    };
    if (await networkInterceptor.isConnected()) {
      var request = http.Request('GET', Uri.parse(url));
      request.body = json.encode(requestMap);
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send().timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        String data = await response.stream.bytesToString();
        var responseData = json.decode(data);
        showLog('responseData -> $responseData');
        FacilityCancelAppointmentVerificationResponseModel facilityCancelAppointmentVerificationResponseModel =
            FacilityCancelAppointmentVerificationResponseModel.fromJson(responseData);
        return facilityCancelAppointmentVerificationResponseModel;
      } else {
        throw CommonException(code: response.statusCode, message: response.stream.bytesToString().toString());
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<CoachCancelAppointmentVerificationResponseModel> verifyCoachCancelAppointmentCancel(Map<String, dynamic> requestMap) async {
    String url = Constants.BASE_URL + ApiEndPoints().verifyCoachCancelAppointment;
    showLog(url);
    var headers = {
      'Content-Type': 'application/json',
    };
    if (await networkInterceptor.isConnected()) {
      var request = http.Request('GET', Uri.parse(url));
      request.body = json.encode(requestMap);
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send().timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        String data = await response.stream.bytesToString();
        var responseData = json.decode(data);
        showLog('responseData -> $responseData');
        CoachCancelAppointmentVerificationResponseModel coachCancelAppointmentVerificationResponseModel =
            CoachCancelAppointmentVerificationResponseModel.fromJson(responseData);
        return coachCancelAppointmentVerificationResponseModel;
      } else {
        throw CommonException(code: response.statusCode, message: response.stream.bytesToString().toString());
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<MeetupResponseModel> getAllMeetup(String fromDate, String toDate) async {
    String url =
        '${Constants.BASE_URL}${ApiEndPoints().getAllMeetup}${OQDOApplication.instance.endUserID}&FromDate=$fromDate&ToDate=$toDate&DateWiseResponse=true';
    showLog('$urlTag $url');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        MeetupResponseModel meetupResponseModel = MeetupResponseModel.fromJson(jsonDecode(response.body));
        return meetupResponseModel;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }
}
