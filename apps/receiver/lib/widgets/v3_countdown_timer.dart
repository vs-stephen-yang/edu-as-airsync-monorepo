import 'dart:math' as math;

import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class V3CountdownTimer extends StatelessWidget {
  const V3CountdownTimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChannelProvider>(
      builder: (_, channelProvider, __) {
        return ValueListenableBuilder<int>(
          valueListenable: channelProvider.countDownProgress,
          builder: (_, progress, __) {
            return ValueListenableBuilder(
              valueListenable: AppPreferences().textSizeOptionNotifier,
              builder: (context, _, __) {
                return Container(
                  height: 45 * AppPreferences().textScale,
                  width: 40,
                  alignment: Alignment.bottomCenter,
                  margin: EdgeInsets.only(
                    left: context.tokens.spacing.vsdslSpacingMd.left,
                  ),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(math.pi),
                    child: SizedBox(
                      width: 27,
                      height: 27,
                      child: CircularProgressIndicator(
                        value: progress / channelProvider.maxCountDown,
                        strokeWidth: 4,
                        backgroundColor: const Color(0xFFE9EAF0),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF636D8A),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
