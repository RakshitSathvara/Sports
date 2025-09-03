import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/screens/bazaar/ads_screen/repository/ads_respository.dart';

class AdsViewModel extends ChangeNotifier {
  final AdsRepositoryImpl adsRepositoryImpl = AdsRepositoryImpl();

  Future createLead(Map<String, dynamic> data) async {
    try {
      var response = await adsRepositoryImpl.createLead(data);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future getAllActivityAndSubActivity() async {
    try {
      var response = await adsRepositoryImpl.getAllActivityAndSubActivity();
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future getAdvertisementTypeList() async {
    try {
      var response = await adsRepositoryImpl.getAdvertisementTypeList();
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future getAdvertisementList(Map<String, dynamic> data) async {
    try {
      var response = await adsRepositoryImpl.getAdvertisementList(data);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      throw error;
    }
  }

  Future getAllSubActivity() async {
    try {
      var response = await adsRepositoryImpl.getAllSubActivity();
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }
}
