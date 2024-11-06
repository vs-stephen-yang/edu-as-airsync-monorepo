import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/utilities/app_constants.dart';
import 'package:display_cast_flutter/utilities/channel_util.dart';
import 'package:display_cast_flutter/widgets/toast.dart';
import 'package:display_channel/display_channel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class PresentSelectRole extends StatelessWidget {
  const PresentSelectRole({super.key});

  @override
  Widget build(BuildContext context) {
    PresentStateProvider presentStateProvider =
        Provider.of<PresentStateProvider>(context, listen: false);
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RoleItem(
          name: S.of(context).present_role_receive,
          iconWidget: const Image(image: Svg('assets/images/ic_receiver.svg')),
          onTap: () {
            trackEvent('click_receive', EventCategory.session);

            channelProvider.currentRole = JoinIntentType.remoteScreen;
            if (channelProvider.isConnectAvailable()) {
              presentStateProvider.presentModeratorNamePage();
            } else {
              Toast.makeFeatureReconnectToast(
                  channelProvider.reconnectState,
                  channelProvider.reconnectState ==
                          ChannelReconnectState.reconnecting
                      ? S.of(context).main_feature_reconnecting_toast
                      : S.of(context).main_feature_reconnect_fail_toast);
            }
          },
        ),
        const SizedBox(width: 10),
        RoleItem(
          name: S.of(context).present_role_cast_screen,
          iconWidget:
              const Image(image: Svg('assets/images/ic_cast_screen.svg')),
          onTap: () async {
            trackEvent('click_share', EventCategory.session);

            channelProvider.currentRole = JoinIntentType.present;
            if (channelProvider.moderatorStatus) {
              presentStateProvider.presentModeratorNamePage();
            } else {
              if (channelProvider.isConnectAvailable()) {
                channelProvider.beginBasicMode();
              } else {
                Toast.makeFeatureReconnectToast(
                    channelProvider.reconnectState,
                    channelProvider.reconnectState ==
                            ChannelReconnectState.reconnecting
                        ? S.of(context).main_feature_reconnecting_toast
                        : S.of(context).main_feature_reconnect_fail_toast);
              }
            }
          },
        ),
      ],
    );
  }
}

class RoleItem extends StatelessWidget {
  const RoleItem(
      {super.key,
      required this.name,
      required this.iconWidget,
      required this.onTap});

  final String name;
  final Widget iconWidget;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(8),
              // color: Colors.transparent,
            ),
            child: iconWidget,
          ),
          const SizedBox(height: 5),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: AppConstants.fontSizeTitle,
            ),
          )
        ],
      ),
    );
  }
}
