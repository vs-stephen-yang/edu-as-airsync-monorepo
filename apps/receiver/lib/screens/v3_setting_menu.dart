import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/message_dialog_provider.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_settings_broadcast.dart';
import 'package:display_flutter/widgets/v3_settings_cast_to_boards.dart';
import 'package:display_flutter/widgets/v3_settings_connectivity.dart';
import 'package:display_flutter/widgets/v3_settings_device.dart';
import 'package:display_flutter/widgets/v3_settings_device_language.dart';
import 'package:display_flutter/widgets/v3_settings_device_name.dart';
import 'package:display_flutter/widgets/v3_settings_legal_policy.dart';
import 'package:display_flutter/widgets/v3_settings_license.dart';
import 'package:display_flutter/widgets/v3_settings_mirroring.dart';
import 'package:display_flutter/widgets/v3_settings_whats_new.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:provider/provider.dart';

class V3SettingMenu extends StatefulWidget {
  const V3SettingMenu({super.key, required this.openedWithLogicalKey});

  static const String settingMenuGroupId = 'V3SettingMenu';
  static final FocusNode _childFocusNode = FocusNode();
  final bool openedWithLogicalKey;

  @override
  State<V3SettingMenu> createState() => _V3SettingMenuState();
}

class _V3SettingMenuState extends State<V3SettingMenu> {
  @override
  void initState() {
    super.initState();
    if (widget.openedWithLogicalKey) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<SettingsProvider>(context, listen: false)
            .resetThenFocusMenuPrimary();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      groupId: V3SettingMenu.settingMenuGroupId,
      onTapOutside: (event) {
        if (riverpod.ProviderScope.containerOf(context)
            .read(dialogProvider)
            .isVisible) return;
        dismissMenu();
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.bottomLeft,
        backgroundColor: context.tokens.color.vsdslColorSurface1000,
        insetPadding: const EdgeInsets.only(left: 8, bottom: 8),
        child: SizedBox(
          width: 518,
          height: 413,
          child: Consumer<SettingsProvider>(
            builder: (context, settingsProvider, child) {
              return Row(
                children: [
                  SizedBox(
                    width: 166,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 13,
                          top: 13,
                          child: AutoSizeText(
                            S.of(context).main_settings_title,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        ),
                        Positioned(
                          left: 13,
                          top: 57,
                          right: 13,
                          child: Column(
                            children: <Widget>[
                              _SubTittleButton(
                                index: 0,
                                state: SettingPageState.deviceSetting,
                                text: S.of(context).v3_settings_device_setting,
                                locked: settingsProvider.isDeviceSettingLock,
                                onClick: () => settingsProvider
                                    .setPage(SettingPageState.deviceSetting),
                              ),
                              const Padding(
                                  padding: EdgeInsets.only(bottom: 5)),
                              _SubTittleButton(
                                index: 1,
                                state: SettingPageState.broadcast,
                                text: S.of(context).v3_settings_broadcast,
                                locked: settingsProvider.isBroadcastLock,
                                onClick: () => settingsProvider
                                    .setPage(SettingPageState.broadcast),
                              ),
                              const Padding(
                                  padding: EdgeInsets.only(bottom: 5)),
                              _SubTittleButton(
                                index: 2,
                                state: SettingPageState.mirroring,
                                text: S.of(context).v3_shortcuts_mirroring,
                                locked: settingsProvider.isMirroringLock,
                                onClick: () => settingsProvider
                                    .setPage(SettingPageState.mirroring),
                              ),
                              const Padding(
                                  padding: EdgeInsets.only(bottom: 5)),
                              _SubTittleButton(
                                index: 3,
                                state: SettingPageState.connectivity,
                                text: S.of(context).v3_settings_connectivity,
                                locked: settingsProvider.isConnectivityLock,
                                onClick: () => settingsProvider
                                    .setPage(SettingPageState.connectivity),
                              ),
                              const Padding(
                                  padding: EdgeInsets.only(bottom: 5)),
                              _SubTittleButton(
                                index: 4,
                                state: SettingPageState.whatsNew,
                                text: S.of(context).v3_settings_whats_new,
                                locked: false,
                                onClick: () => settingsProvider
                                    .setPage(SettingPageState.whatsNew),
                              ),
                              const Padding(
                                  padding: EdgeInsets.only(bottom: 5)),
                              _SubTittleButton(
                                index: 5,
                                state: SettingPageState.legalPolicy,
                                text: S.of(context).v3_settings_legal_policy,
                                locked: false,
                                onClick: () => settingsProvider
                                    .setPage(SettingPageState.legalPolicy),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 8,
                          bottom: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 5, bottom: 10),
                                child: Text(
                                  S.of(context).v3_settings_version(
                                      DateTime.now().year,
                                      AppConfig.of(context)?.appVersion ?? ''),
                                  style: TextStyle(
                                    color: context
                                        .tokens.color.vsdslColorSurface700,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              V3Focus(
                                child: SizedBox(
                                  width: 33,
                                  height: 33,
                                  child: IconButton(
                                    icon: SvgPicture.asset(
                                        'assets/images/ic_menu_close.svg'),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      if (navService.canPop()) {
                                        navService.goBack();
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    color: context.tokens.color.vsdslColorOutlineVariant,
                  ),
                  Expanded(
                    child: FocusScope(
                      child: Builder(
                        builder: (context) {
                          final bool openedWithLogicalKey = HardwareKeyboard
                              .instance.logicalKeysPressed.isNotEmpty;
                          if (openedWithLogicalKey) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              settingsProvider.requestSubFocus();
                            });
                          }
                          switch (settingsProvider.currentPage) {
                            case SettingPageState.deviceSetting:
                              return const V3SettingsDevice();
                            case SettingPageState.deviceName:
                              return V3SettingsDeviceName(
                                  focusNode: V3SettingMenu._childFocusNode);
                            case SettingPageState.deviceLanguage:
                              return const V3SettingsDeviceLanguage();
                            case SettingPageState.broadcast:
                              return const V3SettingsBroadcast();
                            case SettingPageState.broadcastBoards:
                              return const V3SettingsCastToBoards();
                            case SettingPageState.mirroring:
                              return const V3SettingsMirroring();
                            case SettingPageState.connectivity:
                              return const V3SettingsConnectivity();
                            case SettingPageState.whatsNew:
                              return const V3SettingsWhatsNew();
                            case SettingPageState.legalPolicy:
                              return const V3SettingsLegalPolicy();
                            case SettingPageState.licenses:
                              return const V3SettingsLicense();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void dismissMenu() {
    // 點擊text cursor做操作會被TapRegion判定為onTapOutside
    if (V3SettingMenu._childFocusNode.hasFocus) {
      return;
    }
    if (navService.canPop()) {
      navService.goBack();
    }
  }
}

class _SubTittleButton extends StatelessWidget {
  const _SubTittleButton({
    required this.state,
    required this.text,
    required this.locked,
    required this.index,
    required this.onClick,
  });

  final SettingPageState state;
  final String text;
  final bool locked;
  final int index;
  final void Function() onClick;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SettingsProvider>(context);
    return V3Focus(
      onFocusMove: (node, event) =>
          provider.onMainFocusMove(node, event, onClick, state),
      child: InkWell(
        focusNode: provider.getMenuFocusNode(index),
        onTap: onClick,
        child: Container(
          width: 140,
          padding: EdgeInsets.symmetric(
            vertical: context.tokens.spacing.vsdslSpacingSm.top,
            horizontal: context.tokens.spacing.vsdslSpacingMd.left,
          ),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: SettingsProvider.currentTittlePage == state
                ? context.tokens.color.vsdslColorPrimary
                : context.tokens.color.vsdslColorSurface1000,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (locked)
                SizedBox(
                  width: 11,
                  height: 11,
                  child: SvgPicture.asset('assets/images/ic_lock.svg'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
