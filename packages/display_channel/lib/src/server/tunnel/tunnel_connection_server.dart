import 'dart:async';

import 'package:display_channel/src/channel_store.dart';
import 'package:display_channel/src/client_connection.dart';
import 'package:display_channel/src/messages/channel_message.dart';
import 'package:display_channel/src/server/connection.dart';
import 'package:display_channel/src/server/connection_request.dart';
import 'package:display_channel/src/server/idle_connection_timer.dart';
import 'package:display_channel/src/server/tunnel/tunnel_message.dart';
import 'package:display_channel/src/server/tunnel/tunnel_message_handler.dart';
import 'package:display_channel/src/server/tunnel/tunnel_message_parser.dart';
import 'package:display_channel/src/util/channel_message_util.dart';

enum TunnelConnectionStatus {
  connecting('Connecting'),
  connected('Connected'),
  connectFailed('ConnectFailed'),
  disconnected('Disconnected');

  const TunnelConnectionStatus(this.value);

  final String value;
}

class TunnelConnectionServer extends TunnelMessageHandler {
  void Function()? onTunnelConnected;
  void Function()? onTunnelConnecting;
  void Function(bool success, String status)? reportTunnelConnectResult;

  bool _isTunnelConnecting = false;

  final void Function(String clientId, Connection) _onNewClientConnection;
  final VerifyConnectRequest _verifyConnectRequest;

  ClientConnection? _tunnelConnection;
  final ClientConnection Function() _createTunnelConnection;

  late TunnelMessageParser _messageParser;
  final _connections = <String, TunnelClientConnection>{};

  // Heartbeat for tunnel connection
  // Avoid disconnection caused by AWS WebSocket Idle Connection Timeout.
  Timer? _heartbeatTimer;
  final Duration heartbeatInterval;

  final Duration idleConnectionTimeout;

  // Constructor
  TunnelConnectionServer(
    this._createTunnelConnection,
    this._onNewClientConnection,
    this._verifyConnectRequest, {
    // the heartbeat interval for the tunnel connection
    this.heartbeatInterval = const Duration(minutes: 9),
    // the idle timeout for client connections
    required this.idleConnectionTimeout,
  }) {
    _messageParser = TunnelMessageParser(this);
  }

  void _openTunnelConnection() {
    _tunnelConnection = _createTunnelConnection();

    _tunnelConnection!.onConnected = _onTunnelConnected;

    _tunnelConnection!.onConnectFailed = _onTunnelConnectFailed;
    _tunnelConnection!.onDisconnected = _onTunnelDisconnected;

    _tunnelConnection!.onConnecting = _onTunnelConnecting;

    _tunnelConnection!.onMessage = (Map<String, dynamic> message) {
      // parse the tunnel messages
      _messageParser.parse(message);
    };

    _tunnelConnection!.open();
  }

  start() {
    _openTunnelConnection();
  }

  stop() {
    _enableHeartbeat(false);

    _closeTunnelConnection();
  }

  @override
  void onClientConnected(TunnelClientConnected msg) {
    // a new client connection is being established

    // authenticate the connection request
    final connectRequest = ConnectionRequest(
      msg.clientId,
      msg.token,
      msg.displayCode,
      null,
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
      idleConnectionTimeout: idleConnectionTimeout,
    );

    _connections[msg.connectionId] = connection;
    _onNewClientConnection(msg.clientId, connection);
  }

  @override
  void onClientDisconnected(TunnelClientDisconnected msg) {
    // a client connection is being terminated
    final connection = _connections.remove(msg.connectionId);

    connection?.handleClientDisconnected();
  }

  @override
  void onClientMsg(TunnelClientMsg msg) {
    // a message has been received from the client
    final connection = _connections[msg.connectionId];

    connection?.handleClientMessage(msg.data);
  }

  @override
  void onDisconnectClient(TunnelDisconnectClient msg) {
    //TODO:
  }

  void _onTunnelConnecting() {
    if (!_isTunnelConnecting) {
      _isTunnelConnecting = true;
      onTunnelConnecting?.call();
      reportTunnelConnectResult?.call(true, TunnelConnectionStatus.connecting.value);
    }
  }

  void _onTunnelConnected() {
    _isTunnelConnecting = false;
    onTunnelConnected?.call();
    reportTunnelConnectResult?.call(true, TunnelConnectionStatus.connected.value);

    _enableHeartbeat(true);

    // Restore previously established connections after reconnection
    _connections.forEach((_, connection) {
      _onNewClientConnection(
        connection.clientId,
        connection,
      );
    });
  }

  _onTunnelConnectFailed(ConnectError error) {
    _closeTunnelConnection();
    reportTunnelConnectResult?.call(true, TunnelConnectionStatus.connectFailed.value);

    // Reconnect
    _openTunnelConnection();
  }

  void _onTunnelDisconnected() {
    _enableHeartbeat(false);
    reportTunnelConnectResult?.call(true, TunnelConnectionStatus.disconnected.value);

    _connections.forEach((_, connection) {
      connection.onClosed?.call(connection);
    });

    _closeTunnelConnection();

    // Reconnect
    _openTunnelConnection();
  }

  void _closeTunnelConnection() {
    _tunnelConnection?.close();
    _tunnelConnection = null;
  }

  void disconnectClient(String connectionId) {
    // disconnect the client connection
    final reason = DisconnectReason(0, "");

    final msg = TunnelDisconnectClient(connectionId, reason);

    _tunnelConnection?.send(msg.toJson());

    _connections.remove(connectionId);
  }

  void sendMsgToClient(String connectionId, Map<String, dynamic> json) {
    // send a message to the client via the tunnel
    final msg = TunnelClientMsg(connectionId, json);

    _tunnelConnection?.send(msg.toJson());
  }

  _enableHeartbeat(bool enable) {
    if (enable) {
      // Avoid disconnection caused by AWS WebSocket Idle Connection Timeout.
      // https://docs.aws.amazon.com/apigateway/latest/developerguide/limits.html

      _heartbeatTimer?.cancel();
      _heartbeatTimer = Timer.periodic(heartbeatInterval, (Timer timer) {
        // send tunnel hearbeat message
        _tunnelConnection?.send(
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
  late IdleConnectionTimer _idleTimer;

  TunnelClientConnection(
    this._site,
    this._connectionId,
    this._clientId, {
    required Duration idleConnectionTimeout,
  }) {
    _idleTimer = IdleConnectionTimer(
      _onIdleTimeout,
      idleConnectionTimeout,
    );
  }

  @override
  void send(Map<String, dynamic> message) {
    _site.sendMsgToClient(_connectionId, message);
  }

  @override
  void close() {
    _site.disconnectClient(_connectionId);
    _idleTimer.stop();
  }

  void handleClientDisconnected() {
    onClosed?.call(this);
    _idleTimer.stop();
  }

  void _onIdleTimeout() {
    onClosed?.call(this);
    _site.disconnectClient(_connectionId);

    _idleTimer.stop();
  }

  void handleClientMessage(
    Map<String, dynamic> message,
  ) {
    // receive message from the client
    // reset the idle timer
    _idleTimer.reset();

    onMessage?.call(this, message);
  }

  @override
  Map<String, String>? get queryParameters => {};
}
