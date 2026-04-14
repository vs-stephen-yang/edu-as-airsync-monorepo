import 'dart:async';
import 'dart:io';

import 'package:display_channel/src/channel_store.dart';
import 'package:display_channel/src/messages/channel_message.dart';
import 'package:display_channel/src/server/connection.dart';
import 'package:display_channel/src/server/connection_request.dart';
import 'package:display_channel/src/server/direct/direct_connection.dart';
import 'package:display_channel/src/util/channel_message_util.dart';

class DirectConnectionServer {
  final void Function(String clientId, Connection) _onNewConnection;
  final VerifyConnectRequest _verifyConnectRequest;

  static const defaultPingInterval = Duration(seconds: 2);

  final Duration idleConnectionTimeout;
  // websocket ping interval
  final Duration pingInterval;

  DirectConnectionServer(
    this._onNewConnection,
    this._verifyConnectRequest, {
    required this.idleConnectionTimeout,
    this.pingInterval = defaultPingInterval,
  });

  ConnectionRequest? _parseConnectionRequest(HttpRequest req) {
    final parameters = req.requestedUri.queryParameters;

    final clientId = parameters['clientId'];
    final token = parameters['token'];
    final displayCode = parameters['displayCode'];

    if (clientId == null || token == null || displayCode == null) {
      return null;
    }
    final clientIpAddress = req.connectionInfo?.remoteAddress.address;

    return ConnectionRequest(
      clientId,
      token,
      displayCode,
      clientIpAddress,
      queryParameters: parameters,
    );
  }

  Future onHttpRequest(HttpRequest httpRequest) async {
    final connectionRequest = _parseConnectionRequest(httpRequest);

    final websocket = await WebSocketTransformer.upgrade(httpRequest);
    websocket.pingInterval = pingInterval;

    final connection = DirectConnection(
      websocket,
      idleConnectionTimeout: idleConnectionTimeout,
      uri: httpRequest.uri,
    );

    if (connectionRequest == null) {
      // invalid http request
      final reason = convertConnectRequestStatusToReason(
          ConnectRequestStatus.authenticationRequired);
      connection.send(ChannelClosedMessage(reason).toJson());

      Timer(const Duration(seconds: 10), () async {
        await httpRequest.response.close();
      });

      return;
    }

    // authenticate the connectin request
    final status = _verifyConnectRequest(connectionRequest);
    if (status != ConnectRequestStatus.success) {
      // reject the connection
      final reason = convertConnectRequestStatusToReason(status);

      connection.send(ChannelClosedMessage(reason).toJson());

      // TODO: disconnect the connection
      return;
    }

    _onNewConnection(connectionRequest.clientId, connection);
  }
}
