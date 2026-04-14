import 'flutter_ion_sfu_configuration.dart';
import 'flutter_ion_sfu_platform_interface.dart';
import 'flutter_ion_sfu_listener.dart';

class FlutterIonSfu {
  void registerListener(FlutterIonSfuListener listener) {
    return FlutterIonSfuPlatform.instance.registerListener(listener);
  }

  Future<void> initialize() {
    return FlutterIonSfuPlatform.instance.initialize();
  }

  Future<void> start(
    FlutterIonSfuConfiguration configuration,
  ) {
    return FlutterIonSfuPlatform.instance.start(configuration);
  }

  Future<void> stop() {
    return FlutterIonSfuPlatform.instance.stop();
  }

  Future<int> createSignalChannel() {
    return FlutterIonSfuPlatform.instance.createSignalChannel();
  }

  Future<void> closeSignalChannel(int channelId) {
    return FlutterIonSfuPlatform.instance.closeSignalChannel(channelId);
  }

  Future<void> processSignalMessage(
    int channelId,
    String message,
  ) {
    return FlutterIonSfuPlatform.instance.processSignalMessage(
      channelId,
      message,
    );
  }
}
