import 'package:display_channel/src/client_connection.dart';
import 'package:display_channel/src/websocket_client_connection_config.dart';

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

  WebSocketClientConnection(
    String url,
    WebSocketClientConnectionConfig config,
  );

  @override
  void open() {}

  @override
  void close() {}

  @override
  void send(Map<String, dynamic> message) {}
}
