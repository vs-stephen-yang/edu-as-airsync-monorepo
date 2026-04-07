import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/model/multicast_info.dart';
import 'package:display_flutter/model/remote_screen_client.dart';
import 'package:display_flutter/utility/cast_to_boards_session_logger.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/utility/log_uploader_with_cooldown.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class DisplayGroupSession {
  bool get isVideoAvailable => _isVideoAvailable;
  bool _isVideoAvailable = false;

  bool get isAudioEnabled => _remoteScreenClient?.isAudioEnable ?? false;

  StatelessWidget? get videoView => _remoteScreenClient?.videoView;

  void Function(ChannelState? state)? onChannelStateChange;
  void Function(String hostName, String displayCode)? onInvitation;
  void Function()? onWebRtcClose;
  void Function(RemoteScreenStatus? state)? onRemoteScreenStatusChange;

  final Channel _channel;
  final LogUploaderWithCooldown _memberFpsZeroLogUploader;
  final bool Function() _isSmartScalingEnabled;

  RemoteScreenClient? _remoteScreenClient;

  String? hostName;

  DisplayGroupSession(
    this._channel,
    this._memberFpsZeroLogUploader, {
    required bool Function() isSmartScalingEnabled,
    this.onInvitation,
    this.onChannelStateChange,
    this.onWebRtcClose,
    this.onRemoteScreenStatusChange,
  }) : _isSmartScalingEnabled = isSmartScalingEnabled {
    castToBoardsSessionLogger.start('member');
    _channel.messageStream.listen(_onChannelMessage);
    _channel.stateStream.listen((ChannelState state) {
      onChannelStateChange?.call(state);
    });
    _sendDisplayStatus();
  }

  _sendDisplayStatus() {
    final displayStatusMessage = DisplayStatusMessage();
    _channel.send(displayStatusMessage);
  }

  void accept(String hostName) {
    log.info('DisplayGroupSession: User accepted invitation from $hostName');
    this.hostName = hostName;
    _channel.send(InviteDisplayGroupResultMessage(status: 'accept'));
    _startRemoteScreen();
  }

  void reject() {
    log.info('DisplayGroupSession: User rejected invitation');
    _channel.send(InviteDisplayGroupResultMessage(status: 'reject'));
  }

  Future<void> stop({required String reason}) async {
    log.info('DisplayGroupSession: Stopping, reason=$reason');
    castToBoardsSessionLogger.stop();
    _isVideoAvailable = false;
    await _remoteScreenClient?.remove();
    if (_channel.state != ChannelState.closed) {
      _channel.send(StopDisplayGroupMessage());
      Future.delayed(const Duration(seconds: 3), () {
        _channel.close(
            ChannelCloseReason(ChannelCloseCode.remoteClose, text: reason));
      });
    }
  }

  void _onChannelMessage(ChannelMessage message) async {
    switch (message.messageType) {
      case ChannelMessageType.inviteDisplayGroup:
        _onInviteMessage(message as InviteDisplayGroupMessage);
        break;

      case ChannelMessageType.remoteScreenStatus:
        final statusMessage = message as RemoteScreenStatusMessage;
        final status = statusMessage.status;
        onRemoteScreenStatusChange?.call(status);
        break;
      case ChannelMessageType.remoteScreenInfo:
        await _onRemoteScreenInfo(message as RemoteScreenInfoMessage);
        break;
      case ChannelMessageType.remoteScreenSignal:
        final signalMessage = message as RemoteScreenSignalMessage;
        if (_remoteScreenClient is RtcScreenClient) {
          final rtcClient = _remoteScreenClient as RtcScreenClient;
          rtcClient.handleSignalMessage(signalMessage.signal!);
        }
        break;
      case ChannelMessageType.multicastInfo:
        await _onMulticastInfo(message as MulticastInfoMessage);
        break;
      case ChannelMessageType.stopDisplayGroup:
        // Host is stopping, check FPS before closing
        if (_remoteScreenClient is RtcScreenClient) {
          final rtcClient = _remoteScreenClient as RtcScreenClient;
          rtcClient.checkFpsBeforeClose();
        }
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
    final sessionId = Uuid().v4();
    log.info('DisplayGroupSession: Sending StartRemoteScreen, sessionId=$sessionId');
    _channel.send(StartRemoteScreenMessage(sessionId));
  }

  Future<void> _onRemoteScreenInfo(
    RemoteScreenInfoMessage infoMessage,
  ) async {
    log.info('DisplayGroupSession: Received RemoteScreenInfo, roomId=${infoMessage.ionSfuRoom?.roomId}, signalUrl=${infoMessage.ionSfuRoom?.signalUrl}');
    final rtcClient = RtcScreenClient(
      _channel,
      infoMessage.sessionId,
      _memberFpsZeroLogUploader,
      _isSmartScalingEnabled,
    );
    await rtcClient.handleRemoteScreenInfo(
      infoMessage.ionSfuRoom!.signalUrl,
      infoMessage.ionSfuRoom!.roomId!,
      infoMessage.ionSfuRoom!.iceServers,
      () {
        _isVideoAvailable = true;
        onChannelStateChange?.call(null);
      },
      // onClose callback
      () {
        onWebRtcClose?.call();
      },
    );
    _remoteScreenClient = rtcClient;
  }

  Future<void> _onMulticastInfo(MulticastInfoMessage infoMessage) async {
    // MulticastScreenClient currently hardcodes smart scaling to false.
    // Revisit this call site if multicast videoView gets implemented.
    final client = MulticastScreenClient(_channel, infoMessage.sessionId, null);
    await client.handleMulticastInfo(MulticastInfo.fromMessage(infoMessage));
    _remoteScreenClient = client;
  }

  void onMute() {
    _remoteScreenClient?.onMute();
  }
}
