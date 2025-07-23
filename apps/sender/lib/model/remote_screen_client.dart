import 'package:display_cast_flutter/model/remote_screen_channel_signal.dart';
import 'package:display_cast_flutter/utilities/log.dart';
import 'package:display_cast_flutter/utilities/remote_screen_util.dart';
import 'package:display_cast_flutter/utilities/wakelock_manager.dart';
import 'package:display_cast_flutter/utilities/webrtc_util.dart';
import 'package:display_channel/display_channel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'package:ion_sdk_flutter/flutter_ion.dart';
import 'package:uuid/uuid.dart';
import 'package:display_cast_flutter/features/protoc/event.pb.dart' as pb;
import 'package:display_cast_flutter/features/protoc/internal.pb.dart';

abstract class RemoteScreenClient {
  RemoteScreenClient(this._channel, String? sessionId)
      : _sessionId = sessionId ?? const Uuid().v4();

  final Channel? _channel;
  final String? _sessionId;

  bool _textureSizeChanged = false;

  StatelessWidget get createVideoView;
  bool get isVideoAvailable;

  RemoteScreenChannelSignal? _channelSignal;

  void handleSignalMessage(String signal) {
    // handle signal messages from the channel
    _channelSignal?.onPeerMessage(signal);
  }

  Future sendStopRemoteScreenMessage() async {
    final msg = StopRemoteScreenMessage(_sessionId);
    _channel?.send(msg);
  }

  Future sendRemoteScreenState(RemoteScreenStatus status) async {
    final stateMessage = RemoteScreenStatusMessage(_sessionId, status);
    _channel?.send(stateMessage);
  }

  Future remove();

  onVideoSizeChanged() {
    _textureSizeChanged = true;
  }

  void onKeyDown(KeyEvent event);

  void onTouchStart(PointerEvent event) {
    onTouchEvent(pb.TouchEvent_TouchEventType.TOUCH_POINT_START, event);
  }

  void onTouchMove(PointerEvent event) {
    onTouchEvent(pb.TouchEvent_TouchEventType.TOUCH_POINT_MOVE, event);
  }

  void onTouchEnd(PointerEvent event) {
    onTouchEvent(pb.TouchEvent_TouchEventType.TOUCH_POINT_END, event);
  }

  void onTouchEvent(
    pb.TouchEvent_TouchEventType eventType,
    PointerEvent event,
  );

  Future handleRemoteScreenInfo(
      String? url,
      String roomId,
      List<RtcIceServer>? iceServers,
      Function() onTrack,
      Function() onClose,
      );
}

class RtcScreenClient extends RemoteScreenClient {
  Client? _client;

  RTCVideoRenderer _remoteScreenRenderer = RTCVideoRenderer();
  RTCDataChannel? _dataChannel;

  final GlobalKey _rtcWidgetKey = GlobalKey();
  Size _textureSize = const Size(0, 0);
  Offset _textureOffset = const Offset(0, 0);
  bool _isFirstConnected = true;

  RtcScreenClient(super.channel, super.sessionId);

  @override
  StatelessWidget get createVideoView => RTCVideoView(_remoteScreenRenderer, key: _rtcWidgetKey);

  @override
  bool get isVideoAvailable => _remoteScreenRenderer.textureId != null;

  onDataChannelState(RTCDataChannelState state) {
    log.info('Remote screen: Data channel state ${state.name}');

    if (state == RTCDataChannelState.RTCDataChannelClosed) {
      _dataChannel = null;
    }
  }

  // send signal messages to the peer via the channel
  void _sendSignalMessageToPeer(String message) {
    _channel?.send(
      RemoteScreenSignalMessage(_sessionId, message),
    );
  }

  Signal _createChannelSignal() {
    _channelSignal = RemoteScreenChannelSignal(_sendSignalMessageToPeer);
    return _channelSignal!;
  }

  Signal _createWebsocketSignal(String url) {
    return JsonRPCSignal(url);
  }

  Signal _createSignal(String? url) {
    if (url == null) {
      // Signaling through the channel
      return _createChannelSignal();
    } else {
      // Signaling through a separate websocket connection
      // TODO: Retain for backward compatibility. Plan to deprecate and remove in future versions.
      return _createWebsocketSignal(url);
    }
  }

  @override
  Future handleRemoteScreenInfo(
      String? url,
      String roomId,
      List<RtcIceServer>? iceServers,
      Function() onTrack,
      Function() onClose,
      ) async {
    log.info('Remote screen: Create client');

    final signal = _createSignal(url);

    _client = await Client.create(
      sid: roomId,
      uid: const Uuid().v4(),
      signal: signal,
      config: WebRTCUtil.buildWebRtcConfiguration(iceServers),
    );

    _dataChannel = await _client!.createDataChannel(_sessionId!);
    _dataChannel!.onDataChannelState = onDataChannelState;

    _client!.ontrack = (track, RemoteStream remoteStream) async {
      log.info('Remote screen: Track added ${track.label}');

      await _remoteScreenRenderer.initialize();
      _remoteScreenRenderer.srcObject = remoteStream.stream;
      await WakelockManager()
          .manageWakelock(AppScene.rtcRemoteScreenDisplaying);
    };
    _client!.onConnectionState = (RTCPeerConnectionState state) {
      log.info('Remote screen: Connection state ${state.name}');

      switch (state) {
        case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
          onClose();
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
          if (_isFirstConnected) {
            onTrack();
            _isFirstConnected = false;
          }
          break;
        default:
      }
    };

    _client!.ondatachannel = (RTCDataChannel dc) {
      log.info('Remote screen: Data channel added ${dc.label}');
      if (dc.label == _sessionId) {
        _dataChannel = dc;
        _dataChannel!.onDataChannelState = onDataChannelState;
      }
    };

    _client!.onSignalClose = (int code, String reason) {
      log.info('Remote screen: signal closed');
      onClose();
    };
  }

  @override
  Future remove() async {
    if (_remoteScreenRenderer.textureId != null) {
      _remoteScreenRenderer.srcObject = null;
    }
    await _remoteScreenRenderer.dispose();
    _remoteScreenRenderer = RTCVideoRenderer();

    log.info('Remote screen: Closing client');
    _client?.close();
    _client = null;

    await WakelockManager().manageWakelock(AppScene.rtcRemoteScreenHangUp);
  }

  void updateTextureInfo() {
    Element? textureElement;
    void textureVisitor(Element element) {
      if (textureElement != null) return;

      if (element.widget is Texture) {
        textureElement = element;
      } else {
        element.visitChildElements(textureVisitor);
      }
    }

    _rtcWidgetKey.currentContext?.visitChildElements(textureVisitor);
    if (textureElement == null) {
      log.warning('texture widget not found');
      return;
    } else {
      final RenderBox renderBox =
      textureElement!.findRenderObject() as RenderBox;
      _textureSize = renderBox.size;
      _textureOffset = renderBox.localToGlobal(Offset.zero);
      log.info(
          'texture widget size: (${_textureSize.width.toStringAsFixed(2)}, ${_textureSize.height.toStringAsFixed(2)}), offset: (${_textureOffset.dx.toStringAsFixed(2)}, ${_textureOffset.dy.toStringAsFixed(2)})');
      _textureSizeChanged = false;
    }
  }

  @override
  void onKeyDown(KeyEvent event) {
    final eventMessage = EventMessage();
    eventMessage.keyEvent = toKeyEvent(event);

    _dataChannel?.send(
      RTCDataChannelMessage.fromBinary(eventMessage.writeToBuffer()),
    );
  }

  @override
  void onTouchEvent(
      pb.TouchEvent_TouchEventType eventType,
      PointerEvent event,
      ) {
    if (_textureSizeChanged) {
      updateTextureInfo();
    }

    final curTouchEventPoint = pb.TouchEventPoint();
    curTouchEventPoint.x =
        (event.position.dx - _textureOffset.dx) / _textureSize.width;
    /* make curTouchEventPoint.x between 0.0 ~ 1.0 */
    curTouchEventPoint.x = curTouchEventPoint.x.clamp(0.0, 1.0);
    curTouchEventPoint.y =
        (event.position.dy - _textureOffset.dy) / _textureSize.height;
    /* make curTouchEventPoint.y between 0.0 ~ 1.0 */
    curTouchEventPoint.y = curTouchEventPoint.y.clamp(0.0, 1.0);

    curTouchEventPoint.id = event.pointer;

    final curTouchEvent = pb.TouchEvent();
    curTouchEvent.eventType = eventType;
    curTouchEvent.touchPoints.add(curTouchEventPoint);

    final curEventMessage = EventMessage();
    curEventMessage.touchEvent = curTouchEvent;

    _dataChannel?.send(
      RTCDataChannelMessage.fromBinary(curEventMessage.writeToBuffer()),
    );
  }
}
