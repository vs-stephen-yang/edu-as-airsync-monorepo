import 'dart:async';
import 'dart:io';

import 'package:display_cast_flutter/model/profile.dart';
import 'package:display_cast_flutter/model/webrtc_connector.dart';
import 'package:display_cast_flutter/utilities/channel_util.dart';
import 'package:display_channel/display_channel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'log.dart';

class WebRTCHelper {
  // 1. 創建一個靜態變量 _instance，用來存儲單例對象
  static WebRTCHelper? _instance;

  // 2. 將構造函數設為私有，防止被外部實例化
  WebRTCHelper._internal();

  // 3. 提供一個靜態的工廠構造函數，用來獲取單例對象
  factory WebRTCHelper() {
    _instance ??= WebRTCHelper._internal();
    return _instance!;
  }

  WebRTCConnector? webRTCConnector;
  List<RtcIceServer>? iceServerList;
  bool _isMainScreen = false;
  bool _isScreenType = false;
  final String _macMainScreenOrder = '1';
  final String _windowsMainScreenOrder = '0';

  Future<void> init({
    required String sessionId,
    required ProfileStore profileStore,
    required bool systemAudio,
    required Function(PresentSignalMessage message) sendPresentSignalMessage,
    required Function(RTCPeerConnectionState state) onRTCPeerConnectionState,
    required Function() onStreamInterrupted,
  }) async {
    // PeerConnect
    webRTCConnector = WebRTCConnector(
      preset: profileStore.getSelectedProfile().presets.first,
      systemAudio: systemAudio,
      sendSignalMessage: sendPresentSignalMessage,
      onConnectionState: onRTCPeerConnectionState,
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

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        _isMainScreen = true;
        break;
      case TargetPlatform.iOS:
        deviceId = 'broadcast';
        _isMainScreen = true;
        break;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        deviceId = {'exact': selectedSource.id};
        _isScreenType = (selectedSource.type == SourceType.Screen);
        if (Platform.isMacOS) {
          DesktopCapturerSource s = selectedSource;
          webRTCConnector?.subscriptions
              .add(s.onCaptureError.stream.listen((event) async {
            await webRTCConnector?.hangUp();
            await webRTCConnector?.onStreamInterrupted?.call();
          }));
          _isMainScreen =
              _isScreenType ? selectedSource.id == _macMainScreenOrder : false;
        } else {
          _isMainScreen = _isScreenType
              ? selectedSource.id == _windowsMainScreenOrder
              : false;
        }
        break;
      default:
        break;
    }

    await webRTCConnector
        ?.makeCall(
            deviceId: deviceId,
            isScreenType: _isScreenType,
            iceServerList: iceServerList)
        .then((value) {
      log.info('makeCall: ${value ? 'success' : 'failure'}');
      onResult(value);
    });
  }

  void stop() {
    // handle stream
    webRTCConnector?.streamStop();
    webRTCConnector?.hangUp();
  }

  Future<void> close() async {
    try {
      await webRTCConnector?.hangUp();
      webRTCConnector = null;
    } catch (e, stackTrace) {
      log.severe('close', e, stackTrace);
    }
  }

  setTouchBack(bool touchBack) {
    webRTCConnector!.touchBack = touchBack;
  }

  bool getTouchBack() {
    return webRTCConnector!.touchBack;
  }

  bool showTouchBack() {
    return (WebRTC.platformIsWindows || WebRTC.platformIsMacOS) &&
        (_isMainScreen);
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

  Future<void> receiveChangeQuality(ChannelMessage message) async {
    await webRTCConnector?.changePresentQuality(message.toJson());
  }

  Future<bool> changeHighQuality(Preset preset) async {
    return await webRTCConnector?.updateEncodingPreset(preset) ?? false;
  }

  bool isStreaming() {
    return webRTCConnector?.isFirstConnected ?? false;
  }
}
