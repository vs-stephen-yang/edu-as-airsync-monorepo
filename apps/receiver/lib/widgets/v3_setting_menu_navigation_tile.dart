import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/widgets/v3_menu_navigation_icon_button.dart';
import 'package:display_flutter/widgets/v3_setting_menu_sub_item_focus.dart';
import 'package:flutter/material.dart';

class V3SettingMenuNavigationTile extends StatelessWidget {
  const V3SettingMenuNavigationTile({
    super.key,
    required this.title,
    this.focusNode,
    required this.onTap,
    required this.trialling,
    required this.disable,
    required this.label,
    required this.identifier,
  });

  final String title;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final String trialling;
  final bool disable;
  final String label;
  final String identifier;

  @override
  Widget build(BuildContext context) {
    return V3SettingMenuSubItemFocus(
      label: label,
      identifier: identifier,
      excludeSemantics: false,
      child: SizedBox(
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: context.tokens.color.vsdslColorOnSurfaceInverse,
                fontSize: 12,
              ),
            ),
            const Spacer(),
            InkWell(
              focusNode: focusNode,
              onTap: onTap,
              child: Container(
                alignment: Alignment.center,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: Text(
                  trialling,
                  style: TextStyle(
                    color: context.tokens.color.vsdslColorOnSurfaceInverse
                        .withOpacity(disable ? 0.32 : 1),
                    fontSize: 12,
                  ),
                ),
              )
            ),
            V3MenuNavigationIconButton(
              label: label,
              identifier: identifier,
              enabledIconPath: 'assets/images/ic_arrow_right.svg',
              disabledIconPath: 'assets/images/ic_arrow_right_lock.svg',
              disabled: disable,
              onPressed: onTap,
            ),
          ],
        ),
      ),
    );
  }
}
