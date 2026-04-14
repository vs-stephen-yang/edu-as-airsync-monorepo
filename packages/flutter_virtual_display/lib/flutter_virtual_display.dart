import 'dart:async';

import 'flutter_virtual_display_platform_interface.dart';
import 'flutter_virtual_display_event_channel.dart';

class FlutterVirtualDisplay {
  FlutterVirtualDisplay._internal() {
    FlutterVirtualDisplayEventChannel.instance.handleEvents.stream.listen((data) {
      var event = data.keys.first;
      Map<dynamic, dynamic> map = data[event];
      handleEvent(event, map);
    });
  }

  static final FlutterVirtualDisplay instance = FlutterVirtualDisplay._internal();

  StreamController<Map<dynamic, dynamic>> get onVirtualDisplayInitialized => _onVirtualDisplayInitialized;
  final StreamController<Map<dynamic, dynamic>> _onVirtualDisplayInitialized =
    StreamController.broadcast(sync: true);

  StreamController<Map<dynamic, dynamic>> get onVirtualDisplayStarted => _onVirtualDisplayStarted;
  final StreamController<Map<dynamic, dynamic>> _onVirtualDisplayStarted =
    StreamController.broadcast(sync: true);

  StreamController<Map<dynamic, dynamic>> get onVirtualDisplayStopped => _onVirtualDisplayStopped;
  final StreamController<Map<dynamic, dynamic>> _onVirtualDisplayStopped =
    StreamController.broadcast(sync: true);

  StreamController<Map<dynamic, dynamic>> get onVirtualDisplayError => _onVirtualDisplayError;
  final StreamController<Map<dynamic, dynamic>> _onVirtualDisplayError =
    StreamController.broadcast(sync: true);

  Future<bool?> isSupported() {
    return FlutterVirtualDisplayPlatform.instance.isSupported();
  }

  Future<bool?> initialize() {
    return FlutterVirtualDisplayPlatform.instance.initialize();
  }

  Future<bool?> startVirtualDisplay(int pixelWidth, int pixelHeight) async {
    return FlutterVirtualDisplayPlatform.instance.startVirtualDisplay(
      pixelWidth,
      pixelHeight,
    );
  }

  Future<void> stopVirtualDisplay() {
    return FlutterVirtualDisplayPlatform.instance.stopVirtualDisplay();
  }

  void handleEvent(String event, Map<dynamic, dynamic> map) async {
    // print event and map
    print('Event: $event');
    switch (event) {
      case 'virtualDisplayInitialized':
        _onVirtualDisplayInitialized.add(map);
        break;

      case 'virtualDisplayStarted':
        _onVirtualDisplayStarted.add(map);
        break;

      case 'virtualDisplayStopped':
        _onVirtualDisplayStopped.add(map);
        break;

      case 'virtualDisplayError':
        _onVirtualDisplayError.add(map);
        break;

      default:
        print('Unknown event: $event');
    }
  }
}
