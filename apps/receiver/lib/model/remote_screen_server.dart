import 'dart:io';

import 'package:device_info_vs/device_info_vs.dart';
import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/model/remote_screen_connector.dart';
import 'package:display_flutter/model/remote_screen_utils.dart';
import 'package:display_flutter/model/touch_event_manager.dart';
import 'package:display_flutter/utility/ion_sfu_util.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:flutter_ion_sfu/flutter_ion_sfu.dart';
import 'package:flutter_ion_sfu/flutter_ion_sfu_listener.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:ion_sdk_flutter/flutter_ion.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:window_size/window_size.dart';
import 'package:display_flutter/protoc/event.pb.dart';
import 'package:display_flutter/protoc/internal.pb.dart';

const defaultScreenWidth = 1920.0;
const defaultScreenHeight = 1080.0;

class RemoteScreenServer extends FlutterIonSfuListener {
  Client? _ionSfuClient;

  final FlutterIonSfu _sfuServer = FlutterIonSfu();
  bool _sfuServerStarted = false;

  String roomId = 'remote-screen';
  int roomPort = 7000;

  final List<RTCDataChannel> _dataChannels = [];

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

  Future startRemoteScreenPublisher() async {
    if (_ionSfuClient != null) {
      return;
    }

    final ionSignal = JsonRPCSignal("ws://127.0.0.1:$roomPort/ws");

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

      log.info("ondatachannel: ${dc.label}");
      _dataChannels.add(dc);

      dc.onDataChannelState = (RTCDataChannelState state) {
        if (state == RTCDataChannelState.RTCDataChannelClosed) {
          _touchEventManager.releaseEventSlotsByDataChannel(dc);
          _dataChannels.removeWhere((item) => item.id == dc.id);
        }
      };
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

    await Helper.requestCapturePermission();
    if (!kIsWeb && Platform.isAndroid) {
      // Android specific
      Future<void> requestBackgroundPermission() async {
        // Required for android screen share.
        try {
          var hasPermissions = await FlutterBackground.hasPermissions;
          const androidConfig = FlutterBackgroundAndroidConfig(
            notificationTitle: 'Screen Sharing',
            notificationText: 'AirSync is sharing the screen.',
            notificationImportance: AndroidNotificationImportance.Default,
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

          if (hasPermissions &&
              !FlutterBackground.isBackgroundExecutionEnabled) {
            await FlutterBackground.enableBackgroundExecution();
          }
        } catch (e, stackTrace) {
          log.severe('requestBackgroundPermission', e, stackTrace);
        }
      }

      await requestBackgroundPermission();
    }

    var localStream =
        await LocalStream.getDisplayMedia(constraints: constraints);
    await _ionSfuClient?.publish(localStream);
  }

  void stopRemoteScreenPublisher() {
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

  void onTouchMessage(RTCDataChannelMessage data, int dcIndex) async {
    EventMessage eventMessage = EventMessage.fromBuffer(data.binary);
    if (eventMessage.hasTouchEvent()) {
      TouchEvent touchEvent = eventMessage.touchEvent;
      _touchEventManager.setScreenSize(_screenWidth, _screenHeight);
      _touchEventManager.handleTouchEvent(touchEvent, dcIndex);
    }
  }

  void enableTouchBySessionId(String sessionID, bool touchEnabled) {
    log.fine('enableTouch: $sessionID $touchEnabled');

    for (int i = 0; i < _dataChannels.length; i++) {
      if (_dataChannels[i].label == sessionID) {
        int dcIndex = _dataChannels[i].id ?? i;
        _dataChannels[i].onMessage = (data) async {
          if (data.isBinary && touchEnabled) {
            onTouchMessage(data, dcIndex);
          } else {
            onTextMessage(data);
          }
        };
        break;
      }
    }
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

  // Send a signal message to the sfu server
  void _sendSignalToSfu(int channelId, String message) {
    final channel = _connectorChannels[channelId];
    if (channel == null) {
      return;
    }

    _sfuServer.processSignalMessage(channelId, message);
  }
}
