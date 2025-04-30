import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/pref_language_provider.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/widgets/v3_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';

class V3SettingLanguage extends StatelessWidget {
  const V3SettingLanguage({super.key, this.isAppMode = false});

  final bool isAppMode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: 24, vertical: isAppMode ? 8 : 40),
      child: Consumer<PrefLanguageProvider>(builder: (_, languageProvider, __) {
        String selectedLanguage = languageProvider.language;
        Map<String, Locale> languageList = languageProvider.localeMap;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: languageList.keys.toList().map<Widget>((String key) {
              return Container(
                height: 48,
                margin: EdgeInsets.only(
                  bottom: context.tokens.spacing.vsdswSpacingSm.bottom,
                ),
                child: V3Focus(
                  label: sprintf(
                      S.of(context).v3_lbl_setting_language_select, [key]),
                  identifier: 'v3_qa_setting_language_select',
                  button: true,
                  child: InkWell(
                    onTap: () {
                      trackEvent('click_language', EventCategory.setting);

                      selectedLanguage = key;
                      languageProvider.setLanguage(selectedLanguage);
                    },
                    child: SizedBox(
                      height: 28, // Android 要 48
                      child: ExcludeSemantics(
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              width: 20,
                              height: 20,
                              selectedLanguage == key
                                  ? 'assets/images/v3_ic_setting_radio_selected.svg'
                                  : 'assets/images/v3_ic_setting_radio_unselect.svg',
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                right:
                                    context.tokens.spacing.vsdswSpacingXs.right,
                              ),
                            ),
                            AutoSizeText(
                              key,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: context
                                    .tokens.color.vsdswColorOnSurfaceInverse,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }),
    );
  }
}
