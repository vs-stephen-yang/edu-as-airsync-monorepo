import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:flutter/material.dart';

class V3Focus extends StatelessWidget {
  const V3Focus({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.onFocusMove,
    this.label,
    this.identifier,
    this.button = true,
    this.excludeSemantics = true,
    this.trimBorder = false,
  });

  final Widget child;
  final KeyEventResult Function(FocusNode node, KeyEvent event)? onFocusMove;
  final BorderRadius borderRadius;
  final String? label;
  final String? identifier;
  final bool button;
  final bool excludeSemantics;
  final bool trimBorder;

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      onKeyEvent: onFocusMove,
      child: Builder(
        builder: (context) {
          final FocusNode focusNode = Focus.of(context);
          final bool hasFocus = focusNode.hasFocus;
          return Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: borderRadius,
              border: Border.all(
                width: hasFocus && !trimBorder ? 2 : 0,
                color: hasFocus
                    ? context.tokens.color.vsdslColorSecondary
                    : Colors.transparent,
              ),
            ),
            child: Semantics(
              label: label,
              identifier: identifier,
              button: button,
              excludeSemantics: excludeSemantics,
              child: child,
            ),
          );
        },
      ),
    );
  }
}
