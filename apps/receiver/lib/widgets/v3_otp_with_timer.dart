import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/widgets/v3_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class V3OtpWithTimer extends StatelessWidget {
  const V3OtpWithTimer({
    super.key,
    this.style,
  });

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Consumer<ChannelProvider>(
          builder: (_, channelProvider, __) {
            return ValueListenableBuilder<String>(
              valueListenable: channelProvider.otp,
              builder: (_, otp, __) {
                return Semantics(
                  identifier: 'v3_qa_otp_code',
                  // Trialling is otp code , should not use - to confuse user
                  child: Text(
                    otp,
                    style: style ??
                        context.tokens.textStyle.airsyncFontDisplay.apply(
                          color: context.tokens.color.vsdslColorOnSurface,
                        ),
                  ),
                );
              },
            );
          },
        ),
        const Gap(16),
        const V3CountdownTimer(),
      ],
    );
  }
}
