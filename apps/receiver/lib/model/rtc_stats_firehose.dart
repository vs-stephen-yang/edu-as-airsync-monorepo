import 'package:display_flutter/model/rtc_stats.dart';

/// Extension to convert RTC inbound stats to Firehose JSON format.
/// Field naming follows the convention from decoder-stats.txt.
extension RtcVideoInboundStatsFirehose on RtcVideoInboundStats {
  /// Convert to JSON format for Firehose with naming convention from decoder-stats.txt
  Map<String, dynamic> toFirehoseJson() {
    return {
      // Direct values - Video
      'video-frameWidth': frameWidth,
      'video-frameHeight': frameHeight,
      'video-framesPerSecond': framesPerSecond,
      'video-jitter': jitter,
      'video-powerEfficientDecoder': powerEfficientDecoder,

      // Direct values - Audio
      'audio-jitter': audioJitterBufferDelayAvg,

      // Rate fields - Video bytes/packets
      'video-bytesReceived-Rate': bytesReceivedPerSecond,
      'video-packetsReceived-Rate': packetsReceivedPerSecond,
      'video-packetsLost-Rate': packetsLostPerSecond,
      'video-packetsDiscarded-Rate': packetsDiscardedPerSecond,

      // Rate fields - Audio bytes/packets

      // Rate fields - FEC
      'video-fecBytesReceived-Rate': fecBytesReceivedPerSecond,
      'video-fecPacketsReceived-Rate': fecPacketsReceivedPerSecond,
      'video-fecPacketsDiscarded-Rate': fecPacketsDiscardedPerSecond,

      // Rate fields - Retransmission
      'video-retransmittedPacketsReceived-Rate':
          retransmittedPacketsReceivedPerSecond,
      'video-retransmittedBytesReceived-Rate':
          retransmittedBytesReceivedPerSecond,

      // Rate fields - Frames
      'video-framesDecoded-Rate': framesDecodedPerSecond,
      'video-framesRendered-Rate': framesRenderedPerSecond,
      'video-framesDropped-Rate': framesDroppedPerSecond,
      'video-framesReceived-Rate': framesReceivedPerSecond,
      'video-keyFramesDecoded-Rate': keyFramesDecodedPerSecond,

      // Rate fields - Control messages
      'video-nackCount-Rate': nackCountPerSecond,
      'video-firCount-Rate': firCountPerSecond,
      'video-pliCount-Rate': pliCountPerSecond,

      // Rate fields - Packet loss
      'video-packetLoss-Rate': packetLossRate,
      'audio-packetLoss-Rate': null, // Audio packet loss not tracked separately

      // Cumulative values - Freeze/Pause
      'video-freezeCount': freezeCount,
      'video-totalFreezesDuration': totalFreezesDuration,
      'video-pauseCount': pauseCount,
      'video-totalPausesDuration': totalPausesDuration,

      // Rate fields - Audio concealment
      'audio-concealedSamples-Rate': concealedSamplesPerSecond,
      'audio-concealmentEvents-Rate': concealmentEventsPerSecond,
      'audio-silentConcealedSamples-Rate': silentConcealedSamplesPerSecond,
      'audio-insertedSamplesForDeceleration-Rate':
          insertedSamplesForDecelerationPerSecond,
      'audio-removedSamplesForAcceleration-Rate':
          removedSamplesForAccelerationPerSecond,
      'audio-totalSamplesReceived-Rate': totalSamplesReceivedPerSecond,

      // Rate fields - Corruption
      'video-corruptionMeasurements-Rate': corruptionMeasurementsPerSecond,

      // Average fields - Decode/Processing
      'video-totalDecodeTime-Avg': decodeTime,
      'video-totalProcessingDelay-Avg': totalProcessingDelayAvg,
      'video-totalAssemblyTime-Avg': totalAssemblyTimeAvg,

      // Average fields - Jitter buffer
      'video-jitterBufferDelay-Avg': jitterBufferDelayAvg,
      'video-jitterBufferTargetDelay-Avg': jitterBufferTargetDelayPerSecond,
      'video-jitterBufferMinimumDelay-Avg': jitterBufferMinimumDelayPerSecond,
      'audio-jitterBufferDelay-Avg': audioJitterBufferDelayAvg,

      // RTT from candidate pair
      'video-currentRoundTripTime': currentRoundTripTime,
    };
  }
}
