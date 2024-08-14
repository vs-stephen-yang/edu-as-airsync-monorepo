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
          top: 133,
          right: 40,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            insetPadding: const EdgeInsets.only(left: 8, bottom: 8),
            child: SizedBox(
              width: 310,
              height: 507,
              child: Stack(
                children: [
                  const Positioned(
                    left: 13,
                    top: 20,
                    right: 13,
                    bottom: 100,
                    child: V3ParticipantList(),
                  ),
                  Positioned(
                    right: 13,
                    bottom: 13,
                    child: SizedBox(
                      width: 33,
                      child: IconButton(
                        icon: const Image(
                          image: Svg('assets/images/ic_menu_minimal.svg'),
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
