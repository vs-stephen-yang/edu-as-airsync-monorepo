
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

  static bool ShowDebugOverlay = false;
  static bool UseSoftwareDecode = false;
  static bool UseQuickDecodeParams = false;

  static final bool DefaultShowDebugOverlay = false;
  static final bool DefaultUseSoftwareDecode = false;
  static final bool DefaultUseQuickDecodeParams = true;

  static Map<String, int> QuickDecodeParams = {
    "low-latency": 1, // RK3588
    "rk-immediate-out": 1, // RK3288_3399
    "lowlatency": 1, // MTK9950
    "vendor.low-latency.enable": 1 // AMLogic982_1516 or Generic
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
    prefs.setBool("ShowDebugOverlay", ShowDebugOverlay);
    prefs.setBool("UseSoftwareDecode", UseSoftwareDecode);
    prefs.setBool("UseQuickDecodeParams", UseQuickDecodeParams);
  }

  static load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ShowDebugOverlay = prefs.getBool("ShowDebugOverlay") ?? DefaultShowDebugOverlay;
    UseSoftwareDecode = prefs.getBool("UseSoftwareDecode") ?? DefaultUseSoftwareDecode;
    UseQuickDecodeParams = prefs.getBool("UseQuickDecodeParams") ?? DefaultUseQuickDecodeParams;
  }

  static Map<String, int> getQuickDecodeOptions() {
    if (UseQuickDecodeParams) {
      return QuickDecodeParams;
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
