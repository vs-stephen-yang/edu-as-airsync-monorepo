
import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:display_cast_flutter/model/airsync_bonsoir_service.dart';
import 'package:display_cast_flutter/model/discover_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class DeviceListProvider with ChangeNotifier {

  DiscoverServices discoverServices = DiscoverServices();

   void startDiscovery(String versionPostfix) {

    discoverServices.startDiscovery((BonsoirDiscoveryEvent event) {
      if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
        if (WebRTC.platformIsAndroid) {
          if (!checkDevice(event.service?.name ?? '')) {
            discoverServices.resolveService(event.service!);
          }
          return;
        }
        if (event.service!.attributes['ver'] != null) {
          String serviceVersionPostfix = getVersionSuffix(event.service!.attributes['ver']!);
          if (versionPostfix == serviceVersionPostfix) {
            if (checkDisplayCode(event) && checkIP(event)) {
              addDevice(AirSyncBonsoirService(
                  uuid: event.service!.name ?? '',
                  name: event.service!.attributes['fn'] ?? 'AirSync',
                  type: event.service!.type,
                  displayCode: event.service!.attributes['displayCode'] ?? '',
                  ip: event.service!.attributes['ip'] ?? '',
                  port: 5100));
            }
          }
        }
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
        if (WebRTC.platformIsAndroid) {
          if (event.service!.attributes['ver'] != null) {
            String serviceVersionPostfix = getVersionSuffix(event.service!.attributes['ver']!);
            if (versionPostfix == serviceVersionPostfix) {
              if (checkDisplayCode(event) && checkIP(event)) {
                addDevice(AirSyncBonsoirService(
                    uuid: event.service!.name ?? '',
                    name: event.service!.attributes['fn'] ?? 'AirSync',
                    type: event.service!.type,
                    displayCode: event.service!.attributes['displayCode'] ?? '',
                    ip: event.service!.attributes['ip'] ?? '',
                    port: 5100));
              }
            }
          }
        }
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
        if (event.service!.attributes.containsValue('AirSync')) {
          removeDevice(event.service!.attributes['uuid']);
        }
      }
    });
  }

  bool checkDisplayCode(BonsoirDiscoveryEvent event) =>
      event.service!.attributes['displayCode'] != null &&
      event.service!.attributes['displayCode']!.isNotEmpty;

  bool checkIP(BonsoirDiscoveryEvent event) =>
      event.service!.attributes['ip'] != null &&
          event.service!.attributes['ip']!.isNotEmpty;

  Future<void> stopDiscovery() async {
    await discoverServices.stopDiscovery();
  }

  List<AirSyncBonsoirService> _devices = [];
  List<AirSyncBonsoirService> get devices => _devices;

  bool checkDevice(String uuid) {
    bool result = false;
    for (var element in _devices) {
      if (element.uuid == uuid && element.displayCode.isNotEmpty && element.ip.isNotEmpty) {
        result = true;
      }
    }
    return result;
  }

  void addDevice(AirSyncBonsoirService device) {
    _devices.removeWhere((element) => element.ip == device.ip);
    _devices.add(device);
    notifyListeners();
  }

  void removeDevice(String? uuid) {
    _devices.remove(_devices.firstWhere((element) => element.uuid == uuid));
    notifyListeners();
  }

  void clearDevices() {
    _devices.clear();
  }

  String getVersionSuffix(String version) {
    int dashIndex = version.lastIndexOf("-");
    if (dashIndex != -1) {
      return version.substring(dashIndex);
    } else {
      return "";
    }
  }

}