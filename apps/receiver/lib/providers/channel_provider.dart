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
import 'package:display_flutter/model/display_group_mediator.dart';
import 'package:display_flutter/model/display_group_member.dart';
import 'package:display_flutter/model/display_group_member_info.dart';
import 'package:display_flutter/model/display_group_session.dart';
import 'package:display_flutter/model/group_list_item.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/multicast_presenter.dart';
import 'package:display_flutter/model/network_diagnostic.dart';
import 'package:display_flutter/model/remote_screen.dart';
import 'package:display_flutter/model/remote_screen_connector.dart';
import 'package:display_flutter/model/remote_screen_server.dart';
import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/providers/channel_server.dart';
import 'package:display_flutter/providers/group_provider.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:display_flutter/providers/remote_screen_provider.dart';
import 'package:display_flutter/screens/v3_overlay_tab.dart';
import 'package:display_flutter/services/display_service_broadcast.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/utility/device_info.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/utility/log_uploader_with_cooldown.dart';
import 'package:display_flutter/utility/misc_util.dart';
import 'package:display_flutter/utility/sentry_util.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';

import 'appSettings.dart';
import 'group_list_provider.dart';
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

class ChannelProvider extends ChangeNotifier
    implements RemoteScreenServerDelegate {
  // Add these variables to store previous states
  bool? _previousModeratorMode;
  bool? _previousSenderMode;
  bool? _previousGroupMode;

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

  bool get moderatorMode => isModeratorMode;

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

  final int _maxRemoteScreenConnection = 10;

  int get maxRemoteScreenConnection {
    return _maxRemoteScreenConnection *
        (remoteScreenType == RemoteScreenType.multicast ? 10 : 1);
  }

  bool get remoteScreenConnectionFull =>
      _remoteScreenConnectors.length >= maxRemoteScreenConnection;

  RemoteScreenServer get remoteScreenServe => _remoteScreenProvider.server;

  List<RemoteScreenConnector> get remoteScreenConnectors =>
      _remoteScreenConnectors;
  final List<RemoteScreenConnector> _remoteScreenConnectors =
      <RemoteScreenConnector>[];

  List<RemoteScreenConnector> get remoteShareConnectors =>
      _remoteShareConnectors;
  final List<RemoteScreenConnector> _remoteShareConnectors =
      <RemoteScreenConnector>[];

  static const defaultSenderModeEnable = false;

  bool get isSenderMode => _isSenderMode;

  bool get isGroupMode => _isGroupMode;
  bool _isSenderMode = defaultSenderModeEnable;
  bool _isGroupMode = false;
  bool _isShareMode = false;
  final InstanceInfoProvider _instanceInfo;
  final LogUploaderWithCooldown _memberFpsZeroLogUploader;
  final LogUploaderWithCooldown _hostFpsZeroLogUploader;

  static const defaultSmartScaling = true;
  bool _smartScaling = defaultSmartScaling;

  bool get smartScaling => _smartScaling;

  set smartScaling(bool value) {
    _smartScaling = value;
    _save();
    notifyListeners();
  }

  static const defaultHighImageQuality = false;
  bool _highImageQuality = defaultHighImageQuality;

  bool get highImageQuality => _highImageQuality;

  set highImageQuality(bool value) {
    _highImageQuality = value;
    // TODO: Skip saving to shared preferences for now; may add later if needed.
    // _save();
    notifyListeners();
  }

  static const defaultDeviceListQuickConnect = true;
  bool _isDeviceListQuickConnect = defaultDeviceListQuickConnect;

  bool get isDeviceListQuickConnect => _isDeviceListQuickConnect;

  set isDeviceListQuickConnect(bool value) {
    _isDeviceListQuickConnect = value;
    _save();
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

  bool get isDisplayGroupAudioEnabled =>
      _displayGroupSession?.isAudioEnabled ?? false;

  StatelessWidget? get displayGroupVideoView => _displayGroupSession?.videoView;

  ProviderContainer? providerContainer; //透過ProviderContainer來和Riverpod進行互動

  String? get displayGroupHostName => _displayGroupSession?.hostName;

  bool get isAuthorizeMode => _isAuthorizeMode;
  bool _isAuthorizeMode = defaultAuthorizeModeEnable;
  static const defaultAuthorizeModeEnable = true;

  final List<Map<String, RTCConnector>> authorizeRequestList = [];

  late ChannelServer _channelServer;

  late RemoteScreenProvider _remoteScreenProvider;

  RemoteScreenType get remoteScreenType => _settings.remoteScreenType;

  final NetworkDiagnostic _networkDiagnostic = NetworkDiagnostic();

  set isAuthorizeMode(bool value) {
    _isAuthorizeMode = value;
    _save();
    notifyListeners();
  }

  /// 接受授權請求
  /// [index] - authorizeRequestList 中的索引
  void acceptAuthorizeRequest(int index) {
    if (index < 0 || index >= authorizeRequestList.length) {
      log.warning('無效的索引 for acceptAuthorizeRequest: $index');
      return;
    }

    final request = authorizeRequestList[index];
    request.entries.first.value.sendAllowPresent();
    authorizeRequestList.removeAt(index);
    notifyListeners();
  }

  /// 拒絕授權請求
  /// [index] - authorizeRequestList 中的索引
  /// [reasonCode] - 拒絕原因代碼
  /// [reason] - 拒絕原因描述
  void declineAuthorizeRequest(int index, int reasonCode, String reason) {
    if (index < 0 || index >= authorizeRequestList.length) {
      log.warning('無效的索引 for declineAuthorizeRequest: $index');
      return;
    }

    final request = authorizeRequestList[index];
    request.entries.first.value.sendRejectPresent(reasonCode, reason);
    authorizeRequestList.removeAt(index);
    notifyListeners();
  }

  bool get tunnelActivated => _channelServer.isTunnelAvailable;

  Stream<bool> get tunnelActivatedStream =>
      _channelServer.tunnelActivatedController.stream;

  StreamSubscription? _mediaProjectionOnStopSubscription;

  bool showOverlayTab = false;

  _save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_AuthorizeModeEnable', _isAuthorizeMode);
    await prefs.setBool('app_SenderModeEnable', _isSenderMode);
    await prefs.setBool(
        'app_DeviceListQuickConnect', _isDeviceListQuickConnect);
    await prefs.setBool('app_SmartScaling', _smartScaling);
  }

  Future<void> _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isAuthorizeMode =
        prefs.getBool('app_AuthorizeModeEnable') ?? defaultAuthorizeModeEnable;
    _isSenderMode =
        prefs.getBool('app_SenderModeEnable') ?? defaultSenderModeEnable;
    _isDeviceListQuickConnect = prefs.getBool('app_DeviceListQuickConnect') ??
        defaultDeviceListQuickConnect;
    _smartScaling = prefs.getBool('app_SmartScaling') ?? defaultSmartScaling;
  }

  Future<void> reloadPreferences() async {
    await _load();
    notifyListeners();
  }

  late AppSettings _settings;

  bool _postInitRan = false; // 守門：只跑一次

  void bindSettings(AppSettings s) {
    _settings = s;
    if (_postInitRan) {
      _bootstrapNetworking();
    } else {
      _ensurePostInitOnce();
    }
  }

  void _ensurePostInitOnce() {
    if (_postInitRan) return;

    // 若已載入就立刻跑；否則等 ready
    if (_settings.isLoaded) {
      _runPostInitOnce();
    } else {
      _settings.ready.then((_) => _runPostInitOnce());
    }
  }

  void _runPostInitOnce() {
    if (_postInitRan) return;
    _postInitRan = true;

    _bootstrapNetworking();
    // 本來在_load執行，現在需要等確認模式後再開啟
    if (_isSenderMode) {
      startRemoteScreen(fromSender: true);
    }
  }

  void _bootstrapNetworking() {
    _reconfigureNetworking();
  }

  void _reconfigureNetworking() {
    _remoteScreenProvider = RemoteScreenProvider(
      RemoteScreenServer(this),
      _instanceInfo.ipAddress,
      removeSender,
      MulticastPresenter(),
      _settings.remoteScreenType,
    );
  }

  ChannelProvider(
    this.appConfig,
    this._instanceInfo,
    this._memberFpsZeroLogUploader,
    this._hostFpsZeroLogUploader,
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
      webTransportServerPort: appConfig.webTransportServerPort,
      directChannelPort: DisplayServiceBroadcast.channelPort,
      reportPortBindResult: _networkDiagnostic.importPortTestResult,
      reportTunnelConnectResult: _networkDiagnostic.reportTunnelConnectResult,
      reportWebTransportCertDate: _networkDiagnostic.reportWebTransportCertDate,
    );

    // Use P2P connection for WebRTC in the Display group by returning an empty ICE server list.
    _remoteScreenProvider = RemoteScreenProvider(
      RemoteScreenServer(this),
      _instanceInfo.ipAddress,
      removeSender,
      MulticastPresenter(),
      RemoteScreenType.rtc,
    );

    _load();
  }

  // 重啟Publisher
  Future<void> remoteScreenRecreatePublish() async {
    providerContainer?.read(dialogProvider.notifier).showProgress(
        title: S.current.v3_zero_fps_restarting_title,
        content: S.current.v3_zero_fps_restarting_content);
    _remoteScreenProvider.recreatePublisher();
    await AppOverlayTab().setVisibility(true);
    if (!showOverlayTab) {
      await AppOverlayTab().showFpsKeeper();
    }
    sendRemoteScreenStatusToMembers(RemoteScreenStatus.hostRecreating);
  }

  // 關閉大傳大與大傳小功能
  Future<void> stopRemoteScreenFromFail() async {
    await removeSender(fromSender: true, fromGroup: true);
    await _stopModeratorRemoteScreen(stopPublisher: true);
    await AppOverlayTab().setVisibility(showOverlayTab);
  }

  // 關閉Moderator的RemoteScreen但不關閉moderator模式
  Future<void> _stopModeratorRemoteScreen({bool stopPublisher = false}) async {
    for (RTCConnector rtcConnector
        in HybridConnectionList().getRtcConnectorMap().values) {
      if (rtcConnector.isModeratorShare) {
        rtcConnector.sendStopRemoteScreen();
        await Future.delayed(Duration(milliseconds: 200));
        int index = remoteShareConnectors
            .indexWhere((item) => item.clientId == rtcConnector.clientId);
        if (index != -1) {
          RemoteScreenConnector remoteShareConnector =
              remoteShareConnectors[index];

          removeSender(
            fromShare: true,
            remoteScreenConnector: remoteShareConnector,
            kick: false,
          );
        }
      }
    }
    if (stopPublisher) {
      await stopRemoteScreenPublisher();
    }
  }

  @override
  void dispose() {
    _channelServer.dispose();
    _mediaProjectionOnStopSubscription?.cancel();
    super.dispose();
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
    final ipAddress = await findDeviceIpAddress();

    if (ipAddress == null || ipAddress.isEmpty) {
      // consider the device is not connected to any network while looking for the IP address
      if (_lastConnectivityResult == ConnectivityResult.none) {
        log.warning('No IP address found');
        return;
      }
      log.severe('No IP address found');
      return;
    }
    _instanceInfo.ipAddress = ipAddress;

    _channelServer.onIpAddressChange(ipAddress);
  }

  _onTunnelStatusChange(TunnelStatus status) {
    bool isTunnelAvailable = _channelServer.isTunnelAvailable;
    isLanModeOnly.value = !isTunnelAvailable;
    _networkDiagnostic.setTunnelResult(
        TunnelStatusType.register, isTunnelAvailable, status.value);
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
      channel.close(ChannelCloseReason(ChannelCloseCode.remoteClose));
      // TODO: handle the existing display group session
      return;
    }

    _displayGroupSession = DisplayGroupSession(
      channel,
      _memberFpsZeroLogUploader,
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
                    // Store current states before accepting
                    _previousModeratorMode = isModeratorMode;
                    _previousSenderMode = _isSenderMode;
                    _previousGroupMode = _isGroupMode;

                    _displayGroupSession?.accept(hostName);
                  },
                  onCancel: () {
                    _displayGroupSession?.reject();
                    stopReceivedFromHost(closeReason: 'invite rejected');
                  },
                );
            break;
          case '1': // autoAccept
            // Store current states before auto accepting
            _previousModeratorMode = isModeratorMode;
            _previousSenderMode = _isSenderMode;
            _previousGroupMode = _isGroupMode;

            _displayGroupSession?.accept(hostName);
            break;
          case '2': // ignore
            _displayGroupSession?.reject();
            stopReceivedFromHost(closeReason: 'invite ignore');
            break;
        }
      },
      onChannelStateChange: (ChannelState? state) {
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
      onWebRtcClose: () {
        stopReceivedFromHost(closeReason: 'webrtc close');
      },
      onRemoteScreenStatusChange: (RemoteScreenStatus? state) {
        String title = '';
        String message = '';
        switch (state) {
          case RemoteScreenStatus.hostFpsZero:
            title = S.current.v3_zero_fps_capture_failed_title;
            message = S.current.v3_zero_fps_capture_failed_message;
            break;
          case RemoteScreenStatus.hostRecreating:
            title = S.current.v3_zero_fps_repairing_title;
            message = S.current.v3_zero_fps_repairing_message;
            break;
          case RemoteScreenStatus.hostRecreateFailure:
            title = S.current.v3_zero_fps_failed_to_repair_title;
            message = S.current.v3_zero_fps_failed_to_repair_message;
            break;
          case RemoteScreenStatus.hostRecreateSuccess:
            providerContainer?.read(dialogProvider.notifier).hideDialog();
            break;
          default:
            break;
        }
        if (title.isEmpty && message.isEmpty) return;
        providerContainer?.read(dialogProvider.notifier).hideDialog();
        providerContainer?.read(dialogProvider.notifier).showDialog(
              title: title,
              content: message,
              cancelText: S.current.v3_zero_fps_close,
              width: 280,
              height: 200,
              onCancel: () {},
            );
      },
    );
  }

  Future startRemoteScreen({
    bool? fromGroup,
    bool? fromShare,
    bool? fromSender,
  }) async {
    log.info('Starting remote screen');

    if (_remoteScreenProvider.isRemoteScreenPublisherStarted()) {
      _isGroupMode = fromGroup ?? _isGroupMode;
      _isShareMode = fromShare ?? _isShareMode;
      _isSenderMode = fromSender ?? _isSenderMode;
      _save();
      notifyListeners();
      return;
    }
    _isGroupMode = fromGroup ?? _isGroupMode;
    _isShareMode = fromShare ?? _isShareMode;
    _isSenderMode = fromSender ?? _isSenderMode;
    _save();
    final iceServers = await _getIceServers();

    bool result = await _remoteScreenProvider.startPublish(iceServers);

    if (!result) {
      removeSender(fromSender: true, fromGroup: true);
      return await stopRemoteScreenPublisher();
    }

    if (!await AppOverlayTab().getVisibility()) {
      await AppOverlayTab().setVisibility(true);
      await AppOverlayTab().showFpsKeeper();
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

  Future<void> stopRemoteScreenPublisher() async {
    await _remoteScreenProvider.stopPublish();
  }

  void _onNewChannel(Channel channel, ChannelMode mode) {
    RTCConnector rtcConnector = RTCConnector(
      channel,
      maxVideoResolution: _highImageQuality
          ? MaxVideoResolution.uhd2160p_16x9
          : MaxVideoResolution.wqxga1600p_16x10,
    );
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
                      HybridConnectionList.maxHybridConnection ||
                  HybridConnectionList().connectionListFull()) {
                trackEvent(
                  'device_full',
                  EventCategory.session,
                  participatorId: msg.clientId,
                  mode: 'webrtc',
                );

                sendJoinDisplayRejectMessage(channel);
                return;
              }
              if (isModeratorMode &&
                  !(msg.isConnectedViaModeratorMode ?? false)) {
                sendJoinDisplayRejectMessage(channel,
                    errorCode: JoinDisplayRejectedReasonCode
                        .joinedBeforeModeratorOn.code,
                    reason: 'User name is null');
              } else if (HybridConnectionList().isPresenting()) {
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
                      HybridConnectionList.maxHybridSplitScreen ||
                  HybridConnectionList().connectionListFull()) {
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
            remoteScreenConnector = await _remoteScreenProvider
                .createRemoteScreenConnector(channel, msg);
            _remoteScreenConnectors.add(remoteScreenConnector!);
          }
          notifyListeners();
          break;
        case ChannelMessageType.startPresent:
          if (HybridConnectionList.hybridSplitScreenCount.value >=
              HybridConnectionList.maxHybridSplitScreen) {
            sendPresentRejectMessage(channel);
            break;
          }
          final iceServers = await _getIceServers();
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

            remoteScreenConnector = await _remoteScreenProvider
                .createRemoteScreenConnector(channel, joinMessage);
            _remoteShareConnectors.add(remoteScreenConnector!);

            final iceServers = await _getIceServers();

            _remoteScreenProvider.onStartRemoteScreen(remoteScreenConnector!,
                message as StartRemoteScreenMessage, iceServers);
            notifyListeners();

            break;
          }

          if (_isSenderMode) {
            final iceServers = await _getIceServers();

            if (remoteScreenConnector != null) {
              _remoteScreenProvider.onStartRemoteScreen(remoteScreenConnector!,
                  message as StartRemoteScreenMessage, iceServers);
            }
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

        case ChannelMessageType.remoteScreenStatus:
          final statusMessage = message as RemoteScreenStatusMessage;
          final status = statusMessage.status;

          if (status == RemoteScreenStatus.fpsZero) {
            log.warning(
                "Host received FPS zero notification from Cast to Device receiver");
            await _hostFpsZeroLogUploader.upload(
              'Host received FPS zero request from Cast to Device receiver.',
            );
          }
          break;

        default:
          break;
      }
    });

    if (displayGroupVideoView != null && isDisplayGroupVideoAvailable) {
      sendJoinDisplayRejectMessage(channel,
          errorCode:
              JoinDisplayRejectedReasonCode.receiverRemoteScreenBusy.code,
          reason: 'receive a remote screen');
    } else {
      sendDisplayStatus(channel);
    }
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
      if (_isChannelFromHost(connectionRequest.queryParameters)) {
        return ConnectRequestStatus.success;
      }

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

  void sendJoinDisplayRejectMessage(Channel channel,
      {int? errorCode, String? reason}) {
    final message = JoinDisplayRejectedMessage();
    if (errorCode != null) {
      message.reason = Reason(
        errorCode,
        text: reason,
      );
    } else {
      message.reason = Reason(
        JoinDisplayRejectedReasonCode.maxClientsReached.code,
        text: 'Max number of clients reached',
      );
    }
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
  }) async {
    if (remoteScreenConnector != null) {
      if (fromSender != null && fromSender) {
        int index = _remoteScreenConnectors.indexOf(remoteScreenConnector);
        if (index != -1) {
          if (kick) {
            remoteScreenConnector
                .sendRemoteScreenState(RemoteScreenStatus.kicked);
          }
          _remoteScreenProvider.removeConnector(_remoteScreenConnectors[index]);
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
          _remoteScreenProvider.removeConnector(_remoteShareConnectors[index]);
          _remoteShareConnectors.removeAt(index);
        }
      }
    } else {
      if (fromGroup != null) _isGroupMode = false;
      if (fromShare != null) _isShareMode = false;
      if (fromSender != null) {
        _isSenderMode = false;
        _save();
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

      if (fromGroup != null && fromGroup) {
        await providerContainer?.read(discoveryModelProvider.notifier).stop();
        providerContainer
            ?.read(groupProvider.notifier)
            .setBroadcastToGroup(false);
        _displayGroupHost?.stop();
        _displayGroupHost = null;
      }

      if (_isGroupMode || _isShareMode || _isSenderMode) {
        notifyListeners();
        return;
      }

      if (!_isSenderMode && !_isGroupMode && !_isShareMode) {
        await stopRemoteScreenPublisher();
        ConnectionTimer.getInstance().stopShareSenderTimer();
        if (await AppOverlayTab().getVisibility() &&
            await AppOverlayTab().getOverlayType() == OverlayType.fpsKeeper) {
          await AppOverlayTab().setVisibility(false);
        }
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
      _updateOTP();
      DisplayServiceBroadcast.instance?.onBroadcastRestart();
    }
  }

  _updateOTP() {
    otp.value = generateOTP(Random());
  }

  Future<List<RtcIceServer>?> _getIceServers() async {
    if (_shouldUseIceServers()) {
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

  bool _shouldUseIceServers() {
    final connectivityType = AppPreferences().connectivityType;

    // Enable ICE servers when the connectivity type is not restricted to local networks.
    return connectivityType != ConnectivityType.local.name;
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

  void startDisplayGroup(List<GroupListItem> newList,
      {bool anyCasting = false}) {
    log.info('Starting display group, anyCasting: $anyCasting');

    // Use P2P connection for WebRTC in the Display group by returning an empty ICE server list.
    getIceServersForDirect() => Future.value(<RtcIceServer>[]);

    var mediator = DisplayGroupMediatorObject(
        _remoteScreenProvider, getIceServersForDirect);

    _displayGroupHost ??= DisplayGroupHost(mediator, _hostFpsZeroLogUploader);

    if (!anyCasting) {
      _displayGroupHost!.resetCastRejectMember();
    }

    _handleGroupMembersChange(newList, _displayGroupHost!.members,
        onItemsAdded: (addedItems) {
      for (var member in addedItems) {
        final memberInfo = DisplayGroupMemberInfo(
          host: member.ip(),
          displayCode: member.displayCode(),
          version: member.ver(),
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

  //region handle Display Group's client
  Future<void> stopReceivedFromHost({required String closeReason}) async {
    await _displayGroupSession?.stop(reason: closeReason);
    _displayGroupSession = null;

    // Restore previous states if they were saved
    if (_previousSenderMode != null) {
      _isSenderMode = _previousSenderMode!;
      _previousSenderMode = null;
      if (_isSenderMode) {
        await startRemoteScreen(fromSender: true);
      }
    }
    if (_previousGroupMode != null) {
      _isGroupMode = _previousGroupMode!;
      _previousGroupMode = null;
      if (_isGroupMode) {
        await startRemoteScreen(fromGroup: true);
        providerContainer
            ?.read(groupProvider.notifier)
            .setBroadcastToGroup(_isGroupMode);
      }
    }
    if (_previousModeratorMode != null) {
      isModeratorMode = _previousModeratorMode!;
      _previousModeratorMode = null;
      if (isModeratorMode) {
        await startRemoteScreen(fromShare: true);
      }
    }

    notifyListeners();
  }

  void displayGroupOnMute() {
    _displayGroupSession?.onMute();
  }

  void refreshOnlyWhenCastingStatus() {
    if (providerContainer != null) {
      final toggle = providerContainer!.read(groupProvider).broadcastToGroup;
      final launchType =
          providerContainer!.read(groupProvider).broadcastGroupLaunchType;
      if (toggle && launchType == BroadcastGroupLaunchType.onlyWhenCasting) {
        final List<GroupListItem> selectedList =
            HybridConnectionList.hybridSplitScreenCount.value > 0
                ? providerContainer!.read(groupProvider).selectedList
                : [];
        startDisplayGroup(selectedList,
            anyCasting: HybridConnectionList.hybridSplitScreenCount.value != 0);
      }
    }
  }

// endregion

  void sortRemoteScreenConnectors(bool asc) {
    if (asc) {
      _remoteScreenConnectors.sortBySenderNameAsc();
    } else {
      _remoteScreenConnectors.sortBySenderNameDesc();
    }
    notifyListeners();
  }

  void restoreRemoteScreenConnectors() {
    _remoteScreenConnectors.sortByCreatedAtAsc();
  }

  bool get remoteScreenInProgress => _remoteScreenConnectors.isNotEmpty;

  bool get castToBoardInProgress {
    if (_displayGroupHost != null) {
      return (_displayGroupHost!.members as Map<String, DisplayGroupMember>)
          .isNotEmpty;
    } else {
      return false;
    }
  }

  bool get castModeLocked {
    return remoteScreenInProgress || castToBoardInProgress;
  }

  Future<void> setAndRestartRemoteScreen(
      {required AppSettings appSettings, required bool multicast}) async {
    final anyStart = _isGroupMode || _isShareMode || _isSenderMode;
    final tempGroupMode = _isGroupMode;
    final tempShareMode = _isShareMode;
    final tempSenderMode = _isSenderMode;

    if (anyStart) {
      await removeSender(
        fromGroup: true,
        fromSender: true,
        fromShare: true,
      );
    }
    await appSettings.setUseMulticast(multicast);
    if (anyStart) {
      await startRemoteScreen(
        fromGroup: tempGroupMode,
        fromShare: tempShareMode,
        fromSender: tempSenderMode,
      );
      providerContainer
          ?.read(groupProvider.notifier)
          .setBroadcastToGroup(tempGroupMode);
    }
  }

  @override
  void onRecreatePublisherFailure() {
    providerContainer?.read(dialogProvider.notifier).hideDialog();
    providerContainer?.read(dialogProvider.notifier).showDialog(
          title: "",
          content: S.current.v3_zero_fps_restart_failed,
          cancelText: S.current.v3_zero_fps_close,
          width: 280,
          height: 200,
          onCancel: () {
            stopRemoteScreenFromFail();
          },
        );
    sendRemoteScreenStatusToMembers(RemoteScreenStatus.hostRecreateFailure);
  }

  @override
  void onRecreatePublisherSuccess() {
    providerContainer?.read(dialogProvider.notifier).hideDialog();
    providerContainer?.read(dialogProvider.notifier).showDialog(
          title: "",
          content: S.current.v3_zero_fps_restarted_Successfully,
          cancelText: S.current.v3_zero_fps_close,
          width: 280,
          height: 200,
          onCancel: () {},
        );
    sendRemoteScreenStatusToMembers(RemoteScreenStatus.hostRecreateSuccess);
  }

  @override
  Future<void> onShowZeroFpsPrompt() async {
    // UI
    if (await AppOverlayTab().getVisibility() &&
        await AppOverlayTab().getOverlayType() == OverlayType.tab) {
      showOverlayTab = true;
    } else {
      showOverlayTab = false;
      await AppOverlayTab().setVisibility(true);
    }
    await AppOverlayTab().showZeroDialog();
    sendRemoteScreenStatusToMembers(RemoteScreenStatus.hostFpsZero);
  }

  void sendRemoteScreenStatusToMembers(RemoteScreenStatus status) {
    // 大傳小
    // for (var connector in _remoteScreenConnectors) {
    //   connector.sendRemoteScreenState(RemoteScreenStatus.fpsZero);
    // }
    // 大傳大
    final members = _displayGroupHost?.members;
    if (members is Map<String, DisplayGroupMember>) {
      for (final member in members.values) {
        // 3.9.4以後才支援訊息
        if (DisplayGroupMember.isVersionGreater(member.version, "3.9.3")) {
          member.sendRemoteScreenState(status);
        }
      }
    }
  }
}
