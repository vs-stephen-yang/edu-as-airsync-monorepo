class ConnectionRequest {
  String clientId;
  String? token;
  String displayCode;
  String? clientIpAddress;
  Map<String, String>? queryParameters;

  ConnectionRequest(
    this.clientId,
    this.token,
    this.displayCode,
    this.clientIpAddress, {
    this.queryParameters,
  });
}
