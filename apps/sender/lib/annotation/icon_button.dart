


import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

class AnnotationIconButton extends StatelessWidget {
  const AnnotationIconButton(
      {super.key,
        this.onPressed,
        required this.icon,
        this.size = 36,
        this.enable = true,
        this.circleStyle = false,
        this.selected = false,
        this.iconSize,});

  final String icon;
  final VoidCallback? onPressed;
  final bool selected;
  final bool enable;
  final bool circleStyle;
  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    bool tapDown = false;
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return GestureDetector(
          onTapDown: (_) {
            setState(() {
              tapDown = true;
            });
          },
          onTapUp: (_) {
            setState(() {
              tapDown = false;
            });
          },
          onTapCancel: () {
            setState(() {
              tapDown = false;
            });
          },
          onTap: onPressed,
          child: Opacity(
            opacity: enable ? 1 : 0.32,
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: (tapDown || selected) ? const Color(0xFF5D80ED) : null,
                shape: RoundedRectangleBorder(
                    borderRadius: circleStyle
                        ? BorderRadius.circular(24)
                        : BorderRadius.circular(16)),
              ),
              child: SvgPicture.asset(
                icon,
                fit: BoxFit.scaleDown,
                width: iconSize ?? size,
                height: iconSize ?? size,
              ),
            ),
          ),
        );
      },
    );
  }
}