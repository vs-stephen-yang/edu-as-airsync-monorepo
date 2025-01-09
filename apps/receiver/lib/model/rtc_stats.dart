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
}

class RtcIceCandidatePairStats {
  // Represents the latest round trip time measured in seconds
  double? currentRoundTripTime;

  // Represents the sum of all round trip time measurements in seconds since the beginning of the session
  double? totalRoundTripTime;
}
