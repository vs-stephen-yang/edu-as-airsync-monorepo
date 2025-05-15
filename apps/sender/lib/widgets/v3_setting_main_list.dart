import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/pref_language_provider.dart';
import 'package:display_cast_flutter/providers/settings_provider.dart';
import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/utilities/v3_network_status_detector.dart';
import 'package:display_cast_flutter/utilities/v3_update_manager.dart';
import 'package:display_cast_flutter/utilities/version_util.dart';
import 'package:display_cast_flutter/widgets/V3_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';
import 'package:url_launcher/url_launcher.dart';

class V3SettingMainList extends StatelessWidget {
  const V3SettingMainList({super.key, this.isAppMode = false});

  static const String enKnowledgeBaseUrl =
      'https://myviewboard.com/kb/en_US/airsync-overview/airsync';
  static const String zhKnowledgeBaseUrl =
      'https://myviewboard.com/kb/t_CN/airsync-overview/airsync';
  final bool isAppMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Consumer<SettingsProvider>(builder: (_, settingsProvider, __) {
            List<SettingsItems> settings =
                _addSettingsToList(context, settingsProvider);
            return ListView.separated(
              physics: ClampingScrollPhysics(),
              itemCount: settings.length,
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(
                  width: 204,
                  child: V3Focus(
                    label: sprintf(S.current.v3_lbl_setting_select,
                        [settings[index].itemTitle]),
                    identifier: 'v3_qa_setting_select_$index',
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        shadowColor: Colors.transparent,
                        foregroundColor:
                            context.tokens.color.vsdswColorOnSurfaceInverse,
                        backgroundColor: !isAppMode &&
                                SettingsProvider.currentTittlePage.index ==
                                    index
                            ? context.tokens.color.vsdswColorPrimary
                            : context.tokens.color.vsdswColorSurface1000,
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: context.tokens.spacing.vsdswSpacingXs.top,
                          horizontal:
                              context.tokens.spacing.vsdswSpacingSm.left,
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
                          Expanded(
                            child: AutoSizeText(
                              settings[index].itemTitle,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          if (settings[index].itemIcon != null)
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: settings[index].itemIcon!,
                            ),
                        ],
                      ),
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
        ),
        AutoSizeText(
          VersionUtil.isOpenVersion
              ? S.of(context).v3_setting_app_version_independent(
                  DateTime.now().year, AppConfig.of(context)?.appVersion)
              : S.of(context).v3_setting_app_version(
                  DateTime.now().year, AppConfig.of(context)?.appVersion),
          minFontSize: 9,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: isAppMode ? 14 : 10,
            fontWeight: FontWeight.w400,
            color: context.tokens.color.vsdswColorOnSurfaceVariant,
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
        S.of(context).v3_setting_accessibility,
        SvgPicture.asset('assets/images/v3_ic_arrow_right.svg'),
        () {
          settingsProvider.setPage(SettingPageState.accessibility);
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
          trackEvent('click_news', EventCategory.setting);
          PrefLanguageProvider languageProvider =
              Provider.of<PrefLanguageProvider>(context, listen: false);
          var url = Uri.parse(enKnowledgeBaseUrl);
          if (languageProvider.language == '繁體中文') {
            url = Uri.parse(zhKnowledgeBaseUrl);
          }
          await launchUrl(url);
        },
      ),
    );
    list.add(
      SettingsItems(
        S.of(context).v3_setting_check_update,
        null,
        () {
          trackEvent('click_check_update', EventCategory.setting);

          if (V3NetworkStatusDetector().status == ConnectivityResult.none) {
            if (context.mounted) {
              V3UpdateManager()
                  .showUpdateDialog(context, CompareVersionResult.noNetwork);
            }
            return;
          }
          V3UpdateManager().checkUpdateVersion(context, (value) {
            if (context.mounted) {
              V3UpdateManager().showUpdateDialog(context, value);
            }
          });
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
