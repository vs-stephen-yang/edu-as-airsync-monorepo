import 'package:display_flutter/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FocusIconButton extends StatefulWidget {
  const FocusIconButton(
      {super.key,
      this.icons,
      this.svgSource,
      this.childHasFocus,
      this.childNotFocus,
      this.onClick,
      this.hasFocusSize,
      this.notFocusSize,
      this.splashRadius,
      this.focusColor,
      this.iconForegroundColor,
      this.iconBackgroundColor,
      this.iconFocusForegroundColor,
      this.iconFocusBackgroundColor,
      this.isAddGreenDot = false,
      this.rotateX = 0.0,
      this.rotateY = 0.0});

  final IconData? icons;
  final ImageProvider? svgSource;
  final Widget? childHasFocus;
  final Widget? childNotFocus;

  final VoidCallback? onClick;

  final double? hasFocusSize;
  final double? notFocusSize;

  final double? splashRadius;
  final Color? focusColor;

  final Color? iconForegroundColor;
  final Color? iconBackgroundColor;

  final Color? iconFocusForegroundColor;
  final Color? iconFocusBackgroundColor;

  final bool isAddGreenDot;
  final double rotateX;
  final double rotateY;

  @override
  State createState() => _FocusIconButtonState();
}

class _FocusIconButtonState extends State<FocusIconButton> {
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
          double? iconSize;
          if (hasFocus) {
            if (widget.hasFocusSize != null) {
              iconSize = widget.hasFocusSize! - 12; // reduce size for padding.
            }
          } else {
            if (widget.notFocusSize != null) {
              iconSize = widget.notFocusSize! - 12; // reduce size for padding.
            }
          }
          Matrix4 matrix4 = Matrix4.identity();
          matrix4.rotateX(widget.rotateX);
          matrix4.rotateY(widget.rotateY);
          return IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            focusNode: _focusNode,
            icon: (widget.icons != null || widget.svgSource != null)
                ? Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: hasFocus
                          ? widget.iconFocusBackgroundColor ??
                              widget.iconBackgroundColor
                          : widget.iconBackgroundColor,
                    ),
                    child: Stack(
                      children: [
                        Transform(
                          alignment: Alignment.center,
                          transform: matrix4,
                          child: widget.icons != null
                              ? Icon(
                                  widget.icons,
                                  color: hasFocus
                                      ? widget.iconFocusForegroundColor ??
                                          widget.iconForegroundColor
                                      : widget.iconForegroundColor,
                                  size: iconSize,
                                )
                              : Image(
                                  image: widget.svgSource!,
                                  color: hasFocus
                                      ? widget.iconFocusForegroundColor ??
                                          widget.iconForegroundColor
                                      : widget.iconForegroundColor,
                                  width: iconSize,
                                  height: iconSize,
                                ),
                        ),
                        if (widget.isAddGreenDot)
                          const Positioned(
                            top: 0,
                            right: 0,
                            child: SizedBox(
                              width: 10,
                              height: 10,
                              child: CircleAvatar(
                                backgroundColor:
                                    AppColors.iconFeatureOnGreenDot,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : hasFocus
                    ? widget.childHasFocus ??
                        widget.childNotFocus ??
                        const SizedBox()
                    : widget.childNotFocus ?? const SizedBox(),
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
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (widget.onClick != null) {
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            if (event is KeyUpEvent) {
              widget.onClick?.call();
            }
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
    );
  }
}
