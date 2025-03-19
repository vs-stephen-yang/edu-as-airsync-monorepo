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

      _reporter?.pairCandidates(
          localCandidates.firstWhere(
              (StatsReport report) => report.id == localCandidateId),
          remoteCandidates.firstWhere(
            (StatsReport report) => report.id == remoteCandidateId));

      if (selectedCandidatePair != null) {
        _reporter?.selectedCandidatePair(selectedCandidatePair);
      }
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
