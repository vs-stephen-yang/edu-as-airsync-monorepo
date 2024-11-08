import 'dart:async';
import 'package:desktop_screenstate/desktop_screenstate.dart';

class ScreenStateDetector {
  static ScreenStateDetector? _instance;

  static ScreenStateDetector get instance => _instance!;

  final StreamController<ScreenState> _onState =
      StreamController<ScreenState>.broadcast();

  Stream<ScreenState> get onState => _onState.stream;

  ScreenStateDetector._internal() {
    DesktopScreenState.instance.isActive.addListener(() {
      switch (DesktopScreenState.instance.isActive.value) {
        case ScreenState.awaked:
          _onState.add(ScreenState.awaked);
          break;
        case ScreenState.sleep:
          _onState.add(ScreenState.sleep);
          break;
        case ScreenState.locked:
          _onState.add(ScreenState.locked);
          break;
        case ScreenState.unlocked:
          _onState.add(ScreenState.unlocked);
          break;
      }
    });
  }

  static void initialize() {
    // ensures that the class is only initialized once.
    assert(_instance == null);

    _instance = ScreenStateDetector._internal();
  }
}
