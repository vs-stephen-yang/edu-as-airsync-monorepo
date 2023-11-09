import 'package:display_channel/src/channel.dart';

import 'package:uuid/uuid.dart';
import 'package:display_channel/src/server/connection.dart';
import 'package:display_channel/src/server/connection_request.dart';
import 'package:display_channel/src/server/multi_connection_channel.dart';

typedef OnNewChannel = void Function(Channel channel);
typedef VerifyOtpToken = bool Function(String token);

abstract class ChannelServer {
  final OnNewChannel _onNewChannel;
  final VerifyOtpToken _verifyOtpToken;

  final _channels = <String, MultiConnectionChannel>{};
  final _uuid = const Uuid();

  ChannelServer(
    this._onNewChannel,
    this._verifyOtpToken,
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
    }

    channel.addConnection(connection);

    if (isNewChannelCreated) {
      _onNewChannel(channel);
    }
  }

  // check if the connection is valid
  bool verifyConnectionRequest(ConnectionRequest connectionRequest) {
    if (_verifyOtpToken(connectionRequest.token)) {
      return true;
    }

    if (_verifyReconnectionToken(connectionRequest)) {
      return true;
    }

    return false;
  }

  bool _verifyReconnectionToken(ConnectionRequest connectionRequest) {
    var channel = _channels[connectionRequest.clientId];
    if (channel == null) {
      return false;
    }
    return channel.verifyReconnectionToken(connectionRequest.token);
  }
}
