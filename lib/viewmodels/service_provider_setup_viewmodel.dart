import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/model/CoachDetailsResponseModel.dart';
import 'package:oqdo_mobile_app/model/GetCoachBySetupIDModel.dart';
import 'package:oqdo_mobile_app/model/cancel_reason_list_response_model.dart';
import 'package:oqdo_mobile_app/model/coach_vacation_response_model.dart';
import 'package:oqdo_mobile_app/model/facility_vacation_response_model.dart';
import 'package:oqdo_mobile_app/repository/service_provider_repository/service_provider_repository_impl.dart';

import '../model/GetFacilityByIdModel.dart';
import '../model/coach_training_address.dart';
import '../model/facility_list_response_model.dart';
import '../model/get_all_activity_and_sub_activity_response.dart';
import '../model/get_coach_batch_model/get_coach_batch_model.dart';
import '../model/upload_file_response.dart';

class ServiceProviderSetupViewModel extends ChangeNotifier {
  final ServiceProviderSetupRepositoryImpl _serviceProviderSetupRepositoryImpl = ServiceProviderSetupRepositoryImpl();

  Future<FacilityListResponseModel> getFacilitySetupList(String facilityId) async {
    try {
      var response = await _serviceProviderSetupRepositoryImpl.getFacilityProviderList(facilityId);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<GetAllActivityAndSubActivityResponse> getAllActivity() async {
    try {
      var response = await _serviceProviderSetupRepositoryImpl.getAllActivityAndSubActivity();
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<GetAllActivityAndSubActivityResponse> getCoachActivity(String coachId) async {
    try {
      var response = await _serviceProviderSetupRepositoryImpl.getCoachActivityAndSubActivity(coachId);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<UploadFileResponse> uploadFile(Map uploadRequest) async {
    try {
      var response = await _serviceProviderSetupRepositoryImpl.uploadImage(uploadRequest);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<String> addFacilitySetupCall(Map value) async {
    try {
      var response = await _serviceProviderSetupRepositoryImpl.addFacilitySetup(value);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<String> editFacilitySetupCall(Map value) async {
    try {
      var response = await _serviceProviderSetupRepositoryImpl.editFacilitySetup(value);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<String> deleteFacilitySetup(Map facilityData) async {
    try {
      var response = await _serviceProviderSetupRepositoryImpl.deleteFacility(facilityData);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<GetCoachBatchModel> getCoachBatchList(String coachID) async {
    try {
      var response = await _serviceProviderSetupRepositoryImpl.getCoachBatchList(coachID);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<String> deleteCoachBatchSetup(Map deleteCoachSetupMap) async {
    try {
      var response = await _serviceProviderSetupRepositoryImpl.deleteCoachSetup(deleteCoachSetupMap);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<List<CoachTrainingAddress>> getCoachTrainingAddress(String coachID) async {
    try {
      var response = await _serviceProviderSetupRepositoryImpl.getCoachTrainingCenter(coachID);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> addCoachTrainingAddress(Map coachAddressMap, bool isEdit) async {
    try {
      var response = await _serviceProviderSetupRepositoryImpl.addCoachTrainingAddress(coachAddressMap, isEdit);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> addCoach(Map coachMap) async {
    try {
      var response = await _serviceProviderSetupRepositoryImpl.addCoachbatch(coachMap);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> editCoachBatch(Map coachMap) async {
    try {
      var response = await _serviceProviderSetupRepositoryImpl.editCoachBatch(coachMap);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> updateCoachBasicInfo(Map request) async {
    try {
      var response = await _serviceProviderSetupRepositoryImpl.updateCoachBasicInfo(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> updateFacilityBasicInfo(Map request) async {
    try {
      var response = await _serviceProviderSetupRepositoryImpl.updateFacilityBasicInfo(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<GetFacilityByIdModel> getFacilityById(int facilitySetupId) async {
    try {
      var response = await _serviceProviderSetupRepositoryImpl.getFacilityById(facilitySetupId);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<GetCoachBySetupIdModel> getBatchByID(int batchID) async {
    try {
      var response = await _serviceProviderSetupRepositoryImpl.getBatchById(batchID);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<String> addEditEndUserAddress(Map<String, dynamic> addEndUserMap, bool isEdit) async {
    try {
      var response = await _serviceProviderSetupRepositoryImpl.addEditEndUserAddress(addEndUserMap, isEdit);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  // Future<GetFacilityByIdModel> getFacilitySetupDetailsById(int facilitySetupId) async {
  //   try {
  //     var response = await _serviceProviderSetupRepositoryImpl.getFacilitySetupDetailsById(facilitySetupId);
  //     notifyListeners();
  //     return Future.value(response);
  //   } catch (error) {
  //     rethrow;
  //   }
  // }

  Future<CoachDetailsResponseModel> getCoachDetailsById(int coachSetupId) async {
    try {
      var response = await _serviceProviderSetupRepositoryImpl.getCoachDetailsById(coachSetupId.toString());
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<List<CancelReasonListResponseModel>> getCancelReasonList() async {
    try {
      var response = await _serviceProviderSetupRepositoryImpl.getCancelReasonList();
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<String> addFacilityVacationCall(Map<String, dynamic> request) async {
    try {
      var response = await _serviceProviderSetupRepositoryImpl.addFacilityVacation(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<String> addCoachVacationCall(Map<String, dynamic> request) async {
    try {
      var response = await _serviceProviderSetupRepositoryImpl.addCoachVacation(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<List<FacilityVacationResponseModel>> getFacilityVacationCall(String facilityId) async {
    try {
      var response = await _serviceProviderSetupRepositoryImpl.getFacilityVacation(facilityId);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<List<CoachVacationResponseModel>> getCoachVacationCall(String facilityId) async {
    try {
      var response = await _serviceProviderSetupRepositoryImpl.getCoachVacation(facilityId);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<String> deleteFacilityVacation(Map<String, dynamic> vacationId) async {
    try {
      var response = await _serviceProviderSetupRepositoryImpl.deleteFacilityVacation(vacationId);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<String> deleteCoachVacation(Map<String, dynamic> vacationId) async {
    try {
      var response = await _serviceProviderSetupRepositoryImpl.deleteCoachVacation(vacationId);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }
}
