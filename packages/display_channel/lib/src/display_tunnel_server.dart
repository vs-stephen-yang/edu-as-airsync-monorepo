import 'package:display_channel/src/channel_server.dart';
import 'package:display_channel/src/client_connection.dart';
import 'package:display_channel/src/server/connection_request.dart';
import 'package:display_channel/src/server/tunnel/tunnel_connection_server.dart';

class DisplayTunnelServer extends ChannelServer {
  void Function()? onTunnelConnected;
  void Function()? onTunnelConnecting;

  TunnelConnectionServer? _tunnelServer;

  final CreateWebsocketClientConnection _createTunnelConnection;

  DisplayTunnelServer(
    this._createTunnelConnection,
    OnNewChannel onNewChannel,
    VerifyConnectRequest verifyConnectRequest,
  ) : super(
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

    _tunnelServer!.onTunnelConnected = () => onTunnelConnected?.call();
    _tunnelServer!.onTunnelConnecting = () => onTunnelConnecting?.call();

    _tunnelServer!.start();
  }

  @override
  void stop() {
    _tunnelServer?.stop();
  }
}
