import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_flutter/widgets/v3_setting_menu_sub_item_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class V3SettingMenuItemToggleTile extends StatelessWidget {
  const V3SettingMenuItemToggleTile({
    super.key,
    required this.title,
    this.focusNode,
    required this.switchOn,
    this.onTap,
    this.isLocked = false,
    this.label,
    this.identifier,
  });

  final String title;
  final FocusNode? focusNode;
  final bool switchOn;
  final VoidCallback? onTap;
  final bool isLocked;
  final String? label;
  final String? identifier;

  @override
  Widget build(BuildContext context) {
    return V3SettingMenuSubItemFocus(
      label: label,
      identifier: identifier,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        focusNode: focusNode,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 26),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 使用 Expanded 來處理文字溢出
              Expanded(
                child: V3AutoHyphenatingText(
                  title,
                  style: TextStyle(
                    color: context.tokens.color.vsdslColorOnSurfaceInverse,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                width: 48,
                child: ExcludeFocus(
                  child: Center(
                    child: SizedBox(
                      width: 37,
                      height: 21,
                      child: InkWell(
                        highlightColor: Colors.transparent,
                        onTap: isLocked ? null : onTap,
                        child: SvgPicture.asset(
                          isLocked
                              ? switchOn
                                  ? 'assets/images/ic_switch_on_lock.svg'
                                  : 'assets/images/ic_switch_off_lock.svg'
                              : switchOn
                                  ? 'assets/images/ic_switch_on.svg'
                                  : 'assets/images/ic_switch_off.svg',
                          fit: BoxFit.contain, // 圖片會自適應 21x38，無需縮放變形
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
