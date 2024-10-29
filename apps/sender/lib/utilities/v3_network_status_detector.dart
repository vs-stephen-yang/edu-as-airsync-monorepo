import 'package:connectivity_plus/connectivity_plus.dart';

import 'app_analytics.dart';
import 'log.dart';

class V3NetworkStatusDetector {
  static final V3NetworkStatusDetector _instance =
      V3NetworkStatusDetector._internal();

  factory V3NetworkStatusDetector() {
    return _instance;
  }

  V3NetworkStatusDetector._internal();

  static ensureInitialized() async {
    await _instance._initNetworkStatus();
  }

  final Connectivity _connectivity = Connectivity();

  // Current network connectivity
  ConnectivityResult _connectivityResult = ConnectivityResult.none;

  ConnectivityResult get status => _connectivityResult;

  Future<void> _initNetworkStatus() async {
    final result = await _connectivity.checkConnectivity();
    _connectivityResult = result;
    _connectivity.onConnectivityChanged.listen(_onConnectivityChange);
  }

  void _onConnectivityChange(ConnectivityResult result) {
    if (_connectivityResult == result) {
      return;
    }

    log.info('Network connectivity has changed to $result');
    _connectivityResult = result;

    // Track network connectivity
    AppAnalytics.instance
        .setGlobalProperty('network_connectivity', result.name);
  }

  bool isConnected() {
    return _connectivityResult != ConnectivityResult.none;
  }
}
