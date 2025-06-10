import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/pref_language_provider.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:display_flutter/widgets/v3_menu_back_icon_button.dart';
import 'package:display_flutter/widgets/v3_scrollbar.dart';
import 'package:display_flutter/widgets/v3_settings_radio_group.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class V3SettingsDeviceLanguage extends StatelessWidget {
  final bool openedWithLogicalKey;

  const V3SettingsDeviceLanguage(
      {super.key, required this.openedWithLogicalKey});

  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    PrefLanguageProvider languageProvider =
        Provider.of<PrefLanguageProvider>(context, listen: false);
    return Stack(
      children: [
        Positioned(
            left: 0,
            top: 0,
            child: V3MenuBackIconButton(
              onPressed: () {
                settingsProvider.setPage(SettingPageState.deviceSetting);
              },
              title: S.of(context).main_language_title,
            )),
        Positioned(
          top: 57,
          left: 13,
          right: 13,
          bottom: 13,
          child: Builder(
            builder: (context) {
              final ScrollController scrollController = ScrollController();
              return V3Scrollbar(
                controller: scrollController,
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.only(right: 8), // 為滾動條留出空間
                  child: V3SettingsRadioGroup(
                    label: S.current.v3_lbl_main_language_title_item,
                    identifier: "v3_qa_main_language_title_item",
                    hasSubFocusItem: true,
                    focusOnInit: openedWithLogicalKey,
                    initSelectedValue: languageProvider.language,
                    radioList: languageProvider.localeMap.keys.map((key) {
                      return V3SettingsRadioGroupItem(
                        value: key, // use key as value to set newValue
                        title: key, // use key as title
                        divider: false,
                      );
                    }).toList(),
                    onChanged: (value) {
                      trackEvent('click_language', EventCategory.setting);
                      languageProvider.setLanguage(value);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
