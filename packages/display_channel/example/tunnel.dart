import 'package:display_channel/src/util/http_websocket_server.dart';
import 'package:display_channel/src/util/fake_tunnel_service.dart';
import 'dart:io';

void main() async {
  final tunnelService = FakeTunnelService();

  final httpServer = HttpWebSocketServer((WebSocket ws, HttpRequest req) {
    tunnelService.onWsConnection(ws, req);
  });

  await httpServer.start(5000);

  print('Listened on port ${httpServer.port}');
}
