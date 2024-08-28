import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_overlay_tab.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
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
  final valueListenable =
      ValueNotifier<String>(AppPreferences().invitedToGroup);

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
              SizedBox(
                height: 26,
                child: _buildDeviceName(context, settingsProvider),
              ),
              _buildDivider(context),
              SizedBox(
                height: 26,
                child:
                    _buildLanguage(context, languageProvider, settingsProvider),
              ),
              _buildDivider(context),
              _buildShowDisplayCode(context),
              AutoSizeText(
                S.of(context).v3_settings_device_show_display_code_desc,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w400,
                  color: context.tokens.color.vsdslColorSurface600,
                ),
              ),
              _buildDivider(context),
              SizedBox(
                height: 26,
                child: _buildInviteGroup(context),
              ),
              _buildDivider(context),
              Consumer<ChannelProvider>(
                builder: (_, channelProvider, __) {
                  return _buildAutoFillOTP(channelProvider, context);
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 24),
                child: Text(
                  S.of(context).v3_settings_device_auto_fill_otp_desc,
                  style: TextStyle(
                    fontSize: 9,
                    color: context.tokens.color.vsdslColorSurface600,
                  ),
                  maxLines: 2,
                ),
              ),
              _buildDivider(context),
            ],
          ),
        ),
      ],
    );
  }

  Container _buildDivider(BuildContext context) {
    return Container(
      height: 1,
      margin: EdgeInsets.only(
          top: context.tokens.spacing.vsdslSpacingSm.top,
          bottom: context.tokens.spacing.vsdslSpacingSm.bottom),
      color: context.tokens.color.vsdslColorOutlineVariant,
    );
  }

  Row _buildAutoFillOTP(ChannelProvider channelProvider, BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
              value: channelProvider.isDeviceListQuickConnect,
              activeColor: context.tokens.color.vsdslColorSecondary,
              onChanged: (bool? value) {
                if (channelProvider.isDeviceListQuickConnect) {
                  channelProvider.isDeviceListQuickConnect = false;
                } else {
                  channelProvider.isDeviceListQuickConnect = true;
                }
              }),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 4),
        ),
        InkWell(
            onTap: () {
              if (channelProvider.isDeviceListQuickConnect) {
                channelProvider.isDeviceListQuickConnect = false;
              } else {
                channelProvider.isDeviceListQuickConnect = true;
              }
            },
            child: AutoSizeText(
              S.of(context).v3_settings_device_auto_fill_otp,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
              maxLines: 1,
            )),
      ],
    );
  }

  DropdownButtonHideUnderline _buildDropdownMenu(BuildContext context) {
    final List<String> invitedToGroupItems = [
      S.of(context).v3_settings_invite_group_notify_me,
      S.of(context).v3_settings_invite_group_auto_accept,
      S.of(context).v3_settings_invite_group_ignore,
    ];
    return DropdownButtonHideUnderline(
        child: CustomDropDownMenu(
            itemList: invitedToGroupItems,
            defaultSelectedItem: AppPreferences().invitedToGroup,
            selectedItem: Text(
              AppPreferences().invitedToGroup,
              style: const TextStyle(
                fontSize: 9,
              ),
            ),
            unselectedItemsInMenu: (String item) => SizedBox(
                  height: 26,
                  child: Row(
                    children: [
                      Text(
                        item,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
            selectedItemInMenu: Row(
              children: [
                Text(
                  AppPreferences().invitedToGroup,
                  style: TextStyle(
                    fontSize: 9,
                    color: context.tokens.color.vsdslColorOnSurfaceInverse,
                  ),
                ),
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Image(
                    image: Svg('assets/images/ic_checkmark.svg'),
                    width: 16,
                    height: 16,
                  ),
                ),
              ],
            ),
            onChange: (String? value) {
              setState(() {
                AppPreferences().setInvitedToGroupSelectedItem(item: value);
              });
            }));
  }

  Row _buildInviteGroup(BuildContext context) {
    return Row(
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
          child: _buildDropdownMenu(context),
        ),
      ],
    );
  }

  Row _buildShowDisplayCode(BuildContext context) {
    return Row(
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
              // splashRadius: 20,
              focusColor: Colors.grey,
              onClick: () {
                _setVisibility(!isRunning);
              },
            );
          },
        ),
      ],
    );
  }

  Row _buildLanguage(
      BuildContext context,
      PrefLanguageProvider languageProvider,
      SettingsProvider settingsProvider) {
    return Row(
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
    );
  }

  Row _buildDeviceName(
      BuildContext context, SettingsProvider settingsProvider) {
    return Row(
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
    );
  }

  _setVisibility(bool visible) async {
    await AppOverlayTab().setVisibility(visible);
    setState(() {});
  }
}

class CustomDropDownMenu extends StatefulWidget {
  CustomDropDownMenu({
    super.key,
    required this.itemList,
    required this.defaultSelectedItem,
    required this.selectedItem,
    required this.unselectedItemsInMenu,
    required this.selectedItemInMenu,
    required this.onChange,
  }) {
    valueListenable.value = defaultSelectedItem;
  }

  final List<String> itemList;
  final String defaultSelectedItem;
  final Widget selectedItem;
  final Widget Function(String) unselectedItemsInMenu;
  final Widget selectedItemInMenu;
  final Function(String?) onChange;
  final ValueNotifier<String> valueListenable = ValueNotifier("");

  @override
  State<CustomDropDownMenu> createState() => _CustomDropDownMenuState();
}

class _CustomDropDownMenuState extends State<CustomDropDownMenu> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton2<String>(
      isDense: true,
      isExpanded: true,
      value: widget.defaultSelectedItem,
      items: widget.itemList
          .map((String item) => DropdownMenuItem<String>(
                value: item,
                child: widget.unselectedItemsInMenu(item),
              ))
          .toList(),
      onChanged: (String? value) {
        if (value != null) {
          widget.valueListenable.value = value;
          widget.onChange(value);
        }
      },
      selectedItemBuilder: (context) {
        return widget.itemList.map(
          (item) {
            return ValueListenableBuilder<String>(
                valueListenable: widget.valueListenable,
                builder: (context, multiValue, _) {
                  return widget.selectedItem;
                });
          },
        ).toList();
      },
      buttonStyleData: ButtonStyleData(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          height: 26,
          width: 105,
          decoration: BoxDecoration(
            color: context.tokens.color.vsdslColorSurface300,
            borderRadius: BorderRadius.circular(6),
          )),
      dropdownStyleData: DropdownStyleData(
        width: 105,
        padding: const EdgeInsets.only(top: 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          // color: Colors.black,
        ),
      ),
      menuItemStyleData: MenuItemStyleData(
          height: 26,
          selectedMenuItemBuilder: (context, child) {
            return Container(
              height: 26,
              padding: const EdgeInsets.only(left: 16),
              color: context.tokens.color.vsdslColorSecondary,
              child: widget.selectedItemInMenu,
            );
          }),
    );
  }
}
