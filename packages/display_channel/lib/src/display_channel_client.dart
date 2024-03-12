import 'package:display_channel/src/channel.dart';
import 'package:display_channel/src/client_connection.dart';
import 'package:display_channel/src/messages/message_continuity.dart';
import 'package:display_channel/src/messages/channel_message.dart';
import 'package:display_channel/src/util/channel_message_util.dart';
import 'package:display_channel/src/util/channel_util.dart';

class DisplayChannelClient implements Channel {
  @override
  void Function(ChannelMessage channel)? onChannelMessage;

  @override
  void Function(ChannelState state)? onStateChange;

  @override
  ChannelState get state => _state;

  @override
  ChannelCloseReason? get closeReason => _closeReason;

  ClientConnection? _connection;

  final String _clientId;
  final Uri _uri;

  var _queryParameters = <String, String>{};

  late MessageContinuity _continuity;
  ChannelState _state = ChannelState.initialized;
  ChannelCloseReason? _closeReason;

  final CreateWebsocketClientConnection _createConnection;

  DisplayChannelClient(
    this._clientId,
    this._uri,
    this._createConnection,
  ) {
    _continuity = MessageContinuity(
      MessageContinuityRole.client,
      // Process messages received from the peer
      (message) => onChannelMessage?.call(message),
      // Send message requiring retransmission
      (message) => _connection?.send(message.toJson()),
    );
  }

  void openTunnelChannel(
    String instanceIndex,
    String token, {
    required String displayCode,
  }) {
    final parameters = <String, String>{
      'role': 'client',
      'instanceIndex': instanceIndex,
    };

    _openChannel(
      displayCode,
      token,
      parameters,
    );
  }

  void openDirectChannel(
    String token, {
    required String displayCode,
  }) {
    _openChannel(
      displayCode,
      token,
      {},
    );
  }

  bool _isClosed() {
    return _state == ChannelState.closed;
  }

  bool _isConnected() {
    return _state == ChannelState.connected;
  }

  void _changeState(ChannelState newState) {
    if (_isClosed()) {
      return;
    }
    _state = newState;
    onStateChange?.call(_state);
  }

  updateQueryParameters(String token) {
    _queryParameters['token'] = token;
  }

  void _openChannel(
    String displayCode,
    String token,
    Map<String, String> parameters,
  ) {
    // build the query parameters
    _queryParameters = {
      'clientId': _clientId,
      'displayCode': displayCode,
      'token': token,
      ...parameters,
      ..._uri.queryParameters,
    };

    _openNewConnection();
  }

  void _openNewConnection() {
    final uri = _uri.replace(
      queryParameters: _queryParameters,
    );

    _connection = _createConnection(
      uri.toString(),
    );

    _connection!.onConnected = _onConnected;
    _connection!.onConnecting = () => _changeState(ChannelState.connecting);
    _connection!.onConnectFailed = (error) => _onConnectFailed(error);
    _connection!.onDisconnected = () => _onDisconnected();
    _connection!.onMessage =
        (Map<String, dynamic> data) => _onConnectionData(data);

    _connection!.open();
  }

  void _onConnectionData(Map<String, dynamic> message) async {
    if (_isClosed()) {
      return;
    }

    ChannelMessage? parsedMessage = ChannelMessage.parse(message);

    if (parsedMessage == null) {
      return;
    }
    await _handleChannelMessage(parsedMessage);
  }

  Future _handleChannelMessage(ChannelMessage message) async {
    _handleControlMessage(message);

    _continuity.processIncomingMessage(message);
  }

  Future _handleControlMessage(ChannelMessage message) async {
    switch (message.messageType) {
      case ChannelMessageType.channelConnected:
        _onChannelConnected(message as ChannelConnectedMessage);
        return;
      case ChannelMessageType.heartbeat:
        _onHeartbeat(message as HeartbeatMessage);
        return;
      case ChannelMessageType.channelClosed:
        await _onChannelClosedMessage(message as ChannelClosedMessage);
        return;
      default:
        return;
    }
  }

  void _onChannelConnected(ChannelConnectedMessage message) {
    if (message.reconnectionToken != null) {
      updateQueryParameters(message.reconnectionToken!);
    }

    // state changes to "connected" after receiving channel-connected
    _changeState(ChannelState.connected);
  }

  @override
  void send(ChannelMessage message) {
    final preparedMessage = _continuity.prepareOutgoingMessage(message);

    final data = preparedMessage.toJson();

    _connection?.send(data);
  }

  @override
  Future<void> close(ChannelCloseReason? reason) async {
    if (_isClosed()) {
      return;
    }

    final connected = _isConnected();

    _closeReason = reason ?? ChannelCloseReason(ChannelCloseCode.close);
    _state = ChannelState.closed;

    if (connected) {
      // send channel-closed message
      _connection?.send(
        ChannelClosedMessage(
          convertChannelCloseReasonToReason(_closeReason!),
        ).toJson(),
      );
      return;
    }

    await _closeConnection();
  }

  Future _onConnectFailed(ConnectError error) async {
    await _closeConnection();

    if (_isClosed()) {
      return;
    }

    _closeReason = ChannelCloseReason(
      connectErrorToChannelCloseCode(error.error),
      text: error.message,
    );
    _changeState(ChannelState.closed);
  }

  void _onConnected() {
    // send client-connected to the server
    _connection?.send(
      ClientConnectedMessage(
        _continuity.nextIncomingSequenceNumber,
      ).toJson(),
    );
  }

  Future _onDisconnected() async {
    await _closeConnection();

    if (_isClosed()) {
      return;
    }

    // open new connection
    _openNewConnection();
  }

  Future _onChannelClosedMessage(ChannelClosedMessage message) async {
    await _closeConnection();

    if (_isClosed()) {
      return;
    }

    _closeReason = message.reason != null
        ? convertRemoteReasonToChannelCloseReason(message.reason!)
        : ChannelCloseReason(ChannelCloseCode.remoteClose);

    _changeState(ChannelState.closed);
  }

  Future _closeConnection() async {
    await _connection?.close();
    _connection = null;
  }

// when the client receives the heartbeat, it should response with a heartbeat
  _onHeartbeat(HeartbeatMessage message) {
    // response a heartbeat message to the server
    _connection?.send(
      HeartbeatMessage(
        _continuity.nextIncomingSequenceNumber,
      ).toJson(),
    );
  }
}
