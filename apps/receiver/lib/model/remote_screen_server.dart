import 'dart:io';
import 'dart:developer';

import 'package:device_info_vs/device_info_vs.dart';
import 'package:display_flutter/model/remote_screen_utils.dart';
import 'package:flutter_input_injection/flutter_input_injection.dart';
import 'package:flutter_ion_sfu/flutter_ion_sfu.dart';
import 'package:flutter_ion_sfu/flutter_ion_sfu_configuration.dart';
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
const maxEventId = 255;

class EventSlot {
  int channelId = -1;
  int eventId = -1;
}

class RemoteScreenServer {
  Client? _ionSfuClient;
  final FlutterIonSfu _ionSfuServer = FlutterIonSfu();
  bool _iosSfuServerStart = false;
  String roomId = 'remote-screen';
  int roomPort = 7000;
  final List<RTCDataChannel> _dataChannels = [];
  double _screenWidth = defaultScreenWidth;
  double _screenHeight = defaultScreenHeight;
  final List<EventSlot> _eventSlots =
      List.generate(maxEventId, (index) => EventSlot());
  final _flutterInputInjectionPlugin = FlutterInputInjection();

  RemoteScreenServer();

  Future startSfuServer() async {
    if (_iosSfuServerStart) return;
    final configuration = FlutterIonSfuConfiguration();
    await _ionSfuServer.initialize();
    await _ionSfuServer.start(configuration);
    _iosSfuServerStart = true;
  }

  Future startRemoteScreenPublisher() async {
    if (_ionSfuClient == null) {
      final ionSignal = JsonRPCSignal("ws://127.0.0.1:$roomPort/ws");

      final uuid = const Uuid().v4();
      _ionSfuClient = await Client.create(
        sid: roomId,
        uid: uuid,
        signal: ionSignal,
      );

      _ionSfuClient!.ondatachannel = (RTCDataChannel dc) {
        if (dc.label != API_CHANNEL) {
          log("ondatachannel: ${dc.label}");
          _dataChannels.add(dc);

          dc.onDataChannelState = (RTCDataChannelState state) {
            if (state == RTCDataChannelState.RTCDataChannelClosed) {
              releaseEventSlotsByDataChannel(dc);
              _dataChannels.removeWhere((item) => item.id == dc.id);
            }
          };
        }
      };

      await updateScreenSize();
      String? deviceType = await DeviceInfoVs.deviceType;

      final captureResolution = getCaptureVideoResolution(
        deviceType,
        _screenWidth,
        _screenHeight,
      );
      log('Set capture resolution ${captureResolution.name} for ${_screenWidth}x$_screenHeight $deviceType');

      var constraints = Constraints.defaults;
      // Note: ion-sdk-flutter currently hard-code H264, so the settings here
      // are ineffective.
      constraints.codec = "h264";
      constraints.simulcast = false;
      constraints.audio = false;
      constraints.resolution = captureResolution.name;

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
                androidConfig: androidConfig);

            if (hasPermissions &&
                !FlutterBackground.isBackgroundExecutionEnabled) {
              await FlutterBackground.enableBackgroundExecution();
            }
          } catch (e) {
            log(e.toString());
          }
        }

        await requestBackgroundPermission();
      }

      var localStream =
          await LocalStream.getDisplayMedia(constraints: constraints);
      await _ionSfuClient?.publish(localStream);
    }
  }

  Future closeSfuServer() async {
    _ionSfuClient?.close();
    _ionSfuClient = null;
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

  int findSlotById(int channelId, int eventId) {
    int slot = -1;
    for (int i = 0; i < maxEventId; i++) {
      if (_eventSlots[i].channelId == channelId &&
          _eventSlots[i].eventId == eventId) {
        slot = i;
        break;
      }
    }
    return slot;
  }

  int acquireSlot(int channelId, int eventId) {
    // find a free slot
    int slot = findFreeSlot();
    if (slot < 0) {
      return -1;
    }

    _eventSlots[slot].channelId = channelId;
    _eventSlots[slot].eventId = eventId;
    return slot;
  }

  void releaseSlot(int slot) {
    assert(slot >= 0);
    assert(slot < maxEventId);

    _eventSlots[slot].channelId = -1;
    _eventSlots[slot].eventId = -1;
  }

  int releaseSlotById(int channelId, int eventId) {
    int slot = findSlotById(channelId, eventId);
    if (slot == -1) {
      return -1;
    }

    releaseSlot(slot);
    return slot;
  }

  int findFreeSlot() {
    for (int i = 0; i < maxEventId; i++) {
      if (_eventSlots[i].channelId == -1) {
        return i;
      }
    }
    return -1;
  }

  int reassignEventId(int channelId, int eventId, int action) {
    switch (action) {
      case FlutterInputInjection.TOUCH_POINT_START:
        return acquireSlot(channelId, eventId);
      case FlutterInputInjection.TOUCH_POINT_MOVE:
        return findSlotById(channelId, eventId);
      case FlutterInputInjection.TOUCH_POINT_END:
        return releaseSlotById(channelId, eventId);
      default:
        return -1;
    }
  }

  void releaseEventSlotsByDataChannel(RTCDataChannel dc) {
    for (int i = 0; i < maxEventId; i++) {
      if (_eventSlots[i].channelId == dc.id) {
        _flutterInputInjectionPlugin.sendTouch(
            FlutterInputInjection.TOUCH_POINT_END, i, 0, 0);
        releaseSlot(i);
      }
    }
  }

  void onTextMessage(RTCDataChannelMessage data) async {
    log('Received message: ${data.text}');
  }

  void onTouchMessage(RTCDataChannelMessage data, int dcIndex) async {
    EventMessage eventMessage = EventMessage.fromBuffer(data.binary);
    if (eventMessage.hasTouchEvent()) {
      int id = eventMessage.touchEvent.touchPoints[0].id;
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

      id = reassignEventId(dcIndex, id, action);
      if (id == -1) {
        return;
      }

      double remoteX = eventMessage.touchEvent.touchPoints[0].x;
      double remoteY = eventMessage.touchEvent.touchPoints[0].y;

      int injectX = (remoteX * _screenWidth).toInt();
      injectX = injectX.clamp(0, _screenWidth.toInt() - 1);
      int injectY = (remoteY * _screenHeight).toInt();
      injectY = injectY.clamp(0, _screenHeight.toInt() - 1);

      _flutterInputInjectionPlugin.sendTouch(action, id, injectX, injectY);
    }
  }

  void enableTouchBySessionId(String sessionID, bool touchEnabled) {
    log('enableTouch: $sessionID $touchEnabled');
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
}
