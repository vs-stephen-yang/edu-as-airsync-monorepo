import 'package:display_channel/display_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebRTCUtil {
  static bool defaultIceGatheringContinually =
      true; // gather_continually by default
  static bool defaultShowDebugOverlay = false;

  static bool iceGatheringContinually = defaultIceGatheringContinually;
  static bool showDebugOverlay = defaultShowDebugOverlay;

  static saveIceGatheringContinually(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("IceGatheringContinually", value);
  }

  static Future<bool> loadIceGatheringContinually() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("IceGatheringContinually") ??
        defaultIceGatheringContinually;
  }

  static saveShowDebugOverlay(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("ShowDebugOverlay", value);
  }

  static Future<bool> loadShowDebugOverlay() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("ShowDebugOverlay") ?? defaultShowDebugOverlay;
  }

  static Map<String, dynamic> buildWebRtcConfiguration(
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
      'continualGatheringPolicy':
          iceGatheringContinually ? 'gather_continually' : 'gather_once',
    };
  }
}
