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
  final FocusNode? focusNode;

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
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyUpEvent) {
          return KeyEventResult.handled;
        }

        if (event.logicalKey == LogicalKeyboardKey.select ||
            event.logicalKey == LogicalKeyboardKey.enter) {
          onPressed?.call();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        onTap: disabled ? null : onPressed,
        focusNode: focusNode,
        child: Container(
          padding: EdgeInsets.zero,
          constraints: constraints,
          alignment: Alignment.center,
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
