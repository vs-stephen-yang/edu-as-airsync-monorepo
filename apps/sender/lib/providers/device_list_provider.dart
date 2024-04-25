
import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:display_cast_flutter/model/airsync_bonsoir_service.dart';
import 'package:display_cast_flutter/model/discover_services.dart';
import 'package:display_channel/display_channel.dart';
import 'package:flutter/material.dart';

class DeviceListProvider with ChangeNotifier {

  DiscoverServices discoverServices = DiscoverServices();

   void startDiscovery(String versionPostfix) {

    discoverServices.startDiscovery((BonsoirDiscoveryEvent event) {
      if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
        if (event.service!.attributes['ver'] != null) {
          String serviceVersionPostfix = getVersionSuffix(event.service!.attributes['ver']!);
          if (versionPostfix == serviceVersionPostfix) {
            if (event.service!.attributes['displayCode'] != null && event.service!.attributes['displayCode']!.isNotEmpty) {
              String dc = event.service!.attributes['displayCode']!;
              DisplayCode displayCode = decodeDisplayCode(dc);
              addDevice(AirSyncBonsoirService(
                  uuid: event.service!.attributes['uuid'] ?? '',
                  name: event.service!.attributes['fn'] ?? 'AirSync',
                  type: event.service!.type,
                  host: dc,
                  ip: displayCode.ipAddress ?? '',
                  port: 5100));
            }
          }
        }
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {

      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
        if (event.service!.attributes.containsValue('AirSync')) {
          removeDevice(event.service!.attributes['uuid']);
        }
      }
    });
  }

  Future<void> stopDiscovery() async {
    await discoverServices.stopDiscovery();
  }

  List<AirSyncBonsoirService> _devices = [];
  List<AirSyncBonsoirService> get devices => _devices;

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