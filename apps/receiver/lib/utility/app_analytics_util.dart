import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/model/rtc_stats.dart';

import 'list_util.dart';

class RtcVideoInboundStatsLists {
  List<double?> framesPerSecond;

  List<int?> framesReceivedPerSecond;
  List<int?> framesDecodedPerSecond;
  List<int?> framesDroppedPerSecond;

  List<int?> bytesPerSecond;

  List<int?> packetsLost;
  List<int?> packetsReceived;
  List<double?> jitter;
  List<int?> pauseCount;

  List<double?> jitterBufferDelay;

  List<double?> decodeTime;

  RtcVideoInboundStatsLists({
    required this.framesPerSecond,
    required this.framesReceivedPerSecond,
    required this.framesDecodedPerSecond,
    required this.framesDroppedPerSecond,
    required this.bytesPerSecond,
    required this.packetsLost,
    required this.packetsReceived,
    required this.jitter,
    required this.pauseCount,
    required this.jitterBufferDelay,
    required this.decodeTime,
  });

  factory RtcVideoInboundStatsLists.fromStatsList(
      List<RtcVideoInboundStats> statsList) {
    List<double?> framesPerSecond = [];
    List<int?> framesReceivedPerSecond = [];
    List<int?> framesDecodedPerSecond = [];
    List<int?> framesDroppedPerSecond = [];
    List<int?> bytesPerSecond = [];
    List<int?> packetsLost = [];
    List<int?> packetsReceived = [];
    List<double?> jitter = [];
    List<int?> pauseCount = [];
    List<double?> jitterBufferDelay = [];
    List<double?> decodeTime = [];

    for (var stats in statsList) {
      framesPerSecond.add(stats.framesPerSecond);
      framesReceivedPerSecond.add(stats.framesReceivedPerSecond);
      framesDecodedPerSecond.add(stats.framesDecodedPerSecond);
      framesDroppedPerSecond.add(stats.framesDroppedPerSecond);
      bytesPerSecond.add(stats.bytesPerSecond);
      packetsLost.add(stats.packetsLost);
      packetsReceived.add(stats.packetsReceived);
      jitter.add(stats.jitter);
      pauseCount.add(stats.pauseCount);
      jitterBufferDelay.add(stats.jitterBufferDelay);
      decodeTime.add(stats.decodeTime);
    }

    return RtcVideoInboundStatsLists(
      framesPerSecond: framesPerSecond,
      framesReceivedPerSecond: framesReceivedPerSecond,
      framesDecodedPerSecond: framesDecodedPerSecond,
      framesDroppedPerSecond: framesDroppedPerSecond,
      bytesPerSecond: bytesPerSecond,
      packetsLost: packetsLost,
      packetsReceived: packetsReceived,
      jitter: jitter,
      pauseCount: pauseCount,
      jitterBufferDelay: jitterBufferDelay,
      decodeTime: decodeTime,
    );
  }
}

void trackInboundStats(
  String? clientId,
  List<RtcVideoInboundStats> stats,
) {
  final statsLists = RtcVideoInboundStatsLists.fromStatsList(stats);
  //  formats each double value to 2 precision
  const precision = 2;
  final jitterBufferDelay =
      formatDoubleList(statsLists.jitterBufferDelay, precision);
  final decodeTime = formatDoubleList(statsLists.decodeTime, precision);

  AppAnalytics.instance.trackTrace('video_inbound_stats', properties: {
    'clientId': clientId ?? '',
    'framesPerSecond': statsLists.framesPerSecond.join(','),
    'framesReceivedPerSecond': statsLists.framesReceivedPerSecond.join(','),
    'framesDecodedPerSecond': statsLists.framesDecodedPerSecond.join(','),
    'framesDroppedPerSecond': statsLists.framesDroppedPerSecond.join(','),
    'bytesPerSecond': statsLists.bytesPerSecond.join(','),
    'packetsLost': statsLists.packetsLost.join(','),
    'packetsReceived': statsLists.packetsReceived.join(','),
    'jitter': statsLists.jitter.join(','),
    'pauseCount': statsLists.pauseCount.join(','),
    'jitterBufferDelay': jitterBufferDelay.join(','),
    'decodeTime': decodeTime.join(','),
  });
}
