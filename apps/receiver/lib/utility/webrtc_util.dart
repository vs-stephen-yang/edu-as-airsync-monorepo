import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/utility/device_feature_adapter.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class WebRTCUtil {
  static String rtpDump = 'WebRTC-Debugging-RtpDump';

  static String getRtpDumpFieldTrails(bool enabled) {
    return rtpDump + (enabled ? '/Enabled/' : '/Disabled/');
  }

  static Future<void> startWebRtcTracingCapture() async {
    final directory = await getApplicationDocumentsDirectory();

    final tracingFilename = path.join(directory.path, 'webrtc-trace.txt');

    await WebRTC.invokeMethod(
      'startInternalTracingCapture',
      {
        'tracingFilename': tracingFilename,
      },
    );
  }

  static Future<void> stopWebRtcTracingCapture() async {
    await WebRTC.invokeMethod('stopInternalTracingCapture');
  }

  // create config for peerconnection
  static Map<String, dynamic> createPcConfiguration(
    List<RtcIceServer>? iceServers,
  ) {
    return {
      'sdpSemantics': 'unified-plan',
      if (iceServers != null)
        'iceServers': iceServers
            .map(
              (e) => {
                if (e.credential != null) 'credential': e.credential,
                if (e.username != null) 'username': e.username,
                'urls': e.urls,
              },
            )
            .toList(),
      'continualGatheringPolicy': DeviceFeatureAdapter.iceGatheringContinually
          ? 'gather_continually'
          : 'gather_once',
    };
  }
}
