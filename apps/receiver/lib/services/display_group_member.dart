import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/model/remote_screen_connector.dart';
import 'package:display_flutter/services/display_group_member_info.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:uuid/uuid.dart';

class DisplayGroupMember {
  final DisplayGroupMemberInfo _info;

  late DisplayChannelClient _channel;

  RemoteScreenConnector? _connector;

  final String _clientId = const Uuid().v4();

  final Future<RemoteScreenConnector> Function(
    Channel,
    StartRemoteScreenMessage,
  ) createRemoteScreenConnector;

  DisplayGroupMember(
    this._info,
    this.createRemoteScreenConnector,
  ) {
    final uri = Uri(
      scheme: 'wss',
      host: _info.host,
      port: _info.port,
    );

    _channel = DisplayChannelClient(
      _clientId,
      uri,
      _createConnection,
    );

    _channel.onChannelMessage = _onChannelMessage;

    _channel.onStateChange = _onChannelStateChange;

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
        break;
      case ChannelState.closed:
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
          case 'accepted':
            break;
          case 'rejected':
            // TODO:
            // 邀請被拒絕的處理邏輯
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
      default:
    }
  }

  // The display group member requests to start the remote screen
  _onStartRemoteScreen(StartRemoteScreenMessage message) async {
    _connector = await createRemoteScreenConnector(_channel, message);
  }

  void _sendInviteDisplayGroup() {
    final message = InviteDisplayGroupMessage(
      hostName: AppPreferences().instanceName,
      displayCode: '',
    );

    _channel.send(message);
  }

  void stop() {
    _channel.close(null);
  }
}
