import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:flutter/material.dart';

class V3Focus extends StatelessWidget {
  final BorderRadius borderRadius;

  const V3Focus({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.onFocusMove,
  });

  final Widget child;
  final KeyEventResult Function(FocusNode node, KeyEvent event)? onFocusMove;

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
                    ? context.tokens.color.vsdslColorSecondary
                    : Colors.transparent,
              ),
            ),
            child: child,
          );
        },
      ),
    );
  }
}
