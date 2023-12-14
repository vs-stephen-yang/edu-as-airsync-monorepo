import 'package:display_channel/src/channel.dart';
import 'package:display_channel/src/client_connection.dart';
import 'package:display_channel/src/messages/message_continuity.dart';
import 'package:display_channel/src/messages/channel_message.dart';

class DisplayChannelClient implements Channel {
  @override
  void Function(ChannelMessage channel)? onChannelMessage;

  @override
  void Function(ChannelState state)? onStateChange;

  @override
  ChannelState get state => _state;

  ClientConnection? _connection;

  final String _clientId;
  final Uri _uri;

  String? _reconnectionToken;
  late MessageContinuity _continuity;
  ChannelState _state = ChannelState.initialized;

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

  void _changeState(ChannelState newState) {
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
      {},
    );

    _connection!.onConnected = () => _changeState(ChannelState.connected);
    _connection!.onConnecting = () => _changeState(ChannelState.connecting);
    _connection!.onMessage =
        (Map<String, dynamic> data) => _onConnectionData(data);

    _connection!.open();
  }

  void _onConnectionData(Map<String, dynamic> data) {
    ChannelMessage? message = ChannelMessage.parse(data);

    if (message == null) {
      return;
    }
    _handleChannelMessage(message);
  }

  void _handleChannelMessage(ChannelMessage message) {
    _handleControlMessage(message);

    _continuity.processIncomingMessage(message);
  }

  void _handleControlMessage(ChannelMessage message) {
    switch (message.messageType) {
      case ChannelMessageType.channelConnected:
        _onChannelConnected(message as ChannelConnectedMessage);
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
  Future<void> close() async {
    await _connection?.close();
  }
}
