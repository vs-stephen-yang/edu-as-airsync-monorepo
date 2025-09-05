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
  List<int?> keyFramesEncodedPerSecond;

  List<double?> packetSendDelayAvgMs;
  List<double?> encodeTimeAvgMs;
  List<double?> qpSumAvg;

  List<double?> targetBitrate;
  List<double?> availableOutgoingBitrate;

  String? encoderImplementation;

  RtcVideoOutboundStatsLists({
    required this.framesPerSecond,
    required this.framesSentPerSecond,
    required this.framesEncodedPerSecond,
    required this.bytesSentPerSecond,
    required this.keyFramesEncodedPerSecond,
    required this.packetSendDelayAvgMs,
    required this.encodeTimeAvgMs,
    required this.qpSumAvg,
    required this.targetBitrate,
    required this.hugeFramesSentPerSecond,
    required this.availableOutgoingBitrate,
    required this.mediaSourceFramesPerSecond,
    required this.encoderImplementation,
  });

  factory RtcVideoOutboundStatsLists.fromStatsList(
      List<RtcVideoOutboundStats> statsList) {
    List<double?> framesPerSecond = [];
    List<double?> mediaSourceFramesPerSecond = [];
    List<int?> framesSentPerSecond = [];
    List<int?> framesEncodedPerSecond = [];
    List<int?> bytesSentPerSecond = [];
    List<int?> hugeFramesSentPerSecond = [];
    List<int?> keyFramesEncodedPerSecond = [];
    List<double?> packetSendDelayAvgMs = [];
    List<double?> encodeTimeAvgMs = [];
    List<double?> qpSumAvg = [];
    List<double?> targetBitrate = [];
    List<double?> availableOutgoingBitrate = [];
    String? encoderImplementation;

    for (var stats in statsList) {
      framesPerSecond.add(stats.framesPerSecond);
      framesSentPerSecond.add(stats.framesSentPerSecond);
      framesEncodedPerSecond.add(stats.framesEncodedPerSecond);
      bytesSentPerSecond.add(stats.bytesSentPerSecond);
      hugeFramesSentPerSecond.add(stats.hugeFramesSentPerSecond);
      keyFramesEncodedPerSecond.add(stats.keyFramesEncodedPerSecond);
      mediaSourceFramesPerSecond.add(stats.mediaSourceFramesPerSecond);
      packetSendDelayAvgMs.add(stats.packetSendDelayAvgMs);
      encodeTimeAvgMs.add(stats.encodeTimeAvgMs);
      qpSumAvg.add(stats.qpSumAvg);
      targetBitrate.add(stats.targetBitrate);
      availableOutgoingBitrate.add(stats.availableOutgoingBitrate);
      encoderImplementation = stats.encoderImplementation;
    }

    return RtcVideoOutboundStatsLists(
      framesPerSecond: framesPerSecond,
      framesSentPerSecond: framesSentPerSecond,
      framesEncodedPerSecond: framesEncodedPerSecond,
      bytesSentPerSecond: bytesSentPerSecond,
      hugeFramesSentPerSecond: hugeFramesSentPerSecond,
      keyFramesEncodedPerSecond: keyFramesEncodedPerSecond,
      mediaSourceFramesPerSecond: mediaSourceFramesPerSecond,
      packetSendDelayAvgMs: packetSendDelayAvgMs,
      encodeTimeAvgMs: encodeTimeAvgMs,
      qpSumAvg: qpSumAvg,
      targetBitrate: targetBitrate,
      availableOutgoingBitrate: availableOutgoingBitrate,
      encoderImplementation: encoderImplementation,
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
    'keyFramesEncodedPerSecond': statsLists.keyFramesEncodedPerSecond.join(','),
    'mediaSourceFramesPerSecond':
        statsLists.mediaSourceFramesPerSecond.join(','),
    'packetSendDelayAvgMs': packetSendDelayAvgMs.join(','),
    'encodeTimeAvgMs': encodeTimeAvgMs.join(','),
    'qpSumAvg': statsLists.qpSumAvg.join(','),
    'targetBitrate': statsLists.targetBitrate.join(','),
    'availableOutgoingBitrate': statsLists.availableOutgoingBitrate.join(','),
    'encoderImplementation': statsLists.encoderImplementation ?? '',
  });
}
