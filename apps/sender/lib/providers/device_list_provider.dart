import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:display_cast_flutter/model/airsync_bonsoir_service.dart';
import 'package:display_cast_flutter/model/airsync_udp_discovery.dart';
import 'package:display_cast_flutter/model/discover_services.dart';
import 'package:display_cast_flutter/utilities/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class DeviceListProvider with ChangeNotifier {
  DiscoverServices discoverServices = DiscoverServices();
  AirSyncUdpDiscovery? _udpDiscovery;
  static const String _sourceBonjour = 'bonjour';
  static const String _sourceUdp = 'udp';
  static const bool _bonjourEnabled = true;

  void startDiscovery(String versionPostfix) {
    if (_bonjourEnabled) {
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
                      port: 5100,
                      source: _sourceBonjour));
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
                        port: 5100,
                        source: _sourceBonjour));
                  }
                });
              }
            }
          }
        } else if (event.type ==
            BonsoirDiscoveryEventType.discoveryServiceLost) {
          if (event.service!.attributes.containsValue('AirSync')) {
            removeDevice(
              event.service!.attributes['uuid'],
              source: _sourceBonjour,
            );
          }
        }
      });
    }

    _udpDiscovery ??= AirSyncUdpDiscovery(
      serviceType: discoverServices.type,
      directChannelPort: 5100,
      buildResponse: () => '',
      onDevice: (service) {
        addDevice(service);
      },
      onRemove: (service) => removeDevice(
        service.uuid,
        ip: service.ip,
        source: _sourceUdp,
      ),
    );
    _udpDiscovery!.setLogEnabled(true);
    unawaited(_udpDiscovery!.start());
    unawaited(_udpDiscovery!.scanOnce());
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
    log.fine(
      'device add source=${device.source} uuid=${device.uuid} ip=${device.ip}',
    );
    if (device.source == _sourceBonjour) {
      final hasUdp = _devices.any((element) =>
          element.source == _sourceUdp &&
          (element.uuid == device.uuid || element.ip == device.ip));
      if (hasUdp) return;
      final existingIndex = _devices.indexWhere((element) =>
          element.source == _sourceBonjour && element.uuid == device.uuid);
      if (existingIndex != -1) {
        _devices[existingIndex] = device;
        log.fine(
          'device updated source=${device.source} uuid=${device.uuid} ip=${device.ip}',
        );
        notifyListeners();
        return;
      }
      _devices.removeWhere((element) =>
          element.source == _sourceBonjour &&
          (element.uuid == device.uuid || element.ip == device.ip));
    } else if (device.source == _sourceUdp) {
      _devices.removeWhere((element) =>
          element.source == _sourceBonjour &&
          (element.uuid == device.uuid || element.ip == device.ip));
      final existingIndex = _devices.indexWhere((element) =>
          element.source == _sourceUdp && element.uuid == device.uuid);
      if (existingIndex != -1) {
        _devices[existingIndex] = device;
        log.fine(
          'device updated source=${device.source} uuid=${device.uuid} ip=${device.ip}',
        );
        notifyListeners();
        return;
      }
      _devices.removeWhere((element) =>
          element.source == _sourceUdp &&
          (element.uuid == device.uuid || element.ip == device.ip));
    } else {
      _devices.removeWhere((element) =>
          element.uuid == device.uuid || element.ip == device.ip);
    }
    _devices.add(device);
    notifyListeners();
  }

  void removeDevice(String? uuid, {String? ip, String? source}) {
    log.fine('device remove request source=$source uuid=$uuid ip=$ip');
    String? targetUuid = uuid;
    if (targetUuid == null && ip != null && ip.isNotEmpty) {
      final index = _devices.indexWhere((element) =>
          element.ip == ip && (source == null || element.source == source));
      if (index == -1) {
        log.fine('device remove skipped: no match for ip=$ip source=$source');
        return;
      }
      targetUuid = _devices[index].uuid;
    }
    if (targetUuid == null) {
      log.fine('device remove skipped: uuid is null');
      return;
    }
    final index = _devices.indexWhere((element) =>
        element.uuid == targetUuid &&
        (source == null || element.source == source));
    if (index == -1) {
      log.fine(
        'device remove skipped: no match for uuid=$targetUuid source=$source',
      );
      return;
    }
    final removed = _devices.removeAt(index);
    log.fine(
      'device removed source=$source uuid=$targetUuid ip=${removed.ip}',
    );
    log.fine('device list size=${_devices.length}');
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
