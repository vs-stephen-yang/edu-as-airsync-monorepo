import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/widgets/v3_participant_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

class V3ParticipantsMenu extends StatelessWidget {
  const V3ParticipantsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: 40,
          bottom: 80,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: context.tokens.color.vsdslColorSurface100,
            insetPadding: EdgeInsets.zero,
            elevation: 16.0,
            shadowColor: context.tokens.color.vsdslColorOpacityNeutralSm,
            child: SizedBox(
              width: 384,
              height: 442,
              child: Stack(
                children: [
                  const Positioned(
                    left: 13,
                    top: 27,
                    right: 13,
                    bottom: 66,
                    child: V3ParticipantList(isForMenuUse: true),
                  ),
                  Positioned(
                    right: 5,
                    bottom: 5,
                    child: SizedBox(
                      width: 33,
                      height: 33,
                      child: IconButton(
                        icon: const Image(
                          image: Svg('assets/images/ic_menu_close_gray.svg'),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          if (navService.canPop()) {
                            navService.goBack();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
