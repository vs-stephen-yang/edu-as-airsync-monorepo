
import 'client_connection.dart';

class WebTransportClientConnection implements ClientConnection {
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

  WebTransportClientConnection(){}


  @override
  void close() {
    // TODO: implement close
  }

  @override
  void open() {
    // TODO: implement open
  }

  @override
  void send(Map<String, dynamic> message) {
    // TODO: implement send
  }}