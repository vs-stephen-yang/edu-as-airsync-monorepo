import 'dart:io';
import 'dart:convert';
import 'package:display_channel/src/client_connection.dart';
import 'package:retry/retry.dart';

class WebSocketClientConnection implements ClientConnection {
  @override
  void Function()? onConnected;

  @override
  void Function()? onConnectFailed;

  @override
  void Function()? onConnecting;

  @override
  void Function()? onDisconnected;

  @override
  void Function(Map<String, dynamic> data)? onMessage;

  final String _url;
  final Map<String, String> _headers;
  var _closed = false;

  static const defaultPingInterval = Duration(seconds: 1);
  static const defaultConnectionTimeout = Duration(seconds: 1);
  static const defaultMaxRetryDelay = Duration(seconds: 15);
  static const defaultMaxRetryAttempts = 8;

  Duration pingInterval;
  Duration connectionTimeout;
  Duration maxRetryDelay;
  int maxRetryAttempts;

  WebSocket? _socket;

  WebSocketClientConnection(
    this._url,
    this._headers, {
    this.pingInterval = defaultPingInterval,
    this.connectionTimeout = defaultConnectionTimeout,
    this.maxRetryDelay = defaultMaxRetryDelay,
    this.maxRetryAttempts = defaultMaxRetryAttempts,
  });

  @override
  void open() {
    _connect();
  }

  @override
  Future<void> close() async {
    _closed = true;

    await _closeSocket();
  }

  void _connect() async {
    if (_closed) {
      return;
    }

    onConnecting?.call();

    try {
      _socket = await retry(
        maxDelay: maxRetryDelay,
        maxAttempts: maxRetryAttempts,
        () {
          final httpClient = HttpClient();
          httpClient.connectionTimeout = connectionTimeout;

          return WebSocket.connect(
            _url,
            headers: _headers,
            customClient: httpClient,
          );
        },
        retryIf: (e) {
          return !_closed &&
              (e is SocketException ||
                  e is HttpException ||
                  e is WebSocketException);
        },
        onRetry: (p0) {},
      );
    } on HttpException {
      _handleConnectFailed();
      return;
    } on WebSocketException {
      // WebSocketException: Connection to 'https://xxx' was not upgraded to websocket
      _handleConnectFailed();
      return;
    } on SocketException {
      _handleConnectFailed();
      return;
    }

    _socket!.pingInterval = pingInterval;

    // connected
    onConnected?.call();

    _socket!.listen((dynamic data) {
      // receive data
      final message = jsonDecode(data);
      onMessage?.call(message);
    }, onDone: () {
      // websocket connection closed
      _handleDisconnected();
    }, onError: (error) {
      // websocket connection error
      _handleDisconnected();
    }, cancelOnError: true);
  }

  @override
  void send(Map<String, dynamic> message) {
    final data = jsonEncode(message);
    _socket?.add(data);
  }

  void _handleConnectFailed() async {
    onConnectFailed?.call();

    await _reconnect();
  }

  void _handleDisconnected() async {
    onDisconnected?.call();

    await _reconnect();
  }

  Future _closeSocket() async {
    await _socket?.close();
    _socket = null;
  }

  Future _reconnect() async {
    await _closeSocket();

    _connect();
  }
}
