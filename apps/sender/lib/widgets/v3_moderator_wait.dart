import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/widgets/v3_custom_white_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class V3ModeratorWait extends StatelessWidget {
  const V3ModeratorWait({super.key});

  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider = Provider.of<ChannelProvider>(context);
    bool isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    return Container(
      width: isMobile ? 359 : 504,
      height: isMobile ? 360 : 332,
      decoration: BoxDecoration(
        color: context.tokens.color.vsdswColorSurface100,
        borderRadius: context.tokens.radii.vsdswRadius2xl,
        boxShadow: [
          context.tokens.shadow.vsdswShadowNeutralLg[0],
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isMobile) const WaitingText(),
          SizedBox(
            width: 115,
            height: 115,
            child: Lottie.asset('assets/lottie_files/vsdsl-spinner-sty1.json'),
          ),
          const Padding(padding: EdgeInsets.only(top: 40)),
          if (isMobile) const WaitingText(),
          V3CustomWhiteButton(
              buttonSize: Size(isMobile ? 300 : 240, 48),
              text: S.of(context).v3_main_moderator_disconnect,
              onPressed: () {
                channelProvider.presentEnd();
              }),
        ],
      ),
    );
  }
}

class WaitingText extends StatelessWidget {
  const WaitingText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AutoSizeText(
          S.of(context).v3_main_moderator_wait,
          style: TextStyle(
            color: context.tokens.color.vsdswColorOnSurface,
            fontSize: 16,
          ),
        ),
        const Padding(padding: EdgeInsets.only(top: 32)),
      ],
    );
  }
}
