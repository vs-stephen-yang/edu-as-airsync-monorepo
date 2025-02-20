import 'package:display_channel/display_channel.dart';

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

  WebTransportClientConnection(String url, Future<List<String>?> Function() fn,
      WebTransportClientConnectionConfig config);

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
  }
}
