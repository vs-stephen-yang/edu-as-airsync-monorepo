import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/text_scale_option.dart';
import 'package:display_flutter/providers/connectivity_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/widgets/v3_instruction.dart';
import 'package:display_flutter/widgets/v3_no_network_status.dart';
import 'package:display_flutter/widgets/v3_participants_view.dart';
import 'package:display_flutter/widgets/v3_qrcode_quick_connect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class V3MainInfo extends StatelessWidget {
  const V3MainInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isLandscape = constraints.maxWidth > constraints.maxHeight;

      return Container(
        alignment: Alignment.center,
        margin: isLandscape
            ? const EdgeInsets.symmetric(vertical: 106, horizontal: 53)
            : const EdgeInsets.symmetric(vertical: 120, horizontal: 29),
        decoration: _buildContainerDecoration(context),
        child: Consumer<ConnectivityProvider>(
            builder: (_, connectivityProvider, __) {
          return connectivityProvider.connectionStatus ==
                  ConnectivityResult.none
              ? const V3NoNetworkStatus()
              : isLandscape
                  ? _buildLandscapeContent(context)
                  : _buildPortraitContent(context);
        }),
      );
    });
  }

  ShapeDecoration _buildContainerDecoration(BuildContext context) {
    return ShapeDecoration(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        side: BorderSide(
          width: 1,
          color: context.tokens.color.vsdslColorOutline,
        ),
      ),
      color: context.tokens.color.vsdslColorSurface100.withOpacity(0.84),
    );
  }

  Widget _buildLandscapeContent(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            child: _landscapeContent(context),
          ),
        ),
        Container(
          width: 1,
          color: context.tokens.color.vsdslColorOutline,
        ),
        Expanded(
          flex: 2,
          child: const SizedBox(
            child: V3ParticipantsView(),
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitContent(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _portraitContent(context),
        ),
        Container(
          height: 1,
          color: context.tokens.color.vsdslColorOutline,
        ),
        const Expanded(
          child: V3ParticipantsView(isLandscape: false),
        ),
      ],
    );
  }

  Widget _portraitContent(BuildContext context) {
    // 創建 ScrollController
    final ScrollController scrollController = ScrollController();
    return ValueListenableBuilder<int>(
      valueListenable: AppPreferences().textSizeOptionNotifier,
      builder: (context, value, child) {
        final textSizeOption = ResizeTextSizeOption.fromValue(value);
        return Stack(
          children: [
            Container(
              padding: EdgeInsets.all(50),
              child: Scrollbar(
                controller: scrollController, // 使用 ScrollController
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: scrollController, // 使用相同的 ScrollController
                  child: Column(
                    children: [
                      const V3Instruction(isCastToDevice: false),
                      _buildInstructionRow(context),
                      _buildMiracastInstructionRow(context),
                    ],
                  ),
                ),
              ),
            ),
            if (textSizeOption == ResizeTextSizeOption.normal)
              Positioned(
                bottom: 40,
                top: null,
                right: 29,
                child: Container(
                  width: 171,
                  decoration: _buildQrCodeDecoration(context),
                  child: const V3QrCodeQuickConnect(),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _landscapeContent(BuildContext context) {
    // 創建 ScrollController
    final ScrollController scrollController = ScrollController();

    return ValueListenableBuilder<int>(
      valueListenable: AppPreferences().textSizeOptionNotifier,
      builder: (context, value, child) {
        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.topCenter,
                      padding: EdgeInsets.only(left: 53, top: 53),
                      child: Scrollbar(
                        controller: scrollController, // 使用 ScrollController
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller:
                              scrollController, // 使用相同的 ScrollController
                          child: const V3Instruction(isCastToDevice: false),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 43),
                    width: 171,
                    constraints: BoxConstraints(maxHeight: 230),
                    decoration: _buildQrCodeDecoration(context),
                    child: const V3QrCodeQuickConnect(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: _buildInstructionRow(context),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 6),
              child: _buildMiracastInstructionRow(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInstructionRow(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 35),
          child: SvgPicture.asset(
            'assets/images/ic_arrow_to_screen.svg',
            excludeFromSemantics: true,
            width: 21,
            height: 21,
            colorFilter: ColorFilter.mode(
              context.tokens.color.vsdslColorOnSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: AutoSizeText.rich(
              _buildTextSpan(
                fullText: S.of(context).v3_instruction_support,
                formatTexts: ['AirPlay, Google Cast', 'Miracast'],
                formatStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400, // 最新的設計沒有粗體
                  color: context.tokens.color.vsdslColorOnSurfaceVariant,
                ),
              ),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: context.tokens.color.vsdslColorOnSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiracastInstructionRow(BuildContext context) {
    return Consumer<MirrorStateProvider>(builder: (_, provider, __) {
      return provider.isVB005AndDFSChannel
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start, // 保持頂部對齊
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 35),
                  child: SvgPicture.asset(
                    'assets/images/ic_toast_alert.svg',
                    excludeFromSemantics: true,
                    width: 21,
                    height: 21,
                    colorFilter: ColorFilter.mode(
                      context.tokens.color.vsdslColorWarning,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: SizedBox(
                      width: 700, // 設置一個固定的寬度
                      child: AutoSizeText(
                        S.of(context).v3_miracast_not_support,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: context.tokens.color.vsdslColorWarning,
                        ),
                        minFontSize: 9,
                        maxLines: 2, // 允許最多兩行
                        overflow: TextOverflow.ellipsis, // 如果超過兩行，使用省略號
                      ),
                    ),
                  ),
                ),
              ],
            )
          : const SizedBox.shrink();
    });
  }

  ShapeDecoration _buildQrCodeDecoration(BuildContext context) {
    return ShapeDecoration(
      shape: RoundedRectangleBorder(
        borderRadius: context.tokens.radii.vsdslRadiusXl,
        side: BorderSide(
          width: 1,
          color: context.tokens.color.vsdslColorOutline,
        ),
      ),
    );
  }

  TextSpan _buildTextSpan(
      {required String fullText,
      required List<String> formatTexts,
      required TextStyle formatStyle}) {
    List<TextSpan> spans = [];
    int start = 0;

    // Process text based on each substring that needs to be formatted
    while (start < fullText.length) {
      int closestBoldStart = -1;
      String? closestBoldText;

      // Find the earliest occurrence of format text
      for (String boldText in formatTexts) {
        int index = fullText.indexOf(boldText, start);
        if (index != -1 &&
            (closestBoldStart == -1 || index < closestBoldStart)) {
          closestBoldStart = index;
          closestBoldText = boldText;
        }
      }

      // If there is no more format text, add the remaining text
      if (closestBoldStart == -1) {
        spans.add(TextSpan(
          text: fullText.substring(start),
        ));
        break;
      }

      // Add the normal part before the format text
      if (closestBoldStart > start) {
        spans.add(TextSpan(
          text: fullText.substring(start, closestBoldStart),
        ));
      }

      // Add format text
      spans.add(TextSpan(
        text: closestBoldText,
        style: formatStyle,
      ));

      // Update the start position
      start = closestBoldStart + closestBoldText!.length;
    }
    return TextSpan(children: spans);
  }
}
