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

  String? _reconnectionToken;
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
      ((message) => onChannelMessage?.call(message)),
    );
  }

  void openTunnelChannel(
    String displayCode,
    String token,
  ) {
    final parameters = <String, String>{
      'role': 'client',
      'displayCode': displayCode,
    };

    _openChannel(
      token,
      parameters,
    );
  }

  void openDirectChannel(
    String token,
  ) {
    _openChannel(
      token,
      {},
    );
  }

  bool _isClosed() {
    return _state == ChannelState.closed;
  }

  void _changeState(ChannelState newState) {
    if (_isClosed()) {
      return;
    }
    _state = newState;
    onStateChange?.call(_state);
  }

  void _openChannel(
    String token,
    Map<String, String> parameters,
  ) {
    final uri = _uri.replace(queryParameters: {
      'clientId': _clientId,
      'token': token,
      ...parameters,
      ..._uri.queryParameters,
    });

    _connection = _createConnection(
      uri.toString(),
    );

    _connection!.onConnected = () => _changeState(ChannelState.connected);
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
      case ChannelMessageType.channelClosed:
        await _onChannelClosedMessage(message as ChannelClosedMessage);
        return;
      default:
        return;
    }
  }

  void _onChannelConnected(ChannelConnectedMessage message) {
    _reconnectionToken = message.reconnectionToken;
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

    _closeReason = reason ?? ChannelCloseReason(ChannelCloseCode.close);
    _state = ChannelState.closed;
    //_changeState(ChannelState.closed);

    // send channel-closed message
    _connection?.send(
      ChannelClosedMessage(
        convertChannelCloseReasonToReason(_closeReason!),
      ).toJson(),
    );
  }

  Future _onConnectFailed(ConnectError error) async {
    await _closeConnection();

    _closeReason = ChannelCloseReason(
      connectErrorToChannelCloseCode(error.error),
      text: error.message,
    );
    _changeState(ChannelState.closed);
  }

  Future _onDisconnected() async {
    _changeState(ChannelState.disconnected);

    if (_isClosed()) {
      await _closeConnection();
    }
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
}
