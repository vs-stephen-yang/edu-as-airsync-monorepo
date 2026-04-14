import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:display_cast_flutter/model/profile.dart';
import 'package:display_cast_flutter/model/webrtc_connector.dart';
import 'package:display_cast_flutter/utilities/app_instance_create.dart';
import 'package:display_cast_flutter/utilities/audio_switch_manager.dart';
import 'package:display_cast_flutter/utilities/channel_util.dart';
import 'package:display_channel/display_channel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'log.dart';

class WebRTCHelper {
  WebRTCConnector? webRTCConnector;
  List<RtcIceServer>? iceServerList;
  bool _isScreenType = false;

  ValueNotifier<ChannelReconnectState> reconnectStateNotifier =
      ValueNotifier<ChannelReconnectState>(ChannelReconnectState.idle);

  Future<void> init({
    required String sessionId,
    required ProfileStore profileStore,
    required bool systemAudio,
    required bool autoVirtualDisplay,
    required AudioSwitchManager audioSwitchManager,
    required Function(PresentSignalMessage message) sendPresentSignalMessage,
    required Function(RTCPeerConnectionState state) onRTCPeerConnectionState,
    required Function() onStopPresent,
    required Function() onStreamInterrupted,
    required Function(bool isPaused, bool isStop) onTouchEvenWhenPaused,
  }) async {
    // PeerConnect
    webRTCConnector = WebRTCConnector(
      userId: AppInstanceCreate().instanceId,
      sessionId: sessionId,
      preset: profileStore.getSelectedProfile().presets.first,
      systemAudio: systemAudio,
      autoVirtualDisplay: autoVirtualDisplay,
      audioSwitchManager: audioSwitchManager,
      sendSignalMessage: sendPresentSignalMessage,
      onConnectionState: onRTCPeerConnectionState,
      onStopPresent: onStopPresent,
      onTouchEvenWhenPaused: onTouchEvenWhenPaused,
      reconnectStateNotifier: reconnectStateNotifier,
    );
    webRTCConnector?.onStreamInterrupted = (() async {
      onStreamInterrupted();
    });
  }

  Future<void> start({
    required dynamic selectedSource,
    required Function(bool result) onResult,
  }) async {
    dynamic deviceId;

    if (kIsWeb) {
      // In web environment, if do not enter this case first, an error will occur immediately if enter other platforms case.
    } else if (Platform.isAndroid) {
    } else if (Platform.isIOS) {
      deviceId = 'broadcast';
    } else if (WebRTC.platformIsDesktop) {
      deviceId = {'exact': selectedSource.id};
      _isScreenType = (selectedSource.type == SourceType.Screen);
      DesktopCapturerSource s = selectedSource;
      webRTCConnector?.subscriptions
          .add(s.onCaptureError.stream.listen((event) async {
        await webRTCConnector?.hangUp('onCaptureError');
        await webRTCConnector?.onStreamInterrupted?.call();
      }));
    }

    await webRTCConnector
        ?.peerConnectionConnect(
            deviceId: deviceId,
            isScreenType: _isScreenType,
            iceServerList: iceServerList)
        .then((value) {
      onResult(value);
    });
  }

  void pause(String sessionId, {Rect? pauseBtnRect, Rect? stopBtnRect}) {
    webRTCConnector?.pause(
        pauseBtnRect: pauseBtnRect, stopBtnRect: stopBtnRect);
  }

  void resume(String sessionId) {
    webRTCConnector?.resume();
  }

  void sendStop(StopPresentMessage msg) {
    webRTCConnector?.sendStop(msg);
  }

  Future<void> stop() async {
    // handle stream
    webRTCConnector?.stopStream();
    await webRTCConnector?.hangUp('webrtc_helper stop()');
  }

  Future<void> close() async {
    try {
      await webRTCConnector?.hangUp('webrtc_helper close()');
      webRTCConnector = null;
      reconnectStateNotifier.value = ChannelReconnectState.idle;
    } catch (e, stackTrace) {
      log.severe('close', e, stackTrace);
    }
  }

  setTouchBack(bool touchBack) {
    webRTCConnector?.touchBack = touchBack;
  }

  bool getTouchBack() {
    return webRTCConnector?.touchBack ?? false;
  }

  bool showTouchBack() {
    return WebRTC.platformIsAndroid ||
        ((WebRTC.platformIsWindows || WebRTC.platformIsMacOS) &&
            (_isScreenType));
  }

  Future<bool> isAccessibilityServiceAllowed() async {
    return await webRTCConnector?.isAccessibilityServiceAllowed() ?? false;
  }

  Future<void> openAccessibilitySettings() async {
    await webRTCConnector?.openAccessibilitySettings();
  }

  setReconnectState(ChannelReconnectState state) {
    webRTCConnector?.reconnectStateNotifier.value = state;
  }

  ChannelReconnectState getReconnectState() {
    return webRTCConnector?.reconnectStateNotifier.value ??
        ChannelReconnectState.idle;
  }

  Future<void> receiveSignalMessage(PresentSignalMessage message) async {
    await webRTCConnector?.handleSignal(message);
  }

  Future<void> receiveChangeQuality(ChangePresentQuality message) async {
    await webRTCConnector?.changePresentQuality(message);
  }

  Future<bool> changeHighQuality(Preset preset) async {
    return await webRTCConnector?.updateEncodingPreset(preset) ?? false;
  }

  bool isStreaming() {
    return webRTCConnector?.isFirstConnected ?? false;
  }

  Future<void> launchBroadcastUploadExtension() async {
    await WebRTC.invokeMethod('launchBroadcastUploadExtension');
  }

  Map<String, Object> getIceInfo() {
    return webRTCConnector?.getIceInfo() ?? {};
  }
}
