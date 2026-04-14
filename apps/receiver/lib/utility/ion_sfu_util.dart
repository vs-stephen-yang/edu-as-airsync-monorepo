import 'package:display_channel/display_channel.dart';
import 'package:flutter_golang_server/flutter_ion_sfu_configuration.dart';

FlutterIonSfuConfiguration createIonSfuConfiguration(
  List<RtcIceServer>? rtcIceServers,
) {
  List<IceServer>? iceServers = rtcIceServers
      ?.map(
        (RtcIceServer s) => IceServer(
          s.urls,
          username: s.username,
          credential: s.credential,
        ),
      )
      .toList();

  return FlutterIonSfuConfiguration(
    iceServers: iceServers,
  );
}
