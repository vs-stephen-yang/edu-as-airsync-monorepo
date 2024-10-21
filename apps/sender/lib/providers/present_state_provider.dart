

import 'package:flutter/cupertino.dart';

enum ViewState {
  idle,
  selectScreen,
  presentStart,

  selectRole,
  authorizeWait,
  remoteScreen,
  //moderator
  moderatorName,
  moderatorWait,
  moderatorStart,
  moderatorShare,

  settings,
  language,
  deviceList,
  qrScanner,
}

class PresentStateProvider extends ChangeNotifier {

  ViewState _currentState = ViewState.idle;

  ViewState get currentState => _currentState;

  set currentState(ViewState value) {
    _currentState = value;
  }

  setViewState(ViewState newViewState) {
    _currentState = newViewState;
    notifyListeners();
  }

  Future<void> presentMainPage() async {
    setViewState(ViewState.idle);
  }

  Future<void> presentSelectRolePage() async {
    setViewState(ViewState.selectRole);
  }

  Future<void> presentSelectScreenPage() async {
    setViewState(ViewState.selectScreen);
  }

  Future<void> presentBasicStartPage() async {
    setViewState(ViewState.presentStart);
  }

  Future<void> presentAuthorizeWaitPage() async {
    setViewState(ViewState.authorizeWait);
  }

  Future<void> presentRemoteScreenPage() async {
    setViewState(ViewState.remoteScreen);
  }

  Future<void> presentModeratorNamePage() async {
    setViewState(ViewState.moderatorName);
  }

  Future<void> presentModeratorWaitPage() async {
    setViewState(ViewState.moderatorWait);
  }

  Future<void> presentModeratorStartPage() async {
    setViewState(ViewState.moderatorStart);
  }

  Future<void> presentModeratorSharePage() async {
    setViewState(ViewState.moderatorShare);
  }

  Future<void> presentSettingPage() async {
    setViewState(ViewState.settings);
  }

  Future<void> presentLanguagePage() async {
    setViewState(ViewState.language);
  }

  Future<void> presentDeviceListPage() async {
    setViewState(ViewState.deviceList);
  }

  Future<void> presentQrScannerPage() async {
    setViewState(ViewState.qrScanner);
  }

}
