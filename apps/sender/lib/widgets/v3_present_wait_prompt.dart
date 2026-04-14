import 'dart:io';

import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_cast_flutter/widgets/v3_custom_white_button.dart';
import 'package:display_cast_flutter/widgets/v3_scroll_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class V3PresentWaitPrompt extends StatelessWidget {
  const V3PresentWaitPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider = Provider.of<ChannelProvider>(context);
    bool isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    final sc = ScrollController();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? 359 : 504,
            maxHeight: isMobile ? 360 : 332,
          ),
          decoration: BoxDecoration(
            color: context.tokens.color.vsdswColorSurface100,
            borderRadius: context.tokens.radii.vsdswRadius2xl,
            boxShadow: [
              context.tokens.shadow.vsdswShadowNeutralLg[0],
            ],
          ),
          child: Center(
            child: V3Scrollbar(
              controller: sc,
              mainAxisMargin: 10,
              child: SingleChildScrollView(
                controller: sc,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isMobile)
                      WaitingText(isModerator: channelProvider.moderatorStatus),
                    SizedBox(
                      width: 115,
                      height: 115,
                      child: Lottie.asset(
                          'assets/lottie_files/vsdsl-spinner-sty1.json'),
                    ),
                    const Padding(padding: EdgeInsets.only(top: 40)),
                    if (isMobile)
                      WaitingText(isModerator: channelProvider.moderatorStatus),
                    if (!channelProvider.moderatorStatus)
                      Container(
                        width: isMobile ? 300 : 240,
                        height: 48,
                        alignment: Alignment.center,
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
                        // To avoid misinterpreting the hyphen (“-”), use plain text instead.
                        child: Text(
                          channelProvider.randomName,
                          style: TextStyle(
                            color: context.tokens.color.vsdswColorOnSurface,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    if (channelProvider.moderatorStatus)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: V3CustomWhiteButton(
                          label: S.of(context).v3_lbl_moderator_disconnect,
                          identifier: 'v3_qa_moderator_disconnect',
                          buttonSize: Size(isMobile ? 300 : 240, 50),
                          text: S.of(context).v3_main_moderator_disconnect,
                          onPressed: () {
                            trackEvent(
                                'click_disconnect', EventCategory.session);
                            channelProvider.presentEnd();
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class WaitingText extends StatelessWidget {
  const WaitingText({super.key, this.isModerator = true});

  final bool isModerator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          V3AutoHyphenatingText(
            isModerator
                ? S.of(context).v3_main_moderator_wait
                : S.of(context).v3_main_authorize_wait,
            style: TextStyle(
              color: context.tokens.color.vsdswColorOnSurface,
              fontSize: 16,
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 32)),
        ],
      ),
    );
  }
}
