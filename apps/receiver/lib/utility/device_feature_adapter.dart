import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_info_vs/device_info_vs.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/utility/webrtc_util.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceFeatureAdapter {
  static final DeviceFeatureAdapter _instance =
      DeviceFeatureAdapter._internal();

  //private "Named constructors"
  DeviceFeatureAdapter._internal();

  // passes the instantiation to the _instance object
  factory DeviceFeatureAdapter() => _instance;

  static String _deviceType = '';
  static String _sdkVersion = '';
  static bool showOldUI = false;
  static bool showDebugOverlay = false;
  static bool useSoftwareDecode = false;
  static bool useQuickDecodeParams = false;
  static bool enableWebRtcH264BaselineProfile = false;
  static bool enableWebRtcTracing = false;
  static bool verboseWebRtcLog = false;
  static bool dumpSrtpPackets = false;
  static bool iceGatheringContinually = false;
  static String roomNumber = '';

  static bool defaultShowOldUI = false;
  static bool defaultShowDebugOverlay = false;
  static bool defaultUseSoftwareDecode = false;
  static bool defaultEnableWebRtcH264BaselineProfile = true;
  static bool defaultUseQuickDecodeParams = true;
  static const defaultEnableWebRtcTracing = false;
  static const defaultVerboseWebRtcLog = false;
  static bool defaultDumpSrtpPackets = false;
  // gather_continually by default
  static bool defaultIceGatheringContinually = true;
  static const String defaultRoomNumber = '';

  static Map<String, int> quickDecodeParams = {
    "low-latency": 1, // RK3588
    "rk-immediate-out": 1, // RK3288_3399
    "lowlatency": 1, // MTK9950
    "vendor.low-latency.enable": 1 // AMLogic982_1516 or Generic
  };

  static Map<String, dynamic> overrideDefaultParams = {
    'IFP50_3': {
      "useQuickDecode": false,
    },
    'IFP50_3_9850': {
      "useQuickDecode": false,
    }
  };

  static Map<String, dynamic> deviceOptions = {
    'IFP52_1C': {
      "selectCustomAudioFeed": "CVTE",
    },
    'IFP50_3': {
      "maxHardwareDecodeSession": 1,
    },
    'IFP50_3_9850': {
      "maxHardwareDecodeSession": 1,
    },
    'IFP62': {
      "maxHardwareDecodeSession": 1,
    },
    'CDE30': {
      // to avoid green line issue see 66146 and 63865
      "overridePortraitCaptureSize": "736x1280",
      "overrideLandscapeCaptureSize": "1280x720",
    }
  };

  static const Map<String, Map<String, int>> deviceDecodeParams = {
    'IFP52_1C': {
      // https://viewsonic-ssi.visualstudio.com/CVTE/_workitems/edit/58867
      // fix green video on MT9950
      "VideoPath": 1024,
    },
    'IFP52_K': {
      // https://viewsonic-ssi.visualstudio.com/CVTE/_workitems/edit/58867
      // fix green video on MT9950
      "VideoPath": 1024,
    },
  };

  static initDefault() async {
    final Map<String, dynamic>? params = overrideDefaultParams[_deviceType];

    if (params != null) {
      defaultShowOldUI = params["showOldUI"] ?? defaultShowOldUI;
      defaultShowDebugOverlay =
          params["showDebugOverlay"] ?? defaultShowDebugOverlay;
      defaultUseSoftwareDecode =
          params["useSoftwareDecode"] ?? defaultUseSoftwareDecode;
      defaultUseQuickDecodeParams =
          params["useQuickDecode"] ?? defaultUseQuickDecodeParams;
    }
  }

  static load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    showOldUI = prefs.getBool("showOldUI") ?? defaultShowOldUI;
    showDebugOverlay =
        prefs.getBool("ShowDebugOverlay") ?? defaultShowDebugOverlay;
    useSoftwareDecode =
        prefs.getBool("UseSoftwareDecode") ?? defaultUseSoftwareDecode;
    enableWebRtcH264BaselineProfile =
        prefs.getBool("EnableWebRtcH264BaselineProfile") ??
            defaultEnableWebRtcH264BaselineProfile;
    useQuickDecodeParams =
        prefs.getBool("UseQuickDecodeParams") ?? defaultUseQuickDecodeParams;
    enableWebRtcTracing =
        prefs.getBool("EnableWebRtcTracing") ?? defaultEnableWebRtcTracing;
    verboseWebRtcLog =
        prefs.getBool("VerboseWebRtcLog") ?? defaultVerboseWebRtcLog;
    dumpSrtpPackets =
        prefs.getBool("DumpSrtpPackets") ?? defaultDumpSrtpPackets;
    iceGatheringContinually = prefs.getBool("IceGatheringContinually") ??
        defaultIceGatheringContinually;
    roomNumber = prefs.getString("RoomNumber") ?? defaultRoomNumber;
  }

  static save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("showOldUI", showOldUI);
    await prefs.setBool("ShowDebugOverlay", showDebugOverlay);
    await prefs.setBool("UseSoftwareDecode", useSoftwareDecode);
    await prefs.setBool(
        "EnableWebRtcH264BaselineProfile", enableWebRtcH264BaselineProfile);
    await prefs.setBool("UseQuickDecodeParams", useQuickDecodeParams);
    await prefs.setBool("EnableWebRtcTracing", enableWebRtcTracing);
    await prefs.setBool("VerboseWebRtcLog", verboseWebRtcLog);
    await prefs.setBool("DumpSrtpPackets", dumpSrtpPackets);
    await prefs.setBool("IceGatheringContinually", iceGatheringContinually);
    await prefs.setString("RoomNumber", roomNumber);
  }

  static Map<String, int> getDecodeOptions(
      {bool excludeQuickDecodeParams = false}) {
    final options = <String, int>{};

    // add quick decode parameters
    if (!excludeQuickDecodeParams && useQuickDecodeParams) {
      options.addAll(quickDecodeParams);
    }

    // add device-specific decode parameters
    final params = deviceDecodeParams[_deviceType];
    if (params != null) {
      options.addAll(params);
    }

    return options;
  }

  static ensureInitialized() async {
    _deviceType = await DeviceInfoVs.deviceType ?? '';
    _sdkVersion = (await DeviceInfoPlugin().androidInfo).version.release;
    log.info('sdkVersion: $_sdkVersion');

    await initDefault();
    await load();

    Map<String, int> decodeOptions = getDecodeOptions();
    Map<String, dynamic> options = {
      'additionalDecoderParameter': decodeOptions,
      'enableH264BaselineProfile': enableWebRtcH264BaselineProfile,
      'enableTracing': enableWebRtcTracing,
      'logSeverity': verboseWebRtcLog ? 'VERBOSE' : 'INFO',
    };

    final opts = deviceOptions[_deviceType];
    if (opts != null) {
      options.addAll(opts);
    }

    // Workaround for [BUG 71148] 50-5 A13平台無法使用H264 Contraint-BaseLine Profile
    if (_deviceType == 'IFP50_5' && _sdkVersion == '13') {
      options['maxHardwareDecodeSession'] = 0; // disable hardware decode
    }

    if (useSoftwareDecode) {
      options['maxHardwareDecodeSession'] = 0;
    }

    if (dumpSrtpPackets) {
      // enable rtp dump (for debugging)
      options['fieldTrials'] = WebRTCUtil.getRtpDumpFieldTrails(true);
      options['enableInjectableLogger'] = true; // must enable injectable logger
      options['logSeverity'] = 'VERBOSE'; // must override log severity
      log.info(
          'since dumpSrtpPackets is enabled, logSeverity is set to VERBOSE, and webrtc native log is disabled');
    }

    log.info('Initialize webrtc. Options: ${options.toString()}');
    await WebRTC.initialize(options: options);
  }
}
