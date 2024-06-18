
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceFeatureAdapter {

  static final DeviceFeatureAdapter _instance = DeviceFeatureAdapter._internal();

  //private "Named constructors"
  DeviceFeatureAdapter._internal();

  // passes the instantiation to the _instance object
  factory DeviceFeatureAdapter() => _instance;

  static String model = '';
  static bool showDebugOverlay = false;
  static bool useSoftwareDecode = false;
  static bool useQuickDecodeParams = false;
  static bool enableWebRtcTracing = false;
  static bool verboseWebRtcLog = false;

  static bool defaultShowDebugOverlay = false;
  static bool defaultUseSoftwareDecode = false;
  static bool defaultUseQuickDecodeParams = true;
  static const defaultEnableWebRtcTracing = false;
  static const defaultVerboseWebRtcLog = false;

  static Map<String, int> quickDecodeParams = {
    "low-latency": 1, // RK3588
    "rk-immediate-out": 1, // RK3288_3399
    "lowlatency": 1, // MTK9950
    "vendor.low-latency.enable": 1 // AMLogic982_1516 or Generic
  };

  static Map<String, dynamic> overrideDefaultParams = {
    '50-3': {
      "useQuickDecode": false
    }
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


  static const Map<String, Map<String, int>> deviceDecodeParams = {
  };

  static dynamic softwareDecodeOptions = {
    "maxHardwareDecodeSession": 0
  };

  static initDefault() async {
    for (var entry in overrideDefaultParams.entries) {
      if (model.contains(entry.key)) {
        defaultShowDebugOverlay = entry.value["showDebugOverlay"] ?? defaultShowDebugOverlay;
        defaultUseSoftwareDecode = entry.value["useSoftwareDecode"] ?? defaultUseSoftwareDecode;
        defaultUseQuickDecodeParams = entry.value["useQuickDecode"] ?? defaultUseQuickDecodeParams;
      }
    }
  }

  static load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    showDebugOverlay = prefs.getBool("ShowDebugOverlay") ?? defaultShowDebugOverlay;
    useSoftwareDecode = prefs.getBool("UseSoftwareDecode") ?? defaultUseSoftwareDecode;
    useQuickDecodeParams = prefs.getBool("UseQuickDecodeParams") ?? defaultUseQuickDecodeParams;
    enableWebRtcTracing = prefs.getBool("EnableWebRtcTracing") ?? defaultEnableWebRtcTracing;
    verboseWebRtcLog = prefs.getBool("VerboseWebRtcLog") ?? defaultVerboseWebRtcLog;
  }

  static save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("ShowDebugOverlay", showDebugOverlay);
    prefs.setBool("UseSoftwareDecode", useSoftwareDecode);
    prefs.setBool("UseQuickDecodeParams", useQuickDecodeParams);
    prefs.setBool("EnableWebRtcTracing", enableWebRtcTracing);
    prefs.setBool("VerboseWebRtcLog", verboseWebRtcLog);
  }

  static Map<String, int> getDecodeOptions() {
    final options = <String, int>{};

    // add quick decode parameters
    if (useQuickDecodeParams) {
      options.addAll(quickDecodeParams);
    }

    // add device-specific decode parameters
    final params = deviceDecodeParams[model];
    if (params != null) {
      options.addAll(params);
    }

    return options;
  }

  static ensureInitialized() async {
    model = await _instance._loadModel() ?? '';

    await initDefault();
    await load();

    Map<String, int> decodeOptions = getDecodeOptions();
    Map<String, dynamic> options = {
      'additionalDecoderParameter': decodeOptions,
      'enableTracing': enableWebRtcTracing,
      'logSeverity': verboseWebRtcLog ? 'VERBOSE' : 'INFO',
    };

    if (useSoftwareDecode) {
      options.addAll(softwareDecodeOptions);
    } else {
      for (var entry in deviceOptions.entries) {
        if (model.contains(entry.key)) {
          options.addAll(Map<String, dynamic>.from(entry.value));
          break;
        }
      }
    }

    log.info('Initialize webrtc. Options: ${options.toString()}');
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
