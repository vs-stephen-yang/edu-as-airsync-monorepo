import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/app_instance_create.dart';
import 'package:display_flutter/app_overlay_tab.dart';
import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/pref_language_provider.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:display_flutter/screens/v3_setting_menu.dart';
import 'package:display_flutter/services/display_service_broadcast.dart';
import 'package:display_flutter/widgets/v3_custom_checkbox.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_setting_2ndLayer.dart';
import 'package:display_flutter/widgets/v3_setting_menu_item_toggle_tile.dart';
import 'package:display_flutter/widgets/v3_setting_menu_navigation_tile.dart';
import 'package:display_flutter/widgets/v3_setting_menu_sub_item_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';

class V3SettingsDevice extends StatefulWidget {
  const V3SettingsDevice({super.key});

  @override
  State<V3SettingsDevice> createState() => _V3SettingsDeviceState();
}

class _V3SettingsDeviceState extends State<V3SettingsDevice> {
  final valueListenable =
      ValueNotifier<String>(AppPreferences().invitedToGroup);
  static const _autoStartUp =
      MethodChannel('com.mvbcast.crosswalk/auto_startup');

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(builder: (_, settingsProvider, __) {
      return V3Setting2ndLayer(
        isDisable: settingsProvider.isDeviceSettingLock,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDeviceName(context, settingsProvider),
            _buildDivider(context),
            _buildLanguage(context, settingsProvider),
            _buildDivider(context),
            _buildShowDisplayCode(context, settingsProvider),
            Padding(
              padding: EdgeInsets.only(
                top: context.tokens.spacing.vsdslSpacingSm.top,
              ),
              child: _buildTextDesc(
                context,
                S.of(context).v3_settings_device_show_display_code_desc,
              ),
            ),
            _buildSmartScaling(context, settingsProvider),
            Padding(
              padding: EdgeInsets.only(
                top: context.tokens.spacing.vsdslSpacingSm.top,
              ),
              child: _buildTextDesc(
                context,
                S.of(context).v3_settings_device_smart_scaling_desc,
              ),
            ),
            _buildDivider(context),
            V3SettingMenuSubItemFocus(
              child: _buildInviteGroup(context, settingsProvider),
            ),
            _buildDivider(context),
            V3SettingMenuSubItemFocus(
              child: SizedBox(
                child: _buildAutoFillOTP(context, settingsProvider),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: context.tokens.spacing.vsdslSpacingSm.top,
                left: 24,
              ),
              child: _buildTextDesc(
                context,
                S.of(context).v3_settings_device_auto_fill_otp_desc,
              ),
            ),
            if (AppInstanceCreate().isInstalledInVBS200) ...[
              _buildDivider(context),
              V3SettingMenuSubItemFocus(
                child: SizedBox(
                  height: 26,
                  child: _buildLaunchOnStartup(context, settingsProvider),
                ),
              ),
            ],
            _buildDivider(context),
            V3SettingMenuSubItemFocus(
              child: SizedBox(
                child: _buildAuthorizeMode(context, settingsProvider),
              ),
            ),
            if (settingsProvider.isDeviceSettingLock) const Gap(51),
          ],
        ),
      );
    });
  }

  Widget _buildTextDesc(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 9,
        color: context.tokens.color.vsdslColorOnSurfaceVariant,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 1,
      margin: EdgeInsets.only(
          top: context.tokens.spacing.vsdslSpacingSm.top,
          bottom: context.tokens.spacing.vsdslSpacingSm.bottom),
      color: context.tokens.color.vsdslColorOutlineVariant,
    );
  }

  Widget _buildAuthorizeMode(
      BuildContext context, SettingsProvider settingsProvider) {
    return Consumer<ChannelProvider>(
      builder: (_, channelProvider, __) {
        trackClickApprove() {
          trackEvent(
            'click_approve_webrtc',
            EventCategory.setting,
            target: channelProvider.isAuthorizeMode ? 'on' : 'off',
          );
        }

        return Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: V3Focus(
                label: S.of(context).v3_lbl_settings_device_authorize_mode,
                identifier: "v3_qa_settings_device_authorize_mode",
                child: V3CustomCheckbox(
                  value: channelProvider.isAuthorizeMode,
                  isDisable: settingsProvider.isDeviceSettingLock,
                  onChanged: (bool? value) {
                    channelProvider.isAuthorizeMode = value ?? true;

                    trackClickApprove();
                  },
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.only(left: 4)),
            Expanded(
              child: InkWell(
                onTap: settingsProvider.isDeviceSettingLock
                    ? null
                    : () {
                        if (channelProvider.isAuthorizeMode) {
                          channelProvider.isAuthorizeMode = false;
                        } else {
                          channelProvider.isAuthorizeMode = true;
                        }

                        trackClickApprove();
                      },
                child: AutoSizeText(
                  S.of(context).v3_settings_device_authorize_mode,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLaunchOnStartup(
      BuildContext context, SettingsProvider settingsProvider) {
    return FutureBuilder(
      future: _getAutoStartUpSettings(),
      builder: (context, snapshot) {
        return Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: V3Focus(
                label: S.of(context).v3_lbl_settings_device_launch_on_startup,
                identifier: "v3_qa_settings_device_launch_on_startup",
                child: V3CustomCheckbox(
                  value: (snapshot.hasData) ? snapshot.data as bool : null,
                  isDisable: settingsProvider.isDeviceSettingLock,
                  tristate: true,
                  onChanged: (bool? value) {
                    setState(() {
                      _setAutoStartUpSettings(value ?? false);
                    });
                  },
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 4),
            ),
            Expanded(
              child: InkWell(
                onTap: settingsProvider.isDeviceSettingLock
                    ? null
                    : () {
                        bool? startup =
                            (snapshot.hasData) ? snapshot.data as bool : null;
                        if (startup != null) {
                          setState(() {
                            _setAutoStartUpSettings(!startup);
                          });
                        }
                      },
                child: AutoSizeText(
                  S.of(context).v3_settings_device_launch_on_startup,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAutoFillOTP(
      BuildContext context, SettingsProvider settingsProvider) {
    return Consumer<ChannelProvider>(
      builder: (_, channelProvider, __) {
        return Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: V3Focus(
                label: S.of(context).v3_lbl_settings_device_auto_fill_otp,
                identifier: "v3_qa_settings_device_auto_fill_otp",
                child: V3CustomCheckbox(
                  value: channelProvider.isDeviceListQuickConnect,
                  isDisable: settingsProvider.isDeviceSettingLock,
                  onChanged: (bool? value) {
                    if (channelProvider.isDeviceListQuickConnect) {
                      channelProvider.isDeviceListQuickConnect = false;
                    } else {
                      channelProvider.isDeviceListQuickConnect = true;
                    }

                    trackEvent(
                      'click_auto_fill_otp',
                      EventCategory.setting,
                      target: channelProvider.isDeviceListQuickConnect
                          ? 'on'
                          : 'off',
                    );
                  },
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 4),
            ),
            Expanded(
              child: InkWell(
                splashColor: Colors.transparent,
                onTap: settingsProvider.isDeviceSettingLock
                    ? null
                    : () {
                        if (channelProvider.isDeviceListQuickConnect) {
                          channelProvider.isDeviceListQuickConnect = false;
                        } else {
                          channelProvider.isDeviceListQuickConnect = true;
                        }

                        trackEvent(
                          'click_auto_fill_otp',
                          EventCategory.setting,
                          target: channelProvider.isDeviceListQuickConnect
                              ? 'on'
                              : 'off',
                        );
                      },
                child: AutoSizeText(
                  S.of(context).v3_settings_device_auto_fill_otp,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInviteGroup(
      BuildContext context, SettingsProvider settingsProvider) {
    return Row(
      children: [
        Expanded(
          child: Text(
            S.of(context).v3_settings_invite_group,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
        SizedBox(
          width: 105,
          child: CustomDropdown(
            isDisable: settingsProvider.isDeviceSettingLock,
            options: InvitedToGroupOption.invitedToGroupItems(context),
            selectedValue: InvitedToGroupOption.getInvitedToGroupString(
                context, int.parse(AppPreferences().invitedToGroup)),
            onChange: (String? value) {
              setState(() {
                final int optionValue =
                    InvitedToGroupOption.invitedToGroupItems(context)
                        .indexOf(value ?? '');

                trackEvent(
                  'click_broadcast_request',
                  EventCategory.setting,
                  target: InvitedToGroupOption.fromValue(optionValue).name,
                );

                AppPreferences().setInvitedToGroupSelectedItem(
                    item: optionValue.toString());
                DisplayServiceBroadcast.instance
                    .updateInvitedToGroupOption(optionValue.toString());
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShowDisplayCode(
      BuildContext context, SettingsProvider settingsProvider) {
    return FutureBuilder(
      future: AppOverlayTab().getVisibility(),
      builder: (context, snapshot) {
        bool isRunning = false;
        if (snapshot.hasData) {
          isRunning = snapshot.data as bool;
        }
        return V3SettingMenuItemToggleTile(
          label: S.of(context).v3_lbl_settings_show_display_code,
          identifier: "v3_qa_settings_show_display_code",
          switchOn: isRunning,
          isLocked: settingsProvider.isDeviceSettingLock,
          title: S.of(context).v3_settings_device_show_display_code,
          onTap: () async {
            _setVisibility(!isRunning);
          },
        );
      },
    );
  }

  Widget _buildSmartScaling(
      BuildContext context, SettingsProvider settingsProvider) {
    return Consumer<ChannelProvider>(builder: (_, channelProvider, __) {
      return V3SettingMenuItemToggleTile(
        label: S.of(context).v3_lbl_settings_device_smart_scaling,
        identifier: "v3_qa_settings_device_smart_scaling",
        switchOn: channelProvider.smartScaling,
        isLocked: settingsProvider.isDeviceSettingLock,
        title: S.of(context).v3_settings_device_smart_scaling,
        onTap: () async {
          channelProvider.smartScaling = !channelProvider.smartScaling;
        },
      );
    });
  }

  Widget _buildLanguage(
      BuildContext context, SettingsProvider settingsProvider) {
    PrefLanguageProvider languageProvider =
        Provider.of<PrefLanguageProvider>(context, listen: false);
    return V3SettingMenuNavigationTile(
      label: S.of(context).v3_lbl_main_language_title,
      identifier: "v3_qa_main_language_title",
      title: S.of(context).main_language_title,
      onTap: settingsProvider.isDeviceSettingLock
          ? null
          : () {
              settingsProvider.setPage(SettingPageState.deviceLanguage);
            },
      trialling: languageProvider.language,
      disable: settingsProvider.isDeviceSettingLock,
    );
  }

  Widget _buildDeviceName(
          BuildContext context, SettingsProvider settingsProvider) =>
      V3SettingMenuNavigationTile(
          label: S.of(context).v3_lbl_settings_device_name,
          identifier: "v3_qa_settings_device_name",
          title: S.of(context).v3_settings_device_name,
          focusNode: settingsProvider.subFocusNode,
          onTap: settingsProvider.isDeviceSettingLock
              ? null
              : () {
                  settingsProvider.setPage(SettingPageState.deviceName);
                },
          trialling: AppPreferences().instanceName,
          disable: settingsProvider.isDeviceSettingLock);

  _setVisibility(bool visible) async {
    trackEvent(
      'click_show_code',
      EventCategory.setting,
      target: visible ? 'on' : 'off',
    );

    await AppOverlayTab().setVisibility(visible);
    setState(() {});
  }

  Future<bool> _getAutoStartUpSettings() async {
    return await _autoStartUp
        .invokeMethod('getAutoStartupValue', <String, dynamic>{});
  }

  Future<void> _setAutoStartUpSettings(bool startup) async {
    await _autoStartUp.invokeMethod(
        'setAutoStartupValue', <String, dynamic>{'startup': startup});
  }
}

enum InvitedToGroupOption {
  notifyMe(0),
  autoAccept(1),
  ignore(2);

  final int value;

  const InvitedToGroupOption(this.value);

  static List<String> invitedToGroupItems(BuildContext context) {
    return _groupMap(context).values.toList();
  }

  static InvitedToGroupOption fromValue(int value) {
    return InvitedToGroupOption.values.firstWhere(
      (option) => option.value == value,
      orElse: () => InvitedToGroupOption.notifyMe, // Return a default value
    );
  }

  static Map<InvitedToGroupOption, String> _groupMap(BuildContext context) {
    final invitedToGroupMap = {
      InvitedToGroupOption.notifyMe:
          S.of(context).v3_settings_invite_group_notify_me,
      InvitedToGroupOption.autoAccept:
          S.of(context).v3_settings_invite_group_auto_accept,
      InvitedToGroupOption.ignore:
          S.of(context).v3_settings_invite_group_ignore,
    };
    return invitedToGroupMap;
  }

  static String getInvitedToGroupString(BuildContext context, int value) {
    // 找出對應的 InvitedToGroupOption
    final option = InvitedToGroupOption.values.firstWhere(
      (element) => element.value == value,
      orElse: () => InvitedToGroupOption.notifyMe, // 若找不到，預設使用 notifyMe
    );
    // 從 invitedToGroupMap 取得對應的 String
    return InvitedToGroupOption._groupMap(context)[option]!;
  }
}

class CustomDropdown extends StatefulWidget {
  const CustomDropdown(
      {super.key,
      this.isDisable = false,
      required this.options,
      required this.selectedValue,
      required this.onChange});

  final bool isDisable;
  final String selectedValue;
  final List<String> options;
  final Function(String?) onChange;

  @override
  CustomDropdownState createState() => CustomDropdownState();
}

class CustomDropdownState extends State<CustomDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  late List<FocusNode> overlayFocusNodes;

  void _showDropdownMenu() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    widget.options.asMap().entries.map((option) {
      if (option.value == widget.selectedValue) {
        overlayFocusNodes[option.key].requestFocus();
      }
    }).toList();
  }

  void _hideDropdownMenu() {
    for (var focusNode in overlayFocusNodes) {
      focusNode.unfocus(); // Reset focus to other widgets
    }
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        left: offset.dx,
        top: offset.dy + size.height,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height),
          child: TapRegion(
            groupId: V3SettingMenu.settingMenuGroupId,
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: context.tokens.color.vsdslColorOnSurfaceInverse,
                  borderRadius: context.tokens.radii.vsdslRadiusSm,
                ),
                child: FocusScope(
                  autofocus: true,
                  node: FocusScopeNode(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.options.asMap().entries.map((option) {
                      bool isSelected = option.value == widget.selectedValue;
                      return Focus(
                        child: Builder(builder: (context) {
                          final FocusNode focusNode = Focus.of(context);
                          final bool hasFocus = focusNode.hasFocus;
                          return V3Focus(
                            label: sprintf(
                                S.of(context).v3_lbl_settings_invite_group_item,
                                [option.value]),
                            identifier:
                                "v3_qa_settings_invite_group_${option.key}",
                            child: InkWell(
                              focusNode: overlayFocusNodes[option.key],
                              onTap: () {
                                _hideDropdownMenu();
                                widget.onChange.call(option.value);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: hasFocus
                                      ? context.tokens.color.vsdslColorPrimary
                                      : Colors.transparent,
                                  borderRadius:
                                      context.tokens.radii.vsdslRadiusSm,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        option.value,
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: hasFocus
                                              ? context.tokens.color
                                                  .vsdslColorOnPrimary
                                              : context.tokens.color
                                                  .vsdslColorOnSurface,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        size: 16,
                                        Icons.check,
                                        color: hasFocus
                                            ? context.tokens.color
                                                .vsdslColorOnSurfaceInverse
                                            : context.tokens.color
                                                .vsdslColorOnSurface,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        onKeyEvent: (FocusNode node, KeyEvent event) {
                          if (event.logicalKey == LogicalKeyboardKey.select ||
                              event.logicalKey == LogicalKeyboardKey.space ||
                              event.logicalKey == LogicalKeyboardKey.enter) {
                            if (event is KeyDownEvent) {
                              _hideDropdownMenu();
                              widget.onChange.call(option.value);
                            }
                            return KeyEventResult.handled;
                          }
                          return KeyEventResult.ignored;
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    overlayFocusNodes =
        List.generate(widget.options.length, (_) => FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: V3Focus(
        label: S.of(context).v3_lbl_settings_invite_group,
        identifier: "v3_qa_settings_invite_group",
        child: InkWell(
          onTap: widget.isDisable
              ? null
              : () {
                  setState(() {
                    if (_overlayEntry == null) {
                      _showDropdownMenu();
                    } else {
                      _hideDropdownMenu();
                    }
                  });
                },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: _overlayEntry != null
                  ? context.tokens.color.vsdslColorSurface300
                  : context.tokens.color.vsdslColorOnSurfaceInverse,
              borderRadius: context.tokens.radii.vsdslRadiusSm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Text(
                    widget.selectedValue,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9,
                      color: context.tokens.color.vsdslColorOnSurface
                          .withOpacity(widget.isDisable ? 0.32 : 1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  _overlayEntry != null
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 16,
                  color: context.tokens.color.vsdslColorOnSurface
                      .withOpacity(widget.isDisable ? 0.32 : 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hideDropdownMenu();
    for (var focusNode in overlayFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
