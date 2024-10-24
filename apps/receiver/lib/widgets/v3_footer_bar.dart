import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/screens/v3_download_app_menu.dart';
import 'package:display_flutter/screens/v3_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class V3FooterBar extends StatelessWidget {
  const V3FooterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Image.asset(
            'assets/images/ic_wallpaper.png',
            width: 1280,
          ),
          Positioned(
            right: 13,
            bottom: 13,
            child: Image.asset(
              'assets/images/ic_logo_viewsonic.png',
              width: 513 / 3,
              height: 160 / 3,
            ),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: SizedBox(
              width: 41,
              height: 41,
              child: IconButton(
                icon: const Image(
                  image: Svg('assets/images/ic_menu_settings.svg'),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  V3Home.isShowSettingsMenu.value =
                      !V3Home.isShowSettingsMenu.value;
                },
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 106,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    context.tokens.color.vsdslColorOpacityNeutralSm,
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(9999),
                      bottomRight: Radius.circular(9999)),
                ),
                elevation: 0,
              ),
              onPressed: () {
                _showDownloadAppMenuDialog(context);
              },
              icon: const SizedBox(
                width: 16,
                height: 16,
                child: Image(
                  image: Svg('assets/images/ic_qrcode.svg'),
                ),
              ),
              label: SizedBox(
                width: 47,
                height: 23,
                child: Text(
                  S.of(context).v3_download_app_entry,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                    color: context.tokens.color.vsdslColorOnSurfaceInverse,
                  ),
                ),
              ),
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
