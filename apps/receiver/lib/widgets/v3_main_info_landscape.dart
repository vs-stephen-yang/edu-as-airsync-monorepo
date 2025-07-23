import 'dart:math' as math;

import 'package:auto_hyphenating_text/auto_hyphenating_text.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:display_flutter/providers/multi_window_provider.dart';
import 'package:display_flutter/widgets/v3_main_connection_info.dart';
import 'package:display_flutter/widgets/v3_main_instruction_section.dart';
import 'package:display_flutter/widgets/v3_main_qr_code_area.dart';
import 'package:display_flutter/widgets/v3_participants_view.dart';
import 'package:display_flutter/widgets/v3_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

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
                        const V3InstructionOneThird(),
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

class V3InstructionOneThird extends StatelessWidget {
  const V3InstructionOneThird({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AutoHyphenatingText(
          S.of(context).v3_instruction2,
          style: context.tokens.textStyle.airsyncFontTitle.apply(
            color: context.tokens.color.vsdslColorOnSurface,
          ),
          maxLines: 6,
        ),
        Consumer<InstanceInfoProvider>(builder: (_, instanceInfoProvider, __) {
          return Semantics(
            identifier: 'v3_qa_display_code',
            // Trialling is display code, should not use - to confuse user
            child: Text(
              _getDisplayCodeVisualIdentity(instanceInfoProvider.displayCode),
              style: context.tokens.textStyle.airsyncFontDisplay.apply(
                color: context.tokens.color.vsdslColorOnSurface,
              ),
            ),
          );
        }),
        SizedBox(height: context.tokens.spacing.vsdslSpacing3xl.top),
        AutoHyphenatingText(
          S.of(context).v3_instruction3,
          style: context.tokens.textStyle.airsyncFontTitle.apply(
            color: context.tokens.color.vsdslColorOnSurface,
          ),
        ),
        SizedBox(height: context.tokens.spacing.vsdslSpacingXl.top),
        Wrap(
          children: [
            Consumer<ChannelProvider>(builder: (_, channelProvider, __) {
              return ValueListenableBuilder<String>(
                valueListenable: channelProvider.otp,
                builder: (_, otp, __) {
                  return Semantics(
                    identifier: 'v3_qa_otp_code',
                    // Trialling is otp code , should not use - to confuse user
                    child: Text(
                      otp,
                      style: context.tokens.textStyle.airsyncFontDisplay.apply(
                        color: context.tokens.color.vsdslColorOnSurface,
                      ),
                    ),
                  );
                },
              );
            }),
            const Gap(16),
            Consumer<ChannelProvider>(builder: (_, channelProvider, __) {
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
                              left: context.tokens.spacing.vsdslSpacingMd.left),
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
                                    Color(0xFF636D8A)),
                              ),
                            ),
                          ),
                        );
                      });
                },
              );
            }),
          ],
        ),
      ],
    );
  }

  String _getDisplayCodeVisualIdentity(String displayCode) {
    String result = displayCode;
    if (displayCode.length > 5) {
      // https://stackoverflow.com/a/56845471/13160681
      result = displayCode
          .replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)} ")
          .trimRight();
    }
    return result;
  }
}
