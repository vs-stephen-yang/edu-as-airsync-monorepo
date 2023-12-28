import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/main_common.dart';
import 'package:display_flutter/model/connect_timer.dart';
import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:no_context_navigation/no_context_navigation.dart';

import 'mirror_state_provider.dart';


///
/// ChannelProvider
/// - get Tunnel url and display code
/// - connect tunnel server(_tunnelServer) and direct server(_directServer) via display_channel plugin
/// - communicate custom protocols with server and build webRTC connection(_channelRtcConnectors)
/// - refresh MainInternetMode, MainLanMode, WebRTCView
/// -
/// - moderator

enum Mode {
  internet,
  lan
}

enum Feature {
  basic,
  splitScreen,
  moderator,
  mirror
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
  static bool isNewUI = true;
  AppConfig appConfig;
  late String apiGateway, version;

  Mode _currentMode = Mode.internet;
  Mode get currentMode => _currentMode;
  set currentMode(Mode value) {
    _currentMode = value;
    notifyListeners();
  }

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
  bool showMode = true;
  String _displayCode = '';
  String get displayCode => _displayCode;
  set displayCode(String value) {
    _displayCode = value;
    notifyListeners();
  }
  String _otp = '';
  String get otp => _otp;
  set otp(String value) {
    _otp = value;
    notifyListeners();
  }
  final List<String> _otpList =[];
  List<String> get otpList => _otpList;
  setOtpList(String addOTP) {
    _otpList.add(addOTP);
    if (_otpList.length > 2) {
      _otpList.remove(_otpList.first);
    }
  }

  String? host;
  int port = 5100;
  // int passcode = 7;
  bool isServerStart = false;
  late DisplayDirectServer _directServer;
  late DisplayTunnelServer _tunnelServer;
  String _tunnelApiUrl ='';
  static final List<RTCConnector> _channelRtcConnectors = <RTCConnector>[];
  static List<RTCConnector> get channelRtcConnectors => _channelRtcConnectors;
  static bool isModeratorMode = false;

  ChannelProvider(this.appConfig) {
    apiGateway = appConfig.settings.apiGateway;
    version = appConfig.appVersion;

    _checkNetWorkInfo().then((value) {
      host = value;
      if (displayCode.isEmpty || _tunnelApiUrl.isEmpty) {
        getDisplayCode(AppInstanceCreate().displayInstanceID).then((value) {
          if (value.isNotEmpty) {
            displayCode = encodeDisplayCode(DisplayCode(host!, int.parse(value)))!;
          } else {
            displayCode = encodeDisplayCode(DisplayCode(host!, 0))!;
          }
          startServer(AppInstanceCreate().displayInstanceID);
        });
      }
    });

    _checkConnectivity().then((value) {
      if (value) {
        if (displayCode.isEmpty || _tunnelApiUrl.isEmpty) {
          getDisplayCode(AppInstanceCreate().displayInstanceID).then((value) {
            if (value.isNotEmpty) {
              displayCode = encodeDisplayCode(DisplayCode(host!, int.parse(value)))!;
            } else {
              displayCode = encodeDisplayCode(DisplayCode(host!, 0))!;
            }
            startServer(AppInstanceCreate().displayInstanceID);
          });
        }
        connectNet = true;
      }
    });

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        connectNet = false;
        lanNetWork = false;
      } else {
        connectNet = true;
        _checkNetWorkInfo();
        if (displayCode.isEmpty) {
          getDisplayCode(AppInstanceCreate().displayInstanceID).then((value) {
            if (value.isNotEmpty) {
              displayCode = encodeDisplayCode(DisplayCode(host!, int.parse(value)))!;
            } else {
              displayCode = encodeDisplayCode(DisplayCode(host!, 0))!;
            }
            startServer(AppInstanceCreate().displayInstanceID);
          });
        }
      }
    });
  }

  void connectServer(BuildContext context) {
    MyApp.isInBackgroundMode = false;
    ConnectionTimer.getInstance().stopServerTimer();
    startServer(AppInstanceCreate().displayInstanceID);
  }

  void disconnectServer() {
    MyApp.isInBackgroundMode = true;
    if (!hasPresenterOccupied()) {
      ConnectionTimer.getInstance().startServerTimer(() {
        // onFinish
        stopServer();
      });
    }
  }

  void _setServerSide() {
    // create a direct server
    _directServer = DisplayDirectServer(
          (Channel channel) => _onNewChannel(channel, Mode.lan),
          (String token) => _checkOTP(token),
    );

    // create a tunnel server
    _tunnelServer = DisplayTunnelServer(
          (String url, headers) => WebSocketClientConnection(url, headers),
          (Channel channel) => _onNewChannel(channel, Mode.internet),
          (String token) => _checkOTP(token),
    );

    _tunnelServer.onTunnelConnected = () {
      print('Tunnel connected');
    };
    _tunnelServer.onTunnelConnecting = () {
      print('Tunnel is connecting');
    };
  }

  Future<void> startServer(String instanceId) async {
    if (isServerStart) return;
    _setServerSide();

    // start the tunnel server
    _tunnelServer.start(instanceId, _tunnelApiUrl);

    // start the direct server
    await _directServer.start(port);
    isServerStart = true;
  }

  void _onNewChannel(Channel channel, Mode mode) {
    if (_channelRtcConnectors.length >= 6) {
      var message = PresentRejectedMessage();
      message.reason = Reason(401, text:'block');
      channel.send(message);
      return;
    }

    // create a client object to handle this channel
    final client = mode == Mode.internet
        ? RTCConnector(_channelRtcConnectors.length, channel, Mode.internet, iceServersApiUrl: appConfig.settings.getIceServer)
        : RTCConnector(_channelRtcConnectors.length, channel, Mode.lan, host: '$host:$port');

    client.onConnect = ((){
      updateSplitScreen(); // TODO: Check
      updateModePanel(false);
    });

    client.onAddRemoteStream = ((stream) {
      // update state and quality
      updateSplitScreen();
      handleQualityUpdate(client);

      // hideTitleBar
      Home.showTitleBottomBar.value = false;

      if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
        StreamFunction.streamFunctionState.value = stateMenuOff;
      } else {
        if (isModeratorMode && navService.canPop()) {
          StreamFunction.streamFunctionState.value = stateMenuOff;
        } else {
          navService.popUntil('/home');
        }
      }
      notifyListeners();
    });

    client.onRefresh = (() {
      notifyListeners();
    });

    client.onShowMode = (({showMode}) {
      if (showMode != null) {
        updateModePanel(showMode);
      } else {
        updateModePanel(!isPresenting());
      }
    });

    client.onConflictWithMirror = (() {
      if (isModeratorMode) {
        // moderator
      } else if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
        // split screen
        splitScreenOff();
      } else {
        // basic
        basicStreamOff();
      }
    });

    client.onChannelDisconnect = (() async {
      // update SplitScreen's keySplitScreenCount
      // updateSplitScreen();
      // update UI
      if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
        bool presenting = false;
        for (RTCConnector controller in _channelRtcConnectors) {
          if (controller.presentationState != PresentationState.stopStreaming) {
            presenting |= true;
          }
        }
        if (!presenting) {
          Home.showTitleBottomBar.value = true;
          if (MirrorStateProvider.isMirroring) {
            StreamFunction.streamFunctionState.value = stateCast;
          } else {
            StreamFunction.streamFunctionState.value = stateStandby;
          }
          showMode = true;
        } else {
          Home.isSelectedList.value
              .fillRange(0, Home.isSelectedList.value.length, false);
          // Using below method to trigger value changed.
          // https://github.com/flutter/flutter/issues/29958
          Home.isSelectedList.value = List.from(Home.isSelectedList.value);
        }
      } else {
        Home.showTitleBottomBar.value = true;
        if (MirrorStateProvider.isMirroring) {
          StreamFunction.streamFunctionState.value = stateCast;
        } else {
          StreamFunction.streamFunctionState.value = stateStandby;
        }
        showMode = true;
      }
      if (MyApp.isInBackgroundMode) {
        disconnectServer();
      }

      await client.close(ChannelCloseCode.close);
      _channelRtcConnectors.remove(client);
      notifyListeners();
    });

    _channelRtcConnectors.add(client);
  }

  bool stopServer() {
    _tunnelServer.stop();
    _directServer.stop();
    return isServerStart = false;
  }

  bool _checkOTP(String otp) {
    return otpList.contains(otp);
  }

  // bool _checkPinCode(String pinCode) {
  //   return _pinCode == pinCode;
  // }

  Future<String> getDisplayCode(String instanceID) async {
    try {
      http.Response response = await http.put(
        Uri.parse(apiGateway),
        body: json.encode({
          'instanceId': instanceID,
          'version': version,
          'platform': "android",
        }),
      );

      if (response.statusCode >= HttpStatus.ok &&
          response.statusCode < HttpStatus.multiStatus) {
        Map json = jsonDecode(response.body);

        _tunnelApiUrl = json['tunnelApiUrl'] ?? '';
        return json['displayCode'];
      } else {
        return '';
      }
    } catch (e) {
      log('${e.toString()}');
      // http.get maybe no network connection.
      return '';
    }
  }

  // String getPinCode() {
  //   if (host == null) return '';
  //   return _pinCode = encodePinCode(PinCode(host!, passcode));
  // }

  void updateModePanel(bool show) {
    showMode = show;
    notifyListeners();
  }

  static void updateSplitScreen() {
    int connecting = 0, lastID = 0;
    for (int i = 0; i < channelRtcConnectors.length; i++) {
      if (channelRtcConnectors[i].presentationState !=
          PresentationState.stopStreaming) {
        connecting++;
        lastID = i;
      }
    }
    SplitScreen.mapSplitScreen.value[keySplitScreenCount] = connecting;
    SplitScreen.mapSplitScreen.value[keySplitScreenLastId] = lastID;
    // Using below method to trigger value changed.
    // https://github.com/flutter/flutter/issues/29958
    SplitScreen.mapSplitScreen.value =
        Map.from(SplitScreen.mapSplitScreen.value);
  }

  static void handleQualityUpdate(RTCConnector controller) {
    if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      if (SplitScreen.mapSplitScreen.value[keySplitScreenCount] < 2) {
        for (RTCConnector connector in channelRtcConnectors) {
          if (connector.presentationState == PresentationState.streaming) {
            connector.sendChangeQuality(true, true);
          }
        }
      } else {
        for (RTCConnector connector in _channelRtcConnectors) {
          if (connector.clientId != null) {
            connector.sendChangeQuality(false, true);
          }
        }
      }
    } else {
      controller.sendChangeQuality(true, true);
    }
  }

  bool occupyAvailableRTCConnector(int index) {
    for (int i = 0; i < _channelRtcConnectors.length; i++) {
      if (_channelRtcConnectors[i].presentationState.index <
          PresentationState.occupied.index) {
        _channelRtcConnectors[index].presentationState = PresentationState.occupied;
        return true;
      }
    }
    return false;
  }

  bool isPresenting({index}) {
    bool presenting = false;
    if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      if (index != null && _channelRtcConnectors.length > index) {
        if (_channelRtcConnectors[index].presentationState ==
            PresentationState.streaming) {
          presenting = true;
        }
      } else {
        for (RTCConnector controller in _channelRtcConnectors) {
          if (controller.presentationState == PresentationState.streaming) {
            presenting |= true;
          }
        }
      }
    } else {
      if (_channelRtcConnectors.isNotEmpty &&
          _channelRtcConnectors[0].presentationState ==
              PresentationState.streaming) {
        presenting = true;
      }
    }
    return presenting;
  }

  bool hasPresenterOccupied({index}) {
    bool presenting = false;
    if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      if (index != null && _channelRtcConnectors.length > index) {
        if (_channelRtcConnectors[index].presentationState !=
            PresentationState.stopStreaming) {
          presenting = true;
        }
      } else {
        for (RTCConnector controller in _channelRtcConnectors) {
          if (controller.presentationState != PresentationState.stopStreaming) {
            presenting |= true;
          }
        }
      }
    } else {
      if (_channelRtcConnectors.isNotEmpty &&
          _channelRtcConnectors[0].presentationState !=
              PresentationState.stopStreaming) {
        presenting = true;
      }
    }
    return presenting;
  }

  int getPresentingQuantity() {
    int quantity = 0;
    if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      for (RTCConnector controller in _channelRtcConnectors) {
        if (controller.presentationState == PresentationState.streaming) {
          quantity++;
        }
      }
    }
    return quantity;
  }

  bool isPresenterWaitForStream(String clientId) {
    for (RTCConnector controller in _channelRtcConnectors) {
      if (controller.clientId == clientId &&
          controller.presentationState == PresentationState.waitForStream) {
        return true;
      }
    }
    return false;
  }

  bool isPresenterStreaming(String clientId) {
    for (RTCConnector controller in _channelRtcConnectors) {
      if (controller.clientId == clientId &&
          controller.presentationState.index >= PresentationState.streaming.index) {
        return true;
      }
    }
    return false;
  }

  bool isPresenterNotStopStreaming(String clientId) {
    for (RTCConnector controller in _channelRtcConnectors) {
      if (controller.clientId == clientId &&
          controller.presentationState.index >=
              PresentationState.waitForStream.index) {
        // waitForStream and streaming
        return true;
      }
    }
    return false;
  }

  removeAllPresenters() async {
    RTCConnector? selectedController;
    List<RTCConnector> temp = List.from(_channelRtcConnectors);
    for (int i = temp.length - 1; i >= 0; i--) {
      selectedController = temp[i];
      if (selectedController.clientId != null) {
        try {
          await selectedController.disconnectPeerConnection(sendAnalytics: true);
          await selectedController.disconnectChannel();
          // need some delay to prevent exception:
          // 'package:flutter/src/rendering/object.dart': Failed assertion: line 2250 pos 12: '!_debugDisposed': is not true.
          await Future.delayed(const Duration(milliseconds: 300));
        } on PlatformException catch (e) {
          log(e.toString());
        }
      }
    }
  }

  /// a session ID is generated due to the act of presenting.
  removeOtherPresenters({bool keepInList = false}) async {
    RTCConnector? selectedController;
    List<RTCConnector> temp = List.from(_channelRtcConnectors);
    for (int i = temp.length - 1; i >= 0; i--) {
      selectedController = temp[i];
      if (selectedController.sessionId != null) {
        try {
          await selectedController.disconnectPeerConnection(sendAnalytics: true);
          if (!keepInList) {
            await selectedController.disconnectChannel();
          } else {
            selectedController.sendStopPresent();
          }
          // need some delay to prevent exception:
          // 'package:flutter/src/rendering/object.dart': Failed assertion: line 2250 pos 12: '!_debugDisposed': is not true.
          await Future.delayed(const Duration(milliseconds: 300));
        } on PlatformException catch (e) {
          log(e.toString());
        }
      }
    }
  }

  removePresenterBy(int index) async {
    RTCConnector? selectedController = _channelRtcConnectors[index];
    if (selectedController.sessionId != null) {
      try {
        await selectedController.disconnectPeerConnection(sendAnalytics: true);
        await selectedController.disconnectChannel();
        ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
      } on PlatformException catch (e) {
        log(e.toString());
      }
    }
  }

  Future<void> basicStreamOff() async {
    ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
    ConnectionTimer.getInstance().stopRemainingTimeTimer();
    await removeAllPresenters();
  }

  Future<void> splitScreenOff() async {
    ConnectionTimer.getInstance().stopRemainingTimeTimer();
    await removeAllPresenters();
  }

  updateAllQuality(int selection, bool hasSelected) {
    if (selection == -1) {
      _channelRtcConnectors[0].sendChangeQuality(true, true);
    } else {
      for (int i = 0; i < _channelRtcConnectors.length; i++) {
        if (_channelRtcConnectors[i].clientId != null) {
          _channelRtcConnectors[i].sendChangeQuality(
              (i == selection && hasSelected),
              (i == selection || !hasSelected));
        }
      }
    }
  }

  updateAllAudioEnableState(bool enable) {
    for (RTCConnector controller in _channelRtcConnectors) {
      controller.controlAudio(enable);
    }
  }

  updateAudioEnableStateByIndex(int index, bool enable) {
    _channelRtcConnectors[index].controlAudio(enable);
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
      if (interface.name.toLowerCase().contains("eth")) { // 'eth' 通常是 Ethernet
        String? ethernetIp = interface.addresses.isNotEmpty ? interface.addresses[0].address : null;
        if (ethernetIp != null) {
          lanNetWork = isPrivateIp(ethernetIp);
          host = ethernetIp;
          return host;
        }
        break;
      } else if (interface.name.toLowerCase().contains("wi") || interface.name.toLowerCase().contains("wlan")) { // 'wi' 或 'wlan' 通常是 WiFi
        String? wifiIp = interface.addresses.isNotEmpty ? interface.addresses[0].address : null;
        if (wifiIp != null) {
          lanNetWork = isPrivateIp(wifiIp);
          host = wifiIp;
          return host;
        }
        break;
      } else if (interface.name.toLowerCase().contains("rmnet") || interface.name.toLowerCase().contains("wwan")) {
        String? mobileIp = interface.addresses.isNotEmpty ? interface.addresses[0].address : null;
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
      if (secondPart != null && secondPart >= 16 && secondPart <= 31) return true;
    }
    return false;
  }
}