import 'dart:async';

import 'package:display_channel/src/channel_server.dart';
import 'package:display_channel/src/client_connection.dart';
import 'package:display_channel/src/server/connection_request.dart';
import 'package:display_channel/src/server/tunnel/tunnel_connection_server.dart';

class DisplayTunnelServer extends ChannelServer {
  void Function()? onTunnelConnected;
  void Function()? onTunnelConnecting;

  TunnelConnectionServer? _tunnelServer;

  Duration reconnectionTimeoutDuration;
  Timer? _reconnectionTimer;

  final CreateWebsocketClientConnection _createTunnelConnection;

  DisplayTunnelServer(
    this._createTunnelConnection,
    OnNewChannel onNewChannel,
    VerifyConnectRequest verifyConnectRequest, {
    this.reconnectionTimeoutDuration = const Duration(seconds: 2),
  }) : super(
          onNewChannel,
          verifyConnectRequest,
        );

  void start(
    String instanceId,
    String tunnelServiceUrl,
  ) {
    _tunnelServer = TunnelConnectionServer(
      instanceId,
      tunnelServiceUrl,
      (String url) => _createTunnelConnection(url),
      (String clientId, connection) =>
          handleNewConnection(clientId, connection),
      (ConnectionRequest connectionRequest) =>
          verifyConnectionRequest(connectionRequest),
    );

    _tunnelServer!.onTunnelConnected = () {
      _reconnectionTimer?.cancel();
      _reconnectionTimer = null;

      onTunnelConnected?.call();
    };

    _tunnelServer!.onTunnelConnecting = () {
      onTunnelConnecting?.call();

      _reconnectionTimer ??= Timer(reconnectionTimeoutDuration, () {
        // the tunnel connection is not re-established within the timeout
        // close all of the channels
        super.closeAllChannels();
      });
    };

    _tunnelServer!.start();
  }

  @override
  void stop() {
    _tunnelServer?.stop();
  }
}
