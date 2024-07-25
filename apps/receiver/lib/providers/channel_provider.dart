import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/api/ice_api.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/model/connect_timer.dart';
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
import 'package:display_flutter/utility/ip_util.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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

  static const _otpTickInterval = Duration(milliseconds: 100);
  static const _otpDuration = Duration(minutes: 2);

  Timer? _otpTickTimer;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  final ValueNotifier<bool> isEyeOpen = ValueNotifier(true);
  late ValueNotifier<int> countDownProgress;
  final ValueNotifier<bool> isLanModeOnly = ValueNotifier(false);
  final ValueNotifier<int> otp = ValueNotifier(0000);
  final List<String> _otpList = [];

  List<String> get otpList => _otpList;

  String? host;
  bool _isTunnelServerStart = false;
  bool _isDirectServerStart = false;
  DisplayDirectServer? _directServer;
  DisplayTunnelServer? _tunnelServer;
  String _tunnelApiUrl = '';

  bool _isModeratorMode = false;

  bool get isModeratorMode => _isModeratorMode;

  set isModeratorMode(bool value) {
    _isModeratorMode = value;
    notifyListeners();
  }

  bool blockRtcConnection = false;

  final RemoteScreenServer _remoteScreenServe = RemoteScreenServer();

  RemoteScreenServer get remoteScreenServe => _remoteScreenServe;
  static final List<RemoteScreenConnector> _remoteScreenConnectors =
      <RemoteScreenConnector>[];

  static List<RemoteScreenConnector> get remoteScreenConnectors =>
      _remoteScreenConnectors;
  static bool isSenderMode = false;

  final InstanceInfoProvider _instanceInfo;

  bool _isDeviceListQuickConnect = false;

  bool get isDeviceListQuickConnect => _isDeviceListQuickConnect;

  set isDeviceListQuickConnect(bool value) {
    _isDeviceListQuickConnect = value;
    notifyListeners();
  }

  ChannelProvider(
    this.appConfig,
    this._instanceInfo,
  ) : maxCountDown =
            _otpDuration.inMilliseconds ~/ _otpTickInterval.inMilliseconds {
    countDownProgress = ValueNotifier(maxCountDown);
  }

  startChannelProvider() {
    _setConnectivityListener();
    _startNewOTPTimer();
  }

  void _setConnectivityListener() {
    _connectivitySubscription ??=
        Connectivity().onConnectivityChanged.listen((result) async {
      log.info('Network connectivity has changed to $result');

      if (result == ConnectivityResult.none) {
        _handleNoConnectivity();
      } else {
        await _handleConnectivity(result);
      }
      _lastConnectivityResult = result;
    });
  }

  void _handleNoConnectivity() {
    connectNet = false;
    stopServer();
    _instanceInfo.displayCode = '';
  }

  Future<void> _handleConnectivity(ConnectivityResult result) async {
    connectNet = true;
    log.info('Last Network Connectivity is: $_lastConnectivityResult, being changed to result: $result');

    final value = await _checkNetWorkInfo();
    host = _instanceInfo.ipAddress = value;

    if (_lastConnectivityResult != result) {
      registerInstanceIndexById(AppInstanceCreate().displayInstanceID)
          .then((value) => _handleInstanceIndex(value));
    }
  }

  void _handleInstanceIndex(int? instanceIndex) {
    final displayCode = encodeDisplayCode(
      DisplayCode(
        _getPrivateIpWithDefault(host, '192.168.0.0'),
        instanceIndex ?? 0,
      ),
    );

    _instanceInfo.displayCode = displayCode ?? '';
    AppAnalytics().setEventProperties(displayCode: displayCode);

    if (instanceIndex != null) {
      startServer(AppInstanceCreate().displayInstanceID);
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
      (Channel channel) => _onNewChannel(channel, ChannelMode.tunnel),
      (ConnectionRequest connectionRequest) =>
          _verifyConnectRequest(connectionRequest, isDirectConnect: false),
    );

    _tunnelServer?.onTunnelConnected = () {
      log.info('Tunnel connected');
       AppAnalytics().trackEventTunnelConnected();
    };
    _tunnelServer?.onTunnelConnecting = () {
      log.info('Tunnel is connecting');
      AppAnalytics().trackEventTunnelConnecting();
    };
  }

  void _setDirectServer() {
    // create a direct server
    _directServer = DisplayDirectServer(
      reconnectTimeout: channelReconnectTimeoutInStreaming,
      (Channel channel) => _onNewChannel(channel, ChannelMode.direct),
      (ConnectionRequest connectionRequest) =>
          _verifyConnectRequest(connectionRequest, isDirectConnect: true),
    );
  }

  Future startRemoteScreen() async {
    final iceServers = await _getIceServers(ChannelMode.tunnel);

    await _remoteScreenServe.startSfuServer(iceServers);
    await _remoteScreenServe.startRemoteScreenPublisher();
    ConnectionTimer.getInstance().startShareSenderTimer(() {
      removeSender();
      ChannelProvider.isSenderMode = false;
    });
  }

  void stopRemoteScreenPublisher() {
    _remoteScreenServe.stopRemoteScreenPublisher();
  }

  Future<void> startTunnelServer(String instanceId) async {
    if (_isTunnelServerStart) return;

    // start the tunnel server
    log.info('Starting the tunnel channel server $_tunnelApiUrl');
    if (_tunnelApiUrl.isNotEmpty && _tunnelServer == null) {
      // fix when _tunnelApiUrl is empty, will cause App UI not response.
      _setTunnelServer();
      _tunnelServer?.start(instanceId, _tunnelApiUrl);
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

  Future<void> startServer(String instanceId) async {
    if (!_isTunnelServerStart) startTunnelServer(instanceId);
    if (!_isDirectServerStart) startDirectServer();
  }

  void _onNewChannel(Channel channel, ChannelMode mode) {
    RTCConnector rtcConnector = RTCConnector(channel);
    log.info('Received a new channel');
    RemoteScreenConnector? remoteScreenConnector;

    channel.onChannelMessage = (ChannelMessage message) async {
      log.info('Received channel message ${message.messageType}');

      switch (message.messageType) {
        /// basic
        case ChannelMessageType.joinDisplay:
          JoinDisplayMessage msg = message as JoinDisplayMessage;
          if (msg.intent == JoinIntentType.present) {
            if (_isModeratorMode) {
              if (HybridConnectionList().getConnectionCount() >=
                  HybridConnectionList.maxHybridConnection) {
                sendPresentRejectMessage(channel);
                return;
              }
            } else {
              if (HybridConnectionList.hybridSplitScreenCount.value >=
                  HybridConnectionList.maxHybridSplitScreen) {
                sendPresentRejectMessage(channel);
                return;
              }
            }
            rtcConnector = _onJoinDisplay(rtcConnector, mode, msg);
          } else {
            if (_remoteScreenConnectors.length >= 10) {
              final message = JoinDisplayRejectedMessage();
              message.reason = Reason(
                JoinDisplayRejectedReasonCode.maxClientsReached.code,
                text: 'Max number of clients reached',
              );
              channel.send(message);
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
                  remoteScreenConnector: remoteScreenConnector, kick: false);
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
              message as StartPresentMessage, _isModeratorMode, iceServers,);
          break;
        case ChannelMessageType.presentAccepted:
          rtcConnector.onPresentAccepted();
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
              message as StopPresentMessage, _isModeratorMode);
          break;
        case ChannelMessageType.presentSignal:
          rtcConnector.onPresentSignal(message as PresentSignalMessage);
          break;
        case ChannelMessageType.channelClosed:
          rtcConnector.onChannelClose(message as ChannelClosedMessage);
          break;

        /// remote
        case ChannelMessageType.startRemoteScreen:
          if (isSenderMode) {
            final iceServers = await _getIceServers(mode);

            await remoteScreenConnector?.onStartRemoteScreen(
              message as StartRemoteScreenMessage,
              iceServers,
            );
            notifyListeners();
          } else {
            await remoteScreenConnector
                ?.sendRemoteScreenState(RemoteScreenStatus.rejected);
            removeSender(remoteScreenConnector: remoteScreenConnector);
          }
          break;

        case ChannelMessageType.remoteScreenSignal:
          final signalMessage = message as RemoteScreenSignalMessage;
          remoteScreenConnector?.processSignalFromPeer(signalMessage.signal!);
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
    return _isDeviceListQuickConnect;
  }

  bool _isValidOtp(String token) {
    return appConfig.settings.defaultOtp == token || otpList.contains(token);
  }

  void sendDisplayStatus(Channel channel) {
    final displayStatusMessage = DisplayStatusMessage();
    displayStatusMessage.platform = _getPlatform();
    displayStatusMessage.status =
        DisplayStatus.fromJson({'moderator': _isModeratorMode});
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
    rtcConnector.init(message, _isModeratorMode);
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

    rtcConnector.onChannelDisconnect = (() async {
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
      }
      await rtcConnector.close(ChannelCloseCode.close);
      HybridConnectionList().removeConnection(rtcConnector);
      HybridConnectionList().updateSplitScreen();

      notifyListeners();
    });

    HybridConnectionList().addConnection(rtcConnector);

    return rtcConnector;
  }

  Future<int?> registerInstanceIndexById(String instanceId) async {
    try {
      log.info('Registering the instance ${appConfig.settings.apiGateway}');

      http.Response response = await http
          .put(
            Uri.parse(appConfig.settings.apiGateway),
            body: json.encode({
              'instanceId': instanceId,
              'version': appConfig.appVersion,
              'platform': "android",
            }),
          ).timeout(const Duration(seconds: 3));
      log.info('Status of Instance Register API: ${response.statusCode}');

      if (response.statusCode >= HttpStatus.ok &&
          response.statusCode < HttpStatus.multiStatus) {
        Map json = jsonDecode(response.body);

        _tunnelApiUrl = json['tunnelApiUrl'] ?? '';
        final instanceIndex = json['instanceIndex'];

        return int.parse(instanceIndex);
      } else {
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

  removeSender(
      {RemoteScreenConnector? remoteScreenConnector, bool kick = true}) {
    if (remoteScreenConnector != null) {
      int index = remoteScreenConnectors.indexOf(remoteScreenConnector);
      if (index != -1) {
        if (kick) {
          remoteScreenConnector
              .sendRemoteScreenState(RemoteScreenStatus.kicked);
        }
        _remoteScreenServe.removeConnector(remoteScreenConnectors[index]);
        remoteScreenConnectors.removeAt(index);
      }
    } else {
      for (var element in remoteScreenConnectors) {
        element.sendRemoteScreenState(RemoteScreenStatus.kicked);
      }
      remoteScreenConnectors.clear();
      stopRemoteScreenPublisher();
      ConnectionTimer.getInstance().stopShareSenderTimer();
    }
    notifyListeners();
  }

  Future<String?> _checkNetWorkInfo() async {
    List<NetworkInterface> interfaces = await NetworkInterface.list();

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

  String _getPrivateIpWithDefault(String? ipAddress, String defaultIpAddress) {
    if (ipAddress == null) {
      return defaultIpAddress;
    }

    if (isPrivateIp(ipAddress)) {
      return ipAddress;
    }

    return defaultIpAddress;
  }

  String _getPlatform() {
    String platform;
    if (kIsWeb) {
      platform = 'Web';
    } else {
      if (Platform.isIOS) {
        platform = 'iOS';
      } else if (Platform.isAndroid) {
        platform = 'Android';
      } else {
        platform = '';
      }
    }
    return platform;
  }

  _startNewOTPTimer() {
    if (_otpTickTimer != null) {
      return;
    }

    _generateOTP();

    _otpTickTimer = Timer.periodic(_otpTickInterval, (timer) {
      _onOTPTick();
    });
  }

  _onOTPTick() {
    countDownProgress.value -= 1;
    if (countDownProgress.value == 0) {
      countDownProgress.value = maxCountDown;

      _generateOTP();
      _updateDisplayCode();
    }
  }

  _generateOTP() {
    otp.value = Random().nextInt(9000) + 1000;

    if (!otpList.contains(otp.value.toString())) {
      _otpList.add(otp.value.toString());

      if (_otpList.length > 2) {
        _otpList.remove(_otpList.first);
      }
    }
  }

  _updateDisplayCode() async {
    if (_isTunnelServerStart || !connectNet) return;
    final value = await _checkNetWorkInfo();
    host = _instanceInfo.ipAddress = value;

    registerInstanceIndexById(AppInstanceCreate().displayInstanceID)
        .then((value) => _handleInstanceIndex(value));
  }

  Future<List<RtcIceServer>?> _getIceServers(ChannelMode mode) async {
    if (mode == ChannelMode.tunnel) {
      return await getIceServers(appConfig.settings.getIceServer);
    } else {
      return [
        RtcIceServer(['stun:$host'])
      ];
    }
  }
}
