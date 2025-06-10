import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/message_dialog_provider.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/widgets/v3_accessibility.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_scrollbar.dart';
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
                  // 使用拆分出來的左側選單組件
                  _V3SettingMenuSidebar(settingsProvider: settingsProvider),
                  Container(
                    width: 1,
                    color: context.tokens.color.vsdslColorOutlineVariant,
                  ),
                  Expanded(
                    child: FocusTraversalGroup(
                      child: Builder(
                        builder: (context) {
                          final bool openedWithLogicalKey = HardwareKeyboard
                              .instance.logicalKeysPressed.isNotEmpty;

                          // setting language menu page will trigger rebuild page when by itself, if that so need to provide focus to sub focus node
                          if (openedWithLogicalKey &&
                              settingsProvider.currentPage !=
                                  SettingPageState.deviceLanguage) {
                            settingsProvider.resetSubFocusNode();
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              settingsProvider.requestSubFocus();
                            });
                          }

                          switch (settingsProvider.currentPage) {
                            case SettingPageState.deviceSetting:
                              return const V3SettingsDevice();
                            case SettingPageState.accessibility:
                              return const V3Accessibility();
                            case SettingPageState.deviceName:
                              return V3SettingsDeviceName(
                                  focusNode: settingsProvider.subFocusNode ??
                                      FocusNode(),
                                  openedWithLogicalKey: openedWithLogicalKey);
                            case SettingPageState.deviceLanguage:
                              return V3SettingsDeviceLanguage(
                                  openedWithLogicalKey: openedWithLogicalKey);
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
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    if (settingsProvider.currentPage == SettingPageState.deviceName &&
        (settingsProvider.subFocusNode?.hasFocus ?? false)) {
      return;
    }
    if (navService.canPop()) {
      navService.goBack();
    }
  }
}

class _V3SettingMenuSidebar extends StatelessWidget {
  const _V3SettingMenuSidebar({
    required this.settingsProvider,
  });

  final SettingsProvider settingsProvider;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 166,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 頂部標題
          Padding(
            padding: const EdgeInsets.only(left: 13, top: 13),
            child: AutoSizeText(
              S.of(context).main_settings_title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.tokens.color.vsdslColorOnSurfaceInverse),
            ),
          ),

          // 中間可滾動列表
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13),
              child: Builder(
                builder: (context) {
                  final ScrollController scrollController = ScrollController();
                  return V3Scrollbar(
                    controller: scrollController,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.only(right: 8), // 為滾動條留出空間
                      child: Column(
                        children: <Widget>[
                          _SubTittleButton(
                            label: S.current.v3_lbl_settings_device_setting,
                            identifier: "v3_qa_settings_device_setting",
                            index: 0,
                            state: SettingPageState.deviceSetting,
                            text: S.of(context).v3_settings_device_setting,
                            locked: settingsProvider.isDeviceSettingLock,
                            onClick: () => settingsProvider
                                .setPage(SettingPageState.deviceSetting),
                          ),
                          const Padding(padding: EdgeInsets.only(bottom: 5)),
                          _SubTittleButton(
                            label: S.current.v3_lbl_settings_accessibility,
                            identifier: "v3_qa_settings_accessibility",
                            index: 1,
                            state: SettingPageState.accessibility,
                            text: S.of(context).v3_settings_accessibility,
                            locked: false,
                            onClick: () => settingsProvider
                                .setPage(SettingPageState.accessibility),
                          ),
                          const Padding(padding: EdgeInsets.only(bottom: 5)),
                          _SubTittleButton(
                            label: S.current.v3_lbl_settings_broadcast,
                            identifier: "v3_qa_settings_broadcast",
                            index: 2,
                            state: SettingPageState.broadcast,
                            text: S.of(context).v3_settings_broadcast,
                            locked: settingsProvider.isBroadcastLock,
                            onClick: () => settingsProvider
                                .setPage(SettingPageState.broadcast),
                          ),
                          const Padding(padding: EdgeInsets.only(bottom: 5)),
                          _SubTittleButton(
                            label: S.current.v3_lbl_shortcuts_mirroring,
                            identifier: "v3_qa_shortcuts_mirroring",
                            index: 3,
                            state: SettingPageState.mirroring,
                            text: S.of(context).v3_shortcuts_mirroring,
                            locked: settingsProvider.isMirroringLock,
                            onClick: () => settingsProvider
                                .setPage(SettingPageState.mirroring),
                          ),
                          const Padding(padding: EdgeInsets.only(bottom: 5)),
                          _SubTittleButton(
                            label: S.current.v3_lbl_settings_connectivity,
                            identifier: "v3_qa_settings_connectivity",
                            index: 4,
                            state: SettingPageState.connectivity,
                            text: S.of(context).v3_settings_connectivity,
                            locked: settingsProvider.isConnectivityLock,
                            onClick: () => settingsProvider
                                .setPage(SettingPageState.connectivity),
                          ),
                          const Padding(padding: EdgeInsets.only(bottom: 5)),
                          _SubTittleButton(
                            label: S.current.v3_lbl_settings_whats_new,
                            identifier: "v3_qa_settings_whats_new",
                            index: 5,
                            state: SettingPageState.whatsNew,
                            text: S.of(context).v3_settings_whats_new,
                            locked: false,
                            onClick: () => settingsProvider
                                .setPage(SettingPageState.whatsNew),
                          ),
                          const Padding(padding: EdgeInsets.only(bottom: 5)),
                          _SubTittleButton(
                            label: S.current.v3_lbl_settings_legal_policy,
                            identifier: "v3_qa_settings_legal_policy",
                            index: 6,
                            state: SettingPageState.legalPolicy,
                            text: S.of(context).v3_settings_legal_policy,
                            locked: false,
                            onClick: () => settingsProvider
                                .setPage(SettingPageState.legalPolicy),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // 底部版本資訊和關閉按鈕
          Padding(
            padding: const EdgeInsets.only(left: 13, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    S.of(context).v3_settings_version(DateTime.now().year,
                        AppConfig.of(context)?.appVersion ?? ''),
                    semanticsLabel: "v3_qa_settings_version_text",
                    style: TextStyle(
                      color: context.tokens.color.vsdslColorOnSurfaceInverse,
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                V3Focus(
                  label: S.current.v3_lbl_settings_close_icon,
                  identifier: "v3_qa_settings_close_icon",
                  child: SizedBox(
                    width: 33,
                    height: 33,
                    child: IconButton(
                      icon: SvgPicture.asset('assets/images/ic_menu_close.svg'),
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
    );
  }
}

class _SubTittleButton extends StatelessWidget {
  const _SubTittleButton({
    required this.state,
    required this.text,
    required this.locked,
    required this.index,
    required this.onClick,
    this.label,
    this.identifier,
  });

  final SettingPageState state;
  final String text;
  final bool locked;
  final int index;
  final void Function() onClick;
  final String? label;
  final String? identifier;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SettingsProvider>(context);
    return V3Focus(
      label: label,
      identifier: identifier,
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
