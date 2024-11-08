import 'package:flutter_webrtc/flutter_webrtc.dart';

class SdpUtil {
  static bool isAttributeOfPayloadType(String line, String payloadType) {
    //a=rtpmap:35 H264/90000
    final parts = line.split(' ');

    return parts[0].contains(payloadType) &&
        (parts[0].contains('rtpmap') ||
            parts[0].contains('rtcp') ||
            parts[0].contains('fmtp'));
  }

  static String? removeCodec(String sdp, String encodingName) {
    final lines = sdp.split("\r\n");

    List<String> payloadTypes = findPayloadTypes(lines, encodingName);
    if (payloadTypes.isEmpty) {
      return sdp;
    }

    // remove payload types
    for (var payloadType in payloadTypes) {
      //a=rtpmap:35 H264/90000
      lines.removeWhere((line) =>
          line.startsWith('a=') && isAttributeOfPayloadType(line, payloadType));
    }

    sdp = lines.join('\r\n');

    // remove payload types from m= line
    final videoLine =
        lines.where((line) => line.startsWith("m=video")).toList()[0];

    final newVideoLine = removePayloadTypesFromM(videoLine, payloadTypes);

    sdp = sdp.replaceFirst(videoLine, newVideoLine);
    return sdp;
  }

  static RTCSessionDescription fixSdp(RTCSessionDescription s) {
    var sdp = s.sdp;
    s.sdp =
        sdp!.replaceAll('profile-level-id=640c1f', 'profile-level-id=42e032');
    return s;
  }

  // remove payload types from m= line
  static String removePayloadTypesFromM(
      String line, List<String> payloadTypes) {
    //m=video 9 UDP/TLS/RTP/SAVPF 96 97 125 120 124 107

    for (var payloadType in payloadTypes) {
      // must remove leading space
      line = line.replaceFirst(' $payloadType', '');
    }
    return line;
  }

  // find payload type numbers that matche encodingName
  static List<String> findPayloadTypes(
    List<String> sdpLines,
    String encodingName,
  ) {
    final payloadTypes = sdpLines
        .where((line) => line.startsWith("a=rtpmap:"))
        .where((line) => line.contains(encodingName))
        .map((line) => line.split(' ')) //a=rtpmap:41, AV1/90000
        .map((parts) => parts[0]) //a=rtpmap:41
        .map(
          (part) => part.substring("a=rtpmap:".length), //41
        )
        .toList();

    // find apt (associated payload type)
    var associatedPayloadTypes = <String>[];

    for (var payloadType in payloadTypes) {
      //a=fmtp:97 apt=96
      associatedPayloadTypes += sdpLines
          .where((line) => line.startsWith("a=fmtp:"))
          .where((line) => line.contains("apt=$payloadType"))
          .map((line) => line.split(' ')) //a=fmtp:97 apt=96
          .map((parts) => parts[0]) //a=fmtp:97
          .map(
            (part) => part.substring("a=fmtp:".length), //97
          )
          .toList();
    }

    return payloadTypes + associatedPayloadTypes;
  }
}
