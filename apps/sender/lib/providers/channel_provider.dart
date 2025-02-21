import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:display_cast_flutter/annotation/annotation_model.dart';
import 'package:display_cast_flutter/api/fetch_tunnel_info.dart';
import 'package:display_cast_flutter/api/http_request.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/model/airsync_bonsoir_service.dart';
import 'package:display_cast_flutter/model/direct_connector.dart';
import 'package:display_cast_flutter/model/profile.dart';
import 'package:display_cast_flutter/model/remote_screen_client.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:display_cast_flutter/settings/channel_config.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/utilities/channel_util.dart';
import 'package:display_cast_flutter/utilities/data_display_code.dart';
import 'package:display_cast_flutter/utilities/log.dart';
import 'package:display_cast_flutter/utilities/misc_util.dart';
import 'package:display_cast_flutter/utilities/platform_util.dart';
import 'package:display_cast_flutter/utilities/profile_util.dart';
import 'package:display_cast_flutter/utilities/webrtc_helper.dart';
import 'package:display_cast_flutter/utilities/web_util.dart';
import 'package:display_cast_flutter/widgets/toast.dart';
import 'package:display_cast_flutter/widgets/v3_qrcode_scan.dart';
import 'package:display_channel/display_channel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:uuid/uuid.dart';

// convert ChannelConnectorError to ChannelConnectError
ChannelConnectError mapChannelConnectError(ChannelConnectorError error) {
  switch (error) {
    case ChannelConnectorError.networkError:
      return ChannelConnectError.networkError;

    case ChannelConnectorError.rateLimitExceeded:
      return ChannelConnectError.rateLimitExceeded;

    case ChannelConnectorError.unknownError:
      return ChannelConnectError.unknownError;

    case ChannelConnectorError.instanceOffline:
      // TODO: Return ChannelConnectError.instanceOffline indicating the instance is offline
      return ChannelConnectError.instanceNotFound;

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
    _baseApiUrl = AppConfig.of(context)!.settings.baseApiUrl;
    _profileStore = AppConfig.of(context)!.profileStore;
  }

  Channel? _channel;
  DisplayChannelConnector? _channelConnector;
  RemoteScreenClient? _remoteScreenClient;

  String? _clientId;
  var _sessionId = const Uuid().v4();
  int port = 5100;

  PresentStateProvider? _presentStateProvider;
  late String _baseApiUrl = '';
  late ProfileStore _profileStore;

  DisplayCode? displayCode;
  String? otp;
  Timer? _presentTimer;
  String totalSharingTime = '';

  bool _isRtcFirstConnected = false;
  bool _isPresentingErrorReported = false;

  Timer? _channelReconnectTimer;

  JoinIntentType currentRole = JoinIntentType.present;
  bool _moderatorStatus = false;
  ChannelConnectError? _channelConnectError;
  ChannelReconnectState reconnectState = ChannelReconnectState.idle;

  ProfileStore get profileStore => _profileStore;

  bool get moderatorStatus => _moderatorStatus;

  ChannelConnectError? get channelConnectError => _channelConnectError;

  RemoteScreenClient? get remoteScreenClient => _remoteScreenClient;

  String? deviceName;

  bool isJoinDisplayRejected = false;
  bool isModeratorExitedRejected = false;
  bool isPresentRejected = false;
  bool isReceiverRemoteScreenBusyRejected = false;

  bool get authorizeStatus => _authorizeStatus;
  bool _authorizeStatus = false;

  String get randomName => _randomName;
  String _randomName = '';

  void setChannelConnectError(ChannelConnectError error) {
    trackEvent(
      'connect_fail',
      EventCategory.session,
      target: error.name,
    );

    switch (error) {
      case ChannelConnectError.invalidOtp:
        trackEvent('invalid_password', EventCategory.menu);
        break;
      case ChannelConnectError.invalidDisplayCode:
      case ChannelConnectError.instanceNotFound:
        trackEvent('invalid_display_code', EventCategory.menu);
        break;
      default:
        break;
    }

    _channelConnectError = error;
    notifyListeners();
  }

  startConnect({
    required String formattedDisplayCode,
    required String otp,
    required PresentStateProvider presentStateProvider,
    QRcodeConnectResult? qrCallback,
  }) async {
    trackTrace('connect');
    // Generate a new client Id
    _clientId = const Uuid().v4();
    AppAnalytics.instance.setGlobalProperty('participator_id', _clientId!);

    _presentStateProvider = presentStateProvider;
    displayCode = decodeDisplayCode(formattedDisplayCode);
    this.otp = otp;

    // Retrieve the local IP addresses
    final localIpAddresses = await fetchIPv4Addresses();

    // Generate potential remote IP addresses
    final remoteIpCandidates =
      createRemoteIpCandidates(displayCode!, localIpAddresses);

    _channelConnector = DisplayChannelConnector(
      clientId: _clientId!,
      otp: otp,
      displayCode: displayCode!,
      remoteIpAddresses: remoteIpCandidates,
      encodedDisplayCode: formattedDisplayCode,
      createConnectionTunnel: (url, bool isReconnect) =>
          WebSocketClientConnection(
        url,
        WebSocketClientConnectionConfig(
          connectionTimeout: defaultTunnelConnectionTimeout,
          retry: getChannelRetryConfig(isReconnect),
          logger: (url, message) =>
              log.fine('tunnel connection: $url $message}'),
        ),
      ),
      createConnectionDirect: (url, bool isReconnect) =>
          fetchCreateClientConnection(url, isReconnect),
      fetchTunnelUrl: (int instanceIndex, int instanceGroupId) async {
        return await _fetchTunnelUrl(instanceIndex, instanceGroupId);
      },
      onOpened: (channel, bool isDirectChannel) {
        // Note: To prevent missing events, ensure that the channel's callback is registered promptly.
        // Specifically, register callbacks for 'onChannelMessage' and 'onStateChange'.
        setUpChannel(
          channel,
          formattedDisplayCode,
          isDirectChannel: isDirectChannel,
        );
        qrCallback?.call(true);
      },
      onOpenError: (error) {
        _onChannelOpenFailed(error);
        qrCallback?.call(false);
      },
    );

    _channelConnector!.open(
      directPort: kIsWeb ? 8888 : port,
      useWebTransport: kIsWeb
    );
  }

  mapHttpRequestErrorToFetchException(HttpRequestException exception) {
    switch (exception.error) {
      // 4xx or 5xx
      case HttpRequestError.httpError:
        if (exception.statusCode == 404) {
          return FetchChannelTunnelUrlException(
              FetchChannelTunnelUrlError.instanceNotFound);
        } else if (exception.statusCode == 400) {
          return FetchChannelTunnelUrlException(
              FetchChannelTunnelUrlError.instanceOffline);
        } else {
          return FetchChannelTunnelUrlException(
              FetchChannelTunnelUrlError.unknownError);
        }

      // Network error or request timeout
      case HttpRequestError.networkError:
        return FetchChannelTunnelUrlException(
            FetchChannelTunnelUrlError.networkError);

      // Other errors
      default:
        return FetchChannelTunnelUrlError.unknownError;
    }
  }

  Future<String> _fetchTunnelUrl(instanceIndex, instanceGroupId) async {
    try {
      final result = await fetchTunnelInfo(
        _baseApiUrl,
        instanceIndex,
        instanceGroupId,
      );
      return result.tunnelUrl;
    } catch (e) {
      if (e is HttpRequestException) {
        throw mapHttpRequestErrorToFetchException(e);
      }

      throw FetchChannelTunnelUrlError.unknownError;
    }
  }

  startDirectConnect({
    required String? otp,
    required AirSyncBonsoirService service,
    required PresentStateProvider presentStateProvider,
  }) {
    trackTrace('quick_connect');

    // Generate a new client Id
    _clientId = const Uuid().v4();
    AppAnalytics.instance.setGlobalProperty('participator_id', _clientId!);
    _presentStateProvider = presentStateProvider;
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
    AppAnalytics.instance.setGlobalProperty(
        'connectivity', isDirectChannel ? 'intranet' : 'internet');

    trackEvent(
      'connect_successfully',
      EventCategory.session,
      target: isDirectChannel ? 'direct' : 'tunnel',
    );

    _channel = channel;

    _channel?.stateStream.listen((ChannelState state) {
      onChannelStateChange(state);
    });
    _channel?.messageStream.listen((message) async {
      switch (message.messageType) {
        case ChannelMessageType.channelConnected:
          // heartbeatInterval
          // reconnectionToken?
          break;
        case ChannelMessageType.displayStatus:
          resetMessage();
          if (formattedDisplayCode.isNotEmpty) {
            unawaited(DataDisplayCode.getInstance().save(formattedDisplayCode));
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
              // Toast.makeToast(S.current.toast_maximum_moderated);
              isJoinDisplayRejected = true;
            } else if (reason?.code ==
                JoinDisplayRejectedReasonCode.moderatorExited.code) {
              isModeratorExitedRejected = true;
            } else if (reason?.code ==
                JoinDisplayRejectedReasonCode.receiverRemoteScreenBusy.code) {
              isReceiverRemoteScreenBusyRejected = true;
            }
            unawaited(presentEnd());
          } else {
            if (reason?.code ==
                JoinDisplayRejectedReasonCode.maxClientsReached.code) {
              removeRemoteScreenClient();
              // Toast.makeToast(S.current.toast_maximum_remote_screen);
              isJoinDisplayRejected = true;
            }
          }
          break;
        case ChannelMessageType.presentRejected:
          Reason? reason = (message as PresentRejectedMessage).reason;

          if (currentRole == JoinIntentType.present) {
            if (reason?.code ==
                PresentRejectedReasonCode.maxPresentReached.code) {
              // Toast.makeToast(S.current.toast_maximum_split_screen);
              isPresentRejected = true;
            }
            if (_moderatorStatus) {
              // moderator mode need keep sender in moderator list,
              // do not send present end event.
            } else {
              unawaited(presentEnd());
            }
          }
          break;
        case ChannelMessageType.presentSignal:
          unawaited(WebRTCHelper().receiveSignalMessage(message as PresentSignalMessage));
          break;
        case ChannelMessageType.stopPresent:
          // split-screen / moderator mode
          if (_moderatorStatus) {
            unawaited(presentStop());
            unawaited(_presentStateProvider?.presentModeratorWaitPage());
          }
          break;
        case ChannelMessageType.allowPresent:
          // moderator mode
          _sessionId = (message as AllowPresentMessage).sessionId!;
          _startPresent();
          break;
        case ChannelMessageType.inviteRemoteScreen:
          await _handleInviteRemoteScreen(message as InviteRemoteScreenMessage);
          break;
        case ChannelMessageType.stopRemoteScreen:
          await _handleStopRemoteScreen(message as StopRemoteScreenMessage);
          break;
        case ChannelMessageType.remoteScreenStatus:
          unawaited(_handleRemoteScreenState(message as RemoteScreenStatusMessage));
          break;
        case ChannelMessageType.remoteScreenInfo:
          await _handleRemoteScreenInfo(message as RemoteScreenInfoMessage);
          break;
        case ChannelMessageType.remoteScreenSignal:
          await _handleRemoteScreenSignal(message as RemoteScreenSignalMessage);
          break;
        default:
          break;
      }
    });
  }

  Future<void> _handleRemoteScreenInfo(
    RemoteScreenInfoMessage infoMessage,
  ) async {
    await _remoteScreenClient?.handleRemoteScreenInfo(
      infoMessage.ionSfuRoom!.signalUrl,
      infoMessage.ionSfuRoom!.roomId!,
      infoMessage.ionSfuRoom!.iceServers,
      _onRemoteScreenTrack,
      // onClose callback
      () {
        Toast.makeToast(S.current.remote_screen_connect_error);
        removeRemoteScreenClient();
      },
    );
  }

  void _onRemoteScreenTrack() {
    notifyListeners();
  }

  _handleInviteRemoteScreen(InviteRemoteScreenMessage message) async {
    unawaited(_presentStateProvider?.presentModeratorSharePage());
    unawaited(_requestRemoteScreen());
  }

  _handleStopRemoteScreen(StopRemoteScreenMessage message) async {
    removeShareRemoteScreenClient();
  }

  Future<void> _handleRemoteScreenSignal(
    RemoteScreenSignalMessage message,
  ) async {
    _remoteScreenClient?.handleSignalMessage(message.signal!);
  }

  void _onPresentAccepted(PresentAcceptedMessage message) {
    // get ice servers
    WebRTCHelper().iceServerList = message.iceServers;

    // select screen
    _presentStateProvider?.presentSelectScreenPage();
  }

  // The channel failed to reconnect within the specified timeout period
  void _onChannelReconnectTimeout() {
    log.info('The channel failed to reconnect within the timeout period');

    _channelReconnectTimer = null;
    trackTrace('channel_reconnect_timeout');

    reconnectState = ChannelReconnectState.fail;

    presentEnd();
  }

  void _startChannelReconnectTimer() {
    log.info('Start channel reconnect timer');

    _channelReconnectTimer = Timer(
      channelReconnectTimeoutInIdle,
      _onChannelReconnectTimeout,
    );
  }

  void _stopChannelReconnectTimer() {
    if (_channelReconnectTimer != null) {
      log.info('Stop channel reconnect timer');
      _channelReconnectTimer!.cancel();
      _channelReconnectTimer = null;
    }
  }

  void onChannelStateChange(ChannelState state) {
    log.info('Channel state: ${state.name} ${_channel?.closeReason?.code}');
    trackTrace('channel_state', properties: {
      'target': state.name,
    });

    switch (state) {
      case ChannelState.initialized:
        break;
      case ChannelState.connecting:
        reconnectState = ChannelReconnectState.reconnecting;
        notifyListeners();

        if (!WebRTCHelper().isStreaming()) {
          // If no streaming is active, interrupt if the channel remains disconnected for an period
          _startChannelReconnectTimer();
        }
        break;
      case ChannelState.connected:
        if (reconnectState == ChannelReconnectState.reconnecting) {
          reconnectState = ChannelReconnectState.success;
          notifyListeners();
        }

        _stopChannelReconnectTimer();
        break;
      case ChannelState.closed:
        // The channel will no longer switch its state to "closed" solely because of a disconnection.
        // This means that if a disconnection occurs, the channel will continuously attempt to reconnect without changing the state to "closed".
        // A state change to "closed" will only occur if there is an explicit close request from the peer.

        _handleChannelCloseState(_channel?.closeReason);
        break;
    }
  }

  Future<void> presentStart({
    required dynamic selectedSource,
    bool systemAudio = false,
    bool autoVirtualDisplay = false,
  }) async {
    // reset states
    _isRtcFirstConnected = false;
    _isPresentingErrorReported = false;

    // PeerConnect
    await WebRTCHelper().init(
      sessionId: _sessionId,
      profileStore: profileStore,
      systemAudio: systemAudio,
      autoVirtualDisplay: autoVirtualDisplay,
      sendPresentSignalMessage: (PresentSignalMessage message) {
        // offer, answer, candidate
        message.sessionId = _sessionId;
        _channel?.send(message);
      },
      onRTCPeerConnectionState: _onRtcConnectionState,
      onStreamInterrupted: () async {
        unawaited(presentStop());
        if (_moderatorStatus) {
          unawaited(_presentStateProvider?.presentModeratorWaitPage());
        } else {
          unawaited(presentEnd());
        }
      },
      onStopPresent: () {
        // Received StopPresent from the peer via data channel
        presentStop();
      },
      onTouchEvenWhenPaused: (isPaused, isStop) {
        if (isPaused) {
          presentingState.value = !presentingState.value;
          presentResume();
        }
        if (isStop) {
          presentStop();
          if (_moderatorStatus) {
            _presentStateProvider?.presentModeratorWaitPage();
          } else {
            presentEnd();
          }
        }
      },
    );

    await makeCall(selectedSource: selectedSource);
  }

  Future<void> makeCall({required dynamic selectedSource}) async {
    await WebRTCHelper().start(
        selectedSource: selectedSource,
        onResult: (result) {
          log.info('makeCall: ${result ? 'success' : 'failure'}');
          if (result) {
            if (_moderatorStatus) {
              _presentStateProvider?.presentModeratorStartPage();
            } else {
              _presentStateProvider?.presentBasicStartPage();
            }
            presentingState.value = true;
            _startPresentTimer();
          } else {
            presentStop();
            if (_moderatorStatus) {
              _presentStateProvider?.presentModeratorWaitPage();
            } else {
              presentEnd();
            }
          }
        });
  }

  Future<void> presentEnd({bool goIdleState = true}) async {
    try {
      await WebRTCHelper().close();
      await closeChannel();
    } catch (e, stackTrace) {
      log.severe('presentEnd', e, stackTrace);
    }
    _resetTimer();

    if (goIdleState) {
      resetMessage();
      navService.popUntil('/v3home');
      unawaited(_presentStateProvider?.presentMainPage());
    }

    AnnotationModel.closeAnnotation();
  }

  Future<void> presentStop() async {
    // handle stream
    WebRTCHelper().stop();

    // send command
    _stopPresent();
    _resetTimer();
  }

  Future<void> presentPause({Rect? pauseBtnRect, Rect? stopBtnRect}) async {
    WebRTCHelper().pause(_sessionId,
        pauseBtnRect: pauseBtnRect, stopBtnRect: stopBtnRect);
  }

  Future<void> presentResume() async {
    WebRTCHelper().resume(_sessionId);
  }

  Future<bool> presentChangeHighQuality({required bool isHighQuality}) async {
    if (isHighQuality) {
      _profileStore.setSelectedProfile(ProfileStore.videoQualityFirstProfile);
    } else {
      _profileStore.setSelectedProfile(
        ProfileStore.videoSmoothnessFirstProfile,
      );
    }
    Preset preset = _profileStore.getSelectedProfile().presets.first;
    bool result = await WebRTCHelper().changeHighQuality(preset);
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
      _presentStateProvider?.presentModeratorWaitPage();
    } else {
      if (!kIsWeb && Platform.isIOS) {
        UndoManager.setUndoState(canUndo: false, canRedo: false);
      }
      _presentStateProvider?.presentRemoteScreenPage();

      _requestRemoteScreen();
    }
  }

  Future beginBasicMode() async {
    if (_authorizeStatus) {
      _randomName = generateRandomId(Random());
      _joinDisplay(name: _randomName);
      return;
    }
    _joinDisplay();
  }

  void resetMessage() {
    _channelConnectError = null;
  }

  Future closeChannel() async {
    log.info('Closing the channel');

    _stopChannelReconnectTimer();

    await _channel?.close(ChannelCloseReason(ChannelCloseCode.close));
    _channel = null;
    reconnectState = ChannelReconnectState.idle;
    // clear client_id
    _clientId = null;
    AppAnalytics.instance.setGlobalProperty('participator_id', '');
  }

  void removeRemoteScreenClient() async {
    await remoteScreenClient?.remove();
    await closeChannel();
    _resetTimer();
    unawaited(_presentStateProvider?.presentMainPage());
  }

  void removeShareRemoteScreenClient() async {
    await _remoteScreenClient?.sendStopRemoteScreenMessage();
    await remoteScreenClient?.remove();
    if (_moderatorStatus) {
      unawaited(_presentStateProvider?.presentModeratorWaitPage());
    }
  }

  /// get IceServer list and send join-display, start-present
  void _onDisplayStatus(DisplayStatusMessage message) async {
    _moderatorStatus = message.status!.moderator!;
    _authorizeStatus = message.status!.authorize!;
    deviceName = message.name;
    unawaited(_presentStateProvider?.presentSelectRolePage());
  }

  Future _requestRemoteScreen() async {
    _remoteScreenClient = RemoteScreenClient(_channel);
    unawaited(_remoteScreenClient?.sendStartRemoteScreenMessage());
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
        _resetTimer();
        Toast.makeToast(S.current.toast_enable_remote_screen);
        unawaited(_presentStateProvider?.presentMainPage());
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
    msg.platform = getPlatformName();
    msg.isConnectedViaModeratorMode = _moderatorStatus;

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

    WebRTCHelper().sendStop(_sessionId);
  }

  //endregion

  bool isConnectAvailable() {
    if (reconnectState == ChannelReconnectState.reconnecting ||
        reconnectState == ChannelReconnectState.fail) return false;
    return true;
  }

  bool _isRtcFailedOnRemote(ChannelCloseReason? closeReason) {
    // IMPROVE
    return closeReason?.text?.contains('RTC connection failed') ?? false;
  }

  void _handleChannelCloseState(ChannelCloseReason? closeReason) {
    trackTrace('channel_closed', properties: {
      'target': closeReason?.code.toString() ?? '',
      'details': closeReason?.text ?? '',
    });

    if (_isRtcFailedOnRemote(closeReason)) {
      _reportPresentingErrors();
    }

    presentEnd();
  }

  void _onRtcConnectionState(RTCPeerConnectionState state) {
    switch (state) {
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
      trackTrace('cast_successfully');
      _isRtcFirstConnected = true;
    }

    // Ensure streaming is uninterrupted when the channel connection drops
    _stopChannelReconnectTimer();
  }

  void _onRtcConnectionFailed() {
    _reportPresentingErrors();
  }

  void _reportPresentingErrors() {
    if (_isPresentingErrorReported) {
      // ensure that the rtc error is only reported once.
      return;
    }

    // cast_fail: when users lose the webrtc connection while casting
    // cast_error: when users fail to cast their screen on the first attempt
    final eventName = _isRtcFirstConnected ? 'cast_fail' : 'cast_error';

    trackEvent(eventName, EventCategory.session);

    _isPresentingErrorReported = true;
  }

  void _resetTimer() {
    if (_presentTimer != null) {
      _presentTimer!.cancel();
      _presentTimer = null;
      totalSharingTime =
          '${countHoursValue.value.toString().padLeft(2, '0')}:${countMinutesValue.value.toString().padLeft(2, '0')}:${countSecondsValue.value.toString().padLeft(2, '0')}';
    }
    countSecondsValue.value = 0;
    countMinutesValue.value = 0;
    countHoursValue.value = 0;
  }

  void _startPresentTimer() {
    _resetTimer();
    _presentTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (presentingState.value) {
        countSecondsValue.value++;
        if (countSecondsValue.value == 60) {
          countSecondsValue.value = 0;
          countMinutesValue.value++;
        }
        if (countMinutesValue.value == 60) {
          countMinutesValue.value = 0;
          countHoursValue.value++;
        }
      }
    });
  }

  ClientConnection fetchCreateClientConnection(String url, bool isReconnect) {
    if (kIsWeb) {
      return WebTransportClientConnection(
          url,
          fetchWebTransportCertificateHashes,
          WebTransportClientConnectionConfig(
            connectionTimeout: defaultDirectConnectionTimeout,
            allowSelfSignedCertificates: true, // Allow self-signed certificates
            retry: getChannelRetryConfig(isReconnect),
            logger: (url, message) => log.fine('direct connection: $url $message'),
          ),
        );
    } else {
      return WebSocketClientConnection(
        url,
        WebSocketClientConnectionConfig(
          connectionTimeout: defaultDirectConnectionTimeout,
          // allow self-signed certificate
          allowSelfSignedCertificates: true,
          retry: getChannelRetryConfig(isReconnect),
          logger: (url, message) =>
              log.fine('direct connection: $url $message}'),
        ),
      );
    }
  }
}
