import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/settings/app_config.dart';
import 'package:display_cast_flutter/utilities/dart_ui_web_fake.dart'
    if (dart.library.ui_web) 'dart:html' as html;
import 'package:display_cast_flutter/utilities/web_util.dart';
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
    final bool isLargeScreen = isBigThan768(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final downloadItemWidth = isLargeScreen ? 602.0 : screenWidth - 32;

    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(
          minHeight: isLargeScreen ? 700 : 0.0,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isLargeScreen)
              Positioned(
                left: 0,
                top: 131,
                right: 0,
                child: ExcludeSemantics(
                  child: SvgPicture.asset(
                      'assets/images/ic_web_planetary_rings.svg'),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(
                top: isLargeScreen ? 80 : 40,
                bottom: 40,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo部分
                  ExcludeSemantics(
                    child: Image.asset(
                      'assets/images/ic_logo_airsync_icon.png',
                      width: 90,
                      height: 90,
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 40 : 24),

                  // 标题和描述
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AutoSizeText(
                      S.of(context).v3_main_download_title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isLargeScreen ? 32 : 24,
                        color: context.tokens.color.vsdswColorOnSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AutoSizeText(
                      S.of(context).v3_main_download_desc,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isLargeScreen ? 20 : 16,
                        color: context.tokens.color.vsdswColorOnSurfaceVariant,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  SizedBox(height: isLargeScreen ? 60 : 40),

                  // 下载选项
                  SizedBox(
                    width: downloadItemWidth,
                    child: V3WebDownloadItem(
                      leadingSvg: 'assets/images/ic_web_download_windows.svg',
                      title: S.of(context).v3_main_download_win_title,
                      subtitle: S.of(context).v3_main_download_win_subtitle,
                      action: S.of(context).v3_main_download_action_download,
                      onClick: () {
                        launchUrl(Uri.parse(windowLink));
                      },
                      buttonLabel: S.current.v3_lbl_main_download_windows,
                      buttonIdentifier: 'v3_qa_main_download_windows',
                      isSmallScreen: !isLargeScreen,
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: downloadItemWidth,
                    child: V3WebDownloadItem(
                      leadingSvg: 'assets/images/ic_web_download_mac.svg',
                      title: S.of(context).v3_main_download_mac_title,
                      subtitle: S.of(context).v3_main_download_mac_subtitle,
                      action: S.of(context).v3_main_download_action_download,
                      isMac: true,
                      onClick: () {
                        launchUrl(Uri.parse(
                            AppConfig.of(context)!.settings.appStoreUrl));
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
                      buttonLabel:
                          S.current.v3_lbl_download_independent_version,
                      buttonIdentifier: 'v3_qa_download_independent_version',
                      labelSecond: S.current.v3_lbl_main_download_mac_store,
                      identifierSecond: 'v3_qa_main_download_mac_store',
                      isSmallScreen: !isLargeScreen,
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: downloadItemWidth,
                    child: V3WebDownloadItem(
                      leadingSvg: 'assets/images/ic_web_download_qrcode.svg',
                      title: S.of(context).v3_main_download_app_title,
                      subtitle: S.of(context).v3_main_download_app_subtitle,
                      action: S.of(context).v3_main_download_action_download,
                      onClick: () {
                        _showDownloadAppMenuDialog(context);
                      },
                      buttonLabel: S.current.v3_lbl_main_download_mobile,
                      buttonIdentifier: 'v3_qa_main_download_mobile',
                      isSmallScreen: !isLargeScreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
    this.isSmallScreen = false,
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
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    // 大屏幕使用固定高度，小屏幕使用自适应高度
    if (!isSmallScreen) {
      return SizedBox(
        width: 602,
        height: 92 + (isMac ? 37 : 0), // 大屏幕保持原有固定高度
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
          isSmallScreen: isSmallScreen,
        ),
      );
    } else {
      // 小屏幕使用自适应高度
      return Container(
        width: double.infinity,
        // 不设置固定高度，让内容决定高度
        constraints: BoxConstraints(
          minHeight: isMac ? 140 : 110, // 设置最小高度，确保有足够空间
        ),
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
          isSmallScreen: isSmallScreen,
        ),
      );
    }
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
    this.isSmallScreen = false,
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
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 16 : 0,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: context.tokens.color.vsdswColorSurface100,
        borderRadius: context.tokens.radii.vsdswRadius2xl,
        border: Border.all(
          color: context.tokens.color.vsdswColorOutline,
          width: 1,
        ),
      ),
      child: isSmallScreen
          ? _buildSmallScreenLayout(context)
          : _buildLargeScreenLayout(context),
    );
  }

  Widget _buildLargeScreenLayout(BuildContext context) {
    return Stack(
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
                    ExcludeSemantics(
                      child: Text(
                        S.current.v3_main_download_mac_store_label,
                        style: TextStyle(
                            fontSize: 14,
                            color: context.tokens.color.vsdswColorOnSurface),
                      ),
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
    );
  }

  Widget _buildSmallScreenLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ExcludeSemantics(
              child: SvgPicture.asset(
                leadingSvg,
                width: 60,
                height: 60,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    title,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: context.tokens.color.vsdswColorOnSurface,
                    ),
                  ),
                  AutoSizeText(
                    subtitle,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: context.tokens.color.vsdswColorOnSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isSmallScreen) const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isMac) ...[
              ExcludeSemantics(
                child: SvgPicture.asset(
                  'assets/images/v3_ic_web_download_thumb.svg',
                  width: 16,
                  height: 16,
                ),
              ),
              Flexible(
                child: Text(
                  S.current.v3_main_download_mac_pkg_label,
                  style: TextStyle(
                    fontSize: context.tokens.textStyle.vsdswLabelSm.fontSize,
                    color: context.tokens.color.vsdswColorPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (isMac) const SizedBox(height: 13),
        V3Focus(
          label: label,
          identifier: identifier,
          button: true,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 5.0,
              foregroundColor: context.tokens.color.vsdswColorOnSurface,
              backgroundColor: context.tokens.color.vsdswColorSurface100,
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
            child: SizedBox(
              height: 40,
              child: Center(
                child: Semantics(
                  label: label,
                  child: ExcludeSemantics(
                    child: AutoSizeText(action),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (isMac) ...[
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: context.tokens.color.vsdswColorOutline,
          ),
          if (!isSmallScreen) const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  S.current.v3_main_download_mac_store_label,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.tokens.color.vsdswColorOnSurface,
                  ),
                ),
              ),
              Gap(3),
              V3Focus(
                label: labelSecond ?? '',
                identifier: identifierSecond ?? '',
                button: true,
                child: SizedBox(
                  height: 48,
                  child: InkWell(
                    onTap: onClick2,
                    child: Center(
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
        ],
      ],
    );
  }
}
