import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_overlay_tab.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/pref_language_provider.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

import 'focus_icon_button.dart';

class V3SettingsDevice extends StatefulWidget {
  const V3SettingsDevice({super.key});

  @override
  State<V3SettingsDevice> createState() => _V3SettingsDeviceState();
}

class _V3SettingsDeviceState extends State<V3SettingsDevice> {
  @override
  Widget build(BuildContext context) {
    PrefLanguageProvider languageProvider =
        Provider.of<PrefLanguageProvider>(context, listen: false);
    SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    return Stack(
      children: [
        Positioned(
          left: 13,
          top: 57,
          right: 13,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    S.of(context).v3_settings_device_name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    child: Text(
                      AppPreferences().instanceName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    onTap: () {
                      settingsProvider.setPage(SettingPageState.deviceName);
                    },
                  ),
                  IconButton(
                    icon: const Image(
                      image: Svg('assets/images/ic_arrow_right.svg'),
                      width: 21,
                      height: 21,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      settingsProvider.setPage(SettingPageState.deviceName);
                    },
                  ),
                ],
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: context.tokens.color.vsdslColorOutlineVariant,
              ),
              Row(
                children: [
                  Text(
                    S.of(context).main_language_title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    child: Text(
                      languageProvider.language,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    onTap: () {
                      settingsProvider.setPage(SettingPageState.deviceLanguage);
                    },
                  ),
                  IconButton(
                    icon: const Image(
                      image: Svg('assets/images/ic_arrow_right.svg'),
                      width: 21,
                      height: 21,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      settingsProvider.setPage(SettingPageState.deviceLanguage);
                    },
                  ),
                ],
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: context.tokens.color.vsdslColorOutlineVariant,
              ),
              Row(
                children: [
                  Text(
                    S.of(context).v3_settings_device_show_display_code,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  FutureBuilder(
                    future: AppOverlayTab().getVisibility(),
                    builder: (context, snapshot) {
                      bool isRunning = false;
                      if (snapshot.hasData) {
                        isRunning = snapshot.data as bool;
                      }
                      return FocusIconButton(
                        childNotFocus: Image(
                          image: Svg(isRunning
                              ? 'assets/images/ic_switch_on.svg'
                              : 'assets/images/ic_switch_off.svg'),
                          width: 36,
                          height: 21,
                        ),
                        splashRadius: 20,
                        focusColor: Colors.grey,
                        onClick: () {
                          _setVisibility(!isRunning);
                        },
                      );
                    },
                  ),
                ],
              ),
              AutoSizeText(
                S.of(context).v3_settings_device_show_display_code_desc,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w400,
                  color: context.tokens.color.vsdslColorSurface600,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Container(
                  height: 1,
                  color: context.tokens.color.vsdslColorOutlineVariant,
                ),
              ),
              Row(
                children: [
                  Text(
                    S.of(context).v3_settings_invite_group,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 105,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        hint: Text(
                          AppPreferences().invitedToGroup,
                          style: const TextStyle(
                            fontSize: 9,
                          ),
                        ),
                        items: AppPreferences()
                            .invitedToGroupItems
                            .map((String item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 9,
                                    ),
                                  ),
                                ))
                            .toList(),
                        value: AppPreferences().invitedToGroup,
                        onChanged: (String? value) {
                          setState(() {
                            if (value != null) {
                              AppPreferences()
                                  .setInvitedToGroupSelectedItem(item: value);
                            }
                          });
                        },
                        buttonStyleData: ButtonStyleData(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            height: 26,
                            width: 105,
                            decoration: BoxDecoration(
                              color: context.tokens.color.vsdslColorSurface300,
                              borderRadius: BorderRadius.circular(6),
                            )),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Container(
                  height: 1,
                  color: context.tokens.color.vsdslColorOutlineVariant,
                ),
              ),
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                        value: AppPreferences().autoFillOneTimePassword,
                        activeColor: context.tokens.color.vsdslColorSecondary,
                        onChanged: (bool? value) {
                          AppPreferences().autoFillOneTimePassword = false;
                        }),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 4),
                  ),
                  const AutoSizeText(
                    "Auto-fill one-time password",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 24),
                child: Text(
                  "Enable one-touch connection when selecting a device from the device list.",
                  style: TextStyle(
                    fontSize: 9,
                    color: context.tokens.color.vsdslColorSurface600,
                  ),
                  maxLines: 2,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  _setVisibility(bool visible) async {
    await AppOverlayTab().setVisibility(visible);
    setState(() {});
  }
}
