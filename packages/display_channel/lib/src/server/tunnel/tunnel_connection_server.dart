import 'package:display_channel/src/channel.dart';
import 'package:display_channel/src/channel_server.dart';
import 'package:display_channel/src/client_connection.dart';
import 'package:display_channel/src/messages/channel_message.dart';
import 'package:display_channel/src/server/connection.dart';
import 'package:display_channel/src/server/connection_request.dart';
import 'package:display_channel/src/server/tunnel/tunnel_message.dart';
import 'package:display_channel/src/server/tunnel/tunnel_message_handler.dart';
import 'package:display_channel/src/server/tunnel/tunnel_message_parser.dart';
import 'dart:async';

class TunnelConnectionServer extends TunnelMessageHandler {
  void Function()? onTunnelConnected;
  void Function()? onTunnelConnecting;

  final String _instanceId;

  final CreateWebsocketClientConnection _createTunnelConnection;

  final void Function(String clientId, Connection) _onNewClientConnection;
  final VerifyConnectRequest _verifyConnectRequest;

  ClientConnection? _tunnelConnection;

  late TunnelMessageParser _messageParser;
  final _connections = <String, TunnelClientConnection>{};

  // Tunnel Heartbeat
  // Avoid disconnection caused by AWS WebSocket Idle Connection Timeout.
  Timer? _heartbeatTimer;
  final Duration heartbeatInterval;

  // Constructor
  TunnelConnectionServer(
    this._instanceId,
    String tunnelServiceUrl,
    this._createTunnelConnection,
    this._onNewClientConnection,
    this._verifyConnectRequest, {
    // AWS WebSocket Idle Connection Timeout 10 minutes
    this.heartbeatInterval = const Duration(minutes: 9),
  }) {
    _messageParser = TunnelMessageParser(this);

    _initTunnelConnection(tunnelServiceUrl);
  }

  void start() {
    // connect to the tunnel server
    _tunnelConnection?.open();
  }

  Future<void> stop() async {
    _heartbeatTimer?.cancel();
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
    );

    _tunnelConnection!.onConnected = _onTunnelConnected;
    _tunnelConnection!.onConnecting = () => onTunnelConnecting?.call();

    _tunnelConnection!.onDisconnected = _onTunnelDisconnected;

    _tunnelConnection!.onMessage = (Map<String, dynamic> message) {
      // parse the tunnel messages
      _messageParser.parse(message);
    };
  }

  @override
  void onClientConnected(TunnelClientConnected msg) {
    // a new client connection is being established

    // authenticate the connection request
    if (_verifyConnectRequest(ConnectionRequest(
          msg.clientId,
          msg.token,
          msg.displayCode,
        )) !=
        ConnectRequestStatus.success) {
      // reject the connection
      sendMsgToClient(
        msg.connectionId,
        ChannelClosedMessage(
          Reason(
            ChannelCloseCode.authenticationError.index,
            text: 'Wrong OTP',
          ),
        ).toJson(),
      );

      // TODO: disconnect the connection
      return;
    }

    final connection = TunnelClientConnection(this, msg.connectionId);

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

  _onTunnelConnected() {
    // start sending heartbeat
    _enableTunnelHeartbeat(true);

    onTunnelConnected?.call();
  }

  _onTunnelDisconnected() {
    // stop sending heartbeat
    _enableTunnelHeartbeat(false);
  }

  _enableTunnelHeartbeat(bool enable) {
    if (enable) {
      // Avoid disconnection caused by AWS WebSocket Idle Connection Timeout.
      // https://docs.aws.amazon.com/apigateway/latest/developerguide/limits.html

      _heartbeatTimer?.cancel();
      _heartbeatTimer = Timer.periodic(heartbeatInterval, (Timer timer) {
        // send hearbeat message
        _tunnelConnection?.send(
          TunnelHeartbeatMessage().toJson(),
        );
      });
    } else {
      _heartbeatTimer?.cancel();
    }
  }
}

class TunnelClientConnection implements Connection {
  @override
  void Function(Connection connection)? onClosed;

  @override
  void Function(Connection connection, Map<String, dynamic> message)? onMessage;

  final String _connectionId;
  final TunnelConnectionServer _site;

  TunnelClientConnection(this._site, this._connectionId);

  @override
  void send(Map<String, dynamic> message) {
    _site.sendMsgToClient(_connectionId, message);
  }

  @override
  void close() {
    _site.disconnectClient(_connectionId);
  }
}
