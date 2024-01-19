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

  final String _url;
  int maxRetryAttempts;

  void Function(String url, String message)? logger;

  WebSocketClientConnection(
    this._url, {
    this.logger,
    this.maxRetryAttempts = 1,
  });

  @override
  void open() {}

  @override
  Future<void> close() async {}

  @override
  void send(Map<String, dynamic> message) {}
}
