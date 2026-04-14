import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/widgets/V3_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class V3BackButton extends StatelessWidget {
  const V3BackButton({
    super.key,
    this.isDarkTheme = false,
    required this.onPressed,
    this.label,
    required this.identifier,
  });

  final bool isDarkTheme;
  final VoidCallback? onPressed;

  final String? label;
  final String identifier;

  @override
  Widget build(BuildContext context) {
    return V3Focus(
      label: label,
      identifier: identifier,
      child: InkWell(
        onTap: onPressed,
        splashColor: Colors.transparent,
        child: Container(
          width: 48,
          height: 48,
          decoration: ShapeDecoration(
            color: isDarkTheme
                ? context.tokens.color.vsdswColorSurface900
                : context.tokens.color.vsdswColorSurface100,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: isDarkTheme
                    ? context.tokens.color.vsdswColorSurface900
                    : context.tokens.color.vsdswColorNeutralInverse,
              ),
              borderRadius: context.tokens.radii.vsdswRadiusFull,
            ),
            shadows: context.tokens.shadow.vsdswShadowNeutralLg,
          ),
          child: Center(
            child: ExcludeSemantics(
              child: SvgPicture.asset(
                isDarkTheme
                    ? 'assets/images/v3_ic_arrow_back_white.svg'
                    : 'assets/images/v3_ic_arrow_back.svg',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
