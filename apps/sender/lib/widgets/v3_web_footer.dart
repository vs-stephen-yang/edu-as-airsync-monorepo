import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/utilities/web_util.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class V3WebFooter extends StatelessWidget {
  const V3WebFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isBigThan768(context) ? 389 : 368,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/images/ic_wallpaper_web.png',
              width: 1920,
              // height: 160,
              alignment: Alignment.bottomCenter,
            ),
          ),
          Positioned(
            left: 0,
            top: isBigThan1920(context)
                ? 67
                : isBigThan1536(context)
                    ? 99
                    : isBigThan1280(context)
                        ? 120
                        : 143,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/ic_logo_viewsonic_web.png',
                  width: 189,
                  height: 31,
                ),
                const SizedBox(height: 30),
                TextButton(
                  onPressed: () {
                    launchUrl(Uri.parse(
                        '${Uri.base.scheme}://${Uri.base.authority}/legal/privacy_policy.html'));
                  },
                  child: AutoSizeText(
                    S.of(context).v3_main_privacy,
                    style: TextStyle(
                      fontSize: 16,
                      color: context.tokens.color.vsdswColorOnSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                AutoSizeText(
                  S.of(context).v3_main_copy_rights,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.tokens.color.vsdswColorOnSurfaceVariant,
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
