class RtcVideoInboundStats {
  String? decoderName;

  int? frameWidth;
  int? frameHeight;

  double? framesPerSecond;

  int? framesReceivedPerSecond;
  int? framesDecodedPerSecond;
  int? framesDroppedPerSecond;

  int? bytesPerSecond;

  int? packetsLost;
  int? packetsReceived;
  double? jitter;
  int? pauseCount;

  double? jitterBufferDelay;

  double? decodeTime;
}
