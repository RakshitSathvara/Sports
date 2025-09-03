import 'package:flutter/cupertino.dart';
import 'package:oqdo_mobile_app/data/remote/network/api_end_points.dart';
import 'package:oqdo_mobile_app/model/PopularSportsResponseModel.dart';
import 'package:oqdo_mobile_app/model/coach_profile_response.dart';
import 'package:oqdo_mobile_app/model/config_response_model.dart';
import 'package:oqdo_mobile_app/model/end_user_profile_response.dart';
import 'package:oqdo_mobile_app/model/facility_profile_response.dart';
import 'package:oqdo_mobile_app/model/home_response_model.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:oqdo_mobile_app/utils/network_interceptor.dart';

class DashboardRepository {
  var networkInterceptor = NetworkConnectionInterceptor();

  Future<List<PopularSportsResponseModel>> getPopularActivity() async {
    String url = Constants.BASE_URL + ApiEndPoints().getPopularActivity;
    debugPrint(url);
    var uri = Uri.parse(url);
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(uri).timeout(const Duration(seconds: 10));
      debugPrint(response.toString());
      if (response.statusCode == 200) {
        List body = jsonDecode(response.body);
        List<PopularSportsResponseModel> list = [];
        for (int i = 0; i < body.length; i++) {
          PopularSportsResponseModel popularSportsResponseModel = PopularSportsResponseModel.fromJson(body[i]);
          list.add(popularSportsResponseModel);
        }
        return list;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<HomeResponseModel> getSelectedHomeActivity(String selectedActivityName) async {
    String url = Constants.BASE_URL + ApiEndPoints().homeScreenChangesApi + selectedActivityName;
    debugPrint(url);
    var uri = Uri.parse(url);
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(uri).timeout(const Duration(seconds: 10));
      debugPrint(response.toString());
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        HomeResponseModel homeResponseModel = HomeResponseModel.fromJson(body);
        return homeResponseModel;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<ConfigResponseModel> getConfig() async {
    String url = Constants.BASE_URL + ApiEndPoints().getConfig;
    debugPrint(url);
    var uri = Uri.parse(url);

    if (await networkInterceptor.isConnected()) {
      var response = await http.get(uri).timeout(const Duration(seconds: 10));
      debugPrint(response.toString());
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        ConfigResponseModel configResponseModel = ConfigResponseModel.fromJson(body);
        return configResponseModel;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<CoachProfileResponseModel> getCoachUserProfile(String coachId) async {
    String url = Constants.BASE_URL + ApiEndPoints().coachUserProfileCall + coachId;
    debugPrint(url);
    var uri = Uri.parse(url);
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(uri).timeout(const Duration(seconds: 10));
      debugPrint(response.toString());
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        CoachProfileResponseModel coachProfileResponseModel = CoachProfileResponseModel.fromJson(body);
        return coachProfileResponseModel;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<EndUserProfileResponseModel> getEndUserProfile(String endUserId) async {
    String url = Constants.BASE_URL + ApiEndPoints().endUserProfileCall + endUserId;
    debugPrint(url);
    var uri = Uri.parse(url);
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(uri).timeout(const Duration(seconds: 10));
      debugPrint(jsonDecode(response.body));
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        EndUserProfileResponseModel endUserProfileResponseModel = EndUserProfileResponseModel.fromJson(body);
        return endUserProfileResponseModel;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }

  Future<FacilityProfileResponse> getFacilityUserProfile(String facilityId) async {
    String url = Constants.BASE_URL + ApiEndPoints().facilityUserProfileCall + facilityId;
    debugPrint(url);
    var uri = Uri.parse(url);
    if (await networkInterceptor.isConnected()) {
      var response = await http.get(uri).timeout(const Duration(seconds: 10));
      debugPrint(response.toString());
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        FacilityProfileResponse facilityProfileResponseModel = FacilityProfileResponse.fromJson(body);
        return facilityProfileResponseModel;
      } else {
        throw CommonException(code: response.statusCode, message: response.body);
      }
    } else {
      throw NoConnectivityException();
    }
  }
}
