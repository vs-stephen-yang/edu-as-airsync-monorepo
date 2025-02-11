import 'dart:convert';
import 'package:display_channel/src/channel_store.dart';
import 'package:display_channel/src/messages/channel_message.dart';
import 'package:display_channel/src/server/connection.dart';
import 'package:display_channel/src/server/connection_request.dart';
import 'package:display_channel/src/server/direct/webtransport_connection.dart';
import 'package:display_channel/src/util/channel_message_util.dart';
import 'package:flutter_golang_server/flutter_webtransport.dart';

class WebTransportConnectionServer {
  final void Function(String clientId, Connection) _onNewConnection;
  final VerifyConnectRequest _verifyConnectRequest;
  final FlutterWebtransport _webTransport;

  final _connections = <String, WebTransportConnection>{};

  static const defaultPingInterval = Duration(seconds: 2);

  final Duration idleConnectionTimeout;

  WebTransportConnectionServer(
    this._webTransport,
    this._onNewConnection,
    this._verifyConnectRequest, {
    required this.idleConnectionTimeout,
  });

  ConnectionRequest? _generateConnectionRequest(
      Map<String, String> parameters) {
    final clientId = parameters['clientId'];
    final token = parameters['token'];
    final displayCode = parameters['displayCode'];

    if (clientId == null || token == null || displayCode == null) {
      return null;
    }

    return ConnectionRequest(clientId, token, displayCode, null);
  }

  Future onConnect(String connId, String queryStr) async {
    final Map<String, dynamic> decodedMap = await jsonDecode(queryStr);
    Map<String, String> parameters = decodedMap.map(
          (key, value) => MapEntry(key, value.toString()),
    );

    final connectionRequest = _generateConnectionRequest(parameters);

    if (connectionRequest == null) {
      await _webTransport.closeWebTransportConn(connId);
      return;
    }

    final connection = WebTransportConnection(
      _webTransport,
      idleConnectionTimeout: idleConnectionTimeout,
      queryParam: parameters,
      connId: connId,
    );

    // authenticate the connection request
    final status = _verifyConnectRequest(connectionRequest!);
    if (status != ConnectRequestStatus.success) {
      // reject the connection
      final reason = convertConnectRequestStatusToReason(status);

      connection.send(ChannelClosedMessage(reason).toJson());

      // TODO: disconnect the connection
      return;
    }

    _connections[connId] = connection;
    _onNewConnection(connectionRequest.clientId, connection);
  }

  void onMessage(String connId, String message) {
    var connection = _connections[connId];
    if (connection == null) {
      return;
    }

    // receive data from the peer
    // reset the idle timer
    connection.resetIdleTimeout();

    final data = jsonDecode(message);
    connection.onMessage?.call(connection, data);
  }

  void onClose(String connId) {
    var connection = _connections[connId];
    if (connection == null) {
      return;
    }
    connection.onClosed?.call(connection);
    _connections.remove(connId);
  }
}
