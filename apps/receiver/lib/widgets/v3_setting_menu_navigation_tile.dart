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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                title,
                style: TextStyle(
                  color: context.tokens.color.vsdslColorOnSurfaceInverse,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 5,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: InkWell(
                focusNode: focusNode,
                onTap: onTap,
                child: Container(
                  alignment: Alignment.centerRight,
                  constraints: const BoxConstraints(minHeight: 48),
                  padding: const EdgeInsets.symmetric(vertical: 4), // 添加垂直內邊距
                  child: Text(
                    trialling,
                    style: TextStyle(
                      color: context.tokens.color.vsdslColorOnSurfaceInverse
                          .withValues(alpha: disable ? 0.32 : 1),
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2, // 允許顯示最多兩行
                    textAlign: TextAlign.right, // 確保文字右對齊
                  ),
                ),
              ),
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
