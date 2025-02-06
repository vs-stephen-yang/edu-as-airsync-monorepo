import "dart:async";
import "dart:convert";
import "package:display_channel/src/websocket_client_connection_config.dart";
import 'package:retry/retry.dart';

import "package:display_channel/src/client_connection.dart";
import "package:universal_html/html.dart";

class WebSocketClientConnection implements ClientConnection {
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

  final WebSocketClientConnectionConfig _config;

  final RetryOptions _retryOptions;
  int _retryAttempt = 0;
  Timer? _retryTimer;

  var _connected = false;
  var _closed = false;

  WebSocket? _socket;

  WebSocketClientConnection(
    this._url,
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

    _closeSocket();
  }

  void _connect() async {
    _config.logger?.call(_url, "connect");
    if (_closed) {
      return;
    }

    _config.logger?.call(_url, "connecting");
    onConnecting?.call();

    _retryAttempt++;

    _socket = WebSocket(
      _url,
    );

    _socket?.onOpen.listen((Event e) {
      _config.logger?.call(_url, "connected");

      _connected = true;

      _retryAttempt = 0;
      _retryTimer?.cancel();

      onConnected?.call();
    });

    _socket?.onClose.listen(_onSocketClose);

    _socket?.onMessage.listen((MessageEvent e) {
      final message = jsonDecode(e.data);
      onMessage?.call(message);
    });
  }

  @override
  void send(Map<String, dynamic> message) {
    if (_socket?.readyState != WebSocket.OPEN) {
      _config.logger?.call(
          _url, "WebSocket is not open. Current state: ${_socket?.readyState}");
      return;
    }

    final data = jsonEncode(message);
    _socket?.send(data);
  }

  _closeSocket() {
    _socket?.close();
    _socket = null;

    _retryTimer?.cancel();
    _retryTimer = null;
  }

  _onSocketClose(CloseEvent e) {
    if (_connected) {
      _connected = false;

      _handleDisconnected();
      return;
    }

    // retry
    if (_retryAttempt >= _retryOptions.maxAttempts) {
      onConnectFailed?.call(
        ConnectError(
          ConnectErrorType.websocket,
          "code=${e.code} reason=${e.reason}",
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
    _closeSocket();

    _connect();
  }
}
