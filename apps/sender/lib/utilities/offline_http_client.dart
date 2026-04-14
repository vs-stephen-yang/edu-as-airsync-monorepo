import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart';
import 'package:display_cast_flutter/utilities/caching_http_client.dart';

/// A wrapper for CachingHttpClient that triggers flush() when connectivity is restored.
class OfflineHttpClient extends BaseClient {
  final CachingHttpClient _client;
  late final StreamSubscription<ConnectivityResult> _subscription;

  ConnectivityResult? _lastConnectivity;

  OfflineHttpClient(this._client) {
    final connectivity = Connectivity();

    _subscription = connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) {
        if (_lastConnectivity != result) {
          _lastConnectivity = result;

          _onConnectivityChange(result);
        }
      },
    );
  }

  void _onConnectivityChange(ConnectivityResult result) {
    // When connectivity is restored (not 'none'), trigger flush.
    if (result != ConnectivityResult.none) {
      _client.flush();
    }
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    return _client.send(request);
  }

  void dispose() {
    _subscription.cancel();
  }
}
