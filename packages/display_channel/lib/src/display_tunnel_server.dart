import 'package:display_channel/src/channel_store.dart';
import 'package:display_channel/src/client_connection.dart';
import 'package:display_channel/src/server/connection_request.dart';
import 'package:display_channel/src/server/tunnel/tunnel_connection_server.dart';

class DisplayTunnelServer {
  void Function()? onTunnelConnected;
  void Function()? onTunnelConnecting;

  final ChannelStore _store;
  TunnelConnectionServer? _tunnelServer;
  final CreateWebsocketClientConnection _createTunnelConnection;

  late Duration _idleClientConnectionTimeout;

  DisplayTunnelServer(
    this._createTunnelConnection,
    OnNewChannel onNewChannel,
    VerifyConnectRequest verifyConnectRequest, {
    // the heartbeat interval for client connections
    Duration heartbeatInterval = const Duration(seconds: 10),
    // the hearbeat timeout for client connections
    Duration heartbeatTimeout = const Duration(seconds: 10),
    Duration reconnectTimeout = const Duration(seconds: 2),
  }) : _store = ChannelStore(
          onNewChannel,
          verifyConnectRequest,
          // the heartbeat interval for client connections
          heartbeatInterval: heartbeatInterval,
          // the heartbeat timeout for client connections
          heartbeatTimeout: heartbeatTimeout,
          reconnectTimeout: reconnectTimeout,
        ) {
    // idle connection timeout=heartbeat interval + heartbeat timeout
    _idleClientConnectionTimeout = heartbeatInterval + heartbeatTimeout;
  }

  void start(
    String instanceId,
    String tunnelServiceUrl, {
    // AWS WebSocket Idle Connection Timeout 10 minutes
    Duration tunnelHeartbeatInterval = const Duration(minutes: 9),
  }) {
    final uri = Uri.parse(tunnelServiceUrl);

    final uriWithParameters = uri.replace(queryParameters: {
      'role': 'server',
      'instanceId': instanceId,
    });

    final connection = _createTunnelConnection(
      uriWithParameters.toString(),
      false,
    );

    _tunnelServer = TunnelConnectionServer(
      connection,
      (String clientId, connection) =>
          _store.handleNewConnection(clientId, connection),
      (ConnectionRequest connectionRequest) =>
          _store.verifyConnectionRequest(connectionRequest),
      // heartbeat interval for the tunnel connection
      heartbeatInterval: tunnelHeartbeatInterval,
      // the idle timeout for client connections
      idleConnectionTimeout: _idleClientConnectionTimeout,
    );

    _tunnelServer!.onTunnelConnected = () => onTunnelConnected?.call();
    _tunnelServer!.onTunnelConnecting = () => onTunnelConnecting?.call();

    _tunnelServer!.start();
  }

  void stop() {
    _tunnelServer?.stop();
  }
}
