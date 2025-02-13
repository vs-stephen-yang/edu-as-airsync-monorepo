class RetryConfig {
  final int maxRetryAttempts;
  final Duration maxRetryDelay;

  static const defaultMaxRetryDelay = Duration(seconds: 15);
  static const defaultMaxRetryAttempts = 8;

  const RetryConfig({
    this.maxRetryAttempts = defaultMaxRetryAttempts,
    this.maxRetryDelay = defaultMaxRetryDelay,
  });
}

class WebTransportClientConnectionConfig {
  final void Function(String url, String message)? logger;

  static const defaultPingInterval = Duration(seconds: 2);
  static const defaultConnectionTimeout = Duration(seconds: 1);
  static const defaultRetryConfig = RetryConfig();

  final Duration pingInterval;
  final Duration connectionTimeout;

  final RetryConfig retry;

  final bool allowSelfSignedCertificates;

  WebTransportClientConnectionConfig({
    this.pingInterval = defaultPingInterval,
    this.connectionTimeout = defaultConnectionTimeout,
    this.retry = defaultRetryConfig,
    this.allowSelfSignedCertificates = false,
    this.logger,
  });
}
