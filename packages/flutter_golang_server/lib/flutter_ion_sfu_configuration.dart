class IceServer {
  final List<String> urls;
  final String? username;
  final String? credential;

  IceServer(
    this.urls, {
    this.username,
    this.credential,
  });

  Map<String, Object> toMap() {
    return {
      'urls': urls,
      if (username != null) 'username': username!,
      if (credential != null) 'credential': credential!,
    };
  }
}

class FlutterIonSfuConfiguration {
  final int ballast;
  final bool withStats;
  final int maxBandwidth;
  final int maxPacketTrack;
  final int audioLevelThreshold;
  final int audioLevelInterval;
  final int audioLevelFilter;
  final bool bestQualityFirst;
  final bool enableTemporalLayer;
  final int icePortRangeStart;
  final int icePortRangeEnd;
  final String sdpSemantics;
  final bool mdns;
  final int iceDisconnectedTimeout;
  final int iceFailedTimeout;
  final int iceKeepaliveInterval;
  final String credentials;
  final List<IceServer>? iceServers;

  FlutterIonSfuConfiguration({
    this.ballast = 0,
    this.withStats = false,
    this.maxBandwidth = 1500,
    this.maxPacketTrack = 500,
    this.audioLevelThreshold = 40,
    this.audioLevelInterval = 1000,
    this.audioLevelFilter = 20,
    this.bestQualityFirst = true,
    this.enableTemporalLayer = false,
    this.icePortRangeStart = 5000,
    this.icePortRangeEnd = 5200,
    this.sdpSemantics = 'unified-plan',
    this.mdns = true,
    this.iceDisconnectedTimeout = 5,
    this.iceFailedTimeout = 25,
    this.iceKeepaliveInterval = 2,
    this.credentials = 'pion=ion,pion2=ion2',
    this.iceServers,
  });

  Map<String, Object> toMap() {
    return {
      'ballast': ballast,
      'withStats': withStats,
      'maxBandwidth': maxBandwidth,
      'maxPacketTrack': maxPacketTrack,
      'audioLevelThreshold': audioLevelThreshold,
      'audioLevelInterval': audioLevelInterval,
      'audioLevelFilter': audioLevelFilter,
      'bestQualityFirst': bestQualityFirst,
      'enableTemporalLayer': enableTemporalLayer,
      'icePortRangeStart': icePortRangeStart,
      'icePortRangeEnd': icePortRangeEnd,
      'sdpSemantics': sdpSemantics,
      'mdns': mdns,
      'iceDisconnectedTimeout': iceDisconnectedTimeout,
      'iceFailedTimeout': iceFailedTimeout,
      'iceKeepaliveInterval': iceKeepaliveInterval,
      'credentials': credentials,
      if (iceServers != null)
        'iceServers': iceServers!.map((server) => server.toMap()).toList(),
    };
  }
}
