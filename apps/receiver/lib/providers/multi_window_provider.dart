import 'dart:ui';

import 'package:device_info_vs/device_info_vs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class MultiWindowProvider extends ChangeNotifier {
  static const MethodChannel _channel =
      MethodChannel('com.mvbcast.crosswalk/multi_window_mode');

  bool _isInMultiWindow = false;

  Size _realScreenSize = Size.zero;

  Size get realScreenSize => _realScreenSize;

  String _deviceModel = "";

  MultiWindowProvider() {
    _init();
  }

  Future<void> _init() async {
    _deviceModel = await DeviceInfoVs.deviceType ?? '';
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

  bool _isFloatingIFPModel(String deviceModel) {
    final unsupportedModels = [
      'IFP105',
      'IFP92',
    ];
    // 轉成大寫後比較以防大小寫錯誤
    final normalizedModel = deviceModel.toUpperCase();
    return unsupportedModels.any((model) => normalizedModel.contains(model));
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

  bool get isInMultiWindow {
    // IFP92與105只能用高度來判斷是否為全屏，原生的isInMultiWindowMode無效。
    if (multiWindow._isFloatingIFPModel(multiWindow._deviceModel)) {
      final appHeight = MediaQuery.of(this).size.height *
          PlatformDispatcher.instance.views.first.devicePixelRatio;
      if (appHeight != multiWindow._realScreenSize.height) {
        return true;
      }
      return false;
    } else {
      return multiWindow._isInMultiWindow;
    }
  }

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

class MultiWindowAdaptiveLayout extends StatelessWidget {
  final Widget? portrait;
  final Widget landscape;
  final Widget? landscapeHalf;
  final Widget? landscapeOneThird;
  final Widget? landscapeTwoThirds;

  const MultiWindowAdaptiveLayout({
    super.key,
    this.portrait,
    required this.landscape,
    this.landscapeHalf,
    this.landscapeOneThird,
    this.landscapeTwoThirds,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMultiWindow = context.isInMultiWindow;
      final isPortrait =
          constraints.maxWidth < constraints.maxHeight && !isMultiWindow;

      if (isPortrait && portrait != null) {
        return portrait ?? landscape;
      }

      if (!isMultiWindow) return landscape;

      final ratio = context.splitScreenRatio;

      switch (ratio) {
        case SplitScreenRatio.twoThirds:
          return landscapeTwoThirds ?? landscape;
        case SplitScreenRatio.half:
          return landscapeHalf ?? landscape;
        case SplitScreenRatio.oneThird:
          return landscapeOneThird ?? landscape;
        case SplitScreenRatio.none:
          return landscape;
      }
    });
  }
}
