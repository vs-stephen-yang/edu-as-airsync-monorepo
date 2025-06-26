import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/widgets/v3_setting_menu_focus_single_child_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:sprintf/sprintf.dart';

class V3SettingsWhatsNew extends StatelessWidget {
  const V3SettingsWhatsNew({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 57, left: 13, right: 13, bottom: 13),
      child: Column(
        children: [
          Expanded(
            child: V3SettingMenuFocusSingleChildScrollView(
              primaryFocus: true,
              children: [
                SvgPicture.asset(
                  semanticsLabel: S.of(context).v3_lbl_settings_whats_new_icon,
                  'assets/images/ic_logo_airsync_icon.svg',
                  width: 53,
                  height: 53,
                ),
                const Gap(12),
                Center(
                  child: Text(
                    'v${AppConfig.of(context)?.appVersion ?? ''}',
                    style: TextStyle(
                      color: context.tokens.color.vsdslColorOnSurfaceInverse,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Gap(16),
                Text(
                  sprintf(S.of(context).v3_settings_whats_new_content,
                      ['v${AppConfig.of(context)?.appVersion ?? ''}']),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: context.tokens.color.vsdslColorOnSurfaceInverse,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
