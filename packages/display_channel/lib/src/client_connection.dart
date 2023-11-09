abstract class ClientConnection {
  void Function()? onConnected;
  void Function()? onConnecting;

  void Function(Map<String, dynamic> message)? onMessage;

  void open();
  void close();

  void send(Map<String, dynamic> message);
}

typedef CreateWebsocketClientConnection = ClientConnection Function(
    String url, Map<String, String> headers);
