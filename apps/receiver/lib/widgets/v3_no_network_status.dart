import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class V3NoNetworkStatus extends StatelessWidget {
  const V3NoNetworkStatus({
    super.key,
    this.width = 540,
    this.height = 280,
    this.imageWidth = 126,
    this.imageHeight = 110,
    this.spacing,
    this.textStyle,
  });

  final double width;
  final double height;
  final double imageWidth;
  final double imageHeight;
  final double? spacing;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final defaultSpacing = context.tokens.spacing.vsdslSpacing4xl.top;
    final defaultTextStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: context.tokens.color.vsdslColorOnSurfaceVariant,
    );

    return SizedBox(
      width: width,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/ic_status_no_network.svg',
            excludeFromSemantics: true,
            width: imageWidth,
            height: imageHeight,
          ),
          SizedBox(height: spacing ?? defaultSpacing),
          AutoSizeText(
            S.of(context).v3_main_status_no_network,
            style: textStyle ?? defaultTextStyle,
            textAlign: TextAlign.center,
            maxLines: 5,
          ),
        ],
      ),
    );
  }
}