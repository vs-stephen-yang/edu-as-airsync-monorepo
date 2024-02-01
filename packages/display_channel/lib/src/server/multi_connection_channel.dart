import 'dart:async';

import 'package:display_channel/src/messages/message_continuity.dart';
import 'package:display_channel/src/channel.dart';
import 'package:display_channel/src/messages/channel_message.dart';

import 'package:display_channel/src/server/connection.dart';
import 'package:display_channel/src/util/channel_message_util.dart';

class MultiConnectionChannel implements Channel {
  @override
  void Function(ChannelState state)? onStateChange;

  @override
  ChannelState get state => _state;

  @override
  void Function(ChannelMessage message)? onChannelMessage;

  @override
  ChannelCloseReason? get closeReason => _closeReason;

  final _connections = <Connection>{};
  final String _channelId;
  final String _reconnectionToken;
  ChannelState _state = ChannelState.connected;
  ChannelCloseReason? _closeReason;

  late MessageContinuity _messageContinuity;

  Timer? _heartbeatTimer;
  final Duration heartbeatInterval;

  String get channelId {
    return _channelId;
  }

  MultiConnectionChannel(
    this._channelId,
    this._reconnectionToken, {
    // TODO: consider an appropriate interval
    this.heartbeatInterval = const Duration(seconds: 10),
  }) {
    _messageContinuity = MessageContinuity(
      MessageContinuityRole.server,
      // Process messages received from the client
      (message) => onChannelMessage?.call(message),
      // Send messages requiring retransmission
      (message) => _sendToAll(message),
    );
  }

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

  _stopHearbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  bool verifyReconnectionToken(String token) {
    return _reconnectionToken == token;
  }

  void addConnection(Connection newConnection) {
    if (_connections.isEmpty) {
      _startHearbeat();
    }

    _connections.add(newConnection);

    newConnection.onClosed = (connection) => _onConnectionClosed(connection);

    newConnection.onMessage = (Connection c, Map<String, dynamic> message) =>
        _onConnectionData(message);

    _notifyConnected(newConnection);
  }

  void _onConnectionData(Map<String, dynamic> message) {
    if (_isClosed()) {
      return;
    }

    ChannelMessage? parsedMessage = ChannelMessage.parse(message);

    if (parsedMessage == null) {
      return;
    }

    _handleChannelMessage(parsedMessage);
  }

  Future _handleChannelMessage(ChannelMessage message) async {
    _handleControlMessage(message);

    _messageContinuity.processIncomingMessage(message);
  }

  Future _handleControlMessage(ChannelMessage message) async {
    switch (message.messageType) {
      case ChannelMessageType.channelClosed:
        await _onChannelClosedMessage(message as ChannelClosedMessage);
        return;
      default:
        return;
    }
  }

  bool _isClosed() {
    return _state == ChannelState.closed;
  }

  void _onConnectionClosed(Connection c) {
    // the connection is closed
    _connections.remove(c);

    // all underlying connections are closed
    if (_connections.isEmpty) {
      _stopHearbeat();

      // IMPROVE
      _changeState(ChannelState.closed);
    }
  }

  void _notifyConnected(Connection connection) {
    // send channel-connected message to the client
    connection.send(
      ChannelConnectedMessage(
        heartbeatInterval.inMilliseconds,
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

  @override
  Future<void> close(ChannelCloseReason? reason) async {
    _stopHearbeat();

    if (_isClosed()) {
      return;
    }

    _closeReason = reason ?? ChannelCloseReason(ChannelCloseCode.close);
    _state = ChannelState.closed;

    for (var connection in _connections) {
      // send channel-closed message
      connection.send(ChannelClosedMessage(
        convertChannelCloseReasonToReason(_closeReason!),
      ).toJson());
    }
  }

  Future _onChannelClosedMessage(ChannelClosedMessage message) async {
    if (_isClosed()) {
      return;
    }

    for (var connection in _connections) {
      connection.close();
    }

    _closeReason = message.reason != null
        ? convertRemoteReasonToChannelCloseReason(message.reason!)
        : ChannelCloseReason(ChannelCloseCode.remoteClose);

    _changeState(ChannelState.closed);
  }

  void _changeState(ChannelState newState) {
    if (_isClosed()) {
      return;
    }

    _state = newState;
    onStateChange?.call(_state);
  }
}
