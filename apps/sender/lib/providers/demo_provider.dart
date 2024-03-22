
import 'package:flutter/cupertino.dart';

enum DemoViewState {
  off,
  selectRole,
  presentStart,
  remoteScreen,
}

class DemoProvider extends ChangeNotifier {
  DemoProvider();

  bool _isDemoMode = false;
  bool get isDemoMode => _isDemoMode;
  set isDemoMode(bool value) {
    _isDemoMode = value;
  }

  //region setView
  DemoViewState _currentState = DemoViewState.off;
  DemoViewState get state => _currentState;
  setViewState(DemoViewState newViewState) {
    _currentState = newViewState;
    notifyListeners();
  }

  // Future<void> presentMainPage() async {
  //   setViewState(DemoViewState.idle);
  // }

  Future<void> presentSelectRolePage() async {
    setViewState(DemoViewState.selectRole);
  }

  Future<void> presentBasicStartPage() async {
    setViewState(DemoViewState.presentStart);
  }

  Future<void> presentRemoteScreenPage() async {
    setViewState(DemoViewState.remoteScreen);
  }
  //endregion



}