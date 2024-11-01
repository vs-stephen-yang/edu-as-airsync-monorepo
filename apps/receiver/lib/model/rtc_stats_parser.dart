import 'package:display_flutter/model/rtc_stats.dart';
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
  Function(String localCandidateType, String remoteCandidateType)?
      onPairCandidateType;

  Function(RtcVideoInboundStats stats)? onVideoInboundStats;

  // the stats values in the last report
  int? _framesReceived;
  int? _framesDecoded;
  int? _framesDropped;

  int? _jitterBufferEmittedCount;
  double? _jitterBufferDelay;

  double? _totalDecodeTime;
  int? _bytesReceived;

  RtcStatsParser(
    this.onVideoInboundStats,
    this.onPairCandidateType,
  );

  void onStatsReports(List<StatsReport> reports) {
    try {
      _onStatsReports(reports);
    } catch (e, stacktrace) {
      log.severe('onStatsReports', e, stacktrace);
    }
  }

  void _onStatsReports(List<StatsReport> reports) {
    // create Map from candidate-pair reports
    final candidatePairs = reports
        .where((StatsReport report) => report.type == 'candidate-pair')
        .toList();
    final candidatePairMap = {
      for (var report in candidatePairs) report.id: report
    };

    // get active transport
    final transports = reports
        .where((StatsReport report) => report.type == 'transport')
        .toList();
    final bytesSend = transports
        .map((StatsReport report) => report.values['bytesSent'])
        .firstWhere((value) => value != null, orElse: () => null);

    if (bytesSend != null && bytesSend != 0) {
      // get selectedCandidatePairId
      final selectedCandidatePairId = transports
          .map((StatsReport report) => report.values['selectedCandidatePairId'])
          .firstWhere((value) => value != null, orElse: () => null);

      // get selected candidate pair
      final selectedCandidatePair = candidatePairMap[selectedCandidatePairId];

      // get local and remote candidate id
      final localCandidateId =
          selectedCandidatePair?.values['localCandidateId'];
      final remoteCandidateId =
          selectedCandidatePair?.values['remoteCandidateId'];

      // find selected local and remote candidate reports
      final localCandidates = reports
          .where((StatsReport report) => report.type == 'local-candidate')
          .toList();
      final remoteCandidates = reports
          .where((StatsReport report) => report.type == 'remote-candidate')
          .toList();

      _onPairCandidatesReports(
          localCandidates.firstWhere(
              (StatsReport report) => report.id == localCandidateId),
          remoteCandidates.firstWhere(
              (StatsReport report) => report.id == remoteCandidateId));
    }

    // find video inbound-rtp reports
    final inboundRtps = reports
        .where((StatsReport report) => report.type == 'inbound-rtp')
        .toList();
    final videoInboundRtps = inboundRtps
        .where((StatsReport report) => report.values['kind'] == 'video')
        .toList();

    _onVideoStatsReports(videoInboundRtps);
  }

  void _onPairCandidatesReports(
      StatsReport localCandidateReport, StatsReport remoteCandidateReport) {
    final localCandidateType = localCandidateReport.values['candidateType'];
    final remoteCandidateType = remoteCandidateReport.values['candidateType'];
    if (localCandidateType != null && remoteCandidateType != null) {
      onPairCandidateType?.call(
          localCandidateType as String, remoteCandidateType as String);
    }
  }

  void _onVideoStatsReports(List<StatsReport> reports) {
    if (reports.isEmpty) {
      return;
    }

    final videoInboundRtp = reports.first;
    final stats = RtcVideoInboundStats();

    stats.decoderName = videoInboundRtp.values['decoderImplementation'];
    stats.packetsLost = videoInboundRtp.values['packetsLost'];
    stats.packetsReceived = videoInboundRtp.values['packetsReceived'];
    stats.jitter = videoInboundRtp.values['jitter'];
    stats.pauseCount = videoInboundRtp.values['pauseCount'];

    stats.framesPerSecond = videoInboundRtp.values['framesPerSecond'];

    stats.frameWidth = videoInboundRtp.values['frameWidth'];
    stats.frameHeight = videoInboundRtp.values['frameHeight'];

    final jitterBufferEmittedCount =
        videoInboundRtp.values['jitterBufferEmittedCount'];
    final jitterBufferDelay = videoInboundRtp.values['jitterBufferDelay'];

    final framesReceived = videoInboundRtp.values['framesReceived'];
    final framesDecoded = videoInboundRtp.values['framesDecoded'];

    final framesDropped = videoInboundRtp.values['framesDropped'];

    final totalDecodeTime = videoInboundRtp.values['totalDecodeTime'];

    final bytesReceived = videoInboundRtp.values['bytesReceived'];

    stats.bytesPerSecond = _diff(bytesReceived, _bytesReceived);

    stats.framesReceivedPerSecond = _diff(framesReceived, _framesReceived);

    stats.framesDecodedPerSecond = _diff(framesDecoded, _framesDecoded);

    stats.framesDroppedPerSecond = _diff(framesDropped, _framesDropped);

    stats.decodeTime = _avg(
      totalDecodeTime,
      _totalDecodeTime,
      framesDecoded,
      _framesDecoded,
    );

    stats.jitterBufferDelay = _avg(
      jitterBufferDelay,
      _jitterBufferDelay,
      jitterBufferEmittedCount,
      _jitterBufferEmittedCount,
    );

    onVideoInboundStats?.call(stats);

    // update
    _framesReceived = framesReceived;
    _framesDecoded = framesDecoded;
    _framesDropped = framesDropped;

    _totalDecodeTime = totalDecodeTime;

    _bytesReceived = bytesReceived;

    _jitterBufferEmittedCount = jitterBufferEmittedCount;
    _jitterBufferDelay = jitterBufferDelay;
  }
}
