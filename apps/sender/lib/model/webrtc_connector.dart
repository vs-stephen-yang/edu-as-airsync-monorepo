import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:display_cast_flutter/features/protoc/event.pb.dart';
import 'package:display_cast_flutter/features/protoc/internal.pb.dart';
import 'package:display_cast_flutter/model/profile.dart';
import 'package:display_cast_flutter/model/rtc_stats.dart';
import 'package:display_cast_flutter/model/rtc_stats_firehose.dart';
import 'package:display_cast_flutter/model/rtc_stats_parser.dart';
import 'package:display_cast_flutter/model/rtc_stats_presenter.dart';
import 'package:display_cast_flutter/model/rtc_stats_reporter.dart';
import 'package:display_cast_flutter/utilities/app_amplitude.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/utilities/app_amplify_firehose.dart';
import 'package:display_cast_flutter/utilities/app_instance_create.dart';
import 'package:display_cast_flutter/utilities/app_analytics_outbound.dart';
import 'package:display_cast_flutter/utilities/audio_switch_manager.dart';
import 'package:display_cast_flutter/utilities/bounded_list.dart';
import 'package:display_cast_flutter/utilities/channel_util.dart';
import 'package:display_cast_flutter/utilities/list_util.dart';
import 'package:display_cast_flutter/utilities/log.dart';
import 'package:display_cast_flutter/utilities/rtc_metrics_rolling_aggregator.dart';
import 'package:display_cast_flutter/utilities/sdp_utility.dart';
import 'package:display_cast_flutter/utilities/version_util.dart';
import 'package:display_cast_flutter/utilities/wakelock_manager.dart';
import 'package:display_cast_flutter/utilities/web_browser_detect.dart';
import 'package:display_cast_flutter/utilities/webrtc_log_manager.dart';
import 'package:display_cast_flutter/utilities/webrtc_util.dart';
import 'package:display_channel/display_channel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_input_injection/flutter_input_injection.dart';
import 'package:flutter_input_injection/flutter_input_injection_platform_interface.dart';
import 'package:flutter_virtual_display/flutter_virtual_display.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:window_size/window_size.dart';

class _EmaState {
  double emaX;
  double emaY;

  double lastSentX;
  double lastSentY;

  int lastSentUs; // microsecondsSinceEpoch

  _EmaState(
      this.emaX, this.emaY, this.lastSentX, this.lastSentY, this.lastSentUs);
}

class WebRTCConnector {
  WebRTCConnector({
    required String sessionId,
    required this.preset,
    required this.systemAudio,
    required this.autoVirtualDisplay,
    required this.audioSwitchManager,
    required this.sendSignalMessage,
    required this.onConnectionState,
    required this.onStopPresent,
    required this.onTouchEvenWhenPaused,
    required this.reconnectStateNotifier,
  }) : _sessionId = sessionId {
    if (!kIsWeb && Platform.isAndroid) {
      _flutterInputInjectionPlugin.initialize(
          inputInjectionMethod: InputInjectionMethod.accessibilityService);
    }
  }

  final List<StreamSubscription> subscriptions = [];

  void Function(PresentSignalMessage message) sendSignalMessage;
  void Function(RTCPeerConnectionState state) onConnectionState;
  void Function() onStopPresent;
  Function(RtcVideoOutboundStats stats)? onVideoStatsReport;
  void Function(bool isPause, bool isStop) onTouchEvenWhenPaused;

  final AudioSwitchManager audioSwitchManager;

  final String _sessionId;

  dynamic _deviceId;
  int _screenId = 0;
  RTCPeerConnection? _pc;
  RTCDataChannel? _touchbackDataChannel;
  RTCDataChannel? _controlDataChannel;

  RTCDataChannelState? _rtcControlDataChannelState;
  RTCPeerConnectionState? _peerConnectionState;

  MediaStream? _localStream;
  final Completer _descriptionSetCompleter = Completer();

  bool get isFirstConnected {
    return _isRtcFirstConnected;
  }

  bool _isRtcFirstConnected = false;
  bool _isPaused = false; // Track pause state

  // Add rect for pause, stop button
  Rect? _pauseButtonRect, _stopButtonRect;

  // change present quality
  bool _streamPublished = false;
  ChangePresentQuality? _pendingChangePresentQuality;

  static final _resolutionUltraHd = (width: 3840, height: 2160);

  double _screenWidth = _resolutionUltraHd.width.toDouble();
  double _screenHeight = _resolutionUltraHd.height.toDouble();
  static int _maxTrackWidth = _resolutionUltraHd.width;
  static int _maxTrackHeight = _resolutionUltraHd.height;
  int _trackWidth = _maxTrackWidth;
  int _trackHeight = _maxTrackHeight;
  int _actualWidth = 1920;
  int _actualHeight = 1080;
  int _decodeHeightLimit = 0;

  static const double _defaultMinFrameRate = 30.0;
  static const double _defaultFrameRate = 30.0;
  double _idealTrackFrameRate = _defaultFrameRate;
  double _minTrackFrameRate = _defaultMinFrameRate;

  // disable webrtc audio processing
  // Note: the audio constraints in webrtc-flutter only works on web platform
  static const _audioConstraints = {
    'autoGainControl': false,
    'echoCancellation': false,
    'gooAutoGainControl': false,
    'noiseSuppression': false
  };

  Preset preset;
  bool touchBack = true;
  bool systemAudio = false;
  bool autoVirtualDisplay = false;
  final List<String> _codecPreferences = ['h264', 'vp8', 'vp9'];
  bool _isScreenType = false;

  int get trackHeight => _trackHeight;
  final _flutterInputInjectionPlugin = FlutterInputInjection();
  Future<void> Function()? onStreamInterrupted;

  Timer? _statsTimer;
  final _statsTimerInterval = const Duration(seconds: 1);
  RtcStatsParser? _rtcStatsParser;
  RtcStatsPresenter? _rtcStatsPresenter;
  RtcMetricsWindowAggregator<RtcVideoOutboundStats>? _rtcMetricsAggregator;

  DateTime _lastUploadAt = DateTime.fromMillisecondsSinceEpoch(0);
  bool _uploading = false;

  // 存最新一份要上傳的 payload（已序列化）
  Map<String, dynamic>? _latestReportsPayload;

  // keep last 20 RtcVideoOutboundStats
  final _videoOutboundStatsHistory = BoundedList<RtcVideoOutboundStats>(20);

  List<RtcIceServer> _iceServerList = [];

  ValueNotifier<ChannelReconnectState> reconnectStateNotifier;

  set reconnectState(ChannelReconnectState state) {
    reconnectStateNotifier.value = state;
  }

  ChannelReconnectState get reconnectState => reconnectStateNotifier.value;

  /// EventChannel (來自 macOS 原生端)
  static const EventChannel _ecForegroundApp =
      EventChannel('com.viewsonic.display.cast/foreground_app_events');

  /// 你要判斷的 bundle id list
  static final List<String> _targetBundleId = [
    'com.viewsonic.droid',
    'com.microsoft.Powerpoint',
  ];

  /// StreamSubscription
  StreamSubscription? _subForegroundApp;

  static const EventChannel _ecSlideShow =
      EventChannel('com.viewsonic.display.cast/ppt_slideshow_events');

  bool isRunning = false;
  StreamSubscription? _subSlideShow;

  final Map<int, _EmaState> _emaById = {};

  // EMA（指數移動平均）：alpha 越小越平滑但延遲越大
  final double _emaAlpha = 0.35;

  // 降採樣：小於這個像素距離就不送 MOVE（抑制抖動 + 減點）
  final double _minMovePx = 10.0;

  //region connect and communication

  Future<bool> peerConnectionConnect(
      {required dynamic deviceId,
      required bool isScreenType,
      required List<RtcIceServer>? iceServerList}) async {
    _deviceId = deviceId;
    _isScreenType = isScreenType;
    if (!kIsWeb && WebRTC.platformIsDesktop && _isScreenType) {
      // macOS, Windows
      _screenId = int.parse(_deviceId['exact']);
    }
    _iceServerList = iceServerList!;
    final configuration = WebRTCUtil.buildWebRtcConfiguration(iceServerList);

    _pc = await createPeerConnection(configuration);

    _pc!.onAddTrack = _onAddTrack;
    _pc!.onSignalingState = _onSignalingState;
    _pc!.onIceGatheringState = _onIceGatheringState;
    _pc!.onIceConnectionState = _onIceConnectionState;
    _pc!.onConnectionState = _onPeerConnectionState;
    _pc!.onIceCandidate = _onIceCandidate;

    // start the event log
    if (await WebRTCLogManager().startLog(_pc)) {
      final logFilePath = WebRTCLogManager().eventLogFilePath;
      log.info('Start RTC event log: $logFilePath');
    }

    _streamPublished = await _publish();
    if (_streamPublished && _pendingChangePresentQuality != null) {
      await changePresentQuality(_pendingChangePresentQuality!);
      _pendingChangePresentQuality = null;
    }
    return _streamPublished;
  }

  Future<void> _updateScreenSize() async {
    if (!kIsWeb && Platform.isWindows) {
      // PlatformDispatcher did not support get windows width and height yet.
      // Using window_size for workaround.
      // https://github.com/flutter/flutter/issues/125938
      // https://github.com/flutter/flutter/issues/125939
      // todo: tracking issue status to remove this workaround.
      Screen? screen = await getCurrentScreen();
      if (screen != null) {
        _screenWidth = screen.frame.width;
        _screenHeight = screen.frame.height;
      }
    } else {
      double devicePixelRatio =
          PlatformDispatcher.instance.displays.first.devicePixelRatio;
      _screenWidth = PlatformDispatcher.instance.displays.first.size.width /
          devicePixelRatio;
      _screenHeight = PlatformDispatcher.instance.displays.first.size.height /
          devicePixelRatio;
    }
  }

  Future<bool> _setCodecPreferences() async {
    try {
      final List<String> desiredOrder = _codecPreferences.map((codec) {
        return 'video/${codec.toUpperCase()}';
      }).toList();

      RTCRtpCapabilities capabilities = await getRtpSenderCapabilities("video");
      final modifiedCapabilities = capabilities.codecs!
          .where((codec) => desiredOrder.contains(codec.mimeType))
          .toList()
        ..sort((a, b) => desiredOrder
            .indexOf(a.mimeType)
            .compareTo(desiredOrder.indexOf(b.mimeType)));

      List<RTCRtpTransceiver> transceivers = await _pc!.transceivers;
      for (var transceiver in transceivers) {
        if (transceiver.sender.track!.kind == 'video') {
          if (kIsWeb == false && Platform.isAndroid) {
            await transceiver
                .setCodecPreferencesBySenderId(modifiedCapabilities);
          } else {
            await transceiver.setCodecPreferences(modifiedCapabilities);
          }
        }
      }
      log.info('succeeded to set codec preferences');
    } catch (e, stackTrace) {
      // TODO: Temporarily lower severity to warning. Restore to error after fixing setCodecPreferences.
      log.warning('failed to set codec preferences', e, stackTrace);
      return false;
    }
    return true;
  }

  void _updateAudioCodecPreferences(CodecCapabilitySelector codecSelector) {
    var audioCapabilities = codecSelector.getCapabilities('audio');
    if (audioCapabilities != null) {
      // Retain only Opus codec
      audioCapabilities.codecs = audioCapabilities.codecs
          .where((codec) => (codec['codec'] as String).toLowerCase() == 'opus')
          .toList();
      audioCapabilities.setCodecPreferences('audio', audioCapabilities.codecs);
      codecSelector.setCapabilities(audioCapabilities);
    }
  }

  void _updateVideoCodecPreferences(
      CodecCapabilitySelector codecSelector, bool isWebOnMacOS) {
    var videoCapabilities = codecSelector.getCapabilities('video');
    if (videoCapabilities != null) {
      videoCapabilities.codecs = videoCapabilities.codecs.where((codec) {
        var codecName = (codec['codec'] as String).toLowerCase();
        var payload = codec['payload'].toString();

        if (codecName == _codecPreferences[0]) {
          // Allow all profiles for macOS on the web, otherwise exclude baseline profile
          if (isWebOnMacOS) {
            return true;
          } else {
            var profile = codecSelector.getH264CodecProfile(payload);
            return profile != H264CodecProfile.baseline;
          }
        }
        return false; // Exclude all other codecs
      }).toList();

      videoCapabilities.setCodecPreferences('video', videoCapabilities.codecs);
      codecSelector.setCapabilities(videoCapabilities);
    }
  }

  void _modifySDPForCodecPreferences(RTCSessionDescription description) {
    try {
      var codecSelector = CodecCapabilitySelector(description.sdp!);

      // Update audio codec preferences
      _updateAudioCodecPreferences(codecSelector);

      // Check if the platform is macOS on the web
      bool isWebOnMacOS = _isWebOnMacOS();

      // Update video codec preferences
      _updateVideoCodecPreferences(codecSelector, isWebOnMacOS);

      description.sdp = codecSelector.sdp();

      log.info('modifySDPForCodecPreferences vcodec:${_codecPreferences[0]}');
    } catch (e, stackTrace) {
      log.severe('Error modifying SDP for codec preferences', e, stackTrace);
    }
  }

  bool _isWebOnMacOS() {
    final browser = Browser.detectOrNull();
    return browser != null && browser.osPlatform == OSPlatform.macOS;
  }

  Future<void> _createControlDataChannel() async {
    _controlDataChannel = await _pc?.createDataChannel(
      'pc-dc-control',
      RTCDataChannelInit()..id = 2,
    );

    _controlDataChannel!.onDataChannelState = (state) {
      log.info('Data channel state of control: ${state.name}');

      _rtcControlDataChannelState = state;

      trackTrace('control_dc_state', properties: {
        'target': state.name,
      });
    };

    _controlDataChannel!.onMessage = _onControlMessage;
  }

  Future<void> _createTouchbackDataChannel() async {
    // Create a data channel for touchback event
    _touchbackDataChannel = await _pc?.createDataChannel(
      'pc-dc',
      RTCDataChannelInit()..id = 1,
    );

    _touchbackDataChannel!.onDataChannelState = (state) {
      log.info('Data channel state of touchback: ${state.name}');

      trackTrace('dc_state', properties: {
        'target': state.name,
      });
    };

    _touchbackDataChannel!.onMessage = _onTouchbackMessage;
  }

  // When sharing a browser tab, if the shared page has no animation,
  // frame rate may drop to 1fps. On macOS with hardware encoder (VideoToolbox),
  // receiver may see black screen for up to 1 minute; software encoder (OpenH264)
  // improves it to ~5 seconds.
  // Likely caused by buffering in capture pipeline.
  // Increasing capture FPS helps reduce delay.
  //
  // Setting minFrameRate in getDisplayMedia() fails, but applyConstraints() works.
  // Possibly because OS capture limits FPS, and applyConstraints() triggers
  // frame duplication in WebRTC.
  //
  // Related: https://issues.chromium.org/issues/40922733
  Future<void> _applyWebMinFrameRateWorkaround(MediaStreamTrack track) async {
    int constraintHeight = _getConstraintHeight();
    final constraints = <String, dynamic>{
      'frameRate': {
        'ideal': _idealTrackFrameRate,
        'min': min(_idealTrackFrameRate, _minTrackFrameRate),
      },
      'width': _trackWidth,
      'height': constraintHeight,
    };
    log.info('Apply web video constraints: $constraints');
    await track.applyConstraints(constraints);
    log.info(
        'Applied idealFPS: $_idealTrackFrameRate minFPS: $_minTrackFrameRate');
  }

  void _applyVideoContentHint(MediaStreamTrack track) {
    // see https://www.w3.org/TR/mst-content-hint/#dom-mediastreamtrack-contenthint
    //
    // The track should be treated as if video details are extra important. This
    // is generally applicable to presentations or web pages with text content,
    // painting or line art. This setting would normally optimize for detail in
    // the resulting individual frames rather than smooth playback. Artifacts
    // from quantization or downscaling that make small text or line art unintelligible
    // should be avoided.
    //
    track.contentHint = "detail";
    log.info('Applied content hint "details" to video track');
  }

  Future<bool> _publish() async {
    await _createTouchbackDataChannel();
    await _createControlDataChannel();

    _idealTrackFrameRate = _defaultFrameRate;
    _minTrackFrameRate = _defaultMinFrameRate;
    _trackWidth = _maxTrackWidth;
    _trackHeight = _maxTrackHeight;

    _localStream = await getDisplayMedia();
    if (_localStream == null || _pc == null) {
      // GetDisplayMedia method will using different UI UX (control by system)
      // to prompt the user to select screen in Web, Android, iOS.
      // Therefore we did not implement timeout mechanism in those sender,
      // it may disconnect (_pc will be null) due to receiver's timeout.
      // Web: popup a system dialog
      // Android: MediaProjection
      // iOS: Broadcast extension
      await hangUp(
          'getDisplayMedia [_localStream is null: ${(_localStream == null)}, _pc is null: ${_pc == null}]');
      // return false to run makeCall's failure process.
      return false;
    }
    _localStream?.getTracks().forEach((element) {
      element.onEnded = () async {
        await hangUp('_localStream onEnded');
        await onStreamInterrupted?.call();
      };
    });
    for (MediaStreamTrack track in _localStream!.getTracks()) {
      log.info('Adding track: ${track.kind}');
      if (track.kind == 'video') {
        _applyVideoContentHint(track);
        // On Web, we need to apply minFrameRate to avoid static content
        // delay or black screen issue.
        if (kIsWeb) {
          _screenWidth = _resolutionUltraHd.width.toDouble();
          _screenHeight = _resolutionUltraHd.height.toDouble();
          _maxTrackWidth = _resolutionUltraHd.width;
          _maxTrackHeight = _resolutionUltraHd.height;
          await _applyWebMinFrameRateWorkaround(track);
        }
      }
      await _pc!.addTrack(track, _localStream!);
    }

    final bool setCodecPreferencesResult = await _setCodecPreferences();

    final offerConstraints = <String, dynamic>{
      'mandatory': {
        'OfferToReceiveAudio': false,
        'OfferToReceiveVideo': false,
      },
      'optional': [],
    };

    final offer = await _pc!.createOffer(offerConstraints);
    RTCSessionDescription fixedOffer = SdpUtil.fixSdp(offer);

    if (!setCodecPreferencesResult) {
      // Due to incomplete implementation of `setCodecPreferences`
      // in flutter-webrtc, there are issues on certain devices. As a workaround,
      // we have opted to modify the SDP. However, this workaround currently only
      // supports selecting a single codec."
      _modifySDPForCodecPreferences(fixedOffer);
    }

    try {
      await _pc!.setLocalDescription(fixedOffer);

      var message = PresentSignalMessage(null, SignalMessageType.offer);
      message.sdp = fixedOffer.sdp;
      sendSignalMessage(message);

      startStatsTimer();
      startAppBundleIdMonitor();
      await WakelockManager().manageWakelock(AppScene.rtcPublishing);

      return true;
    } catch (e, stackTrace) {
      log.severe('setLocalDescription', e, stackTrace);
      return false;
    }
  }

  Future<MediaStream?> getDisplayMedia() async {
    try {
      int constraintHeight = _getConstraintHeight();
      final videoConstraints = kIsWeb
          ? {
              // note: TypeError - Failed to execute 'getDisplayMedia' on 'MediaDevices':
              // Malformed constraint: Cannot use both optional/mandatory and specific constraints.
              'frameRate': _idealTrackFrameRate,
              'width': _trackWidth,
              'height': constraintHeight,
            }
          : {
              'deviceId': _deviceId,
              'autoSelectVirtualDisplay': autoVirtualDisplay,
              'mandatory': {
                'frameRate': _idealTrackFrameRate,
              },
              'width': _trackWidth,
              'height': constraintHeight,
            };
      int? virtualAudioInputDeviceID; // for macOS only
      if (_isAudioCaptureAllowed()) {
        if (await audioSwitchManager.switchToVirtualAudioOutput()) {
          virtualAudioInputDeviceID =
              await audioSwitchManager.getVirtualAudioInputDeviceID();
        }
      }
      final audioConstraints = _isAudioCaptureAllowed()
          ? {
              ..._audioConstraints,
              if (virtualAudioInputDeviceID != null)
                'deviceId': virtualAudioInputDeviceID.toString(),
            }
          : false;
      final constraints = <String, dynamic>{
        'audio': audioConstraints,
        'video': videoConstraints,
      };
      return await navigator.mediaDevices.getDisplayMedia(constraints);
    } catch (e, stackTrace) {
      String exception = e.toString().toLowerCase();
      if (exception.contains('NotAllowedError'.toLowerCase()) ||
          exception.contains('screenRequestPermissions'.toLowerCase())) {
        log.warning('getDisplayMedia', e, stackTrace);
      } else {
        log.severe('getDisplayMedia', e, stackTrace);
      }
      return null;
    }
  }

  /// handle signal message from Display, ex. offer, answer, candidates
  Future<void> handleSignal(PresentSignalMessage msg) async {
    final type = msg.signalType.toString(); //msg['type'];

    switch (msg.signalType) {
      case SignalMessageType.offer:
        // handle offer from the peer
        final offer = RTCSessionDescription(msg.sdp, type);
        await _pc!.setRemoteDescription(offer);
        // create answer
        final answer = await _pc!.createAnswer();
        RTCSessionDescription fixedAnswer = SdpUtil.fixSdp(answer);
        await _pc!.setLocalDescription(fixedAnswer);
        if (!_descriptionSetCompleter.isCompleted) {
          _descriptionSetCompleter.complete();
        }
        break;
      case SignalMessageType.answer:
        // handle answer from the peer
        final answer = RTCSessionDescription(msg.sdp, 'answer');
        await _pc!.setRemoteDescription(answer);
        if (!_descriptionSetCompleter.isCompleted) {
          _descriptionSetCompleter.complete();
        }
        break;
      case SignalMessageType.candidate:
        final candidate =
            RTCIceCandidate(msg.candidate, msg.sdpMid, msg.sdpMLineIndex);
        await _descriptionSetCompleter.future;
        // pc may be null when disconnect peer connection
        await _pc?.addCandidate(candidate);
        break;
      case null:
        break;
    }
  }

  // Receive a control message from the data channel
  void _onControlMessage(RTCDataChannelMessage data) {
    // The control message is in json format
    if (data.isBinary) {
      // Ignore the binary message
      return;
    }

    try {
      final json = jsonDecode(data.text);
      final message = ChannelMessage.parse(json);

      if (message != null) {
        _onChannelMessageFromDataChannel(message);
      }
    } catch (e, stackTrace) {
      log.severe('_onControlMessage', e, stackTrace);
    }
  }

  // send a control message over the data channel
  void _sendControlMessage(ChannelMessage message) {
    final text = jsonEncode(message.toJson());
    if (_rtcControlDataChannelState == RTCDataChannelState.RTCDataChannelOpen &&
        _peerConnectionState ==
            RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
      _controlDataChannel?.send(RTCDataChannelMessage(text));
    }
  }

  void pause({Rect? pauseBtnRect, Rect? stopBtnRect}) {
    _isPaused = true; //
    _pauseButtonRect = pauseBtnRect;
    _stopButtonRect = stopBtnRect;
    // Sends a control message to remotely pause rendering.
    _sendControlMessage(
      PausePresentMessage(_sessionId),
    );
  }

  void resume() {
    _isPaused = false; // Clear pause state
    _pauseButtonRect = null; // Clear button position info
    _stopButtonRect = null;
    // Sends a control message to remotely resume rendering.
    _sendControlMessage(
      ResumePresentMessage(_sessionId),
    );
  }

  // Helper method to check if a point is within the pause button
  bool _isPointInPauseButton(Offset point) {
    if (_pauseButtonRect == null) return false;
    if (_pauseButtonRect!.contains(point)) {
      return true;
    }
    return false;
  }

  bool _isPointInStopButton(Offset point) {
    if (_stopButtonRect == null) return false;
    if (_stopButtonRect!.contains(point)) {
      return true;
    }
    return false;
  }

  void sendStop(StopPresentMessage message) {
    _isPaused = false; // Reset pause state

    _sendControlMessage(
      message,
    );
  }

  // handle a channel message from the data channel
  void _onChannelMessageFromDataChannel(ChannelMessage message) {
    switch (message.messageType) {
      case ChannelMessageType.changePresentQuality:
        changePresentQuality(message as ChangePresentQuality);
        break;
      case ChannelMessageType.stopPresent:
        onStopPresent();
        break;
      default:
        break;
    }
  }

  void _onTouchbackMessage(RTCDataChannelMessage data) async {
    if (!data.isBinary) {
      return;
    }

    // touch event data
    if (!_isTouchBackAllowed()) {
      return;
    }

    EventMessage eventMessage = EventMessage.fromBuffer(data.binary);

    if (eventMessage.hasTouchEvent()) {
      await _onTouchMessage(eventMessage);
    }
  }

  /// Returns [value] if it is finite, otherwise returns [fallback].
  double sanitizeDouble(double value, [double fallback = 0.0]) =>
      value.isFinite ? value : fallback;

  /// Converts [value] to an int if it is finite, otherwise returns [fallback].
  int safeToInt(double value, [int fallback = 0]) =>
      value.isFinite ? value.toInt() : fallback;

  /// Clamps integer [v] between [min] and [max].
  int clampInt(int v, int min, int max) => v < min ? min : (v > max ? max : v);

  /// Returns the ceiling of [value] if finite, otherwise returns [fallback].
  int safeCeil(double value, [int fallback = 1]) =>
      value.isFinite ? value.ceil() : fallback;

  Future<void> _onTouchMessage(EventMessage eventMessage) async {
    // Validate touchEvent and ensure touchPoints exist
    final touchEvent = eventMessage.touchEvent;
    if (touchEvent.touchPoints.isEmpty) {
      log.warning('Touch event missing or has no touch points');
      return;
    }

    // Determine the touch action type
    int action = FlutterInputInjection.TOUCH_POINT_START;
    final type = touchEvent.eventType;
    if (type == TouchEvent_TouchEventType.TOUCH_POINT_START) {
      action = FlutterInputInjection.TOUCH_POINT_START;
    } else if (type == TouchEvent_TouchEventType.TOUCH_POINT_MOVE) {
      action = FlutterInputInjection.TOUCH_POINT_MOVE;
    } else if (type == TouchEvent_TouchEventType.TOUCH_POINT_END) {
      action = FlutterInputInjection.TOUCH_POINT_END;
    }

    final tp0 = touchEvent.touchPoints.first;

    // Sanitize incoming remote coordinates
    double remoteX = sanitizeDouble(tp0.x, 0.0);
    double remoteY = sanitizeDouble(tp0.y, 0.0);

    // Clamp normalized coordinates to [0, 1] range
    remoteX = (remoteX).clamp(0.0, 1.0);
    remoteY = (remoteY).clamp(0.0, 1.0);

    final int id = tp0.id;

    // Handle paused state — convert normalized coords to pixel positions
    if (_isPaused) {
      await _updateScreenSize();

      // Sanitize screen dimensions
      final double screenW = sanitizeDouble(_screenWidth, 0.0);
      final double screenH = sanitizeDouble(_screenHeight, 0.0);

      // Compute raw pixel positions with NaN/Inf safety
      final int rawX = safeToInt(sanitizeDouble(remoteX * screenW, 0.0), 0);
      final int rawY = safeToInt(sanitizeDouble(remoteY * screenH, 0.0), 0);

      // Calculate valid range for screen coordinates
      final int maxX = (safeCeil(screenW, 1) - 1).clamp(0, 1 << 30);
      final int maxY = (safeCeil(screenH, 1) - 1).clamp(0, 1 << 30);

      // Clamp final pixel coordinates
      final int injectX = clampInt(rawX, 0, maxX);
      final int injectY = clampInt(rawY, 0, maxY);

      // Check if touch falls within pause/stop button area
      final offset = Offset(injectX.toDouble(), injectY.toDouble());
      if (_isPointInPauseButton(offset)) {
        onTouchEvenWhenPaused(true, false);
        return;
      }
      if (_isPointInStopButton(offset)) {
        onTouchEvenWhenPaused(false, true);
        return;
      }

      log.info('Touch event ignored due to paused state');
      return;
    }

    // Normal state: send sanitized and clamped normalized coordinates
    final curX = remoteX;
    final curY = remoteY;
    final nowUs = DateTime.now().microsecondsSinceEpoch;

    // START：初始化 EMA 與 lastSent，直接送
    if (action == FlutterInputInjection.TOUCH_POINT_START) {
      _emaById[id] = _EmaState(curX, curY, curX, curY, nowUs);

      unawaited(_flutterInputInjectionPlugin.sendNormalizedTouch(
        _screenId,
        autoVirtualDisplay,
        FlutterInputInjection.TOUCH_POINT_START,
        id,
        curX,
        curY,
      ));
      return;
    }

    // 確保狀態存在（容錯）
    final st = _emaById.putIfAbsent(
      id,
      () => _EmaState(curX, curY, curX, curY, nowUs),
    );

    // EMA 濾波（normalized）
    final fx = (_emaAlpha * curX) + ((1.0 - _emaAlpha) * st.emaX);
    final fy = (_emaAlpha * curY) + ((1.0 - _emaAlpha) * st.emaY);
    st.emaX = fx;
    st.emaY = fy;

    // END：送 END，清狀態
    if (action == FlutterInputInjection.TOUCH_POINT_END) {
      unawaited(_flutterInputInjectionPlugin.sendNormalizedTouch(
        _screenId,
        autoVirtualDisplay,
        FlutterInputInjection.TOUCH_POINT_END,
        id,
        fx.clamp(0.0, 1.0),
        fy.clamp(0.0, 1.0),
      ));
      _emaById.remove(id);
      return;
    }

    // MOVE：先做距離閾值 +（可選）時間節流
    if (action == FlutterInputInjection.TOUCH_POINT_MOVE) {
      // 如果你 normal state 不會更新 screen size，至少確保這裡拿到合理值
      final screenW = sanitizeDouble(_screenWidth, 0.0);
      final screenH = sanitizeDouble(_screenHeight, 0.0);

      // 用「上次送出的點」計算像素距離
      final dxPx = (fx - st.lastSentX).abs() * screenW;
      final dyPx = (fy - st.lastSentY).abs() * screenH;
      final distPx = sqrt(dxPx * dxPx + dyPx * dyPx);

      // 距離太小：不送（抑制抖動 + 減點）
      if (distPx < _minMovePx) {
        return;
      }

      final sx = fx.clamp(0.0, 1.0);
      final sy = fy.clamp(0.0, 1.0);

      unawaited(_flutterInputInjectionPlugin.sendNormalizedTouch(
        _screenId,
        autoVirtualDisplay,
        FlutterInputInjection.TOUCH_POINT_MOVE,
        id,
        sx,
        sy,
      ));

      // 更新 lastSent
      st.lastSentX = sx;
      st.lastSentY = sy;
      st.lastSentUs = nowUs;

      return;
    }
  }

  void _onAddTrack(MediaStream stream, MediaStreamTrack track) {
    log.info('onAddTrack: ${track.kind}');
  }

  void _onSignalingState(RTCSignalingState state) {
    log.info('onSignalingState: ${state.name}');
  }

  void _onIceGatheringState(RTCIceGatheringState state) {
    log.info('onIceGatheringState: ${state.name}');
  }

  void _onIceConnectionState(RTCIceConnectionState state) {
    log.info('onIceConnectionState: ${state.name}');
  }

  void _onPeerConnectionState(RTCPeerConnectionState state) async {
    log.info('Peer connection state: ${state.name}');
    _peerConnectionState = state;
    trackTrace('pc_state', properties: {
      'target': state.name,
    });
    onConnectionState(state);

    if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
      if (reconnectState == ChannelReconnectState.reconnecting) {
        reconnectState = ChannelReconnectState.success;
      }
      if (!_isRtcFirstConnected) {
        _isRtcFirstConnected = true;
      }

      bool result = await _updateEncodingParameters();
      log.info('updateEncodingParameters result: {$result}');
    } else if (state ==
        RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
      reconnectState = ChannelReconnectState.reconnecting;
    } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
      if (reconnectState == ChannelReconnectState.reconnecting) {
        reconnectState = ChannelReconnectState.fail;
      }
      await hangUp('RTCPeerConnectionStateFailed');
      await onStreamInterrupted?.call();
    }
  }

  void _onIceCandidate(RTCIceCandidate candidate) {
    log.info('onIceCandidate: ${candidate.candidate}');
    var message = PresentSignalMessage(null, SignalMessageType.candidate);
    message.candidate = candidate.candidate;
    message.sdpMid = candidate.sdpMid;
    message.sdpMLineIndex = candidate.sdpMLineIndex;
    sendSignalMessage(message);
  }

  Future<bool> _updateEncodingParameters() async {
    if (_pc == null) {
      return false;
    }
    var senders = await _pc!.getSenders();
    var sender = senders.firstWhereOrNull(
      (sender) => sender.track?.kind == 'video',
    );
    if (sender == null) {
      return false;
    }

    // Note:
    //  Since `degradationPreference` is considered a "feature at risk," we will use
    //  `contentHint` instead of `degradationPreference` to determine the video adaptation strategy.
    //  Currently, we are setting the content hint to "detailed" (see `_applyVideoContentHint`),
    //  which means WebRTC’s internal video adaptation will prioritize maintaining resolution.

    var params = sender.parameters;
    if (params.encodings != null) {
      for (var encoding in params.encodings!) {
        encoding.maxBitrate = _calculateBitrateWithScreenScaling(
          actualWidth: _actualWidth.toDouble(),
          actualHeight: _actualHeight.toDouble(),
          uhdMaxBitrateKbps: preset.parameters.maxBitrateKbps.toInt(),
        );

        // On Android, because ScreenCapture cannot specify the capture frame rate,
        // WebRTC internally controls the frame rate fed to the encoder through the encoding settings.
        // In the future, we could consider applying this approach to other platforms like
        // Windows, macOS, iOS, and Web as well.
        if (!kIsWeb && Platform.isAndroid) {
          encoding.maxFramerate = _idealTrackFrameRate.toInt();
          log.info('Set maxFramerate: ${encoding.maxFramerate}');
        }

        // Note:
        //  We are using `contentHint` to set the minimum bitrate. If the content hint is set to "detail",
        //  WebRTC will use 100 kbps as the minimum bitrate. However, this adjustment may cause the original
        //  profile (video-quality-first/video-smoothness-first) design to become ineffective.
        //
        //  In the future, we plan to use programmatic logic to manage this (e.g., based on AV1 SCC tools).
        //  The previous "high quality" UI/UX will instead set `maxBitrate`.
        //  For details, see https://viewsonic-ssi.visualstudio.com/Display%20App/_workitems/edit/73944/

        // Reference:
        //  https://chromium.googlesource.com/external/webrtc/+/refs/heads/master/pc/sdp_offer_answer.cc#1424
      }
    }
    return await sender.setParameters(params);
  }

  int _getConstraintHeight() {
    return (_decodeHeightLimit > 0 && _decodeHeightLimit < _trackHeight)
        ? _decodeHeightLimit
        : _trackHeight;
  }

  int _calculateBitrateWithScreenScaling({
    required double actualWidth,
    required double actualHeight,
    required int uhdMaxBitrateKbps,
    double baseWidth = 1920,
    double baseHeight = 1080,
  }) {
    final int actualPixels = (actualWidth * actualHeight).toInt();
    const int commonBasePixels = 2073600; // 1920 x 1080
    const int maxPixels = 8294400; // 3840 x 2160
    const int minBitrateBps = 5000000; // 5 Mbps
    const double slope = 3.535; // ≈ 22,000,000 / 6,220,800

    final bool isCommonConfig =
        (uhdMaxBitrateKbps == 27000 && baseWidth == 1920 && baseHeight == 1080);

    // fast path: FHD@5Mbps using slope to determine bitrate (default)
    if (isCommonConfig) {
      if (actualPixels <= commonBasePixels) return minBitrateBps;
      if (actualPixels >= maxPixels) return uhdMaxBitrateKbps * 1000;
      // bitrate = 5_000_000 + (pixels - basePixels) * slope
      return (minBitrateBps + ((actualPixels - commonBasePixels) * slope))
          .round();
    }

    // fallback: baseWidth, baseHeight, and uhdMaxBitrateKbps are not common
    final int basePixels = (baseWidth * baseHeight).toInt();
    const int minBitrateKbps = 5000;
    final int lowBitrateBps = minBitrateKbps * 1000;
    final int highBitrateBps = uhdMaxBitrateKbps * 1000;
    final int pixelRange = maxPixels - basePixels;
    final int pixelDelta = actualPixels - basePixels;

    if (actualPixels <= basePixels) return lowBitrateBps;
    if (actualPixels >= maxPixels) return highBitrateBps;

    final int bitrateDelta = highBitrateBps - lowBitrateBps;
    final int interpolatedBps =
        lowBitrateBps + (bitrateDelta * pixelDelta ~/ pixelRange);
    return interpolatedBps;
  }

  Future<bool> updateEncodingPreset(Preset preset) async {
    this.preset = preset;
    bool result = await _updateEncodingParameters();
    log.info('updateEncodingParameters result: {$result}');
    return result;
  }

  RTCRtpSender? _findSenderByKind(List<RTCRtpSender> senders, String kind) {
    for (final s in senders) {
      if (s.track?.kind == kind) {
        return s;
      }
    }
    return null;
  }

  // apply resolution and fps for desktop platforms
  Future<void> _applyConstraintsForDesktop() async {
    if (_pc == null) {
      return;
    }
    final pc = _pc!;

    final stream = await getDisplayMedia();
    if (stream == null) {
      return;
    }

    final oldStream = _localStream;
    _localStream = stream;

    // Clean up the old stream and tracks
    oldStream?.getTracks().forEach((track) => track.stop());
    await oldStream?.dispose();

    final videoTrack = stream.getVideoTracks().isNotEmpty
        ? stream.getVideoTracks().first
        : null;
    final audioTrack = stream.getAudioTracks().isNotEmpty
        ? stream.getAudioTracks().first
        : null;

    final senders = await pc.getSenders();
    final futures = <Future<void>>[];

    if (videoTrack != null) {
      _applyVideoContentHint(videoTrack);

      final videoSender = _findSenderByKind(senders, 'video');

      if (videoSender != null) {
        futures.add(videoSender.replaceTrack(videoTrack));
      }
    }

    if (audioTrack != null) {
      final audioSender = _findSenderByKind(senders, 'audio');

      if (audioSender != null) {
        futures.add(audioSender.replaceTrack(audioTrack));
      }
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  Future changePresentQuality(ChangePresentQuality msg) async {
    log.info(
        "Received quality change request. resolution: ${msg.constraints?.width} x ${msg.constraints?.height}");

    if (!_streamPublished) {
      _pendingChangePresentQuality = msg;
      return;
    }

    final constraints = msg.constraints;
    if (constraints == null) {
      return;
    }

    if (constraints.height! > _maxTrackHeight) {
      // make sure the width/height is not greater than the max width
      _trackWidth = _maxTrackWidth;
      _trackHeight = _maxTrackHeight;
    } else {
      _trackWidth = constraints.width ??
          _maxTrackWidth ~/ (_maxTrackHeight / constraints.height!);
      _trackHeight = constraints.height!;
    }
    _decodeHeightLimit = constraints.decodeHeightLimit;
    _idealTrackFrameRate = constraints.frameRate!.toDouble();

    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      final videoTrack = _localStream?.getVideoTracks().first;
      if (kIsWeb) {
        // Apply both constraints and minimum frame rate for web platform
        await _applyWebMinFrameRateWorkaround(videoTrack!);
      } else {
        // For Android and iOS, just apply the basic constraints
        final constraints = <String, dynamic>{
          'frameRate': _idealTrackFrameRate,
          'width': _trackWidth,
          'height': _trackHeight,
          'decodeHeightLimit': _decodeHeightLimit,
        };
        log.info("Apply android/ios video constraints: $constraints");
        await videoTrack?.applyConstraints(constraints);
      }
    } else {
      await _applyConstraintsForDesktop();
    }
  }

  //endregion

  //region disconnect
  Future<void> _peerConnectionDisconnect() async {
    if (reconnectState == ChannelReconnectState.reconnecting) {
      reconnectState = ChannelReconnectState.fail;
    }
    try {
      // stop the event log
      await WebRTCLogManager().stopLog(_pc);
      await _pc?.close();
      await _pc?.dispose();
      _pc = null;

      if (!_descriptionSetCompleter.isCompleted) {
        _descriptionSetCompleter.complete();
      }
    } catch (e, stackTrace) {
      log.warning('_peerConnectionDisconnect', e, stackTrace);
    }
  }

  Future<void> hangUp(String reason) async {
    log.info('hangUp reason: $reason');
    _isPaused = false; // Reset pause state
    stopStatsTimer();
    stopAppBundleIdMonitor();
    await AppAmplifyFirehose.instance.flush();

    trackOutboundStats(filterEverySecond(_videoOutboundStatsHistory.elements));
    _trackOutboundPercentiles();

    await WakelockManager().manageWakelock(AppScene.rtcHangUp);

    await audioSwitchManager.restoreToDefaultAudioOutput();

    await _disposeStream();
    await _peerConnectionDisconnect();
    if (WebRTC.platformIsWindows || VersionUtil.isOpenVersion) {
      await FlutterVirtualDisplay.instance.stopVirtualDisplay();
    }
  }

  Future<void> _disposeStream() async {
    try {
      if (_localStream != null) {
        if (kIsWeb) {
          _localStream?.getTracks().forEach((track) => track.stop());
        }
        var stream = _localStream!;
        _localStream = null;
        await stream.dispose();

        for (var element in subscriptions) {
          unawaited(element.cancel());
        }
      }
    } catch (e, stackTrace) {
      log.severe('_disposeStream', e, stackTrace);
    }
    _streamPublished = false;
  }

  void stopStream() {
    if (kIsWeb) return;
    _pc?.getLocalStreams().forEach((element) {
      element?.getTracks().first.enabled = false;
      element?.getTracks().first.stop();
    });
  }

  //endregion

  Future<bool> isAccessibilityServiceAllowed() async {
    return await _flutterInputInjectionPlugin.isAccessibilityServiceEnabled();
  }

  Future<void> openAccessibilitySettings() async {
    await _flutterInputInjectionPlugin.openAccessibilitySettings();
  }

  bool _isTouchBackAllowed() {
    return !kIsWeb &&
        (Platform.isAndroid || _isScreenType) &&
        touchBack &&
        (_localStream != null && _localStream!.getTracks().first.enabled);
  }

  bool _isAudioCaptureAllowed() {
    if (WebRTC.platformIsDesktop) {
      return _isScreenType && systemAudio;
    }
    return true;
  }

  void stopStatsTimer() {
    _statsTimer?.cancel();
    _statsTimer = null;
  }

  void startStatsTimer() {
    _statsTimer?.cancel();

    _rtcStatsParser = RtcStatsParser((width, height) =>
        {log.info('Outbound video size has changed to ${width}x$height')});

    final rtcStatsReporter = RtcStatsReporter(
      (stats) => _handleVideoStatsReport(stats),
    );
    _rtcStatsParser?.addSubscriber(rtcStatsReporter);

    _rtcStatsPresenter = RtcStatsPresenter();
    _rtcStatsParser?.addSubscriber(_rtcStatsPresenter!);
    _rtcMetricsAggregator = RtcMetricsWindowAggregator.outbound();

    _statsTimer = Timer.periodic(
      _statsTimerInterval,
      (timer) async {
        final reports = await _pc?.getStats(null);
        if (reports != null) {
          // feed the stats to the log manager
          WebRTCLogManager().onStatsReport(reports);
          _rtcStatsParser?.onStatsReports(reports);

          // 先把 reports 轉成可上傳的 Map
          _latestReportsPayload = _serializeReports(reports);

          // 每 5 秒上傳一次
          final now = DateTime.now();
          final shouldUpload =
              now.difference(_lastUploadAt) >= const Duration(seconds: 5);

          if (shouldUpload && !_uploading && _latestReportsPayload != null) {
            _uploading = true;
            _lastUploadAt = now; // 先更新避免重入

            try {
              await AppAmplitude().trackEvent('stats', EventCategory.system,
                  properties: _latestReportsPayload!);
            } finally {
              _uploading = false;
            }
          }
        }
      },
    );
  }

  Map<String, dynamic> _serializeReports(List<StatsReport> reports) {
    return {
      "stats": _extractOutboundRtpVideo(reports),
    };
  }

  // Send to Firehose
  Future<void> _sendFirehoseStats(RtcVideoOutboundStats stats) async {
    final record = stats.toFirehoseJson();
    if (record.isEmpty) {
      return;
    }
    final instanceId = AppInstanceCreate().instanceId;
    await AppAmplifyFirehose.instance.enqueueStats(
      streamType: FirehoseStreamType.encoder,
      instanceId: instanceId,
      stats: [record],
    );
  }

  /// 只取 type=outbound-rtp 且 kind=video，並整理成可上傳的 Map
  List<Map<String, dynamic>> _extractOutboundRtpVideo(
      List<StatsReport> reports) {
    return reports
        .where((r) => r.type == 'outbound-rtp' && r.values['kind'] == 'video')
        .map((r) => _simplifyOutboundRtp(r))
        .toList();
  }

  /// 精簡你要的欄位（你可自行增減）
  Map<String, dynamic> _simplifyOutboundRtp(StatsReport r) {
    final v = r.values;
    return {
      "id": r.id,
      "type": r.type,
      "timestamp": r.timestamp,
      "kind": v['kind'],
      "ssrc": v['ssrc'],
      "rid": v['rid'],
      "mid": v['mid'],
      "bytesSent": v['bytesSent'],
      "packetsSent": v['packetsSent'],
      "retransmittedPacketsSent": v['retransmittedPacketsSent'],
      "framesEncoded": v['framesEncoded'],
      "framesPerSecond": v['framesPerSecond'],
      "keyFramesEncoded": v['keyFramesEncoded'],
      "qpSum": v['qpSum'],
      "totalEncodeTime": v['totalEncodeTime'],
      "qualityLimitationReason": v['qualityLimitationReason'],
    };
  }

  void _handleVideoStatsReport(RtcVideoOutboundStats stats) {
    _videoOutboundStatsHistory.add(stats);
    _rtcMetricsAggregator?.add(stats);

    onVideoStatsReport?.call(stats);

    unawaited(_sendFirehoseStats(stats));

    final isWidthChanged =
        stats.frameWidth != null && _actualWidth != stats.frameWidth;
    final isHeightChanged =
        stats.frameHeight != null && _actualHeight != stats.frameHeight;

    if (isWidthChanged || isHeightChanged) {
      _actualWidth = stats.frameWidth!;
      _actualHeight = stats.frameHeight!;
      _updateEncodingParameters();
    }
  }

  void _trackOutboundPercentiles() {
    final aggregator = _rtcMetricsAggregator;
    if (aggregator == null) {
      return;
    }
    final summary = aggregator.buildSummary();
    final flattened = summary.flattenPercentiles();
    if (flattened.isEmpty) {
      return;
    }
    trackTrace('rtc_stats_summary',
        properties: Map<String, Object>.from(flattened));
  }

  Map<String, String> getIceInfo() {
    final result = <String, String>{};

    final candidates = _rtcStatsPresenter?.getCandidates();
    if (candidates != null) {
      final local = (candidates['local'])?.map((e) => e.toJson()).toList();
      final remote = (candidates['remote'])?.map((e) => e.toJson()).toList();

      result['candidates'] = jsonEncode({
        'local': local,
        'remote': remote,
      });
    }

    result['iceServers'] = jsonEncode(
      _iceServerList
          .map((server) => server.urls)
          .expand((urls) => urls)
          .toList(),
    );

    return result;
  }

  void stopAppBundleIdMonitor() {
    _subForegroundApp?.cancel();
    _subForegroundApp = null;
    _subSlideShow?.cancel();
    _subSlideShow = null;
  }

  void startAppBundleIdMonitor() {
    if (!kIsWeb && Platform.isMacOS) {
      _subForegroundApp = _ecForegroundApp
          .receiveBroadcastStream()
          .map((event) => event as String?)
          .listen((bundleId) {
        _flutterInputInjectionPlugin
            .setLongPressDelay(_targetBundleId.contains(bundleId) ? 10 : 80);
      });

      _subSlideShow = _ecSlideShow
          .receiveBroadcastStream()
          .map((event) => event as bool)
          .listen((isInSlideShow) {
        _flutterInputInjectionPlugin.setScrollEnabled(!isInSlideShow);
      });
    }
  }
}
