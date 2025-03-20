import 'package:display_flutter/model/rtc_stats.dart';
import 'package:display_flutter/model/rtc_stats_presenter.dart';
import 'package:display_flutter/model/rtc_stats_reporter.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

int? _diff(int? a, int? b) {
  if (a == null || b == null) {
    return null;
  }
  return a - b;
}

double? _avg(double? a, double? b, int? c, int? d) {
  if (a == null || b == null || c == null || d == null) {
    return null;
  }
  if (c == d) {
    return null;
  }
  return (a - b) / (c - d);
}

class RtcStatsParser {
  RtcStatsReporter? _reporter;
  RtcStatsPresenter? _presenter;

  void setReporter(RtcStatsReporter reporter) {
    _reporter = reporter;
  }

  void setPresenter(RtcStatsPresenter presenter) {
    _presenter = presenter;
  }

  RtcStatsReporter? get reporter => _reporter;
  RtcStatsPresenter? get presenter => _presenter;

  // the stats values in the last report
  int? _framesReceived;
  int? _framesDecoded;
  int? _framesDropped;

  int? _jitterBufferEmittedCount;
  double? _jitterBufferDelay;

  double? _totalDecodeTime;
  int? _bytesReceived;

  RtcStatsParser();

  void onStatsReports(List<StatsReport> reports) {
    try {
      _onStatsReports(reports);
    } catch (e, stacktrace) {
      log.warning('onStatsReports', e, stacktrace);
    }
  }

  void _onStatsReports(List<StatsReport> reports) {
    // Create maps for different report types
    final reportsByType = <String, List<StatsReport>>{};

    // Categorize reports by type
    for (final report in reports) {
      reportsByType.putIfAbsent(report.type, () => []).add(report);
    }

    for (var report in reportsByType['codec'] ?? []) {
      presenter?.addCodecStats(report);
    }

    // Create candidate pair map
    final candidatePairMap = <String, StatsReport>{};

    for (var report in reportsByType['candidate-pair'] ?? []) {
      candidatePairMap[report.id] = report;
      presenter?.addCandidatePairStats(report);
    }

    final localCandidates = reportsByType['local-candidate'] ?? [];
    final remoteCandidates = reportsByType['remote-candidate'] ?? [];

    presenter?.addLocalCandidate(localCandidates);
    presenter?.addRemoteCandidate(remoteCandidates);

    // Process transports
    final transports = reportsByType['transport'] ?? [];
    final bytesSent = _findFirstValueForKey(transports, 'bytesSent');

    if (bytesSent != null && bytesSent != 0) {
      final selectedCandidatePairId =
          _findFirstValueForKey(transports, 'selectedCandidatePairId');

      final selectedCandidatePair = candidatePairMap[selectedCandidatePairId];

      if (selectedCandidatePair != null) {
        final localCandidateId =
            selectedCandidatePair.values['localCandidateId'];
        final remoteCandidateId =
            selectedCandidatePair.values['remoteCandidateId'];

        _reporter?.pairCandidates(
            localCandidates.firstWhere(
                (StatsReport report) => report.id == localCandidateId),
            remoteCandidates.firstWhere(
                (StatsReport report) => report.id == remoteCandidateId));

        _reporter?.selectedCandidatePair(selectedCandidatePair);
      }
    }

    // Process video inbound-rtp
    final inboundRtps = reportsByType['inbound-rtp'] ?? [];
    final videoInboundRtps = inboundRtps
        .where((StatsReport report) => report.values['kind'] == 'video')
        .toList();

    _onVideoStatsReports(videoInboundRtps);
  }

  // Helper method to get the first non-null value from a list of reports
  dynamic _findFirstValueForKey(List<StatsReport> reports, String key) {
    for (final report in reports) {
      final value = report.values[key];
      if (value != null) {
        return value;
      }
    }
    return null;
  }

  void _onVideoStatsReports(List<StatsReport> reports) {
    if (reports.isEmpty) {
      return;
    }

    final videoInboundRtp = reports.first;

    final jitterBufferEmittedCount =
    videoInboundRtp.values['jitterBufferEmittedCount'];
    final jitterBufferDelay = videoInboundRtp.values['jitterBufferDelay'];
    final framesReceived = videoInboundRtp.values['framesReceived'];
    final framesDecoded = videoInboundRtp.values['framesDecoded'];
    final framesDropped = videoInboundRtp.values['framesDropped'];
    final totalDecodeTime = videoInboundRtp.values['totalDecodeTime'];

    final stats = RtcVideoInboundStats(
      decoderName: videoInboundRtp.values['decoderImplementation'],
      frameWidth: videoInboundRtp.values['frameWidth'],
      frameHeight: videoInboundRtp.values['frameHeight'],
      framesPerSecond: videoInboundRtp.values['framesPerSecond'],
      framesReceivedPerSecond: _diff(framesReceived, _framesReceived),
      framesDecodedPerSecond: _diff(framesDecoded, _framesDecoded),
      framesDroppedPerSecond: _diff(framesDropped, _framesDropped),
      bytesPerSecond:
          _diff(videoInboundRtp.values['bytesReceived'], _bytesReceived),
      bytesReceived: videoInboundRtp.values['bytesReceived'],
      packetsLost: videoInboundRtp.values['packetsLost'],
      packetsReceived: videoInboundRtp.values['packetsReceived'],
      jitter: videoInboundRtp.values['jitter'],
      pauseCount: videoInboundRtp.values['pauseCount'],
      jitterBufferDelay: _avg(
        jitterBufferDelay,
        _jitterBufferDelay,
        jitterBufferEmittedCount,
        _jitterBufferEmittedCount,
      ),
      decodeTime: _avg(
        totalDecodeTime,
        _totalDecodeTime,
        framesDecoded,
        _framesDecoded,
      ),
    );

    _reporter?.videoInboundStats(stats);

    final statsForPresent = RtcVideoInboundStatsForPresenter(
        stats,
        powerEfficientDecoder: videoInboundRtp.values['powerEfficientDecoder'],
        qpSum: videoInboundRtp.values['qpSum'],
        timestamp: videoInboundRtp.timestamp,
    );
    _presenter?.addVideoStats(statsForPresent);

    // update
    _framesReceived = framesReceived;
    _framesDecoded = framesDecoded;
    _framesDropped = framesDropped;
    _totalDecodeTime = totalDecodeTime;
    _bytesReceived = stats.bytesReceived;
    _jitterBufferEmittedCount = jitterBufferEmittedCount;
    _jitterBufferDelay = jitterBufferDelay;
  }
}
