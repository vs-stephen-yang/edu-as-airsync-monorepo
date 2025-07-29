import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:display_cast_flutter/features/protoc/event.pb.dart';
import 'package:display_cast_flutter/features/protoc/internal.pb.dart';
import 'package:display_cast_flutter/model/profile.dart';
import 'package:display_cast_flutter/model/rtc_stats.dart';
import 'package:display_cast_flutter/model/rtc_stats_parser.dart';
import 'package:display_cast_flutter/model/rtc_stats_presenter.dart';
import 'package:display_cast_flutter/model/rtc_stats_reporter.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/utilities/app_analytics_outbound.dart';
import 'package:display_cast_flutter/utilities/audio_switch_manager.dart';
import 'package:display_cast_flutter/utilities/bounded_list.dart';
import 'package:display_cast_flutter/utilities/channel_util.dart';
import 'package:display_cast_flutter/utilities/list_util.dart';
import 'package:display_cast_flutter/utilities/log.dart';
import 'package:display_cast_flutter/utilities/sdp_utility.dart';
import 'package:display_cast_flutter/utilities/version_util.dart';
import 'package:display_cast_flutter/utilities/wakelock_manager.dart';
import 'package:display_cast_flutter/utilities/web_browser_detect.dart';
import 'package:display_cast_flutter/utilities/webrtc_log_manager.dart';
import 'package:display_cast_flutter/utilities/webrtc_util.dart';
import 'package:display_channel/display_channel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_input_injection/flutter_input_injection.dart';
import 'package:flutter_input_injection/flutter_input_injection_platform_interface.dart';
import 'package:flutter_virtual_display/flutter_virtual_display.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:window_size/window_size.dart';

class WebRTCConnector {
  WebRTCConnector({
    required this.preset,
    required this.systemAudio,
    required this.autoVirtualDisplay,
    required this.audioSwitchManager,
    required this.sendSignalMessage,
    required this.onConnectionState,
    required this.onStopPresent,
    required this.onTouchEvenWhenPaused,
    required this.reconnectStateNotifier,
  }) {
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

  dynamic _deviceId;
  int _screenId = 0;
  RTCPeerConnection? _pc;
  RTCDataChannel? _touchbackDataChannel;
  RTCDataChannel? _controlDataChannel;

  RTCDataChannelState? _rtcControlDataChannelState;

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

  double _screenWidth = 1920.0;
  double _screenHeight = 1536.0;
  static int _maxTrackWidth = 1920;
  static int _maxTrackHeight = 1536;
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

  // keep last 20 RtcVideoOutboundStats
  final _videoOutboundStatsHistory = BoundedList<RtcVideoOutboundStats>(20);

  List<RtcIceServer> _iceServerList = [];

  ValueNotifier<ChannelReconnectState> reconnectStateNotifier;

  set reconnectState(ChannelReconnectState state) {
    reconnectStateNotifier.value = state;
  }

  ChannelReconnectState get reconnectState => reconnectStateNotifier.value;

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
  void _applyWebMinFrameRateWorkaround(MediaStreamTrack track) {
    int constraintHeight = _getConstraintHeight();
    track.applyConstraints(
      <String, dynamic>{
        'frameRate': {
          'ideal': _idealTrackFrameRate,
          'min': _minTrackFrameRate,
        },
        'width': _trackWidth,
        'height': constraintHeight,
      },
    );
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
      await hangUp();
      // return false to run makeCall's failure process.
      return false;
    }
    _localStream?.getTracks().forEach((element) {
      element.onEnded = () async {
        await hangUp();
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
          _screenWidth = 3840.0;
          _screenHeight = 2160.0;
          _maxTrackWidth = 3840;
          _maxTrackHeight = 2160;
          _applyWebMinFrameRateWorkaround(track);
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

    if (_rtcControlDataChannelState == RTCDataChannelState.RTCDataChannelOpen) {
      _controlDataChannel?.send(RTCDataChannelMessage(text));
    }
  }

  void pause(String sessionId, {Rect? pauseBtnRect, Rect? stopBtnRect}) {
    _isPaused = true; //
    _pauseButtonRect = pauseBtnRect;
    _stopButtonRect = stopBtnRect;
    // Sends a control message to remotely pause rendering.
    _sendControlMessage(
      PausePresentMessage(sessionId),
    );
  }

  void resume(String sessionId) {
    _isPaused = false; // Clear pause state
    _pauseButtonRect = null; // Clear button position info
    _stopButtonRect = null;
    // Sends a control message to remotely resume rendering.
    _sendControlMessage(
      ResumePresentMessage(sessionId),
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

  Future<void> _onTouchMessage(EventMessage eventMessage) async {
    int action = FlutterInputInjection.TOUCH_POINT_START;

    if (eventMessage.touchEvent.eventType ==
        TouchEvent_TouchEventType.TOUCH_POINT_START) {
      action = FlutterInputInjection.TOUCH_POINT_START;
    } else if (eventMessage.touchEvent.eventType ==
        TouchEvent_TouchEventType.TOUCH_POINT_MOVE) {
      action = FlutterInputInjection.TOUCH_POINT_MOVE;
    } else if (eventMessage.touchEvent.eventType ==
        TouchEvent_TouchEventType.TOUCH_POINT_END) {
      action = FlutterInputInjection.TOUCH_POINT_END;
    }
    int id = eventMessage.touchEvent.touchPoints[0].id;
    double remoteX = eventMessage.touchEvent.touchPoints[0].x;
    double remoteY = eventMessage.touchEvent.touchPoints[0].y;
    if (_isPaused) {
      // TODO: following code does not work
      await _updateScreenSize();

      int injectX = (remoteX * _screenWidth).toInt();
      if (injectX < 0) {
        injectX = 0;
      } else if (injectX > _screenWidth.toInt() - 1) {
        injectX = _screenWidth.toInt() - 1;
      }
      int injectY = (remoteY * _screenHeight).toInt();
      if (injectY < 0) {
        injectY = 0;
      } else if (injectY > _screenHeight.toInt() - 1) {
        injectY = _screenHeight.toInt() - 1;
      }

      if (_isPointInPauseButton(
          Offset(injectX.toDouble(), injectY.toDouble()))) {
        onTouchEvenWhenPaused(true, false);
        return;
      }
      if (_isPointInStopButton(
          Offset(injectX.toDouble(), injectY.toDouble()))) {
        onTouchEvenWhenPaused(false, true);
        return;
      }
      log.info('Touch event ignored due to paused state');
      return;
    }
    unawaited(
        _flutterInputInjectionPlugin.sendNormalizedTouch(_screenId, autoVirtualDisplay, action, id, remoteX, remoteY));
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
      await hangUp();
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
    const int commonBasePixels = 2073600;            // 1920 x 1080
    const int maxPixels = 8294400;                   // 3840 x 2160
    const int minBitrateBps = 5000000;               // 5 Mbps
    const double slope = 3.535;                      // ≈ 22,000,000 / 6,220,800

    final bool isCommonConfig = (uhdMaxBitrateKbps == 27000 && baseWidth == 1920 && baseHeight == 1080);

    // fast path: FHD@5Mbps using slope to determine bitrate (default)
    if (isCommonConfig) {
      if (actualPixels <= commonBasePixels) return minBitrateBps;
      if (actualPixels >= maxPixels) return uhdMaxBitrateKbps * 1000;
      // bitrate = 5_000_000 + (pixels - basePixels) * slope
      return (minBitrateBps + ((actualPixels - commonBasePixels) * slope)).round();
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
    final int interpolatedBps = lowBitrateBps + (bitrateDelta * pixelDelta ~/ pixelRange);
    return interpolatedBps;
  }

  Future<bool> updateEncodingPreset(Preset preset) async {
    this.preset = preset;
    bool result = await _updateEncodingParameters();
    log.info('updateEncodingParameters result: {$result}');
    return result;
  }

  Future changePresentQuality(ChangePresentQuality msg) async {
    log.info(
        "Received quality change request. height:${msg.constraints?.height}");

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
      _trackWidth = _maxTrackWidth ~/ (_maxTrackHeight / constraints.height!);
      _trackHeight = constraints.height!;
    }
    _decodeHeightLimit = constraints.decodeHeightLimit;
    _idealTrackFrameRate = constraints.frameRate!.toDouble();

    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      final videoTrack = _localStream?.getVideoTracks().first;
      if (kIsWeb) {
        // Apply both constraints and minimum frame rate for web platform
        _applyWebMinFrameRateWorkaround(videoTrack!);
      } else {
        // For Android and iOS, just apply the basic constraints
        final constraints = <String, dynamic>{
          'frameRate': _idealTrackFrameRate,
          'width': _trackWidth,
          'height': _trackHeight,
          'decodeHeightLimit': _decodeHeightLimit,
        };
        log.info(
            "Apply video constraints. width:$_trackWidth height:$_trackHeight");
        await videoTrack?.applyConstraints(constraints);
      }
    } else {
      _localStream = await getDisplayMedia();

      for (MediaStreamTrack track in _localStream!.getTracks()) {
        if (track.kind == 'video') {
          _applyVideoContentHint(track);
        }
        unawaited(_pc?.getSenders().then((value) async {
          await value.first.replaceTrack(track);
        }));
      }
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

  Future<void> hangUp() async {
    _isPaused = false; // Reset pause state
    stopStatsTimer();

    trackOutboundStats(filterEverySecond(_videoOutboundStatsHistory.elements));

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

    _rtcStatsParser = RtcStatsParser(
        (width, height) =>
            {log.info('Outbound video size has changed to ${width}x$height')});

    final rtcStatsReporter = RtcStatsReporter((stats) => _handleVideoStatsReport(stats));
    _rtcStatsParser?.addSubscriber(rtcStatsReporter);

    _rtcStatsPresenter = RtcStatsPresenter();
    _rtcStatsParser?.addSubscriber(_rtcStatsPresenter!);

    _statsTimer = Timer.periodic(
      _statsTimerInterval,
      (timer) async {
        final reports = await _pc?.getStats(null);
        if (reports != null) {
          // feed the stats to the log manager
          WebRTCLogManager().onStatsReport(reports);
          _rtcStatsParser?.onStatsReports(reports);
        }
      },
    );
  }

  void _handleVideoStatsReport(RtcVideoOutboundStats stats) {
    _videoOutboundStatsHistory.add(stats);

    onVideoStatsReport?.call(stats);

    final isWidthChanged = stats.frameWidth != null && _actualWidth != stats.frameWidth;
    final isHeightChanged = stats.frameHeight != null && _actualHeight != stats.frameHeight;

    if (isWidthChanged || isHeightChanged) {
      _actualWidth = stats.frameWidth!;
      _actualHeight = stats.frameHeight!;
      _updateEncodingParameters();
    }
  }

  Map<String, String> getIceInfo() {
    final result = <String, String>{};

    final candidates = _rtcStatsPresenter?.getCandidates();
    if (candidates != null) {
      final local = (candidates['local'])?.map((e) => e.toJson())
          .toList();
      final remote = (candidates['remote'])?.map((e) => e.toJson())
          .toList();

      result['candidates'] = jsonEncode({
        'local': local,
        'remote': remote,
      });
    }

    result['iceServers'] = jsonEncode(
        _iceServerList.map((server) => server.urls).expand((urls) => urls).toList(),
    );

    return result;
  }
}