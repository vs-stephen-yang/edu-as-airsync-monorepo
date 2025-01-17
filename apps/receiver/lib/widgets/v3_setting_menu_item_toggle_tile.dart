import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/widgets/v3_setting_menu_sub_item_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class V3SettingMenuItemToggleTile extends StatelessWidget {
  const V3SettingMenuItemToggleTile({
    super.key,
    required this.title,
    this.focusNode,
    required this.switchOn,
    this.onTap,
    this.isLocked = false,
  });

  final String title;
  final FocusNode? focusNode;
  final bool switchOn;
  final VoidCallback? onTap;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    return V3SettingMenuSubItemFocus(
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        focusNode: focusNode,
        onTap: onTap,
        child: SizedBox(
          height: 26,
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
              SizedBox(
                height: 21,
                child: ExcludeFocus(
                  child: InkWell(
                    highlightColor: Colors.transparent,
                    onTap: isLocked ? null : onTap,
                    child: Image(
                      image: Svg(isLocked
                          ? switchOn
                              ? 'assets/images/ic_switch_on_lock.svg'
                              : 'assets/images/ic_switch_off_lock.svg'
                          : switchOn
                              ? 'assets/images/ic_switch_on.svg'
                              : 'assets/images/ic_switch_off.svg'),
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
