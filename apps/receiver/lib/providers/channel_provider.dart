import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/model/connect_timer.dart';
import 'package:display_flutter/model/rtc_connector.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/widgets/main_info.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

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
  String _pinCode = '';
  String get pinCode => _pinCode;
  set pinCode(String value) {
    _pinCode = value;
    notifyListeners();
  }
  // final List<String> _pinList =[];
  // List<String> get pinList => _pinList;
  // setPinList(String addOTP) {
  //   _pinList.add(addOTP);
  //   if (_pinList.length > 2) {
  //     _pinList.remove(_pinList.first);
  //   }
  // }

  String? host;
  int port = 5100;
  int passcode = 7;
  bool startServer = false;
  late DisplayDirectServer _directServer;
  late DisplayTunnelServer _tunnelServer;
  String _tunnelApiUrl ='';
  final _channelRtcConnectors = <RTCConnector>[]; // controller
  List<RTCConnector> get channelRtcConnectors => _channelRtcConnectors;

  ChannelProvider(BuildContext context, this.appConfig) {
    apiGateway = appConfig.settings.apiGateway;
    version = appConfig.appVersion;

    _setServerSide();
    _checkConnectivity().then((value) {
      if (value) {
        if (_currentMode == Mode.internet && (displayCode.isEmpty || _tunnelApiUrl.isEmpty)) {
          getDisplayCode(AppInstanceCreate().displayInstanceID).then((value) {
            if (value.isNotEmpty) {
              displayCode = value;
            }
            if (!startServer) {
              _startServer(AppInstanceCreate().displayInstanceID, _tunnelApiUrl, port);
              startServer = true;
            }
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
              displayCode = value;
            }
            if (!startServer) {
              _startServer(AppInstanceCreate().displayInstanceID, _tunnelApiUrl, port);
              startServer = true;
            }
          });
        }
      }
    });
  }

  void _setServerSide() {
    // print('zz setServerSide');
    // create a direct server
    _directServer = DisplayDirectServer(
          (Channel channel) => _onNewChannel(channel, Mode.lan),
          (String token) => _checkPinCode(token),
    );

    // create a tunnel server
    _tunnelServer = DisplayTunnelServer(
          (String url, headers) => WebSocketClientConnection(url, headers),
          (Channel channel) => _onNewChannel(channel, Mode.internet),
          (String token) => _checkOTP(token),
    );

    _tunnelServer.onTunnelConnected = () {
      print('zz Tunnel connected');
    };
    _tunnelServer.onTunnelConnecting = () {
      print('zz Tunnel is connecting');
    };
  }

  Future<void> _startServer(
      String instanceId,
      String tunnelServiceUrl,
      int localPort,
      ) async {
    // start the tunnel server
    _tunnelServer.start(instanceId, tunnelServiceUrl);

    // start the direct server
    await _directServer.start(localPort);
    // print('zz Listened on port ${_directServer.port} for direct channels');
  }

  void _onNewChannel(Channel channel, Mode mode) {

    // create a client object to handle this channel
    final client = mode == Mode.internet
        ? RTCConnector(_channelRtcConnectors.length, channel, Mode.internet, iceServersApiUrl: appConfig.settings.getIceServer)
        : RTCConnector(_channelRtcConnectors.length, channel, Mode.lan, host: '$host:$port');

    client.onConnect = ((){
      showMode = false;
      updateSplitScreen();
      notifyListeners();
    });
    client.onAddRemoteStream = ((stream) {
      // controlAudio(true); //TODO
      // print('zz onAddRemoteStream');

      // update state and quality
      updateSplitScreen();
      _handleQualityUpdate(client);

      // hideTitleBar
      Home.showTitleBottomBar.value = false;

      // TODO: handle SplitScreen & moderator
      // if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      //   StreamFunction.streamFunctionState.value = stateMenuOff;
      //   if (moderator != null && navService.canPop()) {
      //     PresentHelper.getInstance().refreshPresentList();
      //   }
      // } else {
      //   if (moderator != null && navService.canPop()) {
      //     StreamFunction.streamFunctionState.value = stateMenuOff;
      //     PresentHelper.getInstance().refreshPresentList();
      //   } else {
      //     navService.popUntil('/home');
      //   }
      // }
      notifyListeners();
    });
    client.onRefresh = (() {
      notifyListeners();
    });
    client.onDisconnect = (() async {
      // clear renderer
      showMode = true;
      updateSplitScreen();
      _handleQualityUpdate(client);
      if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
        bool presenting = false;
        for (RTCConnector controller in _channelRtcConnectors) {
          if (controller.presentationState != PresentationState.stopStreaming) {
            presenting |= true;
          }
        }
        if (!presenting) {
          // TODO: handle SplitScreen & moderator
          // if (moderator != null && navService.canPop()) {
          //   PresentHelper.getInstance().refreshPresentList();
          // }
          Home.showTitleBottomBar.value = true;
          if (MirrorStateProvider.isMirroring) {
            StreamFunction.streamFunctionState.value = stateCast;
          } else {
            StreamFunction.streamFunctionState.value = stateStandby;
          }
          MainInfo.showMainInfo.value = true;
        } else {
          Home.isSelectedList.value
              .fillRange(0, Home.isSelectedList.value.length, false);
          // Using below method to trigger value changed.
          // https://github.com/flutter/flutter/issues/29958
          Home.isSelectedList.value = List.from(Home.isSelectedList.value);
        }
      } else {
        // TODO: handle SplitScreen & moderator
        // if (moderator != null && navService.canPop()) {
        //   PresentHelper.getInstance().refreshPresentList();
        // }
        Home.showTitleBottomBar.value = true;
        if (MirrorStateProvider.isMirroring) {
          StreamFunction.streamFunctionState.value = stateCast;
        } else {
          StreamFunction.streamFunctionState.value = stateStandby;
        }
        MainInfo.showMainInfo.value = true;
      }
      // TODO:
      // if (MyApp.isInBackgroundMode) {
      //   MyApp.disconnectControlSocket();
      // }
      notifyListeners();
    });

    _channelRtcConnectors.add(client);
  }

  bool _checkOTP(String otp) {
    return otpList.contains(otp);
  }

  bool _checkPinCode(String pinCode) {
    return _pinCode == pinCode;
  }

  Future<String> getDisplayCode(String instanceID) async {
    print('zz getDisplayCode $instanceID $version');
    try {
      http.Response response = await http.put(
        Uri.parse(
            'https://api-us-east-1.gateway.dev.airsync.net/instances'),
        body: json.encode({
          'instanceId': instanceID,
          'version': version,
          'platform': "android",
        }),
      );

      print('zz ${response.body} ${response.headers} ${response.statusCode}');
      if (response.statusCode >= HttpStatus.ok &&
          response.statusCode < HttpStatus.multiStatus) {
        Map json = jsonDecode(response.body);

        _tunnelApiUrl = json['tunnelApiUrl'] ?? '';
        return json['displayCode'];
      } else {
        return '';
      }
    } catch (e) {
      log('zz ${e.toString()}');
      // http.get maybe no network connection.
      return '';
    }
  }

  String getPinCode() {
    if (host == null) return '';
    return _pinCode = encodePinCode(PinCode(host!, passcode));
  }

  void updateSplitScreen() {
    int connecting = 0, lastID = 0;
    for (int i = 0; i < _channelRtcConnectors.length; i++) {
      if (_channelRtcConnectors[i].presentationState !=
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

  void _handleQualityUpdate(RTCConnector controller) { //handleAddStreamState
    if (SplitScreen.mapSplitScreen.value[keySplitScreenEnable]) {
      if (SplitScreen.mapSplitScreen.value[keySplitScreenCount] < 2) {
        for (RTCConnector connector in _channelRtcConnectors) {
          if (connector.presentationState == PresentationState.streaming) {
            connector.changeQuality(true, true);
          }
        }
      } else {
        for (RTCConnector connector in _channelRtcConnectors) {
          if (connector.clientId != null) {
            connector.changeQuality(false, true);
          }
        }
      }
    } else {
      controller.changeQuality(true, true);
    }
  }

  bool occupyAvailableRTCConnector() {
    for (int i = 0; i < _channelRtcConnectors.length; i++) {
      if (_channelRtcConnectors[i].presentationState.index <
          PresentationState.occupied.index) {
        _channelRtcConnectors[i].presentationState = PresentationState.occupied;
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

  //TODO:
  // bool isPresenterWaitForStream(String presenterId) {
  //   for (RTCConnector controller in _channelRtcConnectors) {
  //     if (controller.presenterId == presenterId &&
  //         controller.presentationState == PresentationState.waitForStream) {
  //       return true;
  //     }
  //   }
  //   return false;
  // }

  // bool isPresenterStreaming(String presenterId) {
  //   for (RTCConnector controller in _channelRtcConnectors) {
  //     if (controller.presenterId == presenterId &&
  //         controller.presentationState == PresentationState.streaming) {
  //       return true;
  //     }
  //   }
  //   return false;
  // }

  // bool isPresenterNotStopStreaming(String presenterId) {
  //   for (RTCConnector controller in _channelRtcConnectors) {
  //     if (controller.presenterId == presenterId &&
  //         controller.presentationState.index >=
  //             PresentationState.waitForStream.index) {
  //       // waitForStream and streaming
  //       return true;
  //     }
  //   }
  //   return false;
  // }

  // unbindModerator(String apiGateway, Moderator moderator) async {
  //   try {
  //     http.Response response = await http.patch(
  //       Uri.parse('$apiGateway/presentation/displays/moderator/unbind'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8'
  //       },
  //       body: json.encode({'code': displayCode, 'moderator': moderator}),
  //     );
  //     printInDebug('unbind status: ${response.statusCode}', type: runtimeType);
  //     // every thing else
  //   } catch (e) {
  //     printInDebug('unbind failure: $e', type: runtimeType);
  //     // http.post maybe no network connection.
  //   }
  // }

  removeAllPresenters() async {
    RTCConnector? selectedController;
    List<RTCConnector> temp = List.from(_channelRtcConnectors);
    for (int i = temp.length - 1; i >= 0; i--) {
      selectedController = temp[i];
      if (selectedController.clientId != null) {
        try {
          await selectedController.disconnect(sendAnalytics: true);
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
    if (selectedController.clientId != null) {
      try {
        await selectedController.disconnect(sendAnalytics: true);
        ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
      } on PlatformException catch (e) {
        log(e.toString());
      }
    }
  }

  updateAllQuality(int selection, bool hasSelected) {
    if (selection == -1) {
      _channelRtcConnectors[0].changeQuality(true, true);
    } else {
      for (int i = 0; i < _channelRtcConnectors.length; i++) {
        if (_channelRtcConnectors[i].clientId != null) {
          _channelRtcConnectors[i].changeQuality(
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
          // print("zz Ethernet IP: $ethernetIp $lanNetWork");
          return host;
        } else {
          // print("zz Ethernet interface not found");
        }
        break;
      } else if (interface.name.toLowerCase().contains("wi") || interface.name.toLowerCase().contains("wlan")) { // 'wi' 或 'wlan' 通常是 WiFi
        String? wifiIp = interface.addresses.isNotEmpty ? interface.addresses[0].address : null;
        if (wifiIp != null) {
          lanNetWork = isPrivateIp(wifiIp);
          host = wifiIp;
          // print("zz WiFi IP: $wifiIp $lanNetWork");
          return host;
        } else {
          // print("zz WiFi interface not found");
        }
        break;
      } else if (interface.name.toLowerCase().contains("rmnet") || interface.name.toLowerCase().contains("wwan")) {
        String? mobileIp = interface.addresses.isNotEmpty ? interface.addresses[0].address : null;
        if (mobileIp != null) {
          lanNetWork = isPrivateIp(mobileIp);
          host = mobileIp;
          // print("zz Mobile Network IP: $mobileIp $lanNetWork");
          return host;
        } else {
          // print("zz Mobile network interface not found");
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