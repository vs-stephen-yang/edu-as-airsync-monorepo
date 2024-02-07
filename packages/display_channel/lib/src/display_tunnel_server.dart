import 'package:display_channel/src/channel_server.dart';
import 'package:display_channel/src/client_connection.dart';
import 'package:display_channel/src/server/connection_request.dart';
import 'package:display_channel/src/server/tunnel/tunnel_connection_server.dart';

class DisplayTunnelServer extends ChannelServer {
  void Function()? onTunnelConnected;
  void Function()? onTunnelConnecting;

  TunnelConnectionServer? _tunnelServer;
  final Duration heartbeatInterval;
  final CreateWebsocketClientConnection _createTunnelConnection;

  DisplayTunnelServer(
    this._createTunnelConnection,
    OnNewChannel onNewChannel,
    VerifyConnectRequest verifyConnectRequest, {
    // AWS WebSocket Idle Connection Timeout 10 minutes
    this.heartbeatInterval = const Duration(minutes: 9),
  }) : super(
          onNewChannel,
          verifyConnectRequest,
        );

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
    _tunnelServer = TunnelConnectionServer(
      connection,
      (String clientId, connection) =>
          handleNewConnection(clientId, connection),
      (ConnectionRequest connectionRequest) =>
          verifyConnectionRequest(connectionRequest),
      heartbeatInterval: heartbeatInterval,
    );

    _tunnelServer!.onTunnelConnected = () => onTunnelConnected?.call();
    _tunnelServer!.onTunnelConnecting = () => onTunnelConnecting?.call();

    _tunnelServer!.start();
  }

  @override
  void stop() {
    _tunnelServer?.stop();
  }
}
