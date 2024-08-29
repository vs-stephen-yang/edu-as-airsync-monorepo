import 'package:auto_size_text/auto_size_text.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/settings/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:qr_flutter/qr_flutter.dart';

class V3DownloadAppMenu extends StatelessWidget {
  const V3DownloadAppMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          bottom: 40,
          child: Dialog(
            backgroundColor: context.tokens.color.vsdslColorSurface100,
            insetPadding: EdgeInsets.zero,
            elevation: 16.0,
            shadowColor: context.tokens.color.vsdslColorOpacityNeutralSm,
            child: SizedBox(
              width: 512,
              height: 507,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 80,
                    child: AutoSizeText(
                      S.of(context).v3_download_app_title,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                        color: context.tokens.color.vsdslColorOnSurface,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 135,
                    child: QrImageView(
                      data: AppConfig.of(context)!.settings.appStoreUrl,
                      version: QrVersions.auto,
                      size: 144,
                    ),
                  ),
                  const Positioned(
                    bottom: 151,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image(
                          width: 120,
                          height: 38,
                          image: Svg('assets/images/ic_store_appstore.svg'),
                        ),
                        SizedBox(width: 13),
                        Image(
                          width: 120,
                          height: 38,
                          image: Svg('assets/images/ic_store_google_play.svg'),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                      bottom: 108,
                      child: AutoSizeText(
                        S.of(context).v3_download_app_desc,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: context.tokens.color.vsdslColorSurface400),
                      )),
                  Positioned(
                    right: 13,
                    bottom: 13,
                    child: SizedBox(
                      width: 33,
                      height: 33,
                      child: IconButton(
                        icon: const Image(
                          image: Svg('assets/images/ic_menu_minimal.svg'),
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
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
