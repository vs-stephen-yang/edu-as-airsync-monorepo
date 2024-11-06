import 'dart:io';

import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/app_analytics.dart';
import 'package:display_cast_flutter/utilities/channel_util.dart';
import 'package:display_cast_flutter/widgets/toast.dart';
import 'package:display_channel/display_channel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class V3PresentSelectRole extends StatelessWidget {
  const V3PresentSelectRole({super.key});

  @override
  Widget build(BuildContext context) {
    PresentStateProvider presentStateProvider =
        Provider.of<PresentStateProvider>(context, listen: false);
    ChannelProvider channelProvider =
        Provider.of<ChannelProvider>(context, listen: false);

    bool isMobile = Platform.isAndroid || Platform.isIOS;
    MediaQueryData mediaQuery = MediaQuery.of(context);
    bool useColumn =
        Platform.isIOS || (Platform.isAndroid && mediaQuery.size.width < 768);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          S.of(context).v3_main_select_role_title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.tokens.color.vsdswColorOnSurface,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.24,
          ),
        ),
        Padding(padding: EdgeInsets.only(top: isMobile ? 32 : 60)),
        isMobile
            ? useColumn
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildButtons(
                        context,
                        presentStateProvider,
                        channelProvider,
                        const Size(343, 194),
                        const Size(108, 94)),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildButtons(
                        context,
                        presentStateProvider,
                        channelProvider,
                        const Size(343, 194),
                        const Size(108, 94)),
                  )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildButtons(
                    context,
                    presentStateProvider,
                    channelProvider,
                    const Size(360, 320),
                    const Size(138, 120))),
      ],
    );
  }

  List<Widget> _buildButtons(
      BuildContext context,
      PresentStateProvider presentStateProvider,
      ChannelProvider channelProvider,
      Size buttonSize,
      Size iconSize) {
    return [
      RoleButton(
        buttonSize: buttonSize,
        iconSize: iconSize,
        name: S.of(context).v3_main_select_role_share,
        iconPath: 'assets/images/v3_ic_select_share.svg',
        onTap: () {
          trackEvent('click_share', EventCategory.session);

          channelProvider.currentRole = JoinIntentType.present;
          if (channelProvider.moderatorStatus) {
            presentStateProvider.presentModeratorNamePage();
          } else {
            if (channelProvider.isConnectAvailable()) {
              channelProvider.beginBasicMode();
              if (channelProvider.authorizeStatus) {
                presentStateProvider.presentAuthorizeWaitPage();
              }
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
      const Padding(padding: EdgeInsets.all(8)),
      RoleButton(
        buttonSize: buttonSize,
        iconSize: iconSize,
        name: S.of(context).v3_main_select_role_receive,
        iconPath: 'assets/images/v3_ic_select_receive.svg',
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
    ];
  }
}

class RoleButton extends StatelessWidget {
  const RoleButton({
    super.key,
    required this.buttonSize,
    required this.iconSize,
    required this.name,
    required this.iconPath,
    required this.onTap,
  });

  final Size buttonSize;
  final Size iconSize;

  final String name;
  final String iconPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: buttonSize.width,
        height: buttonSize.height,
        decoration: BoxDecoration(
          color: context.tokens.color.vsdswColorSurface100,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(24),
          boxShadow: context.tokens.shadow.vsdswShadowNeutralLg,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
                width: iconSize.width,
                height: iconSize.height,
                child: SvgPicture.asset(iconPath)),
            const SizedBox(height: 16),
            Text(
              name,
              style: TextStyle(
                color: context.tokens.color.vsdswColorOnSurface,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            )
          ],
        ),
      ),
    );
  }
}
