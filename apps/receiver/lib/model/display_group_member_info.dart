class DisplayGroupMemberInfo {
  final String host;
  final int port;
  final String version;

  final String displayCode;

  DisplayGroupMemberInfo({
    required this.version,
    required this.host,
    this.port = 5100,
    required this.displayCode,
  });
}
