import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/multi_window_provider.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/widgets/v3_auto_hyphenating_text.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:qr_flutter/qr_flutter.dart';

class V3DownloadAppMenu extends StatelessWidget {
  const V3DownloadAppMenu({super.key, required this.primaryFocusNode});

  final FocusNode primaryFocusNode;

  @override
  Widget build(BuildContext context) {
    final storeUrl = AppConfig.of(context)!.settings.appStoreUrl;
    final storeMobileUrl = AppConfig.of(context)!.settings.storeMobileUrl;
    final portraitWidget = _DialogContainer(
      child: PortraitWidget(
        primaryFocusNode: primaryFocusNode,
        storeUrl: storeUrl,
        storeMobileUrl: storeMobileUrl,
      ),
    );
    return MultiWindowAdaptiveLayout(
      landscape: _DialogContainer(
        child: LandscapeWidget(
          primaryFocusNode: primaryFocusNode,
          storeUrl: storeUrl,
          storeMobileUrl: storeMobileUrl,
        ),
      ),
      landscapeHalf: portraitWidget,
      landscapeTwoThirds: portraitWidget,
      landscapeOneThird: const SizedBox.shrink(),
      portrait: portraitWidget,
    );
  }
}

class _DialogContainer extends StatelessWidget {
  final Widget child;

  const _DialogContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(58),
      color: context.tokens.color.vsdslColorOpacityNeutralXs,
      child: Dialog(
        backgroundColor: context.tokens.color.vsdslColorSurface100,
        insetPadding: EdgeInsets.zero,
        elevation: 16.0,
        shadowColor: context.tokens.color.vsdslColorOpacityNeutralSm,
        child: child,
      ),
    );
  }
}

class PortraitWidget extends StatelessWidget {
  final FocusNode primaryFocusNode;
  final String storeUrl;
  final String storeMobileUrl;

  const PortraitWidget({
    super.key,
    required this.primaryFocusNode,
    required this.storeUrl,
    required this.storeMobileUrl,
  });

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    return SizedBox(
      height: 1000,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          V3Scrollbar(
            controller: scrollController,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  const Gap(13),
                  V3AutoHyphenatingText(
                    S.of(context).v3_download_app_title,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: context.tokens.color.vsdslColorOnSurface,
                    ),
                  ),
                  const Gap(13),
                  Container(
                      height: 1, color: context.tokens.color.vsdslColorOutline),
                  const Gap(30),
                  DownloadDesktop(storeUrl: storeUrl),
                  DividerWithText(S.of(context).v3_download_app_or),
                  const Gap(21),
                  DownloadMobile(storeUrl: storeMobileUrl),
                  const Gap(32),
                ],
              ),
            ),
          ),
          Positioned(
            right: 13,
            bottom: 13,
            child: V3Focus(
              label: S.of(context).v3_lbl_close_download_app_menu,
              identifier: 'v3_qa_close_download_app_menu',
              child: SizedBox(
                width: 33,
                height: 33,
                child: IconButton(
                  focusNode: primaryFocusNode,
                  icon: SvgPicture.asset(
                    'assets/images/ic_menu_close_gray.svg',
                    excludeFromSemantics: true,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    if (navService.canPop()) {
                      navService.goBack();
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LandscapeWidget extends StatelessWidget {
  final FocusNode primaryFocusNode;
  final String storeUrl;
  final String storeMobileUrl;

  const LandscapeWidget(
      {super.key,
      required this.primaryFocusNode,
      required this.storeUrl,
      required this.storeMobileUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            const Gap(13),
            V3AutoHyphenatingText(
              textAlign: TextAlign.center,
              S.of(context).v3_download_app_title,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: context.tokens.color.vsdslColorOnSurface,
              ),
            ),
            const Gap(13),
            Container(height: 1, color: context.tokens.color.vsdslColorOutline),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 15,
                    child: DownloadDesktop(storeUrl: storeUrl),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                              width: 2,
                              color: context.tokens.color.vsdslColorOutline),
                        ),
                        const Gap(13),
                        V3AutoHyphenatingText(
                          S.of(context).v3_download_app_or,
                          style: TextStyle(
                            color: context.tokens.color.vsdslColorSurface500,
                            fontSize: 12,
                          ),
                        ),
                        const Gap(13),
                        Expanded(
                          child: Container(
                              width: 2,
                              color: context.tokens.color.vsdslColorOutline),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 11,
                    child: DownloadMobile(storeUrl: storeMobileUrl),
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          right: 13,
          bottom: 13,
          child: V3Focus(
            label: S.of(context).v3_lbl_close_download_app_menu,
            identifier: 'v3_qa_close_download_app_menu',
            child: SizedBox(
              width: 33,
              height: 33,
              child: IconButton(
                focusNode: primaryFocusNode,
                icon: SvgPicture.asset(
                  'assets/images/ic_menu_close_gray.svg',
                  excludeFromSemantics: true,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  if (navService.canPop()) {
                    navService.goBack();
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DownloadMobile extends StatelessWidget {
  const DownloadMobile({
    super.key,
    required this.storeUrl,
  });

  final String storeUrl;

  @override
  Widget build(BuildContext context) {
    final scrollCtrl = ScrollController();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: V3Scrollbar(
        controller: scrollCtrl,
        child: SingleChildScrollView(
          controller: scrollCtrl,
          child: Column(
            children: [
              V3AutoHyphenatingText(
                S.of(context).v3_download_app_mobile_title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.tokens.color.vsdslColorNeutral,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(11),
              V3AutoHyphenatingText(
                S.of(context).v3_download_app_for_mobile_desc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.tokens.color.vsdslColorOnSurfaceVariant,
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(30),
              StoreIconRow(
                assetPaths: [
                  'assets/images/ic_store_google_play.png',
                  'assets/images/ic_store_appstore.png',
                ],
              ),
              const Gap(25),
              QrImageView(
                data: '$storeUrl?r',
                version: QrVersions.auto,
                size: 250,
              ),
              const Gap(32),
            ],
          ),
        ),
      ),
    );
  }
}

class DownloadDesktop extends StatelessWidget {
  const DownloadDesktop({
    super.key,
    required this.storeUrl,
  });

  final String storeUrl;

  @override
  Widget build(BuildContext context) {
    final scrollCtrl = ScrollController();
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 20, top: 10, bottom: 10),
      child: V3Scrollbar(
        controller: scrollCtrl,
        child: SingleChildScrollView(
          controller: scrollCtrl,
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Column(
              children: [
                V3AutoHyphenatingText(
                  S.of(context).v3_download_app_desktop_title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.tokens.color.vsdslColorNeutral,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(11),
                V3AutoHyphenatingText(
                  S.of(context).v3_download_app_for_desktop_desc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.tokens.color.vsdslColorOnSurfaceVariant,
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(30),
                StoreIconRow(
                  assetPaths: [
                    'assets/images/ic_store_windows.png',
                    'assets/images/ic_store_mac.png',
                  ],
                ),
                const Gap(33),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/ic_download_thumbs.svg',
                      excludeFromSemantics: true,
                      width: 27,
                      height: 27,
                    ),
                    const Gap(5),
                    Expanded(
                      child: V3AutoHyphenatingText(
                        S.of(context).v3_download_app_desktop,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: context.tokens.color.vsdslColorPrimary,
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                StoreLinkCard(url: storeUrl, fontSize: 17),
                const Gap(3),
                Align(
                  alignment: Alignment.centerRight,
                  child: V3AutoHyphenatingText(
                    S.of(context).v3_download_app_desktop_hint,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: context.tokens.color.vsdslColorOnSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Gap(25),
                V3AutoHyphenatingText(
                  S.of(context).v3_download_app_desktop_store,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: context.tokens.color.vsdslColorSurface800,
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(8),
                StoreLinkCard(url: '$storeUrl?r', fontSize: 17),
                const Gap(3),
                Align(
                  alignment: Alignment.centerRight,
                  child: V3AutoHyphenatingText(
                    S.of(context).v3_download_app_desktop_store_hint,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: context.tokens.color.vsdslColorOnSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Gap(32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StoreIconRow extends StatelessWidget {
  final List<String> assetPaths;

  const StoreIconRow({required this.assetPaths, super.key});

  @override
  Widget build(BuildContext context) {
    final outlineColor = context.tokens.color.vsdslColorOutline;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(assetPaths.length, (i) {
        final icon =
            Image.asset(assetPaths[i], excludeFromSemantics: true, height: 60);
        if (i == 0) return icon;

        return Row(
          children: [
            const Gap(30),
            Container(width: 2, height: 27, color: outlineColor),
            const Gap(30),
            icon,
          ],
        );
      }),
    );
  }
}

class StoreLinkCard extends StatelessWidget {
  final String url;
  final double fontSize;

  const StoreLinkCard({required this.url, this.fontSize = 17, super.key});

  @override
  Widget build(BuildContext context) {
    final outlineColor = context.tokens.color.vsdslColorOutline;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 2, color: outlineColor),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: V3AutoHyphenatingText(
              url,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: context.tokens.color.vsdslColorOnSurface,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SvgPicture.asset(
            'assets/images/ic_store_magnifier.svg',
            width: 33,
            height: 33,
            excludeFromSemantics: true,
          ),
        ],
      ),
    );
  }
}

class DividerWithText extends StatelessWidget {
  final String text;

  const DividerWithText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final outlineColor = context.tokens.color.vsdslColorOutline;
    final surface500 = context.tokens.color.vsdslColorSurface500;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
          Expanded(
            child: Container(height: 2, color: outlineColor),
          ),
          const Gap(13),
          V3AutoHyphenatingText(
            text,
            style: TextStyle(
              color: surface500,
              fontSize: 12,
            ),
          ),
          const Gap(13),
          Expanded(
            child: Container(height: 2, color: outlineColor),
          ),
        ],
      ),
    );
  }
}
