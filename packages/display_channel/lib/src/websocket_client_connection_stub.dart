import 'package:display_channel/src/client_connection.dart';

class WebSocketClientConnection implements ClientConnection {
  @override
  void Function()? onConnected;

  @override
  void Function(ConnectError error)? onConnectFailed;

  @override
  void Function()? onConnecting;

  @override
  void Function()? onDisconnected;

  @override
  void Function(Map<String, dynamic> data)? onMessage;

  static const defaultConnectionTimeout = Duration(seconds: 1);
  static const defaultMaxRetryDelay = Duration(seconds: 15);
  static const defaultMaxRetryAttempts = 8;

  Duration connectionTimeout;
  Duration maxRetryDelay;
  int maxRetryAttempts;

  void Function(String url, String message)? logger;

  WebSocketClientConnection(
    String url, {
    this.logger,
    this.connectionTimeout = defaultConnectionTimeout,
    this.maxRetryDelay = defaultMaxRetryDelay,
    this.maxRetryAttempts = defaultMaxRetryAttempts,
  });

  @override
  void open() {}

  @override
  Future<void> close() async {}

  @override
  void send(Map<String, dynamic> message) {}
}
