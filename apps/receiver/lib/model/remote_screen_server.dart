import 'dart:io';

import 'package:device_info_vs/device_info_vs.dart';
import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/model/remote_screen_connector.dart';
import 'package:display_flutter/model/remote_screen_utils.dart';
import 'package:display_flutter/model/touch_event_manager.dart';
import 'package:display_flutter/protoc/event.pb.dart';
import 'package:display_flutter/protoc/internal.pb.dart';
import 'package:display_flutter/utility/ion_sfu_util.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_ion_sfu/flutter_ion_sfu.dart';
import 'package:flutter_ion_sfu/flutter_ion_sfu_listener.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:ion_sdk_flutter/flutter_ion.dart';
import 'package:uuid/uuid.dart';
import 'package:window_size/window_size.dart';

const defaultScreenWidth = 1920.0;
const defaultScreenHeight = 1080.0;
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

  final FlutterIonSfu _sfuServer = FlutterIonSfu();
  bool _sfuServerStarted = false;

  int roomPort = 7000;

  // roomId will be updated when starting the publisher
  String roomId = "default-room-id";

  final _channels = <String, RemoteControlChannel>{};
  int _nextChannelId = 0;

  double _screenWidth = defaultScreenWidth;
  double _screenHeight = defaultScreenHeight;
  final _touchEventManager = TouchEventManager();

  final _connectorChannels = <int, RemoteScreenConnector>{};

  RemoteScreenServer();

  Future startSfuServer(List<RtcIceServer>? iceServers) async {
    if (_sfuServerStarted) return;

    final configuration = createIonSfuConfiguration(iceServers);

    _sfuServer.registerListener(this);

    await _sfuServer.initialize();
    await _sfuServer.start(configuration);

    _sfuServerStarted = true;
  }

  void _onControlChannelClosed(RemoteControlChannel channel) {
    _touchEventManager.releaseEventSlotsByChannelId(channel.id);
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
    if (_ionSfuClient != null) {
      return true;
    }

    final ionSignal = JsonRPCSignal("ws://127.0.0.1:$roomPort/ws");

    roomId = _generateRoomId();
    log.info('Start remote screen publisher for room $roomId');

    final uuid = const Uuid().v4();
    _ionSfuClient = await Client.create(
      sid: roomId,
      uid: uuid,
      signal: ionSignal,
    );

    _ionSfuClient!.ondatachannel = (RTCDataChannel dc) {
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

    await updateScreenSize();
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

    var localStream =
        await LocalStream.getDisplayMedia(constraints: constraints);
    await _ionSfuClient?.publish(localStream);
    return true;
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

  void stopRemoteScreenPublisher() {
    log.info('Stop remote screen publisher for room $roomId');
    _ionSfuClient?.close();
    _ionSfuClient = null;
  }

  void addConnector(RemoteScreenConnector connector) async {
    // Check if the connector already exists in the map.
    if (_connectorChannels.containsValue(connector)) {
      log.warning('Channel already exists for connector');
      return;
    }
    final channelId = await _sfuServer.createSignalChannel();

    _connectorChannels[channelId] = connector;

    connector.registerSignalHandler((String message) {
      _sendSignalToSfu(channelId, message);
    });
  }

  void removeConnector(RemoteScreenConnector connector) async {
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
    }
  }

  Future<void> updateScreenSize() async {
    if (Platform.isWindows) {
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
      _screenWidth = PlatformDispatcher.instance.displays.first.size.width;
      _screenHeight = PlatformDispatcher.instance.displays.first.size.height;
    }
  }

  void onTextMessage(RTCDataChannelMessage data) async {
    log.fine('Received message: ${data.text}');
  }

  void _onControlMessage(RTCDataChannelMessage data, int channelId) async {
    EventMessage eventMessage = EventMessage.fromBuffer(data.binary);

    if (eventMessage.hasTouchEvent()) {
      TouchEvent touchEvent = eventMessage.touchEvent;
      _touchEventManager.setScreenSize(_screenWidth, _screenHeight);
      _touchEventManager.handleTouchEvent(touchEvent, channelId);
    }

    if (eventMessage.hasKeyEvent()) {
      KeyEvent event = eventMessage.keyEvent;

      _touchEventManager.handleKeyEvent(event, channelId);
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

    _sfuServer.processSignalMessage(channelId, message);
  }
}
