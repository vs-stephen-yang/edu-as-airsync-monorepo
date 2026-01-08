import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:display_cast_flutter/model/airsync_bonsoir_service.dart';
import 'package:display_cast_flutter/model/airsync_udp_discovery.dart';
import 'package:display_cast_flutter/model/discover_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class DeviceListProvider with ChangeNotifier {
  DiscoverServices discoverServices = DiscoverServices();
  AirSyncUdpDiscovery? _udpDiscovery;

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
          String serviceVersionPostfix =
              getVersionSuffix(event.service!.attributes['ver']!);
          if (versionPostfix == serviceVersionPostfix) {
            checkIP(event).then((value) {
              print('dc: ${event.service!.attributes['dc']}');
              if (value != null && checkDisplayCode(event)) {
                addDevice(AirSyncBonsoirService(
                    uuid: event.service!.name,
                    name: event.service!.attributes['fn'] ?? 'AirSync',
                    type: event.service!.type,
                    displayCode: event.service!.attributes['dc'] ?? '',
                    ip: value,
                    port: 5100));
              }
            });
          }
        }
      } else if (event.type ==
          BonsoirDiscoveryEventType.discoveryServiceResolved) {
        if (WebRTC.platformIsAndroid) {
          if (event.service!.attributes['ver'] != null) {
            String serviceVersionPostfix =
                getVersionSuffix(event.service!.attributes['ver']!);
            if (versionPostfix == serviceVersionPostfix) {
              checkIP(event).then((value) {
                if (value != null && checkDisplayCode(event)) {
                  print('dc: ${event.service!.attributes['dc']}');
                  addDevice(AirSyncBonsoirService(
                      uuid: event.service!.name,
                      name: event.service!.attributes['fn'] ?? 'AirSync',
                      type: event.service!.type,
                      displayCode: event.service!.attributes['dc'] ?? '',
                      ip: value,
                      port: 5100));
                }
              });
            }
          }
        }
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
        if (event.service!.attributes.containsValue('AirSync')) {
          removeDevice(event.service!.attributes['uuid']);
        }
      }
    });

    _udpDiscovery ??= AirSyncUdpDiscovery(
      serviceType: discoverServices.type,
      directChannelPort: 5100,
      buildResponse: () => '',
      onDevice: (service) {
        if (!_isDisplayCodeValid(service.displayCode)) return;
        addDevice(service);
      },
      onRemove: (service) => removeDevice(service.uuid),
    );
    unawaited(_udpDiscovery!.start());
  }

  bool checkDisplayCode(BonsoirDiscoveryEvent event) =>
      event.service!.attributes['dc'] != null &&
      event.service!.attributes['dc']!.isNotEmpty &&
      !event.service!.attributes['dc']!.contains(RegExp(r'[^0-9]'));

  Future<String?> checkIP(BonsoirDiscoveryEvent event) async {
    if (event.service!.attributes['ip'] != null &&
        event.service!.attributes['ip']!.isNotEmpty) {
      return event.service!.attributes['ip'];
    }

    if (event.service is ResolvedBonsoirService) {
      String? ip = await discoverServices
          .lookupIpAddress((event.service as ResolvedBonsoirService).host!);
      return ip;
    }

    return null;
  }

  Future<void> stopDiscovery() async {
    await discoverServices.stopDiscovery();
    _udpDiscovery?.stop();
    _udpDiscovery = null;
  }

  final List<AirSyncBonsoirService> _devices = [];

  List<AirSyncBonsoirService> get devices => _devices;

  bool checkDevice(String uuid) {
    bool result = false;
    for (var element in _devices) {
      if (element.uuid == uuid &&
          element.displayCode.isNotEmpty &&
          element.ip.isNotEmpty) {
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
    if (uuid == null) return;
    final index = _devices.indexWhere((element) => element.uuid == uuid);
    if (index == -1) return;
    _devices.removeAt(index);
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

  bool _isDisplayCodeValid(String displayCode) =>
      displayCode.isNotEmpty && !displayCode.contains(RegExp(r'[^0-9]'));
}
