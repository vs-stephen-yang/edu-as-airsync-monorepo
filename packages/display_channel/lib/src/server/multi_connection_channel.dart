import 'dart:async';

import 'package:display_channel/src/channel.dart';
import 'package:display_channel/src/messages/channel_message.dart';
import 'package:display_channel/src/messages/message_continuity.dart';
import 'package:display_channel/src/server/connection.dart';
import 'package:display_channel/src/util/channel_message_util.dart';
import 'package:rxdart/rxdart.dart';

class MultiConnectionChannel implements Channel {
  @override
  Stream<ChannelState> get stateStream => _stateController.stream;

  @override
  ChannelState get state => _state;

  @override
  Stream<ChannelMessage> get messageStream => _messageController.stream;

  @override
  ChannelCloseReason? get closeReason => _closeReason;

  final _connections = <Connection>{};
  final String _channelId;
  final String _reconnectionToken;
  ChannelState _state = ChannelState.connected;

  static const int _replayMaxSize = 10;

  final _stateController = ReplaySubject<ChannelState>(maxSize: _replayMaxSize);

  final _messageController =
      ReplaySubject<ChannelMessage>(maxSize: _replayMaxSize);

  ChannelCloseReason? _closeReason;

  late MessageContinuity _messageContinuity;

  Timer? _heartbeatTimer;
  final Duration heartbeatInterval;
  final Duration heartbeatTimeout;

  Timer? _reconnectTimer;

  // The amount of time during which a client can reconnect before closing the channel.
  final Duration reconnectTimeout;

  String get channelId {
    return _channelId;
  }

  MultiConnectionChannel(
    this._channelId,
    this._reconnectionToken, {
    // TODO: consider an appropriate interval
    required this.heartbeatInterval,
    required this.heartbeatTimeout,
    required this.reconnectTimeout,
  }) {
    _messageContinuity = MessageContinuity(
      MessageContinuityRole.server,
      // Process messages received from the client
      (message) => _messageController.add(message),
      // Send messages requiring retransmission
      (message) => _sendToAll(message),
    );
  }

  // start heatbeat timer
  _startHearbeat() {
    _heartbeatTimer?.cancel();

    _heartbeatTimer = Timer.periodic(heartbeatInterval, (Timer timer) {
      // Periodically sends a heartbeat to the client.
      _sendToAll(
        HeartbeatMessage(
          _messageContinuity.nextIncomingSequenceNumber,
        ),
      );
    });
  }

  // stop heartbeat timer
  _stopHearbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  _startReconnectTimer() {
    _reconnectTimer = Timer(reconnectTimeout, () {
      // the client does not reconnect within the timeout.
      _onReconnectTimeout();
    });
  }

  _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  bool verifyReconnectionToken(String token) {
    return _reconnectionToken == token;
  }

  // a new connection is added
  void addConnection(Connection newConnection) {
    _stopReconnectTimer();

    if (_connections.isEmpty) {
      _startHearbeat();
    }

    _connections.add(newConnection);

    newConnection.onClosed = (connection) => _onConnectionClosed(connection);

    newConnection.onMessage = _onConnectionData;
  }

  void _onConnectionData(Connection connection, Map<String, dynamic> message) {
    if (_isClosed()) {
      return;
    }

    ChannelMessage? parsedMessage = ChannelMessage.parse(message);

    if (parsedMessage == null) {
      return;
    }

    _handleChannelMessage(connection, parsedMessage);
  }

  _handleChannelMessage(Connection connection, ChannelMessage message) {
    _handleControlMessage(connection, message);

    _messageContinuity.processIncomingMessage(message);
  }

  _handleControlMessage(Connection connection, ChannelMessage message) {
    switch (message.messageType) {
      case ChannelMessageType.clientConnected:
        _onChannelClientConnected(
          connection,
          message as ClientConnectedMessage,
        );
        return;
      case ChannelMessageType.channelClosed:
        _onChannelClosedMessage(message as ChannelClosedMessage);
        return;
      default:
        return;
    }
  }

  bool _isClosed() {
    return _state == ChannelState.closed;
  }

  // a connection is closed
  void _onConnectionClosed(Connection c) {
    _connections.remove(c);

    // all underlying connections are closed
    if (_connections.isEmpty) {
      _changeState(ChannelState.connecting);

      _stopHearbeat();

      _startReconnectTimer();
    }
  }

  void _notifyConnected(Connection connection) {
    // send channel-connected message to the client
    connection.send(
      ChannelConnectedMessage(
        heartbeatInterval.inMilliseconds,
        heartbeatTimeout.inMilliseconds,
        _reconnectionToken,
        _messageContinuity.nextIncomingSequenceNumber,
      ).toJson(),
    );
  }

  @override
  void send(ChannelMessage message) {
    final preparedMessage = _messageContinuity.prepareOutgoingMessage(message);

    _sendToAll(preparedMessage);
  }

  // send message to all the connections
  void _sendToAll(ChannelMessage message) {
    final json = message.toJson();

    // send data to the client
    for (var connection in _connections) {
      connection.send(json);
    }
  }

  // the server initiates channel closure
  @override
  Future<void> close(ChannelCloseReason? reason) async {
    if (_isClosed()) {
      return;
    }
    reason = reason ?? ChannelCloseReason(ChannelCloseCode.close);

    for (var connection in _connections) {
      // send channel-closed message
      connection.send(ChannelClosedMessage(
        convertChannelCloseReasonToReason(reason),
      ).toJson());
    }

    _doClose(reason);
  }

  void _onChannelClientConnected(
    Connection connection,
    ClientConnectedMessage message,
  ) {
    _notifyConnected(connection);

    _changeState(ChannelState.connected);
  }

  // the client initiates channel closure
  _onChannelClosedMessage(ChannelClosedMessage message) {
    if (_isClosed()) {
      return;
    }

    for (var connection in _connections) {
      connection.close();
    }

    _doClose(
      message.reason != null
          ? convertRemoteReasonToChannelCloseReason(message.reason!)
          : ChannelCloseReason(ChannelCloseCode.remoteClose),
    );
  }

  // the client does not reconnect within the timeout.
  _onReconnectTimeout() {
    assert(_connections.isEmpty);
    assert(_heartbeatTimer == null);

    _doClose(
      ChannelCloseReason(
        ChannelCloseCode.networkError,
        text: 'The client does not reconnect within timeout',
      ),
    );
  }

  void _changeState(ChannelState newState) {
    if (_isClosed()) {
      return;
    }

    if (_state != newState) {
      _state = newState;
      // Note that add() is not a synchronous operation. It will
      // enqueue the event to be processed later by listeners of the stream.
      // This means the message is not immediately delivered, and
      // the code execution will continue without waiting for listeners
      // to handle the message.
      _stateController.sink.add(_state);
    }
  }

  void _doClose(ChannelCloseReason reason) {
    _stopHearbeat();
    _stopReconnectTimer();

    _closeReason = reason;
    _changeState(ChannelState.closed);

    _stateController.close();
    _messageController.close();
  }
}
