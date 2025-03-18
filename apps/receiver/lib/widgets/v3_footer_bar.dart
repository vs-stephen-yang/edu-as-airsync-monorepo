import 'package:display_flutter/app_analytics.dart';
import 'package:display_flutter/providers/settings_provider.dart';
import 'package:display_flutter/screens/v3_setting_menu.dart';
import 'package:display_flutter/utility/navigation_service_util.dart';
import 'package:display_flutter/widgets/v3_focus.dart';
import 'package:display_flutter/widgets/v3_settings_password_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
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
              child: V3Focus(
                child: Consumer<SettingsProvider>(
                  builder: (_, settingsProvider, __) {
                    return IconButton(
                      icon: SvgPicture.asset(settingsProvider.isSettingsLock
                          ? 'assets/images/ic_menu_settings_locked.svg'
                          : 'assets/images/ic_menu_settings.svg'),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        trackEvent('click_setting', EventCategory.setting);
                        _showSettingsMenuDialog(context, settingsProvider);
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _showSettingsMenuDialog(
      BuildContext context, SettingsProvider settingsProvider) async {
    settingsProvider.setPage(SettingPageState.deviceSetting);

    final bool openedWithLogicalKey =
        HardwareKeyboard.instance.logicalKeysPressed.isNotEmpty;
    if (openedWithLogicalKey) {
      settingsProvider.initFocus();
    }

    bool isSettingsUnLocked = true;

    if (settingsProvider.isSettingsLock) {
      await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return const V3SettingsPasswordDialog();
          }).then((value) {
        isSettingsUnLocked = value;
      });
    }

    if (!(isSettingsUnLocked && context.mounted)) return;

    final route = DialogRoute(
        barrierColor: Colors.transparent,
        context: context,
        builder: (_) =>
            V3SettingMenu(openedWithLogicalKey: openedWithLogicalKey),
        barrierDismissible: false);

    navService.setRoute(route);

    await navService.push(route).whenComplete(settingsProvider.clearFocus);
  }
}
