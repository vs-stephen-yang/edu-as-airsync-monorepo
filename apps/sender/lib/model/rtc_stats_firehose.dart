import 'package:display_cast_flutter/model/rtc_stats.dart';

/// Extension to convert RTC stats to Firehose JSON format.
extension RtcVideoOutboundStatsFirehose on RtcVideoOutboundStats {
  /// Convert to JSON format for Firehose with naming convention from firehose-stats.txt
  Map<String, dynamic> toFirehoseJson() {
    return {
      // Direct values
      'video-frameHeight': frameHeight,
      'video-frameWidth': frameWidth,
      'video-framesPerSecond': framesPerSecond,
      'video-powerEfficientEncoder': powerEfficientEncoder,
      'video-qualityLimitationDurations-none': qualityLimitationDurationsNone,
      'video-qualityLimitationDurations-cpu': qualityLimitationDurationsCpu,
      'video-qualityLimitationDurations-bandwidth':
          qualityLimitationDurationsBandwith,
      'video-qualityLimitationDurations-other': qualityLimitationDurationsOther,
      'video-qualityLimitationReason': qualityLimitationReason,
      'video-targetBitrate': targetBitrate,

      // Rate fields (per second)
      'video-bytesSent-Rate': bytesSentPerSecond,
      'video-firCount-Rate': firCountPerSecond,
      'video-framesEncoded-Rate': framesEncodedPerSecond,
      'video-framesSent-Rate': framesSentPerSecond,
      'video-hugeFramesSent-Rate': hugeFramesSentPerSecond,
      'video-keyFramesEncoded-Rate': keyFramesEncodedPerSecond,
      'video-nackCount-Rate': nackCountPerSecond,
      'video-packetsSent-Rate': packetsSentPerSecond,
      'video-pliCount-Rate': pliCountPerSecond,
      'video-qualityLimitationResolutionChanges-Rate':
          qualityLimitationResolutionChanges,
      'video-retransmittedBytesSent-Rate': retransmittedBytesSentPerSecond,
      'video-retransmittedPacketsSent-Rate': retransmittedPacketsSentPerSecond,

      // Average fields
      'video-qpSum-Avg': qpSumAvg,
      'video-totalEncodeTime-Avg': encodeTimeAvgMs,
      'video-totalEncodedBytesTarget-Avg': totalEncodedBytesTargetPerSecond,
      'video-totalPacketSendDelay-Avg': packetSendDelayAvgMs,

      // Source stats
      'video-source-framesPerSecond': mediaSourceFramesPerSecond,

      // Candidate pair stats
      'availableOutgoingBitrate': availableOutgoingBitrate,
    };
  }
}
