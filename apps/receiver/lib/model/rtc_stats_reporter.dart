import 'package:display_flutter/model/rtc_stats.dart';
import 'package:display_flutter/model/rtc_stats_parser.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class RtcStatsReporter implements RtcStatsSubscriber {
  final Function(String localCandidateType, String remoteCandidateType)
      _onPairCandidateType;

  final Function(RtcVideoInboundStats stats) _onVideoInboundStats;

  final Function(RtcIceCandidatePairStats stats) _onIceCandidatePairStats;

  RtcStatsReporter(
    this._onVideoInboundStats,
    this._onPairCandidateType,
    this._onIceCandidatePairStats,
  );

  @override
  void updateVideoStats(RtcVideoInboundStats stats) {
    _onVideoInboundStats(stats);
  }

  @override
  void pairCandidates(
      StatsReport localCandidateReport, StatsReport remoteCandidateReport) {
    final localCandidateType = localCandidateReport.values['candidateType'];
    final remoteCandidateType = remoteCandidateReport.values['candidateType'];

    if (localCandidateType != null && remoteCandidateType != null) {
      _onPairCandidateType.call(
          localCandidateType as String, remoteCandidateType as String);
    }
  }

  @override
  void selectedCandidatePair(StatsReport selectedCandidatePair) {
    final stats = RtcIceCandidatePairStats(
      currentRoundTripTime:
          selectedCandidatePair.values['currentRoundTripTime'],
      totalRoundTripTime: selectedCandidatePair.values['totalRoundTripTime'],
    );

    _onIceCandidatePairStats.call(stats);
  }

  @override
  void updateCandidatePairStats(StatsReport report) {
  }

  @override
  void updateCodecStats(StatsReport report) {
  }

  @override
  void updateLocalCandidate(List<StatsReport> reports) {
  }

  @override
  void updateRemoteCandidate(List<StatsReport> reports) {
  }
}
