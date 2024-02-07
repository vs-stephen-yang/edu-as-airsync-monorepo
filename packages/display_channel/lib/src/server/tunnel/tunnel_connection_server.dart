import 'dart:async';

import 'package:display_channel/src/channel_server.dart';
import 'package:display_channel/src/client_connection.dart';
import 'package:display_channel/src/messages/channel_message.dart';
import 'package:display_channel/src/server/connection.dart';
import 'package:display_channel/src/server/connection_request.dart';
import 'package:display_channel/src/server/tunnel/tunnel_message.dart';
import 'package:display_channel/src/server/tunnel/tunnel_message_handler.dart';
import 'package:display_channel/src/server/tunnel/tunnel_message_parser.dart';
import 'package:display_channel/src/util/channel_message_util.dart';

class TunnelConnectionServer extends TunnelMessageHandler {
  void Function()? onTunnelConnected;
  void Function()? onTunnelConnecting;

  final void Function(String clientId, Connection) _onNewClientConnection;
  final VerifyConnectRequest _verifyConnectRequest;

  final ClientConnection _tunnelConnection;

  late TunnelMessageParser _messageParser;
  final _connections = <String, TunnelClientConnection>{};

  // Tunnel Heartbeat
  // Avoid disconnection caused by AWS WebSocket Idle Connection Timeout.
  Timer? _heartbeatTimer;
  final Duration heartbeatInterval;

  // Constructor
  TunnelConnectionServer(
    this._tunnelConnection,
    this._onNewClientConnection,
    this._verifyConnectRequest, {
    this.heartbeatInterval = const Duration(minutes: 9),
  }) {
    _messageParser = TunnelMessageParser(this);

    _tunnelConnection.onConnected = _onTunnelConnected;

    _tunnelConnection.onDisconnected = _onTunnelDisconnected;

    _tunnelConnection.onConnecting = () {
      onTunnelConnecting?.call();
    };

    _tunnelConnection.onMessage = (Map<String, dynamic> message) {
      // parse the tunnel messages
      _messageParser.parse(message);
    };
  }

  start() {
    _tunnelConnection.open();
  }

  stop() {
    _enableHeartbeat(false);

    _tunnelConnection.close();
  }

  @override
  void onClientConnected(TunnelClientConnected msg) {
    // a new client connection is being established

    // authenticate the connection request
    final connectRequest = ConnectionRequest(
      msg.clientId,
      msg.token,
      msg.displayCode,
    );

    final status = _verifyConnectRequest(connectRequest);
    if (status != ConnectRequestStatus.success) {
      // reject the connection
      final reason = convertConnectRequestStatusToReason(status);

      sendMsgToClient(
        msg.connectionId,
        ChannelClosedMessage(reason).toJson(),
      );

      // TODO: disconnect the connection
      return;
    }

    final connection = TunnelClientConnection(
      this,
      msg.connectionId,
      msg.clientId,
    );

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

  void _onTunnelConnected() {
    onTunnelConnected?.call();

    _enableHeartbeat(true);

    // Restore previously established connections after reconnection
    _connections.forEach((_, connection) {
      _onNewClientConnection(
        connection.clientId,
        connection,
      );
    });
  }

  void _onTunnelDisconnected() {
    _enableHeartbeat(false);

    _connections.forEach((_, connection) {
      connection.onClosed?.call(connection);
    });
  }

  void disconnectClient(String connectionId) {
    // disconnect the client connection
    final reason = DisconnectReason(0, "");

    final msg = TunnelDisconnectClient(connectionId, reason);

    _tunnelConnection.send(msg.toJson());
  }

  void sendMsgToClient(String connectionId, Map<String, dynamic> json) {
    // send a message to the client via the tunnel
    final msg = TunnelClientMsg(connectionId, json);

    _tunnelConnection.send(msg.toJson());
  }

  _enableHeartbeat(bool enable) {
    if (enable) {
      // Avoid disconnection caused by AWS WebSocket Idle Connection Timeout.
      // https://docs.aws.amazon.com/apigateway/latest/developerguide/limits.html

      _heartbeatTimer?.cancel();
      _heartbeatTimer = Timer.periodic(heartbeatInterval, (Timer timer) {
        // send tunnel hearbeat message
        _tunnelConnection.send(
          TunnelHeartbeatMessage().toJson(),
        );
      });
    } else {
      _heartbeatTimer?.cancel();
      _heartbeatTimer = null;
    }
  }
}

class TunnelClientConnection implements Connection {
  @override
  void Function(Connection connection)? onClosed;

  @override
  void Function(Connection connection, Map<String, dynamic> message)? onMessage;

  String get clientId {
    return _clientId;
  }

  final String _connectionId;
  final String _clientId;

  final TunnelConnectionServer _site;

  TunnelClientConnection(
    this._site,
    this._connectionId,
    this._clientId,
  );

  @override
  void send(Map<String, dynamic> message) {
    _site.sendMsgToClient(_connectionId, message);
  }

  @override
  void close() {
    _site.disconnectClient(_connectionId);
  }
}
