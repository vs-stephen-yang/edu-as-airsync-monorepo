import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/model/display_group_video_view.dart';
import 'package:display_flutter/model/remote_screen_client.dart';
import 'package:display_flutter/utility/log.dart';

class DisplayGroupSession {
  bool get isVideoAvailable => _isVideoAvailable;
  bool _isVideoAvailable = false;

  DisplayGroupVideoView? get videoView => _remoteScreenClient == null
      ? null
      : DisplayGroupVideoView(
          _remoteScreenClient!.remoteScreenRenderer,
          _remoteScreenClient!.rtcWidgetKey,
        );

  void Function()? onStateChange;
  void Function(String hostName, String displayCode)? onInvitation;

  final Channel _channel;

  RemoteScreenClient? _remoteScreenClient;

  DisplayGroupSession(
    this._channel, {
    this.onInvitation,
    this.onStateChange,
  }) {
    _channel.onChannelMessage = _onChannelMessage;

    _sendDisplayStatus();
  }

  _sendDisplayStatus() {
    final displayStatusMessage = DisplayStatusMessage();
    _channel.send(displayStatusMessage);
  }

  void accept() {
    _startRemoteScreen();
  }

  void reject(String reason) {
    _closeRemoteScreen(reason);
  }

  void _onChannelMessage(ChannelMessage message) async {
    log.info('Display Group - Handling message: ${message.messageType}');

    switch (message.messageType) {
      case ChannelMessageType.inviteDisplayGroup:
        _onInviteMessage(message as InviteDisplayGroupMessage);
        break;

      case ChannelMessageType.remoteScreenStatus:
        // TODO:
        break;
      case ChannelMessageType.remoteScreenInfo:
        await _onRemoteScreenInfo(message as RemoteScreenInfoMessage);
        break;
      case ChannelMessageType.remoteScreenSignal:
        final signalMessage = message as RemoteScreenSignalMessage;

        _remoteScreenClient?.handleSignalMessage(signalMessage.signal!);
        break;
      default:
        break;
    }
  }

  void _onInviteMessage(InviteDisplayGroupMessage message) {
    onInvitation?.call(
      message.hostName ?? '',
      message.displayCode ?? '',
    );
  }

  void _startRemoteScreen() {
    _remoteScreenClient = RemoteScreenClient(_channel);
    _remoteScreenClient?.sendStartRemoteScreenMessage();
  }

  Future<void> _onRemoteScreenInfo(
    RemoteScreenInfoMessage infoMessage,
  ) async {
    await _remoteScreenClient?.handleRemoteScreenInfo(
      infoMessage.ionSfuRoom!.signalUrl,
      infoMessage.ionSfuRoom!.roomId!,
      infoMessage.ionSfuRoom!.iceServers,
      () {
        _isVideoAvailable = true;
        onStateChange?.call();
      },
      // onClose callback
      () {},
    );
  }

  void _closeRemoteScreen(String reason) {
    _channel
        .close(ChannelCloseReason(ChannelCloseCode.remoteClose, text: reason));
  }
}
