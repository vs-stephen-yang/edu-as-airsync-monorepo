import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/widgets/v3_instruction.dart';
import 'package:display_flutter/widgets/v3_participants_view.dart';
import 'package:display_flutter/widgets/v3_qrcode_quick_connect.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class V3MainInfo extends StatelessWidget {
  const V3MainInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 1065,
      height: 505,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Color(0xFFFFFFFF),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 764,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Positioned(
                  left: 50,
                  top: 50,
                  bottom: 118,
                  child: V3Instruction(),
                ),
                Positioned(
                  left: 50,
                  bottom: 30,
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 35),
                        child: Image(
                          image: Svg('assets/images/ic_arrow_to_screen.svg'),
                          height: 21,
                          width: 21,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: AutoSizeText.rich(
                          _buildTextSpan(
                              fullText: S.of(context).v3_instruction_support,
                              formatTexts: ['AirPlay, Google Cast', 'Miracast'],
                              formatStyle:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                          style: const TextStyle(
                            color: Color(0xFF838CA6),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 8,
                  child: Container(
                    width: 170,
                    height: 220,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(
                          width: 1,
                          color: Color(0xFFE9EAF0),
                        ),
                      ),
                    ),
                    child: const V3QrcodeQuickConnect(),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            color: const Color(0xFFE9EAF0),
          ),
          const SizedBox(
            width: 300,
            child: V3ParticipantsView(),
          ),
        ],
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
