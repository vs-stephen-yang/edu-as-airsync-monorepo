import 'package:display_channel/display_channel.dart';

Map<String, dynamic> buildWebRtcConfiguration(
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
  };
}
