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
  });

  final String title;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final String trialling;
  final bool disable;

  @override
  Widget build(BuildContext context) {
    return V3SettingMenuSubItemFocus(
      child: SizedBox(
        height: 26,
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            const Spacer(),
            InkWell(
              focusNode: focusNode,
              onTap: onTap,
              child: Text(
                trialling,
                style: TextStyle(
                  color: Colors.white.withOpacity(disable ? 0.32 : 1),
                  fontSize: 12,
                ),
              ),
            ),
            V3MenuNavigationIconButton(
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
