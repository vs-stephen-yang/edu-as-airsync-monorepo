import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/model/remote_screen_connector.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/utility/log_upload.dart';
import 'package:uuid/uuid.dart';

import 'display_group_mediator.dart';
import 'display_group_member_info.dart';

class DisplayGroupMember {
  final Uri _uri;

  final DisplayGroupMemberInfo _info;

  late DisplayChannelClient _channel;

  final DisplayGroupMediator _mediator;

  final void Function() onRejected;

  final void Function(bool stayOnList) onStopped;

  bool stayOnList = false;

  RemoteScreenConnector? _connector;

  DisplayGroupMember(this._info, this._mediator,
      {required this.onRejected, required this.onStopped})
      : _uri = Uri(
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
        break;
      case ChannelState.closed:
        // The following situations require re-establishing the connection:
        // 1. When disconnected due to network issues
        // 2. When an old DisplayGroupSession from “Cast to Board Member” has not been cleared and sent a remote close
        if (_channel.closeReason?.code == ChannelCloseCode.networkError ||
            _channel.closeReason?.code == ChannelCloseCode.heartbeatTimeout ||
            _channel.closeReason?.code == ChannelCloseCode.remoteClose) {
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
      case ChannelMessageType.remoteScreenStatus:
        final statusMessage = message as RemoteScreenStatusMessage;
        final status = statusMessage.status;

        if (status == RemoteScreenStatus.fpsZero) {
          log.warning(
              "Uploading log due to remote screen FPS zero from ${_info.displayCode}");
          uploadSystemLog(
            'Host received FPS zero request from member. Display code: ${_info.displayCode}',
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
    final message = InviteDisplayGroupMessage(
      hostName: AppPreferences().instanceName,
      displayCode: '',
    );

    _channel.send(message);
  }

  void stop() {
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
}
