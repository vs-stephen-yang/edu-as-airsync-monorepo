import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/model/remote_screen_connector.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:uuid/uuid.dart';

import 'display_group_mediator.dart';
import 'display_group_member_info.dart';

class DisplayGroupMember {
  final DisplayGroupMemberInfo _info;

  late DisplayChannelClient _channel;

  final String _clientId = const Uuid().v4();

  final DisplayGroupMediator _mediator;

  final void Function() onRejected;

  final void Function(bool stayOnList) onStopped;

  bool stayOnList = false;

  RemoteScreenConnector? _connector;

  DisplayGroupMember(this._info, this._mediator,
      {required this.onRejected, required this.onStopped}) {
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
          case 'accept':
            break;
          case 'reject':
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
      default:
    }
  }

  // The display group member requests to start the remote screen
  _onStartRemoteScreen(StartRemoteScreenMessage message) async {
    _connector = await _mediator.createRemoteScreenConnector(_channel, message);
  }

  void _sendInviteDisplayGroup() {
    final message = InviteDisplayGroupMessage(
      hostName: AppPreferences().instanceName,
      displayCode: '',
    );

    _channel.send(message);
  }

  void stop() {
    if (_channel.state == ChannelState.connected) {
      _channel.close(null);
    }
  }
}
