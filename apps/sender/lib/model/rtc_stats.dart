class RtcVideoOutboundStats {
  String? encoderImplementation;
  int? frameWidth;
  int? frameHeight;
  double? framesPerSecond;
  String? contentType;
  String? qualityLimitationReason;
  int? pliCount;
  double? targetBitrate;
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
  double? encodeTimeAvg;
  double? totalEncodedBytesTargetPerSecond;
  double? framesSentPerSecond;
  double? packetSendDelayAvg;
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
      this.encodeTimeAvg,
      this.totalEncodedBytesTargetPerSecond,
      this.framesSentPerSecond,
      this.packetSendDelayAvg,
      this.qpSumAvg
  });
}