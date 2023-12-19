abstract class ClientConnection {
  void Function()? onConnecting;
  void Function()? onConnectFailed;
  void Function()? onConnected;
  void Function()? onDisconnected;

  void Function(Map<String, dynamic> message)? onMessage;

  void open();
  Future<void> close();

  void send(Map<String, dynamic> message);
}

typedef CreateWebsocketClientConnection = ClientConnection Function(
    String url, Map<String, String> headers);
