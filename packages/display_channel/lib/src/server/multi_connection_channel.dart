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

  late MessageContinuity _continuity;

  String get channelId {
    return _channelId;
  }

  MultiConnectionChannel(
    this._channelId,
    this._reconnectionToken,
  ) {
    _continuity = MessageContinuity(((message) {
      onChannelMessage?.call(message);
    }));
  }

  bool verifyReconnectionToken(String token) {
    return _reconnectionToken == token;
  }

  void addConnection(Connection newConnection) {
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

    _continuity.processIncomingMessage(message);
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
      _changeState(ChannelState.disconnected);
    }
  }

  void _notifyConnected(Connection connection) {
    send(ChannelConnectedMessage(
      25000,
      _reconnectionToken,
    ));
  }

  @override
  void send(ChannelMessage message) {
    final preparedMessage = _continuity.prepareOutgoingMessage(message);

    final json = preparedMessage.toJson();

    // send data to the client
    for (var connection in _connections) {
      connection.send(json);
    }
  }

  @override
  Future<void> close(ChannelCloseReason? reason) async {
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
