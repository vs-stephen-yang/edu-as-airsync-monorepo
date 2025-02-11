import 'dart:convert';
import 'package:display_channel/src/server/connection.dart';
import 'package:display_channel/src/server/idle_connection_timer.dart';
import 'package:flutter_golang_server/flutter_webtransport.dart';

class WebTransportConnection implements Connection {
  @override
  void Function(Connection connection)? onClosed;

  @override
  void Function(Connection connection, Map<String, dynamic> message)? onMessage;

  late String _connId;

  @override
  late Map<String, String> queryParameters;

  late FlutterWebtransport _webTransport;
  late IdleConnectionTimer _idleTimer;

  WebTransportConnection(
    FlutterWebtransport webTransport, {
    required String connId,
    required Duration idleConnectionTimeout,
    required Map<String, String> queryParam,
  }) {
    _webTransport = webTransport;
    queryParameters = queryParam;
    _connId = connId;

    _idleTimer = IdleConnectionTimer(
      _onIdleTimeout,
      idleConnectionTimeout,
    );
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

  _onIdleTimeout() {
    _idleTimer.stop();
    onClosed?.call(this);
  }

  void resetIdleTimeout() {
    _idleTimer.reset();
  }
}
