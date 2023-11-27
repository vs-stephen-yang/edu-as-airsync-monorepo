import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:display_channel/display_channel.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

enum Mode {
  internet,
  lan
}

class ChannelProvider extends ChangeNotifier {
  String apiGateway, version;

  ChannelProvider(BuildContext context, this.apiGateway, this.version) {
    print('zz ChannelProvider con $connectNet $lanNetWork');
    _checkConnectivity().then((value) {
      print('zz ChannelProvider _checkConnectivity $value');
      if (value) {
        if (_currentMode == Mode.internet && (displayCode.isEmpty || _tunnelApiUrl.isEmpty)) {
          getDisplayCode(AppInstanceCreate().displayInstanceID).then((value) {
            if (value.isNotEmpty) {
              displayCode = _displayCode;
            }
          });
        }
        connectNet = true;
      }
    });
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        print('zz net broken');
        connectNet = false;
        lanNetWork = false;
      } else {
        print('zz ${result.name} connect ');
        connectNet = true;
        _checkNetWorkInfo();
      }
    });
  }

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

  String? host;
  int passcode = 7;
  static bool isNewUI = true;

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
  List<String> _otpList =[];
  List<String> get otpList => _otpList;
  setOtpList(String addOTP) {
    _otpList.add(addOTP);
    if (_otpList.length > 2) {
      _otpList.remove(_otpList.first);
    }
  }

  late DisplayDirectServer _directServer;
  late DisplayTunnelServer _tunnelServer;
  String _tunnelApiUrl ='';

  bool _checkOTP(String otp) {
    return otpList.contains(otp);
  }

  Future<String> getDisplayCode(String instanceID) async {
    print('zz getDisplayCode $instanceID $version');
    try {
      http.Response response = await http.put(
        Uri.parse(
            'https://62xlwp3dq8.execute-api.us-east-1.amazonaws.com/instances'),
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

        _displayCode = json['displayCode'] ?? '';
        _tunnelApiUrl = json['tunnelApiUrl'] ?? '';
        print('zz $json');
        return _displayCode;
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
    return encodePinCode(PinCode(host!, passcode));
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
          print("Ethernet IP: $ethernetIp $lanNetWork");
          return host;
        } else {
          print("Ethernet interface not found");
        }
        break;
      } else if (interface.name.toLowerCase().contains("wi") || interface.name.toLowerCase().contains("wlan")) { // 'wi' 或 'wlan' 通常是 WiFi
        String? wifiIp = interface.addresses.isNotEmpty ? interface.addresses[0].address : null;
        if (wifiIp != null) {
          lanNetWork = isPrivateIp(wifiIp);
          host = wifiIp;
          print("WiFi IP: $wifiIp $lanNetWork");
          return host;
        } else {
          print("WiFi interface not found");
        }
        break;
      } else if (interface.name.toLowerCase().contains("rmnet") || interface.name.toLowerCase().contains("wwan")) {
        String? mobileIp = interface.addresses.isNotEmpty ? interface.addresses[0].address : null;
        if (mobileIp != null) {
          lanNetWork = isPrivateIp(mobileIp);
          host = mobileIp;
          print("Mobile Network IP: $mobileIp $lanNetWork");
          return host;
        } else {
          print("Mobile network interface not found");
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