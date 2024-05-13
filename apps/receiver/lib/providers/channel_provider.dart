import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/model/connect_timer.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/remote_screen_connector.dart';
import 'package:display_flutter/model/remote_screen_server.dart';
import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:display_flutter/settings/app_config.dart';
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

String _getPrivateIpWithDefault(String? ipAddress, String defaultIpAddress) {
  if (ipAddress == null) {
    return defaultIpAddress;
  }

  if (isPrivateIp(ipAddress)) {
    return ipAddress;
  }

  return defaultIpAddress;
}

class ChannelProvider extends ChangeNotifier {
  AppConfig appConfig;

  static final _log = getDefaultLogger();

  ConnectivityResult _lastConnectivityResult = ConnectivityResult.none;

  bool _connectNet = false;

  bool get connectNet => _connectNet;

  set connectNet(bool value) {
    _connectNet = value;
    notifyListeners();
  }

  final int maxCountDown = 300;
  final ValueNotifier<bool> isEyeOpen = ValueNotifier(true);
  final ValueNotifier<int> countDownProgress = ValueNotifier(300);
  final ValueNotifier<int> otp = ValueNotifier(0000);
  final List<String> _otpList = [];

  List<String> get otpList => _otpList;

  String? host;
  bool isServerStart = false;
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
  ) {
    _setConnectivityListener();
    _generateOTP();
    _startNewOTPTimer();
  }

  void _setConnectivityListener() {
    Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      _log.info('Network connectivity has changed to $result');

      if (result == ConnectivityResult.none) {
        connectNet = false;
        stopServer();
      } else {
        connectNet = true;
        _log.info(
            'Last Network Connectivity is: $_lastConnectivityResult, being changed to result: $result');
        // MUST add async/await, to compare connectivity result with last one.
        await _checkNetWorkInfo().then((value) {
          host = _instanceInfo.ipAddress = value;

          if (_lastConnectivityResult != result) {
            //displayCode.isEmpty || _tunnelApiUrl.isEmpty
            registerInstanceIndexById(AppInstanceCreate().displayInstanceID)
                .then((int? instanceIndex) {
              final displayCode = encodeDisplayCode(
                DisplayCode(
                  _getPrivateIpWithDefault(host, '192.168.0.0'),
                  instanceIndex ?? 0,
                ),
              );

              _instanceInfo.displayCode = displayCode ?? '';

              startServer(AppInstanceCreate().displayInstanceID);
            });
          }
        });
      }

      // Save connectivity result, for status compare.
      _lastConnectivityResult = result;
    });
  }

  void _setTunnelServer() {
    // create a tunnel server
    _tunnelServer = DisplayTunnelServer(
      (String url) => WebSocketClientConnection(
        url,
        logger: (url, message) {
          _log.finest('Tunnel $message');
        },
      ),
      (Channel channel) => _onNewChannel(channel, ChannelMode.tunnel),
      (ConnectionRequest connectionRequest) =>
          _verifyConnectRequest(connectionRequest, isDirectConnect: false),
    );

    _tunnelServer?.onTunnelConnected = () {
      _log.info('Tunnel connected');
    };
    _tunnelServer?.onTunnelConnecting = () {
      _log.info('Tunnel is connecting');
    };
  }

  void _setDirectServer() {
    // create a direct server
    _directServer = DisplayDirectServer(
      (Channel channel) => _onNewChannel(channel, ChannelMode.direct),
      (ConnectionRequest connectionRequest) =>
          _verifyConnectRequest(connectionRequest, isDirectConnect: true),
    );
  }

  Future startRemoteScreen() async {
    await _remoteScreenServe.startSfuServer();
    await _remoteScreenServe.startRemoteScreenPublisher();
    ConnectionTimer.getInstance().startShareSenderTimer(() {
      removeSender();
      ChannelProvider.isSenderMode = false;
    });
  }

  void stopRemoteScreenPublisher() {
    _remoteScreenServe.stopRemoteScreenPublisher();
  }

  Future<void> startServer(String instanceId) async {
    if (isServerStart) return;

    // start the tunnel server
    _log.info('Starting the tunnel channel server $_tunnelApiUrl');
    if (_tunnelApiUrl.isNotEmpty && _tunnelServer == null) {
      // fix when _tunnelApiUrl is empty, will cause App UI not response.
      _setTunnelServer();
      _tunnelServer?.start(instanceId, _tunnelApiUrl);
    }

    // start the direct server
    try {
      final securityContext = await loadSecurityContextForChannel();

      _log.info('Starting the direct channel server');
      if (_directServer == null) {
        _setDirectServer();
        await _directServer?.start(
          appConfig.directChannelPort,
          securityContext: securityContext,
        );
      }
    } on PathNotFoundException catch (e) {
      _log.severe(
          'Failed to load certificate or private key for secure direct connections. $e');
    }

    isServerStart = true;
  }

  void _onNewChannel(Channel channel, ChannelMode mode) {
    RTCConnector rtcConnector = RTCConnector(channel, mode);
    _log.info('Received a new channel');
    RemoteScreenConnector? remoteScreenConnector;

    channel.onChannelMessage = (ChannelMessage message) async {
      _log.info('Received channel message ${message.messageType}');

      switch (message.messageType) {
        /// basic
        case ChannelMessageType.joinDisplay:
          JoinDisplayMessage msg = message as JoinDisplayMessage;
          if (msg.intent == JoinIntentType.present) {
            if (_isModeratorMode) {
              if (HybridConnectionList().getConnectionCount() >=
                  HybridConnectionList.maxHybridConnection) {
                final message = JoinDisplayRejectedMessage();
                message.reason = Reason(
                  JoinDisplayRejectedReasonCode.maxClientsReached.code,
                  text: 'Max number of clients reached',
                );
                channel.send(message);
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
          }
          notifyListeners();
          break;
        case ChannelMessageType.startPresent:
          if (HybridConnectionList.hybridSplitScreenCount.value >=
              HybridConnectionList.maxHybridSplitScreen) {
            final message = PresentRejectedMessage();
            message.reason = Reason(
              PresentRejectedReasonCode.maxPresentReached.code,
              text: 'Max number of presentations reached',
            );
            channel.send(message);
            break;
          }
          rtcConnector.onStartPresent(
              message as StartPresentMessage, _isModeratorMode);
          break;
        case ChannelMessageType.presentAccepted:
          rtcConnector.onPresentAccepted();
          break;
        case ChannelMessageType.presentRejected:
          rtcConnector.onPresentRejected(message as PresentRejectedMessage);
          break;
        case ChannelMessageType.changePresentQuality:
          rtcConnector.onChangeQuality(message as ChangePresentQuality);
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
            await remoteScreenConnector
                ?.onStartRemoteScreen(message as StartRemoteScreenMessage);
            notifyListeners();
          } else {
            await remoteScreenConnector
                ?.sendRemoteScreenState(RemoteScreenStatus.rejected);
            removeSender(remoteScreenConnector: remoteScreenConnector);
          }
          break;
        default:
          break;
      }
    };

    sendDisplayStatus(channel);
  }

  bool stopServer() {
    _log.info('Stopping the channel server');

    _tunnelServer?.stop();
    _tunnelServer = null;
    _directServer?.stop();
    _directServer = null;
    return isServerStart = false;
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

  RTCConnector _onJoinDisplay(
      RTCConnector rtcConnector, ChannelMode mode, JoinDisplayMessage message) {
    // create a client object to handle this channel
    rtcConnector.init(message, _isModeratorMode,
        iceServersApiUrl: appConfig.settings.getIceServer);
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
      _log.info('Registering the instance ${appConfig.settings.apiGateway}');

      http.Response response = await http.put(
        Uri.parse(appConfig.settings.apiGateway),
        body: json.encode({
          'instanceId': instanceId,
          'version': appConfig.appVersion,
          'platform': "android",
        }),
      );
      _log.info('Status of Instance Register API: ${response.statusCode}');

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
      _log.warning('Instance Register API failed with $e');
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
    for (NetworkInterface interface in interfaces) {
      if (interface.name.toLowerCase().contains("eth")) {
        // 'eth' 通常是 Ethernet
        String? ethernetIp = interface.addresses.isNotEmpty
            ? interface.addresses[0].address
            : null;
        if (ethernetIp != null) {
          return ethernetIp;
        }
        break;
      } else if (interface.name.toLowerCase().contains("wi") ||
          interface.name.toLowerCase().contains("wlan")) {
        // 'wi' 或 'wlan' 通常是 WiFi
        String? wifiIp = interface.addresses.isNotEmpty
            ? interface.addresses[0].address
            : null;
        if (wifiIp != null) {
          return wifiIp;
        }
        break;
      } else if (interface.name.toLowerCase().contains("rmnet") ||
          interface.name.toLowerCase().contains("wwan")) {
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
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      countDownProgress.value -= 1;
      if (countDownProgress.value == 0) {
        _generateOTP();
        timer.cancel();
        _startNewOTPTimer();
      }
    });
  }

  _generateOTP() {
    otp.value = Random().nextInt(9000) + 1000;
    if (!otpList.contains(otp.value.toString())) {
      _otpList.add(otp.value.toString());
      if (_otpList.length > 2) {
        _otpList.remove(_otpList.first);
      }
    }
    countDownProgress.value = maxCountDown;
  }
}
