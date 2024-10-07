import 'dart:io';

import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/demo/present_present_start_demo.dart';
import 'package:display_cast_flutter/demo/present_select_role_demo.dart';
import 'package:display_cast_flutter/demo/remote_screen_widget_demo.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/demo_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/log.dart';
import 'package:display_cast_flutter/widgets/device_list.dart';
import 'package:display_cast_flutter/widgets/moderator_idle.dart';
import 'package:display_cast_flutter/widgets/moderator_present_start.dart';
import 'package:display_cast_flutter/widgets/moderator_share.dart';
import 'package:display_cast_flutter/widgets/moderator_wait.dart';
import 'package:display_cast_flutter/widgets/present_present_start.dart';
import 'package:display_cast_flutter/widgets/present_select_screen.dart';
import 'package:display_cast_flutter/widgets/present_wait_ready.dart';
import 'package:display_cast_flutter/widgets/remote_screen_widget.dart';
import 'package:display_cast_flutter/widgets/v3_background.dart';
import 'package:display_cast_flutter/widgets/v3_present_idle.dart';
import 'package:display_cast_flutter/widgets/v3_present_select_role.dart';
import 'package:display_cast_flutter/widgets/v3_qrcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:provider/provider.dart';

class V3HomeApp extends StatelessWidget {
  const V3HomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: Consumer2<PresentStateProvider, DemoProvider>(
          builder: (context, presentStateProvider, demoProvider, child) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            const V3Background(),
            V3PresentStateMachine(
              presentStateProvider: presentStateProvider,
              demoProvider: demoProvider,
            ),
            if (presentStateProvider.currentState == ViewState.idle)
              const SettingMenu(),
          ],
        );
      }),
    );
  }
}

class V3PresentStateMachine extends StatelessWidget {
  const V3PresentStateMachine({
    super.key,
    required this.presentStateProvider,
    required this.demoProvider,
  });

  final PresentStateProvider presentStateProvider;
  final DemoProvider demoProvider;

  @override
  Widget build(BuildContext context) {
    if (!demoProvider.isDemoMode) {
      log.info('PresentState: ${presentStateProvider.currentState}');
      FlutterWindowClose.setWindowShouldCloseHandler(() async {
        ChannelProvider channelProvider =
            Provider.of<ChannelProvider>(context, listen: false);
        await channelProvider.presentStop();
        await channelProvider.presentEnd(goIdleState: false);
        return true;
      });

      switch (presentStateProvider.currentState) {
        case ViewState.idle:
          return const V3PresentIdle();
        case ViewState.selectRole:
          return const V3PresentSelectRole();
        case ViewState.moderatorName:
          return const ModeratorIdle();
        case ViewState.moderatorWait:
          return const ModeratorWait();
        case ViewState.waitReady:
          return const PresentWaitReady();
        case ViewState.selectScreen:
          return const PresentSelectScreen();
        case ViewState.presentStart:
          return PresentPresentStart();
        case ViewState.moderatorStart:
          return ModeratorPresentStart();
        case ViewState.moderatorShare:
          return const ModeratorPresentShare();
        case ViewState.remoteScreen:
          return const RemoteScreenWidget();
        case ViewState.deviceList:
          return const DeviceList();
        case ViewState.qrScanner:
          return const V3QRcodeScan();
        default:
          return const SizedBox();
      }
    } else {
      switch (demoProvider.state) {
        case DemoViewState.off:
          return const SizedBox();
        case DemoViewState.selectRole:
          return const PresentSelectRoleDemo();
        case DemoViewState.presentStart:
          return PresentPresentStartDemo();
        case DemoViewState.remoteScreen:
          return const RemoteScreenDemo();
      }
    }
  }
}

class SettingMenu extends StatelessWidget {
  const SettingMenu({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = Platform.isAndroid || Platform.isIOS;
    return Positioned(
        left: isMobile ? null : 24,
        top: isMobile ? 24 : null,
        right: isMobile ? 8 : null,
        bottom: isMobile ? null : 24,
        child: Container(
          width: 48,
          height: 48,
          decoration: ShapeDecoration(
            color: context.tokens.color.vsdswColorSurface900,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: context.tokens.color.vsdswColorNeutral,
              ),
              borderRadius: context.tokens.radii.vsdswRadiusFull,
            ),
            shadows: context.tokens.shadow.vsdswShadowNeutralLg,
          ),
          child: IconButton(
            color: context.tokens.color.vsdswColorNeutral,
            icon: SvgPicture.asset('assets/images/v3_ic_setting.svg'),
            onPressed: () {},
          ),
        ));
  }
}
