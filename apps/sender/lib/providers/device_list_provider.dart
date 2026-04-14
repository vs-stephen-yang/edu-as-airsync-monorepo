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

  Future<void> startDiscovery(String versionPostfix) async {
    await discoverServices.startDiscovery((BonsoirDiscoveryEvent event) {
      if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
        if (WebRTC.platformIsAndroid) {
          if (!checkDevice(event.service?.name ?? '')) {
            discoverServices.resolveService(event.service!);
          }
          return;
        }
        _addBonjourDeviceIfValid(event, versionPostfix);
      } else if (event.type ==
          BonsoirDiscoveryEventType.discoveryServiceResolved) {
        if (WebRTC.platformIsAndroid) {
          _addBonjourDeviceIfValid(event, versionPostfix);
        }
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
        if (event.service!.attributes.containsValue('AirSync')) {
          removeDevice(
            event.service!.attributes['uuid'],
            source: DeviceSource.bonjour,
          );
        }
      }
    });

    final udpDiscovery = _udpDiscovery ??= AirSyncUdpDiscovery(
      serviceType: discoverServices.type,
      directChannelPort: 5100,
      buildResponse: () => '',
      onDevice: (service) {
        addDevice(service);
      },
      onRemove: (service) => removeDevice(
        service.uuid,
        ip: service.ip,
        source: DeviceSource.udp,
      ),
    );
    udpDiscovery.setLogEnabled(true);
    await udpDiscovery.start();
    // stopDiscovery() can run during the await and clear _udpDiscovery,
    // which would make _udpDiscovery! throw on the next line.
    if (_udpDiscovery != udpDiscovery) return;
    unawaited(udpDiscovery.scanOnce());
  }

  bool checkDisplayCode(BonsoirDiscoveryEvent event) =>
      event.service!.attributes['dc'] != null &&
      event.service!.attributes['dc']!.isNotEmpty &&
      !event.service!.attributes['dc']!.contains(RegExp(r'[^0-9]'));

  void _addBonjourDeviceIfValid(
      BonsoirDiscoveryEvent event, String versionPostfix) {
    final version = event.service!.attributes['ver'];
    if (version == null) return;
    final serviceVersionPostfix = getVersionSuffix(version);
    if (versionPostfix != serviceVersionPostfix) return;
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
            source: DeviceSource.bonjour));
      }
    });
  }

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
    return _devices.any((element) =>
        element.uuid == uuid &&
        element.displayCode.isNotEmpty &&
        element.ip.isNotEmpty);
  }

  void addDevice(AirSyncBonsoirService device) {
    log.fine(
      'device add source=${device.source.value} uuid=${device.uuid} ip=${device.ip}',
    );
    bool updateExisting(DeviceSource source) {
      final existingIndex = _devices.indexWhere(
          (element) => element.source == source && element.uuid == device.uuid);
      if (existingIndex == -1) {
        return false;
      }
      _devices[existingIndex] = device;
      log.fine(
        'device updated source=${device.source.value} uuid=${device.uuid} ip=${device.ip}',
      );
      notifyListeners();
      return true;
    }

    bool sameUuidOrIp(AirSyncBonsoirService element) =>
        element.uuid == device.uuid || element.ip == device.ip;

    switch (device.source) {
      case DeviceSource.bonjour:
        final hasUdp = _devices.any((element) =>
            element.source == DeviceSource.udp && sameUuidOrIp(element));
        if (hasUdp) return;
        if (updateExisting(DeviceSource.bonjour)) return;
        _devices.removeWhere((element) =>
            element.source == DeviceSource.bonjour && sameUuidOrIp(element));
        break;
      case DeviceSource.udp:
        _devices.removeWhere((element) =>
            element.source == DeviceSource.bonjour && sameUuidOrIp(element));
        if (updateExisting(DeviceSource.udp)) return;
        _devices.removeWhere((element) =>
            element.source == DeviceSource.udp && sameUuidOrIp(element));
        break;
      case DeviceSource.unknown:
        _devices.removeWhere((element) => sameUuidOrIp(element));
        break;
    }
    _devices.add(device);
    notifyListeners();
  }

  void removeDevice(String? uuid, {String? ip, DeviceSource? source}) {
    log.fine(
      'device remove request source=${source?.value} uuid=$uuid ip=$ip',
    );
    bool matchesSource(AirSyncBonsoirService element) {
      switch (source) {
        case DeviceSource.bonjour:
        case DeviceSource.udp:
        case DeviceSource.unknown:
          return element.source == source;
        case null:
          return true;
      }
    }

    String? targetUuid = uuid;
    if (targetUuid == null && ip != null && ip.isNotEmpty) {
      final index = _devices.indexWhere((element) =>
          element.ip == ip && matchesSource(element));
      if (index == -1) {
        log.fine(
          'device remove skipped: no match for ip=$ip source=${source?.value}',
        );
        return;
      }
      targetUuid = _devices[index].uuid;
    }
    if (targetUuid == null) {
      log.fine('device remove skipped: uuid is null');
      return;
    }
    final index = _devices.indexWhere(
        (element) => element.uuid == targetUuid && matchesSource(element));
    if (index == -1) {
      log.fine(
        'device remove skipped: no match for uuid=$targetUuid source=${source?.value}',
      );
      return;
    }
    final removed = _devices.removeAt(index);
    log.fine(
      'device removed source=${source?.value} uuid=$targetUuid ip=${removed.ip}',
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
