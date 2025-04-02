import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
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
          margin:
              isLandscape ? null : const EdgeInsets.symmetric(horizontal: 58),
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
    return SizedBox(
      height: 996,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  height: 51,
                  child: AutoSizeText(
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
                Text(
                  S.current.v3_download_app_desktop_title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.tokens.color.vsdslColorNeutral,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(3),
                Text(
                  S.current.v3_download_app_for_desktop_desc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.tokens.color.vsdslColorNeutral,
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
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/ic_download_thumbs.svg',
                      excludeFromSemantics: true,
                      width: 27,
                      height: 27,
                    ),
                    const Gap(5),
                    Text(
                      S.current.v3_download_app_desktop,
                      style: TextStyle(
                        color: context.tokens.color.vsdslColorPrimary,
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Container(
                  height: 63,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                      Text(
                        AppConfig.of(context)!.settings.appStoreUrl,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.tokens.color.vsdslColorOnSurface,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
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
                    Text(
                      S.current.v3_download_app_desktop_hint,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: context.tokens.color.vsdslColorSurface800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Gap(20),
                Row(
                  children: [
                    Text(
                      'Install MacOS via App Store',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: context.tokens.color.vsdslColorSurface800,
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer()
                  ],
                ),
                const Gap(8),
                Container(
                  height: 63,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                      Text(
                        '${AppConfig.of(context)!.settings.appStoreUrl}?r',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.tokens.color.vsdslColorOnSurface,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
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
                    Text(
                      S.current.v3_download_app_desktop_store_hint,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: context.tokens.color.vsdslColorSurface800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 18,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 2,
                          color: context.tokens.color.vsdslColorOutline,
                        ),
                      ),
                      const Gap(13),
                      Text(
                        S.current.v3_download_app_or,
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
                Text(
                  S.current.v3_download_app_mobile_title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.tokens.color.vsdslColorNeutral,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(3),
                Text(
                  S.current.v3_download_app_for_mobile_desc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.tokens.color.vsdslColorNeutral,
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
          Positioned(
            right: 13,
            bottom: 13,
            child: V3Focus(
              label: S.current.v3_lbl_close_download_app_menu,
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
    return SizedBox(
      width: 910,
      height: 604,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 13,
            height: 51,
            child: AutoSizeText(
              S.of(context).v3_download_app_title,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: context.tokens.color.vsdslColorOnSurface,
              ),
            ),
          ),
          Positioned(
            top: 51,
            child: Container(
              width: 910,
              height: 1,
              color: context.tokens.color.vsdslColorOutline,
            ),
          ),
          Positioned(
            top: 61,
            left: 0,
            child: SizedBox(
              width: 510,
              child: Column(
                children: [
                  const Gap(30),
                  Text(
                    S.current.v3_download_app_desktop_title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.tokens.color.vsdslColorNeutral,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(11),
                  Text(
                    S.current.v3_download_app_for_desktop_desc,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.tokens.color.vsdslColorNeutral,
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
                        Text(
                          S.current.v3_download_app_desktop,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.tokens.color.vsdslColorPrimary,
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(8),
                  Container(
                    width: 400,
                    height: 63,
                    padding: const EdgeInsets.symmetric(vertical: 10),
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
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          AppConfig.of(context)!.settings.appStoreUrl,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.tokens.color.vsdslColorOnSurface,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 9),
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
                    child: Text(
                      S.current.v3_download_app_desktop_hint,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: context.tokens.color.vsdslColorSurface800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Gap(25),
                  SizedBox(
                    width: 400,
                    child: Text(
                      S.current.v3_download_app_desktop_store,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: context.tokens.color.vsdslColorSurface800,
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Gap(8),
                  Container(
                    width: 400,
                    height: 63,
                    padding: const EdgeInsets.symmetric(vertical: 10),
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
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${AppConfig.of(context)!.settings.appStoreUrl}?r',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.tokens.color.vsdslColorOnSurface,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 9),
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
                    child: Text(
                      S.current.v3_download_app_desktop_store_hint,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: context.tokens.color.vsdslColorSurface800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 61,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              width: 380,
              child: Column(
                children: [
                  const Gap(32),
                  Text(
                    S.current.v3_download_app_mobile_title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.tokens.color.vsdslColorNeutral,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(11),
                  Text(
                    S.current.v3_download_app_for_mobile_desc,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.tokens.color.vsdslColorNeutral,
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
                  const Gap(25),
                  QrImageView(
                    data: '${AppConfig.of(context)!.settings.appStoreUrl}?r',
                    version: QrVersions.auto,
                    size: 250,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 97,
            left: 500,
            child: Container(
              alignment: Alignment.center,
              height: 459,
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
                  Text(
                    S.current.v3_download_app_or,
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
          ),
          Positioned(
            right: 13,
            bottom: 13,
            child: V3Focus(
              label: S.current.v3_lbl_close_download_app_menu,
              identifier: 'v3_qa_close_download_app_menu',
              child: SizedBox(
                width: 33,
                height: 33,
                child: IconButton(
                  focusNode: primaryFocusNode,
                  icon: SvgPicture.asset(
                    'assets/images/ic_menu_close_gray.svg',
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
