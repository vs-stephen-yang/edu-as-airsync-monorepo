
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
  _setViewState(DemoViewState newViewState) {
    _currentState = newViewState;
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
