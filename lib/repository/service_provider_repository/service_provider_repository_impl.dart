import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oqdo_mobile_app/model/CoachDetailsResponseModel.dart';
import 'package:oqdo_mobile_app/model/GetCoachBySetupIDModel.dart';
import 'package:oqdo_mobile_app/model/GetFacilityByIdModel.dart';
import 'package:oqdo_mobile_app/model/cancel_reason_list_response_model.dart';
import 'package:oqdo_mobile_app/model/cancellation_request_list_response_model.dart';
import 'package:oqdo_mobile_app/model/coach_training_address.dart';
import 'package:oqdo_mobile_app/model/coach_vacation_response_model.dart';
import 'package:oqdo_mobile_app/model/facility_list_response_model.dart';
import 'package:oqdo_mobile_app/model/facility_vacation_response_model.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/repository/service_provider_repository/service_provider_repository.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';

import '../../data/remote/network/api_end_points.dart';
import '../../model/get_all_activity_and_sub_activity_response.dart';
import '../../model/get_coach_batch_model/get_coach_batch_model.dart';
import '../../model/upload_file_response.dart';

class ServiceProviderSetupRepositoryImpl implements ServiceProviderSetupRepository {
  final networkInterceptor = NetworkConnectionInterceptor();

  @override
  Future<FacilityListResponseModel> getFacilityProviderList(String facilityId) async {
    String url = Constants.BASE_URL + ApiEndPoints().getFacilitySetupCall + facilityId;
    // print(url);
    var uri = Uri.parse(url);

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    // print(headers.toString());

    if (await networkInterceptor.isConnected()) {
      var response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      // print(response);
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        FacilityListResponseModel facilityListResponseModel = FacilityListResponseModel.fromJson(body);
        return facilityListResponseModel;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  @override
  Future<GetAllActivityAndSubActivityResponse> getAllActivityAndSubActivity() async {
    String url = "${Constants.BASE_URL}${ApiEndPoints().getAllActivity}PageStart=0&ResultPerPage=10000&SeachQuery";
    // print(url);

    if (await networkInterceptor.isConnected()) {
      var response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      // print(response.body.toString());
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        GetAllActivityAndSubActivityResponse? getAllActivityAndSubActivityResponse = GetAllActivityAndSubActivityResponse.fromMap(body);
        return getAllActivityAndSubActivityResponse!;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  @override
  Future<UploadFileResponse> uploadImage(Map uploadImageData) async {
    String url = Constants.BASE_URL + ApiEndPoints().uploadImage;
    // print(url);
    var uri = Uri.parse(url);
    var body = json.encode(uploadImageData);
    // print(body);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(minutes: 2));
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        UploadFileResponse? uploadFileResponse = UploadFileResponse.fromMap(body);
        return uploadFileResponse!;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  @override
  Future<String> addFacilitySetup(Map addFacilitySetupMap) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };

    // print(headers.toString());

    String url = Constants.BASE_URL + ApiEndPoints().addFacility;
    debugPrint("addFacilitySetup -> $url");
    var uri = Uri.parse(url);
    var body = json.encode(addFacilitySetupMap);
    debugPrint('addFacilitySetup -> $body');

    if (await networkInterceptor.isConnected()) {
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 180));
      debugPrint('addFacilitySetup -> ${response.body}');
      debugPrint('addFacilitySetup -> ${response.headers}');
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  @override
  Future<String> editFacilitySetup(Map addFacilitySetupMap) async {
    String url = Constants.BASE_URL + ApiEndPoints().addFacility;
    debugPrint("editFacilitySetup -> $url");
    var uri = Uri.parse(url);
    var body = json.encode(addFacilitySetupMap);
    debugPrint('editFacilitySetup -> $body');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.put(uri, headers: headers, body: body).timeout(const Duration(seconds: 180));
      debugPrint('editFacilitySetup -> ${response.body}');
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  @override
  Future<String> deleteFacility(Map facilityID) async {
    String url = Constants.BASE_URL + ApiEndPoints().deleteFacility;
    debugPrint('deleteFacility url -> $url');
    var uri = Uri.parse(url);
    var body = json.encode(facilityID);
    debugPrint('deleteFacility request -> $body');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.delete(uri, headers: headers, body: body).timeout(const Duration(seconds: 180));
      debugPrint('deleteFacility response-> ${response.body}');
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  @override
  Future<String> deleteCoachSetup(Map deleteCoachSetupMap) async {
    String url = Constants.BASE_URL + ApiEndPoints().addAndDeleteCoachSetup;
    debugPrint('deleteCoachSetup url -> $url');
    var uri = Uri.parse(url);
    var body = json.encode(deleteCoachSetupMap);
    debugPrint('deleteCoachSetup request -> $body');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.delete(uri, headers: headers, body: body).timeout(const Duration(seconds: 180));
      debugPrint('deleteFacility response-> ${response.body}');
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  @override
  Future<GetCoachBatchModel> getCoachBatchList(String coachID) async {
    String url = Constants.BASE_URL + ApiEndPoints().getCoachBatchList + coachID;
    // print(url);
    var uri = Uri.parse(url);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      debugPrint(response.toString());
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        GetCoachBatchModel getCoachBatchModel = GetCoachBatchModel.fromMap(body);
        return getCoachBatchModel;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  @override
  Future<List<CoachTrainingAddress>> getCoachTrainingCenter(String coachId) async {
    var url = Constants.BASE_URL + ApiEndPoints().getCoachTrainingAddress + coachId;
    debugPrint("getCoachTrainingCenter -> URL$url");
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}',
    };
    var uri = Uri.parse(url);
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      debugPrint("getCoachTrainingCenter -> response${response.body}");
      if (response.statusCode == 200) {
        List body = jsonDecode(response.body);
        List<CoachTrainingAddress> list = [];
        for (int i = 0; i < body.length; i++) {
          CoachTrainingAddress coachTrainingAddress = CoachTrainingAddress.fromJson(body[i]);
          list.add(coachTrainingAddress);
        }
        debugPrint('List -> ${list.length}');
        return list;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  @override
  Future addCoachTrainingAddress(Map coachTrainingAddressMap, bool isEdit) async {
    String url = Constants.BASE_URL + ApiEndPoints().addCoachTrainingAddress;
    debugPrint('addCoachTrainingAddress url -> $url');
    var uri = Uri.parse(url);
    var body = json.encode(coachTrainingAddressMap);
    debugPrint('addCoachTrainingAddress request -> $body');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = isEdit
          ? await http.put(uri, headers: headers, body: body).timeout(const Duration(seconds: 10))
          : await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      debugPrint('addCoachTrainingAddress response-> ${response.body}');
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  @override
  Future addCoachbatch(Map coachSetupMap) async {
    String url = Constants.BASE_URL + ApiEndPoints().addAndDeleteCoachSetup;
    debugPrint('addCoachbatch url -> $url');
    var uri = Uri.parse(url);
    var body = json.encode(coachSetupMap);
    debugPrint('addCoachbatch request -> $body');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 180));
      debugPrint('addCoachbatch response-> ${response.body}');
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  @override
  Future editCoachBatch(Map coachSetupMap) async {
    String url = Constants.BASE_URL + ApiEndPoints().addAndDeleteCoachSetup;
    debugPrint('addAndDeleteCoachSetup url -> $url');
    var uri = Uri.parse(url);
    var body = json.encode(coachSetupMap);
    debugPrint('editCoachBatch request -> $body');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.put(uri, headers: headers, body: body).timeout(const Duration(seconds: 180));
      debugPrint('editCoachBatch response-> ${response.body}');
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  @override
  Future updateCoachBasicInfo(Map coachSetupMap) async {
    String url = Constants.BASE_URL + ApiEndPoints().updateCoachBasicInfo;
    debugPrint('updateCoachBasicInfo url -> $url');
    var uri = Uri.parse(url);
    var body = json.encode(coachSetupMap);
    debugPrint('editCoachBatch request -> $body');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.put(uri, headers: headers, body: body).timeout(const Duration(seconds: 180));
      debugPrint('editCoachBatch response-> ${response.body}');
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  @override
  Future<GetFacilityByIdModel> getFacilityById(int facilitySetupId) async {
    String url = Constants.BASE_URL + ApiEndPoints().getFacilityById + facilitySetupId.toString();
    debugPrint(url);
    var uri = Uri.parse(url);
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(uri).timeout(const Duration(seconds: 10));
      debugPrint(response.toString());
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        GetFacilityByIdModel getFacilityByIdModel = GetFacilityByIdModel.fromJson(body);
        return getFacilityByIdModel;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  @override
  Future<GetCoachBySetupIdModel> getBatchById(int batchSetupID) async {
    String url = Constants.BASE_URL + ApiEndPoints().getBatchById + batchSetupID.toString();
    debugPrint(url);
    var uri = Uri.parse(url);
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(uri).timeout(const Duration(seconds: 10));
      debugPrint(response.toString());
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        GetCoachBySetupIdModel getCoachBySetupIdModel = GetCoachBySetupIdModel.fromJson(body);
        return getCoachBySetupIdModel;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  @override
  Future<String> addEditEndUserAddress(Map<String, dynamic> addEndUserMap, bool isEdit) async {
    String url = Constants.BASE_URL + ApiEndPoints().addEditDelteEndUserAddress;
    debugPrint('URL -> $url');
    var uri = Uri.parse(url);
    var body = json.encode(addEndUserMap);
    debugPrint('Request -> $body');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = isEdit
          ? await http.put(uri, headers: headers, body: body).timeout(const Duration(seconds: 10))
          : await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      debugPrint('Response-> ${response.body}');
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<GetFacilityByIdModel> getFacilitySetupDetailsById(int facilitySetupId) async {
    String url = Constants.BASE_URL + ApiEndPoints().getFacilityById + facilitySetupId.toString();
    debugPrint('URL -> $url');
    var uri = Uri.parse(url);
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(uri).timeout(const Duration(seconds: 10));
      debugPrint(response.toString());
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        GetFacilityByIdModel getFacilityByIdModel = GetFacilityByIdModel.fromJson(body);
        return getFacilityByIdModel;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<CoachDetailsResponseModel> getCoachDetailsById(String coachSetupId) async {
    String url = Constants.BASE_URL + ApiEndPoints().coachDetailsById + coachSetupId;
    debugPrint('URL -> $url');
    var uri = Uri.parse(url);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      debugPrint(response.toString());
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        CoachDetailsResponseModel coachDetailsResponseModel = CoachDetailsResponseModel.fromJson(body);
        return coachDetailsResponseModel;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<GetAllActivityAndSubActivityResponse> getCoachActivityAndSubActivity(String coachId) async {
    String url = "${Constants.BASE_URL}${ApiEndPoints().getAllActivity}PageStart=0&ResultPerPage=10000&CoachId=$coachId";
    // print(url);

    if (await networkInterceptor.isConnected()) {
      var response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      // print(response.body.toString());
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        GetAllActivityAndSubActivityResponse? getAllActivityAndSubActivityResponse = GetAllActivityAndSubActivityResponse.fromMap(body);
        return getAllActivityAndSubActivityResponse!;
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
    var uri = Uri.parse(url);
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(uri).timeout(const Duration(seconds: 10));
      debugPrint(response.toString());
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

  Future<String> addFacilityVacation(Map<String, dynamic> request) async {
    String url = Constants.BASE_URL + ApiEndPoints().addFacilityVacation;
    // print(url);
    var uri = Uri.parse(url);
    var body = json.encode(request);
    // print(body);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 180));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<String> addCoachVacation(Map<String, dynamic> request) async {
    String url = Constants.BASE_URL + ApiEndPoints().addCoachVacation;
    // print(url);
    var uri = Uri.parse(url);
    var body = json.encode(request);
    // print(body);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 180));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<List<FacilityVacationResponseModel>> getFacilityVacation(String facilityId) async {
    String url = Constants.BASE_URL + ApiEndPoints().getFacilityVacation + facilityId;
    debugPrint('URL -> $url');
    var uri = Uri.parse(url);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      debugPrint(response.toString());
      if (response.statusCode == 200) {
        List body = jsonDecode(response.body);
        debugPrint('debugprint -> $body');
        List<FacilityVacationResponseModel> list = [];
        for (int i = 0; i < body.length; i++) {
          FacilityVacationResponseModel facilityVacationResponseModel = FacilityVacationResponseModel.fromJson(body[i]);
          list.add(facilityVacationResponseModel);
        }
        return list;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<List<CoachVacationResponseModel>> getCoachVacation(String facilityId) async {
    String url = Constants.BASE_URL + ApiEndPoints().getCoachVacation + facilityId;
    debugPrint('URL -> $url');
    var uri = Uri.parse(url);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      debugPrint(response.toString());
      if (response.statusCode == 200) {
        List body = jsonDecode(response.body);
        debugPrint('debugprint -> $body');
        List<CoachVacationResponseModel> list = [];
        for (int i = 0; i < body.length; i++) {
          CoachVacationResponseModel facilityVacationResponseModel = CoachVacationResponseModel.fromJson(body[i]);
          list.add(facilityVacationResponseModel);
        }
        return list;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<String> deleteFacilityVacation(Map<String, dynamic> request) async {
    String url = Constants.BASE_URL + ApiEndPoints().deleteFacilityVacation;
    // print(url);
    var uri = Uri.parse(url);
    var body = json.encode(request);
    // print(body);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.delete(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<String> deleteCoachVacation(Map<String, dynamic> request) async {
    String url = Constants.BASE_URL + ApiEndPoints().deleteCoachVacation;
    // print(url);
    var uri = Uri.parse(url);
    var body = json.encode(request);
    // print(body);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.delete(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  @override
  Future updateFacilityBasicInfo(Map facilitySetup) async {
    String url = Constants.BASE_URL + ApiEndPoints().updateFacilityBasicInfo;
    debugPrint('updateFacilityBasicInfo url -> $url');
    var uri = Uri.parse(url);
    var body = json.encode(facilitySetup);
    debugPrint('facility request -> $body');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.put(uri, headers: headers, body: body).timeout(const Duration(seconds: 180));
      debugPrint('facility response-> ${response.body}');
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  @override
  Future<CancellationRequestsListModel> getCoachCancellationRequests({required String endUrl}) async {
    String url = "${Constants.BASE_URL}${ApiEndPoints().getCoachCancellationRequest}?$endUrl";
    debugPrint('URL -> $url');
    var uri = Uri.parse(url);

    if (await networkInterceptor.isConnected()) {
      var response = await http.get(uri).timeout(const Duration(seconds: 10));
      debugPrint(response.toString());

      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        debugPrint("Response of getCoachCancellationRequests ====> $body");
        CancellationRequestsListModel cancellationListModel = CancellationRequestsListModel.fromJson(body);
        return cancellationListModel;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  @override
  Future updateCoachBookingRefundStatus(Map request) async {
    String url = Constants.BASE_URL + ApiEndPoints().updateCoachBookingRefundStatus;
    debugPrint('updateCoachBookingRefundStatus url -> $url');
    var uri = Uri.parse(url);
    var body = json.encode(request);
    debugPrint('updateCoachBookingRefundStatus request -> $body');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.put(uri, headers: headers, body: body).timeout(const Duration(seconds: 60));
      debugPrint('updateCoachBookingRefundStatus response-> ${response.body}');
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  @override
  Future<CancellationRequestsListModel> getFacilityCancellationRequests({required String endUrl}) async {
    String url = "${Constants.BASE_URL}${ApiEndPoints().getFacilityCancellationRequest}?$endUrl";
    debugPrint('URL -> $url');
    var uri = Uri.parse(url);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      debugPrint(response.toString());
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        CancellationRequestsListModel cancellationListModel = CancellationRequestsListModel.fromJson(body);
        return cancellationListModel;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  @override
  Future updateFacilityBookingRefundStatus(Map request) async {
    String url = Constants.BASE_URL + ApiEndPoints().updateFacilityBookingRefundStatus;
    debugPrint('updateFacilityBookingRefundStatus url -> $url');
    var uri = Uri.parse(url);
    var body = json.encode(request);
    debugPrint('updateFacilityBookingRefundStatus request -> $body');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.put(uri, headers: headers, body: body).timeout(const Duration(seconds: 60));
      debugPrint('updateFacilityBookingRefundStatus response-> ${response.body}');
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  @override
  Future<CancellationRequestsListModel> getEnduserCancellationRequests({required String endUrl}) async {
    String url = "${Constants.BASE_URL}${ApiEndPoints().getEnduserCancellationRequests}?$endUrl";
    debugPrint('URL -> $url');
    var uri = Uri.parse(url);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '${OQDOApplication.instance.tokenType} ${OQDOApplication.instance.token}'
    };
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      debugPrint(response.toString());
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        CancellationRequestsListModel cancellationListModel = CancellationRequestsListModel.fromJson(body);
        return cancellationListModel;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }
}
