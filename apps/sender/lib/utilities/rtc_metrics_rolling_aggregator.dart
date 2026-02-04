import 'dart:collection';

import 'package:display_cast_flutter/model/rtc_stats.dart';
import 'package:display_cast_flutter/utilities/math_util.dart';

/// Summary of per-second RTC metrics.
class RtcMetricsSummary {
  /// Percentiles for each metric keyed by percentile name (e.g. p1, p50).
  final Map<String, Map<String, double>> percentiles;

  RtcMetricsSummary({
    required this.percentiles,
  });

  Map<String, dynamic> toJson() => {
        'percentiles': percentiles,
      };

  /// Flattens percentiles into a single map with keys `<metric>.<percentile>`.
  Map<String, double> flattenPercentiles() {
    final result = <String, double>{};
    for (final entry in percentiles.entries) {
      final metric = entry.key;
      for (final pctEntry in entry.value.entries) {
        result['$metric.${pctEntry.key}'] = pctEntry.value;
      }
    }
    return result;
  }
}

/// Generic collector for per-second RTC metrics with percentile summaries.
class RtcMetricsWindowAggregator<T> {
  static const _percentileKeys = [
    'p1',
    'p10',
    'p50',
    'p90',
    'p99',
  ];
  static const _percentileTargets = [1.0, 10.0, 50.0, 90.0, 99.0];

  /// Maximum samples to retain per metric to bound memory.
  final int maxSamples;

  final Map<String, ListQueue<double>> _series = {};
  final Map<String, num? Function(T)> _extractors;

  RtcMetricsWindowAggregator({
    required Map<String, num? Function(T)> extractors,
    this.maxSamples = 3 * 60 * 60,
  }) : _extractors = extractors;

  /// Collector configured for inbound per-second metrics.
  static RtcMetricsWindowAggregator<RtcVideoOutboundStats> outbound() {
    return RtcMetricsWindowAggregator<RtcVideoOutboundStats>(
      extractors: _outboundMetricExtractors,
    );
  }

  /// Add a new stats sample to the collector.
  void add(T stats) {
    _extractors.forEach((name, extractor) {
      final value = extractor(stats);
      if (value == null) {
        return;
      }
      final queue = _series.putIfAbsent(name, () => ListQueue<double>());
      queue.addLast(value.toDouble());
      if (queue.length > maxSamples) {
        queue.removeFirst();
      }
    });
  }

  /// Create a summary containing last values and percentiles for each metric.
  RtcMetricsSummary buildSummary() {
    final percentileValues = <String, Map<String, double>>{};

    for (final entry in _extractors.entries) {
      final metricName = entry.key;
      final data = _series[metricName]?.toList();
      if (data != null && data.isNotEmpty) {
        final percentiles = calculatePercentiles<double>(
            List<double>.from(data), _percentileTargets);
        percentileValues[metricName] = {
          for (var i = 0; i < _percentileKeys.length; i++)
            _percentileKeys[i]: percentiles[i],
        };
      } else {
        percentileValues[metricName] = {};
      }
    }

    return RtcMetricsSummary(
      percentiles: percentileValues,
    );
  }

  void clear() {
    _series.clear();
  }
}

// Inbound per-second metrics.
final Map<String, num? Function(RtcVideoOutboundStats)>
    _outboundMetricExtractors = {
  // Base numeric metrics
  'frameWidth': (s) => s.frameWidth,
  'frameHeight': (s) => s.frameHeight,
  'framesPerSecond': (s) => s.framesPerSecond,
  'mediaSourceFramesPerSecond': (s) => s.mediaSourceFramesPerSecond,
  'targetBitrate': (s) => s.targetBitrate,
  'availableOutgoingBitrate': (s) => s.availableOutgoingBitrate,
  'currentRoundTripTime': (s) => s.currentRoundTripTime,
  // Per-second counters
  'packetsSentPerSecond': (s) => s.packetsSentPerSecond,
  'bytesSentPerSecond': (s) => s.bytesSentPerSecond,
  'framesSentPerSecond': (s) => s.framesSentPerSecond,
  'framesEncodedPerSecond': (s) => s.framesEncodedPerSecond,
  'hugeFramesSentPerSecond': (s) => s.hugeFramesSentPerSecond,
  'keyFramesEncodedPerSecond': (s) => s.keyFramesEncodedPerSecond,
  'retransmittedPacketsSentPerSecond': (s) =>
      s.retransmittedPacketsSentPerSecond,
  'headerBytesSentPerSecond': (s) => s.headerBytesSentPerSecond,
  'retransmittedBytesSentPerSecond': (s) => s.retransmittedBytesSentPerSecond,
  'totalEncodedBytesTargetPerSecond': (s) => s.totalEncodedBytesTargetPerSecond,
  'totalEncodeTimePerSecond': (s) => s.totalEncodeTimePerSecond,
  'totalPacketSendDelayPerSecond': (s) => s.totalPacketSendDelayPerSecond,
  'qpSumPerSecond': (s) => s.qpSumPerSecond,
  'nackCountPerSecond': (s) => s.nackCountPerSecond,
  'firCountPerSecond': (s) => s.firCountPerSecond,
  'pliCountPerSecond': (s) => s.pliCountPerSecond,

  // Quality limitation duration breakdowns
  'qualityLimitationDurationsNone': (s) => s.qualityLimitationDurationsNone,
  'qualityLimitationDurationsCpu': (s) => s.qualityLimitationDurationsCpu,
  'qualityLimitationDurationsBandwith': (s) =>
      s.qualityLimitationDurationsBandwidth,
  'qualityLimitationDurationsOther': (s) => s.qualityLimitationDurationsOther,

  // Averages
  'qpSumAvg': (s) => s.qpSumAvg,
  'encodeTimeAvgMs': (s) => s.encodeTimeAvgMs,
  'packetSendDelayAvgMs': (s) => s.packetSendDelayAvgMs,
};
