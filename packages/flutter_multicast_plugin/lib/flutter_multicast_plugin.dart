
import 'flutter_multicast_plugin_platform_interface.dart';

class FlutterMulticastPlugin {
  Future<String?> getPlatformVersion() {
    return FlutterMulticastPluginPlatform.instance.getPlatformVersion();
  }
}
