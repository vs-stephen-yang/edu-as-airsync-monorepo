import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_menu_navigation_icon_button.dart';
import 'package:flutter/material.dart';

class V3MenuBackIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final FocusNode? focusNode;
  final String? label;
  final String? identifier;

  const V3MenuBackIconButton({
    super.key,
    required this.onPressed,
    required this.title,
    this.focusNode,
    this.label,
    this.identifier,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 13, top: 13),
      child: V3Focus(
        label: S.of(context).v3_lbl_settings_back_icon,
        identifier: "v3_qa_settings_back_icon",
        excludeSemantics: false,
        child: Row(
          children: [
            V3MenuNavigationIconButton(
              label: S.of(context).v3_lbl_settings_back_icon,
              identifier: "v3_qa_settings_back_icon",
              enabledIconPath: 'assets/images/ic_arrow_left.svg',
              constraints: const BoxConstraints(
                minWidth: 21.0,
                minHeight: 21.0,
              ),
              onPressed: onPressed,
              focusNode: focusNode,
            ),
            Padding(
                padding: EdgeInsets.only(
                    right: context.tokens.spacing.vsdslSpacingXs.right)),
            V3AutoHyphenatingText(
              title,
              style: TextStyle(
                color: context.tokens.color.vsdslColorOnSurfaceInverse,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
