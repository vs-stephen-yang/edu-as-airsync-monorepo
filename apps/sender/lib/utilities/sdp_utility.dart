import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sdp_transform/sdp_transform.dart' as sdp_transform;

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

// Copy and modify from ion-sdk-flutter/lib/src/utils.dart
// TODO improve this class
class CodecCapability {
  CodecCapability(
      this.kind, this.payloads, this.codecs, this.fmtp, this.rtcpFb) {
    codecs.forEach((element) {
      element['orign_payload'] = element['payload'];
    });
  }
  String kind;
  List<dynamic> rtcpFb;
  List<dynamic> fmtp;
  List<String> payloads;
  List<dynamic> codecs;
  bool setCodecPreferences(String kind, List<dynamic>? newCodecs) {
    if (newCodecs == null) {
      return false;
    }
    var newRtcpFb = <dynamic>[];
    var newFmtp = <dynamic>[];
    var newPayloads = <String>[];
    newCodecs.forEach((element) {
      var orign_payload = element['orign_payload'] as int;
      var payload = element['payload'] as int;
      // change payload type
      if (payload != orign_payload) {
        newRtcpFb.addAll(rtcpFb.where((e) {
          if (e['payload'] == orign_payload) {
            e['payload'] = payload;
            return true;
          }
          return false;
        }).toList());
        newFmtp.addAll(fmtp.where((e) {
          if (e['payload'] == orign_payload) {
            e['payload'] = payload;
            return true;
          }
          return false;
        }).toList());
        if (payloads.contains('$orign_payload')) {
          newPayloads.add('$payload');
        }
      } else {
        newRtcpFb.addAll(rtcpFb.where((e) => e['payload'] == payload).toList());
        newFmtp.addAll(fmtp.where((e) => e['payload'] == payload).toList());
        newPayloads.addAll(payloads.where((e) => e == '$payload').toList());
      }
    });
    rtcpFb = newRtcpFb;
    fmtp = newFmtp;
    payloads = newPayloads;
    codecs = newCodecs;
    return true;
  }
}

enum H264CodecProfile {
  baseline, // Baseline Profile (BP)
  constrainedBaseline, // Constrained Baseline Profile (CBP)
  main, // Main Profile (MP)
  high, // High Profile (HP)
  unknown, // Unknown Profile
}

class CodecCapabilitySelector {
  CodecCapabilitySelector(String sdp) {
    _sdp = sdp;
    _session = sdp_transform.parse(_sdp);
  }
  late String _sdp;
  late Map<String, dynamic> _session;
  Map<String, dynamic> get session => _session;
  String sdp() => sdp_transform.write(_session, null);

  CodecCapability? getCapabilities(String kind) {
    var mline = _mline(kind);
    if (mline == null) {
      return null;
    }
    var rtcpFb = mline['rtcpFb'] ?? <dynamic>[];
    var fmtp = mline['fmtp'] ?? <dynamic>[];
    var payloads = (mline['payloads'] as String).split(' ');
    var codecs = mline['rtp'] ?? <dynamic>[];
    return CodecCapability(kind, payloads, codecs, fmtp, rtcpFb);
  }

  bool setCapabilities(CodecCapability? caps) {
    if (caps == null) {
      return false;
    }
    var mline = _mline(caps.kind);
    if (mline == null) {
      return false;
    }
    mline['payloads'] = caps.payloads.join(' ');
    mline['rtp'] = caps.codecs;
    mline['fmtp'] = caps.fmtp;
    mline['rtcpFb'] = caps.rtcpFb;
    return true;
  }

  Map<String, dynamic>? _mline(String kind) {
    var mlist = _session['media'] as List<dynamic>;
    return mlist.firstWhere((element) => element['type'] == kind,
        orElse: () => null);
  }

  H264CodecProfile getH264CodecProfile(String h264Payload) {
    var mline = _mline('video');
    if (mline == null) {
      return H264CodecProfile.unknown;
    }

    var fmtpList = mline['fmtp'] ?? <dynamic>[];
    for (var fmtp in fmtpList) {
      if (fmtp['payload'].toString() == h264Payload) {
        var config = fmtp['config'] ?? '';
        var profileMatch =
            RegExp(r'profile-level-id=([0-9a-fA-F]{6})').firstMatch(config);
        if (profileMatch != null) {
          var profileId = profileMatch.group(1);
          switch (profileId) {
            case '42001f':
              return H264CodecProfile.baseline;
            case '42e01f':
              return H264CodecProfile.constrainedBaseline;
            case '4d001f':
              return H264CodecProfile.main;
            case '64001f':
              return H264CodecProfile.high;
            default:
              return H264CodecProfile.unknown;
          }
        }
      }
    }
    return H264CodecProfile.unknown;
  }
}
