import 'package:display_cast_flutter/model/rtc_stats.dart';
import 'package:display_cast_flutter/model/rtc_stats_parser.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class RtcStatsReporter implements RtcStatsSubscriber {
  Function(RtcVideoOutboundStats stats)? onVideoOutboundStats;

  RtcStatsReporter(this.onVideoOutboundStats);

  @override
  void updateVideoStats(RtcVideoOutboundStats stats) {
    onVideoOutboundStats?.call(stats);
  }

  @override
  void updateCandidatePairStats(StatsReport report) {}

  @override
  void updateCodecStats(StatsReport report) {}

  @override
  void updateLocalCandidate(List<StatsReport> reports) {}

  @override
  void updateRemoteCandidate(List<StatsReport> reports) {}
}
