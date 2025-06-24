import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isLandscape = constraints.maxWidth > constraints.maxHeight;
        return Container(
          alignment: Alignment.center,
          padding: isLandscape
              ? const EdgeInsets.symmetric(horizontal: 85, vertical: 58)
              : const EdgeInsets.symmetric(horizontal: 58),
          color: context.tokens.color.vsdslColorOpacityNeutralXs,
          child: Dialog(
            backgroundColor: context.tokens.color.vsdslColorSurface100,
            insetPadding: EdgeInsets.zero,
            elevation: 16.0,
            shadowColor: context.tokens.color.vsdslColorOpacityNeutralSm,
            child: isLandscape
                ? LandscapeWidget(primaryFocusNode: primaryFocusNode)
                : PortraitWidget(primaryFocusNode: primaryFocusNode),
          ),
        );
      },
    );
  }
}

class PortraitWidget extends StatelessWidget {
  final FocusNode primaryFocusNode;

  const PortraitWidget({
    super.key,
    required this.primaryFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();
    return SizedBox(
      height: 996,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          V3Scrollbar(
            controller: scrollController,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 13),
                    child: V3AutoHyphenatingText(
                      S.of(context).v3_download_app_title,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: context.tokens.color.vsdslColorOnSurface,
                      ),
                    ),
                  ),
                  Container(
                    width: 910,
                    height: 1,
                    color: context.tokens.color.vsdslColorOutline,
                  ),
                  const Gap(30),
                  V3AutoHyphenatingText(
                    S.of(context).v3_download_app_desktop_title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.tokens.color.vsdslColorNeutral,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(3),
                  V3AutoHyphenatingText(
                    S.of(context).v3_download_app_for_desktop_desc,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.tokens.color.vsdslColorOnSurfaceVariant,
                      fontSize: 21,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(13),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/ic_store_windows.png',
                        excludeFromSemantics: true,
                        width: 118,
                        height: 60,
                      ),
                      const Gap(30),
                      Container(
                        width: 2,
                        height: 27,
                        color: context.tokens.color.vsdslColorOutline,
                      ),
                      const Gap(30),
                      Image.asset(
                        'assets/images/ic_store_mac.png',
                        excludeFromSemantics: true,
                        width: 102,
                        height: 60,
                      ),
                    ],
                  ),
                  const Gap(16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
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
                            style: TextStyle(
                              color: context.tokens.color.vsdslColorPrimary,
                              fontSize: 21,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(8),
                  Container(
                    height: 63,
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 2,
                          color: context.tokens.color.vsdslColorOutline,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: V3AutoHyphenatingText(
                            AppConfig.of(context)!.settings.appStoreUrl,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: context.tokens.color.vsdslColorOnSurface,
                              fontSize: 19,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SvgPicture.asset(
                          'assets/images/ic_store_magnifier.svg',
                          excludeFromSemantics: true,
                          width: 33,
                          height: 33,
                        ),
                      ],
                    ),
                  ),
                  const Gap(3),
                  Row(
                    children: [
                      const Spacer(),
                      V3AutoHyphenatingText(
                        S.of(context).v3_download_app_desktop_hint,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color:
                              context.tokens.color.vsdslColorOnSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      const Gap(30),
                    ],
                  ),
                  const Gap(20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children: [
                        Expanded(
                          child: V3AutoHyphenatingText(
                            'Install MacOS via App Store',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: context
                                  .tokens.color.vsdslColorOnSurfaceVariant,
                              fontSize: 21,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(8),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 2,
                          color: context.tokens.color.vsdslColorOutline,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: V3AutoHyphenatingText(
                            '${AppConfig.of(context)!.settings.appStoreUrl}?r',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: context.tokens.color.vsdslColorOnSurface,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SvgPicture.asset(
                          'assets/images/ic_store_magnifier.svg',
                          excludeFromSemantics: true,
                          width: 33,
                          height: 33,
                        ),
                      ],
                    ),
                  ),
                  const Gap(3),
                  Row(
                    children: [
                      const Spacer(),
                      V3AutoHyphenatingText(
                        S.of(context).v3_download_app_desktop_store_hint,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color:
                              context.tokens.color.vsdslColorOnSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      const Gap(30),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 2,
                            color: context.tokens.color.vsdslColorOutline,
                          ),
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
                            height: 2,
                            color: context.tokens.color.vsdslColorOutline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(21),
                  V3AutoHyphenatingText(
                    S.of(context).v3_download_app_mobile_title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.tokens.color.vsdslColorNeutral,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(3),
                  V3AutoHyphenatingText(
                    S.of(context).v3_download_app_for_mobile_desc,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.tokens.color.vsdslColorOnSurfaceVariant,
                      fontSize: 21,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(13),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/ic_store_google_play.png',
                        excludeFromSemantics: true,
                        width: 110,
                        height: 60,
                      ),
                      const Gap(30),
                      Container(
                        width: 2,
                        height: 27,
                        color: context.tokens.color.vsdslColorOutline,
                      ),
                      const Gap(13),
                      Image.asset(
                        'assets/images/ic_store_appstore.png',
                        excludeFromSemantics: true,
                        width: 101,
                        height: 60,
                      ),
                    ],
                  ),
                  const Gap(3),
                  QrImageView(
                    data: '${AppConfig.of(context)!.settings.appStoreUrl}?r',
                    version: QrVersions.auto,
                    size: 280,
                  ),
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
          )
        ],
      ),
    );
  }
}

class LandscapeWidget extends StatelessWidget {
  final FocusNode primaryFocusNode;

  const LandscapeWidget({
    super.key,
    required this.primaryFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    final ScrollController leftScrollController = ScrollController();
    final ScrollController rightScrollController = ScrollController();
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 13),
              child: V3AutoHyphenatingText(
                textAlign: TextAlign.center,
                S.of(context).v3_download_app_title,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: context.tokens.color.vsdslColorOnSurface,
                ),
              ),
            ),
            Container(
              height: 1,
              color: context.tokens.color.vsdslColorOutline,
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 15,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 10),
                      child: V3Scrollbar(
                        controller: leftScrollController,
                        child: SingleChildScrollView(
                          controller: leftScrollController,
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
                                  color: context
                                      .tokens.color.vsdslColorOnSurfaceVariant,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Gap(30),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/images/ic_store_windows.png',
                                    excludeFromSemantics: true,
                                    width: 118,
                                    height: 60,
                                  ),
                                  const Gap(30),
                                  Container(
                                    width: 2,
                                    height: 27,
                                    color:
                                        context.tokens.color.vsdslColorOutline,
                                  ),
                                  const Gap(30),
                                  Image.asset(
                                    'assets/images/ic_store_mac.png',
                                    excludeFromSemantics: true,
                                    width: 102,
                                    height: 60,
                                  ),
                                ],
                              ),
                              const Gap(33),
                              SizedBox(
                                width: 400,
                                child: Row(
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
                                          color: context
                                              .tokens.color.vsdslColorPrimary,
                                          fontSize: 21,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(8),
                              Container(
                                width: 400,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 2,
                                      color: context
                                          .tokens.color.vsdslColorOutline,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: V3AutoHyphenatingText(
                                        AppConfig.of(context)!
                                            .settings
                                            .appStoreUrl,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: context
                                              .tokens.color.vsdslColorOnSurface,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SvgPicture.asset(
                                      'assets/images/ic_store_magnifier.svg',
                                      excludeFromSemantics: true,
                                      width: 33,
                                      height: 33,
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(3),
                              SizedBox(
                                width: 400,
                                child: V3AutoHyphenatingText(
                                  S.of(context).v3_download_app_desktop_hint,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: context.tokens.color
                                        .vsdslColorOnSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const Gap(25),
                              SizedBox(
                                width: 400,
                                child: V3AutoHyphenatingText(
                                  S.of(context).v3_download_app_desktop_store,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: context
                                        .tokens.color.vsdslColorSurface800,
                                    fontSize: 21,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Gap(8),
                              Container(
                                width: 400,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 2,
                                      color: context
                                          .tokens.color.vsdslColorOutline,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: V3AutoHyphenatingText(
                                        '${AppConfig.of(context)!.settings.appStoreUrl}?r',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: context
                                              .tokens.color.vsdslColorOnSurface,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SvgPicture.asset(
                                      'assets/images/ic_store_magnifier.svg',
                                      excludeFromSemantics: true,
                                      width: 33,
                                      height: 33,
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(3),
                              SizedBox(
                                width: 400,
                                child: V3AutoHyphenatingText(
                                  S
                                      .of(context)
                                      .v3_download_app_desktop_store_hint,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: context.tokens.color
                                        .vsdslColorOnSurfaceVariant,
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
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            height: 207,
                            width: 2,
                            color: context.tokens.color.vsdslColorOutline,
                          ),
                        ),
                        const SizedBox(height: 13),
                        V3AutoHyphenatingText(
                          S.of(context).v3_download_app_or,
                          style: TextStyle(
                            color: context.tokens.color.vsdslColorSurface500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 13),
                        Expanded(
                          child: Container(
                            height: 207,
                            width: 2,
                            color: context.tokens.color.vsdslColorOutline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 11,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: V3Scrollbar(
                        controller: rightScrollController,
                        child: SingleChildScrollView(
                          controller: rightScrollController,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                V3AutoHyphenatingText(
                                  S.of(context).v3_download_app_mobile_title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        context.tokens.color.vsdslColorNeutral,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Gap(11),
                                V3AutoHyphenatingText(
                                  S.of(context).v3_download_app_for_mobile_desc,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: context.tokens.color
                                        .vsdslColorOnSurfaceVariant,
                                    fontSize: 21,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Gap(30),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'assets/images/ic_store_google_play.png',
                                      excludeFromSemantics: true,
                                      width: 110,
                                      height: 60,
                                    ),
                                    const Gap(30),
                                    Container(
                                      width: 2,
                                      height: 27,
                                      color: context
                                          .tokens.color.vsdslColorOutline,
                                    ),
                                    const Gap(13),
                                    Image.asset(
                                      'assets/images/ic_store_appstore.png',
                                      excludeFromSemantics: true,
                                      width: 101,
                                      height: 60,
                                    ),
                                  ],
                                ),
                                const Gap(25),
                                QrImageView(
                                  data:
                                      '${AppConfig.of(context)!.settings.appStoreUrl}?r',
                                  version: QrVersions.auto,
                                  size: 250,
                                ),
                                const Gap(32),
                              ],
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
        )
      ],
    );
  }
}
