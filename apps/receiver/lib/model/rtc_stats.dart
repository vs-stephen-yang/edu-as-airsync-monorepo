// https://www.w3.org/TR/webrtc-stats/
import 'dart:convert';

import 'package:display_flutter/utility/list_util.dart';

class RtcVideoInboundStats {
  final String? decoderName;
  final int? frameWidth;
  final int? frameHeight;
  final double? framesPerSecond;
  final double? timestamp;

  // Packet and byte counters
  final int? bytesReceived;
  final int? headerBytesReceived;
  final int? packetsReceived;
  final int? packetsLost;
  final int? packetsDiscarded;
  final int? fecBytesReceived;
  final int? fecPacketsReceived;
  final int? fecPacketsDiscarded;
  final int? retransmittedPacketsReceived;
  final int? retransmittedBytesReceived;

  // Frame counters
  final int? framesDecoded;
  final int? framesRendered;
  final int? framesDropped;
  final int? framesReceived;
  final int? framesAssembledFromMultiplePackets;
  final int? keyFramesDecoded;

  // Quality/jitter
  final double? jitter;
  final int? pauseCount;
  final double? totalPausesDuration;
  final int? freezeCount;
  final double? totalFreezesDuration;

  // Timing/processing
  final double? jitterBufferDelay;
  final double? jitterBufferTargetDelay;
  final double? jitterBufferMinimumDelay;
  final int? jitterBufferEmittedCount;
  final double? totalProcessingDelay;
  final double? totalDecodeTime;
  final double? totalInterFrameDelay;
  final double? totalSquaredInterFrameDelay;
  final double? totalAssemblyTime;

  // Codec and control counters
  final int? qpSum;
  final int? nackCount;
  final int? firCount;
  final int? pliCount;

  // Audio-related metrics
  final int? totalSamplesReceived;
  final int? concealedSamples;
  final int? silentConcealedSamples;
  final int? concealmentEvents;
  final int? insertedSamplesForDeceleration;
  final int? removedSamplesForAcceleration;
  final double? audioLevel;
  final double? totalAudioEnergy;
  final double? totalSamplesDuration;

  final double? audioJitterBufferDelay;
  final int? audioJitterBufferEmittedCount;

  // Corruption probabilities
  final double? totalCorruptionProbability;
  final double? totalSquaredCorruptionProbability;
  final int? corruptionMeasurements;

  final bool? powerEfficientDecoder;

  // Per-second deltas
  final int? packetsReceivedPerSecond;
  final int? packetsLostPerSecond;
  final int? packetsDiscardedPerSecond;
  final int? fecBytesReceivedPerSecond;
  final int? fecPacketsReceivedPerSecond;
  final int? fecPacketsDiscardedPerSecond;
  final int? retransmittedPacketsReceivedPerSecond;
  final int? retransmittedBytesReceivedPerSecond;

  final int? framesDecodedPerSecond;
  final int? framesRenderedPerSecond;
  final int? framesDroppedPerSecond;
  final int? framesReceivedPerSecond;
  final int? framesAssembledFromMultiplePacketsPerSecond;
  final int? keyFramesDecodedPerSecond;

  final int? nackCountPerSecond;
  final int? firCountPerSecond;
  final int? pliCountPerSecond;
  final int? bytesReceivedPerSecond;
  final int? bytesPerSecond;
  final int? headerBytesReceivedPerSecond;
  final double? headerBytesPerSecond;

  final double? qpSumPerSecond;
  final double? totalDecodeTimePerSecond;
  final double? totalInterFrameDelayPerSecond;
  final double? totalSquaredInterFrameDelayPerSecond;
  final double? totalInterFrameDelayVariancePerSecond;
  final double? packetLossRate;
  final int? pauseCountPerSecond;
  final double? totalPausesDurationPerSecond;
  final int? freezeCountPerSecond;
  final double? totalFreezesDurationPerSecond;
  final double? totalProcessingDelayPerSecond;
  final double? jitterBufferDelayPerSecond;
  final double? jitterBufferTargetDelayPerSecond;
  final double? jitterBufferMinimumDelayPerSecond;
  final int? jitterBufferEmittedCountPerSecond;
  final double? totalAssemblyTimePerSecond;
  final double? totalAudioEnergyPerSecond;
  final double? totalSamplesDurationPerSecond;
  final int? totalSamplesReceivedPerSecond;
  final int? concealedSamplesPerSecond;
  final int? silentConcealedSamplesPerSecond;
  final int? concealmentEventsPerSecond;
  final int? insertedSamplesForDecelerationPerSecond;
  final int? removedSamplesForAccelerationPerSecond;
  final double? totalCorruptionProbabilityPerSecond;
  final double? totalSquaredCorruptionProbabilityPerSecond;
  final int? corruptionMeasurementsPerSecond;

  // Averages
  final double? decodeTime;
  final double? totalInterFrameDelayAvg;
  final double? totalAssemblyTimeAvg;
  final double? jitterBufferDelayAvg;
  final double? audioJitterBufferDelayAvg;
  final double? qpSumAvg;

  double? currentRoundTripTime; // in seconds

  RtcVideoInboundStats({
    this.decoderName,
    this.frameWidth,
    this.frameHeight,
    this.framesPerSecond,
    this.timestamp,
    this.bytesReceived,
    this.headerBytesReceived,
    this.packetsReceived,
    this.packetsLost,
    this.packetsDiscarded,
    this.fecBytesReceived,
    this.fecPacketsReceived,
    this.fecPacketsDiscarded,
    this.retransmittedPacketsReceived,
    this.retransmittedBytesReceived,
    this.framesDecoded,
    this.framesRendered,
    this.framesDropped,
    this.framesReceived,
    this.framesAssembledFromMultiplePackets,
    this.keyFramesDecoded,
    this.jitter,
    this.pauseCount,
    this.totalPausesDuration,
    this.freezeCount,
    this.totalFreezesDuration,
    this.jitterBufferDelay,
    this.jitterBufferTargetDelay,
    this.jitterBufferMinimumDelay,
    this.jitterBufferEmittedCount,
    this.totalProcessingDelay,
    this.totalDecodeTime,
    this.totalInterFrameDelay,
    this.totalSquaredInterFrameDelay,
    this.totalAssemblyTime,
    this.qpSum,
    this.nackCount,
    this.firCount,
    this.pliCount,
    this.totalSamplesReceived,
    this.concealedSamples,
    this.silentConcealedSamples,
    this.concealmentEvents,
    this.insertedSamplesForDeceleration,
    this.removedSamplesForAcceleration,
    this.audioLevel,
    this.totalAudioEnergy,
    this.totalSamplesDuration,
    this.audioJitterBufferDelay,
    this.audioJitterBufferEmittedCount,
    this.totalCorruptionProbability,
    this.totalSquaredCorruptionProbability,
    this.corruptionMeasurements,
    this.powerEfficientDecoder,
    this.packetsReceivedPerSecond,
    this.packetsLostPerSecond,
    this.packetsDiscardedPerSecond,
    this.fecBytesReceivedPerSecond,
    this.fecPacketsReceivedPerSecond,
    this.fecPacketsDiscardedPerSecond,
    this.retransmittedPacketsReceivedPerSecond,
    this.retransmittedBytesReceivedPerSecond,
    this.framesDecodedPerSecond,
    this.framesRenderedPerSecond,
    this.framesDroppedPerSecond,
    this.framesReceivedPerSecond,
    this.framesAssembledFromMultiplePacketsPerSecond,
    this.keyFramesDecodedPerSecond,
    this.nackCountPerSecond,
    this.firCountPerSecond,
    this.pliCountPerSecond,
    this.bytesReceivedPerSecond,
    this.bytesPerSecond,
    this.headerBytesReceivedPerSecond,
    this.headerBytesPerSecond,
    this.qpSumPerSecond,
    this.totalDecodeTimePerSecond,
    this.totalInterFrameDelayPerSecond,
    this.totalSquaredInterFrameDelayPerSecond,
    this.totalInterFrameDelayVariancePerSecond,
    this.packetLossRate,
    this.pauseCountPerSecond,
    this.totalPausesDurationPerSecond,
    this.freezeCountPerSecond,
    this.totalFreezesDurationPerSecond,
    this.totalProcessingDelayPerSecond,
    this.jitterBufferDelayPerSecond,
    this.jitterBufferTargetDelayPerSecond,
    this.jitterBufferMinimumDelayPerSecond,
    this.jitterBufferEmittedCountPerSecond,
    this.totalAssemblyTimePerSecond,
    this.totalAudioEnergyPerSecond,
    this.totalSamplesDurationPerSecond,
    this.totalSamplesReceivedPerSecond,
    this.concealedSamplesPerSecond,
    this.silentConcealedSamplesPerSecond,
    this.concealmentEventsPerSecond,
    this.insertedSamplesForDecelerationPerSecond,
    this.removedSamplesForAccelerationPerSecond,
    this.totalCorruptionProbabilityPerSecond,
    this.totalSquaredCorruptionProbabilityPerSecond,
    this.corruptionMeasurementsPerSecond,
    this.decodeTime,
    this.totalInterFrameDelayAvg,
    this.totalAssemblyTimeAvg,
    this.jitterBufferDelayAvg,
    this.audioJitterBufferDelayAvg,
    this.qpSumAvg,
    this.currentRoundTripTime,
  });
}

class RtcIceCandidate {
  final String? candidateType;
  final String? protocol;
  final String? address;
  final int? port;
  final String? ip;
  final int? priority;

  // Constructor
  RtcIceCandidate({
    this.candidateType,
    this.protocol,
    this.address,
    this.port,
    this.ip,
    this.priority,
  });

  // Named constructor to create an instance from a map
  factory RtcIceCandidate.fromMap(Map<dynamic, dynamic> values) {
    return RtcIceCandidate(
      candidateType: values['candidateType'],
      protocol: values['protocol'],
      address: values['address'],
      port: values['port'],
      ip: values['ip'],
      priority: values['priority'],
    );
  }
}

class RtcIceCandidatePairStats {
  final String? localCandidateId;
  final String? remoteCandidateId;
  final String? state;

  // Represents the latest round trip time measured in seconds
  final double? currentRoundTripTime;

  // Represents the sum of all round trip time measurements in seconds since the beginning of the session
  final double? totalRoundTripTime;

  RtcIceCandidatePairStats({
    this.localCandidateId,
    this.remoteCandidateId,
    this.state,
    this.totalRoundTripTime,
    this.currentRoundTripTime,
  });

  factory RtcIceCandidatePairStats.fromMap(Map<dynamic, dynamic> map) {
    return RtcIceCandidatePairStats(
      localCandidateId: map['localCandidateId'],
      remoteCandidateId: map['remoteCandidateId'],
      totalRoundTripTime: (map['totalRoundTripTime'] as num?)?.toDouble(),
      currentRoundTripTime: (map['currentRoundTripTime'] as num?)?.toDouble(),
      state: map['state'],
    );
  }
}

class RtcCodecStats {
  final String? sdpFmtpLine;
  final int? payloadType;
  final String? transportId;
  final String? mimeType;
  final int? clockRate;

  RtcCodecStats({
    this.sdpFmtpLine,
    this.payloadType,
    this.transportId,
    this.mimeType,
    this.clockRate,
  });

  factory RtcCodecStats.fromMap(Map<dynamic, dynamic> map) {
    return RtcCodecStats(
      sdpFmtpLine: map['sdpFmtpLine'],
      payloadType: map['payloadType'],
      transportId: map['transportId'],
      mimeType: map['mimeType'],
      clockRate: map['clockRate'],
    );
  }
}

class RtcVideoOutboundStats {
  String? transportId;
  String? mediaSourceId;
  String? encoderImplementation;
  int? frameWidth;
  int? frameHeight;
  double? framesPerSecond;
  String? contentType;
  String? qualityLimitationReason;
  int? pliCount;
  double? targetBitrate;
  bool? powerEfficientEncoder;

  double? timestamp;

  int? bytesSent;
  int? packetsSent;
  bool? active;
  int? firCount;
  int? framesEncoded;
  int? framesSent;
  int? headerBytesSent;
  int? hugeFramesSent;
  int? keyFramesEncoded;
  int? nackCount;
  int? retransmittedBytesSent;
  int? retransmittedPacketsSent;
  double? totalEncodeTime;
  int? totalEncodedBytesTarget;
  double? totalPacketSendDelay;
  int? qpSum;

  // Calculated metrics (per second or averages)
  int? packetsSentPerSecond;
  int? bytesSentPerSecond;
  int? framesSentPerSecond;
  int? framesEncodedPerSecond;
  int? hugeFramesSentPerSecond;
  int? keyFramesEncodedPerSecond;
  double? retransmittedPacketsSentPerSecond;
  double? headerBytesSentPerSecond;
  double? retransmittedBytesSentPerSecond;
  double? encodeTimeAvgMs;
  double? totalEncodedBytesTargetPerSecond;
  double? packetSendDelayAvgMs;
  double? qpSumAvg;

  // extend field from other dictionary
  double? availableOutgoingBitrate;
  double? currentRoundTripTime; // in seconds
  double? mediaSourceFramesPerSecond;

  RtcVideoOutboundStats({
    this.transportId,
    this.mediaSourceId,
    this.encoderImplementation,
    this.frameWidth,
    this.frameHeight,
    this.framesPerSecond,
    this.contentType,
    this.qualityLimitationReason,
    this.pliCount,
    this.targetBitrate,
    this.powerEfficientEncoder,
    this.timestamp,
    this.bytesSent,
    this.packetsSent,
    this.active,
    this.firCount,
    this.framesEncoded,
    this.framesSent,
    this.headerBytesSent,
    this.hugeFramesSent,
    this.keyFramesEncoded,
    this.nackCount,
    this.retransmittedBytesSent,
    this.retransmittedPacketsSent,
    this.totalEncodeTime,
    this.totalEncodedBytesTarget,
    this.totalPacketSendDelay,
    this.qpSum,
    this.packetsSentPerSecond,
    this.bytesSentPerSecond,
    this.retransmittedPacketsSentPerSecond,
    this.headerBytesSentPerSecond,
    this.retransmittedBytesSentPerSecond,
    this.framesEncodedPerSecond,
    this.hugeFramesSentPerSecond,
    this.keyFramesEncodedPerSecond,
    this.encodeTimeAvgMs,
    this.totalEncodedBytesTargetPerSecond,
    this.framesSentPerSecond,
    this.packetSendDelayAvgMs,
    this.qpSumAvg,
    this.availableOutgoingBitrate,
    this.mediaSourceFramesPerSecond,
  });
}

/// Format a list of stats data by separating per-second/average fields from last-value fields
String _formatStatsList(List<Map<String, dynamic>> dataList) {
  final Map<String, List<double?>> perSecondFieldValues = {};
  final Map<String, String> lastValueFields = {};

  for (final data in dataList) {
    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      final isPerSecond = key.contains("PerSecond") || key.contains("Avg");

      if (isPerSecond) {
        if (value is num) {
          perSecondFieldValues.putIfAbsent(key, () => []).add(value.toDouble());
        } else {
          perSecondFieldValues.putIfAbsent(key, () => []).add(null);
        }
      } else {
        if (value != null) {
          lastValueFields[key] = value.toString();
        }
      }
    }
  }

  final perSecondFormatted = <String, String>{
    for (final entry in perSecondFieldValues.entries)
      entry.key: formatDoubleList(entry.value, 2).join(',')
  };

  final result = {...perSecondFormatted, ...lastValueFields};
  return jsonEncode(result);
}

String formatVideoOutboundStatsList(List<RtcVideoOutboundStats> list) {
  final dataList = list
      .map((stat) => <String, dynamic>{
            "transportId": stat.transportId,
            "mediaSourceId": stat.mediaSourceId,
            "encoderImplementation": stat.encoderImplementation,
            "frameWidth": stat.frameWidth,
            "frameHeight": stat.frameHeight,
            "framesPerSecond": stat.framesPerSecond,
            "contentType": stat.contentType,
            "qualityLimitationReason": stat.qualityLimitationReason,
            "pliCount": stat.pliCount,
            "targetBitrate": stat.targetBitrate,
            "powerEfficientEncoder": stat.powerEfficientEncoder,
            "timestamp": stat.timestamp,
            "bytesSent": stat.bytesSent,
            "packetsSent": stat.packetsSent,
            "active": stat.active,
            "firCount": stat.firCount,
            "framesEncoded": stat.framesEncoded,
            "framesSent": stat.framesSent,
            "headerBytesSent": stat.headerBytesSent,
            "hugeFramesSent": stat.hugeFramesSent,
            "keyFramesEncoded": stat.keyFramesEncoded,
            "nackCount": stat.nackCount,
            "retransmittedBytesSent": stat.retransmittedBytesSent,
            "retransmittedPacketsSent": stat.retransmittedPacketsSent,
            "totalEncodeTime": stat.totalEncodeTime,
            "totalEncodedBytesTarget": stat.totalEncodedBytesTarget,
            "totalPacketSendDelay": stat.totalPacketSendDelay,
            "qpSum": stat.qpSum,
            "packetsSentPerSecond": stat.packetsSentPerSecond?.toDouble(),
            "bytesSentPerSecond": stat.bytesSentPerSecond?.toDouble(),
            "framesSentPerSecond": stat.framesSentPerSecond?.toDouble(),
            "framesEncodedPerSecond": stat.framesEncodedPerSecond?.toDouble(),
            "hugeFramesSentPerSecond": stat.hugeFramesSentPerSecond?.toDouble(),
            "keyFramesEncodedPerSecond":
                stat.keyFramesEncodedPerSecond?.toDouble(),
            "retransmittedPacketsSentPerSecond":
                stat.retransmittedPacketsSentPerSecond,
            "headerBytesSentPerSecond": stat.headerBytesSentPerSecond,
            "retransmittedBytesSentPerSecond":
                stat.retransmittedBytesSentPerSecond,
            "encodeTimeAvgMs": stat.encodeTimeAvgMs,
            "totalEncodedBytesTargetPerSecond":
                stat.totalEncodedBytesTargetPerSecond,
            "packetSendDelayAvgMs": stat.packetSendDelayAvgMs,
            "qpSumAvg": stat.qpSumAvg,
            "availableOutgoingBitrate": stat.availableOutgoingBitrate,
            "mediaSourceFramesPerSecond": stat.mediaSourceFramesPerSecond,
          })
      .toList();

  return _formatStatsList(dataList);
}

String formatVideoInboundStatsList(List<RtcVideoInboundStats> list) {
  final dataList = list
      .map((stat) => <String, dynamic>{
            "decoderName": stat.decoderName,
            "frameWidth": stat.frameWidth,
            "frameHeight": stat.frameHeight,
            "framesPerSecond": stat.framesPerSecond,
            "timestamp": stat.timestamp,
            "bytesReceived": stat.bytesReceived,
            "headerBytesReceived": stat.headerBytesReceived,
            "packetsLost": stat.packetsLost,
            "packetsReceived": stat.packetsReceived,
            "packetsDiscarded": stat.packetsDiscarded,
            "fecBytesReceived": stat.fecBytesReceived,
            "fecPacketsReceived": stat.fecPacketsReceived,
            "fecPacketsDiscarded": stat.fecPacketsDiscarded,
            "retransmittedPacketsReceived": stat.retransmittedPacketsReceived,
            "retransmittedBytesReceived": stat.retransmittedBytesReceived,
            "jitter": stat.jitter,
            "pauseCount": stat.pauseCount,
            "totalPausesDuration": stat.totalPausesDuration,
            "freezeCount": stat.freezeCount,
            "totalFreezesDuration": stat.totalFreezesDuration,
            "jitterBufferDelay": stat.jitterBufferDelay,
            "jitterBufferTargetDelay": stat.jitterBufferTargetDelay,
            "jitterBufferMinimumDelay": stat.jitterBufferMinimumDelay,
            "jitterBufferEmittedCount": stat.jitterBufferEmittedCount,
            "powerEfficientDecoder": stat.powerEfficientDecoder,
            "qpSum": stat.qpSum,
            "nackCount": stat.nackCount,
            "firCount": stat.firCount,
            "pliCount": stat.pliCount,
            "totalInterFrameDelay": stat.totalInterFrameDelay,
            "totalSquaredInterFrameDelay": stat.totalSquaredInterFrameDelay,
            "totalAssemblyTime": stat.totalAssemblyTime,
            "totalProcessingDelay": stat.totalProcessingDelay,
            "totalDecodeTime": stat.totalDecodeTime,
            "framesDecoded": stat.framesDecoded,
            "framesRendered": stat.framesRendered,
            "framesAssembledFromMultiplePackets":
                stat.framesAssembledFromMultiplePackets,
            "framesDropped": stat.framesDropped,
            "framesReceived": stat.framesReceived,
            "keyFramesDecoded": stat.keyFramesDecoded,
            "totalSamplesReceived": stat.totalSamplesReceived,
            "concealedSamples": stat.concealedSamples,
            "silentConcealedSamples": stat.silentConcealedSamples,
            "concealmentEvents": stat.concealmentEvents,
            "insertedSamplesForDeceleration":
                stat.insertedSamplesForDeceleration,
            "removedSamplesForAcceleration": stat.removedSamplesForAcceleration,
            "audioLevel": stat.audioLevel,
            "totalAudioEnergy": stat.totalAudioEnergy,
            "totalSamplesDuration": stat.totalSamplesDuration,
            "totalCorruptionProbability": stat.totalCorruptionProbability,
            "totalSquaredCorruptionProbability":
                stat.totalSquaredCorruptionProbability,
            "corruptionMeasurements": stat.corruptionMeasurements,
            // Per-second metrics
            "packetsReceivedPerSecond": stat.packetsReceivedPerSecond,
            "packetsLostPerSecond": stat.packetsLostPerSecond,
            "packetsDiscardedPerSecond": stat.packetsDiscardedPerSecond,
            "fecBytesReceivedPerSecond": stat.fecBytesReceivedPerSecond,
            "fecPacketsReceivedPerSecond": stat.fecPacketsReceivedPerSecond,
            "fecPacketsDiscardedPerSecond": stat.fecPacketsDiscardedPerSecond,
            "retransmittedPacketsReceivedPerSecond":
                stat.retransmittedPacketsReceivedPerSecond,
            "retransmittedBytesReceivedPerSecond":
                stat.retransmittedBytesReceivedPerSecond,
            "framesReceivedPerSecond": stat.framesReceivedPerSecond?.toDouble(),
            "framesDecodedPerSecond": stat.framesDecodedPerSecond?.toDouble(),
            "framesDroppedPerSecond": stat.framesDroppedPerSecond?.toDouble(),
            "framesRenderedPerSecond": stat.framesRenderedPerSecond?.toDouble(),
            "framesAssembledFromMultiplePacketsPerSecond":
                stat.framesAssembledFromMultiplePacketsPerSecond?.toDouble(),
            "keyFramesDecodedPerSecond": stat.keyFramesDecodedPerSecond,
            "nackCountPerSecond": stat.nackCountPerSecond,
            "firCountPerSecond": stat.firCountPerSecond,
            "pliCountPerSecond": stat.pliCountPerSecond,
            "bytesReceivedPerSecond": stat.bytesReceivedPerSecond,
            "bytesPerSecond": stat.bytesPerSecond?.toDouble(),
            "headerBytesReceivedPerSecond":
                stat.headerBytesReceivedPerSecond?.toDouble(),
            "headerBytesPerSecond": stat.headerBytesPerSecond,
            "qpSumPerSecond": stat.qpSumPerSecond,
            "totalDecodeTimePerSecond": stat.totalDecodeTimePerSecond,
            "totalInterFrameDelayPerSecond": stat.totalInterFrameDelayPerSecond,
            "totalSquaredInterFrameDelayPerSecond":
                stat.totalSquaredInterFrameDelayPerSecond,
            "totalInterFrameDelayVariancePerSecond":
                stat.totalInterFrameDelayVariancePerSecond,
            "packetLossRate": stat.packetLossRate,
            "pauseCountPerSecond": stat.pauseCountPerSecond,
            "totalPausesDurationPerSecond": stat.totalPausesDurationPerSecond,
            "freezeCountPerSecond": stat.freezeCountPerSecond,
            "totalFreezesDurationPerSecond": stat.totalFreezesDurationPerSecond,
            "totalProcessingDelayPerSecond": stat.totalProcessingDelayPerSecond,
            "jitterBufferDelayPerSecond": stat.jitterBufferDelayPerSecond,
            "jitterBufferTargetDelayPerSecond":
                stat.jitterBufferTargetDelayPerSecond,
            "jitterBufferMinimumDelayPerSecond":
                stat.jitterBufferMinimumDelayPerSecond,
            "jitterBufferEmittedCountPerSecond":
                stat.jitterBufferEmittedCountPerSecond,
            "totalAssemblyTimePerSecond": stat.totalAssemblyTimePerSecond,
            "totalAudioEnergyPerSecond": stat.totalAudioEnergyPerSecond,
            "totalSamplesDurationPerSecond": stat.totalSamplesDurationPerSecond,
            "totalSamplesReceivedPerSecond":
                stat.totalSamplesReceivedPerSecond?.toDouble(),
            "concealedSamplesPerSecond": stat.concealedSamplesPerSecond,
            "silentConcealedSamplesPerSecond":
                stat.silentConcealedSamplesPerSecond,
            "concealmentEventsPerSecond": stat.concealmentEventsPerSecond,
            "insertedSamplesForDecelerationPerSecond":
                stat.insertedSamplesForDecelerationPerSecond,
            "removedSamplesForAccelerationPerSecond":
                stat.removedSamplesForAccelerationPerSecond,
            "totalCorruptionProbabilityPerSecond":
                stat.totalCorruptionProbabilityPerSecond,
            "totalSquaredCorruptionProbabilityPerSecond":
                stat.totalSquaredCorruptionProbabilityPerSecond,
            "corruptionMeasurementsPerSecond":
                stat.corruptionMeasurementsPerSecond,
            // Averages
            "decodeTime": stat.decodeTime,
            "totalInterFrameDelayAvg": stat.totalInterFrameDelayAvg,
            "totalAssemblyTimeAvg": stat.totalAssemblyTimeAvg,
            "jitterBufferDelayAvg": stat.jitterBufferDelayAvg,
            "qpSumAvg": stat.qpSumAvg,
          })
      .toList();

  return _formatStatsList(dataList);
}
