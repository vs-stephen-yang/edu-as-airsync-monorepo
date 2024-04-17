
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';

class DiscoverServices {

  DiscoverServices();

  String type = '_vs-airsync._tcp';
  BonsoirDiscovery? discovery;

  Future<void> startDiscovery(Function(BonsoirDiscoveryEvent event)? onEventOccurred) async {
    print('zz ${discovery != null}');
    if (discovery != null) return;
    // start the discovery
    discovery = BonsoirDiscovery(type: type);
    await discovery?.ready;

    discovery?.eventStream!.listen(onEventOccurred);

    await discovery?.start();
  }

  Future<void> stopDiscovery() async {
    await discovery?.stop();
    discovery = null;
  }

  Future<void> resolveService(BonsoirService service) async {
    await service.resolve(discovery!.serviceResolver);
    // await lookupIpAddress(service.name);
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
        print('IPv4： $ipv4Address');
        return ipv4Address;
      }
      return null;
    } on SocketException catch (e) {
      print('SocketException： $e');
      return null;
    }
  }

}