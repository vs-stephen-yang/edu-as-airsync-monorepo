import 'package:display_channel/display_channel.dart';

const _initialRetryConfig = RetryConfig(
  maxRetryDelay: Duration(seconds: 3),
  maxRetryAttempts: 3,
);

const _reconnectRetryConfig = RetryConfig(
  maxRetryDelay: Duration(seconds: 1),
  maxRetryAttempts: 12,
);

RetryConfig getChannelRetryConfig(bool isReconnect) {
  return isReconnect ? _reconnectRetryConfig : _initialRetryConfig;
}
