import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/providers/multi_window_provider.dart';
import 'package:display_flutter/utility/channel_util.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:provider/provider.dart';

class V3Toast {
  final List<Map<ReconnectState, DateTime>> _splitScreenLastToastTimes =
      List.filled(HybridConnectionList.maxHybridSplitScreen,
          {ReconnectState.idle: DateTime.now()});
  final Map<ReconnectState, DateTime> _lastToastTimes = {};
  final int second = 3;

  void makeSplitScreenReconnectToast(
      BuildContext context, String message, int index,
      {bool isWebRTC = true,
      ReconnectState state = ReconnectState.idle,
      bool hasNameLabel = false}) {
    if (!isWebRTC) {
      if (!_shouldSplitScreenToast(index, state)) {
        return;
      }
    }

    final provider = Provider.of<MultiWindowProvider>(context, listen: false);
    final windowRatio =
        provider.getSplitScreenRatio(MediaQuery.of(context).size);

    OverlayEntry toast = _buildSplitScreenReconnectToast(
        context, message, index,
        hasNameLabel: hasNameLabel, windowRatio: windowRatio);

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

  OverlayEntry _buildSplitScreenToast(
    BuildContext context,
    String message,
    int index, {
    bool hasNameLabel = false,
    String? icon,
    Color? color,
    double iconWidth = 18.0, // icon 16 + padding 2
    SplitScreenRatio? windowRatio,
  }) {
    final double frameWidth = _getFrameWidth(context, windowRatio: windowRatio);
    final double edgePadding = 20;
    final double maxToastWidth = frameWidth - edgePadding;

    final double textScaleFactor = MediaQuery.of(context).textScaler.scale(1.0);

    const double fontSize = 9;
    const double containerPadding = 20;

    // 計算文字可用的最大寬度
    final double maxTextWidth = maxToastWidth - containerPadding - iconWidth;

    // 用 TextPainter 測量文字寬度（允許換行）
    final textPainter = TextPainter(
      text: TextSpan(
        text: message,
        style: TextStyle(
          fontSize: fontSize * textScaleFactor,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxTextWidth);

    // 計算實際需要的 Toast 寬度
    final int lineCount = textPainter.computeLineMetrics().length;
    final double toastWidth = lineCount > 1
        ? maxToastWidth
        : containerPadding + iconWidth + textPainter.width;

    final position = _calculateToastPosition(
      context,
      index,
      toastWidth,
      hasNameLabel,
      windowRatio: windowRatio,
    );
    final top = position.top;
    final left = position.left;

    return OverlayEntry(
      builder: (BuildContext context) => Positioned(
        left: left,
        top: top,
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(maxWidth: maxToastWidth),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.tokens.color.vsdslColorSurface1000,
              borderRadius: context.tokens.radii.vsdslRadiusXl,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (icon != null)
                  SizedBox(
                    width: 16,
                    child: Image(
                      image: Svg(icon),
                    ),
                  ),
                if (icon != null) const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w400,
                      color: color ?? context.tokens.color.vsdslColorWarning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getFrameWidth(BuildContext context, {SplitScreenRatio? windowRatio}) {
    Size screenSize = MediaQuery.of(context).size;
    final count = HybridConnectionList.hybridSplitScreenCount.value;

    // 如果有放大的畫面，返回全屏寬度
    if (HybridConnectionList().enlargedScreenIndex.value != null) {
      return screenSize.width;
    }

    // 根據窗口模式判斷
    final ratio = windowRatio ?? SplitScreenRatio.none;

    // List 布局 (1/3 窗口) - 垂直排列，每個畫面佔滿寬度
    if (ratio == SplitScreenRatio.oneThirdFull) {
      return screenSize.width;
    }

    // Single 布局 (Launcher) - 每次只顯示一個畫面，佔滿寬度
    if (ratio == SplitScreenRatio.launcher ||
        ratio == SplitScreenRatio.launcherFull) {
      return screenSize.width;
    }

    // Split 布局 (浮動窗口) - 左右分割
    if (ratio == SplitScreenRatio.floatingDefault) {
      if (count > 1) {
        return screenSize.width / 2;
      }
      return screenSize.width;
    }

    // Grid 布局 (全屏、Launcher 主畫面) - 網格排列
    // none (全屏), launcherMain, halfFull, twoThirdsFull 等都使用 Grid 布局
    if (count > 6) {
      return screenSize.width / 3; // 3x3
    } else if (count > 4) {
      return screenSize.width / 3; // 3x2
    } else if (count > 2) {
      return screenSize.width / 2; // 2x2
    } else if (count > 1) {
      return screenSize.width / 2; // 1x2
    } else {
      return screenSize.width; // 1x1
    }
  }

  ({double top, double left}) _calculateToastPosition(
    BuildContext context,
    int index,
    double toastWidth,
    bool hasNameLabel, {
    SplitScreenRatio? windowRatio,
  }) {
    Size screenSize = MediaQuery.of(context).size;
    final double toastPadding = hasNameLabel ? 25 : 5;
    final ratio = windowRatio ?? SplitScreenRatio.none;
    final count = HybridConnectionList.hybridSplitScreenCount.value;

    double top;
    double left;

    // 如果有放大的畫面，Toast 在整個螢幕寬度內置中
    if (HybridConnectionList().enlargedScreenIndex.value != null) {
      top = toastPadding;
      left = (screenSize.width - toastWidth) / 2;
      return (top: top, left: left);
    }

    // 根據布局模式計算位置
    switch (ratio) {
      case SplitScreenRatio.oneThirdFull:
        // List 布局：垂直排列，每個畫面佔滿寬度
        final thirdH = screenSize.height / 3;
        final position = index % 3; // 當前頁的第幾行 (0, 1, 2)
        top = position * thirdH + toastPadding;
        left = (screenSize.width - toastWidth) / 2; // 水平置中
        return (top: top, left: left);

      case SplitScreenRatio.launcher:
      case SplitScreenRatio.launcherFull:
        // Single 布局：每次只顯示一個畫面，完全置中
        top = toastPadding;
        left = (screenSize.width - toastWidth) / 2;
        return (top: top, left: left);

      case SplitScreenRatio.floatingDefault:
        // Split 布局：左右分割
        final halfW = screenSize.width / 2;
        final position = index % 2; // 0=左, 1=右
        top = toastPadding;
        if (position == 0) {
          left = (halfW - toastWidth) / 2; // 左半邊置中
        } else {
          left = halfW + (halfW - toastWidth) / 2; // 右半邊置中
        }
        return (top: top, left: left);

      default:
        // Grid 布局：保持現有邏輯
        break;
    }

    // Grid 布局的現有邏輯
    final double halfWidth = screenSize.width / 2;
    final double halfHeight = screenSize.height / 2;
    final double thirdWidth = screenSize.width / 3;
    final double thirdHeight = screenSize.height / 3;

    if (count > 6) {
      // 9 分屏：3x3 佈局
        if (index == 1) {
          top = 0 + toastPadding;
          left = thirdWidth + (thirdWidth - toastWidth) / 2;
        } else if (index == 2) {
          top = 0 + toastPadding;
          left = thirdWidth * 2 + (thirdWidth - toastWidth) / 2;
        } else if (index == 3) {
          top = thirdHeight + toastPadding;
          left = (thirdWidth - toastWidth) / 2;
        } else if (index == 4) {
          top = thirdHeight + toastPadding;
          left = thirdWidth + (thirdWidth - toastWidth) / 2;
        } else if (index == 5) {
          top = thirdHeight + toastPadding;
          left = thirdWidth * 2 + (thirdWidth - toastWidth) / 2;
        } else if (index == 6) {
          top = thirdHeight * 2 + toastPadding;
          left = (thirdWidth - toastWidth) / 2;
        } else if (index == 7) {
          top = thirdHeight * 2 + toastPadding;
          left = thirdWidth + (thirdWidth - toastWidth) / 2;
        } else if (index == 8) {
          top = thirdHeight * 2 + toastPadding;
          left = thirdWidth * 2 + (thirdWidth - toastWidth) / 2;
        } else {
          top = 0 + toastPadding;
          left = (thirdWidth - toastWidth) / 2;
        }
      } else if (HybridConnectionList.hybridSplitScreenCount.value > 4) {
        // 6 分屏：2x3 佈局
        if (index == 1) {
          top = 0 + toastPadding;
          left = thirdWidth + (thirdWidth - toastWidth) / 2;
        } else if (index == 2) {
          top = 0 + toastPadding;
          left = thirdWidth * 2 + (thirdWidth - toastWidth) / 2;
        } else if (index == 3) {
          top = halfHeight + toastPadding;
          left = (thirdWidth - toastWidth) / 2;
        } else if (index == 4) {
          top = halfHeight + toastPadding;
          left = thirdWidth + (thirdWidth - toastWidth) / 2;
        } else if (index == 5) {
          top = halfHeight + toastPadding;
          left = thirdWidth * 2 + (thirdWidth - toastWidth) / 2;
        } else {
          top = 0 + toastPadding;
          left = (thirdWidth - toastWidth) / 2;
        }
      } else if (HybridConnectionList.hybridSplitScreenCount.value > 2) {
        // 4 分屏：2x2 佈局
        if (index == 1) {
          top = 0 + toastPadding;
          left = halfWidth + (halfWidth - toastWidth) / 2;
        } else if (index == 2) {
          top = halfHeight + toastPadding;
          left = (halfWidth - toastWidth) / 2;
        } else if (index == 3) {
          top = halfHeight + toastPadding;
          left = halfWidth + (halfWidth - toastWidth) / 2;
        } else {
          top = 0 + toastPadding;
          left = (halfWidth - toastWidth) / 2;
        }
      } else if (HybridConnectionList.hybridSplitScreenCount.value > 1) {
        // 2 分屏：橫向分割
        if (index == 1) {
          top = toastPadding;
          left = halfWidth + (halfWidth - toastWidth) / 2;
        } else {
          top = toastPadding;
          left = (halfWidth - toastWidth) / 2;
        }
      } else {
        // 單屏
        top = toastPadding;
      left = (screenSize.width - toastWidth) / 2;
    }

    return (top: top, left: left);
  }

  OverlayEntry _buildSplitScreenReconnectToast(
      BuildContext context, String message, int index,
      {bool hasNameLabel = false, SplitScreenRatio? windowRatio}) {
    return _buildSplitScreenToast(
      context,
      message,
      index,
      hasNameLabel: hasNameLabel,
      icon: 'assets/images/ic_toast_alert.svg',
      color: context.tokens.color.vsdslColorWarning,
      windowRatio: windowRatio,
    );
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

  MotionToast _makeToast({
    required BuildContext context,
    required String message,
    IconData? icon,
    Color? mainColor,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
          text: message,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w400)),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    double toastWidth =
        20 + (icon != null ? 16 + 2.6 : 0) + textPainter.width + 20;

    return MotionToast(
      height: 46,
      width: toastWidth,
      primaryColor: context.tokens.color.vsdslColorSurface1000,
      description: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              ImageIcon(
                size: 16,
                color: mainColor,
                const Svg('assets/images/ic_checkmark.svg'),
              ),
              const SizedBox(width: 2.6),
            ],
            V3AutoHyphenatingText(
              message,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w400,
                color: mainColor,
              ),
            ),
          ],
        ),
      ),
      displaySideBar: false,
      position: MotionToastPosition.bottom,
    );
  }

  MotionToast makeMessageToast(BuildContext context, String message,
      {bool showIcon = true}) {
    return _makeToast(
      context: context,
      message: message,
      icon: showIcon ? Icons.check : null,
      mainColor: context.tokens.color.vsdslColorOnSurfaceInverse,
    );
  }

  MotionToast makeSuccessToast(BuildContext context, String message,
      {bool showIcon = true}) {
    return _makeToast(
      context: context,
      message: message,
      icon: showIcon ? Icons.check : null,
      mainColor: context.tokens.color.vsdslColorSuccess,
    );
  }

  void makeBluetoothStateToast(BuildContext context, String message, int index,
      {Color? color, String? icon, bool hasNameLabel = false}) {
    // 在這裡獲取 windowRatio，使用 listen: false 避免重建
    final provider = Provider.of<MultiWindowProvider>(context, listen: false);
    final windowRatio =
        provider.getSplitScreenRatio(MediaQuery.of(context).size);

    OverlayEntry toast = _buildSplitScreenBluetoothStateToast(
        context, message, index, color, icon,
        hasNameLabel: hasNameLabel, windowRatio: windowRatio);

    Overlay.of(context).insert(toast);

    Future.delayed(const Duration(seconds: 3), () {
      toast.remove();
    });
  }

  OverlayEntry _buildSplitScreenBluetoothStateToast(BuildContext context,
      String message, int index, Color? color, String? icon,
      {bool hasNameLabel = false, SplitScreenRatio? windowRatio}) {
    return _buildSplitScreenToast(
      context,
      message,
      index,
      hasNameLabel: hasNameLabel,
      icon: icon,
      color: color,
      iconWidth: icon != null ? 20.0 : 0,
      windowRatio: windowRatio,
    );
  }
}
