import "package:display_channel/src/retry_config.dart";

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
