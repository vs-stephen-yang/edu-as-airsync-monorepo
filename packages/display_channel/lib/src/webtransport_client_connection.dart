import "dart:async";
import "dart:convert";
import "package:display_channel/src/webtransport_dart2js.dart";
import "package:display_channel/src/webtransport_client_connection_config.dart";
import 'package:retry/retry.dart';

import "package:display_channel/src/client_connection.dart";

class WebTransportClientConnection implements ClientConnection {
  @override
  void Function()? onConnected;

  @override
  void Function(ConnectError error)? onConnectFailed;

  @override
  void Function()? onConnecting;

  @override
  void Function()? onDisconnected;

  @override
  void Function(Map<String, dynamic> data)? onMessage;

  final String _url;
  final List<String> _hashCertificates;

  final WebTransportClientConnectionConfig _config;

  final RetryOptions _retryOptions;
  int _retryAttempt = 0;
  Timer? _retryTimer;

  var _connected = false;
  var _closed = false;

  WebTransport? _webTransport;

  WebTransportClientConnection(
    this._url,
    this._hashCertificates,
    this._config,
  ) : _retryOptions = RetryOptions(
          maxDelay: _config.retry.maxRetryDelay,
          maxAttempts: _config.retry.maxRetryAttempts,
        );

  @override
  void open() {
    _connect();
  }

  @override
  void close() {
    _closed = true;

    _closeWebTransport();
  }

  void _connect() async {
    _config.logger?.call(_url, "connect");
    if (_closed) {
      return;
    }

    _config.logger?.call(_url, "connecting");
    onConnecting?.call();

    _retryAttempt++;

    _webTransport = WebTransport(_url, _hashCertificates);

    _webTransport?.onOpen = () {
      _config.logger?.call(_url, "connected");

      _connected = true;

      _retryAttempt = 0;
      _retryTimer?.cancel();

      onConnected?.call();
    };

    _webTransport?.onClose = (String? e) => _onClose(e);
    _webTransport?.onError = (String e) => _config.logger?.call(_url, e);
    _webTransport?.onMessage = (String data) {
      final message = jsonDecode(data);
      onMessage?.call(message);
    };
  }

  @override
  void send(Map<String, dynamic> message) {
    final data = jsonEncode(message);
    _webTransport?.send(data);
  }

  _closeWebTransport() {
    _webTransport?.disconnect();
    _webTransport = null;

    _retryTimer?.cancel();
    _retryTimer = null;
  }

  _onClose(String? e) {
    if (_connected) {
      _connected = false;

      _handleDisconnected();
      return;
    }

    // retry
    if (_retryAttempt >= _retryOptions.maxAttempts) {
      onConnectFailed?.call(
        ConnectError(
          ConnectErrorType.webTransport,
          e ?? "",
        ),
      );

      _reconnect();
      return;
    }

    // try to connect later
    _retryTimer?.cancel();
    _retryTimer = Timer(
      _retryOptions.delay(_retryAttempt),
      () {
        _reconnect();
      },
    );
  }

  void _handleDisconnected() async {
    _config.logger?.call(_url, "disconnected");
    onDisconnected?.call();

    await _reconnect();
  }

  Future _reconnect() async {
    _closeWebTransport();

    _connect();
  }
}
