import 'package:bot_toast/bot_toast.dart';
import 'package:display_cast_flutter/utilities/channel_util.dart';
import 'package:flutter/material.dart';

class Toast {
  static makeToast(String message,
      {int second = 3,
      msgContentColor = Colors.grey,
      msgTextStyle = const TextStyle(color: Colors.white)}) {
    BotToast.showText(
        text: message,
        duration: Duration(seconds: second),
        align: Alignment.center,
        contentColor: msgContentColor,
        textStyle: msgTextStyle);
  }

  static final Map<ChannelReconnectState, DateTime> _lastToastTimes = {};

  static makeFeatureReconnectToast(ChannelReconnectState state, String message,
      {int second = 3}) {
    if (!shouldToast(state, second)) {
      return;
    }

    BotToast.showText(
        text: message,
        duration: Duration(seconds: second),
        align: const Alignment(0.0, 0.5),
        contentColor: Colors.grey,
        textStyle: const TextStyle(color: Colors.white));

    _lastToastTimes[state] = DateTime.now();
  }

  static bool shouldToast(ChannelReconnectState state, int second) {
    final now = DateTime.now();
    final lastToastTime = _lastToastTimes[state];
    if (lastToastTime != null) {
      final diff = now.difference(lastToastTime);
      return diff.inSeconds >= second;
    }
    return true;
  }
}
