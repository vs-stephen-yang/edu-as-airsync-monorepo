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
    notifyListeners();
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
    final appHeight = appSize.height *
        PlatformDispatcher.instance.views.first.devicePixelRatio;
    final widthRatio =
        double.parse((appWidth / _realScreenSize.width).toStringAsFixed(2));

    final fullHeight = (appHeight - _realScreenSize.height).abs() < 150;
    if (fullHeight) {
      return switch (widthRatio) {
        < 0.33 => SplitScreenRatio.launcherFull,
        >= 0.33 && < 0.5 => SplitScreenRatio.oneThirdFull,
        >= 0.5 && < 0.65 => SplitScreenRatio.halfFull,
        >= 0.65 => SplitScreenRatio.twoThirdsFull,
        _ => SplitScreenRatio.none
      };
    }

    // 先看高度再看寬度
    if (appSize.height < SplitScreenRatio.floatingDefault.heightDP ||
        appSize.width < SplitScreenRatio.floatingDefault.widthDP) {
      return SplitScreenRatio.launcher;
    } else if (appSize.height < SplitScreenRatio.launcherMain.heightDP ||
        appSize.width < SplitScreenRatio.launcherMain.widthDP) {
      return SplitScreenRatio.floatingDefault;
    } else {
      return SplitScreenRatio.launcherMain;
    }
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
      'IFP51',
      'IFP92',
    ];
    // 轉成大寫後比較以防大小寫錯誤
    final normalizedModel = deviceModel.toUpperCase();
    return unsupportedModels.any((model) => normalizedModel.contains(model));
  }
}

enum SplitScreenRatio {
  launcher,
  launcherFull,
  oneThirdFull,
  floatingDefault,
  halfFull,
  twoThirdsFull,
  launcherMain,
  none,
}

extension SplitScreenRatioExt on SplitScreenRatio {
  double get widthFraction {
    switch (this) {
      case SplitScreenRatio.launcher:
      case SplitScreenRatio.launcherFull:
        return 0.21875; // 420/1920
      case SplitScreenRatio.oneThirdFull:
        return 0.33;
      case SplitScreenRatio.floatingDefault:
        return 0.416667; // 800/1920
      case SplitScreenRatio.halfFull:
        return 0.5;
      case SplitScreenRatio.twoThirdsFull:
        return 2 / 3;
      case SplitScreenRatio.launcherMain:
        return 0.6979; // 1340/1920
      case SplitScreenRatio.none:
        return 0;
    }
  }

  double get heightFraction {
    switch (this) {
      case SplitScreenRatio.launcher:
        return 0.2185; // 236/1080
      case SplitScreenRatio.floatingDefault:
        return 0.4166; // 450/1080
      case SplitScreenRatio.launcherMain:
        return 0.6981; // 754/1080
      case SplitScreenRatio.launcherFull:
      case SplitScreenRatio.oneThirdFull:
      case SplitScreenRatio.halfFull:
      case SplitScreenRatio.twoThirdsFull:
        return 1;
      case SplitScreenRatio.none:
        return 0;
    }
  }

  double get widthDP {
    switch (this) {
      case SplitScreenRatio.launcher:
      case SplitScreenRatio.launcherFull:
        return (420 / 3) * 2;
      case SplitScreenRatio.oneThirdFull:
        return (640 / 3) * 2;
      case SplitScreenRatio.floatingDefault:
        return (800 / 3) * 2;
      case SplitScreenRatio.halfFull:
        return (960 / 3) * 2;
      case SplitScreenRatio.twoThirdsFull:
        return (1280 / 3) * 2;
      case SplitScreenRatio.launcherMain:
        return (1340 / 3) * 2;
      case SplitScreenRatio.none:
        return (1920 / 3) * 2;
    }
  }

  double get heightDP {
    switch (this) {
      case SplitScreenRatio.launcher:
        return (236 / 3) * 2;
      case SplitScreenRatio.floatingDefault:
        return (450 / 3) * 2;
      case SplitScreenRatio.launcherMain:
        return (754 / 3) * 2;
      case SplitScreenRatio.launcherFull:
      case SplitScreenRatio.oneThirdFull:
      case SplitScreenRatio.halfFull:
      case SplitScreenRatio.twoThirdsFull:
      case SplitScreenRatio.none:
        return (1080 / 3) * 2;
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
  final Widget? launcher;
  final Widget? launcherFull;
  final Widget? floatingDefault;
  final Widget? landscapeHalf;
  final Widget? landscapeOneThird;
  final Widget? landscapeTwoThirds;
  final Widget? launcherMain;

  const MultiWindowAdaptiveLayout({
    super.key,
    this.portrait,
    required this.landscape,
    this.launcher,
    this.launcherFull,
    this.floatingDefault,
    this.landscapeHalf,
    this.landscapeOneThird,
    this.landscapeTwoThirds,
    this.launcherMain,
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

      //w420、w640、w800、w960、w1280
      switch (ratio) {
        case SplitScreenRatio.launcher:
          return launcher ?? landscape;
        case SplitScreenRatio.floatingDefault:
          return floatingDefault ?? launcher ?? landscape;
        case SplitScreenRatio.twoThirdsFull:
          return landscapeTwoThirds ?? landscape;
        case SplitScreenRatio.halfFull:
          return landscapeHalf ?? landscape;
        case SplitScreenRatio.oneThirdFull:
          return landscapeOneThird ?? landscape;
        case SplitScreenRatio.launcherFull:
          return launcherFull ?? launcher ?? landscape;
        case SplitScreenRatio.launcherMain:
          return launcherMain ?? landscape;
        case SplitScreenRatio.none:
          return landscape;
      }
    });
  }
}
