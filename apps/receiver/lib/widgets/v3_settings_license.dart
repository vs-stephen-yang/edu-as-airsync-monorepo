import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:display_flutter/widgets/v3_focus_single_child_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class V3SettingsLicense extends StatelessWidget {
  const V3SettingsLicense({super.key});

  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    return Stack(
      children: [
        Positioned(
            left: 0,
            top: 0,
            child: Row(
              children: [
                IconButton(
                  icon: const Image(
                    image: Svg('assets/images/ic_arrow_left.svg'),
                    width: 21,
                    height: 21,
                  ),
                  onPressed: () {
                    settingsProvider.setPage(SettingPageState.legalPolicy);
                  },
                ),
                Padding(
                    padding: EdgeInsets.only(
                        right: context.tokens.spacing.vsdslSpacingXs.right)),
                Text(
                  settingsProvider.license?.name ??
                      S.of(context).v3_settings_privacy_policy,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            )),
        Positioned(
          top: 46,
          left: 13,
          right: 13,
          bottom: 13,
          child: V3FocusSingleChildScrollView(
            thumbColor: Colors.transparent,
            children: [
              Text(
                settingsProvider.license?.license ??
                    S.of(context).v3_settings_privacy_policy_description,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
