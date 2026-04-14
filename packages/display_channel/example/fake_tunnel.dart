import 'package:display_channel/src/util/fake_tunnel_service.dart';
import 'dart:io';
import 'package:display_channel/src/util/log.dart';

void main() async {
  const instanceIndex = 100043;

  final tunnelService = FakeTunnelService(
    instanceIndex: instanceIndex.toString(),
  );

  const httpPort = 5000;
  final httpServer = await HttpServer.bind(
    InternetAddress.anyIPv4,
    httpPort,
  );

  httpServer.listen((request) async {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      await tunnelService.onHttpRequest(request);
    }
  });

  log().info('Listened on port $httpPort');
}
