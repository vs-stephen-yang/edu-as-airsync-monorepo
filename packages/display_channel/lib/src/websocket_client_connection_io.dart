import 'dart:io';
import 'dart:convert';
import 'package:display_channel/src/client_connection.dart';
import 'package:retry/retry.dart';

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
  var _closed = false;

  void Function(String url, String message)? logger;

  static const defaultPingInterval = Duration(seconds: 1);
  static const defaultConnectionTimeout = Duration(seconds: 1);
  static const defaultMaxRetryDelay = Duration(seconds: 15);
  static const defaultMaxRetryAttempts = 8;

  Duration pingInterval;
  Duration connectionTimeout;
  Duration maxRetryDelay;
  int maxRetryAttempts;
  bool allowSelfSignedCertificates;

  WebSocket? _socket;
  HttpClient? _httpClient;

  WebSocketClientConnection(
    this._url, {
    this.pingInterval = defaultPingInterval,
    this.connectionTimeout = defaultConnectionTimeout,
    this.maxRetryDelay = defaultMaxRetryDelay,
    this.maxRetryAttempts = defaultMaxRetryAttempts,
    this.allowSelfSignedCertificates = false,
    this.logger,
  });

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
    logger?.call(_url, "connect");
    if (_closed) {
      return;
    }

    logger?.call(_url, "connecting");
    onConnecting?.call();

    WebSocket? socket;
    try {
      socket = await retry(
        maxDelay: maxRetryDelay,
        maxAttempts: maxRetryAttempts,
        () {
          _httpClient = HttpClient();
          _httpClient!.connectionTimeout = connectionTimeout;

          // Determine whether to allow self-signed certificates.
          _httpClient!.badCertificateCallback =
              (X509Certificate cert, String host, int port) =>
                  allowSelfSignedCertificates;

          return WebSocket.connect(
            _url,
            customClient: _httpClient,
          );
        },
        retryIf: (e) {
          logger?.call(_url, e.toString());
          return !_closed &&
              (e is SocketException ||
                  e is HttpException ||
                  e is WebSocketException);
        },
        onRetry: (p0) {},
      );
    } on HttpException catch (e) {
      _handleConnectFailed(ConnectErrorType.http, e.toString());
      return;
    } on WebSocketException catch (e) {
      // WebSocketException: Connection to 'https://xxx' was not upgraded to websocket
      _handleConnectFailed(ConnectErrorType.websocket, e.toString());
      return;
    } on SocketException catch (e) {
      _handleConnectFailed(ConnectErrorType.socket, e.toString());
      return;
    }
    if (_closed) {
      await socket!.close();
      return;
    }

    _socket = socket;
    _socket!.pingInterval = pingInterval;

    // connected
    logger?.call(_url, "connected");
    onConnected?.call();

    _socket!.listen((dynamic data) {
      logger?.call(_url, 'Received $data');

      // receive data
      final message = jsonDecode(data);
      onMessage?.call(message);
    }, onDone: () {
      logger?.call(_url, 'websocket onDone');

      // websocket connection closed
      _handleDisconnected();
    }, onError: (error) {
      logger?.call(_url, 'websocket onError $error');

      // websocket connection error
      _handleDisconnected();
    }, cancelOnError: true);
  }

  @override
  void send(Map<String, dynamic> message) {
    final data = jsonEncode(message);
    _socket?.add(data);

    logger?.call(_url, 'Sent $data');
  }

  void _handleConnectFailed(ConnectErrorType error, String message) async {
    onConnectFailed?.call(
      ConnectError(error, message),
    );

    await _reconnect();
  }

  void _handleDisconnected() async {
    logger?.call(_url, "disconnected");
    onDisconnected?.call();

    await _reconnect();
  }

  void _closeSocket() {
    _httpClient?.close(force: true);
    _httpClient = null;

    _socket?.close();
    _socket = null;
  }

  Future _reconnect() async {
    _closeSocket();

    _connect();
  }
}
