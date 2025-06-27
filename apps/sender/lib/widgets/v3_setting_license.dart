import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/settings_provider.dart';
import 'package:display_cast_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_cast_flutter/widgets/v3_scroll_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class V3SettingLicense extends StatelessWidget {
  const V3SettingLicense({super.key, this.isAppMode = false});

  final bool isAppMode;

  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    return Stack(
      children: [
        if (!isAppMode)
          Positioned(
              left: 0,
              top: 0,
              child: Row(
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                        width: 24,
                        height: 24,
                        'assets/images/v3_ic_arrow_left.svg'),
                    onPressed: () {
                      settingsProvider.setPage(SettingPageState.legalPolicy);
                    },
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                          right: context.tokens.spacing.vsdswSpacingXs.right)),
                  V3AutoHyphenatingText(
                    settingsProvider.license?.name ??
                        S.of(context).v3_setting_privacy_policy,
                    style: TextStyle(
                      color: context.tokens.color.vsdswColorOnSurfaceInverse,
                      fontSize: 14,
                    ),
                  ),
                ],
              )),
        Positioned(
          top: isAppMode ? 0 : 40,
          left: isAppMode ? 16 : 24,
          right: isAppMode ? 16 : 24,
          bottom: isAppMode ? 16 : 24,
          child: Builder(builder: (context) {
            final sc = ScrollController();
            return V3MenuScrollbar(
              controller: sc,
              child: SingleChildScrollView(
                controller: sc,
                child: V3AutoHyphenatingText(
                  settingsProvider.license?.license ??
                      S.of(context).v3_setting_privacy_policy_description,
                  style: TextStyle(
                    color: context.tokens.color.vsdswColorOnSurfaceInverse,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
