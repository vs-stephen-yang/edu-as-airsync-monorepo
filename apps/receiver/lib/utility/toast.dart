import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/screens/home.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';

import 'channel_util.dart';

class Toast {
  static final List<Map<ReconnectState, DateTime>> _splitScreenLastToastTimes =
      List.filled(6, {ReconnectState.idle: DateTime.now()});
  static final Map<ReconnectState, DateTime> _lastToastTimes = {};
  static const int second = 3;

  static OverlayEntry makeSplitScreenReconnectToast(
      BuildContext context, String message, int index,
      {bool isWebRTC = true, bool hasNameLabel = false}) {
    Size screenSize = MediaQuery.of(context).size;
    double sectionWidth = screenSize.width / 2;
    double sectionHeight = screenSize.height / 2;
    double toastPadding = hasNameLabel ? 35 : 5;
    double? top, left;
    if (Home.enlargedScreenPositionIndex.value == null) {
      if (index == 1) {
        top = 0 + toastPadding; // 改：第一行頂部
        left = sectionWidth + (sectionWidth / 2 - 80);
      } else if (index == 2) {
        top = sectionHeight + toastPadding; // 改：第二行頂部
        left = sectionWidth / 2 - 80;
      } else if (index == 3) {
        top = sectionHeight + toastPadding; // 改：第二行頂部
        left = sectionWidth + (sectionWidth / 2 - 80);
      } else {
        if (HybridConnectionList.hybridSplitScreenCount.value > 1) {
          top = 0 + toastPadding; // 改：第一行頂部
          left = sectionWidth / 2 - 80;
        } else {
          top = toastPadding; // 改：頂部
          left = screenSize.width / 2 - 80;
        }
      }
    } else {
      top = toastPadding; // 改：全屏模式放在頂部
      left = screenSize.width / 2 - 80;
    }

    OverlayEntry toast = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        left: left,
        top: top,
        width: 160, // Width of the Toast
        child: Material(
          color: Colors.transparent,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey, // Change the color of the Toast
              borderRadius: BorderRadius.circular(
                  20), // Change the border radius of the Toast
            ),
            child: V3AutoHyphenatingText(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );

    return toast;
  }

  static void showSplitScreenReconnectToast(
      BuildContext context, String message, int index,
      {bool isWebRTC = true,
      ReconnectState state = ReconnectState.idle,
      bool hasNameLabel = false}) {
    if (!isWebRTC) {
      if (!shouldSplitScreenToast(index, state)) {
        return;
      }
    }

    OverlayEntry toast = makeSplitScreenReconnectToast(context, message, index,
        hasNameLabel: hasNameLabel);

    if (!isWebRTC) {
      _splitScreenLastToastTimes[index][state] = DateTime.now();
    }

    Overlay.of(context).insert(toast);

    Future.delayed(const Duration(seconds: 3), () {
      toast.remove();
    });
  }

  static bool shouldSplitScreenToast(int index, ReconnectState state) {
    final now = DateTime.now();
    final lastToastTime = _splitScreenLastToastTimes[index][state];
    if (lastToastTime != null) {
      final diff = now.difference(lastToastTime);
      return diff.inSeconds >= second;
    }
    return true;
  }

  static MotionToast? makeReconnectToast(ReconnectState state, String message,
      {int index = 0}) {
    if (!shouldToast(state)) {
      return null;
    }

    MotionToast toast = MotionToast(
      primaryColor: Colors.grey,
      description: Center(
        child: V3AutoHyphenatingText(message),
      ),
      displaySideBar: false,
      position: MotionToastPosition.bottom,
    );

    _lastToastTimes[state] = DateTime.now();

    return toast;
  }

  static bool shouldToast(ReconnectState state) {
    final now = DateTime.now();
    final lastToastTime = _lastToastTimes[state];
    if (lastToastTime != null) {
      final diff = now.difference(lastToastTime);
      return diff.inSeconds >= second;
    }
    return true;
  }
}
