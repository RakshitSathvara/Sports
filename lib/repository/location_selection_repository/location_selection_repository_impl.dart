import 'dart:convert';

import 'package:oqdo_mobile_app/data/remote/network/api_end_points.dart';
import 'package:oqdo_mobile_app/model/location_selection_response_model.dart';
import 'package:oqdo_mobile_app/repository/location_selection_repository/location_selection_repository.dart';
import 'package:http/http.dart' as http;
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';

class LocationSelectionRepositoryImpl {
  final networkInterceptor = NetworkConnectionInterceptor();

  Future getAllCity() async {
    try {
      var response = await http
          .get(Uri.parse('${Constants.BASE_URL}${ApiEndPoints().getAllCities}?PageStart=0&ResultPerPage=10000&SeachQuery'))
          .timeout(const Duration(seconds: 40));
      return response;
    } on http.ClientException catch (_) {
      final isConnected = await networkInterceptor.isConnected();
      if (isConnected) {
        throw ServerException();
      } else {
        throw NoConnectivityException();
      }
    } catch (e) {
      rethrow;
    }
  }
}
