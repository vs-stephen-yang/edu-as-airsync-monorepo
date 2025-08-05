import 'package:display_channel/display_channel.dart';

class MulticastInfo {
  final String ip;
  final int videoPort;
  final int audioPort;
  final int ssrc;
  final String keyHex;
  final String saltHex;
  final int videoRoc;
  final int audioRoc;

  MulticastInfo({
    required this.ip,
    required this.videoPort,
    required this.audioPort,
    required this.ssrc,
    required this.keyHex,
    required this.saltHex,
    required this.videoRoc,
    required this.audioRoc,
  });

  factory MulticastInfo.fromMessage(MulticastInfoMessage message) {
    return MulticastInfo(
      ip: message.ip,
      videoPort: message.videoPort,
      audioPort: message.audioPort,
      ssrc: message.ssrc,
      keyHex: message.keyHex,
      saltHex: message.saltHex,
      videoRoc: message.videoRoc,
      audioRoc: message.audioRoc,
    );
  }
}
