import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_menu_navigation_icon_button.dart';
import 'package:flutter/material.dart';

class V3MenuBackIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;

  const V3MenuBackIconButton(
      {super.key, required this.onPressed, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 13, top: 13),
      child: V3Focus(
        child: Row(
          children: [
            V3MenuNavigationIconButton(
              enabledIconPath: 'assets/images/ic_arrow_left.svg',
              constraints: const BoxConstraints(
                minWidth: 21.0,
                minHeight: 21.0,
              ),
              onPressed: onPressed,
            ),
            Padding(
                padding: EdgeInsets.only(
                    right: context.tokens.spacing.vsdslSpacingXs.right)),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
