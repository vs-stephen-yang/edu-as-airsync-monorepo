import "dart:async";
import "dart:convert";
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

  static const defaultConnectionTimeout = Duration(seconds: 1);

  final RetryOptions _retryOptions;
  int _retryAttempt = 0;
  Timer? _retryTimer;

  static const defaultMaxRetryDelay = Duration(seconds: 15);
  static const defaultMaxRetryAttempts = 8;

  var _connected = false;
  var _closed = false;

  void Function(String url, String message)? logger;

  WebSocket? _socket;

  WebSocketClientConnection(
    this._url, {
    this.logger,
    connectionTimeout = defaultConnectionTimeout,
    maxRetryDelay = defaultMaxRetryDelay,
    maxRetryAttempts = defaultMaxRetryAttempts,
  }) : _retryOptions = RetryOptions(
          maxDelay: maxRetryDelay,
          maxAttempts: maxRetryAttempts,
        );

  @override
  void open() {
    _connect();
  }

  @override
  Future<void> close() async {
    _closed = true;

    _closeSocket();
  }

  void _connect() async {
    logger?.call(_url, "connect");
    if (_closed) {
      return;
    }

    logger?.call(_url, "connecting");
    onConnecting?.call();

    _retryAttempt++;

    _socket = WebSocket(
      _url,
    );

    _socket?.onOpen.listen((Event e) {
      logger?.call(_url, "connected");

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
    logger?.call(_url, "disconnected");
    onDisconnected?.call();

    await _reconnect();
  }

  Future _reconnect() async {
    _closeSocket();

    _connect();
  }
}
