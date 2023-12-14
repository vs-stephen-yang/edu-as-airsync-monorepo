import 'package:display_channel/src/client_connection.dart';
import 'package:display_channel/src/server/connection.dart';
import 'package:display_channel/src/server/connection_request.dart';
import 'package:display_channel/src/server/tunnel/tunnel_message.dart';
import 'package:display_channel/src/server/tunnel/tunnel_message_handler.dart';
import 'package:display_channel/src/server/tunnel/tunnel_message_parser.dart';

class TunnelConnectionServer implements TunnelMessageHandler {
  void Function()? onTunnelConnected;
  void Function()? onTunnelConnecting;

  final String _instanceId;

  final CreateWebsocketClientConnection _createTunnelConnection;

  final void Function(String clientId, Connection) _onNewClientConnection;
  final bool Function(ConnectionRequest) _authenticationHandler;

  ClientConnection? _tunnelConnection;

  late TunnelMessageParser _messageParser;
  final _connections = <String, TunnelConnection>{};

  // Constructor
  TunnelConnectionServer(
    this._instanceId,
    String tunnelServiceUrl,
    this._createTunnelConnection,
    this._onNewClientConnection,
    this._authenticationHandler,
  ) {
    _messageParser = TunnelMessageParser(this);

    _initTunnelConnection(tunnelServiceUrl);
  }

  void start() {
    // connect to the tunnel server
    _tunnelConnection?.open();
  }

  Future<void> stop() async {
    await _tunnelConnection?.close();
  }

  void _initTunnelConnection(String url) {
    final uri = Uri.parse(url);

    final uriWithParameters = uri.replace(queryParameters: {
      'role': 'server',
      'instanceId': _instanceId,
    });

    _tunnelConnection = _createTunnelConnection(
      uriWithParameters.toString(),
      {},
    );

    _tunnelConnection!.onConnected = () => onTunnelConnected?.call();

    _tunnelConnection!.onConnecting = () => onTunnelConnecting?.call();

    _tunnelConnection!.onMessage = (Map<String, dynamic> message) {
      // parse the tunnel messages
      _messageParser.parse(message);
    };
  }

  @override
  void onClientConnected(TunnelClientConnected msg) {
    // a new client connection is being established

    final connectionRequest = ConnectionRequest(msg.clientId, msg.token);
    if (!_authenticationHandler(connectionRequest)) {
      // TODO: reject the connection
      return;
    }

    final connection = TunnelConnection(this, msg.connectionId);

    _connections[msg.connectionId] = connection;
    _onNewClientConnection(msg.clientId, connection);
  }

  @override
  void onClientDisconnected(TunnelClientDisconnected msg) {
    // a client connection is being terminated
    final connection = _connections[msg.connectionId];

    connection?.onClosed?.call(connection);
  }

  @override
  void onClientMsg(TunnelClientMsg msg) {
    // a message has been received from the client
    final connection = _connections[msg.connectionId];

    connection?.onMessage?.call(connection, msg.data);
  }

  @override
  void onDisconnectClient(TunnelDisconnectClient msg) {
    //TODO:
  }

  void disconnectClient(String connectionId) {
    // disconnect the client connection
    final reason = DisconnectReason(0, "");

    final msg = TunnelDisconnectClient(connectionId, reason);

    _tunnelConnection?.send(msg.toJson());
  }

  void sendMsgToClient(String connectionId, Map<String, dynamic> json) {
    // send a message to the client via the tunnel
    final msg = TunnelClientMsg(connectionId, json);

    _tunnelConnection?.send(msg.toJson());
  }
}

class TunnelConnection implements Connection {
  @override
  void Function(Connection connection)? onClosed;

  @override
  void Function(Connection connection, Map<String, dynamic> message)? onMessage;

  final String _connectionId;
  final TunnelConnectionServer _site;

  TunnelConnection(this._site, this._connectionId);

  @override
  void send(Map<String, dynamic> message) {
    _site.sendMsgToClient(_connectionId, message);
  }

  @override
  void close() {
    _site.disconnectClient(_connectionId);
  }
}
