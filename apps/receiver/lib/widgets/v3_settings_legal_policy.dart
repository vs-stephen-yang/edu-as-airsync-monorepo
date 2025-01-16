import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/oss_licenses.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:display_flutter/widgets/v3_menu_navigation_icon_button.dart';
import 'package:display_flutter/widgets/v3_setting_2ndLayer.dart';
import 'package:display_flutter/widgets/v3_setting_menu_list_item_focus.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class V3SettingsLegalPolicy extends StatelessWidget {
  const V3SettingsLegalPolicy({super.key});

  final List<String> _hiddenLicenses = const [
    'app_ota_flutter',
    'device_info_vs',
    'display_channel',
    'flutter_input_injection',
    'flutter_ion_sfu',
    'flutter_mirror',
  ];

  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    return V3Setting2ndLayer(
      disableScroll: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          V3SettingMenuListTile(
            focusNode: settingsProvider.subFocusNode,
            name: S.of(context).v3_settings_privacy_policy,
            onTap: () {
              settingsProvider.setPage(SettingPageState.licenses);
            },
          ),
          Container(
            height: 1,
            margin: EdgeInsets.only(
                top: context.tokens.spacing.vsdslSpacingSm.top,
                bottom: context.tokens.spacing.vsdslSpacingSm.bottom),
            color: context.tokens.color.vsdslColorOutlineVariant,
          ),
          SizedBox(
            height: 26,
            child: Text(
              S.of(context).v3_settings_open_source_license,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                itemCount: dependencies
                    .where((license) => !_hiddenLicenses.contains(license.name))
                    .length,
                itemBuilder: (context, index) {
                  final visibleLicenses = dependencies
                      .where(
                          (license) => !_hiddenLicenses.contains(license.name))
                      .toList();
                  final license = visibleLicenses[index];
                  return V3SettingMenuListTile(
                      name: license.name,
                      onTap: () {
                        settingsProvider.setPage(SettingPageState.licenses,
                            license: license);
                      });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class V3SettingMenuListTile extends StatelessWidget {
  const V3SettingMenuListTile({
    super.key,
    required this.name,
    required this.onTap,
    this.focusNode,
  });

  final String name;
  final VoidCallback onTap;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 26,
      child: Row(
        children: [
          Expanded(
            child: V3SettingMenuListItemFocus(
              child: Row(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  V3MenuNavigationIconButton(
                    focusNode: focusNode,
                    constraints: const BoxConstraints(
                      minWidth: 40.0,
                      minHeight: 48.0,
                    ),
                    enabledIconPath: 'assets/images/ic_arrow_right.svg',
                    onPressed: onTap,
                  ),
                ],
              ),
            ),
          ),
          const Gap(8),
        ],
      ),
    );
  }
}

class License {
  String? name;
  String? description;

  License(this.name, this.description);

  License.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    description = json['description'];
  }
}
