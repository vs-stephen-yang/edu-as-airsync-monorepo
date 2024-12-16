import 'dart:async';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/api/ice_api.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/app_overlay_tab.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/connect_timer.dart';
import 'package:display_flutter/model/display_group_host.dart';
import 'package:display_flutter/model/display_group_member.dart';
import 'package:display_flutter/model/display_group_member_info.dart';
import 'package:display_flutter/model/display_group_session.dart';
import 'package:display_flutter/model/display_group_video_view.dart';
import 'package:display_flutter/model/group_list_item.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/remote_screen_connector.dart';
import 'package:display_flutter/model/remote_screen_server.dart';
import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/providers/channel_server.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:display_flutter/services/display_service_broadcast.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/utility/ip_util.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/utility/misc_util.dart';
import 'package:display_flutter/utility/sentry_util.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';

import 'message_dialog_provider.dart';

///
/// ChannelProvider
/// - get Tunnel url and display code
/// - connect tunnel server(_tunnelServer) and direct server(_directServer) via display_channel plugin
/// - communicate custom protocols with server and build webRTC connection(_channelRtcConnectors)
/// - refresh Main, WebRTCView

enum ChannelMode {
  tunnel,
  direct,
}

class ChannelProvider extends ChangeNotifier {
  AppConfig appConfig;

  ConnectivityResult _lastConnectivityResult = ConnectivityResult.none;

  bool _isNetworkConnected = false;

  bool get isNetworkConnected => _isNetworkConnected;

  set isNetworkConnected(bool value) {
    _isNetworkConnected = value;
    notifyListeners();
  }

  final int maxCountDown;

  static const _otpTickInterval = Duration(seconds: 1);
  static const _otpDuration = Duration(minutes: 2);

  Timer? _otpTickTimer;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  final ValueNotifier<bool> isEyeOpen = ValueNotifier(true);
  late ValueNotifier<int> countDownProgress;
  final ValueNotifier<bool> isLanModeOnly = ValueNotifier(false);
  final ValueNotifier<String> otp = ValueNotifier('0000');

  static bool isModeratorMode = false;

  setModeratorMode(bool value) {
    isModeratorMode = value;
    if (isModeratorMode) {
      startRemoteScreen(fromShare: true);
    } else {
      removeSender(fromShare: true);
    }
    notifyListeners();
  }

  bool blockRtcConnection = false;

  final int maxRemoteScreenConnection = 10;

  bool get remoteScreenConnectionFull =>
      _remoteScreenConnectors.length >= maxRemoteScreenConnection;

  RemoteScreenServer get remoteScreenServe => _remoteScreenServe;
  final RemoteScreenServer _remoteScreenServe = RemoteScreenServer();

  List<RemoteScreenConnector> get remoteScreenConnectors =>
      _remoteScreenConnectors;
  final List<RemoteScreenConnector> _remoteScreenConnectors =
      <RemoteScreenConnector>[];

  List<RemoteScreenConnector> get remoteShareConnectors =>
      _remoteShareConnectors;
  final List<RemoteScreenConnector> _remoteShareConnectors =
      <RemoteScreenConnector>[];

  bool get isSenderMode => _isSenderMode;

  bool get isGroupMode => _isGroupMode;
  bool _isSenderMode = false;
  bool _isGroupMode = false;
  bool _isShareMode = false;
  final InstanceInfoProvider _instanceInfo;

  bool _isDeviceListQuickConnect = true;

  bool get isDeviceListQuickConnect => _isDeviceListQuickConnect;

  set isDeviceListQuickConnect(bool value) {
    _isDeviceListQuickConnect = value;
    notifyListeners();
  }

  static ValueNotifier<bool> showReconnectWarnToast =
      ValueNotifier<bool>(false);

  ValueNotifier<List<String>> showNewSharingNameList =
      ValueNotifier<List<String>>([]);

  DisplayGroupHost? _displayGroupHost;

  DisplayGroupSession? _displayGroupSession;

  bool get isDisplayGroupVideoAvailable =>
      _displayGroupSession?.isVideoAvailable ?? false;

  DisplayGroupVideoView? get displayGroupVideoView =>
      _displayGroupSession?.videoView;

  ProviderContainer? providerContainer; //透過ProviderContainer來和Riverpod進行互動

  String? get displayGroupHostName => _displayGroupSession?.hostName;

  bool get isAuthorizeMode => _isAuthorizeMode;
  bool _isAuthorizeMode = defaultAuthorizeModeEnable;
  static const defaultAuthorizeModeEnable = true;

  final List<Map<String, RTCConnector>> authorizeRequestList = [];

  late ChannelServer _channelServer;

  set isAuthorizeMode(bool value) {
    _isAuthorizeMode = value;
    _save();
    notifyListeners();
  }

  _save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_AuthorizeModeEnable', _isAuthorizeMode);
  }

  _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isAuthorizeMode =
        prefs.getBool('app_AuthorizeModeEnable') ?? defaultAuthorizeModeEnable;
  }

  ChannelProvider(
    this.appConfig,
    this._instanceInfo,
  ) : maxCountDown =
            _otpDuration.inMilliseconds ~/ _otpTickInterval.inMilliseconds {
    countDownProgress = ValueNotifier(maxCountDown);

    _channelServer = ChannelServer(
      // A new direct channel is created
      onNewDirectChannel: _onNewDirectChannel,
      // A new tunnel channel is created
      onNewTunnelChannel: (channel) {
        _onNewChannel(channel, ChannelMode.tunnel);
      },
      // Verify the connect request
      verifyConnectRequest: _verifyConnectRequest,
      onTunnelStatusChange: _onTunnelStatusChange,
      onDisplayCodeChange: _onDisplayCodeChange,
      baseApiUrl: appConfig.settings.baseApiUrl,
      instanceId: AppInstanceCreate().displayInstanceID,
    );

    _load();
  }

  startChannelProvider() {
    _setConnectivityListener();
    _startNewOTPTimer();

    launchChannelServer();
  }

  void launchChannelServer() {
    final connectivityType = AppPreferences().connectivityType;
    if (connectivityType == ConnectivityType.internet.name) {
      _configureChannelServer(isDirect: false, isTunnel: true);
    } else if (connectivityType == ConnectivityType.local.name) {
      _configureChannelServer(isDirect: true, isTunnel: false);
    } else {
      _configureChannelServer(isDirect: true, isTunnel: true);
    }
  }

  void _configureChannelServer(
      {required bool isDirect, required bool isTunnel}) {
    _channelServer.enableDirect(isDirect);
    _channelServer.enableTunnel(isTunnel);
  }

  setProviderContainer(ProviderContainer pc) {
    providerContainer = pc;
  }

  void _setConnectivityListener() {
    _initConnectivity();
    _connectivitySubscription ??=
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await Connectivity().checkConnectivity();
    } on PlatformException catch (e) {
      log.info('Could not check connectivity status: ${e.message}');
      return;
    }

    return _updateConnectionStatus(result);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    log.info('Network connectivity has changed to $result');

    if (result == _lastConnectivityResult) {
      // Ignore duplicate notifications
      return;
    }

    log.info(
        'Network connectivity has changed to $result from $_lastConnectivityResult');
    _lastConnectivityResult = result;

    trackTrace('network_connectivity', target: result.name);

    if (result == ConnectivityResult.none) {
      _handleNoConnectivity();
    } else {
      await _handleNetworkConnected();
    }
  }

  void _handleNoConnectivity() {
    isNetworkConnected = false;
    _instanceInfo.displayCode = '';
  }

  Future<void> _handleNetworkConnected() async {
    isNetworkConnected = true;

    // Get local IP address
    final ipAddress = await getPreferredNetworkIpAddress();
    if (ipAddress == null || ipAddress.isEmpty) {
      log.severe('No IP address found');
      return;
    }
    _instanceInfo.ipAddress = ipAddress;

    _channelServer.onIpAddressChange(ipAddress);
  }

  _onTunnelStatusChange(TunnelStatus status) {
    isLanModeOnly.value = !_channelServer.isTunnelAvailable;
  }

  void _onDisplayCodeChange() {
    final displayCode = _channelServer.displayCode;

    _instanceInfo.displayCode = displayCode;
    AppAnalytics.instance.setGlobalProperty('display_code', displayCode);

    setSentryTag('display.code', displayCode);
  }

  // Is the channel from the host?
  bool _isChannelFromHost(Map<String, String>? queryParameters) {
    return queryParameters?['role'] == 'host';
  }

  void _onNewDirectChannel(
    Channel channel,
    Map<String, String>? queryParameters,
  ) {
    if (_isChannelFromHost(queryParameters)) {
      _onNewChannelFromHost(channel);
    } else {
      _onNewChannel(channel, ChannelMode.direct);
    }
  }

  void _onNewChannelFromHost(Channel channel) {
    if (_displayGroupSession != null) {
      // TODO: handle the existing display group session
      return;
    }

    _displayGroupSession = DisplayGroupSession(
      channel,
      onInvitation: (String hostName, String displayCode) {
        final invitedToGroup = AppPreferences().invitedToGroup;
        switch (invitedToGroup) {
          case '0': // notifyMe
            providerContainer?.read(dialogProvider.notifier).showDialog(
                  title: sprintf(S.current.v3_group_dialog_title, [hostName]),
                  content:
                      sprintf(S.current.v3_group_dialog_message, [hostName]),
                  confirmText: S.current.v3_group_dialog_accept,
                  cancelText: S.current.v3_group_dialog_decline,
                  showIcon: true,
                  width: 400,
                  height: 265,
                  onConfirm: () {
                    _displayGroupSession?.accept(hostName);
                  },
                  onCancel: () {
                    _displayGroupSession?.reject();
                    stopReceivedFromHost(closeReason: 'invite rejected');
                  },
                );
            break;
          case '1': // autoAccept
            _displayGroupSession?.accept(hostName);
            break;
          case '2': // ignore
            _displayGroupSession?.reject();
            stopReceivedFromHost(closeReason: 'invite ignore');
            break;
        }
      },
      onStateChange: (ChannelState? state) {
        if (state != null) {
          switch (state) {
            case ChannelState.connected:
              break;
            case ChannelState.closed:
              stopReceivedFromHost(closeReason: 'stop received from host');
              break;
            default:
              break;
          }
        }
        notifyListeners();
      },
    );
  }

  Future startRemoteScreen({
    bool? fromGroup,
    bool? fromShare,
    bool? fromSender,
  }) async {
    log.info('Starting remote screen');

    if (_isGroupMode || _isShareMode || _isSenderMode) {
      _isGroupMode = fromGroup ?? _isGroupMode;
      _isShareMode = fromShare ?? _isShareMode;
      _isSenderMode = fromSender ?? _isSenderMode;
      notifyListeners();
      return;
    }
    _isGroupMode = fromGroup ?? _isGroupMode;
    _isShareMode = fromShare ?? _isShareMode;
    _isSenderMode = fromSender ?? _isSenderMode;
    final iceServers = await _getIceServers(ChannelMode.tunnel);

    await _remoteScreenServe.startSfuServer(iceServers);
    bool result = await _remoteScreenServe.startRemoteScreenPublisher();
    if (!result) {
      removeSender(fromSender: true, fromGroup: true);
      return stopRemoteScreenPublisher();
    }

    ConnectionTimer.getInstance().startShareSenderTimer(() {
      removeSender(
        fromGroup: _isGroupMode,
        fromShare: _isShareMode,
        fromSender: _isSenderMode,
      );
    });
    notifyListeners();
  }

  void stopRemoteScreenPublisher() {
    _remoteScreenServe.stopRemoteScreenPublisher();
  }

  void _onNewChannel(Channel channel, ChannelMode mode) {
    RTCConnector rtcConnector = RTCConnector(channel);
    log.info('Received a new channel');
    RemoteScreenConnector? remoteScreenConnector;

    channel.messageStream.listen((ChannelMessage message) async {
      log.info(
          'Received channel message ${message.messageType} ${message.toJson()}');

      switch (message.messageType) {
        /// basic
        case ChannelMessageType.joinDisplay:
          JoinDisplayMessage msg = message as JoinDisplayMessage;

          trackEvent(
            'connect_successfully',
            EventCategory.session,
            participatorId: msg.clientId,
            mode: 'webrtc',
          );

          if (msg.intent == JoinIntentType.present) {
            if (isModeratorMode) {
              if (HybridConnectionList().getConnectionCount() >=
                  HybridConnectionList.maxHybridConnection) {
                trackEvent(
                  'device_full',
                  EventCategory.session,
                  participatorId: msg.clientId,
                  mode: 'webrtc',
                );

                sendJoinDisplayRejectMessage(channel);
                return;
              }
              if (msg.name != null && HybridConnectionList().isPresenting()) {
                showNewSharingNameList.value.add(msg.name!);
                showNewSharingNameList.value =
                    List.from(showNewSharingNameList.value);
              }
            } else {
              if (msg.isConnectedViaModeratorMode ?? false) {
                // was ModeratorMode, quit when inputting name.
                sendJoinModeChangedRejectMessage(channel);
                return;
              }
              if (HybridConnectionList.hybridSplitScreenCount.value >=
                  HybridConnectionList.maxHybridSplitScreen) {
                trackEvent(
                  'device_full',
                  EventCategory.session,
                  participatorId: msg.clientId,
                  mode: 'webrtc',
                );

                sendJoinDisplayRejectMessage(channel);
                return;
              }
            }

            rtcConnector = _onJoinDisplay(rtcConnector, mode, msg);
            if (isAuthorizeMode && !isModeratorMode) {
              if (msg.name != null) {
                Map<String, RTCConnector> requestAuthorize = {
                  msg.name!: rtcConnector,
                };
                authorizeRequestList.add(requestAuthorize);
                Timer.periodic(const Duration(seconds: 10), (_) {
                  if (authorizeRequestList.contains(requestAuthorize)) {
                    requestAuthorize[msg.name]?.sendRejectPresent(
                        PresentRejectedReasonCode.authorizeTimeout.code,
                        'authorize timeout');
                    authorizeRequestList.remove(requestAuthorize);
                    notifyListeners();
                  }
                });
              }
            }

            // After joining the display, a "Present Allow" message
            // should be sent to the sender to initiate the presentation.
            //
            // Moderator Mode: The message will be sent through the
            // participant item list.
            // Accept/Decline Mode: The message will be sent via an
            // authorization dialog.
            // Normal Mode: The message will be sent directly
            if (!isAuthorizeMode && !isModeratorMode) {
              rtcConnector.sendAllowPresent();
            }
          } else {
            if (_remoteScreenConnectors.length >= maxRemoteScreenConnection) {
              trackEvent(
                'device_full',
                EventCategory.session,
                participatorId: msg.clientId,
                mode: 'cast_to_device',
              );

              sendJoinDisplayRejectMessage(channel);
              return;
            }
            remoteScreenConnector = RemoteScreenConnector(
                channel,
                _remoteScreenServe.roomId,
                _instanceInfo.ipAddress,
                _remoteScreenServe.roomPort,
                msg);
            remoteScreenConnector?.onChannelDisconnect = (() async {
              removeSender(
                fromSender: true,
                remoteScreenConnector: remoteScreenConnector,
                kick: false,
              );
            });
            _remoteScreenConnectors.add(remoteScreenConnector!);

            _remoteScreenServe.addConnector(remoteScreenConnector!);
          }
          notifyListeners();
          break;
        case ChannelMessageType.startPresent:
          if (HybridConnectionList.hybridSplitScreenCount.value >=
              HybridConnectionList.maxHybridSplitScreen) {
            sendPresentRejectMessage(channel);
            break;
          }
          final iceServers = await _getIceServers(mode);
          await rtcConnector.onStartPresent(
            message as StartPresentMessage,
            isModeratorMode,
            iceServers,
          );
          break;
        case ChannelMessageType.presentAccepted:
          break;
        case ChannelMessageType.presentRejected:
          rtcConnector.onPresentRejected(message as PresentRejectedMessage);
          break;
        case ChannelMessageType.changePresentQuality:
          // ignore
          break;
        case ChannelMessageType.pausePresent:
          await rtcConnector.onPausePresent();
          break;
        case ChannelMessageType.resumePresent:
          await rtcConnector.onResumePresent();
          break;
        case ChannelMessageType.stopPresent:
          await rtcConnector.onStopPresent(
              message as StopPresentMessage, isModeratorMode);
          break;
        case ChannelMessageType.presentSignal:
          await rtcConnector.onPresentSignal(message as PresentSignalMessage);
          break;
        case ChannelMessageType.channelClosed:
          await rtcConnector.onChannelClose(message as ChannelClosedMessage);
          break;

        /// remote
        case ChannelMessageType.startRemoteScreen:
          if (rtcConnector.isModeratorShare) {
            final joinMessage = JoinDisplayMessage(rtcConnector.clientId);

            remoteScreenConnector = RemoteScreenConnector(
                channel,
                _remoteScreenServe.roomId,
                _instanceInfo.ipAddress,
                _remoteScreenServe.roomPort,
                joinMessage);
            remoteScreenConnector?.onChannelDisconnect = (() async {
              removeSender(
                fromShare: true,
                remoteScreenConnector: remoteScreenConnector,
                kick: false,
              );
            });
            _remoteShareConnectors.add(remoteScreenConnector!);

            _remoteScreenServe.addConnector(remoteScreenConnector!);
            final iceServers = await _getIceServers(mode);

            await remoteScreenConnector?.onStartRemoteScreen(
              message as StartRemoteScreenMessage,
              iceServers,
            );
            notifyListeners();

            break;
          }

          if (_isSenderMode) {
            final iceServers = await _getIceServers(mode);

            await remoteScreenConnector?.onStartRemoteScreen(
              message as StartRemoteScreenMessage,
              iceServers,
            );
            notifyListeners();
          } else {
            await remoteScreenConnector
                ?.sendRemoteScreenState(RemoteScreenStatus.rejected);
            removeSender(
              // hardcode to remove sender rejected remoteScreenConnector
              fromSender: true,
              remoteScreenConnector: remoteScreenConnector,
            );
          }
          break;

        case ChannelMessageType.remoteScreenSignal:
          final signalMessage = message as RemoteScreenSignalMessage;
          remoteScreenConnector?.processSignalFromPeer(signalMessage.signal!);
          break;

        case ChannelMessageType.stopRemoteScreen:
          if (_isShareMode) {
            rtcConnector.isModeratorShare = false;
            notifyListeners();
          }
          break;

        default:
          break;
      }
    });

    sendDisplayStatus(channel);
  }

  ConnectRequestStatus _verifyConnectRequest(
    ConnectionRequest connectionRequest, {
    required bool isDirectConnect,
  }) {
    // Check if the display code is valid
    if (connectionRequest.displayCode.isEmpty ||
        connectionRequest.displayCode != _instanceInfo.displayCode) {
      return ConnectRequestStatus.invalidDisplayCode;
    }

    if (isDirectConnect) {
      // Handle verification for direct connections
      if (connectionRequest.token == null || connectionRequest.token!.isEmpty) {
        // When the token is empty, we assume the connection is initiated from the device list.
        // For connections from the device list, the token may not be required.
        if (isAuthRequiredForDirectConnection()) {
          // the token is still required. reject the connection
          return ConnectRequestStatus.authenticationRequired;
        } else {
          return ConnectRequestStatus.success;
        }
      } else {
        // check if the token is valid
        if (!_isValidOtp(connectionRequest.token!)) {
          return ConnectRequestStatus.invalidOtp;
        } else {
          return ConnectRequestStatus.success;
        }
      }
    } else {
      // Handle verification for tunnel connections
      if (!_isValidOtp(connectionRequest.token!)) {
        return ConnectRequestStatus.invalidOtp;
      } else {
        return ConnectRequestStatus.success;
      }
    }
  }

  bool isAuthRequiredForDirectConnection() {
    return !_isDeviceListQuickConnect;
  }

  bool _isValidOtp(String token) {
    return appConfig.settings.defaultOtp == token || otp.value == token;
  }

  void sendDisplayStatus(Channel channel) {
    final displayStatusMessage = DisplayStatusMessage();
    displayStatusMessage.name = _instanceInfo.deviceName;
    displayStatusMessage.platform = getPlatformName();
    displayStatusMessage.status = DisplayStatus.fromJson(
        {'moderator': isModeratorMode, 'authorize': isAuthorizeMode});
    channel.send(displayStatusMessage);
  }

  void sendPresentRejectMessage(Channel channel) {
    final message = PresentRejectedMessage();
    message.reason = Reason(
      PresentRejectedReasonCode.maxPresentReached.code,
      text: 'Max number of presentations reached',
    );
    channel.send(message);
  }

  RTCConnector _onJoinDisplay(
      RTCConnector rtcConnector, ChannelMode mode, JoinDisplayMessage message) {
    // create a client object to handle this channel
    rtcConnector.init(message, isModeratorMode);
    rtcConnector.onConnect = (() {
      HybridConnectionList().updateSplitScreen();
      StreamFunction.streamFunctionState.value = stateMenuOff;
      notifyListeners();
    });

    rtcConnector.onAddRemoteStream = ((stream) {
      // update state and quality
      HybridConnectionList().updateSplitScreen();

      StreamFunction.streamFunctionState.value = stateMenuOff;
      notifyListeners();
    });

    rtcConnector.onRefresh = (() {
      notifyListeners();
    });

    rtcConnector.onChannelDisconnect = (({String? reason}) async {
      // update UI
      bool presenting = false;
      for (RTCConnector rtcConnector
          in HybridConnectionList().getRtcConnectorMap().values) {
        if (rtcConnector.presentationState != PresentationState.stopStreaming) {
          presenting = true;
          break;
        }
      }
      if (!presenting) {
        if (reason == 'Channel reconnect timeout') {
          showReconnectWarnToast.value = true;
          await Future.delayed(const Duration(seconds: 1));
        }
      }
      await rtcConnector.close(ChannelCloseCode.close, reason: reason);
      HybridConnectionList().removeConnection(rtcConnector);
      HybridConnectionList().updateSplitScreen();

      notifyListeners();
    });

    HybridConnectionList().addConnection(rtcConnector);
    AppOverlayTab().launchApp();

    return rtcConnector;
  }

  void sendJoinDisplayRejectMessage(Channel channel) {
    final message = JoinDisplayRejectedMessage();
    message.reason = Reason(
      JoinDisplayRejectedReasonCode.maxClientsReached.code,
      text: 'Max number of clients reached',
    );
    channel.send(message);
  }

  void sendJoinModeChangedRejectMessage(Channel channel) {
    final message = JoinDisplayRejectedMessage();
    message.reason = Reason(
      JoinDisplayRejectedReasonCode.moderatorExited.code,
      text: 'Moderator mode exited.',
    );
    channel.send(message);
  }

  updateAllAudioEnableState(bool enable) {
    for (RTCConnector rtcConnector
        in HybridConnectionList().getRtcConnectorMap().values) {
      rtcConnector.controlAudio(rtcConnector.isAudioEnabled & enable,
          setIsAudioEnabled: false);
    }
  }

  removeSender({
    bool? fromGroup,
    bool? fromShare,
    bool? fromSender,
    RemoteScreenConnector? remoteScreenConnector,
    bool kick = true,
  }) {
    if (remoteScreenConnector != null) {
      if (fromSender != null && fromSender) {
        int index = _remoteScreenConnectors.indexOf(remoteScreenConnector);
        if (index != -1) {
          if (kick) {
            remoteScreenConnector
                .sendRemoteScreenState(RemoteScreenStatus.kicked);
          }
          _remoteScreenServe.removeConnector(_remoteScreenConnectors[index]);
          _remoteScreenConnectors.removeAt(index);
        }
      }
      if (fromShare != null && fromShare) {
        int index = _remoteShareConnectors.indexOf(remoteScreenConnector);
        if (index != -1) {
          if (kick) {
            remoteScreenConnector
                .sendRemoteScreenState(RemoteScreenStatus.kicked);
          }
          _remoteScreenServe.removeConnector(_remoteShareConnectors[index]);
          _remoteShareConnectors.removeAt(index);
        }
      }
    } else {
      if (fromGroup != null) _isGroupMode = false;
      if (fromShare != null) _isShareMode = false;
      if (fromSender != null) _isSenderMode = false;

      if (_isGroupMode || _isShareMode || _isSenderMode) {
        notifyListeners();
        return;
      }

      if (fromShare != null && fromShare) {
        for (var element in _remoteShareConnectors) {
          element.sendRemoteScreenState(RemoteScreenStatus.kicked);
        }
        _remoteShareConnectors.clear();
      }

      if (fromSender != null && fromSender) {
        for (var element in _remoteScreenConnectors) {
          element.sendRemoteScreenState(RemoteScreenStatus.kicked);
        }
        _remoteScreenConnectors.clear();
      }

      if (!_isSenderMode && !_isGroupMode && !_isShareMode) {
        stopRemoteScreenPublisher();
        ConnectionTimer.getInstance().stopShareSenderTimer();
      }
    }
    notifyListeners();
  }

  _startNewOTPTimer() {
    if (_otpTickTimer != null) {
      return;
    }

    _updateOTP();

    _otpTickTimer = Timer.periodic(_otpTickInterval, (timer) {
      _onOTPTick();
    });
  }

  _onOTPTick() {
    countDownProgress.value -= 1;
    if (countDownProgress.value == 0) {
      countDownProgress.value = maxCountDown;
      DisplayServiceBroadcast.instance.onBroadcastRestart();
      _updateOTP();
    }
  }

  _updateOTP() {
    otp.value = generateOTP(Random());
  }

  Future<List<RtcIceServer>?> _getIceServers(ChannelMode mode) async {
    if (mode == ChannelMode.tunnel) {
      return await getIceServers(
        appConfig.settings.baseApiUrl,
        AppInstanceCreate().displayInstanceID,
      );
    } else {
      return [
        RtcIceServer(['stun:${_instanceInfo.ipAddress}'])
      ];
    }
  }

  bool groupActivated() {
    return _displayGroupHost != null;
  }

  bool isGroupHostMember(String id) {
    if (_displayGroupHost != null) {
      return (_displayGroupHost!.members as Map<String, DisplayGroupMember>)
          .containsKey(id);
    } else {
      return false;
    }
  }

  void stopDisplayGroup() {
    log.info('Stopping display group');

    _displayGroupHost?.stop();
    _displayGroupHost = null;
    removeSender(fromGroup: true);
  }

  void startDisplayGroup(List<GroupListItem> newList) {
    log.info('Starting display group');

    _displayGroupHost ??= DisplayGroupHost(
      _createRemoteScreenConnector,
    );

    _handleGroupMembersChange(newList, _displayGroupHost!.members,
        onItemsAdded: (addedItems) {
      for (var member in addedItems) {
        final memberInfo = DisplayGroupMemberInfo(
          host: member.ip(),
          displayCode: member.displayCode(),
        );
        _displayGroupHost!.addMember(member, memberInfo, providerContainer);
      }
    }, onItemsRemoved: (removedItems) {
      for (var memberId in removedItems) {
        _displayGroupHost!.removeMember(memberId);
      }
    });
  }

  void _handleGroupMembersChange(
    List<GroupListItem> newList,
    Map<String, DisplayGroupMember> oldMap, {
    required Function(List<GroupListItem>) onItemsAdded,
    required Function(List<String>) onItemsRemoved,
  }) {
    Map<String, GroupListItem> newMap = {
      for (var item in newList) item.id(): item
    };

    List<GroupListItem> addedItems =
        newList.where((item) => !oldMap.containsKey(item.id())).toList();
    List<String> removedItems = oldMap.entries
        .where((entry) => !newMap.containsKey(entry.key))
        .map((entry) => entry.key) // 只提取 id (键)
        .toList();

    if (addedItems.isNotEmpty) {
      onItemsAdded(addedItems);
    }
    if (removedItems.isNotEmpty) {
      onItemsRemoved(removedItems);
    }
  }

  Future<RemoteScreenConnector> _createRemoteScreenConnector(
    Channel channel,
    StartRemoteScreenMessage message,
  ) async {
    final joinMessage = JoinDisplayMessage('123');

    final connector = RemoteScreenConnector(
      channel,
      _remoteScreenServe.roomId,
      _instanceInfo.ipAddress,
      _remoteScreenServe.roomPort,
      joinMessage,
    );

    final iceServers = await _getIceServers(ChannelMode.direct);

    _remoteScreenServe.addConnector(connector);

    await connector.onStartRemoteScreen(
      message,
      iceServers,
    );

    return connector;
  }

  //region handle Display Group's client
  void stopReceivedFromHost({required String closeReason}) {
    _displayGroupSession?.stop(reason: closeReason);
    _displayGroupSession = null;
    notifyListeners();
  }
// endregion
}
