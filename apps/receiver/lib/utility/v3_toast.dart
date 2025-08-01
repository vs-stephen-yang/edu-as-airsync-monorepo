import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/model/hybrid_connection_list.dart';
import 'package:display_flutter/utility/channel_util.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:motion_toast/motion_toast.dart';

class V3Toast {
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
    double toastWidth = 300;
    double toastPadding = 83;
    double halfWidth = screenSize.width / 2;
    double halfHeight = screenSize.height / 2;
    double thirdWidth = screenSize.width / 3;
    double thirdHeight = screenSize.height / 3;
    double? top, left;
    if (HybridConnectionList().enlargedScreenIndex.value != null) {
      top = screenSize.height - toastPadding;
      left = (screenSize.width - toastWidth) / 2;
    } else {
      if (HybridConnectionList.hybridSplitScreenCount.value > 6) {
        if (index == 1) {
          top = thirdHeight - toastPadding;
          left = thirdWidth + (thirdWidth - toastWidth) / 2;
        } else if (index == 2) {
          top = thirdHeight - toastPadding;
          left = thirdWidth * 2 + (thirdWidth - toastWidth) / 2;
        } else if (index == 3) {
          top = thirdHeight * 2 - toastPadding;
          left = (thirdWidth - toastWidth) / 2;
        } else if (index == 4) {
          top = thirdHeight * 2 - toastPadding;
          left = thirdWidth + (thirdWidth - toastWidth) / 2;
        } else if (index == 5) {
          top = thirdHeight * 2 - toastPadding;
          left = thirdWidth * 2 + (thirdWidth - toastWidth) / 2;
        } else if (index == 6) {
          top = screenSize.height - toastPadding;
          left = (thirdWidth - toastWidth) / 2;
        } else if (index == 7) {
          top = screenSize.height - toastPadding;
          left = thirdWidth + (thirdWidth - toastWidth) / 2;
        } else if (index == 8) {
          top = screenSize.height - toastPadding;
          left = thirdWidth * 2 + (thirdWidth - toastWidth) / 2;
        } else {
          top = thirdHeight - toastPadding;
          left = (thirdWidth - toastWidth) / 2;
        }
      } else if (HybridConnectionList.hybridSplitScreenCount.value > 4) {
        if (index == 1) {
          top = halfHeight - toastPadding;
          left = thirdWidth + (thirdWidth - toastWidth) / 2;
        } else if (index == 2) {
          top = halfHeight - toastPadding;
          left = thirdWidth * 2 + (thirdWidth - toastWidth) / 2;
        } else if (index == 3) {
          top = halfHeight * 2 - toastPadding;
          left = (thirdWidth - toastWidth) / 2;
        } else if (index == 4) {
          top = halfHeight * 2 - toastPadding;
          left = thirdWidth + (thirdWidth - toastWidth) / 2;
        } else if (index == 5) {
          top = halfHeight * 2 - toastPadding;
          left = thirdWidth * 2 + (thirdWidth - toastWidth) / 2;
        } else {
          top = halfHeight - toastPadding;
          left = (thirdWidth - toastWidth) / 2;
        }
      } else if (HybridConnectionList.hybridSplitScreenCount.value > 2) {
        if (index == 1) {
          top = halfHeight - toastPadding;
          left = halfWidth + (halfWidth - toastWidth) / 2;
        } else if (index == 2) {
          top = halfHeight * 2 - toastPadding;
          left = (halfWidth - toastWidth) / 2;
        } else if (index == 3) {
          top = halfHeight * 2 - toastPadding;
          left = halfWidth + (halfWidth - toastWidth) / 2;
        } else {
          top = halfHeight - toastPadding;
          left = (halfWidth - toastWidth) / 2;
        }
      } else if (HybridConnectionList.hybridSplitScreenCount.value > 1) {
        if (index == 1) {
          top = screenSize.height - toastPadding;
          left = halfWidth + (halfWidth - toastWidth) / 2;
        } else {
          top = screenSize.height - toastPadding;
          left = (halfWidth - toastWidth) / 2;
        }
      } else {
        top = screenSize.height - toastPadding;
        left = (screenSize.width - toastWidth) / 2;
      }
    }

    OverlayEntry toast = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        left: left,
        top: top,
        width: toastWidth,
        child: Material(
          color: Colors.transparent,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              // Change the color of the Toast
              color: context.tokens.color.vsdslColorSurface1000,
              // Change the border radius of the Toast
              borderRadius: context.tokens.radii.vsdslRadiusXl,
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
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      color: context.tokens.color.vsdslColorWarning,
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

  void makeBluetoothStateToast(
      BuildContext context, String message, int index, LayerLink layerLink,
      {Color? color, String? icon}) {
    OverlayEntry toast = _buildSplitScreenBluetoothStateToast(
        context, message, index, layerLink, color, icon);

    Overlay.of(context).insert(toast);

    Future.delayed(const Duration(seconds: 3), () {
      toast.remove();
    });
  }

  OverlayEntry _buildSplitScreenBluetoothStateToast(
      BuildContext context,
      String message,
      int index,
      LayerLink layerLink,
      Color? color,
      String? icon) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    OverlayEntry toast = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        left: 0,
        top: 0,
        child: CompositedTransformFollower(
          link: layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, icon == null ? -size.height : -size.height - 50),
          targetAnchor: Alignment.topCenter,
          followerAnchor: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                // Change the color of the Toast
                color: context.tokens.color.vsdslColorSurface1000,
                // Change the border radius of the Toast
                borderRadius: context.tokens.radii.vsdslRadiusXl,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null)
                    SizedBox(
                      width: 16,
                      child: Image(
                        image: Svg(icon),
                      ),
                    ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                  ),
                  V3AutoHyphenatingText(
                    message,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      color: color ?? Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return toast;
  }
}
