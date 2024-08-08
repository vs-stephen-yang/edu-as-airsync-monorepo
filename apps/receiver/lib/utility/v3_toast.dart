import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/utility/channel_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:motion_toast/motion_toast.dart';

class V3Toast {
  static final V3Toast _instance = V3Toast._internal();

  //private "Named constructors"
  V3Toast._internal();

  // passes the instantiation to the _instance object
  factory V3Toast() => _instance;

  final List<Map<ReconnectState, DateTime>> _splitScreenLastToastTimes =
      List.filled(HybridConnectionList.maxHybridSplitScreen,
          {ReconnectState.idle: DateTime.now()});
  final Map<ReconnectState, DateTime> _lastToastTimes = {};
  final int second = 3;

  void makeSplitScreenReconnectToast(
      BuildContext context, String message, int index,
      {bool isWebRTC = true, ReconnectState state = ReconnectState.idle}) {
    if (!isWebRTC) {
      if (!_shouldSplitScreenToast(index, state)) {
        return;
      }
    }

    OverlayEntry toast =
        _buildSplitScreenReconnectToast(context, message, index);

    if (!isWebRTC) {
      _splitScreenLastToastTimes[index][state] = DateTime.now();
    }

    Overlay.of(context).insert(toast);

    Future.delayed(const Duration(seconds: 3), () {
      toast.remove();
    });
  }

  MotionToast? makeReconnectToast(ReconnectState state, String message,
      {int index = 0}) {
    if (!shouldToast(state)) {
      return null;
    }

    MotionToast toast = MotionToast(
      primaryColor: Colors.grey,
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

  bool _shouldSplitScreenToast(int index, ReconnectState state) {
    final now = DateTime.now();
    final lastToastTime = _splitScreenLastToastTimes[index][state];
    if (lastToastTime != null) {
      final diff = now.difference(lastToastTime);
      return diff.inSeconds >= second;
    }
    return true;
  }

  OverlayEntry _buildSplitScreenReconnectToast(
      BuildContext context, String message, int index) {
    Size screenSize = MediaQuery.of(context).size;
    double sectionWidth = screenSize.width / 2;
    double sectionHeight = screenSize.height / 2;
    double? top, left;
    if (HybridConnectionList().enlargedScreenIndex.value == null) {
      if (index == 1) {
        top = sectionHeight - 80;
        left = sectionWidth + (sectionWidth / 2 - 80);
      } else if (index == 2) {
        top = sectionHeight * 2 - 80;
        left = sectionWidth / 2 - 80;
      } else if (index == 3) {
        top = sectionHeight * 2 - 80;
        left = sectionWidth + (sectionWidth / 2 - 80);
      } else {
        if (HybridConnectionList.hybridSplitScreenCount.value > 1) {
          top = sectionHeight - 80;
          left = sectionWidth / 2 - 80;
        } else {
          top = screenSize.height - 80;
          left = screenSize.width / 2 - 80;
        }
      }
    } else {
      top = screenSize.height - 80;
      left = screenSize.width / 2 - 80;
    }

    OverlayEntry toast = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        left: left,
        top: top,
        width: 298, // Width of the Toast
        child: Material(
          color: Colors.transparent,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              // Change the color of the Toast
              color: const Color(0xFF151C32),
              // Change the border radius of the Toast
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  child: Image(
                    image: Svg('assets/images/ic_toast_alert.svg'),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                ),
                SizedBox(
                  width: 250,
                  child: AutoSizeText(
                    message,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFFC9700),
                    ),
                    minFontSize: 8,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return toast;
  }

  bool shouldToast(ReconnectState state) {
    final now = DateTime.now();
    final lastToastTime = _lastToastTimes[state];
    if (lastToastTime != null) {
      final diff = now.difference(lastToastTime);
      return diff.inSeconds >= second;
    }
    return true;
  }
}
