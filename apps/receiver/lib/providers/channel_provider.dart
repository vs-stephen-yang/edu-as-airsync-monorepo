import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:display_channel/display_channel.dart';
import 'package:flutter/cupertino.dart';

enum Mode {
  internet,
  lan
}

class ChannelProvider extends ChangeNotifier {
  ChannelProvider(BuildContext context) {
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

  String getPinCode() {
    if (host == null) return '';
    return encodePinCode(PinCode(host!, passcode));
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