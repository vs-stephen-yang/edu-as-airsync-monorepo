import 'dart:io';
import 'dart:convert';
import 'package:display_channel/src/server/connection.dart';

class DirectConnection implements Connection {
  @override
  void Function(Connection connection)? onClosed;

  @override
  void Function(Connection connection, Map<String, dynamic> message)? onMessage;

  late WebSocket _socket;

  DirectConnection(WebSocket socket) {
    _socket = socket;

    _socket.listen((dynamic data) {
      // receive data
      final message = jsonDecode(data);
      onMessage?.call(this, message);
    }, onDone: () {
      // websocket connection closed
      onClosed?.call(this);
    }, onError: (error) {
      // websocket connection error
      onClosed?.call(this);
    }, cancelOnError: true);
  }

  @override
  void send(Map<String, dynamic> message) {
    final data = jsonEncode(message);
    _socket.add(data);
  }

  @override
  void close() {
    _socket.close();
  }
}
