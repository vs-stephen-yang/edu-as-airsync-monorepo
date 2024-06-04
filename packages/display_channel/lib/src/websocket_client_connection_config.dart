class WebSocketClientConnectionConfig {
  void Function(String url, String message)? logger;

  static const defaultPingInterval = Duration(seconds: 1);
  static const defaultConnectionTimeout = Duration(seconds: 1);
  static const defaultMaxRetryDelay = Duration(seconds: 15);
  static const defaultMaxRetryAttempts = 8;

  Duration pingInterval;
  Duration connectionTimeout;
  Duration maxRetryDelay;
  int maxRetryAttempts;
  bool allowSelfSignedCertificates;

  WebSocketClientConnectionConfig({
    this.pingInterval = defaultPingInterval,
    this.connectionTimeout = defaultConnectionTimeout,
    this.maxRetryDelay = defaultMaxRetryDelay,
    this.maxRetryAttempts = defaultMaxRetryAttempts,
    this.allowSelfSignedCertificates = false,
    this.logger,
  });
}
