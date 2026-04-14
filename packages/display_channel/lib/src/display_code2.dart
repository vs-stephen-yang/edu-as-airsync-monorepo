class DisplayCode {
  int instanceGroupId;
  int? instanceIndex;

  DisplayCode({
    required this.instanceGroupId,
    this.instanceIndex,
  });

  bool hasTunnelSupport() {
    return instanceIndex != null;
  }
}

// extract instance group Id from an IP address
int getInstanceGroupIdFromIp(String ipAddress) {
  List<String> parts = ipAddress.split('.');
  int instanceGroupId = 0;

  for (int i = 1; i < 4; i++) {
    instanceGroupId = (instanceGroupId << 8) + int.parse(parts[i]);
  }

  return instanceGroupId;
}

List<String> createRemoteIpCandidates(
  DisplayCode displayCode,
  List<String> localIpAddresses,
) {
  // Extract first octets from local IPs
  final firstOctets = localIpAddresses
      .map(
        (ip) => ip.split('.')[0],
      )
      .toSet();

  // Add standard private network octets
  const firstOctetsOfPrivate = ['172', '10', '192'];

  final allFirstOctets = [
    ...firstOctets,
    ...firstOctetsOfPrivate,
  ];

  // Create remote IPs for each first octet
  final remoteIps = allFirstOctets
      .map((firstOctet) =>
          _deriveRemoteIp(firstOctet, displayCode.instanceGroupId))
      .toSet()
      .toList();

  return remoteIps;
}

String _deriveRemoteIp(String firstOctet, int instanceGroupId) {
  int octet1 = (instanceGroupId >> 16) & 0xFF;
  int octet2 = (instanceGroupId >> 8) & 0xFF;
  int octet3 = instanceGroupId & 0xFF;

  return '$firstOctet.$octet1.$octet2.$octet3';
}

final maxInstanceGroups = BigInt.from(256 * 256 * 256);

const minDisplayCodeLength = 8;

String encodeDisplayCode(DisplayCode code) {
  // 16777216*instanceGroupId + instanceIndex
  final value = maxInstanceGroups * BigInt.from(code.instanceIndex ?? 0) +
      BigInt.from(code.instanceGroupId);

  return value.toString().padLeft(minDisplayCodeLength, '0');
}

DisplayCode decodeDisplayCode(String code) {
  final value = BigInt.parse(code);

  final instanceIndex = (value ~/ maxInstanceGroups).toInt();
  final instanceGroupId = (value % maxInstanceGroups).toInt();

  return DisplayCode(
    instanceGroupId: instanceGroupId.toInt(),
    instanceIndex: instanceIndex > 0 ? instanceIndex : null,
  );
}
