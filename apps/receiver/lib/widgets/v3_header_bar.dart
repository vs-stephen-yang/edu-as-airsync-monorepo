import 'package:display_flutter/providers/multi_window_provider.dart';
import 'package:display_flutter/screens/debug_switch.dart';
import 'package:display_flutter/widgets/v3_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
        ratio.widthFraction <= SplitScreenRatio.floatingDefault.widthFraction;

    final padding = _calculatePadding(ratio);

    final logo = GestureDetector(
      excludeFromSemantics: true,
      onTap: _handleDebugTap,
      child: buildAirsyncIcon(ratio),
    );

    final logoText = _buildLogoText(context, ratio, isCompact);

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
            child: !widget.isWaitForStream && !isCompact
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

  Widget _buildLogoText(
      BuildContext context, SplitScreenRatio ratio, bool isCompact) {
    const String assetPath = 'assets/images/ic_logo_airsync_text.svg';
    final color = widget.isWaitForStream ? Colors.white : Colors.black;

    if (isCompact) {
      final width = ratio == SplitScreenRatio.launcher ? 55.133 : 100.0;
      final height = ratio == SplitScreenRatio.launcher ? 12.133 : 24.0;
      return Row(
        children: [
          const Padding(padding: EdgeInsets.only(left: 3.03)),
          SvgPicture.asset(
            assetPath,
            excludeFromSemantics: true,
            width: width,
            height: height,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ],
      );
    } else if (ratio == SplitScreenRatio.twoThirds ||
        !context.isInMultiWindow) {
      return Row(
        children: [
          const Padding(padding: EdgeInsets.only(left: 7)),
          SvgPicture.asset(
            assetPath,
            excludeFromSemantics: true,
            width: 140,
            height: 31,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ],
      );
    }
    return const SizedBox();
  }

  Widget buildAirsyncIcon(SplitScreenRatio ratio) {
    double size;
    switch (ratio) {
      case SplitScreenRatio.launcher:
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

    final double horizontal =
        isCompact ? (ratio == SplitScreenRatio.launcher ? 15.3 : 32.0) : 25.0;

    final double vertical =
        isCompact ? (ratio == SplitScreenRatio.launcher ? 15.3 : 32.0) : 25.0;

    return _Padding(horizontal, vertical);
  }

  Future<void> _showMenuDialog(Widget widget) async {
    FocusScope.of(context).unfocus();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => widget,
    );
    setState(() {}); // 確保切換 debug 後能刷新畫面
  }
}

class _Padding {
  final double horizontal;
  final double vertical;

  const _Padding(this.horizontal, this.vertical);
}
