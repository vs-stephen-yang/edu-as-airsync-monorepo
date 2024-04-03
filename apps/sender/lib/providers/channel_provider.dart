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
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:uuid/uuid.dart';

import '../generated/l10n.dart';
import '../widgets/toast.dart';

enum ChannelConnectError {
  instanceNotFound,
  rateLimitExceeded,
  networkError,
  invalidDisplayCode,
  invalidOtp,
  connectionModeUnsupported,
  unknownError,
}

// convert ChannelConnectorError to ChannelConnectError
ChannelConnectError mapChannelConnectError(ChannelConnectorError error) {
  switch (error) {
    case ChannelConnectorError.networkError:
      return ChannelConnectError.networkError;

    case ChannelConnectorError.rateLimitExceeded:
      return ChannelConnectError.rateLimitExceeded;

    case ChannelConnectorError.unknownError:
      return ChannelConnectError.unknownError;

    case ChannelConnectorError.instanceNotFound:
      return ChannelConnectError.instanceNotFound;

    case ChannelConnectorError.invalidDisplayCode:
      return ChannelConnectError.invalidDisplayCode;

    case ChannelConnectorError.authenticationError:
      return ChannelConnectError.invalidOtp;
  }
}

final ValueNotifier<int> countSecondsValue = ValueNotifier(0);
final ValueNotifier<int> countMinutesValue = ValueNotifier(0);
final ValueNotifier<int> countHoursValue = ValueNotifier(0);
final ValueNotifier<bool> presentingState = ValueNotifier(true);

class ChannelProvider extends ChangeNotifier {
  ChannelProvider(BuildContext context) {
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

  JoinIntentType currentRole = JoinIntentType.present;

  ChannelConnectError? _channelConnectError;

  ChannelConnectError? get channelConnectError => _channelConnectError;

  void setChannelConnectError(ChannelConnectError error) {
    _channelConnectError = error;
    notifyListeners();
  }

  late String _apiGateway = '';
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
  _setViewState(ViewState newViewState) {
    _currentState = newViewState;
    switch (newViewState) {
      case ViewState.idle:
      case ViewState.moderatorWait:
        if (_presentTimer != null) {
          _presentTimer!.cancel();
          _presentTimer = null;
        }
        break;
      case ViewState.presentStart:
      case ViewState.moderatorStart:
        if (_presentTimer != null) {
          _presentTimer!.cancel();
          _presentTimer = null;
        }
        countSecondsValue.value = 0;
        countMinutesValue.value = 0;
        countHoursValue.value = 0;
        _presentTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (presentingState.value) {
            countSecondsValue.value++;
          }
          if (countSecondsValue.value == 60) {
            countSecondsValue.value = 0;
            countMinutesValue.value++;
          }
          if (countMinutesValue.value == 60) {
            countMinutesValue.value = 0;
            countHoursValue.value++;
          }
        });
        break;
      default:
        break;
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
    _setViewState(ViewState.idle);
  }

  Future<void> presentSelectRolePage() async {
    _setViewState(ViewState.selectRole);
  }

  Future<void> presentSelectScreenPage() async {
    _setViewState(ViewState.selectScreen);
  }

  Future<void> presentBasicStartPage() async {
    _setViewState(ViewState.presentStart);
  }

  Future<void> presentRemoteScreenPage() async {
    _setViewState(ViewState.remoteScreen);
  }

  Future<void> presentModeratorNamePage() async {
    _setViewState(ViewState.moderatorName);
  }

  Future<void> presentModeratorWaitPage() async {
    _setViewState(ViewState.moderatorWait);
  }

  Future<void> presentModeratorStartPage() async {
    _setViewState(ViewState.moderatorStart);
  }

  Future<void> presentSettingPage() async {
    _setViewState(ViewState.settings);
  }

  Future<void> presentLanguagePage() async {
    _setViewState(ViewState.language);
  }

  //endregion

  bool _isConnectionModeSupported(DisplayCode displayCode) {
    if (kIsWeb) {
      // web does not support direct connection
      return displayCode.hasInstanceIndex();
    } else {
      // other platforms support direct and tunnel connections
      return true;
    }
  }

  startConnect({
    required String formattedDisplayCode,
    required String otp,
  }) async {
    // Generate a new client Id
    _clientId = const Uuid().v4();
    final encodedDisplayCode = formattedDisplayCode.replaceAll('-', '');

    displayCode = decodeDisplayCode(encodedDisplayCode);
    this.otp = otp;

    if (!_isConnectionModeSupported(displayCode!)) {
      setChannelConnectError(ChannelConnectError.connectionModeUnsupported);
      return;
    }

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
          allowSelfSignedCertificates: true,
          // allow self-signed certificate
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
          resetMessage();
          DataDisplayCode.getInstance().save(formattedDisplayCode);
          _onDisplayStatus(message as DisplayStatusMessage);
          break;
        case ChannelMessageType.presentAccepted:
          _onPresentAccepted(message as PresentAcceptedMessage);
          break;
        case ChannelMessageType.joinDisplayRejected:
          Reason? reason = (message as JoinDisplayRejectedMessage).reason;

          if (currentRole == JoinIntentType.present) {
            if (reason?.code ==
                JoinDisplayRejectedReasonCode.maxClientsReached.code) {
              Toast.makeToast(S.current.toast_maximum_moderated);
            }
            presentEnd();
          } else {
            if (reason?.code ==
                JoinDisplayRejectedReasonCode.maxClientsReached.code) {
              Toast.makeToast(S.current.toast_maximum_remote_screen);
            }
          }
          break;
        case ChannelMessageType.presentRejected:
          Reason? reason = (message as PresentRejectedMessage).reason;

          if (currentRole == JoinIntentType.present) {
            if (reason?.code ==
                PresentRejectedReasonCode.maxPresentReached.code) {
              Toast.makeToast(S.current.toast_maximum_split_screen);
            }
            presentEnd();
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
            if (!kIsWeb && Platform.isIOS) {
              UndoManager.setUndoState(canUndo: false, canRedo: false);
            }
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

  void _onPresentAccepted(PresentAcceptedMessage message) {
    _iceServerList = message.iceServers;

    // select screen
    presentSelectScreenPage();
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
    if (currentRole == JoinIntentType.present) {
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
    _channelConnectError = null;
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
    _moderatorStatus = message.status!.moderator!;

    presentSelectRolePage();
  }

  Future _requestRemoteScreen() async {
    _remoteScreenClient = RemoteScreenClient(_channel);
    _remoteScreenClient?.sendStartRemoteScreenMessage();
  }

  void _onChannelOpenFailed(ChannelConnectorError error) {
    print('Failed to open channel $error');

    presentEnd(goIdleState: false);

    setChannelConnectError(mapChannelConnectError(error));
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
    msg.intent = currentRole;
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
