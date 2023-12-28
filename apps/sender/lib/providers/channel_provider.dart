
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:display_cast_flutter/features/webrtc_connector.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:display_cast_flutter/utilities/data_display_code.dart';
import 'package:display_cast_flutter/utilities/debug_mode_print.dart';
import 'package:display_channel/display_channel.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

enum Mode {
  internet,
  lan
}

class ChannelProvider extends ChangeNotifier {
  ChannelProvider(BuildContext context){
    _urlIce = AppConfig.of(context)!.settings.urlGetIce;
    _apiGateway = AppConfig.of(context)!.settings.urlGateway;
  }

  DisplayChannelClient? _channel;
  final _clientId = const Uuid().v4(); // TODO:GENERATE IT? GET FROM DISPLAY?
  var _sessionId = const Uuid().v4();
  int port = 5100;
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

  late String _urlIce, _apiGateway, _tunnelApiUrl ='';
  DisplayCode? displayCode;
  String? otp;
  Timer? _presentTimer;
  bool _touchBack = false;
  bool get touchBack => _touchBack;
  set touchBack(bool touchBack) {
    _touchBack = touchBack;
  }
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

  setTouchBack(bool touchBack) {
    webRTCConnector!.touchBack = touchBack;
  }

  bool getTouchBack() {
    return webRTCConnector!.touchBack;
  }

  bool isMainScreen() {
    return webRTCConnector!.isMainSource;
  }

  Future<void> presentMainPage() async {
    setViewState(ViewState.idle);
  }

  Future<void> presentSelectScreenPage() async {
    setViewState(ViewState.selectScreen);
  }

  Future<void> presentBasicStartPage() async {
    setViewState(ViewState.presentStart);
  }

  Future<void> presentModeratorNamePage() async {
    setViewState(ViewState.moderatorName);
  }

  Future<void> presentModeratorWaitPage() async {
    setViewState(ViewState.moderatorWait);
  }

  Future<void> presentModeratorStartPage() async {
    setViewState(ViewState.moderatorStart);
  }

  Future<void> presentSettingPage() async {
    setViewState(ViewState.settings);
  }

  Future<void> presentLanguagePage() async {
    setViewState(ViewState.settings);
  }
  //endregion

  presentInternetMode(String displayCode, String otp) {
    this.displayCode = decodeDisplayCode(displayCode.replaceAll('-', ''));
    this.otp = otp;
    if (this.displayCode != null) {
      startConnect(
          displayCode: this.displayCode!.instanceIndex.toString(), token: otp);
    }
  }

  presentLanMode(String displayCode, String otp) {
    this.displayCode = decodeDisplayCode(displayCode.replaceAll('-', ''));
    this.otp = otp;
    if (this.displayCode != null) {
      startConnect(host: this.displayCode!.ipAddress, token: otp);
    }
  }

  startConnect(
      {String? host, String? displayCode, required String token}) async {
    Uri? uri;
    if (currentMode == Mode.internet) {
      await _getTunnelUrl(displayCode!).then((value) => _tunnelApiUrl = value);
      uri = Uri.parse(_tunnelApiUrl);
    } else {
      uri = Uri(scheme: 'ws', host: host, port: port);
    }

    _channel = DisplayChannelClient(_clientId, uri,
        (url, headers) => WebSocketClientConnection(url, headers));

    _channel?.onStateChange = (ChannelState state) {
      switch (state) {
        case ChannelState.initialized:
          break;
        case ChannelState.connecting:
          break;
        case ChannelState.connected:
          break;
        case ChannelState.disconnected:
          presentEnd();
          break;
        case ChannelState.closed:
          presentEnd();
          break;
      }
    };
    _channel?.onChannelMessage = (message) {
      switch (message.messageType) {
        case ChannelMessageType.channelConnected:
          // heartbeatInterval
          // reconnectionToken?
          break;
        case ChannelMessageType.displayStatus:
          DataDisplayCode.getInstance().save(displayCode!);
          _onDisplayStatus(message as DisplayStatusMessage);
          break;
        case ChannelMessageType.presentAccepted:
          // select screen
          if (moderatorStatus) {
            presentSelectScreenPage();
          } else {
            presentSelectScreenPage();
          }
          break;
        case ChannelMessageType.presentRejected:
          // show a message
          // TODO:check the rejected reason
          if (moderatorStatus) {
            presentMainPage();
          }
          presentEnd();
          break;
        case ChannelMessageType.presentSignal:
          webRTCConnector?.handleSignal(message as PresentSignalMessage);
          break;
        case ChannelMessageType.changePresentQuality:
          webRTCConnector?.changeStreamFrameRate(message.toJson());
          break;
        case ChannelMessageType.stopPresent:
          // split-screen / moderator mode
          if (moderatorStatus) {
            presentStop();
            presentModeratorWaitPage();
          }
          break;
        case ChannelMessageType.allowPresent:
          // moderator mode
          _sessionId = (message as AllowPresentMessage).sessionId!;
          _startPresent();
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
    webRTCConnector = WebRTCConnector(_urlIce,
      systemAudio: systemAudio,
      sendSignalMessage: (json) {
        // offer, answer, candidate
        json.sessionId = _sessionId;
        _channel?.send(json);
      },
    );
    await webRTCConnector?.makeCall(_clientId, selectedSource, _iceServerList); // TODO: _clientId

    if (moderatorStatus) {
      presentModeratorStartPage();
    } else {
      presentBasicStartPage();
    }
  }

  Future<void> presentEnd({bool goIdleState = true}) async {
    try {
      if (webRTCConnector != null) await webRTCConnector?.hangUp();
      webRTCConnector = null;

      await _channel?.close(ChannelCloseReason(ChannelCloseCode.close));
      _channel = null;
    } catch (e) {
      debugModePrint(e, type: runtimeType);
    }

    if (goIdleState) {
      resetMessage();
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
    var message = PausePresentMessage(_sessionId);
    _channel?.send(message);
  }

  Future<void> presentResume() async {
    // handle stream
    var message = ResumePresentMessage(_sessionId);
    _channel?.send(message);
  }

  void setModeratorName(String name) {
    _joinDisplay(name: name);
    presentModeratorWaitPage();
  }

  void resetMessage() {
    _exceedMaximumPresenters = false;
  }

  /// get IceServer list and send join-display, start-present
  void _onDisplayStatus(DisplayStatusMessage message) {
    _iceServerList = message.configuration?.iceServers;
    _moderatorStatus = message.status!.moderator!;
    if(_moderatorStatus) {
      presentModeratorNamePage();
    } else {
      _joinDisplay();
      _startPresent();
    }
  }

  //region sendMessage
  void _joinDisplay({String? name}) {
    JoinDisplayMessage msg = JoinDisplayMessage(_clientId);
    if (name != null) {
      msg.name = name;
    }
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

  Future<String> _getTunnelUrl(String displayCode) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$_apiGateway?displayCode=$displayCode'));
      if (response.statusCode >= HttpStatus.ok &&
          response.statusCode < HttpStatus.multiStatus) {
        Map<String, dynamic> json = jsonDecode(response.body);

        return json['tunnelApiUrl'] ?? '';
      }
    } catch (e) {
      // http.get maybe no network connection.
    }
    return '';
  }
}