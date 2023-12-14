import 'package:display_channel/src/messages/message_continuity.dart';
import 'package:display_channel/src/channel.dart';
import 'package:display_channel/src/messages/channel_message.dart';

import 'package:display_channel/src/server/connection.dart';

class MultiConnectionChannel implements Channel {
  @override
  void Function(ChannelState state)? onStateChange;

  @override
  ChannelState get state => _state;

  @override
  void Function(ChannelMessage message)? onChannelMessage;

  final _connections = <Connection>{};
  final String _channelId;
  final String _reconnectionToken;
  ChannelState _state = ChannelState.connected;

  late MessageContinuity _reliable;

  String get channelId {
    return _channelId;
  }

  MultiConnectionChannel(
    this._channelId,
    this._reconnectionToken,
  ) {
    _reliable = MessageContinuity(((message) {
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
    ChannelMessage? parsedMessage = ChannelMessage.parse(message);

    if (parsedMessage == null) {
      return;
    }

    _reliable.processIncomingMessage(parsedMessage);
  }

  void _onConnectionClosed(Connection c) {
    // the connection is closed
    _connections.remove(c);

    // all underlying connections are closed
    if (_connections.isEmpty) {
      _state = ChannelState.disconnected;
      onStateChange?.call(ChannelState.disconnected);
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
    final preparedMessage = _reliable.prepareOutgoingMessage(message);

    final json = preparedMessage.toJson();

    // send data to the client
    for (var connection in _connections) {
      connection.send(json);
    }
  }

  @override
  Future<void> close() async {
    for (var connection in _connections) {
      connection.close();
    }
  }
}
