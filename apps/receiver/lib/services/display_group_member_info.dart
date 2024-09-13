class DisplayGroupMemberInfo {
  final String host;
  final int port;

  final String displayCode;

  DisplayGroupMemberInfo({
    required this.host,
    this.port = 5100,
    required this.displayCode,
  });
}
