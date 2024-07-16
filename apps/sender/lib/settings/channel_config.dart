import 'package:display_channel/display_channel.dart';

const _initialRetryConfig = RetryConfig(
  maxRetryDelay: Duration(seconds: 1),
  maxRetryAttempts: 3,
);

const _reconnectRetryConfig = RetryConfig(
  maxRetryDelay: Duration(seconds: 1),
  // Reconnect indefinitely by setting a high number of retry attempts
  maxRetryAttempts: 60 * 60 * 10, // roughly 10 hours of retries
);

// Channel reconnect timeout during idle
const channelReconnectTimeoutInIdle = Duration(seconds: 10);

RetryConfig getChannelRetryConfig(bool isReconnect) {
  return isReconnect ? _reconnectRetryConfig : _initialRetryConfig;
}

const defaultTunnelConnectionTimeout = Duration(milliseconds: 500);
const defaultDirectConnectionTimeout = Duration(milliseconds: 200);
