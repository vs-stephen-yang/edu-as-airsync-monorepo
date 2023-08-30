import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/model/connect_timer.dart';
import 'package:display_flutter/screens/split_screen.dart';
import 'package:flutter/material.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

import 'control_socket.dart';
import 'display_info.dart';
import 'moderator_socket.dart';

class PresentHelper with ChangeNotifier {
  static final PresentHelper _instance = PresentHelper.internal();

  static PresentHelper getInstance() {
    return _instance;
  }

  PresentHelper.internal();

  void refreshPresentList() {
    notifyListeners();
  }

  Future<void> basicStreamOff() async {
    await ControlSocket().removeAllPresenters();
    ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
    ConnectionTimer.getInstance().stopRemainingTimeTimer();
  }

  Future<void> splitScreenOff() async {
    AppAnalytics().trackEventSplitScreenOff();
    ConnectionTimer.getInstance().stopRemainingTimeTimer();
    AppAnalytics().setEventProperties(meetingId: '');
    await ControlSocket().removeAllPresenters();
  }

  Future<void> moderatorOff() async {
    // remove all presenter
    await ControlSocket().removeAllPresenters();
    // Need remove all presenters first, due to enable/disable will dispose
    // view and will disconnectedP2pClient before send stopVideo
    // cause web presenter did not update status
    SplitScreen.mapSplitScreen.value[keySplitScreenEnable] = false;
    SplitScreen.mapSplitScreen.value[keySplitScreenCount] = 0;
    // Using below method to trigger value changed.
    // https://github.com/flutter/flutter/issues/29958
    SplitScreen.mapSplitScreen.value =
        Map.from(SplitScreen.mapSplitScreen.value);

    ControlSocket().moderator = null;
    // onUpdateParentUI?.call();
    moderatorSocket.unBindFromDisplay(
        ControlSocket().displayCode, ControlSocket().token);
    moderatorSocket.disconnect();
    DisplayInfo().removeBindToDisplayInfo();
    AppPreferences().set(moderatorId: '');
    navService.popUntil('/home');
  }

}
