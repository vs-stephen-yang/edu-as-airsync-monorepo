import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/widgets/v3_setting_menu_focus_single_child_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
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
                const Image(
                  width: 53,
                  height: 53,
                  image: Svg('assets/images/ic_logo_airsync_icon.svg'),
                ),
                const Gap(12),
                Center(
                  child: Text(
                    'v${AppConfig.of(context)?.appVersion ?? ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Gap(16),
                Text(
                  sprintf(S.current.v3_settings_whats_new_content,
                      ['v${AppConfig.of(context)?.appVersion ?? ''}']),
                  textAlign: TextAlign.start,
                  style: const TextStyle(
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
