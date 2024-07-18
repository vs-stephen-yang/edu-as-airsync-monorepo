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

String createRemoteIp(String localIpAddress, int instanceGroupId) {
  List<String> parts = localIpAddress.split('.');

  int octet1 = (instanceGroupId >> 16) & 0xFF;
  int octet2 = (instanceGroupId >> 8) & 0xFF;
  int octet3 = instanceGroupId & 0xFF;

  return '${parts[0]}.$octet1.$octet2.$octet3';
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
