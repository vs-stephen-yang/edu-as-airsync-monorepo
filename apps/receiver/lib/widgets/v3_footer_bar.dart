import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:display_flutter/screens/v3_setting_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

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
                  trackEvent('click_setting', EventCategory.setting);
                  _showSettingsMenuDialog(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  _showSettingsMenuDialog(BuildContext context) {
    SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    settingsProvider.setPage(SettingPageState.deviceSetting);
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return const V3SettingMenu();
      },
    );
  }
}
