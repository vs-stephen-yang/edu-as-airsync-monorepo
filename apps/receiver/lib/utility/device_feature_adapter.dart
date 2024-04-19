
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceFeatureAdapter {

  static final DeviceFeatureAdapter _instance = DeviceFeatureAdapter._internal();

  //private "Named constructors"
  DeviceFeatureAdapter._internal();

  // passes the instantiation to the _instance object
  factory DeviceFeatureAdapter() => _instance;

  static bool UseSoftwareDecode = false;
  static bool UseRK3588QuickDecode = false;
  static bool UseRK3288_3399QuickDecode = false;
  static bool UseMTK9950QuickDecode = false;
  static bool UseAMLogic982_1516QuickDecode = false;
  static bool UseGenericQuickDecode = false;

  static Map<String, int> RK3588 = {
    "low-latency": 1, // quick decode
  };

  static Map<String, int> RK3288_3399 = {
    "rk-immediate-out": 1, // quick decode
  };

  static Map<String, int> MTK9950 = {
    "VideoPath": 1, // green screen on 2nd decoder
    "lowlatency": 1 // quick decode
  };

  static Map<String, int> AMLogic982_1516 = { // DrodiLogic or AMLogic
    "vendor.low-latency.enable": 1, // quick decode
  };

  static Map<String, int> Generic = {
    "vendor.low-latency.enable": 1, // quick decode
  };

  static Map<String, dynamic> deviceOptions = {
    '52-1C': {
      "maxHardwareDecodeSession": 1,
      "selectCustomAudioFeed": "CVTE"
    },
    '50-3': {
      "maxHardwareDecodeSession": 1,
    },
    '6562': {
      "maxHardwareDecodeSession": 1,
    },
  };

  static dynamic softwareDecodeOptions = {
    "maxHardwareDecodeSession": 0
  };

  static save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("UseSoftwareDecode", UseSoftwareDecode);
    prefs.setBool("UseRK3588QuickDecode", UseRK3588QuickDecode);
    prefs.setBool("UseRK3288_3399QuickDecode", UseRK3288_3399QuickDecode);
    prefs.setBool("UseMTK9950QuickDecode", UseMTK9950QuickDecode);
    prefs.setBool("UseAMLogic982_1516QuickDecode", UseAMLogic982_1516QuickDecode);
    prefs.setBool("UseGenericQuickDecode", UseGenericQuickDecode);
  }

  static load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    UseSoftwareDecode = prefs.getBool("UseSoftwareDecode") ?? false;
    UseRK3588QuickDecode = prefs.getBool("UseRK3588QuickDecode") ?? false;
    UseRK3288_3399QuickDecode = prefs.getBool("UseRK3288_3399QuickDecode") ?? false;
    UseMTK9950QuickDecode = prefs.getBool("UseMTK9950QuickDecode") ?? false;
    UseAMLogic982_1516QuickDecode = prefs.getBool("UseAMLogic982_1516QuickDecode") ?? false;
    UseGenericQuickDecode = prefs.getBool("UseGenericQuickDecode") ?? false;
  }

  static Map<String, int> getQuickDecodeOptions() {
    if (UseRK3588QuickDecode) {
      return RK3588;
    } else if (UseRK3288_3399QuickDecode) {
      return RK3288_3399;
    } else if (UseMTK9950QuickDecode) {
      return MTK9950;
    } else if (UseAMLogic982_1516QuickDecode) {
      return AMLogic982_1516;
    } else if (UseGenericQuickDecode) {
      return Generic;
    }
    return {};
  }

  static ensureInitialized() async {
    await load();

    Map<String, int> quickDecodeOptions = getQuickDecodeOptions();
    Map<String, dynamic> options = {
      'additionalDecoderParameter': quickDecodeOptions
    };

    if (UseSoftwareDecode) {
      options.addAll(softwareDecodeOptions);
    } else {
      String model = await _instance._loadModel() ?? '';
      for (var entry in deviceOptions.entries) {
        if (model.contains(entry.key)) {
          options.addAll(Map<String, dynamic>.from(entry.value));
          break;
        }
      }
    }

    await WebRTC.initialize(options: options);
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
