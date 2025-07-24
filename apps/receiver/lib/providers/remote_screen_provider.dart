import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/model/multicast_presenter.dart';
import 'package:display_flutter/model/remote_screen_server.dart';
import 'package:display_flutter/model/remote_screen_connector.dart';
import 'package:display_flutter/model/remote_screen.dart';

class RemoteScreenProvider {
  RemoteScreenServer get server => _server;
  final RemoteScreenServer _server;
  MulticastPresenter get multicast => _multicastPresenter;
  final MulticastPresenter _multicastPresenter;

  final String _ipAddress;
  final void Function({
    bool? fromGroup,
    bool? fromShare,
    bool? fromSender,
    RemoteScreenConnector? remoteScreenConnector,
    bool kick,
  }) _connectorDisconnectCallback;
  RemoteScreenType remoteScreenType = RemoteScreenType.rtc;

  RemoteScreenProvider(this._server, this._ipAddress,
      this._connectorDisconnectCallback, this._multicastPresenter);

  Future<RemoteScreenConnector?> createRemoteScreenConnector(
      Channel channel, JoinDisplayMessage msg) async {
    RemoteScreenConnector connector;

    switch (remoteScreenType) {
      case RemoteScreenType.rtc:
        connector = RtcScreenConnector(
            channel, _server.roomId, _ipAddress, _server.roomPort, msg);
        _server.addConnector(connector as RtcScreenConnector);
        break;
      case RemoteScreenType.multicast:
        final info = await _multicastPresenter.streamInfo;
        if (info == null) {
          return null;
        }
        connector = MulticastScreenConnector(
            channel,
            info.ip,
            info.videoPort,
            info.audioPort,
            info.ssrc,
            info.keyHex,
            info.saltHex,
            info.videoRoc,
            info.audioRoc,
            msg);
        break;
    }

    connector.onDisconnect = (() async {
      _connectorDisconnectCallback(
        fromSender: true,
        remoteScreenConnector: connector,
        kick: false,
      );
    });

    return connector;
  }

  addConnector(RemoteScreenConnector connector) {
    if (remoteScreenType != RemoteScreenType.rtc) {
      return;
    }

    RtcScreenConnector c = connector as RtcScreenConnector;
    _server.addConnector(c);
  }

  removeConnector(RemoteScreenConnector connector) {
    if (remoteScreenType != RemoteScreenType.rtc) {
      return;
    }

    RtcScreenConnector c = connector as RtcScreenConnector;
    _server.removeConnector(c);
  }

  recreateIonSfuClient() {
    _server.recreateIonSfuClient();
  }

  bool isRemoteScreenPublisherStarted() {
    return _server.isRemoteScreenPublisherStarted();
  }

  Future startSfuServer(List<RtcIceServer>? iceServers) {
    return _server.startSfuServer(iceServers);
  }

  Future<bool> startRemoteScreenPublisher() {
    return _server.startRemoteScreenPublisher();
  }

  void stopRemoteScreenPublisher() {
    return _server.stopRemoteScreenPublisher();
  }

  onStartRemoteScreen(
    RemoteScreenConnector connector,
    StartRemoteScreenMessage message,
    List<RtcIceServer>? iceServers,
  ) {
    switch (remoteScreenType) {
      case RemoteScreenType.rtc:
        RtcScreenConnector c = connector as RtcScreenConnector;
        c.onStartRemoteScreen(message, iceServers);
        break;
      case RemoteScreenType.multicast:
        MulticastScreenConnector c = connector as MulticastScreenConnector;
        c.onStartRemoteScreen(message);
        break;
    }
  }
}
