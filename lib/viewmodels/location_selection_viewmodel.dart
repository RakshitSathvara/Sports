import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/repository/location_selection_repository/location_selection_repository_impl.dart';

class LocationSelectionViewModel extends ChangeNotifier {
  final LocationSelectionRepositoryImpl _locationSelectionRepositoryImpl = LocationSelectionRepositoryImpl();

  Future getAllCities() async {
    try {
      var response = await _locationSelectionRepositoryImpl.getAllCity();
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }
}
