
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class DeviceFeatureAdapter {

  static final DeviceFeatureAdapter _instance = DeviceFeatureAdapter._internal();

  //private "Named constructors"
  DeviceFeatureAdapter._internal();

  // passes the instantiation to the _instance object
  factory DeviceFeatureAdapter() => _instance;

  static List<String> deviceList = <String>['52-1C'];

  static int maxHardwareDecodeSession = 1;

  static ensureInitialized() async {
    String model = await _instance._loadModel() ?? '';
    for (var element in deviceList) {
      if (model.contains(element)) {
        await WebRTC.initialize(
            options: {
              "maxHardwareDecodeSession": maxHardwareDecodeSession,
              "selectCustomAudioFeed": "CVTE"
            }
        );
      }
    }
  }

  Future<String?> _loadModel() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo info = await deviceInfo.androidInfo;
      return info.model;
    } else if (Platform.isIOS) {
      IosDeviceInfo info = await deviceInfo.iosInfo;
      return info.model;
    }
    return null;
  }

}
