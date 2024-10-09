import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class V3BackButton extends StatelessWidget {
  const V3BackButton(
      {super.key, this.isDarkTheme = false, required this.onPressed});

  final bool isDarkTheme;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: IconButton(
        icon: SvgPicture.asset(isDarkTheme
            ? 'assets/images/v3_ic_arrow_back_white.svg'
            : 'assets/images/v3_ic_arrow_back.svg'),
        onPressed: onPressed,
      ),
    );
  }
}
