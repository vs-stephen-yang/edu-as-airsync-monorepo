import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc/src/native/rtc_peerconnection_native.dart';

enum WebRTCLogType { stats, event }

class WebRTCLogManager {
  static final WebRTCLogManager _instance = WebRTCLogManager._internal();

  factory WebRTCLogManager() {
    return _instance;
  }

  WebRTCLogManager._internal();

  String _logDir = '';
  String _eventLogFileName = '';
  String _statsLogFileName = '';
  bool _statsLogEnabled = false;
  bool _eventLogEnabled = false;

  String get eventLogFilePath => '$_logDir/$_eventLogFileName';
  String get statsLogFilePath => '$_logDir/$_statsLogFileName';

  void clear() {
    _logDir = '';
    _eventLogFileName = '';
    _statsLogFileName = '';
    _statsLogEnabled = false;
    _eventLogEnabled = false;
  }

  void setup(String dir, bool statsLogEnabled, bool eventLogEnabled) {
    _logDir = dir;
    _statsLogEnabled = statsLogEnabled;
    _eventLogEnabled = eventLogEnabled;
  }

  Future<bool> startLog(RTCPeerConnection? peerConnection) async {
    if (_eventLogEnabled) {
      return await _startEventLog(peerConnection);
    }
    return Future.value(false);
  }

  Future<void> stopLog(RTCPeerConnection? peerConnection) async {
    if (_eventLogEnabled) {
      await _stopEventLog(peerConnection);
    }
  }

  void onStatsReport(List<StatsReport> reports) {
    if (_statsLogEnabled) {
      List<Map<String, dynamic>> jsonData = reports.map((report) {
        return {
          'id': report.id,
          'type': report.type,
          'timestamp': report.timestamp,
          'values': report.values,
        };
      }).toList();

      Directory logDirectory = Directory(_logDir);
      if (!logDirectory.existsSync()) {
        logDirectory.createSync(recursive: true);
      }

      if (_statsLogFileName.isEmpty) {
        _statsLogFileName = _generateFileName(WebRTCLogType.stats);
      }

      final logFile = File(statsLogFilePath);
      final jsonString = jsonEncode(jsonData);
      logFile.writeAsStringSync(
        '$jsonString\n\n', // Add a newline for better readability
        mode: FileMode.append,
        flush: true,
      );
    }
  }

  Future<bool> _startEventLog(RTCPeerConnection? peerConnection) {
    if (peerConnection == null || _logDir.isEmpty) {
      return Future.value(false); // peerConnection is null
    }
    try {
      if (kIsWeb) {
        return Future.value(false); // does not support rtc event log on web
      }
      RtcPeerconnectionNative peerConnectionNative =
          peerConnection as RtcPeerconnectionNative;
      _eventLogFileName = _generateFileName(WebRTCLogType.event);
      if (Platform.isWindows) {
        return peerConnectionNative.startRtcEventLogOnWindows(
            '$_logDir/', _eventLogFileName);
      } else if (Platform.isAndroid) {
        return peerConnectionNative.startRtcEventLogOnAndroid(
            eventLogFilePath, 0 /*unlimited*/);
      } else if (Platform.isIOS || Platform.isMacOS) {
        return peerConnectionNative.startRtcEventLogOnAppleDevice(
            eventLogFilePath, 0 /*unlimited*/);
      }
      return Future.value(false);
    } catch (e) {
      return Future.value(false);
    }
  }

  Future<void> _stopEventLog(RTCPeerConnection? peerConnection) async {
    if (kIsWeb) {
      return; // does not support rtc event log on web
    }
    try {
      RtcPeerconnectionNative peerConnectionNative =
          peerConnection as RtcPeerconnectionNative;
      await peerConnectionNative.stopRTCEventLog();
      _eventLogFileName = ''; // clear log file name
    } catch (e) {
      return;
    }
  }

  String _generateFileName(WebRTCLogType type) {
    if (type == WebRTCLogType.stats) {
      return 'webrtc_stats_log_${DateTime.now().millisecondsSinceEpoch}';
    } else {
      return 'webrtc_event_log_${DateTime.now().millisecondsSinceEpoch}';
    }
  }
}
