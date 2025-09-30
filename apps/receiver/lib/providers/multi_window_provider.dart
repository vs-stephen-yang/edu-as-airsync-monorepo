import 'package:device_info_vs/device_info_vs.dart';
import 'package:display_flutter/utility/view_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class MultiWindowProvider extends ChangeNotifier {
  static const MethodChannel _channel =
      MethodChannel('com.mvbcast.crosswalk/multi_window_mode');

  bool _isInMultiWindow = false;

  Size _realScreenSize = Size.zero;

  Size get realScreenSize => _realScreenSize;

  SystemBarMetrics _systemBarMetrics = const SystemBarMetrics();

  SystemBarMetrics get systemBarMetrics => _systemBarMetrics;

  double get statusBarHeightPx => _systemBarMetrics.statusBarHeightPx;

  double get navigationBarHeightPx => _systemBarMetrics.navigationBarHeightPx;

  bool get isStatusBarVisible => _systemBarMetrics.isStatusBarVisible;

  bool get isNavigationBarVisible => _systemBarMetrics.isNavigationBarVisible;

  bool _systemBarRefreshScheduled = false;

  bool _isCorporateMode = false;

  MultiWindowProvider() {
    _init();
  }

  Future<void> _init() async {
    _isCorporateMode = await DeviceInfoVs.isCorporateMode ?? false;
    notifyListeners();
    try {
      final resolution =
          await _channel.invokeMethod("getRealScreenResolution") as Map?;
      final deviceWidth = (resolution?['width'] ?? 0) as int;
      final deviceHeight = (resolution?['height'] ?? 0) as int;
      _realScreenSize = Size(deviceWidth.toDouble(), deviceHeight.toDouble());
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to get screen resolution: $e");
    }
    _scheduleSystemBarRefresh();

    _channel.setMethodCallHandler(_handleMultiWindowChange);
  }

  Future<bool> _loadAndSetSystemBarMetrics() async {
    var metricsChanged = false;

    try {
      final metrics = await _channel
          .invokeMethod<Map<dynamic, dynamic>>('getSystemBarMetrics');
      if (metrics != null) {
        final updated = _applySystemBarMetrics(
          Map<dynamic, dynamic>.from(metrics),
        );
        metricsChanged = metricsChanged || updated;
      } else {
        debugPrint('System bar metrics result is null');
      }
    } catch (e) {
      debugPrint('Failed to load system bar metrics: $e');
    }

    return metricsChanged;
  }

  bool _applySystemBarMetrics(Map<dynamic, dynamic> metrics) {
    final nextMetrics = SystemBarMetrics.fromMap(metrics);
    if (nextMetrics == _systemBarMetrics) {
      return false;
    }
    _systemBarMetrics = nextMetrics;
    return true;
  }

  bool _updateMultiWindow(bool value) {
    if (_isInMultiWindow != value) {
      _isInMultiWindow = value;
      return true;
    }
    return false;
  }

  SplitScreenRatio getSplitScreenRatio(Size appSize) {
    if (_realScreenSize == Size.zero) return SplitScreenRatio.none;
    // 轉成pixel計算比例
    final dpr = getSafeDevicePixelRatio();
    final appWidth = appSize.width * dpr;
    final appHeight = appSize.height * dpr;
    final widthRatio =
        double.parse((appWidth / _realScreenSize.width).toStringAsFixed(2));

    final fullHeight = _calculateIsFullHeight(appWidth, appHeight);
    if (fullHeight) {
      final r = switch (widthRatio) {
        < 0.33 => SplitScreenRatio.launcherFull,
        >= 0.33 && < 0.5 => SplitScreenRatio.oneThirdFull,
        >= 0.5 && < 0.65 => SplitScreenRatio.halfFull,
        >= 0.65 => SplitScreenRatio.twoThirdsFull,
        _ => SplitScreenRatio.none
      };
      return r;
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

  bool _calculateIsFullHeight(double appWidth, double appHeight) {
    final metrics = _systemBarMetrics;
    final statusBarHeightPx =
        (metrics.isStatusBarVisible) ? metrics.statusBarHeightPx : 0;
    final adjustedNavigationBarHeightPx =
        (metrics.isNavigationBarVisible) ? metrics.navigationBarHeightPx : 0;
    final totalHeight =
        appHeight + statusBarHeightPx + adjustedNavigationBarHeightPx;
    final fullWidth = appWidth == _realScreenSize.width;
    final isFullHeight = totalHeight >= _realScreenSize.height;
    if (!_isCorporateMode || fullWidth) {
      return isFullHeight;
    }

    /// CorporateMode bottom floating bar is 84
    return totalHeight >= (_realScreenSize.height - 84);
  }

  bool _isFloatWindow(Size appSize) {
    if (_isInMultiWindow) {
      final appHeight = appSize.height * getSafeDevicePixelRatio();
      if (appHeight != _realScreenSize.height) {
        return true;
      }
    }
    return false;
  }

  Future<void> _handleMultiWindowChange(MethodCall call) async {
    if (call.method != "onMultiWindowChanged") return;

    final multiWindowChanged = _updateMultiWindow(call.arguments as bool);
    if (!multiWindowChanged) return;

    notifyListeners();

    _scheduleSystemBarRefresh();
  }

  void _scheduleSystemBarRefresh(
      {Duration delay = const Duration(seconds: 1)}) {
    if (_systemBarRefreshScheduled) return;
    final binding = WidgetsBinding.instance;
    _systemBarRefreshScheduled = true;
    binding.addPostFrameCallback((_) async {
      try {
        if (delay > Duration.zero) {
          await Future.delayed(delay);
        }
        final metricsChanged = await _loadAndSetSystemBarMetrics();

        if (!metricsChanged) return;
        notifyListeners();

        if (!_isCorporateMode &&
            _systemBarMetrics.isStatusBarVisible &&
            _isInMultiWindow) {
          // In the multiWindow mode(Split Screen mode) the system status and bottom navigation bar will appear, also not able to hide due to the rule by android's design
          // so we need to set status bar to visible
          await SystemChrome.setEnabledSystemUIMode(
              SystemUiMode.immersiveSticky);
        } else if (!_isCorporateMode && !_isInMultiWindow) {
          // set status to hide status bar and bottom navigation bar when it is not multi mode
          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
              overlays: []);
        }
      } finally {
        _systemBarRefreshScheduled = false;
      }
    });
  }
}

@immutable
class SystemBarMetrics {
  final double statusBarHeightPx;
  final double navigationBarHeightPx;
  final bool isStatusBarVisible;
  final bool isNavigationBarVisible;

  const SystemBarMetrics({
    this.statusBarHeightPx = 0,
    this.navigationBarHeightPx = 0,
    this.isStatusBarVisible = false,
    this.isNavigationBarVisible = false,
  });

  factory SystemBarMetrics.fromMap(Map<dynamic, dynamic> map) {
    final statusBarHeight = (map['statusBarHeight'] as num?)?.toDouble() ?? 0;
    final navigationBarHeight =
        (map['navigationBarHeight'] as num?)?.toDouble() ?? 0;
    final statusBarVisible = map['isStatusBarVisible'] as bool? ?? false;
    final navigationBarVisible =
        map['isNavigationBarVisible'] as bool? ?? false;

    return SystemBarMetrics(
      statusBarHeightPx: statusBarHeight > 0 ? statusBarHeight : 0,
      navigationBarHeightPx: navigationBarHeight > 0 ? navigationBarHeight : 0,
      isStatusBarVisible: statusBarVisible,
      isNavigationBarVisible: navigationBarVisible,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SystemBarMetrics &&
        other.statusBarHeightPx == statusBarHeightPx &&
        other.navigationBarHeightPx == navigationBarHeightPx &&
        other.isStatusBarVisible == isStatusBarVisible &&
        other.isNavigationBarVisible == isNavigationBarVisible;
  }

  @override
  int get hashCode => Object.hash(
        statusBarHeightPx,
        navigationBarHeightPx,
        isStatusBarVisible,
        isNavigationBarVisible,
      );

  @override
  String toString() {
    return 'SystemBarMetrics(statusBarHeightPx: $statusBarHeightPx, '
        'navigationBarHeightPx: $navigationBarHeightPx, '
        'isStatusBarVisible: $isStatusBarVisible, '
        'isNavigationBarVisible: $isNavigationBarVisible)';
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
  none;

  bool get isFullHeight {
    switch (this) {
      case SplitScreenRatio.launcherFull:
      case SplitScreenRatio.oneThirdFull:
      case SplitScreenRatio.twoThirdsFull:
      case SplitScreenRatio.halfFull:
      case SplitScreenRatio.none:
        return true;
      case SplitScreenRatio.launcher:
      case SplitScreenRatio.floatingDefault:
      case SplitScreenRatio.launcherMain:
        return false;
    }
  }

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
        return 1;
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
        return 1;
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
    final size = MediaQuery.of(this).size;
    final appHeight = size.height * getSafeDevicePixelRatio();
    final appWidth = size.width * getSafeDevicePixelRatio();
    if (appHeight != multiWindow._realScreenSize.height ||
        appWidth != multiWindow._realScreenSize.width) {
      return true;
    }

    return false;
  }

  SplitScreenRatio get splitScreenRatio =>
      multiWindow.getSplitScreenRatio(MediaQuery.of(this).size);

  // 目前是不正確的，待調整
  bool get isFloatWindow =>
      multiWindow._isFloatWindow(MediaQuery.of(this).size);

  double get statusBarHeightPx => multiWindow.statusBarHeightPx;

  double get navigationBarHeightPx => multiWindow.navigationBarHeightPx;

  bool get isStatusBarVisible => multiWindow.isStatusBarVisible;

  bool get isNavigationBarVisible => multiWindow.isNavigationBarVisible;
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
