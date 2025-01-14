import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:display_flutter/widgets/v3_menu_back_icon_button.dart';
import 'package:display_flutter/widgets/v3_setting_menu_focus_single_child_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class V3SettingsLicense extends StatelessWidget {
  const V3SettingsLicense({super.key});

  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    return Stack(
      children: [
        Positioned(
            left: 0,
            top: 0,
            child: V3MenuBackIconButton(
              onPressed: () {
                settingsProvider.setPage(SettingPageState.legalPolicy);
              },
              title: settingsProvider.license?.name ??
                  S.of(context).v3_settings_privacy_policy,
            )),
        Positioned(
          top: 46,
          left: 13,
          right: 13,
          bottom: 13,
          child: V3SettingMenuFocusSingleChildScrollView(
            primaryFocus: true,
            children: [
              Text(
                settingsProvider.license?.license ??
                    S.of(context).v3_settings_privacy_policy_description,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
