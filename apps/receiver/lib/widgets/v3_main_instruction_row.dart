import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class V3MainInstructionRow extends StatelessWidget {
  const V3MainInstructionRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildInstructionIcon(context, 'assets/images/ic_arrow_to_screen.svg'),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: AutoSizeText.rich(
              _buildTextSpan(
                fullText: S.of(context).v3_instruction_support,
                formatTexts: const ['AirPlay, Google Cast', 'Miracast'],
                formatStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
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

  Widget _buildInstructionIcon(BuildContext context, String assetPath,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(left: 35),
      child: SvgPicture.asset(
        assetPath,
        excludeFromSemantics: true,
        width: 21,
        height: 21,
        colorFilter: ColorFilter.mode(
          color ?? context.tokens.color.vsdslColorOnSurfaceVariant,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  TextSpan _buildTextSpan({
    required String fullText,
    required List<String> formatTexts,
    required TextStyle formatStyle,
  }) {
    List<TextSpan> spans = [];
    int start = 0;

    while (start < fullText.length) {
      int closestBoldStart = -1;
      String? closestBoldText;

      for (String boldText in formatTexts) {
        int index = fullText.indexOf(boldText, start);
        if (index != -1 &&
            (closestBoldStart == -1 || index < closestBoldStart)) {
          closestBoldStart = index;
          closestBoldText = boldText;
        }
      }

      if (closestBoldStart == -1) {
        spans.add(TextSpan(text: fullText.substring(start)));
        break;
      }

      if (closestBoldStart > start) {
        spans.add(TextSpan(
          text: fullText.substring(start, closestBoldStart),
        ));
      }

      spans.add(TextSpan(
        text: closestBoldText,
        style: formatStyle,
      ));

      start = closestBoldStart + closestBoldText!.length;
    }
    return TextSpan(children: spans);
  }
}
