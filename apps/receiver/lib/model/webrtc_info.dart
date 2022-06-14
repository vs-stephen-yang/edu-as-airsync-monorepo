class WebRTCInfo {
  static final WebRTCInfo _instance = WebRTCInfo.internal();

  static WebRTCInfo getInstance() {
    return _instance;
  }

  WebRTCInfo.internal();

  String? instanceId;
  String token = '';
  String displayCode = '';
  String licenseName = '';
  List<String> featureList = [];
  String otpCode = '';
  int otpTimer = 0;

  bool isUIStateChanged = true;

  PresentationState presentationState = PresentationState.stopStreaming;

  bool moderatorMode = false;
  bool isModeratorLeave = false;
  String? moderatorId;
  String? moderatorName;
  int remainingTime = 0;
  List<double> remainingTimeCheckPoints = [];

  bool isShowDelegate = false;
  bool isShowCode = false;

  String? presenterId;
  String? presenterName;
  String? meetingId;
  String? allowId;
  String? clientId;
  String? nextId;
}

enum PresentationState {
  stopStreaming,
  waitForStream,
  streaming,
}
