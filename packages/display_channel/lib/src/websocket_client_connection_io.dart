import 'dart:async';
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
  int _gen = 0;

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

  WebSocket? _socket;
  HttpClient? _httpClient;
  StreamSubscription? _socketSubscription;

  ConnectionState _state = ConnectionState.disconnected;

  bool _disconnectionHandled = false;

  WebSocketClientConnection(
    this._url,
    this._config,
  );

  @override
  void open() {
    if (_state == ConnectionState.connecting ||
        _state == ConnectionState.connected) {
      return;
    }

    if (_state == ConnectionState.closed) {
      _state = ConnectionState.disconnected;
    }

    _connect();
  }

  @override
  void close() async {
    if (_state == ConnectionState.closed) {
      return;
    }

    _state = ConnectionState.closed;

    await _closeSocket();
  }

  void _connect() async {
    if (_state == ConnectionState.closed ||
        _state == ConnectionState.connecting) {
      return;
    }

    final myGen = ++_gen;
    _state = ConnectionState.connecting;
    _disconnectionHandled = false;

    _config.logger?.call(_url, "connect");
    _config.logger?.call(_url, "GEN $myGen connecting");
    onConnecting?.call();

    WebSocket? socket;
    try {
      socket = await retry(
        maxDelay: _config.retry.maxRetryDelay,
        maxAttempts: _config.retry.maxRetryAttempts,
        () {
          if (_state == ConnectionState.closed) {
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
          return _state != ConnectionState.closed &&
              (e is SocketException ||
                  e is HttpException ||
                  e is TlsException ||
                  e is WebSocketException);
        },
        onRetry: (p0) {},
      );
    } on HttpException catch (e) {
      await _handleConnectFailed(ConnectErrorType.http, e.toString());
      return;
    } on WebSocketException catch (e) {
      // WebSocketException: Connection to 'https://xxx' was not upgraded to websocket
      await _handleConnectFailed(ConnectErrorType.websocket, e.toString());
      return;
    } on SocketException catch (e) {
      await _handleConnectFailed(ConnectErrorType.socket, e.toString());
      return;
    } on TlsException catch (e) {
      await _handleConnectFailed(ConnectErrorType.socket, e.toString());
      return;
    } on ConnectionClosedException catch (_) {
      return;
    } catch (e) {
      await _handleConnectFailed(ConnectErrorType.unknown, e.toString());
      return;
    }

    if (_state == ConnectionState.closed || myGen != _gen) {
      await socket!.close();
      return;
    }

    _socket = socket;
    _socket!.pingInterval = _config.pingInterval;
    _state = ConnectionState.connected;

    // connected
    _config.logger?.call(_url, "GEN $myGen connected");
    onConnected?.call();

    _socketSubscription = _socket!.listen((dynamic data) {
      if (_state != ConnectionState.connected) {
        return;
      }

      _config.logger?.call(_url, 'Received $data');

      // receive data
      try {
        final message = jsonDecode(data);
        onMessage?.call(message);
      } catch (e) {
        _config.logger?.call(_url, 'Invalid message $data');
      }
    }, onDone: () {
      _config.logger?.call(_url, 'GEN $myGen websocket onDone');
      if (myGen == _gen) {
        // websocket connection closed
        _handleDisconnected(myGen);
      }
    }, onError: (error) {
      _config.logger?.call(_url, 'Gen $myGen websocket onError $error');
      if (myGen == _gen) {
        // websocket connection error
        _handleDisconnected(myGen);
      }
    }, cancelOnError: true);
  }

  @override
  void send(Map<String, dynamic> message) {
    if (_state != ConnectionState.connected || _socket == null) {
      _config.logger?.call(_url, 'Cannot send message: connection not ready');
      return;
    }

    try {
      final data = jsonEncode(message);
      _socket!.add(data);
      _config.logger?.call(_url, 'Sent $data');
    } catch (e) {
      _config.logger?.call(_url, 'Send failed: $e');
    }
  }

  Future<void> _handleConnectFailed(
      ConnectErrorType error, String message) async {
    if (_state == ConnectionState.closed) {
      return;
    }

    onConnectFailed?.call(
      ConnectError(error, message),
    );

    await _reconnect();
  }

  void _handleDisconnected(int expectedGen) async {
    if (expectedGen != _gen) {
      return;
    }

    if (_state == ConnectionState.closed || _disconnectionHandled) {
      return;
    }

    _disconnectionHandled = true;

    _config.logger?.call(_url, "disconnected");
    onDisconnected?.call();

    await _reconnect();
  }

  Future<void> _closeSocket() async {
    await _socketSubscription?.cancel();
    _socketSubscription = null;

    _httpClient?.close(force: true);
    _httpClient = null;

    if (_socket != null) {
      try {
        await _socket!.close();
      } catch (e) {
        _config.logger?.call(_url, 'Error closing socket: $e');
      }
      _socket = null;
    }
  }

  Future<void> _reconnect() async {
    if (_state == ConnectionState.closed) {
      return;
    }

    _state = ConnectionState.disconnecting;

    await _closeSocket();

    if (_state != ConnectionState.closed) {
      _state = ConnectionState.disconnected;
      _connect();
    }
  }
}
