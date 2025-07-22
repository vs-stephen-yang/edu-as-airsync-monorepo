import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/model/remote_screen_connector.dart';
import 'package:display_flutter/providers/remote_screen_provider.dart';

abstract class DisplayGroupMediator {
  Future<RemoteScreenConnector> createRemoteScreenConnector(
      Channel channel, StartRemoteScreenMessage message);
}

class DisplayGroupMediatorObject implements DisplayGroupMediator {
  final RemoteScreenProvider _remoteScreenProvider;
  final Future<List<RtcIceServer>?> Function() _getIceServersForDirect;

  DisplayGroupMediatorObject(this._remoteScreenProvider, this._getIceServersForDirect);

  @override
  Future<RemoteScreenConnector> createRemoteScreenConnector(
      Channel channel, StartRemoteScreenMessage message) async {
    final connector = _remoteScreenProvider.createRemoteScreenConnector(channel, JoinDisplayMessage('123'));

    final iceServers = await _getIceServersForDirect();
    await connector.onStartRemoteScreen(
      message,
      iceServers,
    );

    return connector;
  }
}
