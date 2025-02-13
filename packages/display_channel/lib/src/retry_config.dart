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