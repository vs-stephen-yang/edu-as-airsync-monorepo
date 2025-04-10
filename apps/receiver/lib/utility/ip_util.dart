import 'dart:io';

typedef NetworkInterfaceFilter = bool Function(NetworkInterface);

Future<String?> findBestNetworkIp({
  required List<NetworkInterface> interfaces,
  required NetworkInterfaceFilter filter,
  required List<String> priorityOrder,
}) async {
  // Step 1: Filter interfaces
  final filteredInterfaces = interfaces.where(filter).toList();

  // Step 2: Build priority map from prefix to index
  final priorityMap = <String, int>{};
  for (int i = 0; i < priorityOrder.length; i++) {
    priorityMap[priorityOrder[i].toLowerCase()] = i;
  }

  // Step 3: Sort interfaces by priority, then by name
  filteredInterfaces.sort((a, b) {
    int priorityA = _getInterfacePriority(a.name, priorityMap);
    int priorityB = _getInterfacePriority(b.name, priorityMap);

    if (priorityA != priorityB) {
      return priorityA.compareTo(priorityB);
    }
    return a.name.compareTo(b.name);
  });

  // Step 4: Return the first valid IP address
  for (final iface in filteredInterfaces) {
    if (iface.addresses.isNotEmpty) {
      return iface.addresses.first.address;
    }
  }

  return null;
}

int _getInterfacePriority(String name, Map<String, int> priorityMap) {
  final lowered = name.toLowerCase();

  for (final entry in priorityMap.entries) {
    if (lowered.startsWith(entry.key)) {
      return entry.value;
    }
  }
  return priorityMap.length; // lowest priority if not matched
}

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
