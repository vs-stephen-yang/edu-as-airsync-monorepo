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

  StreamController<void> get onVirtualDisplayStarted => _onVirtualDisplayStarted;
  final StreamController _onVirtualDisplayStarted =
    StreamController.broadcast(sync: true);

  StreamController<void> get onVirtualDisplayStopped => _onVirtualDisplayStopped;
  final StreamController _onVirtualDisplayStopped =
    StreamController.broadcast(sync: true);

  Future<bool?> initialize() {
    return FlutterVirtualDisplayPlatform.instance.initialize();
  }

  Future<bool?> startVirtualDisplay() {
    return FlutterVirtualDisplayPlatform.instance.startVirtualDisplay();
  }

  Future<void> stopVirtualDisplay() {
    return FlutterVirtualDisplayPlatform.instance.stopVirtualDisplay();
  }

  void handleEvent(String event, Map<dynamic, dynamic> map) async {
    switch (event) {
      case 'virtualDisplayStarted':
        _onVirtualDisplayStarted.add(null);
        break;

      case 'virtualDisplayStopped':
        _onVirtualDisplayStopped.add(null);
        break;

      default:
        print('Unknown event: $event');
    }
  }
}
