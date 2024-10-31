import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConnectivityProvider extends ChangeNotifier {
  static const platform =
      MethodChannel('com.mvbcast.crosswalk/wifi_signal_strength');

  ConnectivityProvider() {
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  final Connectivity _connectivity = Connectivity();

  get connectionStatus => _connectionStatus;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;

  get signalStrength => _signalStrength;
  int _signalStrength = -1;

  Future<bool> checkInternetConnection() async {
    if (_connectionStatus == ConnectivityResult.none) {
      return false;
    }

    // Try pinging a public internet address
    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true; // Connect to Internet
      }
    } on SocketException catch (_) {
      return false; // Only connect to Intranet
    }

    return false;
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e, stack) {
      log.severe('Could not check connectivity status', e, stack);
      return;
    }

    return _updateConnectionStatus(result);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    _connectionStatus = result;
    if (_connectionStatus == ConnectivityResult.wifi) {
      await _getWifiSignalStrength();
    } else {
      _signalStrength = -1;
    }
    notifyListeners();
  }

  Future<void> _getWifiSignalStrength() async {
    try {
      _signalStrength = await platform.invokeMethod('getWifiSignalStrength');
      log.info('Wifi signalStrength: $_signalStrength');
    } on PlatformException catch (e) {
      _signalStrength = -1;
      log.severe("Failed to get Wi-Fi signal strength", e);
    }
  }
}
