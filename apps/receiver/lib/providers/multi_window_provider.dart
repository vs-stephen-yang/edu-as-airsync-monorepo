import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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
      < 0.5 => SplitScreenRatio.oneThird,
      >= 0.5 && < 0.65 => SplitScreenRatio.half,
      >= 0.65 => SplitScreenRatio.twoThirds,
      _ => SplitScreenRatio.none
    };
  }

  bool _isFloatWindow(Size appSize) {
    if (_isInMultiWindow) {
      final appHeight = appSize.height *
          PlatformDispatcher.instance.views.first.devicePixelRatio;
      if (appHeight != _realScreenSize.height) {
        return true;
      }
    }
    return false;
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

extension MultiWindowContext on BuildContext {
  MultiWindowProvider get multiWindow => watch<MultiWindowProvider>();

  bool get isInMultiWindow => multiWindow.isInMultiWindow;

  SplitScreenRatio get splitScreenRatio =>
      multiWindow.getSplitScreenRatio(MediaQuery.of(this).size);

  // 目前是不正確的，待調整
  bool get isFloatWindow =>
      multiWindow._isFloatWindow(MediaQuery.of(this).size);
}

typedef MultiWindowLayoutBuilder = Widget Function(
  BuildContext context,
  BoxConstraints constraints,
  SplitScreenRatio splitScreenRatio,
  bool isInMultiWindow,
  bool isPortrait,
  bool isFloatWindow,
);

class MultiWindowLayout extends StatelessWidget {
  final MultiWindowLayoutBuilder builder;

  const MultiWindowLayout({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ratio = context.splitScreenRatio;
        final isMultiWindow = context.isInMultiWindow;
        final isPortrait =
            constraints.maxWidth < constraints.maxHeight && !isMultiWindow;
        final isFloatWindow = context.isFloatWindow;
        return builder(
          context,
          constraints,
          ratio,
          isMultiWindow,
          isPortrait,
          isFloatWindow,
        );
      },
    );
  }
}
