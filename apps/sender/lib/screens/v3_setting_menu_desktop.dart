import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/settings_provider.dart';
import 'package:display_cast_flutter/widgets/V3_focus.dart';
import 'package:display_cast_flutter/widgets/v3_setting_language.dart';
import 'package:display_cast_flutter/widgets/v3_setting_legal_policy.dart';
import 'package:display_cast_flutter/widgets/v3_setting_license.dart';
import 'package:display_cast_flutter/widgets/v3_setting_main_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:provider/provider.dart';

class V3SettingMenuDesktop extends StatelessWidget {
  const V3SettingMenuDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      alignment: Alignment.bottomLeft,
      backgroundColor: context.tokens.color.vsdswColorSurfaceInverse,
      insetPadding: const EdgeInsets.only(left: 8, bottom: 8),
      child: SizedBox(
        width: 660,
        height: 455,
        child: Row(
          children: [
            SizedBox(
              width: 235,
              child: Stack(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
                    ),
                    child: V3SettingMainList(isAppMode: false),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: V3Focus(
                      label: S.of(context).v3_lbl_setting_menu_close,
                      identifier: 'v3_qa_setting_menu_close',
                      button: true,
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
                            child: SvgPicture.asset(
                              'assets/images/v3_ic_menu_close.svg',
                              excludeFromSemantics: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              color: context.tokens.color.vsdswColorOutlineVariant,
            ),
            Expanded(
              child: Consumer<SettingsProvider>(
                builder: (context, settingsProvider, _) {
                  switch (settingsProvider.currentPage) {
                    case SettingPageState.language:
                      return const V3SettingLanguage();
                    case SettingPageState.legalPolicy:
                      return const V3SettingsLegalPolicy();
                    case SettingPageState.licenses:
                      return const V3SettingLicense();
                    default:
                      return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
