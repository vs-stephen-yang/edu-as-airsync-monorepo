import 'package:display_channel/src/util/fake_tunnel_service.dart';
import 'dart:io';

void main() async {
  const displayCode = '100018';

  final tunnelService = FakeTunnelService(displayCode);

  const httpPort = 5000;
  final httpServer = await HttpServer.bind(
    InternetAddress.anyIPv4,
    httpPort,
  );

  httpServer.listen((request) async {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      tunnelService.onHttpRequest(request);
    }
  });

  print('Listened on port $httpPort');
}
