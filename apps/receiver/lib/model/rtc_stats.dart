// https://www.w3.org/TR/webrtc-stats/
class RtcVideoInboundStats {
  final String? decoderName;
  final int? frameWidth;
  final int? frameHeight;
  final double? framesPerSecond;
  final int? framesReceivedPerSecond;
  final int? framesDecodedPerSecond;
  final int? framesDroppedPerSecond;
  final int? bytesPerSecond;
  final int? bytesReceived;
  final int? packetsLost;
  final int? packetsReceived;
  final double? jitter;
  final int? pauseCount;
  final double? jitterBufferDelay;
  final double? decodeTime;

  RtcVideoInboundStats({
    this.decoderName,
    this.frameWidth,
    this.frameHeight,
    this.framesPerSecond,
    this.framesReceivedPerSecond,
    this.framesDecodedPerSecond,
    this.framesDroppedPerSecond,
    this.bytesPerSecond,
    this.bytesReceived,
    this.packetsLost,
    this.packetsReceived,
    this.jitter,
    this.pauseCount,
    this.jitterBufferDelay,
    this.decodeTime,
  });
}

class RtcVideoInboundStatsForPresenter {
  final RtcVideoInboundStats _baseStats;

  // Presenter-specific fields
  bool? powerEfficientDecoder;
  int? qpSum;
  double? timestamp;

  RtcVideoInboundStatsForPresenter(
    this._baseStats, {
    this.powerEfficientDecoder,
    this.qpSum,
    this.timestamp,
  });

  // Expose only necessary fields
  int? get frameWidth => _baseStats.frameWidth;
  int? get frameHeight => _baseStats.frameHeight;
  double? get framesPerSecond => _baseStats.framesPerSecond;
  int? get framesReceivedPerSecond => _baseStats.framesReceivedPerSecond;
  int? get framesDecodedPerSecond => _baseStats.framesDecodedPerSecond;
  int? get framesDroppedPerSecond => _baseStats.framesDroppedPerSecond;
  int? get bytesPerSecond => _baseStats.bytesPerSecond;
  int? get bytesReceived => _baseStats.bytesReceived;
  int? get packetsLost => _baseStats.packetsLost;
  int? get packetsReceived => _baseStats.packetsReceived;
  double? get jitter => _baseStats.jitter;
  double? get decodeTime => _baseStats.decodeTime;
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
      currentRoundTripTime: (map['totalRoundTripTime'] as num?)?.toDouble(),
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
