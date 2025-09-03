import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/repository/sell_repository.dart';

class SellViewmodel extends ChangeNotifier {
  final SellRepository _sellRepository = SellRepository();

  Future getEquipments(Map<String, dynamic> request) async {
    try {
      var response = await _sellRepository.getEquipments(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future getAllEquipmentCategories() async {
    try {
      var response = await _sellRepository.getAllEquipmentCategories();
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future getEquipmentFavorite(String request) async {
    try {
      var response = await _sellRepository.getEquipmentFavorite(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future getAllActivityAndSubActivity() async {
    try {
      var response = await _sellRepository.getAllActivityAndSubActivity();
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future getEquipmentCondition() async {
    try {
      var response = await _sellRepository.getAllEquipmentConditionList();
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future multipleUploadFile(List<Map<String, dynamic>> uploadRequest) async {
    try {
      var response = await _sellRepository.multipleUploadImage(uploadRequest);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future postProduct(Map<String, dynamic> request) async {
    try {
      var response = await _sellRepository.postProduct(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future getEquipmentById(String request) async {
    try {
      var response = await _sellRepository.getEquipmentDetail(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future editPostProduct(Map<String, dynamic> request) async {
    try {
      var response = await _sellRepository.editPostProduct(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future deleteEquipment(Map<String, dynamic> request) async {
    try {
      var response = await _sellRepository.deleteEquipment(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future uploadFile(Map uploadRequest) async {
    try {
      var response = await _sellRepository.uploadImage(uploadRequest);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future addRemoveFromFavorite(String request) async {
    try {
      var response = await _sellRepository.addRemoveFromFavorite(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future updateEquipmentStatus(Map<String, dynamic> request) async {
    try {
      var response = await _sellRepository.updateEquipmentStatus(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }
}
