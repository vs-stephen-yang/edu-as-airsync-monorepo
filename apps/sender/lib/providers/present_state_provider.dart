import 'dart:async';

import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:display_cast_flutter/utilities/debug_mode_print.dart';
import 'package:flutter/material.dart';

enum ViewState {
  idle,
  waitReady,
  selectScreen,
  presentStart,
}

class PresentStateProvider extends ChangeNotifier {
  PresentStateProvider(BuildContext context) {
    debugModePrint(
        'appConfig apiGateway: ${AppConfig.of(context)!.settings.urlGateway}');
  }

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

  Future<void> presentTo(
      {required String displayCode, required String otp}) async {
    debugModePrint('presentTo: displayCode: $displayCode, otp: $otp');
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
