import 'dart:async';

import 'package:display_flutter/model/rtc_stats.dart';
import 'package:display_flutter/utility/log.dart';

/// Callback when FPS is detected as zero for a sustained period
typedef OnFpsZeroDetected = void Function({
  required int sampleCount,
  required Duration duration,
  required String reason,
});

/// A detector that monitors WebRTC inbound video FPS and triggers a callback
/// when FPS remains at zero after a specified delay or upon disconnection.
///
/// This detector performs a one-time check only:
/// - After N seconds from the first connection (onTrack)
/// - Or when disconnection occurs
///
/// Once checked, it stops collecting data.
///
/// Usage:
/// ```dart
/// // With default callback (logs warning)
/// final detector = RtcFpsZeroDetector(
///   checkDelay: Duration(seconds: 10),
///   minSamples: 3,
/// );
///
/// // With custom callback
/// final detector = RtcFpsZeroDetector(
///   checkDelay: Duration(seconds: 10),
///   minSamples: 3,
///   onFpsZeroDetected: ({required sampleCount, required duration, required reason}) {
///     print('FPS is zero! Sample count: $sampleCount');
///   },
/// );
///
/// // Start collecting and schedule check
/// detector.startCollecting();
///
/// // Feed stats regularly (called by RtcStatsReporter)
/// detector.onVideoInboundStats(stats);
///
/// // Check on disconnection
/// detector.checkOnDisconnect();
///
/// // Clean up
/// detector.dispose();
/// ```
class RtcFpsZeroDetector {
  /// The delay after which to perform the check
  final Duration checkDelay;

  /// Minimum number of samples required before checking
  final int minSamples;

  /// Callback when FPS is detected as zero
  final OnFpsZeroDetected onFpsZeroDetected;

  /// History of FPS values
  final List<_FpsSample> _fpsHistory = [];

  /// Timer for delayed check
  Timer? _delayedCheckTimer;

  /// Whether detector has been disposed
  bool _isDisposed = false;

  /// Whether check has been performed
  bool _hasChecked = false;

  /// First sample time (for duration calculation)
  DateTime? _firstSampleTime;

  /// Last sample time (for duration calculation)
  DateTime? _lastSampleTime;

  RtcFpsZeroDetector({
    this.checkDelay = const Duration(seconds: 10),
    this.minSamples = 3,
    OnFpsZeroDetected? onFpsZeroDetected,
  }) : onFpsZeroDetected = onFpsZeroDetected ?? _defaultFpsZeroCallback;

  static void _defaultFpsZeroCallback({
    required int sampleCount,
    required Duration duration,
    required String reason,
  }) {
    log.warning(
      'Remote screen FPS is zero! '
      'Sample count: $sampleCount, Duration: $duration, Reason: $reason',
    );
  }

  /// Start collecting data and schedule the delayed check
  void startCollecting() {
    if (_isDisposed || _hasChecked) return;

    log.info('RtcFpsZeroDetector: Start collecting FPS data');

    // Schedule a one-time check after the delay
    _delayedCheckTimer?.cancel();
    _delayedCheckTimer = Timer(checkDelay, () {
      _performCheck(reason: 'Delayed check after $checkDelay');
    });
  }

  /// Feed video inbound stats to the detector
  void onVideoInboundStats(RtcVideoInboundStats stats) {
    if (_isDisposed || _hasChecked) return;

    final now = DateTime.now();
    final fps = stats.framesPerSecond ?? 0.0;

    _firstSampleTime ??= now;
    _lastSampleTime = now;

    _fpsHistory.add(_FpsSample(
      fps: fps,
      timestamp: now,
    ));
  }

  /// Check if all FPS values in history are zero
  void _performCheck({required String reason}) {
    if (_isDisposed || _hasChecked) return;

    // Mark as checked to prevent future checks and data collection
    _hasChecked = true;

    // Cancel the delayed timer if it's still active
    _delayedCheckTimer?.cancel();
    _delayedCheckTimer = null;

    if (_fpsHistory.length < minSamples) {
      log.info(
        'RtcFpsZeroDetector: Not enough samples (${_fpsHistory.length}/$minSamples). '
        'Skipping check. Reason: $reason',
      );
      return;
    }

    // Check if all FPS values are zero
    final allZero = _fpsHistory.every((sample) => sample.fps == 0.0);

    if (allZero) {
      final duration = _firstSampleTime != null && _lastSampleTime != null
          ? _lastSampleTime!.difference(_firstSampleTime!)
          : Duration.zero;

      log.warning(
        'RtcFpsZeroDetector: All FPS values are zero! '
        'Sample count: ${_fpsHistory.length}, Duration: $duration, Reason: $reason',
      );

      onFpsZeroDetected(
        sampleCount: _fpsHistory.length,
        duration: duration,
        reason: reason,
      );
    } else {
      log.info(
        'RtcFpsZeroDetector: FPS check passed. '
        'Non-zero samples found in history (${_fpsHistory.length} total samples). Reason: $reason',
      );
    }
  }

  /// Manually trigger a check (e.g., on disconnection)
  void checkOnDisconnect() {
    _performCheck(reason: 'Disconnection');
  }

  /// Dispose the detector and cancel timers
  void dispose() {
    _isDisposed = true;
    _delayedCheckTimer?.cancel();
    _delayedCheckTimer = null;
    _fpsHistory.clear();
  }
}

/// Internal class to store FPS sample with timestamp
class _FpsSample {
  final double fps;
  final DateTime timestamp;

  _FpsSample({
    required this.fps,
    required this.timestamp,
  });
}
