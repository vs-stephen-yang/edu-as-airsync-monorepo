import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/mirror_state_provider.dart';
import 'package:display_flutter/widgets/focus_icon_button.dart';
import 'package:display_flutter/widgets/menu_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class CastSettings extends StatelessWidget {
  const CastSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MirrorStateProvider>(
      builder: (context, mirror, child) {
        mirror.setDeviceName(context.read<ChannelProvider>().displayCode);
        return MenuDialog(
          backgroundColor: MirrorStateProvider.isMirroring
              ? AppColors.primary_grey_tran
              : AppColors.primary_grey,
          topTitleText: S.of(context).main_cast_settings_title,
          content: Column(
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
          ),
        );
      },
    );
  }
}

class CastSettingItem extends StatelessWidget {
  const CastSettingItem(
      {super.key,
      required this.iconData,
      required this.name,
      required this.enabled,
      required this.callback});

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
