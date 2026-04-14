import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_participant_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

class V3ParticipantsMenu extends StatelessWidget {
  const V3ParticipantsMenu({
    super.key,
    required this.primaryFocusNode,
    this.position,
  });

  final FocusNode primaryFocusNode;
  final Offset? position;

  @override
  Widget build(BuildContext context) {
    // 使用傳入的 position，若無則使用預設值
    final left = position?.dx ?? 60;
    final top = position?.dy ?? (MediaQuery.of(context).size.height - 442 - 80);

    return Stack(
      children: [
        Positioned(
          left: left,
          top: top,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: context.tokens.color.vsdslColorSurface100,
            insetPadding: EdgeInsets.zero,
            elevation: 16.0,
            shadowColor: context.tokens.color.vsdslColorOpacityNeutralSm,
            child: FocusScope(
              autofocus: true,
              node: FocusScopeNode(),
              child: SizedBox(
                width: 384,
                height: 442,
                child: Stack(
                  children: [
                    const Positioned(
                      left: 13,
                      top: 27,
                      right: 13,
                      bottom: 23,
                      child: V3ParticipantList(isForMenuUse: true),
                    ),
                    Positioned(
                      right: 5,
                      bottom: 5,
                      child: V3Focus(
                        label: S.of(context).v3_lbl_close_feature_set_moderator,
                        identifier: 'v3_qa_close_feature_set_moderator',
                        child: SizedBox(
                          width: 33,
                          height: 33,
                          child: IconButton(
                            focusNode: primaryFocusNode,
                            icon: SvgPicture.asset(
                              'assets/images/ic_menu_close_gray.svg',
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
