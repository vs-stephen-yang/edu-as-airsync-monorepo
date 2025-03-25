import 'package:display_cast_flutter/model/rtc_stats.dart';
import 'package:display_cast_flutter/model/rtc_stats_parser.dart';

class RtcStatsReporter implements RtcStatsSubscriber {

  Function(RtcVideoOutboundStats stats)? onVideoOutboundStats;

  RtcStatsReporter(this.onVideoOutboundStats);

  @override
  void onVideoStatsReports(RtcVideoOutboundStats stats) {
    onVideoOutboundStats?.call(stats);
  }
}