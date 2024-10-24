import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/settings_provider.dart';
import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class V3SettingMainList extends StatelessWidget {
  const V3SettingMainList({super.key, this.isAppMode = false});

  final bool isAppMode;

  @override
  Widget build(BuildContext context) {
    String appVersion = S
        .of(context)
        .v3_setting_app_version
        .replaceAll('%s', AppConfig.of(context)?.appVersion ?? '');
    return Stack(
      alignment: Alignment.center,
      children: [
        Consumer<SettingsProvider>(builder: (_, settingsProvider, __) {
          List<SettingsItems> settings =
              _addSettingsToList(context, settingsProvider);
          return ListView.separated(
            itemCount: settings.length,
            itemBuilder: (BuildContext context, int index) {
              return SizedBox(
                width: 204,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shadowColor: context.tokens.color.vsdswColorPrimary,
                    foregroundColor:
                        context.tokens.color.vsdswColorOnSurfaceInverse,
                    backgroundColor: !isAppMode &&
                            SettingsProvider.currentTittlePage.index == index
                        ? context.tokens.color.vsdswColorPrimary
                        : context.tokens.color.vsdswColorSurface1000,
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: context.tokens.spacing.vsdswSpacingXs.top,
                      horizontal: context.tokens.spacing.vsdswSpacingSm.left,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    settings[index].callback?.call();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        settings[index].itemTitle,
                      ),
                      const Spacer(),
                      if (settings[index].itemIcon != null)
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: settings[index].itemIcon!,
                        ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return Divider(
                thickness: 1,
                height: context.tokens.spacing.vsdswSpacingSm.vertical,
                color: context.tokens.color.vsdswColorOutlineVariant,
              );
            },
          );
        }),
        Positioned(
          bottom: isAppMode ? 40 : 0,
          right: isAppMode ? null : 0,
          child: AutoSizeText(
            appVersion,
            minFontSize: 9,
            style: TextStyle(
              fontSize: isAppMode ? 14 : 10,
              fontWeight: FontWeight.w400,
              color: context.tokens.color.vsdswColorOnSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  List<SettingsItems> _addSettingsToList(
      BuildContext context, SettingsProvider settingsProvider) {
    List<SettingsItems> list = [];
    list.add(
      SettingsItems(
        S.of(context).v3_setting_language,
        SvgPicture.asset('assets/images/v3_ic_arrow_right.svg'),
        () {
          settingsProvider.setPage(SettingPageState.language);
        },
      ),
    );
    list.add(
      SettingsItems(
        S.of(context).v3_setting_legal_policy,
        SvgPicture.asset('assets/images/v3_ic_arrow_right.svg'),
        () {
          settingsProvider.setPage(SettingPageState.legalPolicy);
        },
      ),
    );
    list.add(
      SettingsItems(
        S.of(context).v3_setting_knowledge_base,
        SvgPicture.asset('assets/images/v3_ic_setting_external.svg'),
        () async {
          var url = Uri.parse('https://myviewboard.com/kb/t_CN');
          await launchUrl(url);
        },
      ),
    );
    list.add(
      SettingsItems(
        S.of(context).v3_setting_check_update,
        null,
        () {
          //todo: implement ota mechanism.
        },
      ),
    );
    return list;
  }
}

class SettingsItems {
  String itemTitle;
  Widget? itemIcon;
  VoidCallback? callback;

  SettingsItems(this.itemTitle, this.itemIcon, this.callback);
}
