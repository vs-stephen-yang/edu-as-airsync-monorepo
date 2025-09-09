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
import 'package:display_flutter/protoc/internal.pb.dart';
import 'package:display_flutter/utility/bounded_list.dart';
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
  Client? _ionSfuClient;
  LocalStream? _localStream;
  final _lock = Lock();

  final FlutterIonSfu _sfuServer = FlutterIonSfu();
  bool _sfuServerStarted = false;

  int roomPort = 7000;
  JsonRPCSignal? _ionSignal;

  // roomId will be updated when starting the publisher
  String roomId = "default-room-id";

  final _channels = <String, RemoteControlChannel>{};
  int _nextChannelId = 0;

  bool get supportTouchEvent => _supportTouchEvent;
  bool _supportTouchEvent = false;
  double _screenWidth = defaultScreenWidth;
  double _screenHeight = defaultScreenHeight;
  TouchEventManager? _touchEventManager;

  final _connectorChannels = <int, RtcScreenConnector>{};

  RtcStatsParser? _rtcStatsParser;

  Timer? _statsTimer;
  final _statsTimerInterval = const Duration(seconds: 1);

  final _videoOutboundStatsHistory = BoundedList<RtcVideoOutboundStats>(5);

  RemoteScreenServer() {
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

  void _onControlChannelClosed(RemoteControlChannel channel) {
    _touchEventManager?.releaseEventSlotsByChannelId(channel.id);
    _channels.removeWhere((key, item) => item.id == channel.id);
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
      if (_ionSfuClient != null) {
        return true;
      }

      _ionSignal = JsonRPCSignal("ws://127.0.0.1:$roomPort/ws");
      roomId = _generateRoomId();
      log.info('Start remote screen publisher for room $roomId');

      _ionSfuClient = await _createIonSfuClient();

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
          'Set capture resolution ${captureResolution.name} for ${_screenWidth}x$_screenHeight $deviceType');

      var constraints = Constraints.defaults;
      // Note: ion-sdk-flutter currently hard-code H264, so the settings here
      // are ineffective.
      constraints.codec = "h264";
      constraints.simulcast = false;
      constraints.audio = false;
      constraints.resolution = captureResolution.name;

      bool capturePermission = await Helper.requestCapturePermission();
      if (!capturePermission) {
        return false;
      }
      bool backgroundPermission = await requestBackgroundPermission();
      if (!backgroundPermission) {
        return false;
      }

      _localStream =
          await LocalStream.getDisplayMedia(constraints: constraints);
      await _ionSfuClient?.publish(_localStream!);
      _startStatsTimer();
      return true;
    });
  }

  Future<Client?> _createIonSfuClient() async {
    if (_ionSignal == null) {
      return null;
    }

    final uuid = const Uuid().v4();
    log.info('create ionSfuClient, uuid: $uuid');
    final client = await Client.create(
      sid: roomId,
      uid: uuid,
      signal: _ionSignal!,
    );

    client.ondatachannel = (RTCDataChannel dc) {
      if (dc.label == API_CHANNEL) {
        return;
      }
      log.info("New data channel: ${dc.label} ${dc.id}");

      if (dc.label == null) {
        log.warning('Data channel has no label');
        return;
      }

      _channels[dc.label!] = _createRemoteControlChannel(dc);
    };

    client.onConnectionState = (RTCPeerConnectionState state) async {
      log.info('ionSfuClient $uuid Connection state: ${state.name}');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        await recreateIonSfuClient();
      }
    };

    return client;
  }

  Future<void> recreateIonSfuClient() async {
    await _lock.synchronized(() async {
      if (_ionSfuClient == null) {
        return;
      }

      log.info('ionSfuClient recreate');
      final client = await _createIonSfuClient();
      if (client == null) {
        return;
      }

      if (_localStream != null) {
        await client.publish(_localStream!);
        // ensure an uninterrupted transition between the old and new client
        final oldClient = _ionSfuClient;
        _ionSfuClient = client;
        oldClient?.close();
      } else {
        client.close();
      }
    });
  }

  Future<bool> requestBackgroundPermission() async {
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

  bool isRemoteScreenPublisherStarted() {
    return _ionSfuClient != null;
  }

  Future<void> stopRemoteScreenPublisher() async {
    await _lock.synchronized(() async {
      if (FlutterBackground.isBackgroundExecutionEnabled) {
        await FlutterBackground.disableBackgroundExecution();
      }
      if (_ionSfuClient != null) {
        log.info('Stop remote screen publisher for room $roomId');
        final client = _ionSfuClient;
        _ionSfuClient = null;
        client?.close();
      }
      if (_statsTimer != null) {
        _stopStatsTimer();
      }
    });
  }

  void addConnector(RtcScreenConnector connector) async {
    // Check if the connector already exists in the map.
    if (_connectorChannels.containsValue(connector)) {
      log.warning('Channel already exists for connector');
      return;
    }
    try {
      final channelId = await _sfuServer.createSignalChannel();

      _connectorChannels[channelId] = connector;

      connector.registerSignalHandler((String message) {
        _sendSignalToSfu(channelId, message);
      });

      final remoteScreenStats =
          formatVideoOutboundStatsList(_videoOutboundStatsHistory.elements);
      final chunkLogger = ChunkedLogger(log);
      chunkLogger.info('Remote Screen Stats: $remoteScreenStats');
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
      log.warning('No channel is found for connector');
    } catch (e) {
      log.warning(e);
    }
  }

  void onTextMessage(RTCDataChannelMessage data) async {
    log.fine('Received message: ${data.text}');
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

  void enableRemoteControlBySessionId(String sessionId, bool enable) {
    log.info('Enable remote control for $sessionId $enable');

    final channel = _channels[sessionId];
    if (channel == null) {
      return;
    }
    channel.setControlAllowed(enable);
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
