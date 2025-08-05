import 'package:auto_hyphenating_text/auto_hyphenating_text.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/widgets/v3_display_code.dart';
import 'package:display_flutter/widgets/v3_main_connection_info.dart';
import 'package:display_flutter/widgets/v3_main_qr_code_area.dart';
import 'package:display_flutter/widgets/v3_otp_with_timer.dart';
import 'package:display_flutter/widgets/v3_participants_view.dart';
import 'package:display_flutter/widgets/v3_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../providers/multi_window_provider.dart';

class V3MainInfoLandscape extends StatelessWidget {
  const V3MainInfoLandscape({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiWindowAdaptiveLayout(
      landscape: Row(
        children: [
          Expanded(
            flex: 5,
            child: const V3MainConnectionInfo(),
          ),
          Container(
            width: 1,
            color: context.tokens.color.vsdslColorOutline,
          ),
          Expanded(
            flex: 2,
            child: const V3ParticipantsView(),
          ),
        ],
      ),
      landscapeTwoThirds: V3MainConnectionInfo(),
      landscapeHalf: V3MainConnectionInfo(),
      landscapeOneThird: V3MainConnectionInfoOneThird(),
    );
  }
}

class V3MainConnectionInfoOneThird extends StatefulWidget {
  const V3MainConnectionInfoOneThird({super.key});

  @override
  State<V3MainConnectionInfoOneThird> createState() =>
      _V3MainConnectionInfoOneThirdState();
}

class _V3MainConnectionInfoOneThirdState
    extends State<V3MainConnectionInfoOneThird> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppPreferences().textSizeOptionNotifier,
      builder: (context, value, child) {
        return Column(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 13.3,
                  top: 20.0,
                  bottom: 10,
                ),
                child: V3Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    controller: _scrollController,
                    child: Column(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AutoHyphenatingText(
                              S.of(context).v3_instruction2,
                              style: context.tokens.textStyle.airsyncFontTitle
                                  .apply(
                                color: context.tokens.color.vsdslColorOnSurface,
                              ),
                              maxLines: 6,
                            ),
                            const V3DisplayCode(),
                            SizedBox(
                                height:
                                    context.tokens.spacing.vsdslSpacing3xl.top),
                            AutoHyphenatingText(
                              S.of(context).v3_instruction3,
                              style: context.tokens.textStyle.airsyncFontTitle
                                  .apply(
                                color: context.tokens.color.vsdslColorOnSurface,
                              ),
                            ),
                            SizedBox(
                                height:
                                    context.tokens.spacing.vsdslSpacingXl.top),
                            const V3OtpWithTimer(),
                          ],
                        ),
                        const V3MainQrCodeArea(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const V3MainInstructionSection(),
            const Gap(30.0),
          ],
        );
      },
    );
  }
}
