import 'flutter_ion_sfu_configuration.dart';
import 'flutter_ion_sfu_platform_interface.dart';

class FlutterIonSfu {
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
}
