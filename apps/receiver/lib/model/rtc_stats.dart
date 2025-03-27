// https://www.w3.org/TR/webrtc-stats/
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
  final double? framesReceivedPerSecond;
  final double? framesDecodedPerSecond;
  final double? framesDroppedPerSecond;
  final double? bytesPerSecond;
  final double? keyFramesDecodedPerSecond;
  final double? interFrameDelayPerSecond;
  final double? headerBytesPerSecond;

  final double? decodeTimeAvg;
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
      this.decodeTimeAvg,
      this.totalInterFrameDelayAvg,
      this.totalAssemblyTimeAvg,
      this.jitterBufferDelayAvg,
      this.qpSumAvg
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
