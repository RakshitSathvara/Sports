import 'package:flutter/cupertino.dart';
import 'package:oqdo_mobile_app/model/PopularSportsResponseModel.dart';
import 'package:oqdo_mobile_app/model/config_response_model.dart';
import 'package:oqdo_mobile_app/model/home_response_model.dart';
import 'package:oqdo_mobile_app/repository/DashboardRepository.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardRepository dashboardRepository = DashboardRepository();

  bool _isIgnorePoint = false;
  bool get isIgnorePoint => _isIgnorePoint;

  void setIgnorePoint(bool isIgnorePoint) {
    _isIgnorePoint = isIgnorePoint;
    debugPrint('isIgnorePoint: $_isIgnorePoint');
    notifyListeners();
  }

  Future<List<PopularSportsResponseModel>> getPopularSports() async {
    try {
      var response = await dashboardRepository.getPopularActivity();
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<HomeResponseModel> getHomeActivity(String selectedActivityName) async {
    try {
      var response = await dashboardRepository.getSelectedHomeActivity(selectedActivityName);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<ConfigResponseModel> getConfig() async {
    try {
      var response = await dashboardRepository.getConfig();
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  // Future<EndUserProfileResponseModel> getEndUserProfile(String endUserId) async {
  //   try {
  //     var response = await dashboardRepository.getEndUserProfile(endUserId);
  //     notifyListeners();
  //     return Future.value(response);
  //   } catch (error) {
  //     rethrow;
  //   }
  // }

  // Future<FacilityProfileResponse> getFacilityUserProfile(String facilityUserId) async {
  //   try {
  //     var response = await dashboardRepository.getFacilityUserProfile(facilityUserId);
  //     notifyListeners();
  //     return Future.value(response);
  //   } catch (error) {
  //     rethrow;
  //   }
  // }

  // Future<CoachProfileResponseModel> getCoachUserProfile(String coachUserId) async {
  //   try {
  //     var response = await dashboardRepository.getCoachUserProfile(coachUserId);
  //     notifyListeners();
  //     return Future.value(response);
  //   } catch (error) {
  //     rethrow;
  //   }
  // }
}
