import 'package:display_cast_flutter/model/rtc_stats.dart';

import 'app_analytics.dart';
import 'list_util.dart';

class RtcVideoOutboundStatsLists {
  List<double?> framesPerSecond;

  List<int?> framesSentPerSecond;
  List<int?> framesEncodedPerSecond;

  List<int?> bytesSentPerSecond;

  List<double?> packetSendDelayAvgMs;

  List<double?> encodeTimeAvgMs;

  RtcVideoOutboundStatsLists(
      {required this.framesPerSecond,
      required this.framesSentPerSecond,
      required this.framesEncodedPerSecond,
      required this.bytesSentPerSecond,
      required this.packetSendDelayAvgMs,
      required this.encodeTimeAvgMs});

  factory RtcVideoOutboundStatsLists.fromStatsList(
      List<RtcVideoOutboundStats> statsList) {
    List<double?> framesPerSecond = [];
    List<int?> framesSentPerSecond = [];
    List<int?> framesEncodedPerSecond = [];
    List<int?> bytesSentPerSecond = [];
    List<double?> packetSendDelayAvgMs = [];
    List<double?> encodeTimeAvgMs = [];

    for (var stats in statsList) {
      framesPerSecond.add(stats.framesPerSecond);
      framesSentPerSecond.add(stats.framesSentPerSecond);
      framesEncodedPerSecond.add(stats.framesEncodedPerSecond);
      bytesSentPerSecond.add(stats.bytesSentPerSecond);
      packetSendDelayAvgMs.add(stats.packetSendDelayAvgMs);
      encodeTimeAvgMs.add(stats.encodeTimeAvgMs);
    }

    return RtcVideoOutboundStatsLists(
      framesPerSecond: framesPerSecond,
      framesSentPerSecond: framesSentPerSecond,
      framesEncodedPerSecond: framesEncodedPerSecond,
      bytesSentPerSecond: bytesSentPerSecond,
      packetSendDelayAvgMs: packetSendDelayAvgMs,
      encodeTimeAvgMs: encodeTimeAvgMs,
    );
  }
}

void trackOutboundStats(
  List<RtcVideoOutboundStats> stats,
) {
  final statsLists = RtcVideoOutboundStatsLists.fromStatsList(stats);
  //  formats each double value to 2 precision
  const precision = 2;
  final packetSendDelayAvgMs =
      formatDoubleList(statsLists.packetSendDelayAvgMs, precision);
  final encodeTimeAvgMs = formatDoubleList(statsLists.encodeTimeAvgMs, precision);

  trackTrace('video_outbound_stats', properties: {
    'framesPerSecond': statsLists.framesPerSecond.join(','),
    'framesSentPerSecond': statsLists.framesSentPerSecond.join(','),
    'framesEncodedPerSecond': statsLists.framesEncodedPerSecond.join(','),
    'bytesSentPerSecond': statsLists.bytesSentPerSecond.join(','),
    'packetSendDelayAvgMs': packetSendDelayAvgMs.join(','),
    'encodeTimeAvgMs': encodeTimeAvgMs.join(','),
  });
}
