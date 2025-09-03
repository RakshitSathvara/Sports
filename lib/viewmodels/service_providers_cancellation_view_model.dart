import 'package:flutter/cupertino.dart';
import 'package:oqdo_mobile_app/model/cancellation_request_list_response_model.dart';
import 'package:oqdo_mobile_app/repository/service_provider_repository/service_provider_repository_impl.dart';

class ServiceProvidersCancellationViewModel extends ChangeNotifier{

  final _serviceProviderRepository = ServiceProviderSetupRepositoryImpl();

  Future<CancellationRequestsListModel> getCoachTransactionList(String endUrl) async {
    try {
      CancellationRequestsListModel response = await _serviceProviderRepository.getCoachCancellationRequests(endUrl:endUrl);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> updateCoachBookingRefundStatus(Map request) async {
    try {
      var response = await _serviceProviderRepository.updateCoachBookingRefundStatus(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<CancellationRequestsListModel> getFacilityTransactionList(String endUrl) async {
    try {
      CancellationRequestsListModel response = await _serviceProviderRepository.getFacilityCancellationRequests(endUrl:endUrl);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> updateFacilityBookingRefundStatus(Map request) async {
    try {
      var response = await _serviceProviderRepository.updateFacilityBookingRefundStatus(request);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<CancellationRequestsListModel> getEnduserCancellationRequests(String endUrl) async {
    try {
      CancellationRequestsListModel response = await _serviceProviderRepository.getEnduserCancellationRequests(endUrl:endUrl);
      notifyListeners();
      return Future.value(response);
    } catch (error) {
      rethrow;
    }
  }

}