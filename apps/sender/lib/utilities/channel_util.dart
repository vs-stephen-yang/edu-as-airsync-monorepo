enum ChannelReconnectState {
  idle,
  reconnecting,
  success,
  fail,
}

enum ChannelConnectError {
  instanceNotFound,
  rateLimitExceeded,
  networkError,
  invalidDisplayCode,
  invalidOtp,
  connectionModeUnsupported,
  unknownError,
  authenticationRequired,
}
