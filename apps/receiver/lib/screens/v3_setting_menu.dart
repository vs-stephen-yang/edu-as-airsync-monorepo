import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:display_flutter/screens/v3_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class V3SettingMenu extends StatelessWidget {
  const V3SettingMenu({super.key});

  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);

    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.bottomLeft,
        backgroundColor: const Color(0xFF151C32),
        insetPadding: const EdgeInsets.only(left: 8, bottom: 8),
        child: SizedBox(
            width: 518,
            height: 413,
            child: Consumer<SettingsProvider>(
              builder: (context, value, child) {
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
                                _subTittleButton(context,
                                    state: SettingPageState.deviceSetting,
                                    text: S
                                        .of(context)
                                        .v3_settings_device_setting,
                                    onClick: () {
                                  settingsProvider
                                      .setPage(SettingPageState.deviceSetting);
                                }),
                                _subTittleButton(context,
                                    state: SettingPageState.broadcast,
                                    text: S.of(context).v3_settings_broadcast,
                                    onClick: () {
                                  settingsProvider
                                      .setPage(SettingPageState.broadcast);
                                }),
                                _subTittleButton(context,
                                    state: SettingPageState.connectivity,
                                    text: S
                                        .of(context)
                                        .v3_settings_connectivity, onClick: () {
                                  settingsProvider
                                      .setPage(SettingPageState.connectivity);
                                }),
                                _subTittleButton(context,
                                    state: SettingPageState.mirroring,
                                    text: S.of(context).v3_shortcuts_mirroring,
                                    onClick: () {
                                  settingsProvider
                                      .setPage(SettingPageState.mirroring);
                                }),
                                _subTittleButton(context,
                                    state: SettingPageState.whatsNew,
                                    text: S.of(context).v3_settings_whats_new,
                                    onClick: () {
                                  settingsProvider
                                      .setPage(SettingPageState.whatsNew);
                                }),
                              ],
                            ),
                          ),
                          Positioned(
                            left: 8,
                            bottom: 8,
                            child: SizedBox(
                              width: 33,
                              height: 33,
                              child: IconButton(
                                icon: const Image(
                                  image: Svg('assets/images/ic_menu_close.svg'),
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  V3Home.isShowSettingsMenu.value = false;
                                },
                              ),
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
                      child: Builder(
                        builder: (context) {
                          switch (value.currentPage) {
                            case SettingPageState.deviceSetting:
                            // TODO: Handle this case.
                            case SettingPageState.deviceName:
                            // TODO: Handle this case.
                            case SettingPageState.deviceLanguage:
                            // TODO: Handle this case.
                            case SettingPageState.broadcast:
                            // TODO: Handle this case.
                            case SettingPageState.mirroring:
                            // TODO: Handle this case.
                            case SettingPageState.connectivity:
                            // TODO: Handle this case.
                            case SettingPageState.whatsNew:
                              // TODO: Handle this case.
                              return SizedBox();
                          }
                        },
                      ),
                    ),
                  ],
                );
              },
            )));
  }

  _subTittleButton(BuildContext context,
      {required SettingPageState state,
      required String text,
      required VoidCallback onClick}) {
    return InkWell(
      onTap: () {
        onClick();
      },
      child: Container(
        width: 140,
        height: 30,
        padding: const EdgeInsets.only(left: 16),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: SettingsProvider.currentTittlePage == state
              ? context.tokens.color.vsdslColorSecondary
              : const Color(0xFF151C32),
          borderRadius: BorderRadius.circular(15),
        ),
        child: AutoSizeText(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
          maxLines: 1,
        ),
      ),
    );
  }
}
