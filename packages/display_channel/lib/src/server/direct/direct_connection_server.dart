import 'dart:io';

import 'package:display_channel/display_channel.dart';
import 'package:display_channel/src/server/direct/direct_connection.dart';

class DirectConnectionServer {
  final void Function(String clientId, Connection) _onNewConnection;
  final bool Function(ConnectionRequest) _authenticationHandler;

  DirectConnectionServer(
    this._onNewConnection,
    this._authenticationHandler,
  );

  ConnectionRequest? _parseConnectionRequest(HttpRequest req) {
    final parameters = req.requestedUri.queryParameters;

    final clientId = parameters['clientId'];
    final token = parameters['token'];

    if (clientId == null || token == null) {
      return null;
    }

    return ConnectionRequest(
      clientId,
      token,
    );
  }

  void onWsConnection(WebSocket ws, HttpRequest httpRequest) {
    final connectionRequest = _parseConnectionRequest(httpRequest);

    if (connectionRequest == null) {
      // invalid http request
      ws.close();
      return;
    }

    final connection = DirectConnection(ws);

    // authenticate the connectin request
    if (!_authenticationHandler(connectionRequest)) {
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
