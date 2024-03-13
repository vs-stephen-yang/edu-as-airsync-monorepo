import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:display_cast_flutter/features/webrtc_connector.dart';
import 'package:display_cast_flutter/model/remote_screen_client.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:display_cast_flutter/utilities/data_display_code.dart';
import 'package:display_cast_flutter/utilities/debug_mode_print.dart';
import 'package:display_channel/display_channel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:uuid/uuid.dart';

import '../generated/l10n.dart';
import '../widgets/toast.dart';

enum RejectReasonType {
  maxModeratorSessions(401),
  maxSplitScreenSessions(402);

  const RejectReasonType(this.code);

  final int code;
}

class ChannelProvider extends ChangeNotifier {
  ChannelProvider(BuildContext context) {
    _urlIce = AppConfig.of(context)!.settings.urlGetIce;
    _apiGateway = AppConfig.of(context)!.settings.urlGateway;
  }

  Channel? _channel;
  DisplayChannelConnector? _channelConnector;

  String? _clientId;
  var _sessionId = const Uuid().v4();
  int port = 5100;
  WebRTCConnector? webRTCConnector;
  List<RtcIceServer>? _iceServerList;

  bool _moderatorStatus = false;

  bool get moderatorStatus => _moderatorStatus;

  ViewState _currentState = ViewState.idle;

  ViewState get state => _currentState;

  set currentState(ViewState value) {
    _currentState = value;
  }

  JoinIntentType _currentRole = JoinIntentType.present;

  JoinIntentType get currentRole => _currentRole;

  set currentRole(JoinIntentType value) {
    _currentRole = value;
  }

  bool _exceedMaximumPresenters = false;

  bool get exceedMaximumPresenters => _exceedMaximumPresenters;

  bool _invalidOtp = false;

  bool get invalidOtp => _invalidOtp;

  void setInvalidOtp(bool b) {
    _invalidOtp = b;
    _invalidDisplayCode = !b;
    notifyListeners();
  }

  bool _invalidDisplayCode = false;

  bool get invalidDisplayCode => _invalidDisplayCode;

  void setInvalidDisplayCode(bool b) {
    _invalidDisplayCode = b;
    _invalidOtp = !b;
    notifyListeners();
  }

  late String _urlIce, _apiGateway = '';
  DisplayCode? displayCode;
  String? otp;
  Timer? _presentTimer;

  bool _touchBack = false;

  bool get touchBack => _touchBack;

  set touchBack(bool touchBack) {
    _touchBack = touchBack;
  }

  RemoteScreenClient? _remoteScreenClient;

  RemoteScreenClient? get remoteScreenClient => _remoteScreenClient;

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

  bool showTouchBack() {
    return (WebRTC.platformIsWindows || WebRTC.platformIsMacOS) &&
        (webRTCConnector!.isMainSource);
  }

  Future<void> presentMainPage() async {
    setViewState(ViewState.idle);
  }

  Future<void> presentSelectRolePage() async {
    setViewState(ViewState.selectRole);
  }

  Future<void> presentSelectScreenPage() async {
    setViewState(ViewState.selectScreen);
  }

  Future<void> presentBasicStartPage() async {
    setViewState(ViewState.presentStart);
  }

  Future<void> presentRemoteScreenPage() async {
    setViewState(ViewState.remoteScreen);
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
    setViewState(ViewState.language);
  }

  //endregion

  startConnect({
    required String formattedDisplayCode,
    required String otp,
  }) async {
    // Generate a new client Id
    _clientId = const Uuid().v4();
    final encodedDisplayCode = formattedDisplayCode.replaceAll('-', '');

    displayCode = decodeDisplayCode(encodedDisplayCode);
    this.otp = otp;

    _channelConnector = DisplayChannelConnector(
      clientId: _clientId!,
      otp: otp,
      displayCode: displayCode!,
      encodedDisplayCode: encodedDisplayCode,
      createConnectionTunnel: (url) => WebSocketClientConnection(url,
          maxRetryDelay: const Duration(seconds: 3),
          maxRetryAttempts: 3,
          logger: (url, message) => print('tunnel connection: $url $message}')),
      createConnectionDirect: (url) => WebSocketClientConnection(url,
          maxRetryDelay: const Duration(seconds: 3),
          maxRetryAttempts: 3,
          logger: (url, message) => print('direct connection: $url $message}')),
      fetchTunnelUrl: (int instanceIndex) async {
        return await _fetchTunnelUrl(displayCode!.instanceIndex);
      },
      onOpened: (channel) {
        // Note: To prevent missing events, ensure that the channel's callback is registered promptly.
        // Specifically, register callbacks for 'onChannelMessage' and 'onStateChange'.
        setUpChannel(channel, formattedDisplayCode);
      },
      onOpenError: (error) {
        _onChannelOpenFailed(error);
      },
    );

    _channelConnector!.open(
      // Web does not support direct channel connection
      directPort: kIsWeb ? null : port,
    );
  }

  void setUpChannel(Channel channel, String formattedDisplayCode) {
    _channel = channel;

    _channel?.onStateChange = (ChannelState state) {
      onChannelStateChange(state);
    };
    _channel?.onChannelMessage = (message) async {
      switch (message.messageType) {
        case ChannelMessageType.channelConnected:
          // heartbeatInterval
          // reconnectionToken?
          break;
        case ChannelMessageType.displayStatus:
          _invalidDisplayCode = false;
          _invalidOtp = false;
          DataDisplayCode.getInstance().save(formattedDisplayCode);
          _onDisplayStatus(message as DisplayStatusMessage);
          break;
        case ChannelMessageType.presentAccepted:
          // select screen
          presentSelectScreenPage();
          break;
        case ChannelMessageType.presentRejected:
          Reason? reason = (message as PresentRejectedMessage).reason;
          if (currentRole == JoinIntentType.present) {
            if (reason?.code == RejectReasonType.maxModeratorSessions.code) {
              Toast.makeToast(S.current.toast_maximum_moderated);
            } else if (reason?.code ==
                RejectReasonType.maxSplitScreenSessions.code) {
              Toast.makeToast(S.current.toast_maximum_split_screen);
            }
            presentEnd();
          } else {
            if (reason?.code == RejectReasonType.maxModeratorSessions.code) {
              Toast.makeToast(S.current.toast_maximum_remote_screen);
            }
          }
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
        case ChannelMessageType.remoteScreenStatus:
          _handleRemoteScreenState(message as RemoteScreenStatusMessage);
          break;
        case ChannelMessageType.remoteScreenInfo:
          RemoteScreenInfoMessage infoMessage =
              message as RemoteScreenInfoMessage;
          await _remoteScreenClient?.handleRemoteScreenInfo(
              infoMessage.ionSfuRoom!.url!, infoMessage.ionSfuRoom!.roomId!,
              () {
            presentRemoteScreenPage();
          },
              // onClose callback
              (int code, String reason) {
            removeRemoteScreenClient();
          });
          break;
        default:
          break;
      }
    };
  }

  void onChannelStateChange(ChannelState state) {
    switch (state) {
      case ChannelState.initialized:
        break;
      case ChannelState.connecting:
        break;
      case ChannelState.connected:
        break;
      case ChannelState.closed:
        _handleChannelCloseState(_channel?.closeReason);
        break;
    }
  }

  Future<void> presentStart({
    required dynamic selectedSource,
    bool systemAudio = false,
  }) async {
    // PeerConnect
    webRTCConnector = WebRTCConnector(
      _urlIce,
      systemAudio: systemAudio,
      sendSignalMessage: (json) {
        // offer, answer, candidate
        json.sessionId = _sessionId;
        _channel?.send(json);
      },
    );
    webRTCConnector?.onStreamInterrupted = (() async {
      presentEnd();
    });
    await webRTCConnector?.makeCall(
      selectedSource,
      _iceServerList,
    );

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

      await closeChannel();
    } catch (e) {
      debugModePrint(e, type: runtimeType);
    }

    if (goIdleState) {
      resetMessage();
      navService.popUntil('/home');
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

  void setSenderName(String name) {
    _joinDisplay(name: name);
    if (_currentRole == JoinIntentType.present) {
      presentModeratorWaitPage();
    } else {
      _requestRemoteScreen();
    }
  }

  Future beginBasicMode() async {
    _joinDisplay();
    _startPresent();
  }

  void resetMessage() {
    _invalidDisplayCode = false;
    _invalidOtp = false;
    _exceedMaximumPresenters = false;
  }

  Future closeChannel() async {
    await _channel?.close(ChannelCloseReason(ChannelCloseCode.close));
    _channel = null;
  }

  void removeRemoteScreenClient() async {
    await remoteScreenClient?.remove();
    await closeChannel();
    presentMainPage();
  }

  /// get IceServer list and send join-display, start-present
  void _onDisplayStatus(DisplayStatusMessage message) async {
    _iceServerList = message.configuration?.iceServers;
    _moderatorStatus = message.status!.moderator!;

    presentSelectRolePage();
  }

  Future _requestRemoteScreen() async {
    _remoteScreenClient = RemoteScreenClient(_channel);
    _remoteScreenClient?.sendStartRemoteScreenMessage();
  }

  void _onChannelOpenFailed(ChannelConnectorError error) {
    print('Failed to open channel $error');

    switch (error) {
      case ChannelConnectorError.networkError:
      // TODO:
      case ChannelConnectorError.rateLimitExceeded:
      // TODO:
      case ChannelConnectorError.unknownError:
      // TODO:
      case ChannelConnectorError.instanceNotFound:
      // TODO:
      case ChannelConnectorError.invalidDisplayCode:
        presentEnd(goIdleState: false);
        setInvalidDisplayCode(true);
        break;
      case ChannelConnectorError.authenticationError:
        presentEnd(goIdleState: false);
        setInvalidOtp(true);
        break;
    }
  }

  Future _handleRemoteScreenState(RemoteScreenStatusMessage message) async {
    switch (message.status) {
      case RemoteScreenStatus.accepted:
        break;
      case RemoteScreenStatus.rejected:
        Toast.makeToast(S.current.toast_enable_remote_screen);
        presentMainPage();
        break;
      case RemoteScreenStatus.kicked:
        removeRemoteScreenClient();
        break;
      case null:
        break;
    }
  }

  //region sendMessage
  void _joinDisplay({String? name}) {
    JoinDisplayMessage msg = JoinDisplayMessage(_clientId);
    msg.intent = _currentRole;
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

  void _handleChannelCloseState(ChannelCloseReason? closeReason) {
    ChannelCloseCode? reasonCode = closeReason?.code;
    switch (reasonCode) {
      // TODO
      default:
        presentEnd();
        break;
    }
  }

  Future<String> _fetchTunnelUrl(int instanceIndex) async {
    late http.Response response;

    try {
      response = await http
          .get(Uri.parse('$_apiGateway?instanceIndex=$instanceIndex'));
    } on SocketException catch (e) {
      print(e);

      throw FetchChannelTunnelUrlException(
        FetchChannelTunnelUrlError.networkError,
      );
    } on http.ClientException catch (e) {
      print(e);

      throw FetchChannelTunnelUrlException(
        FetchChannelTunnelUrlError.networkError,
      );
    } catch (e) {
      print(e);

      throw FetchChannelTunnelUrlException(
        FetchChannelTunnelUrlError.unknownError,
      );
    }

    if (response.statusCode != HttpStatus.ok) {
      if (response.statusCode == HttpStatus.notFound) {
        throw FetchChannelTunnelUrlException(
          FetchChannelTunnelUrlError.instanceNotFound,
        );
      } else {
        throw FetchChannelTunnelUrlException(
          FetchChannelTunnelUrlError.unknownError,
        );
      }
    }

    late Map<String, dynamic> json;

    try {
      json = jsonDecode(response.body);
    } on FormatException catch (e) {
      print(e);

      throw FetchChannelTunnelUrlException(
        FetchChannelTunnelUrlError.unknownError,
      );
    }

    final url = json['tunnelApiUrl'];
    if (url == null) {
      throw FetchChannelTunnelUrlException(
        FetchChannelTunnelUrlError.instanceNotFound,
      );
    }

    return url as String;
  }
}
