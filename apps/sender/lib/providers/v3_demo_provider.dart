import 'dart:async';

import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_channel/display_channel.dart';
import 'package:flutter/cupertino.dart';

enum V3DemoViewState {
  off,
  selectRole,
  presentStart,
  remoteScreen,
  idle,
}

class V3DemoProvider extends ChangeNotifier {
  V3DemoProvider();

  bool isDemoMode = false;
  JoinIntentType currentRole = JoinIntentType.present;
  V3DemoViewState _currentState = V3DemoViewState.off;
  Timer? _presentTimer;

  V3DemoViewState get state => _currentState;

  void _startTimer() {
    if (_presentTimer != null) {
      _presentTimer!.cancel();
    }
    _resetCounters();
    _presentTimer = Timer.periodic(const Duration(seconds: 1), _onTimerTick);
  }

  void _stopTimer() {
    _presentTimer?.cancel();
    _presentTimer = null;
  }

  void _resetCounters() {
    countSecondsValue.value = 0;
    countMinutesValue.value = 0;
    countHoursValue.value = 0;
  }

  void _onTimerTick(Timer timer) {
    if (presentingState.value) {
      _incrementCounters();
    }
  }

  void _incrementCounters() {
    countSecondsValue.value++;
    if (countSecondsValue.value == 60) {
      countSecondsValue.value = 0;
      countMinutesValue.value++;
    }
    if (countMinutesValue.value == 60) {
      countMinutesValue.value = 0;
      countHoursValue.value++;
    }
  }

  void _setViewState(V3DemoViewState newViewState) {
    _currentState = newViewState;

    switch (newViewState) {
      case V3DemoViewState.presentStart:
        _startTimer();
        break;
      case V3DemoViewState.off:
      case V3DemoViewState.selectRole:
      case V3DemoViewState.remoteScreen:
      case V3DemoViewState.idle:
        _stopTimer();
        break;
    }

    notifyListeners();
  }

  Future<void> presentDemoOff() async {
    isDemoMode = false;
    _setViewState(V3DemoViewState.off);
  }

  Future<void> presentSelectRoleDemoPage() async {
    _setViewState(V3DemoViewState.selectRole);
  }

  Future<void> presentBasicStartDemoPage() async {
    _setViewState(V3DemoViewState.presentStart);
  }

  Future<void> presentRemoteScreenDemoPage() async {
    _setViewState(V3DemoViewState.remoteScreen);
  }

  void presentResume() {
    presentingState.value = true;
    if (_presentTimer == null || !_presentTimer!.isActive) {
      _presentTimer = Timer.periodic(const Duration(seconds: 1), _onTimerTick);
    }
    notifyListeners();
  }

  void presentPause() {
    presentingState.value = false;
    notifyListeners();
  }

  void presentStop() {
    presentingState.value = true;
    presentDemoOff();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
