import 'dart:async';
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:synchronized/synchronized.dart';

class DiscoverServices {
  DiscoverServices();

  String type = '_vs-airsync._tcp';
  BonsoirDiscovery? discovery;

  final lock = Lock(); // uses the “synchronized” package

  Future<void> startDiscovery(
      Function(BonsoirDiscoveryEvent event)? onEventOccurred) async {
    if (discovery != null) return;
    // start the discovery
    discovery = BonsoirDiscovery(printLogs: true, type: type);
    unawaited(discovery?.ready.then((value) {
      discovery?.eventStream!.listen(onEventOccurred);
      discovery?.start();
    }));
  }

  Future<void> stopDiscovery() async {
    await discovery?.stop();
    discovery = null;
  }

  Future<void> resolveService(BonsoirService service) async {
    unawaited(lock.synchronized(
        () async => await service.resolve(discovery!.serviceResolver)));
  }

  Future<String?> lookupIpAddress(String hostName) async {
    try {
      List<InternetAddress> addresses = await InternetAddress.lookup(hostName);
      if (addresses.isNotEmpty) {
        String? ipv4Address;
        for (InternetAddress address in addresses) {
          if (address.type == InternetAddressType.IPv4) {
            ipv4Address = address.address;
            break;
          }
        }
        return ipv4Address;
      }
      return null;
    } on SocketException {
      return null;
    }
  }
}
