import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:display_flutter/services/display_service_broadcast.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/settings/channel_config.dart';
import 'package:display_flutter/utility/channel_util.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/utility/misc_util.dart';
import 'package:display_flutter/utility/sentry_util.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
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

  bool _connectNet = false;

  bool get connectNet => _connectNet;

  set connectNet(bool value) {
    _connectNet = value;
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

  String? host;
  bool _isTunnelServerStart = false;
  bool _isDirectServerStart = false;
  DisplayDirectServer? _directServer;
  DisplayTunnelServer? _tunnelServer;
  String _tunnelApiUrl = '';

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

  set isAuthorizeMode(bool value) {
    _isAuthorizeMode = value;
    _save();
    notifyListeners();
  }

  _save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('app_AuthorizeModeEnable', _isAuthorizeMode);
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
    _load();
  }

  startChannelProvider() {
    _setConnectivityListener();
    _startNewOTPTimer();
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

    trackTrace('network_connectivity', target: result.name);

    if (result == ConnectivityResult.none) {
      _handleNoConnectivity();
    } else {
      await _handleConnectivity(result);
    }
    _lastConnectivityResult = result;
  }

  void _handleNoConnectivity() {
    connectNet = false;
    stopServer();
    _instanceInfo.displayCode = '';
  }

  Future<void> _handleConnectivity(ConnectivityResult result) async {
    connectNet = true;
    log.info(
        'Last Network Connectivity is: $_lastConnectivityResult, being changed to result: $result');

    final value = await _checkNetWorkInfo();
    if (value == null || value.isEmpty) {
      log.warning('_handleConnectivity: No IP address found');
    }
    host = _instanceInfo.ipAddress = value;
    final instanceGroupId = getInstanceGroupIdFromIp(host!);

    if (_lastConnectivityResult != result) {
      registerInstanceIndexById(
        AppInstanceCreate().displayInstanceID,
        instanceGroupId,
      ).then((value) => _handleInstanceIndex(value, instanceGroupId));
    }
  }

  void _handleInstanceIndex(int? instanceIndex, int instanceGroupId) {
    if (host == null) {
      return;
    }

    final displayCode = encodeDisplayCode(
      DisplayCode(
        instanceGroupId: instanceGroupId,
        instanceIndex: instanceIndex,
      ),
    );

    _instanceInfo.displayCode = displayCode;
    AppAnalytics.instance.setGlobalProperty('display_code', displayCode);

    setSentryTag('display.code', displayCode);

    if (instanceIndex != null) {
      startServer(AppInstanceCreate().displayInstanceID, instanceGroupId);
      isLanModeOnly.value = false;
    } else {
      startDirectServer();
      isLanModeOnly.value = true;
    }
  }

  void _setTunnelServer() {
    // create a tunnel server
    _tunnelServer = DisplayTunnelServer(
      reconnectTimeout: channelReconnectTimeoutInStreaming,
      (String url, bool isReconnect) => WebSocketClientConnection(
        url,
        WebSocketClientConnectionConfig(
          logger: (url, message) {
            log.finest('Tunnel $message');
          },
        ),
      ),
      (Channel channel, _) => _onNewChannel(channel, ChannelMode.tunnel),
      (ConnectionRequest connectionRequest) =>
          _verifyConnectRequest(connectionRequest, isDirectConnect: false),
    );

    _tunnelServer?.onTunnelConnected = () {
      log.info('Tunnel connected');
      trackTrace('tunnel_connected');
    };
    _tunnelServer?.onTunnelConnecting = () {
      log.info('Tunnel is connecting');
      trackTrace('tunnel_connecting');
    };
  }

  void _setDirectServer() {
    // create a direct server
    _directServer = DisplayDirectServer(
      reconnectTimeout: channelReconnectTimeoutInStreaming,
      _onNewDirectChanel,
      (ConnectionRequest connectionRequest) =>
          _verifyConnectRequest(connectionRequest, isDirectConnect: true),
    );
  }

  // Is the channel from the host?
  bool _isChannelFromHost(Map<String, String>? queryParameters) {
    return queryParameters?['role'] == 'host';
  }

  void _onNewDirectChanel(
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
    await _remoteScreenServe.startRemoteScreenPublisher();
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

  Future<void> startTunnelServer(String instanceId, int instanceGroupId) async {
    if (_isTunnelServerStart) return;

    // start the tunnel server
    log.info('Starting the tunnel channel server $_tunnelApiUrl');
    if (_tunnelApiUrl.isNotEmpty && _tunnelServer == null) {
      // fix when _tunnelApiUrl is empty, will cause App UI not response.
      _setTunnelServer();
      _tunnelServer?.start(
        instanceId,
        instanceGroupId,
        Uri.parse(_tunnelApiUrl),
      );
    }
    _isTunnelServerStart = true;
  }

  Future<void> startDirectServer() async {
    if (_isDirectServerStart) return;

    // start the direct server
    try {
      final securityContext = await loadSecurityContextForChannel();

      log.info('Starting the direct channel server');
      if (_directServer == null) {
        _setDirectServer();
        await _directServer?.start(
          DisplayServiceBroadcast.instance.directChannelPort,
          securityContext: securityContext,
        );
      }
      _isDirectServerStart = true;
    } on Exception catch (e) {
      log.severe(
          'Failed to load certificate or private key for secure direct connections. $e');
      _isDirectServerStart = false;
    }
  }

  Future<void> startServer(String instanceId, int instanceGroupId) async {
    if (!_isTunnelServerStart) startTunnelServer(instanceId, instanceGroupId);
    if (!_isDirectServerStart) startDirectServer();
  }

  void _onNewChannel(Channel channel, ChannelMode mode) {
    RTCConnector rtcConnector = RTCConnector(channel);
    log.info('Received a new channel');
    RemoteScreenConnector? remoteScreenConnector;

    channel.onChannelMessage = (ChannelMessage message) async {
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
                host,
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
          rtcConnector.onStartPresent(
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
          rtcConnector.onPausePresent();
          break;
        case ChannelMessageType.resumePresent:
          rtcConnector.onResumePresent();
          break;
        case ChannelMessageType.stopPresent:
          rtcConnector.onStopPresent(
              message as StopPresentMessage, isModeratorMode);
          break;
        case ChannelMessageType.presentSignal:
          rtcConnector.onPresentSignal(message as PresentSignalMessage);
          break;
        case ChannelMessageType.channelClosed:
          rtcConnector.onChannelClose(message as ChannelClosedMessage);
          break;

        /// remote
        case ChannelMessageType.startRemoteScreen:
          if (rtcConnector.isModeratorShare) {
            final joinMessage = JoinDisplayMessage(rtcConnector.clientId);

            remoteScreenConnector = RemoteScreenConnector(
                channel,
                _remoteScreenServe.roomId,
                host,
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
    };

    sendDisplayStatus(channel);
  }

  void stopServer() {
    log.info('Stopping the channel server');

    _tunnelServer?.stop();
    _tunnelServer = null;
    _directServer?.stop();
    _directServer = null;
    _isTunnelServerStart = false;
    _isDirectServerStart = false;
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
        }
      }
      if (presenting) {
        Home.enlargedScreenPositionIndex.value = null;
        HybridConnectionList().enlargedScreenIndex.value = null;
      } else {
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

  Future<int?> registerInstanceIndexById(
    String instanceId,
    int instanceGroupId,
  ) async {
    try {
      log.info(
          'Registering the instance ${appConfig.settings.baseApiUrl} groupId:$instanceGroupId');

      final request = buildApiRequest(
        appConfig.settings.baseApiUrl,
        '/v1/instance/$instanceId',
        queryParameters: {
          'groupId': '$instanceGroupId',
        },
        time: DateTime.now(),
        signatureLocation: SignatureLocation.header,
      );

      http.Response response = await http
          .put(
            request.url,
            headers: request.headers,
            body: request.body,
          )
          .timeout(const Duration(seconds: 6));
      log.info('Status of Instance Register API: ${response.statusCode}');

      if (response.statusCode >= HttpStatus.ok &&
          response.statusCode < HttpStatus.multiStatus) {
        Map json = jsonDecode(response.body);

        _tunnelApiUrl = json['tunnelUrl'] ?? '';
        final instanceIndex = json['instanceIndex'];

        return instanceIndex;
      } else {
        log.warning(
            'Instance Register API failed. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log.warning('Instance Register API failed with $e');
      // http.get maybe no network connection.
      return null;
    }
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

  Future<String?> _checkNetWorkInfo() async {
    List<NetworkInterface> interfaces =
        await NetworkInterface.list(type: InternetAddressType.IPv4);

    List<NetworkInterface> ethernetInterfaces = [];
    List<NetworkInterface> wifiInterfaces = [];
    List<NetworkInterface> mobileInterfaces = [];
    for (NetworkInterface interface in interfaces) {
      if (interface.name.toLowerCase().startsWith("eth")) {
        ethernetInterfaces.add(interface);
      } else if (interface.name.toLowerCase().startsWith("wi") ||
          interface.name.toLowerCase().startsWith("wlan")) {
        wifiInterfaces.add(interface);
      } else if (interface.name.toLowerCase().startsWith("rmnet") ||
          interface.name.toLowerCase().startsWith("wwan")) {
        mobileInterfaces.add(interface);
      }
    }

    // by order
    ethernetInterfaces.sort((a, b) => a.name.compareTo(b.name));
    wifiInterfaces.sort((a, b) => a.name.compareTo(b.name));
    mobileInterfaces.sort((a, b) => a.name.compareTo(b.name));

    if (ethernetInterfaces.isNotEmpty) {
      for (NetworkInterface interface in ethernetInterfaces) {
        String? ethernetIp = interface.addresses.isNotEmpty
            ? interface.addresses[0].address
            : null;
        if (ethernetIp != null) {
          return ethernetIp;
        }
        break;
      }
    }

    if (wifiInterfaces.isNotEmpty) {
      for (NetworkInterface interface in wifiInterfaces) {
        String? wifiIp = interface.addresses.isNotEmpty
            ? interface.addresses[0].address
            : null;
        if (wifiIp != null) {
          return wifiIp;
        }
        break;
      }
    }

    if (mobileInterfaces.isNotEmpty) {
      for (NetworkInterface interface in mobileInterfaces) {
        String? mobileIp = interface.addresses.isNotEmpty
            ? interface.addresses[0].address
            : null;
        if (mobileIp != null) {
          return mobileIp;
        }
        break;
      }
    }
    return null;
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

      _updateOTP();
      _updateDisplayCode();
    }
  }

  _updateOTP() {
    otp.value = generateOTP(Random());
  }

  _updateDisplayCode() async {
    if (_isTunnelServerStart || !connectNet) return;
    final value = await _checkNetWorkInfo();
    if (value == null || value.isEmpty) {
      log.warning('_updateDisplayCode: No IP address found');
    }
    host = _instanceInfo.ipAddress = value;
    final instanceGroupId = getInstanceGroupIdFromIp(host!);

    registerInstanceIndexById(
      AppInstanceCreate().displayInstanceID,
      instanceGroupId,
    ).then((value) => _handleInstanceIndex(value, instanceGroupId));
  }

  Future<List<RtcIceServer>?> _getIceServers(ChannelMode mode) async {
    if (mode == ChannelMode.tunnel) {
      return await getIceServers(
        appConfig.settings.baseApiUrl,
        AppInstanceCreate().displayInstanceID,
      );
    } else {
      return [
        RtcIceServer(['stun:$host'])
      ];
    }
  }

  bool checkGroupActivated(List<GroupListItem>? newList) {
    if (_displayGroupHost == null) {
      return false;
    } else {
      if (newList != null) {
        _handleGroupMembersChange(
          newList,
          _displayGroupHost!.members,
          onItemsAdded: (addedItems) {
            for (var member in addedItems) {
              final memberInfo = DisplayGroupMemberInfo(
                host: member.ip(),
                displayCode: member.displayCode(),
              );
              _displayGroupHost!
                  .addMember(member, memberInfo, providerContainer);
            }
          },
          onItemsRemoved: (removedItems) {
            for (var memberId in removedItems) {
              _displayGroupHost!.removeMember(memberId);
            }
          },
        );
      }
      return true;
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
      host,
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
