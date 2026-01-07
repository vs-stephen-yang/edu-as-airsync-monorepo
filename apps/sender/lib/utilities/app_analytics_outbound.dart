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
  List<int?> packetsSentPerSecond;
  List<double?> headerBytesSentPerSecond;
  List<double?> retransmittedPacketsSentPerSecond;
  List<double?> retransmittedBytesSentPerSecond;
  List<double?> totalEncodedBytesTargetPerSecond;
  List<double?> totalEncodeTimePerSecond;
  List<double?> totalPacketSendDelayPerSecond;
  List<double?> qpSumPerSecond;
  List<int?> nackCountPerSecond;
  List<int?> firCountPerSecond;
  List<int?> pliCountPerSecond;

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
    required this.packetsSentPerSecond,
    required this.headerBytesSentPerSecond,
    required this.retransmittedPacketsSentPerSecond,
    required this.retransmittedBytesSentPerSecond,
    required this.totalEncodedBytesTargetPerSecond,
    required this.totalEncodeTimePerSecond,
    required this.totalPacketSendDelayPerSecond,
    required this.qpSumPerSecond,
    required this.nackCountPerSecond,
    required this.firCountPerSecond,
    required this.pliCountPerSecond,
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
    List<int?> packetsSentPerSecond = [];
    List<double?> headerBytesSentPerSecond = [];
    List<double?> retransmittedPacketsSentPerSecond = [];
    List<double?> retransmittedBytesSentPerSecond = [];
    List<double?> totalEncodedBytesTargetPerSecond = [];
    List<double?> totalEncodeTimePerSecond = [];
    List<double?> totalPacketSendDelayPerSecond = [];
    List<double?> qpSumPerSecond = [];
    List<int?> nackCountPerSecond = [];
    List<int?> firCountPerSecond = [];
    List<int?> pliCountPerSecond = [];
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
      packetsSentPerSecond.add(stats.packetsSentPerSecond);
      headerBytesSentPerSecond.add(stats.headerBytesSentPerSecond);
      retransmittedPacketsSentPerSecond
          .add(stats.retransmittedPacketsSentPerSecond);
      retransmittedBytesSentPerSecond
          .add(stats.retransmittedBytesSentPerSecond);
      totalEncodedBytesTargetPerSecond
          .add(stats.totalEncodedBytesTargetPerSecond);
      totalEncodeTimePerSecond.add(stats.totalEncodeTimePerSecond);
      totalPacketSendDelayPerSecond.add(stats.totalPacketSendDelayPerSecond);
      qpSumPerSecond.add(stats.qpSumPerSecond);
      nackCountPerSecond.add(stats.nackCountPerSecond);
      firCountPerSecond.add(stats.firCountPerSecond);
      pliCountPerSecond.add(stats.pliCountPerSecond);
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
      packetsSentPerSecond: packetsSentPerSecond,
      headerBytesSentPerSecond: headerBytesSentPerSecond,
      retransmittedPacketsSentPerSecond: retransmittedPacketsSentPerSecond,
      retransmittedBytesSentPerSecond: retransmittedBytesSentPerSecond,
      totalEncodedBytesTargetPerSecond: totalEncodedBytesTargetPerSecond,
      totalEncodeTimePerSecond: totalEncodeTimePerSecond,
      totalPacketSendDelayPerSecond: totalPacketSendDelayPerSecond,
      qpSumPerSecond: qpSumPerSecond,
      nackCountPerSecond: nackCountPerSecond,
      firCountPerSecond: firCountPerSecond,
      pliCountPerSecond: pliCountPerSecond,
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
  final headerBytesSentPerSecond =
      formatDoubleList(statsLists.headerBytesSentPerSecond, precision);
  final retransmittedPacketsSentPerSecond = formatDoubleList(
      statsLists.retransmittedPacketsSentPerSecond, precision);
  final retransmittedBytesSentPerSecond = formatDoubleList(
      statsLists.retransmittedBytesSentPerSecond, precision);
  final totalEncodedBytesTargetPerSecond = formatDoubleList(
      statsLists.totalEncodedBytesTargetPerSecond, precision);
  final totalEncodeTimePerSecond =
      formatDoubleList(statsLists.totalEncodeTimePerSecond, precision);
  final totalPacketSendDelayPerSecond = formatDoubleList(
      statsLists.totalPacketSendDelayPerSecond, precision);
  final qpSumPerSecond =
      formatDoubleList(statsLists.qpSumPerSecond, precision);

  trackTrace('video_outbound_stats', properties: {
    'framesPerSecond': statsLists.framesPerSecond.join(','),
    'framesSentPerSecond': statsLists.framesSentPerSecond.join(','),
    'framesEncodedPerSecond': statsLists.framesEncodedPerSecond.join(','),
    'packetsSentPerSecond': statsLists.packetsSentPerSecond.join(','),
    'bytesSentPerSecond': statsLists.bytesSentPerSecond.join(','),
    'hugeFramesSentPerSecond': statsLists.hugeFramesSentPerSecond.join(','),
    'keyFramesEncodedPerSecond': statsLists.keyFramesEncodedPerSecond.join(','),
    'headerBytesSentPerSecond': headerBytesSentPerSecond.join(','),
    'retransmittedPacketsSentPerSecond':
        retransmittedPacketsSentPerSecond.join(','),
    'retransmittedBytesSentPerSecond':
        retransmittedBytesSentPerSecond.join(','),
    'totalEncodedBytesTargetPerSecond':
        totalEncodedBytesTargetPerSecond.join(','),
    'totalEncodeTimePerSecond': totalEncodeTimePerSecond.join(','),
    'totalPacketSendDelayPerSecond': totalPacketSendDelayPerSecond.join(','),
    'qpSumPerSecond': qpSumPerSecond.join(','),
    'nackCountPerSecond': statsLists.nackCountPerSecond.join(','),
    'firCountPerSecond': statsLists.firCountPerSecond.join(','),
    'pliCountPerSecond': statsLists.pliCountPerSecond.join(','),
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
