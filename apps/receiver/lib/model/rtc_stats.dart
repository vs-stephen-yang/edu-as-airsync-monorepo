// https://www.w3.org/TR/webrtc-stats/
class RtcVideoInboundStats {
  String? decoderName;

  int? frameWidth;
  int? frameHeight;

  double? framesPerSecond;

  int? framesReceivedPerSecond;
  int? framesDecodedPerSecond;
  int? framesDroppedPerSecond;

  int? bytesPerSecond;

  int? bytesReceived;

  int? packetsLost;
  int? packetsReceived;
  double? jitter;
  int? pauseCount;

  double? jitterBufferDelay;

  double? decodeTime;

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
  final RtcVideoInboundStats baseStats;

  // Presenter-specific fields
  bool? powerEfficientDecoder;
  int? qpSum;

  RtcVideoInboundStatsForPresenter(
    this.baseStats, {
    this.powerEfficientDecoder,
    this.qpSum,
  });

  // Expose only necessary fields
  int? get frameWidth => baseStats.frameWidth;
  int? get frameHeight => baseStats.frameHeight;
  double? get framesPerSecond => baseStats.framesPerSecond;
  int? get framesReceivedPerSecond => baseStats.framesReceivedPerSecond;
  int? get framesDecodedPerSecond => baseStats.framesDecodedPerSecond;
  int? get framesDroppedPerSecond => baseStats.framesDroppedPerSecond;
  int? get bytesPerSecond => baseStats.bytesPerSecond;
  int? get bytesReceived => baseStats.bytesReceived;
  int? get packetsLost => baseStats.packetsLost;
  int? get packetsReceived => baseStats.packetsReceived;
  double? get jitter => baseStats.jitter;
  double? get decodeTime => baseStats.decodeTime;
}

class RtcIceCandidatePairStats {
  // Represents the latest round trip time measured in seconds
  double? currentRoundTripTime;

  // Represents the sum of all round trip time measurements in seconds since the beginning of the session
  double? totalRoundTripTime;
}
