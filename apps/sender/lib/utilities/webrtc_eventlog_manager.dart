import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc/src/native/rtc_peerconnection_native.dart';

class WebRTCEventlogManager {
  static final WebRTCEventlogManager _instance = WebRTCEventlogManager._internal();

  factory WebRTCEventlogManager() {
    return _instance;
  }

  WebRTCEventlogManager._internal();

  String _eventLogDir = '';
  String _logFileName = '';

  String get logFilePath => '$_eventLogDir/$_logFileName';

  void clearEventLogDir() {
    _eventLogDir = '';
  }

  void setEventLogDir(String eventLogDir) {
    _eventLogDir = eventLogDir;
  }

  Future<bool> startEventLog(RTCPeerConnection? peerConnection) {
    if (peerConnection == null || _eventLogDir.isEmpty) {
      return Future.value(false); // peerConnection is null
    }
    try {
      if (kIsWeb) {
        return Future.value(false); // does not support rtc event log on web
      }
      RtcPeerconnectionNative peerConnectionNative = peerConnection as RtcPeerconnectionNative;
      _logFileName = _generateFileName();
      if (Platform.isWindows) {
        return peerConnectionNative.startRtcEventLogOnWindows(_eventLogDir + '/', _logFileName);
      } else if (Platform.isAndroid) {
        return peerConnectionNative.startRtcEventLogOnAndroid(logFilePath, 0/*unlimit*/);
      } else if (Platform.isIOS || Platform.isMacOS) {
        return peerConnectionNative.startRtcEventLogOnAppleDevice(logFilePath, 0/*unlimit*/);
      }
      return Future.value(false);
    } catch (e) {
      return Future.value(false);
    }
  }

  Future<void> stopEventLog(RTCPeerConnection? peerConnection) async {
    if (kIsWeb) {
      return; // does not support rtc event log on web
    }
    try {
      RtcPeerconnectionNative peerConnectionNative = peerConnection as RtcPeerconnectionNative;
      await peerConnectionNative.stopRTCEventLog();
      _logFileName = ''; // clear log file name
    } catch (e) {
      return;
    }
  }

  String _generateFileName() {
    return 'webrtc_event_log_${DateTime.now().millisecondsSinceEpoch}';
  }
}