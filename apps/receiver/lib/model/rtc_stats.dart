// https://www.w3.org/TR/webrtc-stats/
import 'dart:convert';

import 'package:display_flutter/utility/list_util.dart';

class RtcVideoInboundStats {
  final String? decoderName;
  final int? frameWidth;
  final int? frameHeight;
  final int? bytesReceived;
  final int? packetsLost;
  final int? packetsReceived;
  final double? jitter;
  final int? pauseCount;
  final double? jitterBufferDelay;

  final double? timestamp;

  final bool? powerEfficientDecoder;
  final int? qpSum;
  final int? nackCount;
  final int? firCount;
  final int? pliCount;
  final int? freezeCount;
  final double? totalFreezesDuration;
  final int? keyFramesDecoded;

  final double? totalInterFrameDelay;
  final double? totalSquaredInterFrameDelay;
  final double? totalPausesDuration;
  final double? totalAssemblyTime;
  final int? framesAssembledFromMultiplePackets;
  final int? framesDropped;
  final int? framesReceived;
  final int? framesDecoded;
  final int? jitterBufferEmittedCount;
  final int? headerBytesReceived;
  final double? totalProcessingDelay;
  final double? totalDecodeTime;

  final double? packetsReceivedPerSecond;
  final double? framesPerSecond;
  final int? framesReceivedPerSecond;
  final int? framesDecodedPerSecond;
  final int? framesDroppedPerSecond;
  final int? bytesPerSecond;
  final double? keyFramesDecodedPerSecond;
  final double? interFrameDelayPerSecond;
  final double? headerBytesPerSecond;

  final double? decodeTime;
  final double? totalInterFrameDelayAvg;
  final double? totalAssemblyTimeAvg;
  final double? jitterBufferDelayAvg;
  final double? qpSumAvg;

  RtcVideoInboundStats({
    this.decoderName,
    this.frameWidth,
    this.frameHeight,
    this.bytesReceived,
    this.packetsLost,
    this.packetsReceived,
    this.jitter,
    this.pauseCount,
    this.jitterBufferDelay,
    this.timestamp,
    this.powerEfficientDecoder,
    this.qpSum,
    this.nackCount,
    this.firCount,
    this.pliCount,
    this.freezeCount,
    this.totalFreezesDuration,
    this.keyFramesDecoded,
    this.totalInterFrameDelay,
    this.totalSquaredInterFrameDelay,
    this.totalPausesDuration,
    this.totalAssemblyTime,
    this.framesAssembledFromMultiplePackets,
    this.framesDropped,
    this.framesReceived,
    this.framesDecoded,
    this.jitterBufferEmittedCount,
    this.headerBytesReceived,
    this.totalProcessingDelay,
    this.totalDecodeTime,
    this.packetsReceivedPerSecond,
    this.framesPerSecond,
    this.framesReceivedPerSecond,
    this.framesDecodedPerSecond,
    this.framesDroppedPerSecond,
    this.bytesPerSecond,
    this.keyFramesDecodedPerSecond,
    this.interFrameDelayPerSecond,
    this.headerBytesPerSecond,
    this.decodeTime,
    this.totalInterFrameDelayAvg,
    this.totalAssemblyTimeAvg,
    this.jitterBufferDelayAvg,
    this.qpSumAvg,
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

String formatVideoOutboundStatsList(List<RtcVideoOutboundStats> list) {
  final Map<String, List<double?>> perSecondFieldValues = {};
  final Map<String, String> lastValueFields = {};

  for (final stat in list) {
    final data = <String, dynamic>{
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
      "keyFramesEncodedPerSecond": stat.keyFramesEncodedPerSecond?.toDouble(),
      "retransmittedPacketsSentPerSecond":
          stat.retransmittedPacketsSentPerSecond,
      "headerBytesSentPerSecond": stat.headerBytesSentPerSecond,
      "retransmittedBytesSentPerSecond": stat.retransmittedBytesSentPerSecond,
      "encodeTimeAvgMs": stat.encodeTimeAvgMs,
      "totalEncodedBytesTargetPerSecond": stat.totalEncodedBytesTargetPerSecond,
      "packetSendDelayAvgMs": stat.packetSendDelayAvgMs,
      "qpSumAvg": stat.qpSumAvg,
      "availableOutgoingBitrate": stat.availableOutgoingBitrate,
      "mediaSourceFramesPerSecond": stat.mediaSourceFramesPerSecond,
    };

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
