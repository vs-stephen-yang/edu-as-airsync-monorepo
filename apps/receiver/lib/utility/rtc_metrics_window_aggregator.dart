import 'package:display_flutter/model/rtc_stats.dart';
import 'package:display_flutter/utility/math_util.dart';

/// Summary of per-second RTC metrics.
class RtcMetricsWindowSummary {
  /// Percentiles for each metric keyed by percentile name (e.g. p1, p50).
  final Map<String, Map<String, double>> percentiles;

  RtcMetricsWindowSummary({
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

  final Map<String, List<double>> _series = {};
  final Map<String, num? Function(T)> _extractors;

  RtcMetricsWindowAggregator({
    required Map<String, num? Function(T)> extractors,
    this.maxSamples = 3 * 60 * 60,
  }) : _extractors = extractors;

  /// Collector configured for inbound per-second metrics.
  static RtcMetricsWindowAggregator<RtcVideoInboundStats> inbound() {
    return RtcMetricsWindowAggregator<RtcVideoInboundStats>(
      extractors: _inboundMetricExtractors,
    );
  }

  /// Add a new stats sample to the collector.
  void add(T stats) {
    _extractors.forEach((name, extractor) {
      final value = extractor(stats);
      if (value == null) {
        return;
      }
      final list = _series.putIfAbsent(name, () => []);
      list.add(value.toDouble());
      if (list.length > maxSamples) {
        list.removeAt(0);
      }
    });
  }

  /// Create a summary containing last values and percentiles for each metric.
  RtcMetricsWindowSummary buildSummary() {
    final percentileValues = <String, Map<String, double>>{};

    for (final entry in _extractors.entries) {
      final metricName = entry.key;
      final data = _series[metricName];
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

    return RtcMetricsWindowSummary(
      percentiles: percentileValues,
    );
  }

  void clear() {
    _series.clear();
  }
}

// Inbound per-second metrics.
final Map<String, num? Function(RtcVideoInboundStats)>
    _inboundMetricExtractors = {
  // Base numeric metrics
  'frameWidth': (s) => s.frameWidth,
  'frameHeight': (s) => s.frameHeight,
  'framesPerSecond': (s) => s.framesPerSecond,
  'jitter': (s) => s.jitter,
  'audioLevel': (s) => s.audioLevel,
  'packetsReceivedPerSecond': (s) => s.packetsReceivedPerSecond,
  'packetsLostPerSecond': (s) => s.packetsLostPerSecond,
  'packetsDiscardedPerSecond': (s) => s.packetsDiscardedPerSecond,
  'fecBytesReceivedPerSecond': (s) => s.fecBytesReceivedPerSecond,
  'fecPacketsReceivedPerSecond': (s) => s.fecPacketsReceivedPerSecond,
  'fecPacketsDiscardedPerSecond': (s) => s.fecPacketsDiscardedPerSecond,
  'retransmittedPacketsReceivedPerSecond': (s) =>
      s.retransmittedPacketsReceivedPerSecond,
  'retransmittedBytesReceivedPerSecond': (s) =>
      s.retransmittedBytesReceivedPerSecond,
  'framesDecodedPerSecond': (s) => s.framesDecodedPerSecond,
  'framesRenderedPerSecond': (s) => s.framesRenderedPerSecond,
  'framesDroppedPerSecond': (s) => s.framesDroppedPerSecond,
  'framesReceivedPerSecond': (s) => s.framesReceivedPerSecond,
  'framesAssembledFromMultiplePacketsPerSecond': (s) =>
      s.framesAssembledFromMultiplePacketsPerSecond,
  'keyFramesDecodedPerSecond': (s) => s.keyFramesDecodedPerSecond,
  'nackCountPerSecond': (s) => s.nackCountPerSecond,
  'firCountPerSecond': (s) => s.firCountPerSecond,
  'pliCountPerSecond': (s) => s.pliCountPerSecond,
  'bytesReceivedPerSecond': (s) => s.bytesReceivedPerSecond,
  'bytesPerSecond': (s) => s.bytesPerSecond,
  'headerBytesReceivedPerSecond': (s) => s.headerBytesReceivedPerSecond,
  'headerBytesPerSecond': (s) => s.headerBytesPerSecond,
  'qpSumPerSecond': (s) => s.qpSumPerSecond,
  'totalDecodeTimePerSecond': (s) => s.totalDecodeTimePerSecond,
  'totalInterFrameDelayPerSecond': (s) => s.totalInterFrameDelayPerSecond,
  'totalSquaredInterFrameDelayPerSecond': (s) =>
      s.totalSquaredInterFrameDelayPerSecond,
  'pauseCountPerSecond': (s) => s.pauseCountPerSecond,
  'totalPausesDurationPerSecond': (s) => s.totalPausesDurationPerSecond,
  'freezeCountPerSecond': (s) => s.freezeCountPerSecond,
  'totalFreezesDurationPerSecond': (s) => s.totalFreezesDurationPerSecond,
  'totalProcessingDelayPerSecond': (s) => s.totalProcessingDelayPerSecond,
  'jitterBufferDelayPerSecond': (s) => s.jitterBufferDelayPerSecond,
  'jitterBufferTargetDelayPerSecond': (s) => s.jitterBufferTargetDelayPerSecond,
  'jitterBufferMinimumDelayPerSecond': (s) =>
      s.jitterBufferMinimumDelayPerSecond,
  'jitterBufferEmittedCountPerSecond': (s) =>
      s.jitterBufferEmittedCountPerSecond,
  'totalAssemblyTimePerSecond': (s) => s.totalAssemblyTimePerSecond,
  'totalAudioEnergyPerSecond': (s) => s.totalAudioEnergyPerSecond,
  'totalSamplesDurationPerSecond': (s) => s.totalSamplesDurationPerSecond,
  'totalSamplesReceivedPerSecond': (s) => s.totalSamplesReceivedPerSecond,
  'concealedSamplesPerSecond': (s) => s.concealedSamplesPerSecond,
  'silentConcealedSamplesPerSecond': (s) => s.silentConcealedSamplesPerSecond,
  'concealmentEventsPerSecond': (s) => s.concealmentEventsPerSecond,
  'insertedSamplesForDecelerationPerSecond': (s) =>
      s.insertedSamplesForDecelerationPerSecond,
  'removedSamplesForAccelerationPerSecond': (s) =>
      s.removedSamplesForAccelerationPerSecond,
  'totalCorruptionProbabilityPerSecond': (s) =>
      s.totalCorruptionProbabilityPerSecond,
  'totalSquaredCorruptionProbabilityPerSecond': (s) =>
      s.totalSquaredCorruptionProbabilityPerSecond,
  'corruptionMeasurementsPerSecond': (s) => s.corruptionMeasurementsPerSecond,
  // Averages
  'decodeTime': (s) => s.decodeTime,
  'totalInterFrameDelayAvg': (s) => s.totalInterFrameDelayAvg,
  'totalAssemblyTimeAvg': (s) => s.totalAssemblyTimeAvg,
  'jitterBufferDelayAvg': (s) => s.jitterBufferDelayAvg,
  'qpSumAvg': (s) => s.qpSumAvg,
};
