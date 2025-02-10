import 'flutter_webtransport_config.dart';
import 'flutter_webtransport_listener.dart';
import 'flutter_webtransport_platform_interface.dart';

class FlutterWebtransport {
  void registerListener(FlutterWebtransportListener listener) {
    return FlutterWebtransportPlatform.instance.registerListener(listener);
  }

  Future<void> startWebtransportServer(FlutterWebtransportConfig config) {
    return FlutterWebtransportPlatform.instance.startWebTransportServer(config);
  }

  Future<void> stopServer() {
    return FlutterWebtransportPlatform.instance.stopServer();
  }

  Future<void> sendMessage(String clientId, String message) {
    return FlutterWebtransportPlatform.instance.sendMessage(clientId, message);
  }

  Future<void> updateCertificate(FlutterWebtransportConfig config) {
    return FlutterWebtransportPlatform.instance.updateCertificate(config);
  }
}
