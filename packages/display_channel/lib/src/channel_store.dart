import 'package:display_channel/src/channel.dart';

import 'package:uuid/uuid.dart';
import 'package:display_channel/src/server/connection.dart';
import 'package:display_channel/src/server/connection_request.dart';
import 'package:display_channel/src/server/multi_connection_channel.dart';

enum ConnectRequestStatus {
  success,
  invalidOtp,
  invalidDisplayCode,
  rateLimitExceeded,
  authenticationRequired,
  channelClosed,
}

typedef OnNewChannel = void Function(
  Channel channel,
  Map<String, String>? queryParameters,
);

typedef VerifyConnectRequest = ConnectRequestStatus Function(
    ConnectionRequest connectRequest);

class ChannelStore {
  final OnNewChannel _onNewChannel;
  final VerifyConnectRequest _verifyConnectRequest;

  final _channels = <String, MultiConnectionChannel>{};
  final _uuid = const Uuid();

  final Duration heartbeatInterval;
  final Duration heartbeatTimeout;
  final Duration reconnectTimeout;

  int get channelCount => _channels.length;
  static const _reconnectTokenPrefix = 'reconn_';

  ChannelStore(
    this._onNewChannel,
    this._verifyConnectRequest, {
    this.heartbeatInterval = const Duration(seconds: 10),
    this.heartbeatTimeout = const Duration(seconds: 10),
    this.reconnectTimeout = const Duration(seconds: 2),
  });

  void _onChannelClosed(String clientId, MultiConnectionChannel channel) {
    _channels.remove(clientId);
  }

  // handle a new connection
  void handleNewConnection(
    String clientId,
    Connection connection,
  ) {
    var channel = _channels[clientId];

    bool isNewChannelCreated = false;

    if (channel == null) {
      //TODO: improve the creation of reconnection token
      final reconnectionToken = _reconnectTokenPrefix + _uuid.v4();

      // create a new channel
      channel = MultiConnectionChannel(
        clientId,
        reconnectionToken,
        heartbeatInterval: heartbeatInterval,
        heartbeatTimeout: heartbeatTimeout,
        reconnectTimeout: reconnectTimeout,
      );
      isNewChannelCreated = true;
      _channels[clientId] = channel;

      channel.stateStream.listen((ChannelState state) {
        if (state == ChannelState.closed) {
          _onChannelClosed(clientId, channel!);
        }
      });
    }

    channel.addConnection(connection);

    if (isNewChannelCreated) {
      _onNewChannel(channel, connection.queryParameters);
    }
  }

  // Returns true if the connection request is considered a reconnection,
  // based on token length or other identifying characteristics.
  bool _isReconnection(String token) {
    return token.length >= _uuid.v4().length ||
        token.startsWith(_reconnectTokenPrefix);
  }

  // check if the connection is valid
  ConnectRequestStatus verifyConnectionRequest(
      ConnectionRequest connectionRequest) {
    final token = connectionRequest.token;

    // Reject if no token is provided
    if (token == null) {
      return ConnectRequestStatus.invalidOtp;
    }

    // If it's a reconnection attempt, validate it separately
    if (_isReconnection(token)) {
      return _verifyReconnectionToken(connectionRequest.clientId, token);
    }

    return _verifyConnectRequest(connectionRequest);
  }

  ConnectRequestStatus _verifyReconnectionToken(String clientId, String token) {
    final channel = _channels[clientId];

    // Reject if no active channel is found (likely already closed)
    if (channel == null) {
      return ConnectRequestStatus.channelClosed;
    }
    return channel.verifyReconnectionToken(token)
        ? ConnectRequestStatus.success
        : ConnectRequestStatus.invalidOtp;
  }
}
