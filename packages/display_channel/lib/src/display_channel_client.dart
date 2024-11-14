import 'dart:async';

import 'package:display_channel/src/api/api_request.dart';
import 'package:display_channel/src/channel.dart';
import 'package:display_channel/src/client_connection.dart';
import 'package:display_channel/src/messages/channel_message.dart';
import 'package:display_channel/src/messages/message_continuity.dart';
import 'package:display_channel/src/util/channel_message_util.dart';
import 'package:display_channel/src/util/channel_util.dart';
import 'package:display_channel/src/util/uri_util.dart';

class DisplayChannelClient implements Channel {
  @override
  Stream<ChannelMessage> get messageStream => _messageController.stream;

  @override
  Stream<ChannelState> get stateStream => _stateController.stream;

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

  final StreamController<ChannelState> _stateController =
      StreamController<ChannelState>.broadcast();

  final StreamController<ChannelMessage> _messageController =
      StreamController<ChannelMessage>.broadcast();

  ChannelCloseReason? _closeReason;

  // Stores messages received before the channel is connected.
  final _pendingMessages = <ChannelMessage>[];

  final CreateWebsocketClientConnection _createConnection;

  DisplayChannelClient(
    this._clientId,
    this._uri,
    this._createConnection,
  ) {
    _continuity = MessageContinuity(
      MessageContinuityRole.client,
      // Process messages received from the peer
      _onChannelMessage,
      // Send message requiring retransmission
      (message) => _connection?.send(message.toJson()),
    );
  }

  void openTunnelChannel(
    int instanceIndex,
    int instanceGroupId,
    String token, {
    required String displayCode,
  }) {
    final parameters = <String, String>{
      'role': 'client',
      'instanceIndex': '$instanceIndex',
      'groupId': '$instanceGroupId',
    };

    _openChannel(
      displayCode,
      token,
      parameters,
    );
  }

  // allow direct connection without token
  void openDirectChannel({
    String? token,
    String? displayCode,
    Map<String, String>? queryParameters,
  }) {
    _openChannel(
      displayCode,
      token,
      queryParameters ?? {},
    );
  }

  bool _isClosed() {
    return _state == ChannelState.closed;
  }

  bool _isConnected() {
    return _state == ChannelState.connected;
  }

  void _deliverMessage(ChannelMessage message) {
    // Note that add() is not a synchronous operation. It will
    // enqueue the event to be processed later by listeners of the stream.
    // This means the message is not immediately delivered, and
    // the code execution will continue without waiting for listeners
    // to handle the message.
    _messageController.sink.add(message);
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

  updateQueryParameters(String token) {
    _queryParameters['token'] = token;
  }

  void _openChannel(
    String? displayCode,
    String? token,
    Map<String, String> parameters,
  ) {
    // build the query parameters
    _queryParameters = {
      'clientId': _clientId,
      'displayCode': displayCode ?? '',
      'token': token ?? '',
      ...parameters,
      ..._uri.queryParameters,
    };

    _openNewConnection();
  }

  void _openNewConnection({bool isReconnect = false}) {
    // Add signature to query string for API authentication
    final request = buildApiRequest(
      getUriOrigin(_uri),
      _uri.path,
      queryParameters: _queryParameters,
      time: DateTime.now(),
      signatureLocation: SignatureLocation.queryString,
    );

    _connection = _createConnection(
      request.url.toString(),
      isReconnect,
    );

    _connection!.onConnected = _onConnected;
    _connection!.onConnecting = () => _changeState(ChannelState.connecting);
    _connection!.onConnectFailed = (error) => _onConnectFailed(error);
    _connection!.onDisconnected = () => _onDisconnected();
    _connection!.onMessage =
        (Map<String, dynamic> data) => _onConnectionData(data);

    _connection!.open();
  }

  void _onConnectionData(Map<String, dynamic> message) {
    if (_isClosed()) {
      return;
    }

    ChannelMessage? parsedMessage = ChannelMessage.parse(message);

    if (parsedMessage == null) {
      return;
    }

    _handleControlMessage(parsedMessage);

    _continuity.processIncomingMessage(parsedMessage);
  }

  void _handleControlMessage(ChannelMessage message) {
    switch (message.messageType) {
      case ChannelMessageType.channelConnected:
        _onChannelConnected(message as ChannelConnectedMessage);
        return;
      case ChannelMessageType.heartbeat:
        _onHeartbeat(message as HeartbeatMessage);
        return;
      case ChannelMessageType.channelClosed:
        _onChannelClosedMessage(message as ChannelClosedMessage);
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
    // Workaround: When switching the onStateChange function to use a stream
    // listener, the process becomes asynchronous, so onChannelMessage may
    // not be set up yet. Adding a 100ms delay here to wait it initialized.
    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      _drainPendingMessages();
    });
  }

  // Process messages received before the channel is connected.
  void _drainPendingMessages() {
    for (var message in _pendingMessages) {
      _deliverMessage(message);
    }
    _pendingMessages.clear();
  }

  void _onChannelMessage(ChannelMessage message) {
    if (_isConnected()) {
      _deliverMessage(message);
    } else {
      _pendingMessages.add(message);
    }
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

    _closeConnection();
  }

  Future _onConnectFailed(ConnectError error) async {
    _closeConnection();

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

  void _onDisconnected() {
    _closeConnection();

    if (_isClosed()) {
      return;
    }

    // open new connection
    _openNewConnection(isReconnect: true);
  }

  void _onChannelClosedMessage(ChannelClosedMessage message) {
    _closeConnection();

    if (_isClosed()) {
      return;
    }

    _closeReason = message.reason != null
        ? convertRemoteReasonToChannelCloseReason(message.reason!)
        : ChannelCloseReason(ChannelCloseCode.remoteClose);

    _changeState(ChannelState.closed);
  }

  void _closeConnection() {
    _connection?.close();
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
