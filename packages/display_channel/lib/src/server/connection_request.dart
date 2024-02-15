class ConnectionRequest {
  String clientId;
  String token;
  String displayCode;
  String? clientIpAddress;

  ConnectionRequest(
    this.clientId,
    this.token,
    this.displayCode,
    this.clientIpAddress,
  );
}
