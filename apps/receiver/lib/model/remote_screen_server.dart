
import 'package:flutter_ion_sfu/flutter_ion_sfu.dart';
import 'package:flutter_ion_sfu/flutter_ion_sfu_configuration.dart';
import 'package:ion_sdk_flutter/flutter_ion.dart';
import 'package:uuid/uuid.dart';

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