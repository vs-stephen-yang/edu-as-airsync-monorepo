import 'dart:io';
import 'dart:developer';

import 'package:flutter_ion_sfu/flutter_ion_sfu.dart';
import 'package:flutter_ion_sfu/flutter_ion_sfu_configuration.dart';
import 'package:ion_sdk_flutter/flutter_ion.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background/flutter_background.dart';

class RemoteScreenServer {

  Client? _ionSfuClient;
  final FlutterIonSfu _ionSfuServer = FlutterIonSfu();
  bool _iosSfuServerStart = false;
  String roomId = 'remote-screen';
  int roomPort = 7000;


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

}