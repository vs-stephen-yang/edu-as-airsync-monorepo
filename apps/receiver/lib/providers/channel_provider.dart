import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/main_common.dart';
import 'package:display_flutter/model/connect_timer.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/model/remote_screen_connector.dart';
import 'package:display_flutter/model/remote_screen_server.dart';
import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/utility/log.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:flutter/cupertino.dart';
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

enum PresentationState {
  stopStreaming,
  occupied,
  waitForStream,
  streaming,
  pauseStreaming,
  resumeStreaming,
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

  bool _lanNetWork = false;

  bool get lanNetWork => _lanNetWork;

  set lanNetWork(bool value) {
    _lanNetWork = value;
    notifyListeners();
  }

  String _displayCode = '';

  String get displayCode => _displayCode;

  String get displayCodeWithDash => _getDisplayCodeWithDash(_displayCode);

  set displayCode(String value) {
    _displayCode = value;
    notifyListeners();
  }

  final int maxCountDown = 300;
  final ValueNotifier<bool> isEyeOpen = ValueNotifier(true);
  final ValueNotifier<int> countDownProgress = ValueNotifier(300);
  final ValueNotifier<int> otp = ValueNotifier(0000);
  final List<String> _otpList = [];

  List<String> get otpList => _otpList;

  String? host;
  int port = 5100;
  bool isServerStart = false;
  late DisplayDirectServer? _directServer;
  late DisplayTunnelServer? _tunnelServer;
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

  ChannelProvider(this.appConfig) {
    _checkConnectivity().then((value) {
      _log.info('checkConnectivity: $value');
      if (value) {
        connectNet = true;
        _checkNetWorkInfo().then((value) {
          host = value;
          if (displayCode.isEmpty || _tunnelApiUrl.isEmpty) {
            getDisplayCode(AppInstanceCreate().displayInstanceID).then((value) {
              if (value.isNotEmpty) {
                displayCode =
                    encodeDisplayCode(DisplayCode(host!, int.parse(value)))!;
              } else {
                displayCode = encodeDisplayCode(DisplayCode(host!, 0))!;
              }
              startServer(AppInstanceCreate().displayInstanceID);
            });
          }
        });
      }
    });

    Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      _log.info('Network connectivity has changed to $result');

      if (result == ConnectivityResult.none) {
        connectNet = false;
        lanNetWork = false;
      } else {
        connectNet = true;
        _log.info(
            'Last Network Connectivity is: $_lastConnectivityResult, result: $result');
        // MUST add async/await, to compare connectivity result with last one.
        await _checkNetWorkInfo().then((_) {
          _log.info(
              'Last Network Connectivity is: $_lastConnectivityResult, result: $result');
          if (displayCode.isEmpty || _lastConnectivityResult != result) {
            getDisplayCode(AppInstanceCreate().displayInstanceID).then((value) {
              if (value.isNotEmpty) {
                displayCode =
                    encodeDisplayCode(DisplayCode(host!, int.parse(value)))!;
              } else {
                displayCode = encodeDisplayCode(DisplayCode(host!, 0))!;
              }
              startServer(AppInstanceCreate().displayInstanceID);
            });
          }
        });
      }

      // Save connectivity result, for status compare.
      _lastConnectivityResult = result;
    });

    _generateOTP();
    _startNewOTPTimer();
  }

  void connectServer(BuildContext context) {
    MyApp.isInBackgroundMode = false;
    ConnectionTimer.getInstance().stopServerTimer();
    startServer(AppInstanceCreate().displayInstanceID);
  }

  void disconnectServer() {
    MyApp.isInBackgroundMode = true;
    if (!HybridConnectionList().hasPresenterOccupied()) {
      ConnectionTimer.getInstance().startServerTimer(() {
        // onFinish
        stopServer();
      });
    }
  }

  void _setServerSide() {
    // create a direct server
    _directServer = DisplayDirectServer(
      (Channel channel) => _onNewChannel(channel, ChannelMode.direct),
      (ConnectionRequest connectionRequest) =>
          _verifyConnectRequest(connectionRequest),
    );

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
          _verifyConnectRequest(connectionRequest),
    );

    _tunnelServer?.onTunnelConnected = () {
      _log.info('Tunnel connected');
    };
    _tunnelServer?.onTunnelConnecting = () {
      _log.info('Tunnel is connecting');
    };
  }

  Future startRemoteScreen() async {
    await _remoteScreenServe.startSfuServer();
    await _remoteScreenServe.startRemoteScreenPublisher();
  }

  void stopRemoteScreenPublisher() {
    _remoteScreenServe.stopRemoteScreenPublisher();
  }

  Future<void> startServer(String instanceId) async {
    if (isServerStart) return;
    _setServerSide();

    // start the tunnel server
    _log.info('Starting the tunnel channel server $_tunnelApiUrl');
    if (_tunnelApiUrl.isNotEmpty) {
      // fix when _tunnelApiUrl is empty, will cause App UI not response.
      _tunnelServer?.start(instanceId, _tunnelApiUrl);
    }

    // start the direct server
    _log.info('Starting the direct channel server');
    await _directServer?.start(port);
    isServerStart = true;
  }

  void _onNewChannel(Channel channel, ChannelMode mode) {
    RTCConnector rtcConnector = RTCConnector(channel, mode);
    _log.info('Received a new channel');
    RemoteScreenConnector? remoteScreenConnector;

    channel.onChannelMessage = (ChannelMessage message) async {
      _log.info('Received channel message ${message.messageType}');

      // if (blockRtcConnection) {
      //   var message = PresentRejectedMessage();
      //   message.reason = Reason(403, text: 'block');
      //   channel.send(message);
      //   rtcConnector.onPresentRejected(message);
      //   return;
      // }

      switch (message.messageType) {
        /// basic
        case ChannelMessageType.joinDisplay:
          JoinDisplayMessage msg = message as JoinDisplayMessage;
          if (msg.intent == JoinIntentType.present) {
            if (_isModeratorMode) {
              if (HybridConnectionList().hybridConnectionList.nonNulls.length >=
                  6) {
                var message = PresentRejectedMessage();
                message.reason = Reason(401, text: 'block');
                channel.send(message);
                return;
              }
            } else {
              if (SplitScreen.mapSplitScreen.value[keySplitScreenCount] == 4) {
                var message = PresentRejectedMessage();
                message.reason = Reason(402, text: 'block');
                channel.send(message);
                return;
              }
            }
            rtcConnector = _onJoinDisplay(rtcConnector, mode, msg);
          } else {
            if (_remoteScreenConnectors.length >= 10) {
              var message = PresentRejectedMessage();
              message.reason = Reason(401, text: 'block');
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
          rtcConnector.onStartPresent(message as StartPresentMessage);
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
      ConnectionRequest connectionRequest) {
    if (connectionRequest.displayCode != displayCode) {
      return ConnectRequestStatus.invalidDisplayCode;
    } else if (!_isValidOtp(connectionRequest.token)) {
      return ConnectRequestStatus.invalidOtp;
    } else {
      return ConnectRequestStatus.success;
    }
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
    });

    rtcConnector.onAddRemoteStream = ((stream) {
      // update state and quality
      HybridConnectionList().updateSplitScreen();
      HybridConnectionList().handleQualityUpdate(controller: rtcConnector);

      // hideTitleBar
      Home.showTitleBottomBar.value = false;

      StreamFunction.streamFunctionState.value = stateMenuOff;
      notifyListeners();
    });

    rtcConnector.onRefresh = (() {
      notifyListeners();
    });

    rtcConnector.onChannelDisconnect = (() async {
      // update UI
      bool presenting = false;
      for (RTCConnector? rtcConnector
          in HybridConnectionList().getRtcConnectorMap().values) {
        if (rtcConnector != null &&
            rtcConnector.presentationState != PresentationState.stopStreaming) {
          presenting = true;
        }
      }
      if (!presenting) {
        Home.showTitleBottomBar.value = true;
      } else {
        Home.enlargedScreenPositionIndex.value = null;
      }
      if (MyApp.isInBackgroundMode) {
        disconnectServer();
      }
      await rtcConnector.close(ChannelCloseCode.close);
      HybridConnectionList().removeConnection(rtcConnector);
      HybridConnectionList().updateSplitScreen();
      HybridConnectionList().handleQualityUpdate();
      notifyListeners();
    });

    HybridConnectionList().addConnection(rtcConnector);

    return rtcConnector;
  }

  Future<String> getDisplayCode(String instanceID) async {
    try {
      _log.info('Registering the instance ${appConfig.settings.apiGateway}');

      http.Response response = await http.put(
        Uri.parse(appConfig.settings.apiGateway),
        body: json.encode({
          'instanceId': instanceID,
          'version': appConfig.appVersion,
          'platform': "android",
        }),
      );
      _log.info('Status of Instance Register API: ${response.statusCode}');

      if (response.statusCode >= HttpStatus.ok &&
          response.statusCode < HttpStatus.multiStatus) {
        Map json = jsonDecode(response.body);

        _tunnelApiUrl = json['tunnelApiUrl'] ?? '';
        return json['instanceIndex'];
      } else {
        return '';
      }
    } catch (e) {
      _log.warning('Instance Register API failed with $e');
      // http.get maybe no network connection.
      return '';
    }
  }

  // Future<void> basicStreamOff() async {
  //   ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
  //   ConnectionTimer.getInstance().stopRemainingTimeTimer();
  //   await RtcConnectorList().removeAllPresenters();
  // }
  //
  // Future<void> splitScreenOff() async {
  //   ConnectionTimer.getInstance().stopRemainingTimeTimer();
  //   await RtcConnectorList().removeAllPresenters();
  // }

  updateAllQuality(int selection, bool hasSelected) {
    var rtcConnectorMap = HybridConnectionList().getRtcConnectorMap();
    if (selection == -1) {
      rtcConnectorMap.values.first.sendChangeQuality(true, true);
    } else {
      for (RTCConnector rtcConnector in rtcConnectorMap.values) {
        if (rtcConnector.clientId != null) {
          rtcConnector.sendChangeQuality(
              (rtcConnector == rtcConnectorMap[selection] && hasSelected),
              (rtcConnector == rtcConnectorMap[selection] || !hasSelected));
        }
      }
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
    }
    notifyListeners();
  }

  Future<bool> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    return true;
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
          lanNetWork = isPrivateIp(ethernetIp);
          host = ethernetIp;
          return host;
        }
        break;
      } else if (interface.name.toLowerCase().contains("wi") ||
          interface.name.toLowerCase().contains("wlan")) {
        // 'wi' 或 'wlan' 通常是 WiFi
        String? wifiIp = interface.addresses.isNotEmpty
            ? interface.addresses[0].address
            : null;
        if (wifiIp != null) {
          lanNetWork = isPrivateIp(wifiIp);
          host = wifiIp;
          return host;
        }
        break;
      } else if (interface.name.toLowerCase().contains("rmnet") ||
          interface.name.toLowerCase().contains("wwan")) {
        String? mobileIp = interface.addresses.isNotEmpty
            ? interface.addresses[0].address
            : null;
        if (mobileIp != null) {
          lanNetWork = isPrivateIp(mobileIp);
          host = mobileIp;
          return host;
        }
        break;
      }
    }
    return host = null;
  }

  bool isPrivateIp(String ip) {
    if (ip.startsWith('192.168.')) return true;
    if (ip.startsWith('10.')) return true;
    if (ip.startsWith('172.')) {
      var parts = ip.split('.');
      var secondPart = int.tryParse(parts[1]);
      if (secondPart != null && secondPart >= 16 && secondPart <= 31) {
        return true;
      }
    }
    return false;
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

  _getDisplayCodeWithDash(String displayCode) {
    String result = '';
    for (int i = 0; i < displayCode.length; i++) {
      if (i % 3 == 0 && result.isNotEmpty) {
        result += '-';
      }
      result += displayCode.substring(i, i + 1);
    }
    return result;
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
