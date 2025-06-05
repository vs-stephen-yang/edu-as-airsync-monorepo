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
      final reconnectionToken = _uuid.v4();

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

  // check if the connection is valid
  ConnectRequestStatus verifyConnectionRequest(
      ConnectionRequest connectionRequest) {
    // check reconnection token
    if (_verifyReconnectionToken(connectionRequest)) {
      return ConnectRequestStatus.success;
    }

    return _verifyConnectRequest(connectionRequest);
  }

  bool _verifyReconnectionToken(ConnectionRequest connectionRequest) {
    var channel = _channels[connectionRequest.clientId];
    if (channel == null) {
      return false;
    }

    if (connectionRequest.token == null) {
      return false;
    }
    return channel.verifyReconnectionToken(connectionRequest.token!);
  }
}
