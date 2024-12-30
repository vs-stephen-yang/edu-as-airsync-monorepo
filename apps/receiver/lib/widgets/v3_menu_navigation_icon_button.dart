import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class V3MenuNavigationIconButton extends StatelessWidget {
  final String enabledIconPath;
  final String? disabledIconPath;
  final bool disabled;
  final VoidCallback? onPressed;
  final BoxConstraints constraints;
  final double iconSize;

  const V3MenuNavigationIconButton({
    super.key,
    required this.enabledIconPath,
    this.disabledIconPath,
    this.disabled = false,
    this.onPressed,
    this.constraints = const BoxConstraints(
      minWidth: 48.0,
      minHeight: 48.0,
    ),
    this.iconSize = 21,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event.logicalKey == LogicalKeyboardKey.enter) {
          onPressed?.call();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: disabled ? null : onPressed,
        child: Container(
          padding: EdgeInsets.zero, // 確保沒有內邊距
          constraints: constraints,
          alignment: Alignment.center, // 保持圖標居中
          child: SvgPicture.asset(
            disabled ? disabledIconPath ?? enabledIconPath : enabledIconPath,
            width: iconSize,
            height: iconSize,
          ),
        ),
      ),
    );
  }
}
