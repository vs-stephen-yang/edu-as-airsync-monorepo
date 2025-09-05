import 'package:display_cast_flutter/model/rtc_stats.dart';

import 'app_analytics.dart';
import 'list_util.dart';

class RtcVideoOutboundStatsLists {
  List<double?> framesPerSecond;
  List<double?> mediaSourceFramesPerSecond;

  List<int?> framesSentPerSecond;
  List<int?> framesEncodedPerSecond;
  List<int?> hugeFramesSentPerSecond;
  List<int?> bytesSentPerSecond;

  List<double?> packetSendDelayAvgMs;
  List<double?> encodeTimeAvgMs;
  List<double?> qpSumAvg;

  double? targetBitrate;
  double? availableOutgoingBitrate;

  RtcVideoOutboundStatsLists({
    required this.framesPerSecond,
    required this.framesSentPerSecond,
    required this.framesEncodedPerSecond,
    required this.bytesSentPerSecond,
    required this.packetSendDelayAvgMs,
    required this.encodeTimeAvgMs,
    required this.qpSumAvg,
    required this.targetBitrate,
    required this.hugeFramesSentPerSecond,
    required this.availableOutgoingBitrate,
    required this.mediaSourceFramesPerSecond,
  });

  factory RtcVideoOutboundStatsLists.fromStatsList(
      List<RtcVideoOutboundStats> statsList) {
    List<double?> framesPerSecond = [];
    List<double?> mediaSourceFramesPerSecond = [];
    List<int?> framesSentPerSecond = [];
    List<int?> framesEncodedPerSecond = [];
    List<int?> bytesSentPerSecond = [];
    List<int?> hugeFramesSentPerSecond = [];
    List<double?> packetSendDelayAvgMs = [];
    List<double?> encodeTimeAvgMs = [];
    List<double?> qpSumAvg = [];
    double? targetBitrate;
    double? availableOutgoingBitrate;

    for (var stats in statsList) {
      framesPerSecond.add(stats.framesPerSecond);
      framesSentPerSecond.add(stats.framesSentPerSecond);
      framesEncodedPerSecond.add(stats.framesEncodedPerSecond);
      bytesSentPerSecond.add(stats.bytesSentPerSecond);
      hugeFramesSentPerSecond.add(stats.hugeFramesSentPerSecond);
      mediaSourceFramesPerSecond.add(stats.mediaSourceFramesPerSecond);
      packetSendDelayAvgMs.add(stats.packetSendDelayAvgMs);
      encodeTimeAvgMs.add(stats.encodeTimeAvgMs);
      qpSumAvg.add(stats.qpSumAvg);
      targetBitrate = stats.targetBitrate;
      availableOutgoingBitrate = stats.availableOutgoingBitrate;
    }

    return RtcVideoOutboundStatsLists(
      framesPerSecond: framesPerSecond,
      framesSentPerSecond: framesSentPerSecond,
      framesEncodedPerSecond: framesEncodedPerSecond,
      bytesSentPerSecond: bytesSentPerSecond,
      hugeFramesSentPerSecond: hugeFramesSentPerSecond,
      mediaSourceFramesPerSecond: mediaSourceFramesPerSecond,
      packetSendDelayAvgMs: packetSendDelayAvgMs,
      encodeTimeAvgMs: encodeTimeAvgMs,
      qpSumAvg: qpSumAvg,
      targetBitrate: targetBitrate,
      availableOutgoingBitrate: availableOutgoingBitrate,
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
  final encodeTimeAvgMs =
      formatDoubleList(statsLists.encodeTimeAvgMs, precision);

  trackTrace('video_outbound_stats', properties: {
    'framesPerSecond': statsLists.framesPerSecond.join(','),
    'framesSentPerSecond': statsLists.framesSentPerSecond.join(','),
    'framesEncodedPerSecond': statsLists.framesEncodedPerSecond.join(','),
    'bytesSentPerSecond': statsLists.bytesSentPerSecond.join(','),
    'hugeFramesSentPerSecond': statsLists.hugeFramesSentPerSecond.join(','),
    'mediaSourceFramesPerSecond':
        statsLists.mediaSourceFramesPerSecond.join(','),
    'packetSendDelayAvgMs': packetSendDelayAvgMs.join(','),
    'encodeTimeAvgMs': encodeTimeAvgMs.join(','),
    'qpSumAvg': statsLists.qpSumAvg.join(','),
    'targetBitrate': statsLists.targetBitrate ?? 0.0,
    'availableOutgoingBitrate': statsLists.availableOutgoingBitrate ?? 0.0,
  });
}
