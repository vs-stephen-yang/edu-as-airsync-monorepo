enum ConnectErrorType {
  websocket,
  socket,
  http,
  webTransport,
}

enum ConnectionState {
  connecting,
  connected,
  disconnecting,
  disconnected,
  closed
}

class ConnectError {
  ConnectErrorType error;
  String message;

  ConnectError(this.error, this.message);
}

abstract class ClientConnection {
  void Function()? onConnecting;
  void Function(ConnectError error)? onConnectFailed;
  void Function()? onConnected;
  void Function()? onDisconnected;

  void Function(Map<String, dynamic> message)? onMessage;

  void open();
  void close();

  void send(Map<String, dynamic> message);
}

typedef CreateClientConnection = ClientConnection Function(
  String url,
  bool isReconnect,
);