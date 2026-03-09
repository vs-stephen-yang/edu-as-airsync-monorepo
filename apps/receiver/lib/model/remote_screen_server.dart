import 'dart:async';
import 'dart:io';

import 'package:device_info_vs/device_info_vs.dart';
import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/model/remote_screen_connector.dart';
import 'package:display_flutter/model/remote_screen_utils.dart';
import 'package:display_flutter/model/rtc_stats.dart';
import 'package:display_flutter/model/rtc_stats_parser.dart';
import 'package:display_flutter/model/rtc_stats_reporter.dart';
import 'package:display_flutter/model/touch_event_manager.dart';
import 'package:display_flutter/model/zero_fps_detector.dart';
import 'package:display_flutter/protoc/internal.pb.dart';
import 'package:display_flutter/utility/bounded_list.dart';
import 'package:display_flutter/utility/cast_to_boards_session_logger.dart';
import 'package:display_flutter/utility/ion_sfu_util.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_golang_server/flutter_ion_sfu.dart';
import 'package:flutter_golang_server/flutter_ion_sfu_listener.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:ion_sdk_flutter/flutter_ion.dart';
import 'package:synchronized/synchronized.dart';
import 'package:uuid/uuid.dart';

const int roomIdLength = 8;

class RemoteControlChannel {
  final RTCDataChannel _channel;
  bool _isControlAllowed = false;
  final int _id;

  int get id {
    return _id;
  }

  RemoteControlChannel(
    this._id,
    this._channel,
    Function(RemoteControlChannel) onClosed,
    Function(RTCDataChannelMessage, int id) onMessage,
  ) {
    assert(_channel.label != null);

    _channel.onDataChannelState = (RTCDataChannelState state) {
      if (state == RTCDataChannelState.RTCDataChannelClosed) {
        // channel is closed
        onClosed(this);
      }
    };

    _channel.onMessage = (RTCDataChannelMessage data) async {
      if (!data.isBinary) {
        // ignore text data
        return;
      }
      if (!_isControlAllowed) {
        return;
      }
      onMessage(data, _id);
    };
  }

  void setControlAllowed(bool isAllowed) {
    _isControlAllowed = isAllowed;
  }
}

class RemoteScreenServer extends FlutterIonSfuListener {
  SfuPublisher? _sfuPublisher;
  final _lock = Lock();
  ZeroFpsDetector? _zeroFpsDetector;

  final FlutterIonSfu _sfuServer = FlutterIonSfu();
  bool _sfuServerStarted = false;

  int roomPort = 7000;
  JsonRPCSignal? _ionSignal;

  // roomId will be updated when starting the publisher
  String roomId = "default-room-id";

  bool get supportTouchEvent => _supportTouchEvent;
  bool _supportTouchEvent = false;
  TouchEventManager? _touchEventManager;

  final _connectorChannels = <int, RtcScreenConnector>{};

  // UI callback（需要從外部設定）
  final RemoteScreenServerDelegate? callback;

  RemoteScreenServer(this.callback) {
    initTouchEventManager();
  }

  Future<void> initTouchEventManager() async {
    var channel = const MethodChannel('com.mvbcast.crosswalk/wifi_helper');
    String flavor = await channel.invokeMethod("getFlavor") ?? '';
    if (flavor == 'ifp' || flavor == 'edla') {
      _touchEventManager = TouchEventManager();
      _supportTouchEvent = true;
    }
  }

  Future startSfuServer(List<RtcIceServer>? iceServers) async {
    if (_sfuServerStarted) return;

    final configuration = createIonSfuConfiguration(iceServers);

    _sfuServer.registerListener(this);

    await _sfuServer.initialize();
    await _sfuServer.start(configuration);

    _sfuServerStarted = true;
  }

  static String _generateRoomId() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    var rand = const Uuid().v4();
    return String.fromCharCodes(Iterable.generate(
      roomIdLength,
      (_) => chars.codeUnitAt(
        rand.codeUnitAt(_ % rand.length) % chars.length,
      ),
    ));
  }

  Future<bool> startRemoteScreenPublisher() async {
    return _lock.synchronized(() async {
      if (_sfuPublisher != null && _sfuPublisher!.isStarted()) {
        log.info('RemoteScreenServer: Publisher already started');
        return true;
      }

      castToBoardsSessionLogger.start('host');
      _ionSignal = JsonRPCSignal("ws://127.0.0.1:$roomPort/ws");
      roomId = _generateRoomId();
      log.info('RemoteScreenServer: Starting publisher for room $roomId');

      _zeroFpsDetector = ZeroFpsDetector(
        onZeroFpsNotify: _handleShowZeroFpsUiPrompt,
        onAutoRecreate: _recreateSfuPublisher,
        onRecreateSuccess: _handleRecreateSuccess,
        onRecreateFailure: _handleRecreateFailure,
        maxAutoRecreateAttempts: 3,
        zeroFpsDetectLength: 2,
      );

      // Create and start publisher
      _sfuPublisher = await SfuPublisher.create(
        _ionSignal!,
        roomId,
        _touchEventManager,
        (fps) => _zeroFpsDetector?.onFpsStatsReceived(fps),
      );

      bool success = await _sfuPublisher!.start();
      if (!success) {
        log.warning('RemoteScreenServer: Failed to start publisher');
        await _sfuPublisher!.stop();
        _sfuPublisher = null;
        _zeroFpsDetector?.dispose();
        _zeroFpsDetector = null;
        return false;
      }

      return true;
    });
  }

  Future<void> stopRemoteScreenPublisher() async {
    await _lock.synchronized(() async {
      if (_sfuPublisher != null) {
        log.info('RemoteScreenServer: Stopping publisher for room $roomId');
        await _sfuPublisher!.stop();
        _sfuPublisher = null;
      }
      _zeroFpsDetector?.dispose();
      _zeroFpsDetector = null;
      castToBoardsSessionLogger.stop();
    });
  }

  bool isRemoteScreenPublisherStarted() {
    return _sfuPublisher != null && _sfuPublisher!.isStarted();
  }

  void enableRemoteControlBySessionId(String sessionId, bool enable) {
    _sfuPublisher?.enableRemoteControlBySessionId(sessionId, enable);
  }

  Future<bool> _recreateSfuPublisher() async {
    return await _lock.synchronized(() async {
      if (_zeroFpsDetector == null) {
        log.info('RemoteScreenServer: Shutting down, skip recreate');
        return false;
      }

      log.info('RemoteScreenServer: Recreating entire SfuPublisher');

      if (_sfuPublisher != null) {
        await _sfuPublisher!.stop();
      }

      _sfuPublisher = await SfuPublisher.create(
        _ionSignal!,
        roomId,
        _touchEventManager,
        (fps) => _zeroFpsDetector?.onFpsStatsReceived(fps),
      );

      bool success = await _sfuPublisher!.start();

      if (!success) {
        log.severe('RemoteScreenServer: Failed to recreate publisher');
        await _sfuPublisher!.stop();
        _sfuPublisher = null;
      } else {
        log.info('RemoteScreenServer: SfuPublisher recreated successfully');
      }

      return success;
    });
  }

  void _handleShowZeroFpsUiPrompt() {
    log.info('RemoteScreenServer: Notifying UI to show zero FPS prompt');
    callback?.onShowZeroFpsPrompt.call();
  }

  void _handleRecreateSuccess() {
    log.info('RemoteScreenServer: Notifying UI that recreate succeeded');
    callback?.onRecreatePublisherSuccess.call();
  }

  void _handleRecreateFailure() {
    log.info('RemoteScreenServer: Notifying UI that recreate failed, shutting down server');
    unawaited(castToBoardsSessionLogger.upload('Host recreate failed after max attempts'));
    callback?.onRecreatePublisherFailure.call();
    unawaited(stopRemoteScreenPublisher());
  }

  void userConfirmRecreate() async {
    _zeroFpsDetector?.onUserConfirmRecreate();
  }

  void addConnector(RtcScreenConnector connector) async {
    // Check if the connector already exists in the map.
    if (_connectorChannels.containsValue(connector)) {
      log.warning('RemoteScreenServer: Channel already exists for connector');
      return;
    }
    try {
      final channelId = await _sfuServer.createSignalChannel();

      _connectorChannels[channelId] = connector;

      connector.registerSignalHandler((String message) {
        _sendSignalToSfu(channelId, message);
      });

      _sfuPublisher?.logOutboundStats();
    } catch (e) {
      log.warning(e);
    }
  }

  void removeConnector(RtcScreenConnector connector) async {
    connector.registerSignalHandler(null);

    try {
      final entry = _connectorChannels.entries.firstWhere(
        (entry) => entry.value == connector,
      );
      final channelId = entry.key;

      await _sfuServer.closeSignalChannel(channelId);

      _connectorChannels.remove(channelId);
    } on StateError {
      log.warning('RemoteScreenServer: No channel is found for connector');
    } catch (e) {
      log.warning(e);
    }
  }

  void onTextMessage(RTCDataChannelMessage data) async {
    log.fine('Received message: ${data.text}');
  }

  // onError callback from FlutterIonSfu
  @override
  void onError(String error, String msg) {}

  @override
  void onSignalMessage(int channelId, String message) {
    // Received a signal message from sfu server
    final connector = _connectorChannels[channelId];

    if (connector == null) {
      return;
    }

    // forward the signal message to the peer
    connector.sendSignalToPeer(message);
  }

  @override
  void onIceConnectionState(int channelId, IceConnectionState state) {
    _connectorChannels[channelId]?.onRtcConnectionState(state);
  }

  // Send a signal message to the sfu server
  void _sendSignalToSfu(int channelId, String message) {
    final channel = _connectorChannels[channelId];
    if (channel == null) {
      return;
    }

    try {
      _sfuServer.processSignalMessage(channelId, message);
    } catch (e) {
      log.warning(e);
    }
  }
}

class SfuPublisher {
  Client? _ionSfuClient;
  LocalStream? _localStream;
  final TouchEventManager? _touchEventManager;

  final JsonRPCSignal _ionSignal;
  final String _roomId;
  final _lock = Lock();

  final _channels = <String, RemoteControlChannel>{};
  int _nextChannelId = 0;

  double _screenWidth = defaultScreenWidth;
  double _screenHeight = defaultScreenHeight;

  RtcStatsParser? _rtcStatsParser;

  Timer? _statsTimer;
  final _statsTimerInterval = const Duration(seconds: 1);

  final _videoOutboundStatsHistory = BoundedList<RtcVideoOutboundStats>(5);
  final Function(int) _onFpsStatsReceived;

  SfuPublisher._(
    this._ionSignal,
    this._roomId,
    this._touchEventManager,
    this._onFpsStatsReceived,
  );

  static Future<SfuPublisher> create(
    JsonRPCSignal ionSignal,
    String roomId,
    TouchEventManager? touchEventManager,
    Function(int) onFpsStatsReceived,
  ) async {
    final publisher = SfuPublisher._(
      ionSignal,
      roomId,
      touchEventManager,
      onFpsStatsReceived,
    );

    return publisher;
  }

  Future<bool> start() async {
    return _lock.synchronized(() async {
      if (_ionSfuClient != null) {
        log.warning('SfuPublisher: Already started');
        return true;
      }

      log.info('SfuPublisher: Starting for room $_roomId');

      // Create ion sfu client
      _ionSfuClient = await _createIonSfuClient();

      // Get constraints
      Constraints constraints = await _getConstraints();

      // Request permissions
      bool capturePermission = await Helper.requestCapturePermission();
      if (!capturePermission) {
        log.warning('Capture permission denied');
        return false;
      }

      bool backgroundPermission = await _requestBackgroundPermission();
      if (!backgroundPermission) {
        log.warning('Background permission denied');
        return false;
      }

      // Create local stream
      _localStream =
          await LocalStream.getDisplayMedia(constraints: constraints);
      final videoTracks = _localStream!.stream.getVideoTracks();
      log.info('SfuPublisher: Local stream acquired, videoTracks=${videoTracks.length}');
      if (videoTracks.isEmpty) {
        log.warning('SfuPublisher: No video tracks in local stream, publish will have no video');
      }

      // Publish stream
      await _ionSfuClient?.publish(_localStream!);
      log.info('SfuPublisher: Stream published to SFU');

      // Start stats monitoring
      _startStatsTimer();

      log.info('SfuPublisher: Started successfully');
      return true;
    });
  }

  // Recreate only the client, reuse existing stream
  Future<void> recreateClient() async {
    await _lock.synchronized(() async {
      if (_ionSfuClient == null) {
        log.warning('SfuPublisher: No client to recreate');
        return;
      }

      log.info('SfuPublisher: Recreating ionSfuClient');

      final newClient = await _createIonSfuClient();

      if (_localStream != null) {
        await newClient.publish(_localStream!);
        // ensure an uninterrupted transition between the old and new client
        final oldClient = _ionSfuClient;
        _ionSfuClient = newClient;
        oldClient?.close();

        log.info('SfuPublisher: ionSfuClient recreated successfully');
      } else {
        log.warning('SfuPublisher: No local stream available, closing new client');
        newClient.close();
      }
    });
  }

  Future<Client> _createIonSfuClient() async {
    final uuid = const Uuid().v4();
    log.info('SfuPublisher: Creating ionSfuClient, uuid=$uuid');
    final client = await Client.create(
      sid: _roomId,
      uid: uuid,
      signal: _ionSignal,
    );

    client.ondatachannel = (RTCDataChannel dc) {
      if (dc.label == API_CHANNEL) {
        return;
      }
      log.info('SfuPublisher: New data channel: ${dc.label} ${dc.id}');

      if (dc.label == null) {
        log.warning('SfuPublisher: Data channel has no label');
        return;
      }

      _channels[dc.label!] = _createRemoteControlChannel(dc);
    };

    client.onConnectionState = (RTCPeerConnectionState state) async {
      log.info('SfuPublisher: ionSfuClient $uuid Connection state: ${state.name}');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        await recreateClient();
      }
    };

    return client;
  }

  RemoteControlChannel _createRemoteControlChannel(RTCDataChannel dataChannel) {
    _nextChannelId += 1;

    return RemoteControlChannel(
      _nextChannelId,
      dataChannel,
      _onControlChannelClosed,
      _onControlMessage,
    );
  }

  void _onControlChannelClosed(RemoteControlChannel channel) {
    _touchEventManager?.releaseEventSlotsByChannelId(channel.id);
    _channels.removeWhere((key, item) => item.id == channel.id);
  }

  void _onControlMessage(RTCDataChannelMessage data, int channelId) async {
    EventMessage eventMessage = EventMessage.fromBuffer(data.binary);

    if (eventMessage.hasTouchEvent()) {
      _touchEventManager?.setScreenSize(_screenWidth, _screenHeight);
      _touchEventManager?.handleTouchEvent(eventMessage.touchEvent, channelId);
    }

    if (eventMessage.hasKeyEvent()) {
      _touchEventManager?.handleKeyEvent(eventMessage.keyEvent, channelId);
    }
  }

  Future<Constraints> _getConstraints() async {
    final (width, height) = await getScreenSize();
    _screenWidth = width;
    _screenHeight = height;

    String? deviceType = await DeviceInfoVs.deviceType;

    final captureResolution = getCaptureVideoResolution(
      deviceType,
      _screenWidth,
      _screenHeight,
    );
    log.info(
        'SfuPublisher: Set capture resolution ${captureResolution.name} for ${_screenWidth}x$_screenHeight $deviceType');

    var constraints = Constraints.defaults;
    // Note: ion-sdk-flutter currently hard-code H264, so the settings here
    // are ineffective.
    constraints.codec = "h264";
    constraints.simulcast = false;
    constraints.audio = false;
    constraints.resolution = captureResolution.name;
    return constraints;
  }

  Future<bool> _requestBackgroundPermission() async {
    if (Platform.isAndroid) {
      try {
        var hasPermissions = await FlutterBackground.hasPermissions;
        const androidConfig = FlutterBackgroundAndroidConfig(
          notificationTitle: 'Screen Sharing',
          notificationText: 'AirSync is sharing the screen.',
          notificationImportance: AndroidNotificationImportance.normal,
          notificationIcon: AndroidResource(
            name: 'ic_launcher',
            defType: 'mipmap',
          ),
          // Above Android 12 will has some issue if set below option true.
          shouldRequestBatteryOptimizationsOff: false,
        );

        hasPermissions = await FlutterBackground.initialize(
          androidConfig: androidConfig,
        );
        if (hasPermissions && !FlutterBackground.isBackgroundExecutionEnabled) {
          bool result = await FlutterBackground.enableBackgroundExecution();
          return result;
        }
        return hasPermissions;
      } catch (e, stackTrace) {
        log.severe('requestBackgroundPermission', e, stackTrace);
      }
    }
    return false;
  }

  void _startStatsTimer() {
    _rtcStatsParser = RtcStatsParser();
    final rtcStatsReporter = RtcStatsReporter(
      (RtcVideoInboundStats stats) {},
      _handleVideoStatsReport,
      (String localCandidateType, String remoteCandidateType) {},
      (RtcIceCandidatePairStats stats) {},
    );
    _rtcStatsParser!.addSubscriber(rtcStatsReporter);

    _statsTimer?.cancel();
    _statsTimer = Timer.periodic(
      _statsTimerInterval,
      (timer) async {
        final reports = await _ionSfuClient?.getPubStats(null);
        if (reports != null) {
          _rtcStatsParser?.onStatsReports(reports);
        }
      },
    );
  }

  void _stopStatsTimer() {
    _statsTimer?.cancel();
    _statsTimer = null;
  }

  void _handleVideoStatsReport(RtcVideoOutboundStats stats) {
    _videoOutboundStatsHistory.add(stats);
    final fps = stats.framesSentPerSecond ?? 0;
    _onFpsStatsReceived(fps);
    log.info('SfuPublisher: Stats - '
        'FPS=${stats.framesSentPerSecond}, '
        'bitrate=${stats.bytesSentPerSecond}, '
        'available=${stats.availableOutgoingBitrate?.toStringAsFixed(0)}, '
        'limit=${stats.qualityLimitationReason}, '
        'encodeTime=${stats.encodeTimeAvgMs?.toStringAsFixed(1)}ms, '
        'retransmit/s=${stats.retransmittedPacketsSentPerSecond?.toStringAsFixed(1)}');
  }

  List<RtcVideoOutboundStats> getVideoOutboundStatsHistory() {
    return _videoOutboundStatsHistory.elements;
  }

  bool isStarted() {
    return _ionSfuClient != null;
  }

  Future<void> stop() async {
    await _lock.synchronized(() async {
      log.info('Stopping SfuPublisher');

      if (FlutterBackground.isBackgroundExecutionEnabled) {
        await FlutterBackground.disableBackgroundExecution();
      }

      _stopStatsTimer();

      _localStream?.stop();
      _localStream = null;

      _ionSfuClient?.close();
      _ionSfuClient = null;

      _channels.clear();

      log.info('SfuPublisher stopped');
    });
  }

  void enableRemoteControlBySessionId(String sessionId, bool enable) {
    log.info('SfuPublisher: Enable remote control for $sessionId $enable');

    final channel = _channels[sessionId];
    if (channel == null) {
      return;
    }
    channel.setControlAllowed(enable);
  }

  void logOutboundStats() {
    final remoteScreenStats =
        formatVideoOutboundStatsList(_videoOutboundStatsHistory.elements);
    final chunkLogger = ChunkedLogger(log);
    chunkLogger.info('Remote Screen Stats: $remoteScreenStats');
    // TODO: upload remoteScreenStats to appInsight
  }
}

abstract class RemoteScreenServerDelegate {
  void onShowZeroFpsPrompt();

  void onRecreatePublisherSuccess();

  void onRecreatePublisherFailure();
}
