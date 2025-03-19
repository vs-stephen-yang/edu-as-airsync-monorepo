import 'package:display_flutter/model/rtc_stats.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class RtcStatsReporter {
  final Function(String localCandidateType, String remoteCandidateType)
      _onPairCandidateType;

  final Function(RtcVideoInboundStats stats) _onVideoInboundStats;

  final Function(RtcIceCandidatePairStats stats) _onIceCandidatePairStats;

  RtcStatsReporter(
    this._onVideoInboundStats,
    this._onPairCandidateType,
    this._onIceCandidatePairStats,
  );

  void videoInboundStats(RtcVideoInboundStats stats) {
    _onVideoInboundStats(stats);
  }

  void pairCandidates(
      StatsReport localCandidateReport, StatsReport remoteCandidateReport) {
    final localCandidateType = localCandidateReport.values['candidateType'];
    final remoteCandidateType = remoteCandidateReport.values['candidateType'];

    if (localCandidateType != null && remoteCandidateType != null) {
      _onPairCandidateType.call(
          localCandidateType as String, remoteCandidateType as String);
    }
  }

  void selectedCandidatePair(StatsReport selectedCandidatePair) {
    final stats = RtcIceCandidatePairStats(
      currentRoundTripTime:
          selectedCandidatePair.values['currentRoundTripTime'],
      totalRoundTripTime: selectedCandidatePair.values['totalRoundTripTime'],
    );

    _onIceCandidatePairStats.call(stats);
  }
}
