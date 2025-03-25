class RtcVideoOutboundStats {
  String? encoderImplementation;
  int? frameWidth;
  int? frameHeight;
  double? framesPerSecond;
  String? contentType;
  String? qualityLimitationReason;
  int? pliCount;
  int? targetBitrate;
  double? encodeTime;
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
  double? packetsSentPerSecond;
  double? bytesSentPerSecond;
  double? retransmittedPacketsSentPerSecond;
  double? headerBytesSentPerSecond;
  double? retransmittedBytesSentPerSecond;
  double? framesEncodedPerSecond;
  double? encodeTimeAvgMs;
  double? totalEncodedBytesTargetPerSecond;
  double? framesSentPerSecond;
  double? packetSendDelayAvgMs;
  double? qpSumAvg;

  RtcVideoOutboundStats({
      this.encoderImplementation,
      this.frameWidth,
      this.frameHeight,
      this.framesPerSecond,
      this.contentType,
      this.qualityLimitationReason,
      this.pliCount,
      this.targetBitrate,
      this.encodeTime,
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
      this.encodeTimeAvgMs,
      this.totalEncodedBytesTargetPerSecond,
      this.framesSentPerSecond,
      this.packetSendDelayAvgMs,
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