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
