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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

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
    PrefLanguageProvider languageProvider =
        Provider.of<PrefLanguageProvider>(context, listen: false);
    SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(left: 13, top: 57, right: 13),
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
            child: _buildLanguage(context, languageProvider, settingsProvider),
          ),
          _buildDivider(context),
          SizedBox(height: 26, child: _buildShowDisplayCode(context)),
          Padding(
            padding: EdgeInsets.only(
              top: context.tokens.spacing.vsdslSpacingSm.top,
            ),
            child: _buildTextDesc(
              context,
              S.of(context).v3_settings_device_show_display_code_desc,
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
            SizedBox(
              height: 26,
              child: _buildLaunchOnStartup(context),
            ),
          ],
          _buildDivider(context),
          Consumer<ChannelProvider>(
            builder: (_, channelProvider, __) {
              return SizedBox(
                height: 26,
                child: _buildAuthorizeMode(context, channelProvider),
              );
            },
          ),
        ],
      ),
    );
  }

  Text _buildTextDesc(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 9,
        color: context.tokens.color.vsdslColorOnSurfaceVariant,
        fontWeight: FontWeight.w400,
      ),
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

  Widget _buildAuthorizeMode(
      BuildContext context, ChannelProvider channelProvider) {
    trackClickApprove() {
      trackEvent(
        'clcik_approve_webrtc',
        EventCategory.setting,
        target: channelProvider.isAuthorizeMode ? 'on' : 'off',
      );
    }

    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: channelProvider.isAuthorizeMode,
            activeColor: context.tokens.color.vsdslColorPrimary,
            onChanged: (bool? value) {
              channelProvider.isAuthorizeMode = value ?? true;

              trackClickApprove();
            },
          ),
        ),
        const Padding(padding: EdgeInsets.only(left: 4)),
        InkWell(
          onTap: () {
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
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildLaunchOnStartup(BuildContext context) {
    return FutureBuilder(
      future: _getAutoStartUpSettings(),
      builder: (context, snapshot) {
        return Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: (snapshot.hasData) ? snapshot.data as bool : null,
                tristate: true,
                activeColor: context.tokens.color.vsdslColorPrimary,
                onChanged: (bool? value) {
                  setState(() {
                    _setAutoStartUpSettings(value ?? false);
                  });
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 4),
            ),
            InkWell(
              onTap: () {
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
                maxLines: 1,
              ),
            ),
          ],
        );
      },
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
              activeColor: context.tokens.color.vsdslColorPrimary,
              onChanged: (bool? value) {
                if (channelProvider.isDeviceListQuickConnect) {
                  channelProvider.isDeviceListQuickConnect = false;
                } else {
                  channelProvider.isDeviceListQuickConnect = true;
                }

                trackEvent(
                  'click_auto_fill_otp',
                  EventCategory.setting,
                  target:
                      channelProvider.isDeviceListQuickConnect ? 'on' : 'off',
                );
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

            trackEvent(
              'click_auto_fill_otp',
              EventCategory.setting,
              target: channelProvider.isDeviceListQuickConnect ? 'on' : 'off',
            );
          },
          child: AutoSizeText(
            S.of(context).v3_settings_device_auto_fill_otp,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownMenu(BuildContext context) {
    return CustomDropdown(
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

          AppPreferences()
              .setInvitedToGroupSelectedItem(item: optionValue.toString());
          DisplayServiceBroadcast.instance
              .updateInvitedToGroupOption(optionValue.toString());
        });
      },
    );
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
          style: TextStyle(
            color: context.tokens.color.vsdslColorOnSurfaceInverse,
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
            return SizedBox(
              height: 21,
              child: IconButton(
                icon: Image(
                  image: Svg(isRunning
                      ? 'assets/images/ic_switch_on.svg'
                      : 'assets/images/ic_switch_off.svg'),
                ),
                padding: EdgeInsets.zero,
                // constraints: const BoxConstraints(),
                onPressed: () async {
                  _setVisibility(!isRunning);
                },
              ),
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
      required this.options,
      required this.selectedValue,
      required this.onChange});

  final String selectedValue;
  final List<String> options;
  final Function(String?) onChange;

  @override
  CustomDropdownState createState() => CustomDropdownState();
}

class CustomDropdownState extends State<CustomDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _showDropdownMenu() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideDropdownMenu() {
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.options.map((option) {
                    bool isSelected = option == widget.selectedValue;
                    return GestureDetector(
                      onTap: () {
                        _hideDropdownMenu();
                        widget.onChange.call(option);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.tokens.color.vsdslColorPrimary
                              : Colors.transparent,
                          borderRadius: context.tokens.radii.vsdslRadiusSm,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isSelected
                                      ? context.tokens.color.vsdslColorOnPrimary
                                      : context
                                          .tokens.color.vsdslColorOnSurface,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                size: 16,
                                Icons.check,
                                color: context
                                    .tokens.color.vsdslColorOnSurfaceInverse,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
        fontSize: 9,
        color: context.tokens.color.vsdslColorOnSurface,
        fontWeight: FontWeight.w600);
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () {
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
              Text(
                widget.selectedValue,
                style: textStyle,
              ),
              const Spacer(),
              Icon(
                  _overlayEntry != null
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 16,
                  color: context.tokens.color.vsdslColorOnSurface),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hideDropdownMenu();
    super.dispose();
  }
}
