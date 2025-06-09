import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:flutter/material.dart';

class V3Focus extends StatelessWidget {
  const V3Focus({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.onFocusMove,
    this.label,
    required this.identifier,
    this.button = true,
    this.link = false,
  }) : assert((button == true ? 1 : 0) + (link == true ? 1 : 0) <=
            1); // 只能有一個是 true

  final Widget child;
  final KeyEventResult Function(FocusNode node, KeyEvent event)? onFocusMove;
  final BorderRadius borderRadius;
  final String? label;
  final String identifier;
  final bool button;
  final bool link;

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
                width: 2,
                color: hasFocus
                    ? context.tokens.color.vsdswColorSecondary
                    : Colors.transparent,
              ),
            ),
            child: Semantics(
              label: label,
              identifier: identifier,
              button: button,
              link: link,
              child: child,
            ),
          );
        },
      ),
    );
  }
}
