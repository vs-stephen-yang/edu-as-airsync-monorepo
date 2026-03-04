import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/model/remote_screen_connector.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/utility/log_uploader_with_cooldown.dart';
import 'package:uuid/uuid.dart';

import 'display_group_mediator.dart';
import 'display_group_member_info.dart';

class DisplayGroupMember {
  final Uri _uri;

  final DisplayGroupMemberInfo _info;

  late DisplayChannelClient _channel;

  final DisplayGroupMediator _mediator;
  final LogUploaderWithCooldown _hostFpsZeroLogUploader;

  final void Function() onRejected;

  final void Function(bool stayOnList) onStopped;

  bool stayOnList = false;

  RemoteScreenConnector? _connector;

  DisplayGroupMember(
    this._info,
    this._mediator,
    this._hostFpsZeroLogUploader, {
    required this.onRejected,
    required this.onStopped,
  }) : _uri = Uri(
          scheme: 'wss',
          host: _info.host,
          port: _info.port,
        ) {
    newChannel();
  }

  void newChannel() {
    final clientId = const Uuid().v4();

    _channel = DisplayChannelClient(
      clientId,
      _uri,
      _createConnection,
    );

    _channel.messageStream.listen(_onChannelMessage);

    _channel.stateStream.listen((ChannelState state) {
      _onChannelStateChange(state);
    });

    // Open a direct connection with the display group member
    _channel.openDirectChannel(
      displayCode: _info.displayCode,
      queryParameters: {
        'role': 'host',
      },
    );
  }

  WebSocketClientConnection _createConnection(url, bool isReconnect) {
    return WebSocketClientConnection(
      url,
      WebSocketClientConnectionConfig(
        logger: (url, message) => log.info('$url $message}'),
        allowSelfSignedCertificates: true,
      ),
    );
  }

  void _onChannelStateChange(ChannelState state) {
    switch (state) {
      case ChannelState.connected:
        log.info('DisplayGroupMember [${_info.displayCode}]: Channel connected');
        break;
      case ChannelState.closed:
        log.info('DisplayGroupMember [${_info.displayCode}]: Channel closed, reason=${_channel.closeReason?.code}');
        // The following situations require re-establishing the connection:
        // 1. When disconnected due to network issues
        // 2. When an old DisplayGroupSession from “Cast to Board Member” has not been cleared and sent a remote close
        if (_channel.closeReason?.code == ChannelCloseCode.networkError ||
            _channel.closeReason?.code == ChannelCloseCode.heartbeatTimeout ||
            _channel.closeReason?.code == ChannelCloseCode.remoteClose) {
          log.info('DisplayGroupMember [${_info.displayCode}]: Reconnecting...');
          newChannel();
        }
        break;
      default:
        break;
    }
  }

  // handle channel messages from the display group member
  void _onChannelMessage(ChannelMessage message) {
    switch (message.messageType) {
      case ChannelMessageType.displayStatus:
        _sendInviteDisplayGroup();
        break;
      case ChannelMessageType.inviteDisplayGroupResult:
        final inviteResult = message as InviteDisplayGroupResultMessage;
        final status = inviteResult.status;

        // 根據狀態進行相應處理
        switch (status) {
          case 'accept':
            log.info('DisplayGroupMember [${_info.displayCode}]: Member accepted invitation');
            break;
          case 'reject':
            log.info('DisplayGroupMember [${_info.displayCode}]: Member rejected invitation');
            stayOnList = true;
            onRejected();
            break;
          default:
            // 處理未知狀態
            break;
        }
        break;
      case ChannelMessageType.startRemoteScreen:
        final startRemoteScreenMessage = message as StartRemoteScreenMessage;
        _onStartRemoteScreen(startRemoteScreenMessage);
        break;
      case ChannelMessageType.remoteScreenSignal:
        final signalMessage = message as RemoteScreenSignalMessage;
        _connector?.processSignalFromPeer(signalMessage.signal!);
        break;
      case ChannelMessageType.stopDisplayGroup:
        stop();
        onStopped(stayOnList);
        break;
      case ChannelMessageType.remoteScreenStatus:
        final statusMessage = message as RemoteScreenStatusMessage;
        final status = statusMessage.status;

        if (status == RemoteScreenStatus.fpsZero) {
          log.warning(
              "Host received FPS zero notification from Display Group member: ${_info.displayCode}");
          _hostFpsZeroLogUploader.upload(
            'Host received FPS zero request from Display Group member. Display code: ${_info.displayCode}',
          );
        }

        break;
      default:
    }
  }

  // The display group member requests to start the remote screen
  _onStartRemoteScreen(StartRemoteScreenMessage message) async {
    _connector = await _mediator.createRemoteScreenConnector(_channel, message);
  }

  void _sendInviteDisplayGroup() {
    log.info('DisplayGroupMember [${_info.displayCode}]: Sending invite');
    final message = InviteDisplayGroupMessage(
      hostName: AppPreferences().instanceName,
      displayCode: '',
    );

    _channel.send(message);
  }

  void stop() {
    log.info('DisplayGroupMember [${_info.displayCode}]: Stopping');
    if (_channel.state == ChannelState.connected) {
      // Send stop message to trigger FPS check on receiver side
      // before closing the channel
      _channel.send(StopDisplayGroupMessage());

      // Delay closing to allow receiver to send FPS zero notification
      Future.delayed(const Duration(milliseconds: 500), () {
        _channel.close(null);
      });
    }
  }

  void sendRemoteScreenState(RemoteScreenStatus status) {
    _connector?.sendRemoteScreenState(status);
  }

  get version {
    return _info.version;
  }

  static bool isVersionGreater(String ver, String target) {
    // 先去掉 - 後面的部分
    String cleanVer = ver.split('-').first;        // e.g. "3.9.3-d" -> "3.9.3"
    String cleanTarget = target.split('-').first;  // 保險一點，target 也處理

    List<int> vParts =
    cleanVer.split('.').map((e) => int.parse(e)).toList();
    List<int> tParts =
    cleanTarget.split('.').map((e) => int.parse(e)).toList();

    int maxLen = vParts.length > tParts.length ? vParts.length : tParts.length;

    for (int i = 0; i < maxLen; i++) {
      int v = i < vParts.length ? vParts[i] : 0;
      int t = i < tParts.length ? tParts[i] : 0;

      if (v > t) return true;   // ver 比較大
      if (v < t) return false;  // ver 比較小
    }

    // 跑完都一樣 = 版本相等，不算大於
    return false;
  }
}
