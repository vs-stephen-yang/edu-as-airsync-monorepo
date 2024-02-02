import 'package:display_channel/src/channel.dart';

import 'package:uuid/uuid.dart';
import 'package:display_channel/src/server/connection.dart';
import 'package:display_channel/src/server/connection_request.dart';
import 'package:display_channel/src/server/multi_connection_channel.dart';

enum ConnectRequestStatus {
  success,
  invalidOtp,
  invalidDisplayCode,
}

typedef OnNewChannel = void Function(Channel channel);
typedef VerifyConnectRequest = ConnectRequestStatus Function(
    ConnectionRequest connectRequest);

abstract class ChannelServer {
  final OnNewChannel _onNewChannel;
  final VerifyConnectRequest _verifyConnectRequest;

  final _channels = <String, MultiConnectionChannel>{};
  final _uuid = const Uuid();

  ChannelServer(
    this._onNewChannel,
    this._verifyConnectRequest,
  );

  void stop();

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
      );
      isNewChannelCreated = true;
      _channels[clientId] = channel;
    }

    channel.addConnection(connection);

    if (isNewChannelCreated) {
      _onNewChannel(channel);
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
    return channel.verifyReconnectionToken(connectionRequest.token);
  }

  closeAllChannels() {
    for (var entry in _channels.entries) {
      entry.value.close(
        ChannelCloseReason(
          ChannelCloseCode.transportClose,
          text: '',
        ),
      );
    }

    _channels.clear();
  }
}
