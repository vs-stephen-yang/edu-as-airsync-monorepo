import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FocusElevatedButton extends StatefulWidget {
  const FocusElevatedButton(
      {Key? key,
      required this.child,
      this.onClick,
      this.style,
      this.hasFocusTextColor,
      this.notFocusTextColor,
      this.hasFocusBackgroundColor,
      this.notFocusBackgroundColor,
      this.focusAddWidth,
      this.focusAddHeight,
      this.hasFocusWidth,
      this.hasFocusHeight,
      this.notFocusWidth,
      this.notFocusHeight})
      : super(key: key);

  final Widget child;

  final VoidCallback? onClick;

  final ButtonStyle? style;

  final Color? hasFocusTextColor;
  final Color? notFocusTextColor;

  final Color? hasFocusBackgroundColor;
  final Color? notFocusBackgroundColor;

  final double? focusAddWidth;
  final double? focusAddHeight;

  final double? hasFocusWidth;
  final double? hasFocusHeight;

  final double? notFocusWidth;
  final double? notFocusHeight;

  @override
  State createState() => FocusElevatedButtonState();
}

class FocusElevatedButtonState extends State<FocusElevatedButton> {
  late FocusNode _focusNode;
  final _childKey = GlobalKey();
  Size? _childSize;

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
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      if (_childKey.currentContext != null) {
        RenderObject? renderObject =
            _childKey.currentContext!.findRenderObject();
        if (renderObject is RenderBox) {
          RenderBox renderBox = renderObject;
          _childSize = Size(renderBox.size.width, renderBox.size.height);
        }
      }
    });
    return Focus(
      canRequestFocus: false,
      child: Builder(
        builder: (context) {
          final FocusNode focusNode = Focus.of(context);
          final bool hasFocus = focusNode.hasFocus;
          ButtonStyle style = ElevatedButton.styleFrom(
            onPrimary: hasFocus // focus blend color
                ? widget.hasFocusTextColor
                : widget.notFocusTextColor,
            primary: hasFocus // button color
                ? widget.hasFocusBackgroundColor
                : widget.notFocusBackgroundColor,
          );

          double? childWidth, childHeight;
          if (_childSize != null && hasFocus) {
            if (widget.focusAddWidth != null) {
              childWidth = _childSize!.width + widget.focusAddWidth!;
            }
            if (widget.focusAddHeight != null) {
              childHeight = _childSize!.height + widget.focusAddHeight!;
            }
          }
          if (widget.hasFocusWidth != null) {
            if (hasFocus) {
              childWidth = widget.hasFocusWidth;
            } else {
              childWidth = widget.notFocusWidth;
            }
          }
          if (widget.hasFocusHeight != null) {
            if (hasFocus) {
              childHeight = widget.hasFocusHeight;
            } else {
              childHeight = widget.notFocusHeight;
            }
          }
          return SizedBox(
            width: childWidth,
            height: childHeight,
            child: ElevatedButton(
              key: _childKey,
              focusNode: _focusNode,
              child: widget.child,
              style: style.merge(widget.style),
              onPressed: widget.onClick != null
                  ? () {
                      _focusNode.requestFocus();
                      widget.onClick?.call();
                    }
                  : null,
            ),
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
