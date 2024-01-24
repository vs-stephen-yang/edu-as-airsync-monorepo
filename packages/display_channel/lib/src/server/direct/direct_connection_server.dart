import 'dart:io';

import 'package:display_channel/src/channel.dart';
import 'package:display_channel/src/channel_server.dart';
import 'package:display_channel/src/messages/channel_message.dart';
import 'package:display_channel/src/server/connection.dart';
import 'package:display_channel/src/server/connection_request.dart';
import 'package:display_channel/src/server/direct/direct_connection.dart';

class DirectConnectionServer {
  final void Function(String clientId, Connection) _onNewConnection;
  final VerifyConnectRequest _verifyConnectRequest;

  DirectConnectionServer(
    this._onNewConnection,
    this._verifyConnectRequest,
  );

  ConnectionRequest? _parseConnectionRequest(HttpRequest req) {
    final parameters = req.requestedUri.queryParameters;

    final clientId = parameters['clientId'];
    final token = parameters['token'];
    final displayCode = parameters['displayCode'];

    if (clientId == null || token == null || displayCode == null) {
      return null;
    }

    return ConnectionRequest(
      clientId,
      token,
      displayCode,
    );
  }

  Future onHttpRequest(HttpRequest httpRequest) async {
    final connectionRequest = _parseConnectionRequest(httpRequest);

    if (connectionRequest == null) {
      // invalid http request
      httpRequest.response.close();
      return;
    }

    final websocket = await WebSocketTransformer.upgrade(httpRequest);

    final connection = DirectConnection(websocket);

    // authenticate the connectin request
    if (_verifyConnectRequest(connectionRequest) !=
        ConnectRequestStatus.success) {
      // reject the connection
      connection.send(ChannelClosedMessage(
        Reason(
          ChannelCloseCode.authenticationError.index,
          text: 'Wrong OTP',
        ),
      ).toJson());

      // TODO: disconnect the connection
      return;
    }

    _onNewConnection(connectionRequest.clientId, connection);
  }
}
