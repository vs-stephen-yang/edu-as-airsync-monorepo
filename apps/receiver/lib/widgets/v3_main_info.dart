import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/connectivity_provider.dart';
import 'package:display_flutter/widgets/v3_instruction.dart';
import 'package:display_flutter/widgets/v3_no_network_status.dart';
import 'package:display_flutter/widgets/v3_participants_view.dart';
import 'package:display_flutter/widgets/v3_qrcode_quick_connect.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class V3MainInfo extends StatelessWidget {
  const V3MainInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 1173,
      height: 505,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          side: BorderSide(
            width: 1,
            color: context.tokens.color.vsdslColorOutline,
          ),
        ),
        color: context.tokens.color.vsdslColorSurface100.withOpacity(0.64),
      ),
      child: Consumer<ConnectivityProvider>(
          builder: (_, connectivityProvider, __) {
        return connectivityProvider.connectionStatus == ConnectivityResult.none
            ? const V3NoNetworkStatus()
            : Row(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Positioned(
                          left: 53,
                          top: 26,
                          bottom: 76,
                          child: V3Instruction(isCastToDevice: false),
                        ),
                        Positioned(
                          left: 50,
                          bottom: 44,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 35),
                                child: Image(
                                  image: const Svg(
                                      'assets/images/ic_arrow_to_screen.svg'),
                                  width: 21,
                                  height: 21,
                                  color:
                                      context.tokens.color.vsdslColorSurface600,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: AutoSizeText.rich(
                                  _buildTextSpan(
                                      fullText:
                                          S.of(context).v3_instruction_support,
                                      formatTexts: [
                                        'AirPlay, Google Cast',
                                        'Miracast'
                                      ],
                                      formatStyle: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: context
                                            .tokens.color.vsdslColorSurface600,
                                      )),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: context
                                        .tokens.color.vsdslColorSurface600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 150,
                          right: 42,
                          child: Container(
                            width: 171,
                            height: 229,
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    context.tokens.radii.vsdslRadiusXl,
                                side: BorderSide(
                                  width: 1,
                                  color: context.tokens.color.vsdslColorOutline,
                                ),
                              ),
                            ),
                            child: const V3QrCodeQuickConnect(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    color: context.tokens.color.vsdslColorOutline,
                  ),
                  const SizedBox(
                    width: 340,
                    child: V3ParticipantsView(),
                  ),
                ],
              );
      }),
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
