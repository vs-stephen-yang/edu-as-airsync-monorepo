import 'dart:io';
import 'dart:convert';
import 'package:display_channel/src/server/connection.dart';
import 'package:display_channel/src/server/idle_connection_timer.dart';

class DirectConnection implements Connection {
  @override
  void Function(Connection connection)? onClosed;

  @override
  void Function(Connection connection, Map<String, dynamic> message)? onMessage;

  late WebSocket _socket;
  late IdleConnectionTimer _idleTimer;
  late Uri _uri;

  DirectConnection(
    WebSocket socket, {
    required Duration idleConnectionTimeout,
    required Uri uri,
  }) {
    _socket = socket;
    _uri = uri;

    _idleTimer = IdleConnectionTimer(
      _onIdleTimeout,
      idleConnectionTimeout,
    );

    _socket.listen((dynamic data) {
      // receive data from the peer
      // reset the idle timer
      _idleTimer.reset();

      final message = jsonDecode(data);
      onMessage?.call(this, message);
    }, onDone: () {
      // websocket connection closed
      _idleTimer.stop();

      onClosed?.call(this);
    }, onError: (error) {
      // websocket connection error
      _idleTimer.stop();

      onClosed?.call(this);
    }, cancelOnError: true);
  }

  @override
  void send(Map<String, dynamic> message) {
    final data = jsonEncode(message);
    _socket.add(data);
  }

  @override
  void close() {
    _socket.close();
  }

  _onIdleTimeout() {
    _idleTimer.stop();
    onClosed?.call(this);
  }

  @override
  Map<String, String>? get queryParameters {
    return _uri.queryParameters;
  }
}
