import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/model/remote_screen_connector.dart';
import 'package:display_flutter/model/remote_screen_server.dart';

abstract class DisplayGroupMediator {
  Future<RemoteScreenConnector> createRemoteScreenConnector(
      Channel channel, StartRemoteScreenMessage message);
}

class DisplayGroupMediatorObject implements DisplayGroupMediator {
  final RemoteScreenServer _server;
  final String _ipAddress;
  final Future<List<RtcIceServer>?> Function() _getIceServersForDirect;

  DisplayGroupMediatorObject(
      this._server, this._ipAddress, this._getIceServersForDirect);

  RemoteScreenConnector _createConnector(Channel channel) {
    return RemoteScreenConnector(
      channel,
      _server.roomId,
      _ipAddress,
      _server.roomPort,
      JoinDisplayMessage('123'),
    );
  }

  @override
  Future<RemoteScreenConnector> createRemoteScreenConnector(
      Channel channel, StartRemoteScreenMessage message) async {
    final connector = _createConnector(channel);
    // Use ServerManager to handle connector creation and server update
    _server.addConnector(connector);

    final iceServers = await _getIceServersForDirect();
    connector.onStartRemoteScreen(
      message,
      iceServers,
    );

    return connector;
  }
}
