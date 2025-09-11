import 'package:auto_hyphenating_text/auto_hyphenating_text.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/widgets/v3_display_code.dart';
import 'package:display_flutter/widgets/v3_instruction.dart';
import 'package:display_flutter/widgets/v3_main_connection_info.dart';
import 'package:display_flutter/widgets/v3_main_qr_code_area.dart';
import 'package:display_flutter/widgets/v3_otp_with_timer.dart';
import 'package:display_flutter/widgets/v3_participants_view.dart';
import 'package:display_flutter/widgets/v3_qrcode_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../providers/multi_window_provider.dart';

/// Landscape layout manager for multi-window adaptive display
///
/// Automatically switches between different layouts based on screen split ratio:
/// - Full screen: Connection info (5/7) + Divider + Participants (2/7)
/// - 2/3 screen: Connection info only
/// - 1/2 screen: Simplified connection info (no download step, no icons)
/// - 1/3 screen: Minimal layout (vertical stack, QR code in scroll area)
class V3MainInfoLandscape extends StatelessWidget {
  const V3MainInfoLandscape({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiWindowAdaptiveLayout(
      launcher: V3MainConnectionInfoLauncher(),
      launcherFull: V3MainConnectionInfoLauncher(),
      landscapeOneThird: V3MainConnectionInfoOneThird(),
      launcherMain: V3MainConnectionInfoLauncherMain(),
      floatingDefault: V3MainConnectionInfoFloatingDefault(),
      landscapeHalf: V3MainConnectionInfoHalf(),
      landscapeTwoThirds: V3MainConnectionInfo(),
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
    );
  }
}

class V3MainConnectionInfoHalf extends StatefulWidget {
  const V3MainConnectionInfoHalf({super.key});

  @override
  State<V3MainConnectionInfoHalf> createState() =>
      _V3MainConnectionInfoHalfState();
}

class _V3MainConnectionInfoHalfState extends State<V3MainConnectionInfoHalf> {
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
              child: Row(
                children: [
                  Expanded(
                    child: V3MainInstructionArea(
                      scrollController: _scrollController,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          V3InstructionHeader(
                            isCastToDevice: false,
                            isQuickConnect: false,
                          ),
                          V3InstructionDisplayCode(showIcon: false),
                          SizedBox(
                              height:
                                  context.tokens.spacing.vsdslSpacing3xl.top),
                          V3InstructionOtpCode(showIcon: false),
                        ],
                      ),
                    ),
                  ),
                  const V3MainQrCodeArea(),
                ],
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
              child: V3MainInstructionArea(
                scrollController: _scrollController,
                child: Column(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        V3InstructionStep(
                          showIcon: false,
                          textContent: AutoHyphenatingText(
                            S.of(context).v3_instruction2_onethird,
                            style:
                                context.tokens.textStyle.airsyncFontTitle.apply(
                              color: context.tokens.color.vsdslColorOnSurface,
                            ),
                            maxLines: 6,
                          ),
                          actionWidget: const V3DisplayCode(),
                          actionPadding: EdgeInsets.zero,
                        ),
                        SizedBox(
                            height: context.tokens.spacing.vsdslSpacing3xl.top),
                        V3InstructionStep(
                          showIcon: false,
                          textContent: AutoHyphenatingText(
                            S.of(context).v3_instruction3_onethird,
                            style:
                                context.tokens.textStyle.airsyncFontTitle.apply(
                              color: context.tokens.color.vsdslColorOnSurface,
                            ),
                          ),
                          actionWidget: const V3OtpWithTimer(),
                          actionPadding: EdgeInsets.only(
                            top: context.tokens.spacing.vsdslSpacingXl.top,
                          ),
                        ),
                      ],
                    ),
                    const V3MainQrCodeArea(),
                  ],
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

class V3MainConnectionInfoLauncherMain extends StatefulWidget {
  const V3MainConnectionInfoLauncherMain({super.key});

  @override
  State<V3MainConnectionInfoLauncherMain> createState() =>
      _V3MainConnectionInfoLauncherMainState();
}

class _V3MainConnectionInfoLauncherMainState
    extends State<V3MainConnectionInfoLauncherMain> {
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
        return V3MainInstructionArea(
          topPadding: 26.66,
          scrollController: _scrollController,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    V3InstructionStep(
                      showIcon: false,
                      textContent: AutoHyphenatingText(
                        S.of(context).v3_instruction2_onethird,
                        style: context.tokens.textStyle.airsyncFontTitle.apply(
                          color: context.tokens.color.vsdslColorOnSurface,
                        ),
                        maxLines: 6,
                      ),
                      actionWidget: const V3DisplayCode(),
                      actionPadding: EdgeInsets.zero,
                    ),
                    SizedBox(
                        height: context.tokens.spacing.vsdslSpacing3xl.top),
                    V3InstructionStep(
                      showIcon: false,
                      textContent: AutoHyphenatingText(
                        S.of(context).v3_instruction3_onethird,
                        style: context.tokens.textStyle.airsyncFontTitle.apply(
                          color: context.tokens.color.vsdslColorOnSurface,
                        ),
                      ),
                      actionWidget: const V3OtpWithTimer(),
                      actionPadding: EdgeInsets.only(
                        top: context.tokens.spacing.vsdslSpacingXl.top,
                      ),
                    ),
                    const Gap(10),
                    const V3MainInstructionSection(
                      horizontalPadding: 0,
                      verticalPadding: 0,
                    ),
                    const Gap(26.66),
                  ],
                ),
              ),
              const V3MainQrCodeArea(),
            ],
          ),
        );
      },
    );
  }
}

class V3MainConnectionInfoLauncher extends StatelessWidget {
  const V3MainConnectionInfoLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return const _V3MainConnectionInfoSmall(
      leftPadding: 16,
      titleFontSize: 10.66,
      actionFontSize: 18.66,
      topGap: 10.66,
      qrSize: 69.33,
      qrPadding: 6,
    );
  }
}

class V3MainConnectionInfoFloatingDefault extends StatelessWidget {
  const V3MainConnectionInfoFloatingDefault({super.key});

  @override
  Widget build(BuildContext context) {
    return const _V3MainConnectionInfoSmall(
      leftPadding: 32,
      titleFontSize: 10.66 * 2,
      actionFontSize: 18.66 * 2,
      topGap: 10.66 * 2,
      qrSize: 69.66 * 2,
      qrPadding: 16,
    );
  }
}

class _V3MainConnectionInfoSmall extends StatefulWidget {
  const _V3MainConnectionInfoSmall({
    required this.leftPadding,
    required this.titleFontSize,
    required this.actionFontSize,
    required this.topGap,
    required this.qrSize,
    required this.qrPadding,
  });

  final double leftPadding;
  final double titleFontSize;
  final double actionFontSize;
  final double topGap;
  final double qrSize;
  final double qrPadding;

  @override
  State<_V3MainConnectionInfoSmall> createState() =>
      _V3MainConnectionInfoSmallState();
}

class _V3MainConnectionInfoSmallState
    extends State<_V3MainConnectionInfoSmall> {
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
    final color = context.tokens.color.vsdslColorOnSurface;

    return V3MainInstructionArea(
      topPadding: 0,
      leftPadding: widget.leftPadding,
      scrollController: _scrollController,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Gap(widget.topGap),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    V3InstructionStep(
                      showIcon: false,
                      textContent: AutoHyphenatingText(
                        S.of(context).v3_instruction2_onethird,
                        style: context.tokens.textStyle.airsyncFontTitle
                            .copyWith(fontSize: widget.titleFontSize)
                            .apply(color: color),
                        maxLines: 6,
                      ),
                      actionWidget: V3DisplayCode(
                        style: context.tokens.textStyle.airsyncFontDisplay
                            .copyWith(fontSize: widget.actionFontSize)
                            .apply(color: color),
                      ),
                      actionPadding: EdgeInsets.zero,
                    ),
                    Gap(widget.topGap),
                    V3InstructionStep(
                      showIcon: false,
                      textContent: AutoHyphenatingText(
                        S.of(context).v3_instruction3_onethird,
                        style: context.tokens.textStyle.airsyncFontTitle
                            .copyWith(fontSize: widget.titleFontSize)
                            .apply(color: color),
                      ),
                      actionWidget: V3OtpWithTimer(
                        style: context.tokens.textStyle.airsyncFontDisplay
                            .copyWith(fontSize: widget.actionFontSize)
                            .apply(color: color),
                      ),
                      actionPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: widget.qrSize,
            height: widget.qrSize,
            child: V3QrCodeImage(
              isShowBackground: true,
              size: widget.qrSize,
              backgroundPadding: widget.qrPadding,
            ),
          ),
          Gap(16),
        ],
      ),
    );
  }
}
