import 'dart:io';
import 'dart:convert';
import 'package:display_channel/src/client_connection.dart';
import 'package:retry/retry.dart';

class WebSocketClientConnection implements ClientConnection {
  @override
  void Function()? onConnected;

  @override
  void Function()? onConnecting;

  @override
  void Function(Map<String, dynamic> data)? onMessage;

  final String _url;
  final Map<String, String> _headers;
  var _closed = false;

  static const defaultPingInterval = Duration(seconds: 1);
  static const defaultConnectionTimeout = Duration(seconds: 1);
  static const defaultMaxRetryDelay = Duration(seconds: 15);

  WebSocket? _socket;

  WebSocketClientConnection(
    this._url,
    this._headers,
  );

  @override
  void open() {
    _connect();
  }

  @override
  void close() {
    _closed = true;
    _socket?.close();
  }

  void _connect() async {
    onConnecting?.call();

    try {
      _socket = await retry(
        maxDelay: defaultMaxRetryDelay,
        () {
          final httpClient = HttpClient();
          httpClient.connectionTimeout = defaultConnectionTimeout;

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
      _handleDisconnected();
      return;
    } on WebSocketException {
      // WebSocketException: Connection to 'https://xxx' was not upgraded to websocket
      _handleDisconnected();
      return;
    } on SocketException {
      _handleDisconnected();
      return;
    }

    _socket!.pingInterval = defaultPingInterval;

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

  void _handleDisconnected() {
    _socket?.close();
    _socket = null;

    _connect();
  }
}
