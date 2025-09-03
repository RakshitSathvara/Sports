import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkConnectionInterceptor {
  Connectivity? _connectivity;

  NetworkConnectionInterceptor() {
    _connectivity = Connectivity();
  }

  Future<bool> isConnected() async {
    try {
      var connectivityResult = await _connectivity!.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }
      return true;
    } on SocketException catch (_) {
      return false;
    }
  }
}

class NoConnectivityException implements Exception {
  int get code => 100;
}

class APITimeoutException implements Exception {
  int get code => 101;
}

class ServerException implements Exception {
  int get code => 102;
}
