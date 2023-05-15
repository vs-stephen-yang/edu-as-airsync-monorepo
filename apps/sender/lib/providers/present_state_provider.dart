import 'dart:async';

import 'package:flutter/material.dart';

enum ViewState {
  idle,
  waitReady,
  selectScreen,
  presentStart,
}

class PresentStateProvider extends ChangeNotifier {
  PresentStateProvider();

  ViewState get state => _currentState;
  ViewState _currentState = ViewState.idle;
  Timer? _presentTimer;

  setViewState(ViewState newViewState) {
    _currentState = newViewState;
    if (_presentTimer != null) {
      _presentTimer!.cancel();
      _presentTimer = null;
    }
    notifyListeners();
  }

  Future<void> presentTo() async {
    setViewState(ViewState.waitReady);
    _presentTimer = Timer(const Duration(seconds: 30), () {
      presentStop();
    });
  }

  Future<void> presentSelectScreen() async {
    setViewState(ViewState.selectScreen);
  }

  Future<void> presentToTimeout() async {
    setViewState(ViewState.idle);
  }

  Future<void> presentStart() async {
    setViewState(ViewState.presentStart);
  }

  Future<void> presentStop() async {
    setViewState(ViewState.idle);
  }
}
