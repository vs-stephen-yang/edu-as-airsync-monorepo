abstract class Connection {
  void Function(Connection connection, Map<String, dynamic> message)? onMessage;
  void Function(Connection connection)? onClosed;

  Map<String, String>? get queryParameters;

  void send(Map<String, dynamic> message);
  void close();
}
