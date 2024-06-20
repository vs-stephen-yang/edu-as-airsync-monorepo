import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:display_cast_flutter/settings/channel_config.dart';
import 'package:display_cast_flutter/utilities/channel_util.dart';
import 'package:display_cast_flutter/utilities/log.dart';
import 'package:display_cast_flutter/features/webrtc_connector.dart';
import 'package:display_cast_flutter/model/airsync_bonsoir_service.dart';
import 'package:display_cast_flutter/model/direct_connector.dart';
import 'package:display_cast_flutter/model/remote_screen_client.dart';
import 'package:display_cast_flutter/model/profile.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/utilities/data_display_code.dart';
import 'package:display_cast_flutter/utilities/profile_util.dart';
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
  authenticationRequired,
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

    case ChannelConnectorError.authenticationRequired:
      return ChannelConnectError.authenticationRequired;
  }
}

final ValueNotifier<int> countSecondsValue = ValueNotifier(0);
final ValueNotifier<int> countMinutesValue = ValueNotifier(0);
final ValueNotifier<int> countHoursValue = ValueNotifier(0);
final ValueNotifier<bool> presentingState = ValueNotifier(true);

class ChannelProvider extends ChangeNotifier {
  ChannelProvider(BuildContext context) {
    _apiGateway = AppConfig.of(context)!.settings.urlGateway;
    _profileStore = AppConfig.of(context)!.profileStore;
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

  ChannelReconnectState reconnectState = ChannelReconnectState.idle;

  void setChannelConnectError(ChannelConnectError error) {
    AppAnalytics.instance.trackEvent(
      'connect_error',
      properties: {
        'target': error.name,
      },
    );
    switch (error) {
      case ChannelConnectError.invalidOtp:
        AppAnalytics.instance.trackEvent('invalid_password');
        break;
      case ChannelConnectError.invalidDisplayCode:
      case ChannelConnectError.instanceNotFound:
        AppAnalytics.instance.trackEvent('invalid_display_code');
        break;
      default:
        break;
    }

    _channelConnectError = error;
    notifyListeners();
  }

  late String _apiGateway = '';
  late ProfileStore _profileStore;
  ProfileStore get profileStore => _profileStore;

  DisplayCode? displayCode;
  String? otp;
  Timer? _presentTimer;

  bool _isRtcFirstConnected = false;

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
        presentingState.value = true;
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

  Future<void> presentDeviceListPage() async {
    _setViewState(ViewState.deviceList);
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
    AppAnalytics.instance.trackEvent('connect');

    // Generate a new client Id
    _clientId = const Uuid().v4();
    AppAnalytics.instance.setGlobalProperty('client_id', _clientId!);

    displayCode = decodeDisplayCode(formattedDisplayCode);
    this.otp = otp;

    if (!_isConnectionModeSupported(displayCode!)) {
      setChannelConnectError(ChannelConnectError.connectionModeUnsupported);
      return;
    }

    _channelConnector = DisplayChannelConnector(
      clientId: _clientId!,
      otp: otp,
      displayCode: displayCode!,
      encodedDisplayCode: formattedDisplayCode,
      createConnectionTunnel: (url, bool isReconnect) =>
          WebSocketClientConnection(
        url,
        WebSocketClientConnectionConfig(
          connectionTimeout: defaultTunnelConnectionTimeout,
          retry: getChannelRetryConfig(isReconnect),
          logger: (url, message) => log.fine('tunnel connection: $url $message}'),
        ),
      ),
      createConnectionDirect: (url, bool isReconnect) =>
          WebSocketClientConnection(
        url,
        WebSocketClientConnectionConfig(
          connectionTimeout: defaultDirectConnectionTimeout,
          // allow self-signed certificate
          allowSelfSignedCertificates: true,
          retry: getChannelRetryConfig(isReconnect),
          logger: (url, message) => log.fine('direct connection: $url $message}'),
        ),
      ),
      fetchTunnelUrl: (int instanceIndex) async {
        return await _fetchTunnelUrl(displayCode!.instanceIndex);
      },
      onOpened: (channel, bool isDirectChannel) {
        // Note: To prevent missing events, ensure that the channel's callback is registered promptly.
        // Specifically, register callbacks for 'onChannelMessage' and 'onStateChange'.
        setUpChannel(
          channel,
          formattedDisplayCode,
          isDirectChannel: isDirectChannel,
        );
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

  startDirectConnect({
    required String? otp,
    required AirSyncBonsoirService service,
  }) {
    AppAnalytics.instance.trackEvent('quick_connect');

    // Generate a new client Id
    _clientId = const Uuid().v4();
    AppAnalytics.instance.setGlobalProperty('client_id', _clientId!);

    displayCode = decodeDisplayCode(service.displayCode);
    this.otp = otp;
    DirectConnector connector = DirectConnector(
      clientId: _clientId!,
      displayCode: service.displayCode,
      otp: otp,
      onOpened: (channel) {
        setUpChannel(channel, '', isDirectChannel: true);
      },
      onOpenError: (error) {
        _onChannelOpenFailed(error);
      },
    );

    connector.open(service: service);
  }

  void setUpChannel(
    Channel channel,
    String formattedDisplayCode, {
    required bool isDirectChannel,
  }) {
    AppAnalytics.instance.trackEvent('connect_successfully', properties: {
      'target': isDirectChannel ? 'direct' : 'tunnel',
    });

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
          if (formattedDisplayCode.isNotEmpty) {
            DataDisplayCode.getInstance().save(formattedDisplayCode);
          }
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
            if (moderatorStatus) {
              // moderator mode need keep sender in moderator list,
              // do not send present end event.
            } else {
              presentEnd();
            }
          }
          break;
        case ChannelMessageType.presentSignal:
          webRTCConnector?.handleSignal(message as PresentSignalMessage);
          break;
        case ChannelMessageType.changePresentQuality:
          unawaited(webRTCConnector?.changePresentQuality(message.toJson()));
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
    log.info('Channel state: ${state.name}');
    AppAnalytics.instance.trackEvent('channel_state', properties: {
      'state': state.name,
    });

    switch (state) {
      case ChannelState.initialized:
        break;
      case ChannelState.connecting:
        reconnectState = ChannelReconnectState.reconnecting;
        notifyListeners();
        break;
      case ChannelState.connected:
        if (reconnectState == ChannelReconnectState.reconnecting) {
          reconnectState = ChannelReconnectState.success;
          notifyListeners();
        }
        break;
      case ChannelState.closed:
        if (reconnectState == ChannelReconnectState.reconnecting) {
          reconnectState = ChannelReconnectState.fail;
        }

        // The receiver closes the channel when the RTC connection is not established or encounters a failure
        _handleRtcConnectionErrors();

        _handleChannelCloseState(_channel?.closeReason);
        break;
    }
  }

  Future<void> presentStart({
    required dynamic selectedSource,
    bool systemAudio = false,
  }) async {
    _isRtcFirstConnected = false;

    // PeerConnect
    webRTCConnector = WebRTCConnector(
      preset: _profileStore.getSelectedProfile().presets.first,
      systemAudio: systemAudio,
      sendSignalMessage: (json) {
        // offer, answer, candidate
        json.sessionId = _sessionId;
        _channel?.send(json);
      },
      onConnectionState: _onRtcConnectionState,
    );
    webRTCConnector?.onStreamInterrupted = (() async {
      presentStop();
      if (moderatorStatus) {
        presentModeratorWaitPage();
      } else {
        presentEnd();
      }
    });
    await webRTCConnector
        ?.makeCall(selectedSource, _iceServerList)
        .then((value) {
      log.info('makeCall: ${value ? 'success' : 'failure'}');
      if (value) {
        if (moderatorStatus) {
          presentModeratorStartPage();
        } else {
          presentBasicStartPage();
        }
      } else {
        presentStop();
        if (moderatorStatus) {
          presentModeratorWaitPage();
        } else {
          presentEnd();
        }
      }
    });
  }

  Future<void> presentEnd({bool goIdleState = true}) async {
    try {
      if (webRTCConnector != null) await webRTCConnector?.hangUp();
      webRTCConnector = null;

      await closeChannel();
    } catch (e, stackTrace) {
      log.severe('presentEnd', e, stackTrace);
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
  Future<bool> presentChangeHighQuality({required bool isHighQuality}) async {
    if (isHighQuality) {
      _profileStore.setSelectedProfile(ProfileStore.videoQualityFirstProfile);
    } else {
      _profileStore.setSelectedProfile(ProfileStore.videoSmoothnessFirstProfile);
    }
    Preset preset = _profileStore.getSelectedProfile().presets.first;
    bool result = await webRTCConnector?.updateEncodingPreset(preset) ?? false;
    ProfileUtil.saveSelectedProfile(_profileStore.getSelectedProfile().name);
    if (result) {
      log.info('updateEncodingPreset success');
    } else {
      log.info('updateEncodingPreset fail');
    }
    return result;
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
    log.info('Closing the channel');

    await _channel?.close(ChannelCloseReason(ChannelCloseCode.close));
    _channel = null;
    reconnectState = ChannelReconnectState.idle;
    // clear client_id
    _clientId = null;
    AppAnalytics.instance.setGlobalProperty('client_id', '');
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
    log.warning('Failed to open channel $error');

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

  bool isConnectAvailable() {
    if (reconnectState == ChannelReconnectState.reconnecting || reconnectState == ChannelReconnectState.fail) return false;
    return true;
  }

  void _handleChannelCloseState(ChannelCloseReason? closeReason) {
    AppAnalytics.instance.trackEvent('channel_closed', properties: {
      'code': closeReason?.code.toString() ?? '',
      'text': closeReason?.text ?? '',
    });

    ChannelCloseCode? reasonCode = closeReason?.code;
    switch (reasonCode) {
      // TODO
      default:
        presentEnd();
        break;
    }
  }

  _trackFetchError(String errorType, String details) {
    log.warning('Failed to fetch the instance info. $errorType $details');

    AppAnalytics.instance.trackEvent('request_get_instance_error', properties: {
      'error': errorType,
      'details': details,
    });
  }

  Future<String> _fetchTunnelUrl(int instanceIndex) async {
    late http.Response response;

    try {
      response = await http
          .get(Uri.parse('$_apiGateway?instanceIndex=$instanceIndex'));
    } on SocketException catch (e) {
      _trackFetchError('SocketException', e.toString());

      throw FetchChannelTunnelUrlException(
        FetchChannelTunnelUrlError.networkError,
      );
    } on http.ClientException catch (e) {
      _trackFetchError('http.ClientException', e.toString());

      throw FetchChannelTunnelUrlException(
        FetchChannelTunnelUrlError.networkError,
      );
    } catch (e) {
      _trackFetchError('Exception', e.toString());

      throw FetchChannelTunnelUrlException(
        FetchChannelTunnelUrlError.unknownError,
      );
    }

    if (response.statusCode != HttpStatus.ok) {
      _trackFetchError('StatusCode', response.statusCode.toString());

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
      _trackFetchError('FormatException', e.toString());

      throw FetchChannelTunnelUrlException(
        FetchChannelTunnelUrlError.unknownError,
      );
    }

    final url = json['tunnelApiUrl'];
    if (url == null) {
      _trackFetchError('InvalidResponse', 'tunnelApiUrl is empty');

      throw FetchChannelTunnelUrlException(
        FetchChannelTunnelUrlError.instanceNotFound,
      );
    }

    return url as String;
  }

  void _onRtcConnectionState(RTCPeerConnectionState state) {
    switch(state) {
      case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
        _onRtcConnectionConnected();
        break;

      case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
        _onRtcConnectionFailed();
        break;

      default:
        break;
    }
  }

  void _onRtcConnectionConnected() {
    if (!_isRtcFirstConnected) {
      AppAnalytics.instance.trackEvent('cast_successfully');
    } else {
      _isRtcFirstConnected = true;
    }
  }

  void _onRtcConnectionFailed() {
    _handleRtcConnectionErrors();
  }

  void _handleRtcConnectionErrors() {
    if (_isRtcFirstConnected) {
      // When users lose the webrtc connection while casting
      AppAnalytics.instance.trackEvent('cast_fail');
    } else {
      // When users fail to cast their screen on the first attempt
      AppAnalytics.instance.trackEvent('cast_error');
    }
  }
}
