import 'package:display_flutter/model/rtc_stats.dart';
import 'package:display_flutter/utility/math_util.dart';

class RtcStatsSummary {
  final Duration? duration;
  final int? totalInboundVideoBytes;
  final double? ewmaRttSec;

  RtcStatsSummary({
    this.duration,
    this.totalInboundVideoBytes,
    this.ewmaRttSec,
  });
}

class RtcStatsMonitor {
  DateTime? _startTime;
  DateTime? _lastUpdateTime;

  int? _totalInboundVideoBytes;

  double? _ewmaRttSec = 0;
  static const _ewmaAlpha = 0.1;

  RtcStatsSummary createSummary() {
    final duration = (_startTime != null && _lastUpdateTime != null)
        ? _lastUpdateTime!.difference(_startTime!)
        : null;

    return RtcStatsSummary(
      duration: duration,
      totalInboundVideoBytes: _totalInboundVideoBytes,
      ewmaRttSec: _ewmaRttSec,
    );
  }

  void onVideoInboundStats(RtcVideoInboundStats stats) {
    final now = DateTime.now();

    _startTime ??= now;
    _lastUpdateTime = now;

    _totalInboundVideoBytes = stats.bytesReceived;
  }

  void onIceCandidatePairStats(RtcIceCandidatePairStats stats) {
    if (stats.currentRoundTripTime != null) {
      // Calculate the EWMA (Exponentially Weighted Moving Average) of RTT
      _ewmaRttSec = calculateEwma(
        currentValue: stats.currentRoundTripTime!,
        previousValue: _ewmaRttSec ?? 0,
        alpha: _ewmaAlpha,
      );
    }
  }
}
