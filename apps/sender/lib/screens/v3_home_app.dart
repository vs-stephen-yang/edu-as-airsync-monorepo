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
import 'package:display_cast_flutter/widgets/language.dart';
import 'package:display_cast_flutter/widgets/moderator_idle.dart';
import 'package:display_cast_flutter/widgets/moderator_present_start.dart';
import 'package:display_cast_flutter/widgets/moderator_share.dart';
import 'package:display_cast_flutter/widgets/moderator_wait.dart';
import 'package:display_cast_flutter/widgets/present_present_start.dart';
import 'package:display_cast_flutter/widgets/present_select_role.dart';
import 'package:display_cast_flutter/widgets/present_select_screen.dart';
import 'package:display_cast_flutter/widgets/present_wait_ready.dart';
import 'package:display_cast_flutter/widgets/remote_screen_widget.dart';
import 'package:display_cast_flutter/widgets/settings.dart';
import 'package:display_cast_flutter/widgets/v3_background.dart';
import 'package:display_cast_flutter/widgets/v3_present_idle.dart';
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
      child: Consumer3<PresentStateProvider, ChannelProvider, DemoProvider>(
          builder: (context, present, channel, demo, child) {
        Widget mainContent;

        if (!demo.isDemoMode) {
          log.info('PresentState: ${present.currentState}');
          FlutterWindowClose.setWindowShouldCloseHandler(() async {
            await channel.presentStop();
            await channel.presentEnd(goIdleState: false);
            return true;
          });

          switch (present.currentState) {
            case ViewState.idle:
              mainContent = const V3PresentIdle();
              break;
            case ViewState.selectRole:
              mainContent = const PresentSelectRole();
              break;
            case ViewState.moderatorName:
              mainContent = const ModeratorIdle();
              break;
            case ViewState.moderatorWait:
              mainContent = const ModeratorWait();
              break;
            case ViewState.waitReady:
              mainContent = const PresentWaitReady();
              break;
            case ViewState.selectScreen:
              mainContent = const PresentSelectScreen();
              break;
            case ViewState.presentStart:
              mainContent = PresentPresentStart();
              break;
            case ViewState.moderatorStart:
              mainContent = ModeratorPresentStart();
              break;
            case ViewState.moderatorShare:
              mainContent = const ModeratorPresentShare();
              break;
            case ViewState.remoteScreen:
              mainContent = const RemoteScreenWidget();
              break;
            case ViewState.settings:
              mainContent = const Settings();
              break;
            case ViewState.language:
              mainContent = const Language();
              break;
            case ViewState.deviceList:
              mainContent = const DeviceList();
              break;
            default:
              mainContent = const SizedBox();
              break;
          }
        } else {
          switch (demo.state) {
            case DemoViewState.off:
              mainContent = const SizedBox();
              break;
            case DemoViewState.selectRole:
              mainContent = const PresentSelectRoleDemo();
              break;
            case DemoViewState.presentStart:
              mainContent = PresentPresentStartDemo();
              break;
            case DemoViewState.remoteScreen:
              mainContent = const RemoteScreenDemo();
              break;
          }
        }

        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            const V3Background(),
            mainContent,
            _settingMenu(context),
          ],
        );
      }),
    );
  }

  Widget _settingMenu(BuildContext context) {
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
