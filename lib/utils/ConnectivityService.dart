import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';

class ConnectivityService {
  static Future<bool> isInternetConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      debugPrint('Connected to mobile');
      return true;
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      debugPrint('Connected to wifi');
      return true;
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      debugPrint('Connected to ethernet');
      return true;
    } else if (connectivityResult.contains(ConnectivityResult.vpn)) {
      debugPrint('Connected to vpn');
      return true;
    } else if (connectivityResult.contains(ConnectivityResult.none)) {
      debugPrint('Not connected');
      return false;
    }
    return false;
  }
}

class NetworkConnectivity {
  NetworkConnectivity._();
  static final _instance = NetworkConnectivity._();
  static NetworkConnectivity get instance => _instance;
  final Connectivity _networkConnectivity = Connectivity();
  final StreamController _controller = StreamController.broadcast();
  Stream get myStream => _controller.stream;

  void initialise() async {
    var result = await _networkConnectivity.checkConnectivity();
    _checkStatus(result);
    _networkConnectivity.onConnectivityChanged.listen((result) {
      _checkStatus(result);
    });
  }

  void _checkStatus(List<ConnectivityResult> result) async {
    bool isOnline = false;
    try {
      final result = await InternetAddress.lookup('example.com');
      isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      isOnline = false;
    }
    _controller.sink.add({result: isOnline});
  }

  void disposeStream() => _controller.close();
}
