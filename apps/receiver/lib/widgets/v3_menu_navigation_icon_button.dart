import 'package:display_flutter/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class V3MenuNavigationIconButton extends StatelessWidget {
  final String enabledIconPath;
  final String? disabledIconPath;
  final bool disabled;
  final VoidCallback? onPressed;
  final BoxConstraints constraints;
  final double iconSize;
  final FocusNode? focusNode;
  final String? label;
  final String? identifier;

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
    this.label,
    this.identifier,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(builder: (_, settingsProvider, __) {
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

          return settingsProvider.onSubFocusMove(node, event);
        },
        child: Semantics(
          label: label,
          identifier: identifier,
          child: InkWell(
            excludeFromSemantics: true,
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
                disabled
                    ? disabledIconPath ?? enabledIconPath
                    : enabledIconPath,
                width: iconSize,
                height: iconSize,
              ),
            ),
          ),
        ),
      );
    });
  }
}
