import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:display_flutter/widgets/menu_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:provider/provider.dart';

class CastSettings extends StatelessWidget {
  const CastSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MenuDialog(
      backgroundColor: AppColors.primary_grey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: [
                  FittedBox(
                    fit: BoxFit.fitHeight,
                    child: FocusIconButton(
                      childNotFocus: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.primary_white,
                      ),
                      splashRadius: 20,
                      focusColor: Colors.grey,
                      onClick: () {
                        navService.popUntil('/home');
                      },
                    ),
                  ),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          S.of(context).main_cast_settings_title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary_white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Consumer<MirrorStateProvider>(
                builder: (context, mirror, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Text(
                            S.of(context).main_cast_settings_device_name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            mirror.deviceName,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      CastSettingItem(
                        iconData: Icons.airplay,
                        name: S.of(context).main_cast_settings_airplay,
                        enabled: mirror.airplayEnabled,
                        callback: () {
                          if (!mirror.airplayEnabled) {
                            mirror.startAirPlay();
                          } else {
                            mirror.stopAirPlay();
                          }
                        },
                      ),
                      CastSettingItem(
                        iconData: Icons.cast,
                        name: S.of(context).main_cast_settings_google_cast,
                        enabled: mirror.googleCastEnabled,
                        callback: () {
                          if (mirror.googleCastEnabled) {
                            mirror.stopGoogleCast();
                          } else {
                            mirror.startGoogleCast();
                          }
                        },
                      ),
                      CastSettingItem(
                        iconData: Icons.cast,
                        name: S.of(context).main_cast_settings_miracast,
                        enabled: mirror.miracastEnabled,
                        callback: () {
                          if (mirror.miracastEnabled) {
                            mirror.stopMiracast();
                          } else {
                            mirror.startMiracast();
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CastSettingItem extends StatelessWidget {
  const CastSettingItem(
      {Key? key,
      required this.iconData,
      required this.name,
      required this.enabled,
      required this.callback})
      : super(key: key);

  final IconData iconData;
  final String name;
  final bool enabled;
  final VoidCallback callback;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(iconData, color: Colors.white),
        const SizedBox(width: 5),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        const Spacer(),
        FittedBox(
          fit: BoxFit.fitHeight,
          child: FocusIconButton(
            childNotFocus: Image(
              image: Svg(enabled
                  ? 'assets/images/ic_activate_on.svg'
                  : 'assets/images/ic_activate_off.svg'),
            ),
            splashRadius: 20,
            focusColor: Colors.grey,
            onClick: callback,
          ),
        ),
      ],
    );
  }
}
