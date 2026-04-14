import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';

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

  String? get ssidName => _ssidName;
  String? _ssidName;

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
      await _getWifiSSIDName();
    } else {
      _signalStrength = -1;
      _ssidName = null;
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

  Future<void> _getWifiSSIDName() async {
    final startTime = DateTime.now();
    const retryDelay = Duration(milliseconds: 500);
    const timeout = Duration(seconds: 30);

    // Keep trying while connected to Wi-Fi and within 30 seconds
    while (_connectionStatus == ConnectivityResult.wifi &&
        DateTime.now().difference(startTime) < timeout) {
      try {
        String? ssid = await NetworkInfo().getWifiName();
        _ssidName = ssid?.replaceAll('"', '');
        log.info('Wi-Fi SSID name: $_ssidName');
      } on PlatformException catch (e) {
        _ssidName = null;
        log.severe('Failed to get Wi-Fi SSID name', e);
      }

      // Stop retrying if SSID was successfully retrieved
      if (_ssidName != null && _ssidName!.isNotEmpty) {
        log.info('SSID retrieved successfully: $_ssidName');
        break;
      }

      // Wait before next retry
      await Future.delayed(retryDelay);
    }

    if (_ssidName == null || _ssidName!.isEmpty) {
      log.warning('SSID not obtained within 30 seconds or connection lost');
    }
  }
}
