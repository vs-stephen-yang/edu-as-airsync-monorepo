import 'dart:convert';
import 'package:display_channel/src/server/connection.dart';
import 'package:display_channel/src/server/idle_connection_timer.dart';
import 'package:flutter_golang_server/flutter_webtransport.dart';

class WebTransportConnection implements Connection {
  @override
  void Function(Connection connection)? onClosed;

  @override
  void Function(Connection connection, Map<String, dynamic> message)? onMessage;

  @override
  final Map<String, String> queryParameters;

  final FlutterWebtransport _webTransport;
  late IdleConnectionTimer _idleTimer;
  final String _connId;

  WebTransportConnection(
    this._webTransport,
    this._connId,
    this.queryParameters, {
    required Duration idleConnectionTimeout,
  }) {
    _idleTimer = IdleConnectionTimer(_onIdleTimeout, idleConnectionTimeout);
  }

  @override
  void send(Map<String, dynamic> message) {
    final data = jsonEncode(message);
    _webTransport.sendMessage(_connId, data);
  }

  @override
  void close() {
    _webTransport.closeWebTransportConn(_connId);
  }

  void _onIdleTimeout() {
    _idleTimer.stop();
    onClosed?.call(this);
  }

  void resetIdleTimeout() {
    _idleTimer.reset();
  }
}
