import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/utilities/web_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class V3WebDownload extends StatelessWidget {
  const V3WebDownload({super.key});

  final windowLink = 'https://dl.myviewboard.com/latest?airsyncsender_windows';
  final macLink =
      'macappstore://apps.apple.com/app/airsync-sender/id6453759985';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 700,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            top: isBigThan1536(context)
                ? 162
                : isBigThan1280(context)
                    ? 184
                    : 131,
            right: 0,
            child: const Image(
              width: 1022,
              height: 215,
              image: Svg('assets/images/ic_web_planetary_rings.svg'),
            ),
          ),
          Positioned(
            top: isBigThan1536(context)
                ? 124
                : isBigThan1280(context)
                    ? 146
                    : 80,
            child: Column(
              children: [
                Image.asset('assets/images/ic_logo_airsync_icon.png'),
                const SizedBox(height: 6),
                AutoSizeText(
                  S.of(context).v3_main_download_title,
                  style: TextStyle(
                    fontSize: 32,
                    color: context.tokens.color.vsdslColorOnSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                AutoSizeText(
                  S.of(context).v3_main_download_desc,
                  style: TextStyle(
                    fontSize: 20,
                    color: context.tokens.color.vsdslColorOnSurfaceVariant,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: isBigThan1280(context) ? 455 : 349,
            child: Wrap(
              direction:
                  isBigThan1280(context) ? Axis.horizontal : Axis.vertical,
              children: [
                V3WebDownloadItem(
                  leadingSvg: 'assets/images/ic_web_download_windows.svg',
                  title: S.of(context).v3_main_download_win_title,
                  subtitle: S.of(context).v3_main_download_win_subtitle,
                  action: S.of(context).v3_main_download_action_download,
                  onClick: () {
                    launchUrl(Uri.parse(windowLink));
                  },
                ),
                const SizedBox(width: 24, height: 12),
                V3WebDownloadItem(
                  leadingSvg: 'assets/images/ic_web_download_mac.svg',
                  title: S.of(context).v3_main_download_mac_title,
                  subtitle: S.of(context).v3_main_download_mac_subtitle,
                  action: S.of(context).v3_main_download_action_download,
                  onClick: () {
                    launchUrl(Uri.parse(macLink));
                  },
                ),
                const SizedBox(width: 24, height: 12),
                V3WebDownloadItem(
                  leadingSvg: 'assets/images/ic_web_download_qrcode.svg',
                  title: S.of(context).v3_main_download_app_title,
                  subtitle: S.of(context).v3_main_download_app_subtitle,
                  action: S.of(context).v3_main_download_action_get,
                  onClick: () {
                    if (defaultTargetPlatform == TargetPlatform.android) {
                      launchUrl(Uri.parse(
                          'https://play.google.com/store/apps/details?id=com.viewsonic.display.cast&pcampaignid=web_share'));
                    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                      launchUrl(Uri.parse(
                          'https://apps.apple.com/tw/app/airsync-sender/id6453759985'));
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class V3WebDownloadItem extends StatelessWidget {
  const V3WebDownloadItem({
    super.key,
    required this.leadingSvg,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.onClick,
  });

  final String leadingSvg;
  final String title;
  final String subtitle;
  final String action;
  final Function() onClick;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isBigThan1920(context)
          ? 502
          : isBigThan1536(context)
              ? 396
              : isBigThan1280(context)
                  ? 325
                  : isBigThan1024(context)
                      ? 643
                      : 472,
      height: 92,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: context.tokens.color.vsdslColorSurface100,
        child: Center(
          child: ListTile(
            leading: Image(
              width: 60,
              height: 60,
              image: Svg(leadingSvg),
            ),
            title: AutoSizeText(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: context.tokens.color.vsdslColorOnSurface,
              ),
            ),
            subtitle: AutoSizeText(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: context.tokens.color.vsdslColorOnSurfaceVariant,
              ),
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 5.0,
                foregroundColor: context.tokens.color.vsdslColorOnSurface,
                backgroundColor: context.tokens.color.vsdslColorSurface100,
                side: BorderSide(
                  color: context.tokens.color.vsdslColorSurface300,
                  width: 1,
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: () {
                onClick.call();
              },
              child: AutoSizeText(action),
            ),
          ),
        ),
      ),
    );
  }
}
