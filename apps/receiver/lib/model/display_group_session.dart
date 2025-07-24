import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/model/remote_screen.dart';
import 'package:display_flutter/model/remote_screen_client.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'multicast_info.dart';

class DisplayGroupSession {
  bool get isVideoAvailable => _isVideoAvailable;
  bool _isVideoAvailable = false;

  bool get isAudioEnabled {
    switch (_remoteScreenType) {
      case RemoteScreenType.rtc:
        final rtcClient = _remoteScreenClient as RtcScreenClient;
        return rtcClient.remoteScreenRenderer.srcObject != null &&
            rtcClient.remoteScreenRenderer.srcObject!
                .getAudioTracks()
                .isNotEmpty &&
            rtcClient.remoteScreenRenderer.srcObject!
                .getAudioTracks()[0]
                .enabled;

      case RemoteScreenType.multicast:
      // TODO: implement it
    }

    return false;
  }

  StatelessWidget? get videoView {
    if (_remoteScreenClient == null) {
      return null;
    }

    switch (_remoteScreenType) {
      case RemoteScreenType.rtc:
        final rtcClient = _remoteScreenClient as RtcScreenClient;
        return RTCVideoView(
          rtcClient.remoteScreenRenderer,
          key: rtcClient.rtcWidgetKey,
        );
      case RemoteScreenType.multicast:
      // TODO: implement it
    }

    return null;
  }

  void Function(ChannelState? state)? onChannelStateChange;
  void Function(String hostName, String displayCode)? onInvitation;
  void Function()? onWebRtcClose;

  final Channel _channel;
  late RemoteScreenType _remoteScreenType;

  RemoteScreenClient? _remoteScreenClient;

  String? hostName;

  DisplayGroupSession(
    this._channel, {
    this.onInvitation,
    this.onChannelStateChange,
    this.onWebRtcClose,
  }) {
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
    this.hostName = hostName;
    _channel.send(InviteDisplayGroupResultMessage(status: 'accept'));
    _startRemoteScreen();
  }

  void reject() {
    _channel.send(InviteDisplayGroupResultMessage(status: 'reject'));
  }

  Future<void> stop({required String reason}) async {
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
    log.info('Display Group - Handling message: ${message.messageType}');

    switch (message.messageType) {
      case ChannelMessageType.inviteDisplayGroup:
        _onInviteMessage(message as InviteDisplayGroupMessage);
        break;

      case ChannelMessageType.remoteScreenStatus:
        // TODO:
        break;
      case ChannelMessageType.remoteScreenInfo:
        if (_remoteScreenType == RemoteScreenType.rtc &&
            _remoteScreenClient is RtcScreenClient) {
          await _onRemoteScreenInfo(message as RemoteScreenInfoMessage);
        }
        break;
      case ChannelMessageType.remoteScreenSignal:
        final signalMessage = message as RemoteScreenSignalMessage;
        if (_remoteScreenType == RemoteScreenType.rtc &&
            _remoteScreenClient is RtcScreenClient) {
          final rtcClient = _remoteScreenClient as RtcScreenClient;
          rtcClient.handleSignalMessage(signalMessage.signal!);
        }
        break;
      case ChannelMessageType.multicastInfo:
        if (_remoteScreenType == RemoteScreenType.multicast &&
            _remoteScreenClient is MulticastScreenClient) {
            await _onMulticastInfo(message as MulticastInfoMessage);
        }
        break;
      default:
        break;
    }
  }

  void _onInviteMessage(InviteDisplayGroupMessage message) {
    _remoteScreenType = RemoteScreenType.fromDisplayGroupType(message.connectionType);
    onInvitation?.call(
      message.hostName ?? '',
      message.displayCode ?? '',
    );
  }

  void _startRemoteScreen() {
    switch (_remoteScreenType) {
      case RemoteScreenType.rtc:
        _remoteScreenClient = RtcScreenClient(_channel);
        break;
      case RemoteScreenType.multicast:
        _remoteScreenClient = MulticastScreenClient(_channel);
        break;
    }
    _remoteScreenClient?.sendStartRemoteScreenMessage();
  }

  Future<void> _onRemoteScreenInfo(
    RemoteScreenInfoMessage infoMessage,
  ) async {
    final rtcClient = _remoteScreenClient as RtcScreenClient;
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
  }

  Future<void> _onMulticastInfo(MulticastInfoMessage infoMessage) async {
    final client = _remoteScreenClient as MulticastScreenClient;
    await client.handleMulticastInfo(MulticastInfo.fromMessage(infoMessage));
  }

  void onMute() {
    switch (_remoteScreenType) {
      case RemoteScreenType.rtc:
        final rtcClient = _remoteScreenClient as RtcScreenClient;
        if (rtcClient.remoteScreenRenderer.srcObject != null &&
            rtcClient.remoteScreenRenderer.srcObject!
                .getAudioTracks()
                .isNotEmpty) {
          rtcClient.remoteScreenRenderer.srcObject!
                  .getAudioTracks()[0]
                  .enabled =
              !rtcClient.remoteScreenRenderer.srcObject!
                  .getAudioTracks()[0]
                  .enabled;
        }

      case RemoteScreenType.multicast:
      // TODO: implement it
    }
  }
}
