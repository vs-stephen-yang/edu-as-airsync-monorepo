import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
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
      height: 961,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
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
              const Gap(40),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/ic_store_windows.png',
                    width: 55,
                    height: 55,
                  ),
                  const Gap(13),
                  Image.asset(
                    'assets/images/ic_store_mac.png',
                    width: 55,
                    height: 55,
                  ),
                ],
              ),
              const Gap(30),
              Text(
                S.current.v3_download_app_for_desktop,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.tokens.color.vsdslColorInfo,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(11),
              Text(
                S.current.v3_download_app_for_desktop_desc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.tokens.color.vsdslColorInfo,
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(40),
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
                    const Image(
                      width: 33,
                      height: 33,
                      image: Svg('assets/images/ic_store_magnifier.svg'),
                    ),
                  ],
                ),
              ),
              const Gap(29),
              SizedBox(
                width: 524,
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
              const Gap(29),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/ic_store_google_play.png',
                    width: 55,
                    height: 55,
                  ),
                  const Gap(13),
                  Image.asset(
                    'assets/images/ic_store_appstore.png',
                    width: 55,
                    height: 55,
                  ),
                ],
              ),
              const Gap(40),
              Text(
                S.current.v3_download_app_for_mobile,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.tokens.color.vsdslColorInfo,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(11),
              Text(
                S.current.v3_download_app_for_mobile_desc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.tokens.color.vsdslColorInfo,
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(30),
              QrImageView(
                data: AppConfig.of(context)!.settings.appStoreUrl,
                version: QrVersions.auto,
                size: 200,
              ),
            ],
          ),
          Positioned(
            right: 13,
            bottom: 13,
            child: V3Focus(
              child: SizedBox(
                width: 33,
                height: 33,
                child: IconButton(
                  focusNode: primaryFocusNode,
                  icon: const Image(
                    image: Svg('assets/images/ic_menu_close_gray.svg'),
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
            top: 97,
            left: 0,
            child: SizedBox(
              width: 510,
              height: 460,
              child: Column(
                children: [
                  const Gap(30),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/ic_store_windows.png',
                        width: 55,
                        height: 55,
                      ),
                      const Gap(13),
                      Image.asset(
                        'assets/images/ic_store_mac.png',
                        width: 55,
                        height: 55,
                      ),
                    ],
                  ),
                  const Gap(32),
                  Text(
                    S.current.v3_download_app_for_desktop,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.tokens.color.vsdslColorInfo,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(11),
                  Text(
                    S.current.v3_download_app_for_desktop_desc,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.tokens.color.vsdslColorInfo,
                      fontSize: 21,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(93),
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
                        const Image(
                          width: 33,
                          height: 33,
                          image: Svg('assets/images/ic_store_magnifier.svg'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 97,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              width: 380,
              height: 460,
              child: Column(
                children: [
                  const Gap(30),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/ic_store_google_play.png',
                        width: 55,
                        height: 55,
                      ),
                      const Gap(13),
                      Image.asset(
                        'assets/images/ic_store_appstore.png',
                        width: 55,
                        height: 55,
                      ),
                    ],
                  ),
                  const Gap(32),
                  Text(
                    S.current.v3_download_app_for_mobile,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.tokens.color.vsdslColorInfo,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(11),
                  Text(
                    S.current.v3_download_app_for_mobile_desc,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.tokens.color.vsdslColorInfo,
                      fontSize: 21,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(25),
                  QrImageView(
                    data: AppConfig.of(context)!.settings.appStoreUrl,
                    version: QrVersions.auto,
                    size: 200,
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
              child: SizedBox(
                width: 33,
                height: 33,
                child: IconButton(
                  focusNode: primaryFocusNode,
                  icon: const Image(
                    image: Svg('assets/images/ic_menu_close_gray.svg'),
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
