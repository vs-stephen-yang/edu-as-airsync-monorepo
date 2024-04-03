import 'dart:async';

import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:flutter/cupertino.dart';

enum DemoViewState {
  off,
  selectRole,
  presentStart,
  remoteScreen,
}

class DemoProvider extends ChangeNotifier {
  DemoProvider();

  bool isDemoMode = false;

  //region setView
  DemoViewState _currentState = DemoViewState.off;

  DemoViewState get state => _currentState;
  Timer? _presentTimer;

  _setViewState(DemoViewState newViewState) {
    _currentState = newViewState;
    switch (newViewState) {
      case DemoViewState.off:
        if (_presentTimer != null) {
          _presentTimer!.cancel();
          _presentTimer = null;
        }
        break;
      case DemoViewState.presentStart:
        if (_presentTimer != null) {
          _presentTimer!.cancel();
          _presentTimer = null;
        }
        countSecondsValue.value = 0;
        countMinutesValue.value = 0;
        countHoursValue.value = 0;
        _presentTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (presentingState.value) {
            countSecondsValue.value++;
          }
          if (countSecondsValue.value == 60) {
            countSecondsValue.value = 0;
            countMinutesValue.value++;
          }
          if (countMinutesValue.value == 60) {
            countMinutesValue.value = 0;
            countHoursValue.value++;
          }
        });
        break;
      default:
        break;
    }
    notifyListeners();
  }

  Future<void> presentDemoOff() async {
    _setViewState(DemoViewState.off);
  }

  Future<void> presentSelectRoleDemoPage() async {
    _setViewState(DemoViewState.selectRole);
  }

  Future<void> presentBasicStartDemoPage() async {
    _setViewState(DemoViewState.presentStart);
  }

  Future<void> presentRemoteScreenDemoPage() async {
    _setViewState(DemoViewState.remoteScreen);
  }
//endregion
}
