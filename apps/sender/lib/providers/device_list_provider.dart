
import 'package:bonsoir/bonsoir.dart';
import 'package:display_cast_flutter/model/airsync_bonsoir_service.dart';
import 'package:display_cast_flutter/model/discover_services.dart';
import 'package:flutter/material.dart';

class DeviceListProvider with ChangeNotifier {

  DiscoverServices discoverServices = DiscoverServices();

  Future<void> startDiscovery() async {
    await discoverServices.startDiscovery((BonsoirDiscoveryEvent event) async {
      if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
        print('Service found : ${event.service?.toJson()}');
        await discoverServices.resolveService(event.service!);
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
        print('Service resolved : ${event.service?.toJson()}');
        if (event.service is ResolvedBonsoirService) {
          String? ip = await discoverServices.lookupIpAddress((event.service as ResolvedBonsoirService).host!);
          addDevice(AirSyncBonsoirService(
              uuid: event.service!.attributes['uuid'] ?? '',
              name: event.service!.name,
              type: event.service!.type,
              host: (event.service as ResolvedBonsoirService).host!,
              ip: ip ?? '',
              port: event.service!.port));
        }
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
        print('Service lost : ${event.service?.toJson()}');
        removeDevice(event.service!.attributes['uuid']);
      }
    });
  }

  Future<void> stopDiscovery() async {
    await discoverServices.stopDiscovery();
  }

  List<AirSyncBonsoirService> _devices = [];
  List<AirSyncBonsoirService> get devices => _devices;

  void addDevice(AirSyncBonsoirService device) {
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

}