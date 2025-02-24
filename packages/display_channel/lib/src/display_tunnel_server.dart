import 'package:display_channel/src/api/api_request.dart';
import 'package:display_channel/src/channel_store.dart';
import 'package:display_channel/src/client_connection.dart';
import 'package:display_channel/src/server/connection_request.dart';
import 'package:display_channel/src/server/tunnel/tunnel_connection_server.dart';
import 'package:display_channel/src/util/uri_util.dart';

class DisplayTunnelServer {
  void Function()? onTunnelConnected;
  void Function()? onTunnelConnecting;

  final ChannelStore _store;
  TunnelConnectionServer? _tunnelServer;
  final CreateClientConnection _createWebSocketConnection;

  Uri? _tunnelUrl;
  String? _instanceId;

  late Duration _idleClientConnectionTimeout;

  DisplayTunnelServer(
    this._createWebSocketConnection,
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
    int instanceGroupId,
    Uri uri, {
    // AWS WebSocket Idle Connection Timeout 10 minutes
    Duration tunnelHeartbeatInterval = const Duration(minutes: 9),
  }) {
    _tunnelUrl = uri;
    _instanceId = instanceId;

    _tunnelServer = TunnelConnectionServer(
      _createTunnelConnection,
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

  ClientConnection _createTunnelConnection() {
    // Add signature to query string for API authentication
    final request = buildApiRequest(
      getUriOrigin(_tunnelUrl!),
      _tunnelUrl!.path,
      queryParameters: {
        'role': 'server',
        'instanceId': _instanceId!,
      },
      time: DateTime.now(),
      signatureLocation: SignatureLocation.queryString,
    );

    return _createWebSocketConnection(
      request.url.toString(),
      false,
    );
  }
}
