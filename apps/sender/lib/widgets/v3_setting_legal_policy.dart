import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/oss_licenses.dart';
import 'package:display_cast_flutter/providers/pref_text_scale_provider.dart';
import 'package:display_cast_flutter/providers/settings_provider.dart';
import 'package:display_cast_flutter/widgets/V3_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';

class V3SettingsLegalPolicy extends StatelessWidget {
  const V3SettingsLegalPolicy({super.key, this.isAppMode = false});

  final bool isAppMode;

  final List<String> _hiddenLicenses = const [
    'display_channel',
    'flutter_input_injection',
    'flutter_virtual_display',
  ];

  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    double textScale =
        Provider.of<TextScaleProvider>(context, listen: false).textSize.value;
    return Padding(
      padding: EdgeInsets.only(
        left: isAppMode ? 16 : 24,
        top: isAppMode ? 0 : 40,
        right: isAppMode ? 16 : 24,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          V3Focus(
            label: S.of(context).v3_lbl_setting_privacy_policy,
            identifier: 'v3_qa_setting_privacy_policy',
            child: SizedBox(
              height: (WebRTC.platformIsMobile ? 44 : 40) * textScale,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: context.tokens.spacing.vsdswSpacingXs.top,
                  horizontal: context.tokens.spacing.vsdswSpacingSm.left,
                ),
                child: Row(
                  children: [
                    AutoSizeText(
                      S.of(context).v3_setting_privacy_policy,
                      style: TextStyle(
                        color: context.tokens.color.vsdswColorOnSurfaceInverse,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    ExcludeSemantics(
                      child: IconButton(
                        icon: SvgPicture.asset(
                            'assets/images/v3_ic_arrow_right.svg'),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          settingsProvider.setPage(SettingPageState.licenses);
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 1,
            margin: EdgeInsets.symmetric(
              vertical: context.tokens.spacing.vsdswSpacingSm.top,
            ),
            color: context.tokens.color.vsdswColorOutlineVariant,
          ),
          SizedBox(
            width: 376,
            height: 40 * textScale,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: context.tokens.spacing.vsdswSpacingXs.top,
                horizontal: context.tokens.spacing.vsdswSpacingSm.left,
              ),
              child: AutoSizeText(
                S.of(context).v3_setting_open_source_license,
                style: TextStyle(
                  color: context.tokens.color.vsdswColorOnSurfaceInverse,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 24),
              child: ListView.separated(
                itemCount: dependencies
                    .where((license) => !_hiddenLicenses.contains(license.name))
                    .length,
                itemBuilder: (BuildContext context, int index) {
                  final visibleLicenses = dependencies
                      .where(
                          (license) => !_hiddenLicenses.contains(license.name))
                      .toList();
                  final license = visibleLicenses[index];
                  return V3Focus(
                    label: sprintf(S.of(context).v3_lbl_setting_legal_policy,
                        [license.name]),
                    identifier: sprintf(
                        'v3_qa_setting_legal_policy %s', [license.name]),
                    child: SizedBox(
                      width: 352,
                      height: (WebRTC.platformIsMobile ? 44 : 40) * textScale,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: context.tokens.spacing.vsdswSpacingXs.top,
                            horizontal:
                                context.tokens.spacing.vsdswSpacingSm.left),
                        child: Row(
                          children: [
                            Expanded(
                              child: AutoSizeText(
                                license.name,
                                style: TextStyle(
                                  color: context
                                      .tokens.color.vsdswColorOnSurfaceInverse,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            ExcludeSemantics(
                              child: IconButton(
                                icon: SvgPicture.asset(
                                    'assets/images/v3_ic_arrow_right.svg'),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  settingsProvider.setPage(
                                      SettingPageState.licenses,
                                      license: license);
                                },
                              ),
                            )
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
