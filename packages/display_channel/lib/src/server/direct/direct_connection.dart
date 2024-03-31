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

  DirectConnection(
    WebSocket socket, {
    required Duration idleConnectionTimeout,
  }) {
    _socket = socket;

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
}
