import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:display_flutter/providers/connectivity_provider.dart';
import 'package:display_flutter/providers/multi_window_provider.dart';
import 'package:display_flutter/screens/debug_switch.dart';
import 'package:display_flutter/widgets/v3_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class V3HeaderBar extends StatefulWidget {
  const V3HeaderBar({super.key, this.isWaitForStream = false});

  final bool isWaitForStream;

  @override
  State<StatefulWidget> createState() => _V3HeaderBarState();
}

class _V3HeaderBarState extends State<V3HeaderBar> {
  int debugCounter = 0;
  final int openDebugCounter = 5;

  @override
  Widget build(BuildContext context) {
    final ratio = context.splitScreenRatio;
    final isMultiWindow = context.isInMultiWindow;
    final isCompact = isMultiWindow &&
        ratio.widthFraction <= SplitScreenRatio.launcherFull.widthFraction;
    final padding = _calculatePadding(ratio);
    final hide = context.watch<ConnectivityProvider>().connectionStatus ==
            ConnectivityResult.none &&
        ratio == SplitScreenRatio.oneThirdFull;
    if (hide) {
      return const SizedBox();
    }
    final logo = GestureDetector(
      excludeFromSemantics: true,
      onTap: _handleDebugTap,
      child: buildAirsyncIcon(ratio),
    );

    final logoText = _buildLogoText(context, ratio);

    final content = Padding(
      padding: EdgeInsets.only(
          top: padding.vertical,
          left: padding.horizontal,
          right: padding.horizontal),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [logo, logoText],
          ),
          Expanded(
            child: !widget.isWaitForStream && !isCompact && !context.isLessThanOneThird
                ? const V3Status()
                : const SizedBox(),
          ),
        ],
      ),
    );

    return !isCompact
        ? Positioned(
            left: padding.horizontal,
            top: padding.vertical,
            right: padding.horizontal,
            child: content,
          )
        : content;
  }

  void _handleDebugTap() {
    debugCounter++;
    if (debugCounter >= openDebugCounter) {
      _showMenuDialog(const DebugSwitch());
      debugCounter = 0;
    }
  }

  Widget _buildLogoText(BuildContext context, SplitScreenRatio ratio) {
    const String assetPath = 'assets/images/ic_logo_airsync_text.svg';
    final color = widget.isWaitForStream ? Colors.white : Colors.black;
    final inLauncher = ratio == SplitScreenRatio.launcher;
    final logoText = Row(
      children: [
        const Padding(padding: EdgeInsets.only(left: 7)),
        SvgPicture.asset(
          assetPath,
          excludeFromSemantics: true,
          height: inLauncher ? 15 : 31,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      ],
    );

    return MultiWindowAdaptiveLayout(
      launcher: logoText,
      landscape: logoText,
      landscapeOneThird: const SizedBox(),
      floatingDefault: const SizedBox(),
      landscapeHalf: const SizedBox(),
      landscapeTwoThirds: const SizedBox(),
      launcherMain: const SizedBox(),
    );
  }

  Widget buildAirsyncIcon(SplitScreenRatio ratio) {
    double size;
    switch (ratio) {
      case SplitScreenRatio.launcher:
      case SplitScreenRatio.launcherFull:
        size = 18;
        break;
      case SplitScreenRatio.floatingDefault:
        size = 25;
        break;
      default:
        size = 36;
    }

    return SvgPicture.asset(
      'assets/images/ic_logo_airsync_icon.svg',
      excludeFromSemantics: true,
      width: size,
      height: size,
    );
  }

  _Padding _calculatePadding(SplitScreenRatio ratio) {
    final isCompact = context.isInMultiWindow &&
        ratio.widthFraction <= SplitScreenRatio.floatingDefault.widthFraction;

    final double horizontal = isCompact
        ? (ratio.widthFraction == SplitScreenRatio.launcher.widthFraction
            ? 15.3
            : 32.0)
        : 25.0;

    final double vertical = isCompact
        ? (ratio.widthFraction == SplitScreenRatio.launcher.widthFraction
            ? 15.3
            : 32.0)
        : 25.0;

    return _Padding(horizontal, vertical);
  }

  Future<void> _showMenuDialog(Widget widget) async {
    FocusScope.of(context).unfocus();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => widget,
    );
    if (!mounted) return;
    setState(() {}); // 確保切換 debug 後能刷新畫面
  }
}

class _Padding {
  final double horizontal;
  final double vertical;

  const _Padding(this.horizontal, this.vertical);
}
