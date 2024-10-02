import 'dart:io';

import 'package:display_cast_flutter/assets/tokens/tokens.g.dart';
import 'package:display_cast_flutter/demo/present_present_start_demo.dart';
import 'package:display_cast_flutter/demo/present_select_role_demo.dart';
import 'package:display_cast_flutter/demo/remote_screen_widget_demo.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/demo_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/log.dart';
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
        Widget _mainContent;

        if (!demo.isDemoMode) {
          log.info('PresentState: ${present.currentState}');
          FlutterWindowClose.setWindowShouldCloseHandler(() async {
            await channel.presentStop();
            await channel.presentEnd(goIdleState: false);
            return true;
          });

          switch (present.currentState) {
            case ViewState.idle:
              _mainContent = V3PresentIdle();
            case ViewState.selectRole:
            // _mainContent = const PresentSelectRole();
            case ViewState.moderatorName:
            case ViewState.moderatorWait:
            case ViewState.waitReady:
            case ViewState.selectScreen:
            case ViewState.presentStart:
            case ViewState.moderatorStart:
            case ViewState.moderatorShare:
            case ViewState.remoteScreen:
            case ViewState.settings:
            case ViewState.language:
            case ViewState.deviceList:
            default:
              _mainContent = const SizedBox();
          }
        } else {
          switch (demo.state) {
            case DemoViewState.off:
              _mainContent = const SizedBox();
            case DemoViewState.selectRole:
              _mainContent = const PresentSelectRoleDemo();
            case DemoViewState.presentStart:
              _mainContent = PresentPresentStartDemo();
            case DemoViewState.remoteScreen:
              _mainContent = const RemoteScreenDemo();
          }
        }
        // _mainContent =  const SizedBox();

        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            V3Background(),
            _mainContent,
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
            color: context.tokens.color.vsdslColorSurface900,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: context.tokens.color.vsdslColorNeutral,
              ),
              borderRadius: context.tokens.radii.vsdslRadiusFull,
            ),
            shadows: context.tokens.shadow.vsdslShadowNeutralSm,
          ),
          child: IconButton(
            color: Colors.black,
            icon: SvgPicture.asset('assets/images/v3_ic_setting.svg'),
            onPressed: () {},
          ),
        ));
  }
}
