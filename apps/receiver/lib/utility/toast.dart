import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';

import 'channel_util.dart';

class Toast {

  static final Map<ReconnectState, DateTime> _lastToastTimes = {};

  static MotionToast? makeReconnectToast(ReconnectState state, String message,
      {int second = 3}) {
    if (!shouldToast(state, second)) {
      return null;
    }

    MotionToast toast = MotionToast(
      primaryColor: Colors.grey,
      backgroundType: BackgroundType.solid,
      description: Center(
        child: AutoSizeText(
          message,
          maxLines: 1,
        ),
      ),
      displaySideBar: false,
      position: MotionToastPosition.bottom,
    );

    _lastToastTimes[state] = DateTime.now();

    return toast;
  }

  static bool shouldToast(ReconnectState state, int second) {
    final now = DateTime.now();
    final lastToastTime = _lastToastTimes[state];
    if (lastToastTime != null) {
      final diff = now.difference(lastToastTime);
      return diff.inSeconds >= second;
    }
    return true;
  }
}
