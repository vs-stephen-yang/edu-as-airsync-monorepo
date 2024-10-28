import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class V3NoNetworkStatus extends StatelessWidget {
  const V3NoNetworkStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 540,
      height: 174,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Image(
            width: 126,
            height: 110,
            image: Svg(
              'assets/images/ic_status_no_network.svg',
            ),
          ),
          SizedBox(
            height: context.tokens.spacing.vsdslSpacing4xl.top,
          ),
          AutoSizeText(
            S.of(context).v3_main_status_no_network,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: context.tokens.color.vsdslColorSurface600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
