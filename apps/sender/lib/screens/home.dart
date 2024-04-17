import 'package:display_cast_flutter/demo/present_present_start_demo.dart';
import 'package:display_cast_flutter/demo/present_select_role_demo.dart';
import 'package:display_cast_flutter/demo/remote_screen_widget_demo.dart';
import 'package:display_cast_flutter/providers/channel_provider.dart';
import 'package:display_cast_flutter/providers/demo_provider.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/app_colors.dart';
import 'package:display_cast_flutter/utilities/debug_mode_print.dart';
import 'package:display_cast_flutter/widgets/app_retain.dart';
import 'package:display_cast_flutter/widgets/bottom_bar.dart';
import 'package:display_cast_flutter/widgets/device_list.dart';
import 'package:display_cast_flutter/widgets/language.dart';
import 'package:display_cast_flutter/widgets/moderator_idle.dart';
import 'package:display_cast_flutter/widgets/moderator_present_start.dart';
import 'package:display_cast_flutter/widgets/moderator_wait.dart';
import 'package:display_cast_flutter/widgets/present_idle.dart';
import 'package:display_cast_flutter/widgets/present_present_start.dart';
import 'package:display_cast_flutter/widgets/present_select_role.dart';
import 'package:display_cast_flutter/widgets/present_select_screen.dart';
import 'package:display_cast_flutter/widgets/present_wait_ready.dart';
import 'package:display_cast_flutter/widgets/remote_screen_widget.dart';
import 'package:display_cast_flutter/widgets/settings.dart';
import 'package:display_cast_flutter/widgets/title_bar.dart';
import 'package:display_channel/display_channel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return AppRetain(
      child: SafeArea(
        child: Scaffold(
          body: ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: Container(
              decoration: const BoxDecoration(
                  gradient: RadialGradient(
                      center: Alignment(0, -0.7),
                      radius: 1,
                      colors: [
                        AppColors.homeBackground,
                        Colors.black,
                      ])),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: TitleBar(),
                  ),
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: BottomBar(),
                  ),
                  Consumer2<ChannelProvider, DemoProvider>(builder: (context, channel, demo, child) {
                    if (!demo.isDemoMode) {
                      debugModePrint('PresentState: ${channel.state}');
                      if (!kIsWeb) {
                        FlutterWindowClose.setWindowShouldCloseHandler(() async {
                          await channel.presentStop();
                          await channel.presentEnd(goIdleState: false);
                          return true;
                        });
                      }
                      switch (channel.state) {
                        case ViewState.idle:
                          return PresentIdle();
                        case ViewState.selectRole:
                          if (kIsWeb) {
                            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                              channel.currentRole = JoinIntentType.present;
                              if (channel.moderatorStatus) {
                                channel.presentModeratorNamePage();
                              } else {
                                channel.beginBasicMode();
                              }
                            });
                            return const SizedBox();
                          } else {
                            return const PresentSelectRole();
                          }
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
                        case ViewState.remoteScreen:
                          return const RemoteScreenWidget();
                        case ViewState.settings:
                          return const Settings();
                        case ViewState.language:
                          return const Language();
                        case ViewState.deviceList:
                          return const DeviceList();
                        default:
                          return const SizedBox();
                      }
                    } else {
                      switch (demo.state) {
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
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
