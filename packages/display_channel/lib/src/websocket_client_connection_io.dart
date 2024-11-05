import 'dart:io';
import 'dart:convert';
import 'package:display_channel/src/client_connection.dart';
import 'package:display_channel/src/websocket_client_connection_config.dart';
import 'package:retry/retry.dart';

class ConnectionClosedException implements Exception {
  final String message;

  ConnectionClosedException(
      [this.message =
          'Connection was aborted because the WebSocketClientConnection is already closed.']);

  @override
  String toString() => 'ConnectionClosedException: $message';
}

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

  final WebSocketClientConnectionConfig _config;

  WebSocket? _socket;
  HttpClient? _httpClient;

  WebSocketClientConnection(
    this._url,
    this._config,
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

    WebSocket? socket;
    try {
      socket = await retry(
        maxDelay: _config.retry.maxRetryDelay,
        maxAttempts: _config.retry.maxRetryAttempts,
        () {
          if (_closed) {
            throw ConnectionClosedException();
          }

          _httpClient = HttpClient();
          _httpClient!.connectionTimeout = _config.connectionTimeout;

          // Determine whether to allow self-signed certificates.
          _httpClient!.badCertificateCallback =
              (X509Certificate cert, String host, int port) =>
                  _config.allowSelfSignedCertificates;

          return WebSocket.connect(
            _url,
            customClient: _httpClient,
          );
        },
        retryIf: (e) {
          _config.logger?.call(_url, e.toString());
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
    } on ConnectionClosedException catch (_) {
      return;
    }

    if (_closed) {
      await socket!.close();
      return;
    }

    _socket = socket;
    _socket!.pingInterval = _config.pingInterval;

    // connected
    _config.logger?.call(_url, "connected");
    onConnected?.call();

    _socket!.listen((dynamic data) {
      _config.logger?.call(_url, 'Received $data');

      // receive data
      try {
        final message = jsonDecode(data);
        onMessage?.call(message);
      } catch (e) {
        _config.logger?.call(_url, 'Invalid message $data');
      }
    }, onDone: () {
      _config.logger?.call(_url, 'websocket onDone');

      // websocket connection closed
      _handleDisconnected();
    }, onError: (error) {
      _config.logger?.call(_url, 'websocket onError $error');

      // websocket connection error
      _handleDisconnected();
    }, cancelOnError: true);
  }

  @override
  void send(Map<String, dynamic> message) {
    final data = jsonEncode(message);
    _socket?.add(data);

    _config.logger?.call(_url, 'Sent $data');
  }

  void _handleConnectFailed(ConnectErrorType error, String message) async {
    if (_closed) {
      return;
    }

    onConnectFailed?.call(
      ConnectError(error, message),
    );

    await _reconnect();
  }

  void _handleDisconnected() async {
    if (_closed) {
      return;
    }

    _config.logger?.call(_url, "disconnected");
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
