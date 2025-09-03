import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:signalr_netcore/http_connection_options.dart';

enum ConnectionStatus { disconnected, connecting, connected, reconnecting, failed }

class Pair<T1, T2> {
  final T1 first;
  final T2 second;

  Pair(this.first, this.second);
}

class BuyingSocketService {
  // Event listeners
  static const listenConnected = "Connected";

  // Equipment chat specific events
  static const listenEquipmentMessages = "ReceiveEquipmentMessages";
  static const listenEquipmentCloseDealMessages = "ReceiveEquipmentCloseDealMessages";

  // Server URL
  final String serverURL = '${Constants.SOCKET_BASE_URL}/ChatHub';

  // Singleton pattern
  static final BuyingSocketService _instance = BuyingSocketService._internal();
  factory BuyingSocketService() => _instance;
  BuyingSocketService._internal() {
    setupLogger();
  }

  // Socket instance
  HubConnection? _hubConnection;

  // Logger
  final hubProtLogger = Logger("SignalR - buying hub");
  final transportProtLogger = Logger("SignalR - buying transport");

  setupLogger() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      if (kDebugMode) {
        print('BuyingSignalR :=> ${rec.level.name}: ${rec.time}: ${rec.message}');
      }
    });
  }

  // Stream controllers
  final _socketListenerController = StreamController<Pair<String, List<Object?>?>>.broadcast();
  final _connectionStatusController = StreamController<ConnectionStatus>.broadcast();

  // Getters
  Stream<Pair<String, List<Object?>?>> get socketListenerStream => _socketListenerController.stream;
  Stream<ConnectionStatus> get connectionStatusStream => _connectionStatusController.stream;

  bool get isConnected => _hubConnection != null && _hubConnection!.state == HubConnectionState.Connected;

  /// Connect to the socket server
  Future<void> connect() async {
    if (_hubConnection != null && isConnected) {
      await _hubConnection!.stop();
    }

    try {
      _connectionStatusController.add(ConnectionStatus.connecting);
      commonPrint('Socket connecting:');

      final connectionOptions = HttpConnectionOptions();

      _hubConnection = HubConnectionBuilder()
          .withUrl(serverURL, options: connectionOptions)
          .withAutomaticReconnect(retryDelays: [0, 2000, 3000, 4000]) // try auto connect in 2, 3, 4 seconds...
          .build();

      _setupSocketListeners();

      await _hubConnection!.start();
      commonPrint("Socket Connected: ${_hubConnection!.connectionId}");
    } catch (e) {
      _connectionStatusController.add(ConnectionStatus.failed);
      commonPrint('Socket connection failed: $e');
    }
  }

  /// Setup all socket event listeners
  void _setupSocketListeners() {
    _hubConnection!.onreconnected(({connectionId}) {
      commonPrint('Socket reconnected: $connectionId');
      _connectionStatusController.add(ConnectionStatus.connected);
    });

    _hubConnection!.onreconnecting(({error}) {
      commonPrint('Socket reconnecting: $error');
      _connectionStatusController.add(ConnectionStatus.connecting);
    });

    _hubConnection!.onclose(({error}) {
      commonPrint('Socket disconnected: $error');
      _connectionStatusController.add(ConnectionStatus.disconnected);
    });

    _hubConnection!.on(listenConnected, _handleConnected);

    // Equipment chat events
    _hubConnection!.on(listenEquipmentMessages, _handleEquipmentMessages);
    _hubConnection!.on(listenEquipmentCloseDealMessages, _handleEquipmentCloseDealMessages);
  }

  void _handleConnected(List<Object?>? arguments) {
    commonPrint("Socket Connected: $arguments");
    _connectionStatusController.add(ConnectionStatus.connected);
  }

  void _handleEquipmentMessages(List<Object?>? arguments) {
    commonPrint("Callback:=> Equipment Messages: $arguments");
    _socketListenerController.add(Pair(listenEquipmentMessages, arguments));
  }

  void _handleEquipmentCloseDealMessages(List<Object?>? arguments) {
    commonPrint("Callback:=> Equipment Close Deal Messages: $arguments");
    _socketListenerController.add(Pair(listenEquipmentCloseDealMessages, arguments));
  }

  /// Disconnect from the socket server
  Future<void> disconnect() async {
    if (_hubConnection != null) {
      await _hubConnection!.stop();
      _connectionStatusController.add(ConnectionStatus.disconnected);
    }
  }

  /// Send message to the server
  Future<dynamic> sendMessage(String methodName, List<Object> args) async {
    if (_hubConnection != null && isConnected) {
      return await _hubConnection!.invoke(methodName, args: args);
    } else {
      commonPrint('Hub connection is not established');
      throw Exception('Hub connection is not established');
    }
  }

  /// Register user with hub
  Future<void> registerUser(String userId) async {
    if (_hubConnection != null && isConnected) {
      await _hubConnection!.invoke('EquipmentUserConnected', args: [userId]);
      commonPrint('User registered: $userId');
    } else {
      commonPrint('Cannot register user, hub not connected');
      throw Exception('Hub connection is not established');
    }
  }

  /// Common print function for debugging
  void commonPrint(String message) {
    if (kDebugMode) {
      debugPrint('BuyingSocketService: $message');
    }
  }

  /// Dispose method
  void dispose() {
    disconnect();
    _hubConnection?.stop();
    _hubConnection = null;
    _socketListenerController.close();
    _connectionStatusController.close();
  }
}
