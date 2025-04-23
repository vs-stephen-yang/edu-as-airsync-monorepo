import 'dart:io';

import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/v3_demo_provider.dart';
import 'package:display_channel/display_channel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class V3PresentSelectRoleDemo extends StatelessWidget {
  const V3PresentSelectRoleDemo({super.key});

  @override
  Widget build(BuildContext context) {
    V3DemoProvider presentStateProvider =
        Provider.of<V3DemoProvider>(context, listen: false);

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
                        const Size(343, 194),
                        const Size(108, 94)),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildButtons(
                        context,
                        presentStateProvider,
                        const Size(343, 194),
                        const Size(108, 94)),
                  )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildButtons(
                    context,
                    presentStateProvider,
                    const Size(300, 300), const Size(138, 120))),
      ],
    );
  }

  List<Widget> _buildButtons(
      BuildContext context,
      V3DemoProvider presentStateProvider,
      // ChannelProvider channelProvider,
      Size buttonSize,
      Size iconSize) {
    return [
      RoleButton(
        buttonSize: buttonSize,
        iconSize: iconSize,
        name: S.of(context).v3_main_select_role_share,
        iconPath: 'assets/images/v3_ic_select_share.svg',
        onTap: () {
          presentStateProvider.currentRole = JoinIntentType.present;
          presentStateProvider.presentBasicStartDemoPage();
        },
      ),
      const Padding(padding: EdgeInsets.all(8)),
      RoleButton(
        buttonSize: buttonSize,
        iconSize: iconSize,
        name: S.of(context).v3_main_select_role_receive,
        iconPath: 'assets/images/v3_ic_select_receive.svg',
        onTap: () {
          presentStateProvider.currentRole = JoinIntentType.remoteScreen;
          presentStateProvider.presentRemoteScreenDemoPage();
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
