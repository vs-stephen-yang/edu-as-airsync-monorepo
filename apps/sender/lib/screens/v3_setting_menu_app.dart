import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/settings_provider.dart';
import 'package:display_cast_flutter/widgets/V3_focus.dart';
import 'package:display_cast_flutter/widgets/v3_setting_accessibility.dart';
import 'package:display_cast_flutter/widgets/v3_setting_language.dart';
import 'package:display_cast_flutter/widgets/v3_setting_legal_policy.dart';
import 'package:display_cast_flutter/widgets/v3_setting_license.dart';
import 'package:display_cast_flutter/widgets/v3_setting_main_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:provider/provider.dart';

class V3SettingMenuApp extends StatelessWidget {
  const V3SettingMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog.fullscreen(
        backgroundColor: context.tokens.color.vsdswColorSurfaceInverse,
        child: Consumer<SettingsProvider>(
          builder: (context, settingsProvider, __) {
            String submenuTitle;
            Widget submenuWidget;
            switch (settingsProvider.currentPage) {
              case SettingPageState.language:
                submenuTitle = S.of(context).v3_setting_language;
                submenuWidget = const V3SettingLanguage(isAppMode: true);
                break;
              case SettingPageState.legalPolicy:
                submenuTitle = S.of(context).v3_setting_legal_policy;
                submenuWidget = const V3SettingsLegalPolicy(isAppMode: true);
                break;
              case SettingPageState.licenses:
                submenuTitle = settingsProvider.license?.name ??
                    S.of(context).v3_setting_privacy_policy;
                submenuWidget = const V3SettingLicense(isAppMode: true);
                break;
              case SettingPageState.accessibility:
                submenuTitle = S.of(context).v3_setting_accessibility;
                submenuWidget = const V3SettingAccessibility(isAppMode: true);
                break;
              default:
                submenuTitle = S.of(context).v3_setting_title;
                submenuWidget = const V3SettingMainList(isAppMode: true);
                break;
            }

            return Column(
              children: [
                SizedBox(
                  height: 100,
                  child: Stack(
                    children: [
                      Center(
                        child: AutoSizeText(
                          submenuTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color:
                                context.tokens.color.vsdswColorOnSurfaceInverse,
                          ),
                        ),
                      ),
                      if (settingsProvider.currentPage !=
                          SettingPageState.appHome)
                        Positioned(
                          left: 16,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: CircleAvatar(
                              backgroundColor:
                                  context.tokens.color.vsdswColorSurface900,
                              radius: 24,
                              child: V3Focus(
                                label: S.of(context).v3_lbl_setting_menu_back,
                                identifier: 'v3_qa_setting_menu_back',
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () {
                                    final settingsProvider =
                                        Provider.of<SettingsProvider>(context,
                                            listen: false);
                                    if (settingsProvider.currentPage ==
                                        SettingPageState.licenses) {
                                      settingsProvider.setPage(
                                          SettingPageState.legalPolicy);
                                    } else {
                                      settingsProvider
                                          .setPage(SettingPageState.appHome);
                                    }
                                  },
                                  child: SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Center(
                                      child: ExcludeSemantics(
                                        child: SvgPicture.asset(
                                          'assets/images/v3_ic_arrow_left.svg',
                                          width: 24,
                                          height: 24,
                                          color: context.tokens.color
                                              .vsdswColorOnTertiary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 0,
                        right: 16,
                        bottom: 0,
                        child: Center(
                          child: V3Focus(
                            label: S.of(context).v3_lbl_setting_menu_close,
                            identifier: 'v3_qa_setting_menu_close',
                            child: CircleAvatar(
                              backgroundColor:
                                  context.tokens.color.vsdswColorSurface900,
                              radius: 24,
                              child: InkWell(
                                onTap: () {
                                  if (navService.canPop()) {
                                    navService.goBack();
                                  }
                                },
                                borderRadius: BorderRadius.circular(24),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ExcludeSemantics(
                                    child: SvgPicture.asset(
                                      'assets/images/v3_ic_menu_close.svg',
                                      color: context.tokens.color
                                          .vsdswColorNeutralInverse,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: submenuWidget,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
