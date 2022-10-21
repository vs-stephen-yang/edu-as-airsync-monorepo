import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FocusIconButton extends StatefulWidget {
  const FocusIconButton(
      {Key? key,
      required this.child,
      this.onClick,
      this.hasFocusSize,
      this.notFocusSize,
      this.splashRadius,
      this.focusColor})
      : super(key: key);

  final Widget child;

  final VoidCallback? onClick;

  final double? hasFocusSize;
  final double? notFocusSize;

  final double? splashRadius;
  final Color? focusColor;

  @override
  State createState() => FocusIconButtonState();
}

class FocusIconButtonState extends State<FocusIconButton> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      child: Builder(
        builder: (context) {
          final FocusNode focusNode = Focus.of(context);
          final bool hasFocus = focusNode.hasFocus;
          return IconButton(
            focusNode: _focusNode,
            icon: widget.child,
            iconSize: hasFocus ? widget.hasFocusSize : widget.notFocusSize,
            splashRadius: widget.splashRadius,
            focusColor: widget.focusColor,
            onPressed: widget.onClick != null
                ? () {
                    _focusNode.requestFocus();
                    widget.onClick?.call();
                  }
                : null,
          );
        },
      ),
      onKey: (node, event) {
        if (widget.onClick != null) {
          /*if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter) {
              widget.onClick?.call();
              return KeyEventResult.handled;
            }
          } else*/
          if (event is RawKeyUpEvent) {
            if (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter) {
              widget.onClick?.call();
              return KeyEventResult.handled;
            }
          }
        }
        return KeyEventResult.ignored;
      },
    );
  }
}
