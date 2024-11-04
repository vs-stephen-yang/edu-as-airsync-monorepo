import 'dart:io';

bool isPrivateIp(String ipAddress) {
  var address = InternetAddress(ipAddress);

  if (address.type == InternetAddressType.IPv4) {
    List<int> bytes = address.rawAddress;

    return (bytes[0] == 10) ||
        (bytes[0] == 172 && bytes[1] >= 16 && bytes[1] <= 31) ||
        (bytes[0] == 192 && bytes[1] == 168);
  } else if (address.type == InternetAddressType.IPv6) {
    // Add logic for IPv6 addresses if needed
    return false;
  } else {
    // Unknown IP address type
    return false;
  }
}

Future<String?> getPreferredNetworkIpAddress() async {
  List<NetworkInterface> interfaces =
      await NetworkInterface.list(type: InternetAddressType.IPv4);

  List<NetworkInterface> ethernetInterfaces = [];
  List<NetworkInterface> wifiInterfaces = [];
  List<NetworkInterface> mobileInterfaces = [];
  for (NetworkInterface interface in interfaces) {
    if (interface.name.toLowerCase().startsWith("eth")) {
      ethernetInterfaces.add(interface);
    } else if (interface.name.toLowerCase().startsWith("wi") ||
        interface.name.toLowerCase().startsWith("wlan")) {
      wifiInterfaces.add(interface);
    } else if (interface.name.toLowerCase().startsWith("rmnet") ||
        interface.name.toLowerCase().startsWith("wwan")) {
      mobileInterfaces.add(interface);
    }
  }

  // by order
  ethernetInterfaces.sort((a, b) => a.name.compareTo(b.name));
  wifiInterfaces.sort((a, b) => a.name.compareTo(b.name));
  mobileInterfaces.sort((a, b) => a.name.compareTo(b.name));

  if (ethernetInterfaces.isNotEmpty) {
    for (NetworkInterface interface in ethernetInterfaces) {
      String? ethernetIp = interface.addresses.isNotEmpty
          ? interface.addresses[0].address
          : null;
      if (ethernetIp != null) {
        return ethernetIp;
      }
      break;
    }
  }

  if (wifiInterfaces.isNotEmpty) {
    for (NetworkInterface interface in wifiInterfaces) {
      String? wifiIp = interface.addresses.isNotEmpty
          ? interface.addresses[0].address
          : null;
      if (wifiIp != null) {
        return wifiIp;
      }
      break;
    }
  }

  if (mobileInterfaces.isNotEmpty) {
    for (NetworkInterface interface in mobileInterfaces) {
      String? mobileIp = interface.addresses.isNotEmpty
          ? interface.addresses[0].address
          : null;
      if (mobileIp != null) {
        return mobileIp;
      }
      break;
    }
  }
  return null;
}
