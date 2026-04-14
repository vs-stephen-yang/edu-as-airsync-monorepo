import 'dart:async';
import 'dart:io';

import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/utility/log_upload.dart';
import 'package:display_flutter/utility/logcat_reader.dart';
import 'package:logging/logging.dart';

/// Global singleton instance.
final castToBoardsSessionLogger = CastToBoardsSessionLogger();

/// Collects Cast to Boards related log lines from the Dart logger during a
/// session and uploads them together with the Android logcat as a single
/// Sentry attachment when a diagnostic event occurs.
///
/// Lifecycle:
///   - Host  : start() in RemoteScreenServer.startRemoteScreenPublisher()
///             stop()  in RemoteScreenServer.stopRemoteScreenPublisher()
///   - Member: start() in DisplayGroupSession constructor
///             stop()  in DisplayGroupSession.stop()
///
/// Upload triggers:
///   - Signal closed abnormally   (RtcScreenClient.onSignalClose)
///   - WebRTC connection failed   (RTCPeerConnectionStateFailed)
///   - Member FPS zero            (RtcScreenClient._onFpsZero)
///   - Host recreate max failure  (RemoteScreenServer._handleRecreateFailure)
///   - Member reported FPS zero   (DisplayGroupMember._onChannelMessage)
class CastToBoardsSessionLogger {
  static const _keywords = [
    'DisplayGroupHost',
    'DisplayGroupMember',
    'DisplayGroupSession',
    'DisplayGroupMediator',
    'RtcScreenConnector',
    'Remote screen:',
    'RtcScreenClient',
    'SfuPublisher',
    'ZeroFpsDetector',
    'RtcFpsZeroDetector',
    'VideoTrackManager',
    'Display Group',
  ];

  static const _maxLines = 2000;

  final _buffer = <String>[];
  StreamSubscription<LogRecord>? _subscription;
  DateTime? _sessionStart;
  String? _role;

  bool get isActive => _subscription != null;

  /// Start collecting logs for a new Cast to Boards session.
  /// Clears any previously collected data.
  void start(String role) {
    _buffer.clear();
    _sessionStart = DateTime.now();
    _role = role;
    _subscription?.cancel();
    _subscription = Logger.root.onRecord.listen(_onRecord);
    log.info('CastToBoardsSessionLogger: Session started, role=$role');
  }

  /// Stop collecting logs.
  void stop() {
    log.info(
        'CastToBoardsSessionLogger: Session stopped, collected ${_buffer.length} lines');
    _subscription?.cancel();
    _subscription = null;
  }

  void _onRecord(LogRecord record) {
    final isCastLog = _keywords.any((kw) => record.message.contains(kw));
    if (!isCastLog) return;

    var line = '${record.time} ${record.level.name} ${record.message}';
    if (record.error != null) line += ' | ${record.error}';

    if (_buffer.length >= _maxLines) _buffer.removeAt(0);
    _buffer.add(line);
  }

  /// Upload collected Dart logs + Android logcat to Sentry as a single file.
  Future<void> upload(String reason) async {
    if (_sessionStart == null) {
      log.warning(
          'CastToBoardsSessionLogger: Upload skipped, no active session');
      return;
    }

    log.info(
        'CastToBoardsSessionLogger: Uploading session log, reason=$reason, lines=${_buffer.length}');

    final dartLogs = _buffer.join(Platform.lineTerminator);
    final logcatLogs = await LogcatReader.readLog(lines: 2000);

    final content = [
      '=== Cast to Boards Session Log ===',
      'Role    : ${_role ?? 'unknown'}',
      'Reason  : $reason',
      'Start   : $_sessionStart',
      'Upload  : ${DateTime.now().toIso8601String()}',
      '',
      '=== Cast to Boards Dart Logs (${_buffer.length} lines) ===',
      dartLogs,
      '',
      '=== Android Logcat (last 2000 lines) ===',
      logcatLogs,
    ].join(Platform.lineTerminator);

    await uploadLog(reason, content);
  }
}
