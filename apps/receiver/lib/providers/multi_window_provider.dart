import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MultiWindowProvider extends ChangeNotifier {
  static const MethodChannel _channel =
      MethodChannel('com.mvbcast.crosswalk/multi_window_mode');

  bool _isInMultiWindow = false;

  bool get isInMultiWindow => _isInMultiWindow;

  Size _realScreenSize = Size.zero;

  Size get realScreenSize => _realScreenSize;

  MultiWindowProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      final resolution =
          await _channel.invokeMethod("getRealScreenResolution") as Map?;
      final deviceWidth = (resolution?['width'] ?? 0) as int;
      final deviceHeight = (resolution?['height'] ?? 0) as int;
      _realScreenSize = Size(deviceWidth.toDouble(), deviceHeight.toDouble());
    } catch (e) {
      debugPrint("Failed to get screen resolution: $e");
    }
    _channel.setMethodCallHandler(_handleMultiWindowChange);
  }

  void _updateMultiWindow(bool value) {
    if (_isInMultiWindow != value) {
      _isInMultiWindow = value;
      notifyListeners();
    }
  }

  SplitScreenRatio getSplitScreenRatio(Size appSize) {
    if (_realScreenSize == Size.zero) return SplitScreenRatio.none;
    // 轉成pixel計算比例
    final appWidth = appSize.width *
        PlatformDispatcher.instance.views.first.devicePixelRatio;
    final ratio = double.parse(
      (appWidth / _realScreenSize.width).toStringAsFixed(2),
    );
    debugPrint('**** ratio $ratio');
    return switch (ratio) {
      <= 0.34 => SplitScreenRatio.oneThird,
      > 0.33 && <= 0.5 => SplitScreenRatio.half,
      > 0.5 && <= 0.65 => SplitScreenRatio.twoThirds,
      _ => SplitScreenRatio.none
    };
  }

  Future<void> _handleMultiWindowChange(MethodCall call) async {
    if (call.method == "onMultiWindowChanged") {
      _updateMultiWindow(call.arguments as bool);
    }
  }
}

enum SplitScreenRatio { half, oneThird, twoThirds, none }

extension SplitScreenRatioExt on SplitScreenRatio {
  String get label {
    switch (this) {
      case SplitScreenRatio.half:
        return "1/2";
      case SplitScreenRatio.oneThird:
        return "1/3";
      case SplitScreenRatio.twoThirds:
        return "2/3";
      case SplitScreenRatio.none:
        return "None";
    }
  }
}
