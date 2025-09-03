import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oqdo_mobile_app/data/remote/network/api_end_points.dart';
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
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/screens/appointment/response/referral_coupon_response_model.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';

class SlotManagementRepository {
  final networkInterceptor = NetworkConnectionInterceptor();

  Future<List<Get21DaysSlotResponseModel>> get21DaysFacilitySlots(int facilityId, String selectedDate, String passingLastDate) async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().getFacilitySlotByDate}facilitySetupId=$facilityId&SelectedDate=$selectedDate&endDate=$passingLastDate';
    debugPrint('$urlTag $url');
    var headers = {'Content-Type': 'application/json', 'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'};
    debugPrint('Auth -> ${OQDOApplication.instance.token}');
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag $response');
      if (response.statusCode == 200) {
        List body = jsonDecode(response.body);
        debugPrint('debugprint -> $body');
        List<Get21DaysSlotResponseModel> list = [];
        for (int i = 0; i < body.length; i++) {
          Get21DaysSlotResponseModel get21daysSlotResponseModel = Get21DaysSlotResponseModel.fromJson(body[i]);
          list.add(get21daysSlotResponseModel);
        }
        return list;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  //Coach
  Future<List<CoachGet21DaysSlotResponseModel>> getCoach21DaysFacilitySlots(int coachId, String selectedDate, String passingLastDate) async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().getCoachSlotByDate}coachBatchSetupId=$coachId&SelectedDate=$selectedDate&endDate=$passingLastDate';
    debugPrint('$urlTag $url');
    var headers = {'Content-Type': 'application/json', 'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'};
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag $response');
      if (response.statusCode == 200) {
        List body = jsonDecode(response.body);
        debugPrint('debugprint -> $body');
        List<CoachGet21DaysSlotResponseModel> list = [];
        for (int i = 0; i < body.length; i++) {
          CoachGet21DaysSlotResponseModel coachGet21DaysSlotResponseModel = CoachGet21DaysSlotResponseModel.fromJson(body[i]);
          list.add(coachGet21DaysSlotResponseModel);
        }
        return list;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<List<AvailableSlotsByDateResponseModel>> getFacilityAvailableSlotsByDate(int facilityId, String selectedDate) async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().getFacilityAvailableSlotsByDate}facilitySetupId=$facilityId&setupDate=$selectedDate';
    debugPrint('$urlTag $url');
    var headers = {'Content-Type': 'application/json', 'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'};
    debugPrint('Auth -> ${OQDOApplication.instance.token}');
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag getFacilityAvailableSlotsByDate -> $response');
      if (response.statusCode == 200) {
        List body = jsonDecode(response.body);
        debugPrint('debugprint -> $body');
        List<AvailableSlotsByDateResponseModel> list = [];
        for (int i = 0; i < body.length; i++) {
          AvailableSlotsByDateResponseModel availableSlotsByDateResponseModel = AvailableSlotsByDateResponseModel.fromJson(body[i]);
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

  // Coach
  Future<List<CoachAvailableSlotsByDateResponseModel>> getCoachAvailableSlotsByDate(int coachId, String selectedDate) async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().getCoachAvailableSlotsByDate}coachBatchSetupId=$coachId&SelectedDate=$selectedDate';
    debugPrint('$urlTag $url');
    var headers = {'Content-Type': 'application/json', 'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'};
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag getCoachAvailableSlotsByDate -> $response');
      if (response.statusCode == 200) {
        List body = jsonDecode(response.body);
        debugPrint('debugprint -> $body');
        List<CoachAvailableSlotsByDateResponseModel> list = [];
        for (int i = 0; i < body.length; i++) {
          CoachAvailableSlotsByDateResponseModel availableSlotsByDateResponseModel = CoachAvailableSlotsByDateResponseModel.fromJson(body[i]);
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

  Future<FreezeFacilityResponseModel> freezeFacilityBooking(Map<String, dynamic> request) async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().freezeFacilityBooking}';
    debugPrint('$urlTag $url');
    var uri = Uri.parse(url);
    var body = json.encode(request);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    debugPrint('$requestTag $body');
    debugPrint('${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}');
    if (await networkInterceptor.isConnected()) {
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag freezeFacilityBooking -> ${response.body}');
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        FreezeFacilityResponseModel facilityResponseModel = FreezeFacilityResponseModel.fromJson(body);
        return facilityResponseModel;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<FreezeCoachResponseModel> freezeCoachBooking(Map<String, dynamic> request) async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().freezeCoachBooking}';
    debugPrint('$urlTag $url');
    var uri = Uri.parse(url);
    var body = json.encode(request);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    debugPrint('$requestTag $body');
    if (await networkInterceptor.isConnected()) {
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag freezeCoachBooking -> ${response.body}');
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        FreezeCoachResponseModel facilityResponseModel = FreezeCoachResponseModel.fromJson(body);
        return facilityResponseModel;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<FreezeFacilityResponseModel> unFreezeFacilityBooking(Map<String, dynamic> request) async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().unFreezeFacilityBooking}';
    debugPrint('$urlTag $url');
    var uri = Uri.parse(url);
    var body = json.encode(request);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    debugPrint('$requestTag $body');
    if (await networkInterceptor.isConnected()) {
      var response = await http.put(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag unFreezeFacilityBooking -> ${response.body}');
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        FreezeFacilityResponseModel facilityResponseModel = FreezeFacilityResponseModel.fromJson(body);
        return facilityResponseModel;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<FreezeCoachResponseModel> unFreezeCoachBooking(Map<String, dynamic> request) async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().unFreezeCoachBooking}';
    debugPrint('$urlTag $url');
    var uri = Uri.parse(url);
    var body = json.encode(request);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    debugPrint('$requestTag $body');
    if (await networkInterceptor.isConnected()) {
      var response = await http.put(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag unFreezeCoachBooking -> ${response.body}');
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        FreezeCoachResponseModel facilityResponseModel = FreezeCoachResponseModel.fromJson(body);
        return facilityResponseModel;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<FacilityBookingListModelResponse> getFreezeBooking(String orderId) async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().bookingFreezeList}$orderId';
    debugPrint('$urlTag $url');
    var uri = Uri.parse(url);

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag getFreezeBooking -> ${response.body}');
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        FacilityBookingListModelResponse facilityBookingListModelResponse = FacilityBookingListModelResponse.fromJson(body);
        return facilityBookingListModelResponse;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<CoachBookingListModelResponse> getFreezeCoachBooking(String orderId) async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().coachBookingFreezeList}$orderId';
    debugPrint('$urlTag $url');
    var uri = Uri.parse(url);

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag getFreezeCoachBooking -> ${response.body}');
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        CoachBookingListModelResponse facilityBookingListModelResponse = CoachBookingListModelResponse.fromJson(body);
        return facilityBookingListModelResponse;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<FacilityBookingResponse> facilitySlotBooking(Map<String, dynamic> request) async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().facilityAppointmentBooking}';
    debugPrint('$urlTag $url');
    var uri = Uri.parse(url);
    var body = json.encode(request);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    debugPrint('$requestTag $body');
    if (await networkInterceptor.isConnected()) {
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag facilitySlotBooking -> ${response.body}');
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        FacilityBookingResponse facilityBookingResponse = FacilityBookingResponse.fromJson(body);
        return facilityBookingResponse;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<CoachBookingResponse> coachSlotBooking(Map<String, dynamic> request) async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().coachAppointmentBooking}';
    debugPrint('$urlTag $url');
    var uri = Uri.parse(url);
    var body = json.encode(request);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    debugPrint('$requestTag $body');
    if (await networkInterceptor.isConnected()) {
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag coachSlotBooking -> ${response.body}');
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        CoachBookingResponse bookingResponse = CoachBookingResponse.fromJson(body);
        return bookingResponse;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<bool> successCoachBooking(Map<String, dynamic> request) async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().successCoachBooking}';
    debugPrint('$urlTag $url');
    var uri = Uri.parse(url);
    var body = json.encode(request);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    debugPrint('$requestTag $body');
    if (await networkInterceptor.isConnected()) {
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 60));
      debugPrint('$responseTag coachSlotBooking -> ${response.body}');
      if (response.statusCode == 200) {
        return true;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<bool> successFacilityBooking(Map<String, dynamic> request) async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().successFacilityBooking}';
    debugPrint('$urlTag $url');
    var uri = Uri.parse(url);
    var body = json.encode(request);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    debugPrint('$requestTag $body');
    if (await networkInterceptor.isConnected()) {
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 60));
      debugPrint('$responseTag coachSlotBooking -> ${response.body}');
      if (response.statusCode == 200) {
        return true;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<bool> failedCoachBooking(Map<String, dynamic> request) async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().failedCoachBooking}';
    debugPrint('$urlTag $url');
    var uri = Uri.parse(url);
    var body = json.encode(request);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    debugPrint('$requestTag $body');
    if (await networkInterceptor.isConnected()) {
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag Facility Success -> ${response.body}');
      if (response.statusCode == 200) {
        return true;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<bool> failedFacilityBooking(Map<String, dynamic> request) async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().failedFacilityBooking}';
    debugPrint('$urlTag $url');
    var uri = Uri.parse(url);
    var body = json.encode(request);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    debugPrint('$requestTag $body');
    if (await networkInterceptor.isConnected()) {
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag Facility Failed -> ${response.body}');
      if (response.statusCode == 200) {
        return true;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<List<ReferralActivityData>> getReferralCoupons() async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().getReferralCoupons}';
    debugPrint('$urlTag $url');
    var uri = Uri.parse(url);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag Facility Failed -> ${response.body}');
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        ReferralCouponResponseModel referralCouponResponseModel = ReferralCouponResponseModel.fromJson(body);
        return referralCouponResponseModel.data;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<bool> unFreezeFacilityBookingList(List<Map<String, dynamic>> request) async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().unFreezeFacilityBookingList}';
    debugPrint('$urlTag $url');
    var uri = Uri.parse(url);
    var body = json.encode(request);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    debugPrint('$requestTag $body');
    if (await networkInterceptor.isConnected()) {
      var response = await http.put(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag unFreezeFacilityBooking -> ${response.body}');
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        // FreezeFacilityResponseModel facilityResponseModel = FreezeFacilityResponseModel.fromJson(body);
        return body;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<bool> unFreezeCoachBookingBulk(List<Map<String, dynamic>> request) async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().unFreezeCoachBookingBulk}';
    debugPrint('$urlTag $url');
    var uri = Uri.parse(url);
    var body = json.encode(request);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    debugPrint('$requestTag $body');
    if (await networkInterceptor.isConnected()) {
      var response = await http.put(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag unFreezeCoachBooking -> ${response.body}');
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        return body;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<bool> validateFacilityPaymentActivity(Map<String, dynamic> request) async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().validateFacilityPaymentActivity}';
    debugPrint('$urlTag $url');
    var uri = Uri.parse(url);
    var body = json.encode(request);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    debugPrint('$requestTag $body');
    if (await networkInterceptor.isConnected()) {
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag Validate Facility Payment -> ${response.body}');
      if (response.statusCode == 200) {
        dynamic responseBody = jsonDecode(response.body);
        return responseBody;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<bool> validateCoachPaymentActivity(Map<String, dynamic> request) async {
    var url = '${Constants.BASE_URL}${ApiEndPoints().validateCoachPaymentActivity}';
    debugPrint('$urlTag $url');
    var uri = Uri.parse(url);
    var body = json.encode(request);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    debugPrint('$requestTag $body');
    if (await networkInterceptor.isConnected()) {
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      debugPrint('$responseTag Validate Coach Payment -> ${response.body}');
      if (response.statusCode == 200) {
        dynamic responseBody = jsonDecode(response.body);
        return responseBody;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }
}
