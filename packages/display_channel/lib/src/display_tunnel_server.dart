import 'dart:async';

import 'package:display_channel/src/channel_server.dart';
import 'package:display_channel/src/client_connection.dart';
import 'package:display_channel/src/server/connection_request.dart';
import 'package:display_channel/src/server/tunnel/tunnel_connection_server.dart';

class DisplayTunnelServer extends ChannelServer {
  void Function()? onTunnelConnected;
  void Function()? onTunnelConnecting;

  TunnelConnectionServer? _tunnelServer;
  ClientConnection? _tunnelConnection;

  Duration reconnectionTimeoutDuration;
  Timer? _reconnectionTimer;

  // Tunnel Heartbeat
  // Avoid disconnection caused by AWS WebSocket Idle Connection Timeout.
  Timer? _heartbeatTimer;
  final Duration heartbeatInterval;

  final CreateWebsocketClientConnection _createTunnelConnection;

  DisplayTunnelServer(
    this._createTunnelConnection,
    OnNewChannel onNewChannel,
    VerifyConnectRequest verifyConnectRequest, {
    this.reconnectionTimeoutDuration = const Duration(seconds: 2),
    // AWS WebSocket Idle Connection Timeout 10 minutes
    this.heartbeatInterval = const Duration(minutes: 9),
  }) : super(
          onNewChannel,
          verifyConnectRequest,
        );

  _enableHeartbeat(bool enable) {
    if (enable) {
      // Avoid disconnection caused by AWS WebSocket Idle Connection Timeout.
      // https://docs.aws.amazon.com/apigateway/latest/developerguide/limits.html

      _heartbeatTimer?.cancel();
      _heartbeatTimer = Timer.periodic(heartbeatInterval, (Timer timer) {
        _tunnelServer?.onHearbeatTick();
      });
    } else {
      _heartbeatTimer?.cancel();
      _heartbeatTimer = null;
    }
  }

  _enableReconnectionTimer(bool enable) {
    if (enable) {
      _reconnectionTimer ??= Timer(reconnectionTimeoutDuration, () {
        // if the tunnel connection is not re-established within the timeout,
        // close all of the channels
        super.closeAllChannels();
      });
    } else {
      _reconnectionTimer?.cancel();
      _reconnectionTimer = null;
    }
  }

  void start(
    String instanceId,
    String tunnelServiceUrl,
  ) {
    final uri = Uri.parse(tunnelServiceUrl);

    final uriWithParameters = uri.replace(queryParameters: {
      'role': 'server',
      'instanceId': instanceId,
    });

    final connection = _createTunnelConnection(
      uriWithParameters.toString(),
    );

    connection.onConnected = () {
      _enableReconnectionTimer(false);

      onTunnelConnected?.call();
    };

    connection.onDisconnected = () {
      _enableReconnectionTimer(true);
    };

    connection.onConnecting = () {
      onTunnelConnecting?.call();
    };

    _tunnelServer = TunnelConnectionServer(
      connection,
      (String clientId, connection) =>
          handleNewConnection(clientId, connection),
      (ConnectionRequest connectionRequest) =>
          verifyConnectionRequest(connectionRequest),
    );

    connection.open();

    _tunnelConnection = connection;
  }

  @override
  void stop() {
    _enableReconnectionTimer(false);

    _enableHeartbeat(false);

    _tunnelConnection?.close();
  }
}
