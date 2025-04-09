import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/widgets/v3_focus.dart';
import 'package:flutter/material.dart';

class V3CustomWhiteButton extends StatelessWidget {
  const V3CustomWhiteButton({
    super.key,
    required this.buttonSize,
    required this.text,
    required this.onPressed,
    required this.label,
    required this.identifier,
  });

  final Size buttonSize;
  final String text;
  final GestureTapCallback? onPressed;
  final String label;
  final String identifier;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: buttonSize.width,
        height: buttonSize.height,
        child: V3Focus(
          label: label,
          identifier: identifier,
          child: InkWell(
            onTap: onPressed,
            child: Container(
              decoration: BoxDecoration(
                  color: context.tokens.color.vsdswColorSurface100,
                  border: Border.all(
                    color: context.tokens.color.vsdswColorSecondary,
                    width: 1,
                  ),
                  borderRadius: context.tokens.radii.vsdswRadiusFull,
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0.0, 8.0),
                      blurRadius: 16.0,
                      spreadRadius: 0.0,
                      color: context.tokens.color.vsdswColorSecondary
                          .withOpacity(0.2),
                    ),
                  ]),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    color: context.tokens.color.vsdswColorSecondary, // 文字顏色
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
