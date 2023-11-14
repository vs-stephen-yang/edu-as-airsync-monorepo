
import 'dart:async';

import 'package:display_cast_flutter/features/webrtc_connector.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/debug_mode_print.dart';
import 'package:display_channel/display_channel.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

enum Mode {
  internet,
  lan
}

class ChannelProvider extends ChangeNotifier {
  ChannelProvider(BuildContext context);

  DisplayChannelClient? _channel;
  final _clientId = const Uuid().v4(); // TODO:GENERATE IT? GET FROM DISPLAY?
  final _sessionId = const Uuid().v4();

  WebRTCConnector? webRTCConnector;
  List<RtcIceServer>? _iceServerList;

  bool _moderatorStatus = false;
  bool get moderatorStatus => _moderatorStatus;
  bool _exceedMaximumPresenters = false;
  bool get exceedMaximumPresenters => _exceedMaximumPresenters;

  ViewState _currentState = ViewState.idle;
  ViewState get state => _currentState;
  set currentState(ViewState value) {
    _currentState = value;
  }

  Mode _currentMode = Mode.internet;
  Mode get currentMode => _currentMode;
  set currentMode(Mode value) {
    _currentMode = value;
    notifyListeners();
  }

  Timer? _presentTimer;
  bool _touchBack = false;
  bool get touchBack => _touchBack;
  bool _systemAudio = false;
  bool get systemAudio => _systemAudio;

  //region setView
  setViewState(ViewState newViewState) {
    _currentState = newViewState;
    if (_presentTimer != null) {
      _presentTimer!.cancel();
      _presentTimer = null;
    }
    notifyListeners();
  }

  Future<void> presentMainPage() async {
    setViewState(ViewState.idle);
  }

  Future<void> presentSelectScreen() async {
    setViewState(ViewState.selectScreen);
  }

  Future<void> presentBasicStart() async {
    setViewState(ViewState.presentStart);
  }

  Future<void> presentModeratorStart() async {
    setViewState(ViewState.moderatorStart);
  }
  //endregion

  presentInternetMode(String displayCode, String token) {
    startConnect(displayCode: displayCode, token: token);
  }

  presentLanMode(String host, int port, String token) {
    startConnect(host: host, port: port, token: token);
  }

  startConnect({String? host, int? port, String? displayCode, required String token}) {
    debugModePrint('startConnect ${currentMode.name} $host $port $displayCode $token', type: runtimeType);

    Uri uri = currentMode == Mode.internet
        ? Uri.parse('wss://yu438hq3bi.execute-api.us-east-1.amazonaws.com/dev/')
        : Uri(scheme: 'ws', host: host, port: port);

    _channel = DisplayChannelClient(_clientId, uri,
        (url, headers) => WebSocketClientConnection(url, headers));
    _channel?.onStateChange = (ChannelState state) {
      debugModePrint('startLanModeConnect onStateChange $state',
          type: runtimeType);
    };
    _channel?.onChannelMessage = (message) {
      debugModePrint('startLanModeConnect onChannelMessage $message',
          type: runtimeType);

      switch (message.messageType) {
        case ChannelMessageType.channelConnected:
          // heartbeatInterval
          // reconnectionToken?
          break;
        case ChannelMessageType.displayStatus:
          _onDisplayStatus(message as DisplayStatusMessage);
          break;
        case ChannelMessageType.presentAccepted:
          // select screen
          presentSelectScreen();
          break;
        case ChannelMessageType.presentRejected:
          // show a message
        //TODO:check the rejected reason
          break;
        case ChannelMessageType.presentSignal:
          webRTCConnector?.handleSignal(message as PresentSignalMessage);
          break;
        case ChannelMessageType.presentChangeQuality:
          webRTCConnector?.changeStreamFrameRate(message.toJson());
          break;
        case ChannelMessageType.stopPresent:
          // split-screen / moderator mode
          break;
        case ChannelMessageType.allowPresent:
          // moderator mode
          break;
        default:
          break;
      }
    };

    if(currentMode == Mode.internet) {
      _channel?.openTunnelChannel(displayCode!, token);
    } else {
      _channel?.openDirectChannel(token);
    }
  }

  Future<void> presentStart({required dynamic selectedSource, bool systemAudio = false}) async {
    // PeerConnect
    webRTCConnector = WebRTCConnector(
      touchBack: touchBack,
      systemAudio: systemAudio,
      sendSignalMessage: (json) {
        // offer, answer, candidate
        json.addAll({
          'sessionId': _sessionId
        });
        _channel?.send(PresentSignalMessage.fromJson(json));
      },
    );
    webRTCConnector?.makeCall(_clientId, selectedSource, _iceServerList); // TODO: _clientId

    if (moderatorStatus) {
      presentModeratorStart();
    } else {
      presentBasicStart();
    }
  }

  Future<void> presentEnd({bool goIdleState = true}) async {
    try {
      if (webRTCConnector != null) await webRTCConnector?.hangUp();
      webRTCConnector = null;

      _channel?.close();
      _channel = null;
    } catch (e) {
      debugModePrint(e, type: runtimeType);
    }

    if (goIdleState) {
      _resetMessage();
      presentMainPage();
    }
  }

  Future<void> presentStop() async {
    // handle stream
    webRTCConnector?.streamStop();
    webRTCConnector?.hangUp();
    // send command
    _stopPresent();
  }

  Future<void> presentPause() async {
    // handle stream
    webRTCConnector?.streamPause();
  }

  Future<void> presentResume() async {
    // handle stream
    webRTCConnector?.streamResume();
  }

  _resetMessage() {
    _exceedMaximumPresenters = false;
  }

  /// get IceServer list and send join-display, start-present
  void _onDisplayStatus(DisplayStatusMessage message) {
    _iceServerList = message.configuration?.iceServers;
    _moderatorStatus = message.status!.moderator!;
    if(_moderatorStatus) {

    } else {
      _joinDisplay();
      _startPresent();
    }
  }

  //region sendMessage
  void _joinDisplay() {
    final msg = JoinDisplayMessage(_clientId);
    _channel?.send(msg);
  }

  void _startPresent() {
    final msg = StartPresentMessage(_sessionId);
    _channel?.send(msg);
  }

  void _stopPresent() {
    final msg = StopPresentMessage();
    msg.sessionId = _sessionId;
    _channel?.send(msg);
  }
  //endregion
}