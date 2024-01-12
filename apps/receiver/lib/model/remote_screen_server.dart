import 'dart:io';
import 'dart:developer';

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

const DEFAULT_SCREEN_WIDTH = 1920.0;
const DEFAULT_SCREEN_HEIGHT = 1080.0;
const MAX_EVENT_ID = 255;
class EventSlot {
  int channelID = -1;
  int eventID = -1;
}

class RemoteScreenServer {

  Client? _ionSfuClient;
  final FlutterIonSfu _ionSfuServer = FlutterIonSfu();
  bool _iosSfuServerStart = false;
  String roomId = 'remote-screen';
  int roomPort = 7000;
  List<RTCDataChannel> _dataChannels = [];
  double _screenWidth = DEFAULT_SCREEN_WIDTH;
  double _screenHeight = DEFAULT_SCREEN_HEIGHT;
  List<EventSlot> _eventSlots = List.generate(MAX_EVENT_ID, (index) => EventSlot());
  final _flutterInputInjectionPlugin = FlutterInputInjection();

  RemoteScreenServer();

  Future startSfuServer() async {
    if(_iosSfuServerStart) return;
    final configuration = FlutterIonSfuConfiguration();
    await _ionSfuServer.initialize();
    await _ionSfuServer.start(configuration);
    _iosSfuServerStart = true;
  }

  Future startRemoteScreenPublisher() async {
    if (_ionSfuClient == null) {

      final ionSignal = JsonRPCSignal("ws://127.0.0.1:$roomPort/ws");

      final uuid = const Uuid().v4();
      _ionSfuClient = await Client.create(sid: roomId, uid: uuid, signal: ionSignal,);

      _ionSfuClient!.ondatachannel = (RTCDataChannel dc) {
        if( dc.label != API_CHANNEL) {
          int dcIndex = _dataChannels.length;
          _dataChannels.add(dc);
          dc!.onMessage = (data) async {
            if ( data.isBinary ) {
              EventMessage eventMessage = EventMessage.fromBuffer(data.binary);
              if(eventMessage.hasTouchEvent()) {
                int action = FlutterInputInjection.TOUCH_POINT_START;
                if (eventMessage.touchEvent.eventType == TouchEvent_TouchEventType.TOUCH_POINT_START) {
                  action = FlutterInputInjection.TOUCH_POINT_START;
                } else if (eventMessage.touchEvent.eventType == TouchEvent_TouchEventType.TOUCH_POINT_MOVE) {
                  action = FlutterInputInjection.TOUCH_POINT_MOVE;
                } else if (eventMessage.touchEvent.eventType == TouchEvent_TouchEventType.TOUCH_POINT_END) {
                  action = FlutterInputInjection.TOUCH_POINT_END;
                }
                double remoteX = eventMessage.touchEvent.touchPoints[0].x;
                double remoteY = eventMessage.touchEvent.touchPoints[0].y;

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
                int id = eventMessage.touchEvent.touchPoints[0].id;
                id = reassignEventID(dcIndex, id, action);
                if(id == -1) {
                  return;
                } else {
                  _flutterInputInjectionPlugin.sendTouch(action, id, injectX, injectY);
                }              }
            } else {
              log('dcCreate: Received message: ${data.text}');
            }
          };
        }
      };

      await updateScreenSize();

      var constraints = Constraints.defaults;
      // Note: ion-sdk-flutter currently hard-code H264, so the settings here
      // are ineffective.
      constraints.codec = "h264";
      constraints.simulcast = false;
      constraints.audio = false;
      constraints.resolution = "fhd";

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

      var localStream = await LocalStream.getDisplayMedia(
          constraints: constraints
      );
      await _ionSfuClient?.publish(localStream);
    }
  }

  Future closeSfuServer() async {
    _ionSfuClient?.close();
    _ionSfuClient = null;
  }

  Future<void> updateScreenSize() async{
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

  int reassignEventID(int channelID, int eventID, int action) {
    int foundSlotIdx = -1;
    int emptySlotIdx = -1;
    for (int i = 0; i < MAX_EVENT_ID; i++) {
      if (emptySlotIdx == -1 && _eventSlots[i].channelID == -1) {
        emptySlotIdx = i;
      }

      if (_eventSlots[i].channelID == channelID && _eventSlots[i].eventID == eventID) {
        foundSlotIdx = i;
        break;
      }
    }

    if (foundSlotIdx == -1) {
      if (action == FlutterInputInjection.TOUCH_POINT_END || emptySlotIdx == -1) {
        /* can't found matched slot for end event or no empty slot */
        return -1;
      }
      foundSlotIdx = emptySlotIdx;
      // print('put touch slot:' + foundSlotIdx.toString() + 'channel:' + channelID.toString() + ' id:' + eventID.toString());
    }

    /* update slot info */
    if(action == FlutterInputInjection.TOUCH_POINT_END) {
      _eventSlots[foundSlotIdx].channelID = -1;
      _eventSlots[foundSlotIdx].eventID = -1;
      // print('remove touch slot:' + foundSlotIdx.toString() + 'channel:' + channelID.toString() + ' id:' + eventID.toString());
    } else {
      _eventSlots[foundSlotIdx].channelID = channelID;
      _eventSlots[foundSlotIdx].eventID = eventID;
    }

    return foundSlotIdx;
  }
}