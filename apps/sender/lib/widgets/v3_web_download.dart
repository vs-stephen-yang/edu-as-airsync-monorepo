import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:display_cast_flutter/utilities/dart_ui_web_fake.dart'
    if (dart.library.ui_web) 'dart:html' as html;
import 'package:display_cast_flutter/widgets/V3_focus.dart';
import 'package:display_cast_flutter/widgets/v3_web_download_app_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
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
            top: 131,
            right: 0,
            child: ExcludeSemantics(
              child:
                  SvgPicture.asset('assets/images/ic_web_planetary_rings.svg'),
            ),
          ),
          Positioned(
            top: 80,
            child: Column(
              children: [
                ExcludeSemantics(
                  child: Image.asset(
                    'assets/images/ic_logo_airsync_icon.png',
                    width: 90,
                    height: 90,
                  ),
                ),
                const SizedBox(height: 40),
                AutoSizeText(
                  S.of(context).v3_main_download_title,
                  style: TextStyle(
                    fontSize: 32,
                    color: context.tokens.color.vsdswColorOnSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                AutoSizeText(
                  S.of(context).v3_main_download_desc,
                  style: TextStyle(
                    fontSize: 20,
                    color: context.tokens.color.vsdswColorOnSurfaceVariant,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 80 + 269,
            child: Column(
              children: [
                V3WebDownloadItem(
                  leadingSvg: 'assets/images/ic_web_download_windows.svg',
                  title: S.of(context).v3_main_download_win_title,
                  subtitle: S.of(context).v3_main_download_win_subtitle,
                  action: S.of(context).v3_main_download_action_download,
                  onClick: () {
                    launchUrl(Uri.parse(windowLink));
                  },
                  buttonLabel: S.current.v3_lbl_main_download_windows,
                  buttonIdentifier: 'v3_qa_main_download_windows',
                ),
                const SizedBox(width: 24, height: 12),
                V3WebDownloadItem(
                  leadingSvg: 'assets/images/ic_web_download_mac.svg',
                  title: S.of(context).v3_main_download_mac_title,
                  subtitle: S.of(context).v3_main_download_mac_subtitle,
                  action: S.of(context).v3_main_download_action_download,
                  isMac: true,
                  onClick: () {
                    launchUrl(
                        Uri.parse(AppConfig.of(context)!.settings.appStoreUrl));
                  },
                  onClick2: () {
                    String userAgent =
                        html.window.navigator.userAgent.toLowerCase();
                    if (userAgent.contains("mac os")) {
                      launchUrl(Uri.parse(macLink));
                    } else {
                      launchUrl(Uri.parse(
                          macLink.replaceAll("macappstore", "https")));
                    }
                  },
                  buttonLabel: S.current.v3_lbl_download_independent_version,
                  buttonIdentifier: 'v3_qa_download_independent_version',
                  labelSecond: S.current.v3_lbl_main_download_mac_store,
                  identifierSecond: 'v3_qa_main_download_mac_store',
                ),
                const SizedBox(width: 24, height: 12),
                V3WebDownloadItem(
                  leadingSvg: 'assets/images/ic_web_download_qrcode.svg',
                  title: S.of(context).v3_main_download_app_title,
                  subtitle: S.of(context).v3_main_download_app_subtitle,
                  action: S.of(context).v3_main_download_action_download,
                  onClick: () {
                    _showDownloadAppMenuDialog(context);
                  },
                  buttonLabel: S.current.v3_lbl_main_download_mobile,
                  buttonIdentifier: 'v3_qa_main_download_mobile',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _showDownloadAppMenuDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return const V3DownloadAppMenu();
      },
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
    this.isMac = false,
    this.onClick2,
    required this.buttonLabel,
    required this.buttonIdentifier,
    this.labelSecond,
    this.identifierSecond,
  });

  final String leadingSvg;
  final String title;
  final String subtitle;
  final String action;
  final bool isMac;
  final Function() onClick;
  final Function()? onClick2;
  final String buttonLabel;
  final String buttonIdentifier;
  final String? labelSecond;
  final String? identifierSecond;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 602,
      height: 92 + (isMac ? 37 : 0),
      child: DownloadWidget(
        leadingSvg: leadingSvg,
        title: title,
        subtitle: subtitle,
        action: action,
        onClick: onClick,
        onClick2: onClick2,
        label: buttonLabel,
        identifier: buttonIdentifier,
        labelSecond: labelSecond,
        identifierSecond: identifierSecond,
        isMac: isMac,
      ),
    );
  }
}

class DownloadWidget extends StatelessWidget {
  const DownloadWidget({
    super.key,
    required this.leadingSvg,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.onClick,
    required this.onClick2,
    required this.label,
    required this.identifier,
    this.isMac = false,
    this.labelSecond,
    this.identifierSecond,
  });

  final String leadingSvg;
  final String title;
  final String subtitle;
  final String action;
  final String label;
  final String identifier;
  final String? labelSecond;
  final String? identifierSecond;
  final bool isMac;
  final Function() onClick;
  final Function()? onClick2;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: context.tokens.color.vsdswColorSurface100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              ExcludeSemantics(
                child: SvgPicture.asset(leadingSvg),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AutoSizeText(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: context.tokens.color.vsdswColorOnSurface,
                    ),
                  ),
                  AutoSizeText(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: context.tokens.color.vsdswColorOnSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isMac) ...[
                      ExcludeSemantics(
                        child: SvgPicture.asset(
                            'assets/images/v3_ic_web_download_thumb.svg'),
                      ),
                      const Gap(4),
                      Text(
                        maxLines: 2,
                        S.current.v3_main_download_mac_pkg_label,
                        style: TextStyle(
                            fontSize: 14,
                            color: context.tokens.color.vsdswColorPrimary,
                            fontWeight: FontWeight.bold),
                      ),
                      const Gap(13),
                    ] else
                      const Spacer(),
                    // 這邊 label不會唸，需要加到下一層
                    V3Focus(
                      label: label,
                      identifier: identifier,
                      button: true,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 5.0,
                          foregroundColor:
                              context.tokens.color.vsdswColorOnSurface,
                          backgroundColor:
                              context.tokens.color.vsdswColorSurface100,
                          side: BorderSide(
                            color: context.tokens.color.vsdswColorSurface300,
                            width: 1,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onPressed: onClick,
                        child: Semantics(
                          label: label,
                          child: ExcludeSemantics(
                            child: AutoSizeText(action),
                          ),
                        ),
                      ),
                    ),
                    const Gap(5),
                  ],
                ),
              ),
              if (isMac) ...[
                const Gap(12),
                Container(
                  height: 1,
                  width: 250,
                  color: context.tokens.color.vsdswColorOutline,
                ),
                const Gap(12),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        S.current.v3_main_download_mac_store_label,
                        style: TextStyle(
                            fontSize: 14,
                            color: context.tokens.color.vsdswColorOnSurface),
                      ),
                      const Gap(5),
                      V3Focus(
                        label: labelSecond ?? '',
                        identifier: identifierSecond ?? '',
                        button: true,
                        child: InkWell(
                          onTap: onClick2,
                          child: SizedBox(
                            height: 28,
                            child: ExcludeSemantics(
                              child: Text(
                                S.current.v3_main_download_mac_store,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.tokens.color.vsdswColorLink,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
