import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/model/multicast_presenter.dart';
import 'package:display_flutter/model/remote_screen.dart';
import 'package:display_flutter/model/remote_screen_connector.dart';
import 'package:display_flutter/model/remote_screen_server.dart';
import 'package:display_flutter/utility/log.dart';

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
  final RemoteScreenType remoteScreenType;

  RemoteScreenProvider(
      this._server,
      this._ipAddress,
      this._connectorDisconnectCallback,
      this._multicastPresenter,
      this.remoteScreenType);

  Future<RemoteScreenConnector> createRemoteScreenConnector(
    Channel channel,
    JoinDisplayMessage msg,
  ) async {
    log.info(
      'RemoteScreenProvider: Creating connector - '
      'Type: $remoteScreenType, '
      'ClientId: ${msg.clientId}, '
      'SenderName: ${msg.name}',
    );

    RemoteScreenConnector connector;
    switch (remoteScreenType) {
      case RemoteScreenType.rtc:
        connector = RtcScreenConnector(
            channel, _server.roomId, _ipAddress, _server.roomPort, msg);
        _server.addConnector(connector as RtcScreenConnector);
        log.info(
            'RemoteScreenProvider: RTC connector created and added to server - '
            'RoomId: ${_server.roomId}, '
            'Host: $_ipAddress:${_server.roomPort}, ');
        break;
      case RemoteScreenType.multicast:
        connector = MulticastScreenConnector(channel, msg);
        log.info(
          'RemoteScreenProvider: Multicast connector created',
        );
        break;
    }

    connector.onDisconnect = (() async {
      log.info(
        'RemoteScreenProvider: Connector disconnect triggered - '
        'ClientId: ${msg.clientId}, '
        'SenderName: ${msg.name}',
      );
      _connectorDisconnectCallback(
        fromSender: true,
        remoteScreenConnector: connector,
        kick: false,
      );
    });

    log.info('RemoteScreenProvider: Connector creation completed');
    return connector;
  }

  addConnector(RemoteScreenConnector connector) {
    log.info(
      'RemoteScreenProvider: Adding RTC connector - '
      'Type: $remoteScreenType, '
      'ClientId: ${connector.clientId}, '
      'SessionId: ${connector.sessionId}',
    );
    if (remoteScreenType != RemoteScreenType.rtc) {
      return;
    }

    RtcScreenConnector c = connector as RtcScreenConnector;
    _server.addConnector(c);
  }

  removeConnector(RemoteScreenConnector connector) {
    log.info(
      'RemoteScreenProvider: Removing RTC connector - '
      'Type: $remoteScreenType, '
      'ClientId: ${connector.clientId}, '
      'SessionId: ${connector.sessionId}',
    );
    if (remoteScreenType != RemoteScreenType.rtc) {
      return;
    }

    RtcScreenConnector c = connector as RtcScreenConnector;
    _server.removeConnector(c);
  }

  bool isRemoteScreenPublisherStarted() {
    return _server.isRemoteScreenPublisherStarted();
  }

  Future startSfuServer(List<RtcIceServer>? iceServers) {
    log.info(
      'RemoteScreenProvider: Starting SFU server - '
      'ICE servers count: ${iceServers?.length ?? 0}',
    );
    return _server.startSfuServer(iceServers);
  }

  Future<bool> startRemoteScreenPublisher() {
    return _server.startRemoteScreenPublisher();
  }

  Future<void> stopPublish() async {
    log.info(
      'RemoteScreenProvider: Stopping publish - Type: $remoteScreenType',
    );
    switch (remoteScreenType) {
      case RemoteScreenType.rtc:
        return await _server.stopRemoteScreenPublisher();
      case RemoteScreenType.multicast:
        return await _multicastPresenter.stop();
    }
  }

  onStartRemoteScreen(
    RemoteScreenConnector connector,
    StartRemoteScreenMessage message,
    List<RtcIceServer>? iceServers,
  ) async {
    log.info(
      'RemoteScreenProvider: Starting remote screen - '
      'Type: $remoteScreenType, '
      'SessionId: ${message.sessionId}, '
      'ClientId: ${connector.clientId}, '
      'ICE servers count: ${iceServers?.length ?? 0}',
    );

    switch (remoteScreenType) {
      case RemoteScreenType.rtc:
        RtcScreenConnector c = connector as RtcScreenConnector;
        c.onStartRemoteScreen(message, iceServers);
        log.info(
          'RemoteScreenProvider: RTC remote screen started - '
          'SessionId: ${message.sessionId}',
        );
        break;
      case RemoteScreenType.multicast:
        final streamInfo = await _multicastPresenter.streamInfo;
        if (streamInfo != null) {
          MulticastScreenConnector c = connector as MulticastScreenConnector;
          c.onStartRemoteScreen(message, streamInfo);
          log.info(
            'RemoteScreenProvider: Multicast remote screen started - '
            'SessionId: ${message.sessionId}',
          );
        } else {
          log.warning(
            'RemoteScreenProvider: Failed to get multicast stream info - '
            'SessionId: ${message.sessionId}',
          );
        }
        break;
    }
  }

  Future<bool> startPublish(List<RtcIceServer>? iceServers) async {
    log.info(
      'Starting publish - Type: $remoteScreenType, ICE servers: ${iceServers?.length ?? 0}',
    );

    switch (remoteScreenType) {
      case RemoteScreenType.rtc:
        await startSfuServer(iceServers);
        final result = await startRemoteScreenPublisher();
        log.info('RemoteScreenProvider: RTC publish result - Success: $result');
        return result;

      case RemoteScreenType.multicast:
        final result = await _multicastPresenter.start();
        log.info(
            'RemoteScreenProvider: Multicast publish result - Success: $result');
        return result;
    }
  }

  void recreatePublisher() {
    log.info(
      'RemoteScreenProvider: Recreating publisher - '
      'Type: $remoteScreenType',
    );
    switch (remoteScreenType) {
      case RemoteScreenType.rtc:
        return _server.userConfirmRecreate();
      case RemoteScreenType.multicast:
        log.info('RemoteScreenProvider: Recreate not supported for Multicast');
        return;
    }
  }
}
