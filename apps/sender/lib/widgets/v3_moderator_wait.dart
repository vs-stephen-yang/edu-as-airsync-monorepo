import 'dart:io';

import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class V3ModeratorWait extends StatelessWidget {
  const V3ModeratorWait({super.key});

  @override
  Widget build(BuildContext context) {
    ChannelProvider channelProvider = Provider.of<ChannelProvider>(context);
    bool isMobile = Platform.isAndroid || Platform.isIOS;

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
          if (!isMobile) _waitingText(context),
          if (!isMobile) const Padding(padding: EdgeInsets.only(top: 32)),
          SizedBox(
            width: 115,
            height: 115,
            child: Lottie.asset('assets/lottie_files/vsdsl-spinner-sty1.json'),
          ),
          const Padding(padding: EdgeInsets.only(top: 40)),
          if (isMobile) _waitingText(context),
          if (isMobile) const Padding(padding: EdgeInsets.only(top: 32)),
          SizedBox(
              width: isMobile ? 300 : 240,
              height: 48,
              child: InkWell(
                onTap: () {
                  channelProvider.presentEnd();
                },
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
                      'Disconnect',
                      style: TextStyle(
                        color: context.tokens.color.vsdswColorSecondary, // 文字顏色
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Text _waitingText(BuildContext context) {
    return Text(
      'Wait for moderator to invite you to share',
      style: TextStyle(
        color: context.tokens.color.vsdswColorOnSurface,
        fontSize: 16,
      ),
    );
  }
}
